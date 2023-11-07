# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


data "aws_availability_zones" "current_region" {
  state = "available"
}

/* VPC */

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"

  name = local.var.network.vpc.name
  cidr = format("%s.0.0/16", local.var.network.vpc.prefix_subnet)
 
  azs             = data.aws_availability_zones.current_region.names[*]
  enable_nat_gateway = local.var.network.enable_nat_gateway

  tags = local.var.network.vpc.tags
}

/* Private Subnet */
resource "aws_subnet" "public" {
  count             = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0

  vpc_id                  = module.vpc.vpc_id
  cidr_block              = cidrsubnet(format("%s.0.0/21", local.var.network.vpc.prefix_subnet), ceil(log(length(data.aws_availability_zones.current_region.names), 2)), count.index)
  availability_zone       = data.aws_availability_zones.current_region.names[count.index]
  tags = {
    Name = "Public-${data.aws_availability_zones.current_region.names[count.index]}"
  }

}

resource "aws_subnet" "private" {
  count             = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0


  vpc_id                  = module.vpc.vpc_id
  cidr_block              =  cidrsubnet(format("%s.100.0/20", local.var.network.vpc.prefix_subnet), ceil(log(length(data.aws_availability_zones.current_region.names), 2)), (count.index + 1))
  availability_zone       = data.aws_availability_zones.current_region.names[count.index]
  tags = {
    Name = "Prvt-${data.aws_availability_zones.current_region.names[count.index]}"
  }
}

/* Gateways Nat and Internet */
resource "aws_internet_gateway" "dev_igw" {
  count   = contains(local.var.flags, "create_network") ? 1 : 0

  vpc_id  = module.vpc.vpc_id

  tags = {
    Name        = "${terraform.workspace}-igw"
    Description = "Internet Gateway for Public Subnets of ${terraform.workspace}"
  }
}

resource "aws_eip" "dev_eip" {
  count = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0
  domain   = "vpc"
  tags = {
    Name        = "${terraform.workspace}-${data.aws_availability_zones.current_region.names[count.index]}-eip"
    Description = "Elastic IP for NAT Gateway of ${terraform.workspace}"
  }
}

resource "aws_nat_gateway" "dev_natgw" {
  count         = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0

  allocation_id = element(aws_eip.dev_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  depends_on    = [
    aws_subnet.public
  ]

  tags = {
    Name        = "${terraform.workspace}-${data.aws_availability_zones.current_region.names[count.index]}-natgw"
    Description = "NAT Gateway for ${data.aws_availability_zones.current_region.names[count.index]} of ${terraform.workspace}"
  }
}

/* Route Tables */
resource "aws_route_table" "private_rt" {
  count  = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0
  vpc_id  = module.vpc.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.dev_natgw.*.id, count.index)
  }

  # dynamic "route" {
  #   for_each = local.var.network.routes.transit_gateway.cidr_blocks

  #   content {
  #     cidr_block = route.value
  #     transit_gateway_id = local.var.network.routes.transit_gateway.id
  #   }
  # }

  depends_on = [
    aws_nat_gateway.dev_natgw
  ]

  tags = {
    Name        = "${terraform.workspace}-Private-${data.aws_availability_zones.current_region.names[count.index]}-rt"
    Description = "Route table Target to Nat Gateway for ${terraform.workspace}"
  }
}

resource "aws_route_table" "public_rt" {
  count  = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0
  vpc_id  = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_igw[0].id
  }

  depends_on = [
    aws_internet_gateway.dev_igw
  ]

  tags = {
    Name        = "${terraform.workspace}-Public-${data.aws_availability_zones.current_region.names[count.index]}-routetable"
    Description = "Route table Target to Internet Gateway for ${terraform.workspace}"
  }
}

/* Route Table Association to Public and Private Subnets */

resource "aws_route_table_association" "eks_private_rta" {
  count          = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private_rt.*.id, count.index)

  depends_on = [
    aws_subnet.private ,
    aws_route_table.dev_private_rt,
  ]
}

resource "aws_route_table_association" "dev_public_rta" {
  count          = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public_rt.*.id, count.index)

  depends_on = [
    aws_subnet.public,
    aws_route_table.public_rt,
  ]
}




