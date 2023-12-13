# Terraform Remote State Datasource - Remote Backend AWS S3
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "ncti-terraform-statefile-dev"
    key    = "dev/eks-cluster/terraform.tfstate"
    region = "eu-west-2"
  }   
}
