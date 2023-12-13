

# Create VPC Terraform Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  #version = "3.11.0"
  #version = "~> 3.11"
  version = "5.2.0"  
  
  # VPC Basic Details
  count = contains(local.var.flags, "create_network") ? 1 : 0

  name = "${terraform.workspace}-vpc"
  cidr = format("%s.0.0/16", local.var.network.vpc.prefix_subnet)
  #azs             = var.vpc_availability_zones
  azs             = data.aws_availability_zones.available.names
  public_subnets  = cidrsubnet(format("%s.0.0/21", local.var.network.vpc.prefix_subnet), ceil(log(length(data.aws_availability_zones.current_region.names), 2)), count.index)
  private_subnets = cidrsubnet(format("%s.100.0/20", local.var.network.vpc.prefix_subnet), ceil(log(length(data.aws_availability_zones.current_region.names), 2)), (count.index + 1))  

  # Database Subnets
  database_subnets = cidrsubnet(format("%s.200.0/20", local.var.network.vpc.prefix_subnet), ceil(log(length(data.aws_availability_zones.current_region.names), 2)), (count.index + 1))  
  create_database_subnet_group = local.var.network.vpc.create_database_subnet_group
  create_database_subnet_route_table = local.var.network.vpc.create_database_subnet_route_table
  # create_database_internet_gateway_route = true
  # create_database_nat_gateway_route = true
  
  # NAT Gateways - Outbound Communication
  enable_nat_gateway = local.var.network.vpc.enable_nat_gateway 
  single_nat_gateway = local.var.network.vpc.single_nat_gateway

  # VPC DNS Parameters
  enable_dns_hostnames = true
  enable_dns_support   = true

  vpc_tags = {
    Name        = "${terraform.workspace}-vpc"
    Description = "VPC for ${terraform.workspace}."
  }

  # Additional Tags to Subnets
  public_subnet_tags = {
    Name                     = "${terraform.workspace}-Public-${data.aws_availability_zones.current_region.names[count.index]}-subnet"
    Description              = "Public Subnet for ${terraform.workspace}."
    "kubernetes.io/role/elb" = 1    
    "kubernetes.io/cluster/${local.names.eks_cluster}" = "shared"        
  }
  private_subnet_tags = {
    Name                              = "${terraform.workspace}-Private-${data.aws_availability_zones.current_region.names[count.index]}-subnet"
    Description                       = "Private Subnet for ${terraform.workspace}."
    "kubernetes.io/role/internal-elb" = 1    
    "kubernetes.io/cluster/${local.names.eks_cluster}" = "shared"    
  }

  database_subnet_tags = {
    Name                              = "${terraform.workspace}-database-${data.aws_availability_zones.current_region.names[count.index]}-subnet"
    Description                       = "Database Subnet for ${terraform.workspace}."

  }
  # Instances launched into the Public subnet should be assigned a public IP address.
  map_public_ip_on_launch = true
}

