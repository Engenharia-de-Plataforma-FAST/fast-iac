resource "google_storage_bucket" "bucket-statefile" {
  name                        = var.bucket_tfsatefile_name
  location                    = var.google_region
  storage_class               = var.storage_class
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }

  labels = {
    "environment" = "fast2023"
  }

}