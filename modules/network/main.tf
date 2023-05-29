/***
  *
  * # Network Module
  *
  * This module will create the Network related resources.
  *
  * | Resource | Type | Description |
  * | --- | --- | --- |
  * | VPC | VPC | This is the VPC that will be used to create the network |
  * | Public Subnets | Subnet | We will create one public subnet per availability zone available |
  * | Private Subnets | Subnet | We will create one private subnet per availability zone available |
  * | Internet Gateway | Internet Gateway | This is the gateway that will be used to connect the VPC to the internet |
  * | NAT Gateway | NAT Gateway | This is the gateway that will be used to connect the private subnets to the internet |
  * | External Route Table | Route Table | This Route Table will allow communication from the public subnets to the Internet |
  * | Internal Route Table | Route Table | This Route Table will allow communication between the public and private subnets |
  *
  */

locals {

  N_public_subnets  = (var.N_Subnets % 2) == 0 ? var.N_Subnets / 2 : floor(var.N_Subnets / 2)
  N_private_subnets = var.N_Subnets - local.N_public_subnets

  subnets = {
    for i in range(var.N_Subnets) :
    "subnet-${i}" => {
      name  = "${var.Name}-subnet-${i}"
      type  = i >= local.N_public_subnets ? "private" : "public"
      cidr  = cidrsubnet(var.Network_CIDR, 8, i)
      id    = "subnet-${i}"
      index = i
    }
  }
  public_subnets  = [for k, v in local.subnets : v.id if v.type == "public"]
  private_subnets = [for k, v in local.subnets : v.id if v.type == "private"]
}

/*********************************
 * DATA SOURCES
 *********************************/
data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

resource "random_shuffle" "azs" {
  input        = data.aws_availability_zones.available.names
  count        = 1
  result_count = local.N_public_subnets
}

data "aws_subnet" "info" {
  for_each = {
    for s in concat(local.public_subnets, local.private_subnets) : s => aws_subnet.this[s].id
  }

  id = each.value
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.this.id]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }

  depends_on = [aws_subnet.this]
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.this.id]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = ["false"]
  }

  depends_on = [aws_subnet.this]
}

/*********************************
 * RESOURCES
 *********************************/
// Creates the dedicated VPC for the project
resource "aws_vpc" "this" {
  cidr_block           = var.Network_CIDR
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    { "Name" = var.Name },
    var.Tags,
  )

  tags_all = var.Tags

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags, tags_all, ]
  }
}

// Subnets
resource "aws_subnet" "this" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = each.value.type == "public" ? true : false
  availability_zone       = element(random_shuffle.azs[0].result, each.value.index)

  tags = merge(
    {
      "Name" = "${each.value.name}-${each.value.type}"
      "Type" = each.value.type
    },
    var.Tags,
  )

  tags_all = var.Tags

  lifecycle {
    ignore_changes = [tags, tags_all, ]
  }
}

// Public Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    { "Name" = "${var.Name}-igw" },
    var.Tags,
  )

  lifecycle {
    ignore_changes = [tags, ]
  }
}

// Elastic IP for NAT Gateway
resource "aws_eip" "nat_ip" {
  domain = "vpc"

  tags = merge(
    { "Name" = "${var.Name}-nat-eip" },
    var.Tags,
  )

  lifecycle {
    ignore_changes = [tags, ]
  }
}

// NAT Gateway
resource "aws_nat_gateway" "this" {
  subnet_id     = aws_subnet.this[local.private_subnets[0]].id
  allocation_id = aws_eip.nat_ip.id

  tags = merge(
    { "Name" = "${var.Name}-nat" },
    var.Tags,
  )

  lifecycle {
    ignore_changes = [tags, ]
  }

  depends_on = [aws_eip.nat_ip]
}

// Create Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    { "Name" = "${var.Name}-public-rt" },
    var.Tags,
  )

  lifecycle {
    ignore_changes = [tags, ]
  }

  depends_on = [aws_internet_gateway.this]
}

// Create Default Route for Public Route Table
resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  depends_on = [aws_route_table.public]
}

// Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  for_each = {
    for s in local.public_subnets : s => aws_subnet.this[s]
  }

  route_table_id = aws_route_table.public.id
  subnet_id      = each.value.id

  depends_on = [aws_route_table.public, aws_subnet.this]
}

// Create Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    { "Name" = "${var.Name}-private-rt" },
    var.Tags,
  )

  lifecycle {
    ignore_changes = [tags, ]
  }

  depends_on = [aws_nat_gateway.this]
}

// Default Route for Private Subnets
resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id

  depends_on = [aws_route_table.private]
}

// Associate Private Subnets with Private Route Tables
resource "aws_route_table_association" "private" {
  for_each = {
    for s in local.private_subnets : s => aws_subnet.this[s]
  }

  route_table_id = aws_route_table.private.id
  subnet_id      = each.value.id

  depends_on = [aws_route_table.private, aws_subnet.this]
}
