output "alb" {
  value = aws_security_group.alb.id
}

output "ecs_tasks" {
  value = aws_security_group.ecs_tasks.id
}

output "alb_hostname" {
  value = aws_lb.ncti.dns_name
}
