# Define the provider - AWS
provider "aws" {
  region     = "us-east-1"
  access_key = "ASIA6GF37BXSZVXAHD53"
  secret_key = "Pm/8QW9RAl/Eux//Fo1OutIENsTPl+CQ/p/pq0SD"
  token      = "IQoJb3JpZ2luX2VjEAMaCXVzLXdlc3QtMiJHMEUCIH3zT0HTYdIhwsEhGtWvuZwohoBox7xAbhNyol3Hz7hdAiEAk68upv28cZ1/ak3UpKdwgWrI5w1Hr5Cp2+2QRRnzUNsqpQIIXBAAGgw5NzUzNTE3Nzg3ODkiDEwEEWBXcrap3BXhqiqCAqBN1+6VzOZ/6YJ6Dyu/+7/z7Bi6Mc9ApoJGRe7BMvQw984Fy9RHYb0foODoShSwbslXqT0zMW5kaT8GqQ8+hpNf/6IbXrZhJgV+PirhS+NbKQSihVuY+qOMN7hhfqQ4ewhpeIhkOvazVCCu24f+meUn6eTexp3bTWMRiZXVgn//QbhvkfatYZctCXywQxkiPPWWey/3bJnBzYSP7iUVIHfis4gLmZvt4pNxqAGzFxp6KHWSspPggDKom8Ji+ejhSGSEuAbsiE0ZA8c5dF2nNa1nP9ifnhEjzpn+VC3AucBr5+elyxRXLmPqH4CTawRq19zR8ite4Y1cgPTHgkGb6KEcQzCmxZm4BjqdATz0+rokOz8MBnpE5zXqWNEDPhENZeh2tbKiMIrq13QmHSIajtvEzIyoVYRDCoHvBss8w//Dy4WSOCV8cFmzAGcnp6ORnqT9iZBtzuBKx0X9DkIRRyAChIoSYxLDEXgzrozm0nkrRHvrdTcJKX2i0Iee/AI9d2NJruHHcZ3IambPApjXobKTBOM+2bqCW6gs0weYUlcIj2NquCgFuP4="
}

# Define the key pair
resource "aws_key_pair" "deployer_key" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Create a security group for the EC2 instance
resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allows SSH from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allows HTTP traffic from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allows all outbound traffic
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

