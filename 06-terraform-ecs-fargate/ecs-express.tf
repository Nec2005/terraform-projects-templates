# ecs.tf | Elastic Container Service Configuration

resource "aws_ecs_cluster" "ecs_cluster" {
    name = "${var.app_name}-${var.app_env}"
    
    tags = {
        Name        = "${var.app_name}-ecs_cluster"
  }
}

resource "aws_ecs_task_definition" "ncti" {
  family                   = "${var.app_name}-${var.app_env}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::894213385675:role/ecsTaskExecutionRole"  
   
  container_definitions = <<DEFINITION
  [
    {
      "name": "express",
      "image": "${var.ecr_url}:latest", 
      "entryPoint": [],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.ncti.id}",
          "awslogs-region": "${var.aws_region}", 
          "awslogs-stream-prefix": "ecs"
        }
      },
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ],
      "cpu": 128,
      "memory": 512,
      "networkMode": "awsvpc"
    }
  ]
  DEFINITION

  tags = {
    Name        = "${var.app_name}-ecs_td"
  }
}



resource "aws_ecs_service" "ncti" {
  name                               = "${var.app_name}-service-${var.app_env}"
  cluster                            = aws_ecs_cluster.ecs_cluster.id
  task_definition                    = aws_ecs_task_definition.ncti.arn #"${aws_ecs_task_definition.express.family}:${max(aws_ecs_task_definition.express.revision, data.aws_ecs_task_definition.express.revision)}"
  launch_type                        = "FARGATE"
  desired_count                      = 1
  force_new_deployment               = true
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 60

  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = true
    security_groups = [ aws_security_group.ecs_tasks.id ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ncti.arn
    container_name   = "express"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

  depends_on = [aws_lb_listener.http]
}