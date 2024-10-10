# Defines the provider - AWS
provider "aws" {
  region     = "us-east-1"
  access_key = "ASIA6GF37BXSYRZT23SM"
  secret_key = "E4JfyUZ9+QNJoGmlWr374EV6/prxXIFrWPyPZRdU"
  token      = "IQoJb3JpZ2luX2VjEBAaCXVzLXdlc3QtMiJHMEUCIQDjImOY7knttVg7UbxFFJnnJgSgoV2hvDot190dILSZgQIgPUGXZp0bk3Cdxh5eeaEbe8s3COpu8Pg1xDJdS4LzsKIqpQIIaRAAGgw5NzUzNTE3Nzg3ODkiDIvwOwSsap9liMbVWSqCAkvP9YrnZzvVKFeuwDQNHSkEu+dY8H9MDqsByaG+PoC9FK0Pg9VQ+RFjEQ/Q17CkRwmtckjzRNM5EKnQIq8WWc+JYpS7E0I2uOWD1Rs5g421Z0T4LDrxADXHoEoAVU6vWbdRrzge1qfiXUdRBHCkYRCReGeV1XwzaM1KpaCe/5BMywRXJP7akPEHz/9Y2x7AGG1dWXyGkoLF1dFSEOqhCOXcT606kl/dRNdJXF+qRaayP81wf2jB2vkHGIzwx13NM9PdKcrLu1l+Yy3S4VoRXFGzv8i8IISMKGENjYWIiM861B41Eg5vMUd3dUduTxY2Lx7LbbhXlOHqdA4Kpo/Hn2YyBTD8qZy4BjqdAYhQVy2QCe376Oq7BZyRQFzJaF+gm48TWVamzCpOMFUA01hNHJben48voagbdkBs21d1gKalQ1y26i8Y7gnpYrApkwBMRBYuz5F7Ydir+ACDztmddqVG0VYFb+nbp8DnvGzVqVZ+SaJBhOGX+T7qAw+0KzgDfPtBWGetKLGdyRpAeLhswZNuAoJqrqfzY9YYzMIc5RWxMqCC7J4dw1o="
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
  ami           = "ami-0fff1b9a61dec8a5f"  # Updated AMI ID
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer_key.key_name

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "web-server"
  }
}

# Output the public IP of the EC2 instance
output "instance_public_ip" {
  value = aws_instance.web.public_ip
}

