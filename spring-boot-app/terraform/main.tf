provider "aws" {
  region = "ca-central-1"
}

# Security Group for EC2 instances
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2_security_group"
  description = "Allow inbound HTTP and SSH traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
/*
# Security Group for Load Balancer
resource "aws_security_group" "elb_security_group" {
  name        = "elb_security_group"
  description = "Allow inbound HTTP traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
*/
# Data Source for Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Default VPC
data "aws_vpc" "default" {
  default = true
}

# Subnets in the Default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# EC2 Instances
resource "aws_instance" "web" {
  count         = 1
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.large"
  key_name      = "myNewKey"  # Replace with your existing key pair name
  security_groups = [aws_security_group.ec2_security_group.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y apache2
              sudo systemctl start apache2.service
              sudo systemctl enable apache2.service
              echo "Hello Arun from $(hostname -I)" > /var/www/html/index.html
              EOF

  tags = {
    Name = "jekins_master_node${count.index}"
  }
}
/*
# Create a Load Balancer
resource "aws_lb" "main" {
  name               = "main-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb_security_group.id]
  subnets            = data.aws_subnets.default.ids
}

# Create a Target Group
resource "aws_lb_target_group" "main" {
  name     = "main-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

# Register EC2 Instances with Target Group
resource "aws_lb_target_group_attachment" "web" {
  count            = length(aws_instance.web)
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

# Create a Listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
*/

/* output "elb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}
 */
output "instance_public_ips" {
  description = "Public IPs of the EC2 instances"
  value       = [for instance in aws_instance.web : instance.public_ip]
}
