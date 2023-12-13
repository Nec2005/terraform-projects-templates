# VPC Output Values

# VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = concat(module.vpc.*.vpc_id, [""])[0] 
}

# VPC CIDR blocks
output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.*.vpc_cidr_block
}

# VPC Private Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.*.private_subnets
}

# VPC Public Subnets
output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.*.public_subnets
}

# VPC NAT gateway Public IP
output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.*.nat_public_ips
}

# VPC AZs
output "azs" {
  description = "A list of availability zones spefified as argument to this module"
  value       = module.vpc.*.azs
}





### Outputs of Network Components ###
output "vpc_id" {
  value       = concat(aws_vpc.eks_cluster.*.id, [""])[0]
  description = "The ID of the VPC"
}
output "vpc" {
  value       = aws_vpc.eks_cluster
  description = "The Object of the VPC"
}
output "private_subnet_ids" {
  value       = aws_subnet.eks_private.*.id
  description = "List of IDs of Private Subnets"
}
output "public_subnet_ids" {
  value       = aws_subnet.eks_public.*.id
  description = "List of IDs of Public Subnets"
}
output "eip_ids" {
  value       = aws_eip.eks_eip.*.id
  description = "List of IDs of Elastic IPs"
}
output "nat_gateway_ids" {
  value       = concat(aws_nat_gateway.eks_natgw.*.id)
  description = "List of IDs of NAT Gateways"
}
output "internet_gateway_id" {
  value       = try(aws_internet_gateway.eks_igw[0].id, null)
  description = "The ID of the Internet Gateway"
}
output "private_route_table_ids" {
  value       = aws_route_table.eks_private_rt.*.id
  description = "List of IDs of Private Route Tables"
}
output "public_route_table_ids" {
  value       = aws_route_table.eks_public_rt.*.id
  description = "List of IDs of Public Route Tables"
}
# output "transit_gateway_cidrs" {
#   value       = local.var.network.routes.transit_gateway.cidr_blocks
#   description = "transit_gateway_cidrs"  
# }

# output "prometheus_auth_pwd" {
#   value       = contains(local.var.flags, "install_monitoring") ? random_password.prometheus_admin[0].result : ""
#   description = "Prometheus Auth Password"
#   sensitive   = true
# }

# output "grafana_auth_pwd" {
#   value       = contains(local.var.flags, "install_monitoring") ? random_password.grafana_admin[0].result : ""
#   description = "Grafana Auth Password"
#   sensitive   = true
# }

output "eks_nodes_ssh_private_key" {
  value     = tls_private_key.k8s_nodes_private_key.private_key_pem
  sensitive = true
}