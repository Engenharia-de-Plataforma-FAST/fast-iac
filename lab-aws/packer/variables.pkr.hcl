
# =============================================================================
# SSH Configuration Variables
# =============================================================================

variable "ssh_public_key" {
  description = "SSH public key content for instance access"
  type        = string
}

variable "ssh_private_key_file" {
  description = "Path to SSH private key file for instance access"
  type        = string
  
  validation {
    condition     = can(regex("^[/~].*", var.ssh_private_key_file))
    error_message = "SSH private key file path must be absolute (starting with /) or home-relative (starting with ~)."
  }
}

variable "ssh_username" {
  description = "SSH username for connecting to the instance"
  type        = string
  default     = "ec2-user"
}

# =============================================================================
# AWS Configuration Variables
# =============================================================================

variable "region" {
  description = "AWS region where the AMI will be built"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-central-1", "eu-west-1", "eu-west-2", "eu-west-3",
      "ap-northeast-1", "ap-northeast-2", "ap-southeast-1", "ap-southeast-2",
      "ap-south-1", "ca-central-1", "sa-east-1"
    ], var.region)
    error_message = "Region must be a valid AWS region."
  }
}

variable "aws_profile_name" {
  description = "AWS profile name to use for authentication"
  type        = string
  default     = "default"
}

variable "instance_type" {
  description = "EC2 instance type to use for building the AMI (Free Tier eligible)"
  type        = string
  default     = "t2.micro"
  
  validation {
    condition = contains([
      "t2.micro",
      "t3.micro"
    ], var.instance_type)
    error_message = "Instance type must be AWS Free Tier eligible. Allowed: t2.micro, t3.micro."
  }
}

# =============================================================================
# Image Configuration Variables
# =============================================================================

variable "image_name" {
  description = "Base name for the AMI (timestamp will be appended)"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.image_name)) && length(var.image_name) >= 3 && length(var.image_name) <= 50
    error_message = "Image name must be 3-50 characters long and contain only alphanumeric characters, underscores, and hyphens."
  }
}

variable "image_description" {
  description = "Description for the AMI"
  type        = string
  
  validation {
    condition     = length(var.image_description) >= 10 && length(var.image_description) <= 255
    error_message = "Image description must be between 10 and 255 characters long."
  }
}

# =============================================================================
# Provisioning Configuration Variables
# =============================================================================

variable "ansible_playbook_path" {
  description = "Path to the Ansible playbook file for provisioning"
  type        = string
  
  validation {
    condition     = can(regex("\\.ya?ml$", var.ansible_playbook_path))
    error_message = "Ansible playbook path must point to a .yml or .yaml file."
  }
}

# =============================================================================
# Tagging Variables
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
  description = "Name of the project this AMI belongs to"
  type        = string
  default     = "fast"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.project_name)) && length(var.project_name) >= 2 && length(var.project_name) <= 30
    error_message = "Project name must be 2-30 characters long and contain only alphanumeric characters, underscores, and hyphens."
  }
}

variable "owner" {
  description = "Owner or team responsible for this AMI"
  type        = string
  default     = "DevOps Team"
  
  validation {
    condition     = length(var.owner) >= 3 && length(var.owner) <= 50
    error_message = "Owner must be between 3 and 50 characters long."
  }
}

variable "lab_name" {
  description = "Name of the lab or specific use case for this AMI"
  type        = string
  default     = "Packer"
}
