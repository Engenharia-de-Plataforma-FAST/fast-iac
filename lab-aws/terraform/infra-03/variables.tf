# =============================================================================
# AWS CONFIGURATION VARIABLES
# =============================================================================

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.region))
    error_message = "Region must be a valid AWS region format (e.g., us-east-1)."
  }
}

variable "aws_profile_name" {
  description = "AWS Profile Name"
  type        = string
  default     = "batatinha"
}

# =============================================================================
# NETWORKING VARIABLES
# =============================================================================

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.4.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "At least 2 public subnets are required for ALB."
  }
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) >= 1
    error_message = "At least 1 private subnet is required."
  }
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

# =============================================================================
# COMPUTE VARIABLES
# =============================================================================

variable "instance_type" {
  description = "EC2 Instance Type (Free tier eligible)"
  type        = string
  default     = "t2.micro"

  validation {
    condition = contains([
      "t2.micro",
      "t3.micro",
      "t4g.micro"
    ], var.instance_type)
    error_message = "Instance type must be a free tier eligible type: t2.micro, t3.micro, or t4g.micro"
  }
}

variable "instance_ami" {
  description = "Instance AMI name pattern"
  type        = string
  default     = "al2023-ami*x86_64"
}

variable "ami_owner" {
  description = "AMI Owner (amazon for AWS AMIs, self or account ID for custom AMIs)"
  type        = string
  default     = "amazon"
}

variable "create_bastion" {
  description = "Create bastion host"
  type        = bool
  default     = true
}

variable "web_server_count" {
  description = "Number of web servers to create"
  type        = number
  default     = 2

  validation {
    condition     = var.web_server_count >= 1 && var.web_server_count <= 10
    error_message = "Web server count must be between 1 and 10"
  }
}

# =============================================================================
# TAGGING VARIABLES
# =============================================================================

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, test."
  }
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "fast"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "owner" {
  description = "Resource owner"
  type        = string
  default     = "DevOps Team"

  validation {
    condition     = length(var.owner) >= 3 && length(var.owner) <= 50
    error_message = "Owner must be between 3 and 50 characters."
  }
}

variable "lab_name" {
  description = "Lab name"
  type        = string
  default     = "Lab6-Modular"
}
