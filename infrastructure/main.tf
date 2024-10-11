# Defines the provider - AWS
provider "aws" {
  region     = "us-east-1"
  access_key = "ASIA6GF37BXSTGUNSNO2"
  secret_key = "/dzCOMRjs+ALcnVGQdbt7VciPa/YY1OSYY8KZNRl"
  token      = "IQoJb3JpZ2luX2VjECgaCXVzLXdlc3QtMiJIMEYCIQDJjjsOygfy1TwaFIZW6HLZTvs4/nbkDgKzqvlGfjJFnAIhAIjPe56y/BZKk6Xs7KsV0yxRUIX740dzh/t5f+jPX6MDKq4CCIH//////////wEQABoMOTc1MzUxNzc4Nzg5IgxElBK5gzXQrpXg6uYqggIduUldjrMaYzwoFtKsyia2nb5bD9kTJh/THnAHrM69FydiNC7ALvbCxUmu2lLaQW51Wb/2KqKkP5XFnGlHCalhktzV3g1kfUrIDDNISA7G1xfC/pdtZ/t6KcxJRMT/31Z9IJqWl0JPR1cw4Pj4rmzyaC8B3rTFDhdwqRWz99oqMu/fTMOL2hf+4yES6K+K9es6sf9miikxwE3kAjWmtCByDpr+GX25MxbdSrAa/SlEpQtq4z7Hx+NpWue120O/rn7sSuPNYkD0vduDWHAG9mNw4ntn+mTeh99UlRLt5ryl2/bElAjT72shun+xFunFdjqi/T3STmQ16ngdtVm1IP3+/2kwucuhuAY6nAHmyC170UndKAQzBqTDb5QU8CT/CZKmOjo6kYiha2FE1uIqX8OEU/gFX5uxMLLZs9/jfQPSpWLAzeSFWbLS+8Vz68v4Pdym/9CA5c+5p99Ue16c3D7xTJwAB9d3rSzFkai01krXDMqsptwsfHafdv/TqoJIEySfdM7uYDC4qVneoJ55TovIEPTGByimzqLRA4pRsYUse8vJD1S4BDk="
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

