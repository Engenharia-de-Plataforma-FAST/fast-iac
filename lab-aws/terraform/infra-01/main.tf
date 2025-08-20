terraform {
  required_version = "~> 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.9"
    }
  }
  
  backend "s3" {
    encrypt = true
  }
}

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

provider "aws" {
  region  = var.region
  profile = var.aws_profile_name
  default_tags {
    tags = local.common_tags
  }
}