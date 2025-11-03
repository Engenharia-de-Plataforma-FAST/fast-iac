# =============================================================================
# TERRAFORM CONFIGURATION
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

# =============================================================================
# MODULES
# =============================================================================

# Networking Module: VPC, Subnets, Gateways, Route Tables
module "networking" {
  source = "./modules/networking"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway

  tags = local.common_tags
}

# Security Module: Security Groups and Rules
module "security" {
  source = "./modules/security"

  name_prefix       = local.name_prefix
  vpc_id            = module.networking.vpc_id
  create_bastion_sg = var.create_bastion
  create_web_sg     = true
  create_alb_sg     = true

  tags = local.common_tags
}

# Compute Module: EC2 Instances (Bastion and Web Servers)
module "compute" {
  source = "./modules/compute"

  name_prefix               = local.name_prefix
  instance_type             = var.instance_type
  instance_ami              = var.instance_ami
  ami_owner                 = var.ami_owner
  create_bastion            = var.create_bastion
  web_server_count          = var.web_server_count
  public_subnet_ids         = module.networking.public_subnet_ids
  private_subnet_ids        = module.networking.private_subnet_ids
  bastion_security_group_id = module.security.bastion_security_group_id
  web_security_group_id     = module.security.web_security_group_id

  tags = local.common_tags

  depends_on = [module.networking, module.security]
}

# Load Balancer Module: ALB, Target Group, Listeners
module "load_balancer" {
  source = "./modules/load-balancer"

  name_prefix           = local.name_prefix
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  web_instance_ids      = module.compute.web_instance_ids

  tags = local.common_tags

  depends_on = [module.compute]
}
