terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.72.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


#Create a VPC

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-vpc"
  }
}


# #Private Subnet

# resource "aws_subnet" "private-subnet" {
#   cidr_block = "10.0.1.0/24"
#   vpc_id     = aws_vpc.my-vpc.id
#   tags = {
#     Name = "private-subnet"
#   }
# }

#Public Subnet

resource "aws_subnet" "public-subnet" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.my-vpc.id
  tags = {
    Name = "public-subnet"
  }
}

#Internet Gateway

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "my-igw"
  }
}

#Routing table

resource "aws_route_table" "my-routetable" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }
}

resource "aws_route_table_association" "public-sub" {
  route_table_id = aws_route_table.my-routetable.id
  subnet_id      = aws_subnet.public-subnet.id
}

#AWS EC2

resource "aws_instance" "server-pub-sub" {
  ami           = "ami-0866a3c8686eaeeba"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "server-pub-sub"
  }
}