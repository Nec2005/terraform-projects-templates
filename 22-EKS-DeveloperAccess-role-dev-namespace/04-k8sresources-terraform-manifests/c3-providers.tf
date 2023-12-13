# Terraform AWS Provider Block
provider "aws" {
  region = "eu-west-2"
  #profile = "terraform"

}

# Terraform Remote State Datasource
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "ncti-terraform-statefile-dev"
    key    = "dev/eks-cluster/terraform.tfstate"
    region = "eu-west-2"
  }   
}

# Datasource: EKS Cluster
data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id
}

# Datasource: EKS Cluster Authentication
data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id
}

# Terraform Kubernetes Provider
provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}