# variables.tf

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "eu-west-2"
}

variable "vpc_cidr" {
  description = "The AWS region things are created in"
  default     = "10.0.0.0/16"
}

variable "cluster_name" {
  description = "TCluster name"
  default     = "mytest-ecs"
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default = "myEcsTaskExecutionRole"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "607709576948.dkr.ecr.eu-west-2.amazonaws.com/my-demo-repo/clarusshop:latest"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = "80"
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = "1"
}

variable "health_check_path" {
  default = "/"
}

variable "ec2_cpu" {
  description = "ec2 instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "ec2_memory" {
  description = "ec2 instance memory to provision (in MiB)"
  default     = "1024"
}

