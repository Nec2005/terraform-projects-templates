output "vpc_public_subnets" {
  description = "IDs of the VPC's public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "vpc_private_subnets" {
  description = "IDs of the VPC's private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "vpc" {
  value       = aws_vpc.eks_cluster
  description = "The Object of the VPC"
}


output "internet_gateway_id" {
  value       = try(aws_internet_gateway.igw[0].id, null)
  description = "The ID of the Internet Gateway"
}

output "public_route_table_ids" {
  value       = aws_route_table.public_rt.*.id
  description = "List of IDs of Public Route Tables"
}

