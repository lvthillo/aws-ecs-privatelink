resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "subnet_1a_public" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_1a_public_cidr
  availability_zone = "eu-west-1a"

  tags = {
    Name = var.subnet_1a_public_name
  }
}

resource "aws_subnet" "subnet_1b_public" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_1b_public_cidr
  availability_zone = "eu-west-1b"

  tags = {
    Name = var.subnet_1b_public_name
  }
}

resource "aws_subnet" "subnet_1a_private" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_1a_private_cidr
  availability_zone = "eu-west-1a"

  tags = {
    Name = var.subnet_1a_private_name
  }
}

resource "aws_subnet" "subnet_1b_private" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_1b_private_cidr
  availability_zone = "eu-west-1b"

  tags = {
    Name = var.subnet_1b_private_name
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw.id
  }

  tags = {
    Name = "private_route_table"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.igw_name
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.subnet_1a_public.id

  tags = {
    Name = var.nat_name
  }
}

resource "aws_route_table_association" "rta_subnet_public_1a" {
  subnet_id      = aws_subnet.subnet_1a_public.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "rta_subnet_public_1b" {
  subnet_id      = aws_subnet.subnet_1b_public.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "rta_subnet_private_1a" {
  subnet_id      = aws_subnet.subnet_1a_private.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "rta_subnet_private_1b" {
  subnet_id      = aws_subnet.subnet_1b_private.id
  route_table_id = aws_route_table.private_route_table.id
}
