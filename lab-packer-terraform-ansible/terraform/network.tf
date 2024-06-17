resource "google_compute_network" "network" {
    name = "fast-network"
    auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
    name          = "fast-subnet"
    ip_cidr_range = "10.0.1.0/24"
    network       = google_compute_network.network.name
    region        = var.google_region
}

