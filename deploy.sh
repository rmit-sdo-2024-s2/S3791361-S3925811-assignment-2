#!/bin/bash
#
# Deploy Foo app - see README.md
#

!/bin/bash
echo "running the script"
cd infrastructure/
terraform init
terraform validate
terraform apply
