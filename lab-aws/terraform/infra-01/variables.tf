variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.region))
    error_message = "Region must be a valid AWS region format (e.g., us-east-1)."
  }
}

variable "instance_type" {
  description = "EC2 Instance Type (Free tier eligible)"
  type        = string
  default     = "t2.micro"
  
  validation {
    condition = contains([
      "t2.micro",    # Free tier eligible
      "t3.micro",    # Free tier eligible in most regions
      "t4g.micro"    # Free tier eligible ARM-based
    ], var.instance_type)
    error_message = "Instance type must be a free tier eligible type: t2.micro, t3.micro, or t4g.micro"
  }
}

variable "instance_ami" {
  description = "Instance AMI"
  type        = string
  default     = "al2023-ami*x86_64"
}

variable "ami_owner" {
  description = "AMI Owner (amazon for AWS AMIs, self for custom AMIs)"
  type        = string
  default     = "amazon"
}

variable "key_name" {
  description = "SSH Key Name for web server"
  type        = string
  default     = "fast-web-key"
}

variable "aws_profile_name" {
  description = "AWS Profile Name"
  type        = string
  default     = "batatinha"
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
  
  validation {
    condition     = length(var.allowed_ssh_cidrs) > 0
    error_message = "At least one CIDR block must be specified for SSH access"
  }
  
  validation {
    condition = alltrue([
      for cidr in var.allowed_ssh_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All values must be valid CIDR blocks (e.g., 192.168.1.0/24 or 10.0.0.1/32)"
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
  default     = "fast"
}

variable "owner" {
  description = "Owner team or person responsible for resources"
  type        = string
  default     = "DevOps Team"
}

variable "lab_name" {
  description = "Lab identifier for tagging"
  type        = string
  default     = "Lab1"
}