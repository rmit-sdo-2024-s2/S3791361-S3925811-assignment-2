# Defines the provider - AWS
provider "aws" {
  region     = "us-east-1"
  access_key = "ASIA6GF37BXSYLHYOYPA"
  secret_key = "iZLnX9/gxZvlIHWkeLnFxtsgfsTpydYxvv4hymWm"
  token      = "IQoJb3JpZ2luX2VjEC8aCXVzLXdlc3QtMiJIMEYCIQCuH+EYk6vL3edQDlySyLV0Evr2XnWZZZXI7seFW6OIawIhALrE+bEheyUbegk/pOBH0t6I3X/mDKuxh6umEaAK3uvxKq4CCIj//////////wEQABoMOTc1MzUxNzc4Nzg5IgzRe7rRw6qdq2pwo8kqggKwR46HpJLHGQOESYGJHuE+XBzmwiTNJ7ISiEWr+KpJ5LeW4EvsPnZG/+NHnVpOr+OHJZZTx5D9JnlFJCafEEVF0E763FCxpYvHAK+nvTuF8yhLeuQoQs6kwWgDVCSountrHcO9iKUXzppdWf0tm4Qn+2bkMrhkRCUVoNBVrJkaxMs+bSBC9Oiq62hdC16KARXI2K8DH5763lfp8SlShGCSH2PPrq4HAN72vB1o+Olb+MilVJExVxFM76dGVqMo8OIrMGYm5vdGs4l7P6Hb2oLiKKb2aGnz5Yjhe1K/IprlmLzeWqIYVC99UpsXW8fYQqrRRN9yrAICHYTnHEkSkyHbElowiJKjuAY6nAFYn6msQY6fOybnKdAwRy9VWXWcJ9EW+VkbH7VEqKPrgK8qP9pf8R5eYH3ZWHRJA74QeCFdkHhJpTam94TsBP6RjNjVC9nCTiPkmT3X5Mdww4izw2ratmMRBtrY+cb+G/UElXxeFWF2tGhd1iMDdpaCD2OIf2KXwlzKG7AIUhHg/xMeFK09R3rEh6evOzYsCe48j+1zHFwOZue+C7Q="
}


# Terraform S3 backend configuration
terraform {
  backend "s3" {
    bucket         = "foostatebuckets39"
    key            = "terraform/state"
    region         = "us-east-1"
    dynamodb_table = "foostatelock"
  }
}

# Define the key pair
resource "aws_key_pair" "deployer_key" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Create a security group for the EC2 instance
resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg"
#This will allow for ssh from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

#This will allow for HTTP traffic from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

#I think this will allow traffic on port 3001
  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }


#This will allow for all outbound traffic 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
  }
}



# Create an EC2 instance
resource "aws_instance" "web" {
  ami           = "ami-0fff1b9a61dec8a5f" 
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer_key.key_name

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker

    # Run PostgreSQL container
    sudo docker run --name postgres -e POSTGRES_USER=isaac -e POSTGRES_PASSWORD=Isaac -d postgres:14

    # Run Foo app container
    sudo docker run --name foo_app --add-host host.docker.internal:host-gateway -e DB_HOSTNAME=postgres -e DB_PORT=5432 -e DB_USERNAME=isaac -e DB_PASSWORD=Isaac -p 80:3001 mattcul/assignment2app:1.0.0
  EOF

  tags = {
    Name = "web-server"
  }
}

# Output the public IP of the EC2 instance
output "instance_public_ip" {
  value = aws_instance.web.public_ip
}

