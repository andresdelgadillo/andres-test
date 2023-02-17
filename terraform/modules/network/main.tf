terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

data "aws_region" "current" {
  provider = aws
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = var.vpc_name
    Description = "${var.vpc_name} VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = join("-", [var.vpc_name, "igw"])
    Description = "${var.vpc_name} Internet Gateway"
  }
}

resource "aws_subnet" "subnet_pub" {
  for_each          = toset([for k, v in var.subnets.public : k])
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnets.public[each.key].cidr
  availability_zone = format("%s%s", data.aws_region.current.name, var.subnets.public[each.key].az)
  tags = {
    Name        = join("-", [var.vpc_name, "snet", each.key])
    Description = "${var.vpc_name} Public Subnet ${each.key}"
  }
}

resource "aws_subnet" "subnet_pvt" {
  for_each          = toset([for k, v in var.subnets.private : k])
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnets.private[each.key].cidr
  availability_zone = format("%s%s", data.aws_region.current.name, var.subnets.private[each.key].az)
  tags = {
    Name        = join("-", [var.vpc_name, "snet", each.key])
    Description = "${var.vpc_name} Private Subnet ${each.key}"
  }
}

resource "aws_subnet" "subnet_pvt_rds" {
  for_each          = toset([for k, v in var.subnets.private_rds : k])
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnets.private_rds[each.key].cidr
  availability_zone = format("%s%s", data.aws_region.current.name, var.subnets.private_rds[each.key].az)
  tags = {
    Name        = join("-", [var.vpc_name, "snet", each.key])
    Description = "${var.vpc_name} Private RDS Subnet ${each.key}"
  }
}


resource "aws_route_table" "route_table_pub" {
  for_each = toset([for k, v in var.subnets.public : k])
  vpc_id   = aws_vpc.vpc.id
  tags = {
    Name        = join("-", [aws_subnet.subnet_pub[each.key].tags.Name, "rttbl", "pub"])
    Description = "${aws_subnet.subnet_pub[each.key].tags.Name} Public Route Table"
  }
}

resource "aws_route_table_association" "rta_pub" {
  for_each = toset([for k, v in var.subnets.public : k])

  subnet_id      = aws_subnet.subnet_pub[each.key].id
  route_table_id = aws_route_table.route_table_pub[each.key].id
}

resource "aws_route_table" "route_table_pvt" {
  for_each = toset([for k, v in var.subnets.private : k])
  vpc_id   = aws_vpc.vpc.id
  tags = {
    Name        = join("-", [aws_subnet.subnet_pvt[each.key].tags.Name, "rttbl", "pvt"])
    Description = "${aws_subnet.subnet_pvt[each.key].tags.Name} Private Route Table"
  }
}

resource "aws_route_table" "route_table_pvt_rds" {
  for_each = toset([for k, v in var.subnets.private_rds : k])
  vpc_id   = aws_vpc.vpc.id
  tags = {
    Name        = join("-", [aws_subnet.subnet_pvt_rds[each.key].tags.Name, "rttbl", "pvt"])
    Description = "${aws_subnet.subnet_pvt_rds[each.key].tags.Name} Private RDS Route Table"
  }
}

resource "aws_route_table_association" "rta_pvt" {
  for_each = toset([for k, v in var.subnets.private : k])

  subnet_id      = aws_subnet.subnet_pvt[each.key].id
  route_table_id = aws_route_table.route_table_pvt[each.key].id
}

resource "aws_route_table_association" "rta_pvt_rds" {
  for_each = toset([for k, v in var.subnets.private_rds : k])

  subnet_id      = aws_subnet.subnet_pvt_rds[each.key].id
  route_table_id = aws_route_table.route_table_pvt_rds[each.key].id
}

resource "aws_eip" "natips" {
  for_each = toset([for k, v in var.subnets.public : k])
  vpc      = true
  tags = {
    Name        = join("-", [aws_subnet.subnet_pub[each.key].tags.Name, "natip"])
    Description = "${aws_subnet.subnet_pub[each.key].tags.Name} NAT Public IP"
  }
}

resource "aws_nat_gateway" "natgws" {
  for_each      = toset([for k, v in var.subnets.public : k])
  allocation_id = aws_eip.natips[each.key].id
  subnet_id     = aws_subnet.subnet_pub[each.key].id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name        = join("-", [aws_subnet.subnet_pub[each.key].tags.Name, "natgw"])
    Description = "${aws_subnet.subnet_pub[each.key].tags.Name} NAT Gateway"
  }
}

resource "aws_route" "ipv4_pub_routes" {
  for_each               = toset([for k, v in var.subnets.public : k])
  route_table_id         = aws_route_table.route_table_pub[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "ipv4_pvt_routes" {
  for_each               = toset([for k, v in var.subnets.private : k])
  route_table_id         = aws_route_table.route_table_pvt[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgws[tomap(var.subnets.private)[each.key].nat_subnet].id
}

resource "aws_route" "ipv4_pvt_routes_rds" {
  for_each               = toset([for k, v in var.subnets.private_rds : k])
  route_table_id         = aws_route_table.route_table_pvt_rds[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgws[tomap(var.subnets.private_rds)[each.key].nat_subnet].id
}
