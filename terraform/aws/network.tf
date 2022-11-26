# VPC
resource "aws_vpc" "titans_network" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${local.tag_name}-network"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "titans_igw" {
  vpc_id = aws_vpc.titans_network.id
  tags = {
    Name = "main"
  }
}

# Subnets : public
resource "aws_subnet" "titans-subnet" {
  count                   = length(var.subnets_cidr)
  vpc_id                  = aws_vpc.titans_network.id
  cidr_block              = element(var.subnets_cidr, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.tag_name}-subnet-${count.index + 1}"
  }
}

# Route table: attach Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.titans_network.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.titans_igw.id
  }
  tags = {
    Name = "${local.tag_name}-publicRouteTable"
  }
}

# Route table association with public subnets
resource "aws_route_table_association" "a" {
  count          = length(var.subnets_cidr)
  subnet_id      = element(aws_subnet.titans-subnet.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}
