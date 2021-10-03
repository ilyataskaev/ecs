# The task definition. This is a simple metadata description of what
# container to run, and what resource requirements it has.

resource "aws_ecs_task_definition" "task_definition" {
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  family                   = var.service
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = var.container_definitions
  task_role_arn            = var.enable_execute_command ? aws_iam_role.task_role[0].arn : null
  tags                     = merge(var.common_tags, var.tags)
}

resource "aws_ecs_service" "ecs_service_lb" {
  count                  = var.use_api_gateway ? 0 : 1
  enable_execute_command = var.enable_execute_command
  depends_on = [
    aws_lb_listener.public_lb_listener_https,
    aws_iam_role_policy.ecs_role_policy
  ]
  name                               = var.service
  cluster                            = aws_ecs_cluster.ecs_cluster.arn
  task_definition                    = aws_ecs_task_definition.task_definition.arn
  deployment_minimum_healthy_percent = "75"
  desired_count                      = "1"
  launch_type                        = "FARGATE"
  tags                               = merge(var.common_tags, var.tags)

  load_balancer {
    container_name   = var.service
    container_port   = var.container_port
    target_group_arn = aws_lb_target_group.service_target_group[0].arn
  }

  network_configuration {
    assign_public_ip = "true"
    security_groups  = [aws_security_group.container_sg.id]
    subnets          = var.private_subnets
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count
    ]
  }
}

