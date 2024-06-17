#!/bin/sh

terraform init
terraform validate
terraform destroy -var-file=input.tfvars
