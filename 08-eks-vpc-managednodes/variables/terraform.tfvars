########################### General Variables ###########################
region                = "eu-west-1"
region_name           = "ireland"
platform              = "exp"
environment           = "dev"

########################### EKS Cluster Variables ###########################
cluster_version        = "1.26"
iam_eks_role_cluster_autoscaler_name  = "EKSClusterAutoscaler"
iam_eks_role_lb_name                  = "EKSLoadBalancer"

node_groups = [
  {
    name                    = "v1"
    disk_size               = 30
    instance_types          = ["t3.medium"]
    create_launch_template  = "false"

    autoscaling = {
      desired_size = 1
      min_size     = 1
      max_size     = 2
    }

    iam_role_additional_policies  = {
      AmazonEBSCSIDriverPolicy      = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }

  }
]


########################### Cluster AddOn Apps Installation Flags ###########################
flags = [
  "create_network",
  "install_metrics_server",
  "install_nginx_ingress_controller_external",
]


########################### Network Variables ###########################
network = {
  vpc = {
    cidr          = "10.92.0.0/16"
    prefix_subnet = "10.92"
    name          = "interview3-vpc"
    tags          = {
        Name        = "eks-vpc"
        Description = "VPC for EKS"
        "kubernetes.io/cluster/expressapi-nbs-test" = "shared"          
    }

  }
    
    allowed_cidrs_to_access_cluster = []

  # If need to access EKS cluster from public network, add the public ip in the below list
  eks_endpoint_public_access_cidrs = {
    external_ips = [
      "0.0.0.0/0",   # External IP 
    ]
  }

  eks_endpoint_public_access_ec2_instances = []

  # route53 = {
  #   external_domain = {
  #     zone_name = "xxx.com"
  #   }
  # }


}


########################### IAM Variables ######
iam = {
  eks_aws_auth_users = [
    {
      userarn  = "arn:aws:iam::894213385675:user/devops-interview3"
      username = "devops-interview3"
      groups   = [ "devops-interview" ]
    }
  ]

  eks_admin_access_group_users = [
    "devops-interview3"
  ]

  eks_viewonly_access_group_users = [
    "devops-interview1"
  ]


}

