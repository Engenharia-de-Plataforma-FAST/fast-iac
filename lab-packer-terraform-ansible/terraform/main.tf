terraform {

  required_version = "1.5.7"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.83.0"
    }
  }

#   export GOOGLE_CLOUD_KEYFILE_JSON=~/git/personal/fast2023/terraform/credential.json
#   export GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_CLOUD_KEYFILE_JSON

#   backend "gcs" {
#     bucket  = "bucket-statefile-fast2023-brayner"
#     prefix  = "terraform/state"
#   }

}