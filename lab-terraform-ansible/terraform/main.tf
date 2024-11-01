terraform {

  required_version = "1.9.8"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.83.0"
    }
  }

  backend "gcs" {
    bucket  = "bucket-statefile-fast2024"
    prefix  = "terraform"
  }

}