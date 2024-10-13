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

Section A required the deployment of the required infrastructure using Terraform, the configuration of the EC2 instance using Ansible and the automation of the process through a shell script. 
Terraform was used to provision the EC2 instance, security groups and other network configurations. 
Ansible was used to configure the EC2 instance to run on both the Foo app and PostgreSQL in Docker containers. 
The shell script is used to automate the process.
Using Amazon Linux, we were able to run both the app and the data base for the instance. 
Docker was used to ensure that both the app and the database can be deployed consistently and without conflicts. 
Using terraform init, reconfigure and apply, we were able to successfully use Terraform. Ansible was used to configure the EC2 instances once they were provisioned by Terraform. We created the playbook to ensure all containers are installed correctly. 

Justification 
The reason we created the main.tf like we did was to ensure the application would run correctly. There were multiple different editions including we tried to clone the repo on AWS instances, which we later discovered cause numerous other issues. This was the straightforward way we could figure. 

##### Section B
Section B was to enhance the resilience and availability of the application. We deployed the app container on two identical EC2 instances that were placed behind Application Load Balancer. 

The architecture consists of
•	EC2 Instances: Two EC2 instances running the Foo app and one separate EC2 instance for the PostgreSQL database.
•	Load Balancer: An Application Load Balancer is used to distribute traffic between the two app instances.
•	Terraform: Infrastructure as Code using Terraform for provisioning the EC2 instances, load balancer, and security groups.
•	Ansible: Configuration management using Ansible to automate the deployment of Docker containers on the EC2 instances.

Terraform was used to provision infrastructure. Terraform was used to create the following; 
-	Two identical EC2 instances for the app servers
-	One EC2 instance for the PostgreSQL database
-	Application Load Balancer to route traffic to the app servers
-	Security groups to control network access for the app and data base. 
Ansible was used to configure instances. Here is what it was used to create: 
-	Install and configure Docker on EC2 instances
-	Deploy PostgreSQL container on the database instance
-	Deploy the Foo app container on the two app instances
The PostgreSQL is preloaded with the initial data using snapshot-prod-data.sql script. The Foo app is deployed via Docker on the app instances, the app connects to the database via environment variables which are through Ansible. The load balancer then distributes the traffic between the two app instances.

Decisions and justifications 
We used Terraform and Ansible because it allowed for the solution to be modular and easily reproducible. 
It was required for a Application Load Balancer, it allows for traffic to efficiently be distributed between the two instances. It ensures fault tolerance and scalability.
We used Docker for the App and Database containers to ensure consistency between development and production environments. 


##### Section C
Section C focuses on configuring terraform to use an s3 bucket as the remote backend for storing the Terraform state. 

The S3 bucket and DynamoDB table were created to store and manage Terraforms state file and locking mechanism. 
The S3 bucket is used to store the Terraform state file. It ensures the state is persistently store and can be accessed from multiple systems.
The DynamoDB table is used for statelocking, ensuring only one Terraform process can modify the state at a time. This was done to ensure conflict are prevented. 
The main.tf file is the terraform configuration file. The backend is set to S3.
Once the S3 bucket and DynamoDB table were manually created, the following command was run: 
-	Terraform init -reconfigure
This command reconfigures the backed which then points to the S3 bucket and DynamoDB table, which in turn ensures that future Terraform operations are using the correct backend. 
The bucket that is created is called – foostatebuckets39
The Dynamodb table made is called – foostatelock.

Justification 
The reason the team chose to manually create the bucket and table was to avoid issues with Terraform deploying resource while using them at the same time. Creating the bucket and table manually allowed terraform to use the bucket for state storage without and conflicts. 

#### Description of the GitHub Actions workflow

due to time restraints the github actions workflow couldn't be completed.

#### Backup process: deploying from a shell script

we have a shell script that can launch terraform and create a new ssh key if needed.

#### Validating that the app is working

How to connect to the app

One way to check if the server is running is that we can ssh into by running
- ssh ec2-user@${IP_ADDRESS} -i ~/.ssh/foo_ec2_key

another way is once ansible is running we will be able to connect to the sererv via http

## Contents of this repo


