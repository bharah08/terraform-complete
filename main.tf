provider "aws" {
    region=var.region
}
resource "aws_vpc" "main" {
  cidr_block = var.vpc

  tags = {
    Name = var.vpc-name
  }
}
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public
  availability_zone = var.zone1

  tags = {
    Name = var.subnet1
  }
}
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private
  availability_zone = var.zone2

  tags = {
    Name = var.subnet2
  }
}
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "my-ig"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.route
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-route"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Allocate an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true

  tags = {
    Name = "my-eip"
  }
}
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "my-nat"
  }

  # Ensure proper ordering, NAT Gateway needs EIP to be allocated first
  depends_on = [aws_eip.nat_eip]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "private-route"
  }
}
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route" "internet_route" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gw.id
}
resource "aws_security_group" "web" {
  vpc_id = aws_vpc.main.id

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
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-sg-1"
  }
}
resource "aws_instance" "public" {
    ami=var.ami
    instance_type=var.type
    key_name=var.key
    subnet_id              = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.web.id]
    associate_public_ip_address = true
     user_data = <<-EOF
              #!/bin/bash
              apt update
              apt install apache2 -y
              systemctl start apache2 
              systemctl enable apache2
              echo "Hello, World from $(hostname -f)" > /var/www/html/index.html
              EOF
    tags = {
        name=var.instance1
    }
}
resource "aws_instance" "private" {
    ami=var.ami
    instance_type=var.type
    key_name=var.key
    subnet_id              = aws_subnet.private.id
    vpc_security_group_ids = [aws_security_group.web.id]
    tags = {
        name =var.instance2
    }
}
