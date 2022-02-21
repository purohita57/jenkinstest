################################################################################
# VPC
################################################################################

resource "aws_vpc" "myVPC" {
  cidr_block                       = var.cidr
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  tags = {
    Name = var.vpc_name
  }
}

###############################################################################
# Internet Gateway
###############################################################################

resource "aws_internet_gateway" "myIGW" {

  vpc_id = aws_vpc.myVPC.id
  tags = {
    "Name" = var.igw_tag
  }
}

################################################################################
# Public subnet
################################################################################

resource "aws_subnet" "public_subnet_1" {
  vpc_id                          = aws_vpc.myVPC.id
  cidr_block                      = var.public_subnets_cidr_1
  availability_zone               = data.aws_availability_zones.available_1.names[0]
  map_public_ip_on_launch         = var.map_public_ip_on_launch

  tags = {
   Name = var.public_subnet_tag_1
  }
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id                          = aws_vpc.myVPC.id
  cidr_block                      = var.public_subnets_cidr_2
  availability_zone               = data.aws_availability_zones.available_1.names[1]
  map_public_ip_on_launch         = var.map_public_ip_on_launch

  tags = {
   Name = var.public_subnet_tag_2
  }
}

################################################################################
# Database subnet
################################################################################

resource "aws_subnet" "database_subnet_1" {
  vpc_id                          = aws_vpc.myVPC.id
  cidr_block                      = var.database_subnets_cidr_1
  availability_zone               = data.aws_availability_zones.available_1.names[0]
  map_public_ip_on_launch         = false

  tags = {
    Name = var.database_subnet_tag_1
  }
}
resource "aws_subnet" "database_subnet_2" {
  vpc_id                          = aws_vpc.myVPC.id
  cidr_block                      = var.database_subnets_cidr_2
  availability_zone               = data.aws_availability_zones.available_1.names[1]
  map_public_ip_on_launch         = false

  tags = {
    Name = var.database_subnet_tag_2
  }
}

################################################################################
# Publiс routes
################################################################################

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.myVPC.id
  tags = {
    Name = var.public_route_table_tag
  }
}
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.myIGW.id
}

################################################################################
# Database route table
################################################################################

resource "aws_route_table" "database_route_table" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = var.database_route_table_tag
  }
}

################################################################################
# Route table association with subnets
################################################################################

resource "aws_route_table_association" "public_route_table_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "public_route_table_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "database_route_table_association_1" {
  subnet_id      = aws_subnet.database_subnet_1.id
  route_table_id = aws_route_table.database_route_table.id
}
resource "aws_route_table_association" "database_route_table_association_2" {
  subnet_id      = aws_subnet.database_subnet_2.id
  route_table_id = aws_route_table.database_route_table.id
}

###############################################################################
# Security Group
###############################################################################