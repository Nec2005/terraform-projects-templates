locals {

  var                 = data.tfvars_file.env.variables
  prefix              = "${local.var.platform}-nbs-${local.var.environment}"
  cluster_ip_family   = "ipv4"
  k8s_external_domain = local.var.network.route53.external_domain.zone_name

  names = {
    aws_profile_name                = "nbstest"
    eks_cluster                     = "${local.prefix}"
    key_name                        = "eksnodes"

    iam_eks_role_cluster_autoscaler = "${replace(title(local.prefix), "-", "")}${local.var.iam_eks_role_cluster_autoscaler_name}"
    iam_eks_role_lb                 = "${replace(title(local.prefix), "-", "")}${local.var.iam_eks_role_lb_name}"
    cluster_autoscaler              = "cluster-autoscaler"
    cluster_autoscaler_fullname     = "aws-cluster-autoscaler"
    aws_load_balancer               = "aws-load-balancer-controller"
    ingress_nginx_external          = "ingress-nginx-external"

    terraform_viewonly_group = "terraform-viewonly-group"
    k8s_rbac_admin_group     = "nu-admin-group"
    k8s_rbac_viewonly_group  = "nu-viewonly-group"

    security_groups = {
      cluster              = "${local.prefix}-eks-cluster-sg"
      cluster_access_allow = "${local.prefix}-eks-cluster-access-allow"
      stub                 = "${local.prefix}-eks-stub-sg"
    }    
  }

  const = {
    kube_system_ns = "kube-system"
    all_ips        = ["0.0.0.0/0"]
    all_ipv6_ips   = ["::/0"]
  }

  default_tags = {
    env          = local.var.environment
    created-by   = "terraform-int3"
  }
}
