#!/bin/bash

echo "running the script"

#running terraform

cd infrastructure/
terraform init
terraform validate
terraform apply

#creates an ssh key if their isnt one present

echo "checking for ssh key otherwise creating one"

#defines the path for the ssh key
path_to_ssh_key=~/.ssh/foo_ec2_key

if [ ! -e "${path_to_ssh_key}" ]
then
	echo "Creating SSH key ${path_to_ssh_key}..."
	ssh-keygen -f "${path_to_ssh_key}" -N ''
else
    echo "SSH key ${path_to_ssh_key} already exists."

fi