# Create VPC
resource "aws_vpc" "this" {
  cidr_block = var.cidr.vpc
  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

# Create subnets
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.cidr.public_subnet_a
  availability_zone       = var.availability_zones.zone_a
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.name_prefix}-public-subnet-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.cidr.public_subnet_b
  availability_zone       = var.availability_zones.zone_b
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.name_prefix}-public-subnet-b"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.cidr.private_subnet_a
  availability_zone = var.availability_zones.zone_a
  tags = {
    Name = "${local.name_prefix}-private-subnet-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.cidr.private_subnet_b
  availability_zone = var.availability_zones.zone_b
  tags = {
    Name = "${local.name_prefix}-private-subnet-b"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

# Create Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${local.name_prefix}-public-rt"
  }
}

# Create Route to Internet Gateway
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Associate Public Subnets with Route Table
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}
