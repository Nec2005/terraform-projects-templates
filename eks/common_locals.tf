locals {

  var                 = data.tfvars_file.env.variables
  prefix              = "${local.var.platform}-k8s-${local.var.region_name}-${local.var.environment}"
  cluster_ip_family   = "ipv4"
  k8s_external_domain = local.var.network.route53.external_domain.zone_name

  names = {
    aws_profile_name                = "terraform"
    key_name                        = "eksnodes"
    eks_cluster                     = "${local.prefix}"
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
    efs_csi_driver = {
      name                  = "aws-efs-csi-driver"
      image_repository      = "602401143452.dkr.ecr.eu-west-2.amazonaws.com/eks/aws-efs-csi-driver"
      service_account_name  = "aws-efs-csi-driver-sa"
    }

  }

  const = {
    kube_system_ns = "kube-system"
    all_ips        = ["0.0.0.0/0"]
    all_ipv6_ips   = ["::/0"]
  }

  default_tags = {
    TerraformWorkspace = "dev"

    created-by   = "terraform-nu"
    tf-workspace = terraform.workspace
    env          = local.var.environment
  }
}
