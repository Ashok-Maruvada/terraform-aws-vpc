##vpc-creation
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  #Indicates whether instances with public IP addresses get corresponding public DNS hostnames
  enable_dns_hostnames = var.enabling_DNS_hostnames

  tags = merge(
    var.comman_tags,
    var.vpc_tags,
    {
        Name = local.resource_name
    }
  )
}
##internet-gateway creation and association with vpc
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.comman_tags,
    var.gw_tags,
    {
        Name = local.resource_name
    }
  )
}
##public-subnets in 1a and 1b
resource "aws_subnet" "public" { # first name is public[0], second name is public[1]
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  #as it is public subnet, instances launched into the subnet should have assigned a public IP address
  #by default, it set to false.we set to true to assign public ip for public subnet
  #Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false.
  map_public_ip_on_launch = true
  availability_zone = local.az_names[count.index]
  cidr_block = var.public_subnet_cidrs[count.index]

  tags = merge(
    var.comman_tags,
    var.public_subnet_cidrs_tags,
    {
        Name = "${local.resource_name}-public-${local.az_names[count.index]}"
    }
  )
}
##private-subnets in 1a and 1b
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  availability_zone = local.az_names[count.index]
  cidr_block = var.private_subnet_cidrs[count.index]

  tags = merge(
    var.comman_tags,
    var.private_subnet_cidrs_tags,
    {
      Name = "${local.resource_name}-private-${local.az_names[count.index]}"
    }
  )
}
##database-subnets in 1a and 1b
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  availability_zone = local.az_names[count.index]
  cidr_block = var.database_subnet_cidrs[count.index]

  tags = merge(
    var.comman_tags,
    var.database_subnet_tags,
    {
      Name = "${local.resource_name}-database-${local.az_names[count.index]}"
    }
  )
}

## creating database subnet group for HA as it is critical 
resource "aws_db_subnet_group" "default" {
  name       = local.resource_name
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    var.comman_tags,var.database_subnet_group_tags,
    {
      Name = local.resource_name
    }
  )
}

#creating elastic ip
resource "aws_eip" "eip" {
  domain   = "vpc"
}

#creating nat-gateway and associating with eip
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.comman_tags,
    var.nat_gateway_tags,
    {
      Name = local.resource_name
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}
##route-table creation
## 3 route tables for three subnets
## public route-table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.resource_name}-public"
  }
}
# private route-table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.resource_name}-private"
  }
}
# database route-table
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.resource_name}-database"
  }
}

## creating routes for route-tables
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
  # u can also add peering con. after creating peering connection
}
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
  # u can also add peering con. after creating peering connection
}
resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
  # u can also add peering con. after creating peering connection
}

## route-table and subnet association
resource "aws_route_table_association" "public" {
  # rt association is done for both 1a and 1b subnets
  count = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  # rt association is done for both 1a and 1b subnets
  count = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "database" {
  # rt association is done for both 1a and 1b subnets
  count = length(var.database_subnet_cidrs)
  subnet_id      = element(aws_subnet.database[*].id, count.index)
  route_table_id = aws_route_table.database.id
}