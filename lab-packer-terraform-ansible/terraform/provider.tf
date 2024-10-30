provider "aws" {
  region  = var.region
  profile = var.aws_profile_name

 default_tags {
   tags = {
     Environment = "Dev"
     Owner       = "Terraform"
     Project     = "FAST"
   }
 }
}