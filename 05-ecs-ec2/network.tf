# network.tf

# Fetch AZs in the current region
data "aws_availability_zones" "available" {
}

resource "aws_vpc" "main" {
 cidr_block           = var.vpc_cidr
 enable_dns_hostnames = true
 tags = {
   Name = "ECS-Apps"
 }
}
# Create var.az_count private subnets, each in a different AZ
resource "aws_subnet" "private" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id
}

# Create var.az_count public subnets, each in a different AZ
resource "aws_subnet" "public" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
}

# Internet Gateway for the public subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Route the public subnet traffic through the IGW
resource "aws_route_table" "public_rt" {
  vpc_id  = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  depends_on = [
    aws_internet_gateway.igw
  ]

}

resource "aws_route_table_association" "public_rta" {
  count          = var.az_count

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public_rt.*.id, count.index)

  depends_on = [
    aws_subnet.public,
    aws_route_table.public_rt,
  ]
}

# Create a NAT gateway with an Elastic IP for each private subnet to get internet connectivity
# resource "aws_eip" "gw" {
#   count      = var.az_count
#   domain   = "vpc"
#   depends_on = [aws_internet_gateway.gw]
# }

# resource "aws_nat_gateway" "gw" {
#   count         = var.az_count
#   subnet_id     = element(aws_subnet.public.*.id, count.index)
#   allocation_id = element(aws_eip.gw.*.id, count.index)
# }

# # Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
# resource "aws_route_table" "private" {
#   count  = var.az_count
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = element(aws_nat_gateway.gw.*.id, count.index)
#   }
# }

# # Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
# resource "aws_route_table_association" "private" {
#   count          = var.az_count
#   subnet_id      = element(aws_subnet.private.*.id, count.index)
#   route_table_id = element(aws_route_table.private.*.id, count.index)
# }

