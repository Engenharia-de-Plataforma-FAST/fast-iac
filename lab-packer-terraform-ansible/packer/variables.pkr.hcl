
variable "ssh_public_key" {
  type = string
}

variable "ssh_private_key_file" {
  type = string
}

variable "ansible_playbook_path" {
  type = string
}

variable "image_name" {
  type = string
}

variable "image_description" {
  type = string
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "aws_profile_name" {
  type = string
  default = "default"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "ssh_username" {
  type = string
}
