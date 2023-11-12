
terraform {
  /* Uncomment this block to use Terraform Cloud 
  cloud {
    organization = "organization-name"
    workspaces {
      name = ""
    }
  }
  */

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    tfvars = {
      source  = "innovationnorway/tfvars"
      version = "0.0.1"
    }
  }
  #required_version = ">= 1.1.0"
}

provider "aws" {
  region = local.var.region
  profile = local.names.aws_profile_name

  default_tags {
    tags = local.default_tags
  }
}


provider "tfvars" {}
