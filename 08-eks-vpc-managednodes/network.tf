/* VPC */
resource "aws_vpc" "eks_cluster" {
  count = contains(local.var.flags, "create_network") ? 1 : 0

  cidr_block           = format("%s.0.0/16", local.var.network.vpc.prefix_subnet)
  enable_dns_hostnames = true

  tags = local.var.network.vpc.tags
}

/*  Subnets */
resource "aws_subnet" "public" {
  count             = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0

  vpc_id                  = aws_vpc.eks_cluster[0].id
  map_public_ip_on_launch = true
  cidr_block              = cidrsubnet(format("%s.0.0/21", local.var.network.vpc.prefix_subnet), ceil(log(length(data.aws_availability_zones.current_region.names), 2)), count.index)
  availability_zone       = data.aws_availability_zones.current_region.names[count.index]
  tags = {
    Name = "Public-${data.aws_availability_zones.current_region.names[count.index]}"
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/${local.names.eks_cluster}"= "shared"
  }

}

resource "aws_subnet" "private" {
  count             = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0


  vpc_id                  = aws_vpc.eks_cluster[0].id
  cidr_block              =  cidrsubnet(format("%s.100.0/20", local.var.network.vpc.prefix_subnet), ceil(log(length(data.aws_availability_zones.current_region.names), 2)), (count.index + 1))
  availability_zone       = data.aws_availability_zones.current_region.names[count.index]
  tags = {
    Name = "Prvt-${data.aws_availability_zones.current_region.names[count.index]}"
    "kubernetes.io/cluster/${local.names.eks_cluster}"= "shared"
  }
}

/* Gateways Nat and Internet */
resource "aws_internet_gateway" "igw" {
  count   = contains(local.var.flags, "create_network") ? 1 : 0

  vpc_id  = aws_vpc.eks_cluster[0].id

  tags = {
    Name        = "test-eks-igw"
    Description = "Internet Gateway for Public Subnets of ${local.var.environment}"
  }
}

# resource "aws_eip" "dev_eip" {
#   count = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0
#   domain   = "vpc"
#   tags = {
#     Name        = "${local.var.environment}-${data.aws_availability_zones.current_region.names[count.index]}-eip"
#     Description = "Elastic IP for NAT Gateway of ${local.var.environment}"
#   }
# }

# resource "aws_nat_gateway" "dev_natgw" {
#   count         = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0

#   allocation_id = element(aws_eip.dev_eip.*.id, count.index)
#   subnet_id     = element(aws_subnet.public.*.id, count.index)

#   depends_on    = [
#     aws_subnet.public
#   ]

#   tags = {
#     Name        = "${local.var.environment}-${data.aws_availability_zones.current_region.names[count.index]}-natgw"
#     Description = "NAT Gateway for ${data.aws_availability_zones.current_region.names[count.index]} of ${local.var.environment}"
#   }
# }

/* Route Tables */
# resource "aws_route_table" "private_rt" {
#   count  = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0
#   vpc_id  = aws_vpc.eks_cluster[0].id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = element(aws_nat_gateway.dev_natgw.*.id, count.index)
#   }


#   depends_on = [
#     aws_nat_gateway.dev_natgw
#   ]

#   tags = {
#     Name        = "${local.var.environment}-Private-${data.aws_availability_zones.current_region.names[count.index]}-rt"
#     Description = "Route table Target to Nat Gateway for ${local.var.environment}"
#   }
# }

resource "aws_route_table" "public_rt" {
  count  = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0
  vpc_id  = aws_vpc.eks_cluster[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }

  depends_on = [
    aws_internet_gateway.igw
  ]

  tags = {
    Name        = "${local.var.environment}-Public-${data.aws_availability_zones.current_region.names[count.index]}-routetable"
    Description = "Route table Target to Internet Gateway for ${local.var.environment}"
  }
}

/* Route Table Association to Public and Private Subnets */

# resource "aws_route_table_association" "dev_private_rta" {
#   count          = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0

#   subnet_id      = element(aws_subnet.private.*.id, count.index)
#   route_table_id = element(aws_route_table.private_rt.*.id, count.index)

#   depends_on = [
#     aws_subnet.private ,
#     aws_route_table.dev_private_rt,
#   ]
# }

resource "aws_route_table_association" "dev_public_rta" {
  count          = contains(local.var.flags, "create_network") ? length(data.aws_availability_zones.current_region.names) : 0

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public_rt.*.id, count.index)

  depends_on = [
    aws_subnet.public,
    aws_route_table.public_rt,
  ]
}




