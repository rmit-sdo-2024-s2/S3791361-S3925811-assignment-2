# COSC2759 Assignment 2

## Student details

- Full Name: Bailey Liebler, Isaac Kelly
- Student ID: S3791361, S3925811

## Solution design


### Infrastructure


#### Key data flows

process diagram and infrastructure architecture diagram
![Infrastructure diagram](Images/Infrastructure.png "Infrastructure")

![process diagram](Images/process.png "process")
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

- we now can start to configure the server by using Ansible

##### Section B

##### Section C
- First the team created a S3 bucked called foostatebuckets39, this stores the terraform state file. 
- Then a DynamoDB table was created called foostatelock, which was set up for state locking. 
- Then the back end configuration was added to the main.tf file.
- The file was updated to configure terraform to use the S3 bucket and the DynamoDB table. 
- Then terraform was initialised with the command – terraform init -reconfigure
- After this we checked if the state file was stored in the S3 by checking the AWS management console. 
- We did the same with DynamoDB table to ensure foostatelock was active and being use. 



#### Description of the GitHub Actions workflow

Section D Info

No credentials stored in git repo. place them in the workflow

#### Backup process: deploying from a shell script

Note: If you attempt the "HD" part of this assignment, also include a standalone shell script which performs the deployment. Use your README file to explain which file does what.

#### Validating that the app is working

How to connect to the app

One way to check if the server is running is that we can ssh into by running
- ssh ec2-user@${IP_ADDRESS} -i ~/.ssh/foo_ec2_key

another way is once ansible is running we will be able to connect to the sererv via http

## Contents of this repo


