variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "create_bastion_sg" {
  description = "Create bastion host security group"
  type        = bool
  default     = true
}

variable "create_web_sg" {
  description = "Create web server security group"
  type        = bool
  default     = true
}

variable "create_alb_sg" {
  description = "Create ALB security group"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
