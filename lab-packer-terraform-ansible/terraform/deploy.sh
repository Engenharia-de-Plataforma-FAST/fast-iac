#!/bin/sh

terraform init
terraform validate
terraform apply -var-file=input.tfvars -auto-approve
