# Create VPC
# terraform aws create vpc
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc-cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "Test VPC"
  }
}

# Create Internet Gateway and Attach it to VPC
# terraform aws create internet gateway
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Test IGW"
  }
}

# Create Public Subnet
# terraform aws create subnet
resource "aws_subnet" "public-subnet" {
  count = 2

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public-subnet-cidr[count.index]
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet ${count.index}"
  }
}

# Create Route Table and Add Public Route
# terraform aws create route table
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

# Associate Public Subnet to "Public Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "public-subnet-route-table-association" {
  count = 2

  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.public-route-table.id
}

# Create Private Subnet
# terraform aws create subnet
resource "aws_subnet" "private-subnet" {
  count = 2

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private-subnet-cidr[count.index]
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private Subnet ${count.index} | App tier"
  }
}

# Allocate Elastic IP Address (EIP)
# terraform aws allocate elastic ip
resource "aws_eip" "eip-for-nat-gateway" {
  count = 2

  vpc = true

  tags = {
    Name = "EIP ${count.index}"
  }
}

# Create Nat Gateway in Public Subnet
# terraform create aws nat gateway
resource "aws_nat_gateway" "nat-gateway" {
  count = 2

  allocation_id = aws_eip.eip-for-nat-gateway[count.index].id
  subnet_id     = aws_subnet.public-subnet[count.index].id

  tags = {
    Name = "Public Subnet ${count.index}"
  }
}

# Create Private Route Table and Add Route Through Nat Gateway
# terraform aws create route table
resource "aws_route_table" "private-route-table" {
  count = 2

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway[count.index].id
  }

  tags = {
    Name = "Private Route Table ${count.index}"
  }
}

# Associate Private Subnet with "Private Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "private-subnet-route-table-association" {
  count = 2

  subnet_id      = aws_subnet.private-subnet[count.index].id
  route_table_id = aws_route_table.private-route-table[count.index].id
}
