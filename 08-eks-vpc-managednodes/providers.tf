
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.0"
    }
    tfvars = {
      source  = "innovationnorway/tfvars"
      version = "0.0.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5.1"
    }

  }
  backend "s3" {
    # S3 Bucket Configs
    bucket  = "nbs-devops-interviews-terraform"
    key     = "necati_eks/terraform.tfstate"
    region  = "eu-west-1"

  }  
}

provider "tfvars" {}

provider "aws" {
  region = local.var.region
  profile = local.names.aws_profile_name

  default_tags {
    tags = local.default_tags
  }
}


data "aws_eks_cluster_auth" "default" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", local.var.region]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"

      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", local.var.region]
    }
  }
}



