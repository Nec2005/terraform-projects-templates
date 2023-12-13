###################### External Ingress Controller ######################

resource "helm_release" "nginx_ingress_controller_external" {
  count = contains(local.var.flags, "install_nginx_ingress_controller_external") ? 1 : 0

  name  = local.names.ingress_nginx_external
  chart = "./helm/ingress-nginx"

  timeout = 20 * 60 # 20min

  reset_values = true
  wait         = true

  set {
    name  = "vpcCIDR"
    value = local.var.network.vpc.cidr
  }

  set {
    name  = "certARN"
    value = "arn:aws:acm:eu-west-2:607709576948:certificate/d2d5ced5-3891-4cdc-a420-951b1acefa31"
  }

  depends_on = [
    module.eks,
    helm_release.aws_load_balancer,
  ]
}

data "kubernetes_service" "ingress_nginx_controller_external" {
  count = contains(local.var.flags, "install_nginx_ingress_controller_external") ? 1 : 0

  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  depends_on = [
    helm_release.nginx_ingress_controller_external
  ]
}
