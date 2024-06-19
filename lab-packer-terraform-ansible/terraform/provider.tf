provider "aws" {
  region  = var.region
  profile = "fast"

 default_tags {
   tags = {
     Environment = "Dev"
     Owner       = "Terraform"
     Project     = "FAST"
   }
 }
}