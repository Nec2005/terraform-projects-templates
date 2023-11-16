locals {
    region                = "eu-west-2"
    region_name           = "london"
    environment           = "dev"
    key_name              = "ecr"

  
  names = {
    aws_profile_name      = "terraform"
    
  }

  default_tags = {
    #tf-workspace = terraform.workspace
    env          = local.environment
  }
}
