#!/bin/bash

rm -rf .terraform* || true
rm -rf terraform.tfstate* || true
rm -rf *.tfplan || true
rm -rf *.log || true
rm -rf .terraform.lock.hcl || true