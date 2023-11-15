# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "vpc_public_subnets" {
  description = "IDs of the VPC's public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "ec2_instance_private_ips" {
  description = "Public IP addresses of EC2 instances"
  value       = module.ec2_instances[*].private_ip
}

output "ec2_instance_ids" {
  value = module.ec2_instances[*].id
}

output "private_key" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}
