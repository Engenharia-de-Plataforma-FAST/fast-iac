variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_ami" {
  description = "AMI name pattern to search for"
  type        = string
  default     = "al2023-ami*x86_64"
}

variable "ami_owner" {
  description = "AMI owner (amazon or account ID for custom AMIs)"
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

variable "public_subnet_ids" {
  description = "List of public subnet IDs for bastion"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for web servers"
  type        = list(string)
}

variable "bastion_security_group_id" {
  description = "Security group ID for bastion host"
  type        = string
}

variable "web_security_group_id" {
  description = "Security group ID for web servers"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
