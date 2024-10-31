terraform {

  required_version = "1.9.8"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.83.0"
    }
  }
  
  backend "local" {
    path = "terraform.tfstate"
  } 
  
  # export GOOGLE_CLOUD_KEYFILE_JSON=/Users/crisapolinario/GitHub/Engenharia-de-Plataforma-FAST/fast-iac/lab-terraform-ansible/terraform/credential.json
  # export GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_CLOUD_KEYFILE_JSON

  # backend "gcs" {
  #   bucket  = "bucket-statefile-fast2024"
  #   prefix  = "terraform/state"
  # }

}