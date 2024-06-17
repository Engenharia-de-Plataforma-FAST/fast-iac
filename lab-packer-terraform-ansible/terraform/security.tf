resource "google_compute_firewall" "allow-http-services" {
  name    = "allow-http-services"
  network = google_compute_network.network.name

  allow {
    protocol = "tcp"
    ports    = ["8080", "9000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["allow-http-services"]
  direction   = "INGRESS"

}

resource "google_compute_firewall" "allow-ssh" {
  name    = "fast-allow-ssh"
  network = google_compute_network.network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["allow-ssh"]
  direction   = "INGRESS"
}
