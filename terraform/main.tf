data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

module "fargate_app" {
  source                         = "./fargate_app"
  app_name                       = var.app_name
  container_port                 = var.container_port
  container_definitions          = module.container.json_map_encoded_list
  ecs_task_execution_role_policy = data.aws_iam_policy_document.ecs_task_execution_role_policy.json
  use_api_gateway                = var.use_api_gateway
  use_https_listener             = false
}

data "aws_iam_policy_document" "ecs_task_execution_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*",
    ]
  }
}

module "container" {
  source          = "./container_definition_generator"
  container_name  = var.app_name
  container_image = "${module.fargate_app.ecr_repo_url}:latest"
  port_mappings = [{
    containerPort = "${var.container_port}"
    hostPort      = "${var.container_port}"
    protocol      = "tcp"
  }]
  log_configuration = {
    logDriver     = "awslogs"
    secretOptions = []
    options = {
      awslogs-group         = module.fargate_app.log_group_name
      awslogs-region        = data.aws_region.current.name
      awslogs-stream-prefix = "ecs"
    }
  }
}
