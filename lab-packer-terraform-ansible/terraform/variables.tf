variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Instance Type"
  type        = string
  default     = "t3.micro"
}

variable "instance_ami" {
  description = "Instance AMI"
  type        = string
  default     = "fast-20240617203935"
}

variable "key_name" {
  description = "Key Name"
  type        = string
  default     = "fast"
}

