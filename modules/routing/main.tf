# Create an Internet Gateway (IGW) and attach it to the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "MainInternetGateway"
  }
}

# Create a public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc_id

  # Route all traffic (0.0.0.0/0) to the Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# Associate the public subnets with the public route table
resource "aws_route_table_association" "public_route_association" {
  count = length(var.public_subnet_ids)  # Adjust to the number of public subnets

  subnet_id      = element(var.public_subnet_ids, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

# Create a private route table (no need for an Internet Gateway route)
resource "aws_route_table" "private_route_table" {
  vpc_id = var.vpc_id

  tags = {
    Name = "PrivateRouteTable"
  }
}

# Associate the private subnets with the private route table
resource "aws_route_table_association" "private_route_association" {
  count = length(var.private_subnet_ids)  

  subnet_id      = element(var.private_subnet_ids, count.index)
  route_table_id = aws_route_table.private_route_table.id
}
