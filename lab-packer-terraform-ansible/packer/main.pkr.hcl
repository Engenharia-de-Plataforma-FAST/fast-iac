packer {
  required_plugins {
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1.1"
    }
    amazon = {
      version = ">= 1.3.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "vm-instance" {
  ami_name        = "${var.image_name}-${local.timestamp}"
  ami_description = var.image_description
  instance_type   = var.instance_type
  region          = var.region
  profile         = var.aws_profile_name
  ssh_username    = var.ssh_username
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  tags = {
    Name = "AMI FAST"
  }
}

build {
  sources = ["source.amazon-ebs.vm-instance"]

  provisioner "ansible" {
    extra_arguments = ["--extra-vars", "ansible_ssh_common_args='-o StrictHostKeyChecking=no'"]
    playbook_file   = var.ansible_playbook_path
    use_proxy       = false
  }

}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}
