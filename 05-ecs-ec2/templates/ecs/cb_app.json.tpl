[
  {
    "name": "shop-app",
    "image": "${app_image}",
    "cpu": ${ec2_cpu},
    "memory": ${ec2_memory},
    "networkMode": "awsvpc",
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${app_port},
        "hostPort": ${app_port},
        "protocol": "tcp"
      }
    ]
  }
]
