resource "google_compute_instance" "my_instance" {
  provider = google
  name = "terraform-ansible-instance"
  machine_type = var.google_instance_type
  allow_stopping_for_update = true
  zone = var.google_zone
  metadata = {
    ssh-keys = "ansible:${file(var.ssh_key_path_default_user)}"
  }

  network_interface {
    network = var.google_network
    access_config {}
  }

  tags = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = var.google_instance_image
    }
  }

  # provisioner "local-exec" {
  #   command = <<EOT
  #     sed -i '' 's/NAT_IP/${self.network_interface.0.access_config.0.nat_ip}/' ../ansible/inventory/main.yml
  #   EOT
  # }
  provisioner "local-exec" {
    command = "echo 'terraform-instance ansible_port=22 ansible_host=${self.network_interface.0.access_config.0.nat_ip} ansible_user=ansible ansible_ssh_private_key_file=${var.ssh_key_path_default_user}'' >> ../ansible/inventory.yml"
  }

}
