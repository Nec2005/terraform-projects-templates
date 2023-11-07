########################### General Variables ###########################
region                = "eu-west-2"
region_name           = "london"
platform              = "nu"
environment           = "dev"
key_name              = "dev1"

########################### Node Variables ###########################

node_groups = [
  {
    name                    = "my-dev-ec2"
    disk_size               = 30
    instance_type          = "t2.micro"
    create_launch_template  = "false"

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
    name          = "example-vpc"
    tags          = {
        Name        = "dev-vpc"
        Description = "VPC for dev"          
    }

  }
    enable_nat_gateway = "false"
    allowed_cidrs_to_access_cluster = []
}



