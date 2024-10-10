# COSC2759 Assignment 2

## Student details

- Full Name: Bailey Liebler, Isaac Kelly
- Student ID: S3791361, S3925811

## Solution design


### Infrastructure


#### Key data flows

process diagram and infrastructure architecture diagram

### Deployment process

#### Prerequisites

To run this application you must have:
- AWS
- A computer running Ubuntu (22.04 recommended)
	- with the repository in it 
- Terraform
- Ansible
- Docker
    
to install terraform we used:
sudo snap terraform --classic

#### Running the applications

##### Section A

- First we edited the main.tf and add our access_key, secret_key and our token.
- This allows us to connect to the AWS server.
- Then we ran.
- "Terraform init"
- Which created the terraform files.
- We then added our ip address into the you.auto.tfvars which allow us to connect to the AWS server followed by running
- "terraform apply"
- Followed by "yes" to accept the command.
- Which started the terraform and connected to the AWS server and created a EC2 instance on it.

we can now ssh into the server

##### Section B

##### Section C



#### Description of the GitHub Actions workflow

Section D Info

No credentials stored in git repo. place them in the workflow

#### Backup process: deploying from a shell script

Note: If you attempt the "HD" part of this assignment, also include a standalone shell script which performs the deployment. Use your README file to explain which file does what.

#### Validating that the app is working

How to connect to the app

## Contents of this repo


