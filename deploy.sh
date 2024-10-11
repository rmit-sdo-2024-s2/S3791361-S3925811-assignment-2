#!/bin/bash

echo "running the script"
cd infrastructure/
terraform init
terraform validate
terraform apply

echo "checking for ssh key otherwise creating one"

path_to_ssh_key=~/.ssh/foo_ec2_key
if [ ! -e "${path_to_ssh_key}" ]
then
	echo "Creating SSH key ${path_to_ssh_key}..."
	ssh-keygen -f "${path_to_ssh_key}" -N ''
else
    echo "SSH key ${path_to_ssh_key} already exists."

fi