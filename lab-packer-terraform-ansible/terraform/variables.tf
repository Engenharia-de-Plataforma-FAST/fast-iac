variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Instance Type"
  type        = string
  default     = "t2.micro"
}

variable "instance_ami" {
  description = "Instance AMI"
  type        = string
  default     = "fast-20241029230820"
#   default     = "al2023-ami*x86_64"
}

variable "key_name" {
  description = "Key Name"
  type        = string
  default     = "fast"
}

variable "aws_profile_name" {
  description = "AWS Profile Name"
  type        = string
  default     = "batatinha"
}
