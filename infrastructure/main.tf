# Defines the provider - AWS
provider "aws" {
  region = "us-east-1"
}


#Here the subnest are created for the VPC 
resource "aws_subnet" "subnet_1" {
  vpc_id            = var.vpc_id
  cidr_block        = "172.31.96.0/20"
  availability_zone = "us-east-1a" 
}

resource "aws_subnet" "subnet_2" {
  vpc_id            = var.vpc_id
  cidr_block        = "172.31.112.0/20"
  availability_zone = "us-east-1b" 
}


variable "vpc_id" {
  description = "The VPC ID where the resources will be deployed"
  type        = string
  default     = "vpc-058602ee0fec7eadd"
}


# Here the route table is created
resource "aws_route_table" "main_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-028a664ab5746a41a"
  }
}




# here the route tables are associated with the subnets
resource "aws_route_table_association" "subnet_1_association" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.main_route_table.id
}

resource "aws_route_table_association" "subnet_2_association" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.main_route_table.id
}


# Here the S3 is setup
terraform {
  backend "s3" {
    bucket         = "foostatebuckets39"
    key            = "terraform/state"
    region         = "us-east-1"
    dynamodb_table = "foostatelock"
  }
}

# The key is here to allow access, i believe this is working correctly now
resource "aws_key_pair" "deployer_key" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}


#Here the load balancer is taken care of 
resource "aws_lb" "app_load_balancer" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_security_group.id]
  subnets            = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
}

#Target group  is here to define the ec2 instances that receive traffic from the load balancer
resource "aws_lb_target_group" "app_target_group" {
  name     = "app-target-group1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

#Used to route traffic from load balancers to target group
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}

#makes app sever instances the attached target group
resource "aws_lb_target_group_attachment" "app_targets" {
  count            = 2
  target_group_arn = aws_lb_target_group.app_target_group.arn
  target_id        = aws_instance.app_servers[count.index].id
  port             = 80
}




# This is all the security group rules for the app instances
resource "aws_security_group" "app_security_group" {
  vpc_id = var.vpc_id 
  name = "app-security-group"

  #rules for traffic from load balancer
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.lb_security_group.id]
  }
  #Traffic from any port on 3001 can be used
  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Allows for ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }
  #Allowing all out traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




#here is the rules for the db
resource "aws_security_group" "db_security_group" {
  name = "db-security-group"
  #THis should allow traffic from postgreSQL
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.app_security_group.id]
  }
  #ssh 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #out anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Create a security group for the web server
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



# this is for web sever instance
resource "aws_instance" "web" {
  ami           = "ami-0fff1b9a61dec8a5f" 
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer_key.key_name
  vpc_security_group_ids = [aws_security_group.app_security_group.id]
 
  #docker started should run fine 
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker

    #here the container for the posgresql runs, password Isaac username isaac.... sorry!
    sudo docker run --name postgres -e POSTGRES_USER=isaac -e POSTGRES_PASSWORD=Isaac -d postgres:14

    # this one runs the foo app container allowing acces from port 80 and 3001
    sudo docker run --name foo_app --add-host host.docker.internal:host-gateway -e DB_HOSTNAME=postgres -e DB_PORT=5432 -e DB_USERNAME=isaac -e DB_PASSWORD=Isaac -p 80:3001 mattcul/assignment2app:1.0.0
  EOF

  tags = {
    Name = "web-server"
  }
}

#this one runs the db postgresql
resource "aws_instance" "db_server" {
  ami           = "ami-0fff1b9a61dec8a5f"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer_key.key_name

  #uses db security group
  vpc_security_group_ids = [aws_security_group.db_security_group.id]

  #runs and installs docter
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker

    # this runs the inital script to ru the postgre database 
    sudo docker run --name postgres -e POSTGRES_USER=isaac -e POSTGRES_PASSWORD=Isaac -d postgres:14
  EOF

  tags = {
    Name = "db-server"
  }
}


# Output the public IP's after running terrafrom apply
output "instance_public_ip" {
  value = aws_instance.web.public_ip
}

output "app_instances_public_ips" {
  value = [for instance in aws_instance.app_servers : instance.public_ip]
}

output "db_instance_public_ip" {
  value = aws_instance.db_server.public_ip
}


#here two identical ec2 instances are created
resource "aws_instance" "app_servers" {
  count         = 2
  ami           = "ami-0fff1b9a61dec8a5f"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer_key.key_name
  
  #uses app security group
  vpc_security_group_ids = [aws_security_group.app_security_group.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker

    #allos for the container to access the hosts netowrk 
    sudo docker run --name foo_app --add-host host.docker.internal:host-gateway -e DB_HOSTNAME=postgres -e DB_PORT=5432 -e DB_USERNAME=isaac -e DB_PASSWORD=Isaac -p 80:3001 mattcul/assignment2app:1.0.0
  EOF

  tags = {
    Name = "app-server-${count.index}"
  }
}

#Here is the load balancer security group
resource "aws_security_group" "lb_security_group" {
  name = "lb-security-group"

  #Allows traffic from 80
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  #out traffic work allows for all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

  
