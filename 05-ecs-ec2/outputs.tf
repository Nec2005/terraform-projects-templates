# outputs.tf

output "alb_hostname" {
  value = aws_lb.ecs_alb.dns_name
}

