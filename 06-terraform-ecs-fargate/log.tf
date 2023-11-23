# log.tf | VPC Log Configuration

resource "aws_cloudwatch_log_group" "ncti" {
  name = "/ecs/${var.app_name}-${var.app_env}"

    tags = {
        Name        = "${var.app_name}-log_group"
  }
}

resource "aws_flow_log" "ncti" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.ncti.arn
  traffic_type    = "ALL"
  vpc_id          = var.vpc_id
}
