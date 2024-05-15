#!/bin/sh

packer init .
packer validate -var-file=variables.pkrvars.hcl .
packer build --force -var-file=variables.pkrvars.hcl .

