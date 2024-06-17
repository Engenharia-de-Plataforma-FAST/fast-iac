
variable "ssh_public_key" {
  type = string
}

variable "ssh_private_key_file" {
  type = string
}

variable "google_project_id" {
  type = string
}

variable "google_zone" {
  type = string
}

variable "google_machine_type" {
  type = string
}

variable "ansible_playbook_path" {
  type = string
}

variable "project_image_name" {
  type = string
}

variable "project_image_description" {
  type = string
}
