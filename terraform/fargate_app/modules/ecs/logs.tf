resource "aws_cloudwatch_log_group" "log_group" {
  name              = var.log_group_name != "" ? var.log_group_name : "/ecs/${var.service}-${terraform.workspace}"
  retention_in_days = "14"
}
