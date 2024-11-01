resource "google_compute_instance" "my_instance" {
  provider = google
  name = "terraform-ansible-instance"
  machine_type = var.google_instance_type
  allow_stopping_for_update = true
  zone = var.google_zone
  # metadata = {
  #   ssh-keys = "ansible:${file(var.ssh_key_path_default_user)}"
  # }

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
  #     export ANSIBLE_HOST_KEY_CHECKING=False
  #     sleep 120
  #     ansible-playbook -i ../ansible/inventory/main.yml ../ansible/main.yml
  #   EOT
  # }

}
