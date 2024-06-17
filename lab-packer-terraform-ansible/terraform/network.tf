resource "aws_vpc" "fast_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "fast-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.fast_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "fast-subnet"
  }
}

resource "aws_internet_gateway" "fast_igw" {
  vpc_id = aws_vpc.fast_vpc.id
  tags = {
    Name = "fast-igw"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.fast_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fast_igw.id
  }
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  tags = {
    Name = "fast-route-table"
  }
}

resource "aws_route_table_association" "fast" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rtb.id
}