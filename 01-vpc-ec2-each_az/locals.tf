locals {

  var                 = data.tfvars_file.env.variables
  prefix              = "${local.var.platform}-my-${local.var.region_name}-${local.var.environment}"
  cluster_ip_family   = "ipv4"
  regions = length(data.aws_availability_zones.current_region.names)
  
  names = {
    aws_profile_name                = "terraform"
    
  }

  const = {
    kube_system_ns = "kube-system"
    all_ips        = ["0.0.0.0/0"]
    all_ipv6_ips   = ["::/0"]
  }

  default_tags = {
    tf-workspace = terraform.workspace
    env          = local.var.environment
  }
}
