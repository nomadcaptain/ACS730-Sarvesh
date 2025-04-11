# Define required providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">=0.14"
}

provider "aws" {
  region  = "us-east-1"
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Create a new VPC 
resource "aws_vpc" "main_vpc" {
  cidr_block       = var.vpc_cidr
  tags = {
    Name = "${var.prefix}-VPC"
  }
}

# Add provisioning of the public subnetin the created VPC
resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  depends_on = [aws_vpc.main_vpc]
  tags = {
    Name = "${var.prefix}-public-subnet-${count.index + 1}"
  }
}

# Add provisioning of the private subnets in the created VPC
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  depends_on = [aws_vpc.main_vpc]
  tags = {
    Name = "${var.prefix}-private-subnet-${count.index + 1}"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  depends_on = [aws_vpc.main_vpc]
  tags = { 
    Name = "${var.prefix}-igw"
  }
}

# Route table to route add default gateway pointing to Internet Gateway (IGW)
resource "aws_route_table" "public_subnets_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.prefix}-public-RT"
  }
}

# Associate subnets with the custom route table
resource "aws_route_table_association" "public_rt_association" {
  count          = length(aws_subnet.public_subnet[*].id)
  route_table_id = aws_route_table.public_subnets_rt.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
  depends_on = [aws_subnet.public_subnet, aws_route_table.public_subnets_rt]
}

resource "aws_eip" "nat_eip" {
  vpc = true
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.prefix}-nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  connectivity_type = "public"
  allocation_id     = aws_eip.nat_eip.id
  subnet_id         = aws_subnet.public_subnet[0].id # Changed to public_subnet
  depends_on        = [aws_subnet.public_subnet, aws_eip.nat_eip]
  tags = {
    Name = "${var.prefix}-nat-gw"
  }
}

# resource "aws_nat_gateway" "nat_gw" {
#   connectivity_type = "private"
#   subnet_id         = aws_subnet.public_subnet[0].id
#   depends_on = [aws_subnet.public_subnet]
#   tags = {
#     Name = "${var.prefix}-nat-gw"
#   }
# }

# Route table to route add default gateway pointing to NAT Gateway (nat_gw)
resource "aws_route_table" "private_subnets_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }
  depends_on = [aws_nat_gateway.nat_gw]
  tags = {
    Name = "${var.prefix}-private-RT"
  }
}

# Associate subnets with the custom route table
resource "aws_route_table_association" "private_rt_association" {
  count          = length(aws_subnet.private_subnet[*].id)
  route_table_id = aws_route_table.private_subnets_rt.id
  subnet_id      = aws_subnet.private_subnet[count.index].id
  depends_on = [aws_subnet.private_subnet, aws_route_table.private_subnets_rt]
}







# resource "aws_nat_gateway" "nat_gw" {
#   count          = length(aws_subnet.private_subnet[*].id)
#   connectivity_type = "private"
#   subnet_id         = aws_subnet.private_subnet[count.index].id
#   tags = {
#     Name = "${local.name_prefix}-nat-gw-${count.index}"
#   }
# }

# # Route table to route add default gateway pointing to NAT Gateway (nat_gw)
# resource "aws_route_table" "private_subnets_rt" {
#   count          = length(aws_nat_gateway.nat_gw[*].id)
#   vpc_id = aws_vpc.main_vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_nat_gateway.nat_gw[count.index].id
#   }
#   tags = {
#     Name = "${local.name_prefix}-private-subnets-route-table-${count.index}"
#   }
# }

# # Associate subnets with the custom route table
# resource "aws_route_table_association" "private_route_table_association" {
#   count          = length(aws_route_table.private_subnets_rt[*].id)
#   route_table_id = aws_route_table.private_subnets_rt[count.index].id
#   subnet_id      = aws_subnet.private_subnet[count.index].id
# }