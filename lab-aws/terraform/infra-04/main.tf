# =============================================================================
# TERRAFORM CONFIGURATION - USING OFFICIAL AWS MODULES
# =============================================================================

terraform {
  required_version = "~> 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.9"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }

  backend "s3" {
    encrypt = true
  }
}

# =============================================================================
# LOCALS
# =============================================================================

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Owner       = var.owner
    Lab         = var.lab_name
  }

  name_prefix = "${var.project_name}-${var.environment}"
}

# =============================================================================
# PROVIDER
# =============================================================================

provider "aws" {
  region  = var.region
  profile = var.aws_profile_name
  default_tags {
    tags = local.common_tags
  }
}

# =============================================================================
# DATA SOURCES
# =============================================================================

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "instance_ami" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = [var.instance_ami]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# =============================================================================
# SSH KEY PAIR
# =============================================================================

resource "tls_private_key" "ssh_key" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "main" {
  key_name   = "${local.name_prefix}-keypair"
  public_key = tls_private_key.ssh_key.public_key_openssh

  tags = {
    Name = "${local.name_prefix}-keypair"
  }
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_openssh
  filename        = "${path.root}/${local.name_prefix}-key.pem"
  file_permission = "0400"
}

# =============================================================================
# VPC MODULE - Official AWS Module
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws
# =============================================================================

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.5"

  name = "${local.name_prefix}-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }

  public_subnet_tags = {
    Type = "Public"
  }

  private_subnet_tags = {
    Type = "Private"
  }
}

# =============================================================================
# SECURITY GROUP MODULES - Official AWS Modules
# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws
# =============================================================================

# Bastion Security Group
module "bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  count = var.create_bastion ? 1 : 0

  name        = "${local.name_prefix}-sg-bastion"
  description = "Security group for bastion host"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH from anywhere"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_rules = ["all-all"]

  tags = {
    Name = "${local.name_prefix}-sg-bastion"
    Role = "Bastion"
  }
}

# Web Server Security Group
module "web_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name        = "${local.name_prefix}-sg-web"
  description = "Security group for web servers"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  ingress_with_source_security_group_id = var.create_bastion ? [
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "SSH from bastion"
      source_security_group_id = module.bastion_sg[0].security_group_id
    }
  ] : []

  egress_rules = ["all-all"]

  tags = {
    Name = "${local.name_prefix}-sg-web"
    Role = "WebServer"
  }
}

# ALB Security Group
module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name        = "${local.name_prefix}-sg-alb"
  description = "Security group for Application Load Balancer"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP from anywhere"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_rules = ["all-all"]

  tags = {
    Name = "${local.name_prefix}-sg-alb"
    Role = "LoadBalancer"
  }
}

# =============================================================================
# EC2 INSTANCE MODULES - Official AWS Module
# https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws
# =============================================================================

# Bastion Host
module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.1"

  count = var.create_bastion ? 1 : 0

  name = "${local.name_prefix}-bastion"

  ami                         = data.aws_ami.instance_ami.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.main.key_name
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [module.bastion_sg[0].security_group_id]
  associate_public_ip_address = true

  tags = {
    Name = "${local.name_prefix}-bastion"
    Role = "Bastion"
  }
}

# Web Servers
module "web_servers" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.1"

  count = var.web_server_count

  name = "${local.name_prefix}-web-${count.index + 1}"

  ami                    = data.aws_ami.instance_ami.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.main.key_name
  subnet_id              = module.vpc.private_subnets[count.index % length(module.vpc.private_subnets)]
  vpc_security_group_ids = [module.web_sg.security_group_id]

  tags = {
    Name = "${local.name_prefix}-web-${count.index + 1}"
    Role = "WebServer"
  }
}

# =============================================================================
# APPLICATION LOAD BALANCER MODULE - Official AWS Module
# https://registry.terraform.io/modules/terraform-aws-modules/alb/aws
# =============================================================================

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.11"

  name = "${local.name_prefix}-alb"

  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [module.alb_sg.security_group_id]

  enable_deletion_protection = false

  # Target Group
  target_groups = {
    web = {
      name_prefix      = "web-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200"
      }

      # Attach first instance directly
      target_id = var.web_server_count > 0 ? module.web_servers[0].id : null
      port      = 80
    }
  }

  # Attach additional instances
  additional_target_group_attachments = var.web_server_count > 1 ? {
    for idx in range(1, var.web_server_count) : "web-${idx}" => {
      target_group_key = "web"
      target_id        = module.web_servers[idx].id
      port             = 80
    }
  } : {}

  # Listener
  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "web"
      }
    }
  }

  tags = {
    Name = "${local.name_prefix}-alb"
  }
}
