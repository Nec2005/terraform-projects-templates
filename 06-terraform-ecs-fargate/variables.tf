# Global Variables
###################################################################################
variable "aws_profile" {
    type        = string
    default     = "default"
    description = "Profile name to access the AWS"
}

# variable "aws_access_key" {
#   type        = string
#   description = "AWS Access Key"
# }

# variable "aws_secret_key" {
#   type        = string
#   description = "AWS Secret Key"
# }

variable "aws_region" {
    type        = string
    default     = "eu-west-1"
    description = "AWS Region"
}

variable "app_name" {
    type        = string
    description = "Application Name"
}

variable "app_env" {
    type        = string
    description = "Application Environment"
}


# Network Variables
###################################################################################

variable "vpc_id" {
  description = "Default VPC Id"
}

variable "subnet_ids" {
  description = "List of subnetIds"
}

variable "ecr_url" {
  type = string
  description = "Elastic Container Repository Url"  
}