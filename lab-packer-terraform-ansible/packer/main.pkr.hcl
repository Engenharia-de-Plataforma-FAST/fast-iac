packer {
  required_plugins {
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1.1"
    }
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1.1"
    }
  }
}

source "googlecompute" "vm-instance" {
  account_file      = "credential.json"
  image_description = var.project_image_description
  image_family      = "centos-stream-8"
  image_labels = {
    source = "packer"
  }
  image_name   = var.project_image_name
  machine_type = var.google_machine_type
  metadata = {
    ssh-keys = var.ssh_public_key
  }
  project_id              = var.google_project_id
  source_image_family     = "centos-stream-8"
  source_image_project_id = ["centos-cloud"]
  ssh_private_key_file    = var.ssh_private_key_file
  ssh_username            = "centos"
  zone                    = var.google_zone
  tags                    = ["allow-ssh"]
}

build {
  sources = ["source.googlecompute.vm-instance"]

  provisioner "ansible" {
    extra_arguments = ["--extra-vars", "ansible_ssh_common_args='-o StrictHostKeyChecking=no'"]
    playbook_file   = var.ansible_playbook_path
    use_proxy       = false
  }

}
