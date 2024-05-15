resource "google_compute_instance" "default" {
  provider = google
  name = "terraform-ansible-instance"
  machine_type = var.google_instance_type
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
  
}