provider "google" {
  credentials = file("./credential.json")

  project = var.google_project_number
  region  = var.google_region
  zone    = var.google_zone
}