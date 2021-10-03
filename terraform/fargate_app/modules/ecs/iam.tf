# A role used to allow AWS Autoscaling to inspect stats and adjust scalable targets
# on your AWS account
resource "aws_iam_role" "autoscaling_role" {
  name               = "${var.service}-autoscaling-role"
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "application-autoscaling.amazonaws.com"
      }
    }
  ],
  "Version": "2008-10-17"
}
POLICY
  path               = "/"
  tags               = merge(var.common_tags, var.tags)
}

resource "aws_iam_role_policy" "service_autoscaling" {
  name = "${var.service}-ecs-autoscaling-policy"
  role = aws_iam_role.autoscaling_role.id

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": [
        "application-autoscaling:*",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:PutMetricAlarm",
        "ecs:DescribeServices",
        "ecs:UpdateService"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

# This is an IAM role which authorizes ECS to manage resources on your
# account on your behalf, such as updating your load balancer with the
# details of where your containers are, so that traffic can reach your
# containers.

resource "aws_iam_role" "ecs_role" {
  name               = "${var.service}-ecs-service-role"
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  description          = "Role to enable Amazon ECS to manage your cluster."
  max_session_duration = "3600"
  path                 = "/"
  tags                 = merge(var.common_tags, var.tags)
}


resource "aws_iam_role_policy" "ecs_role_policy" {
  name = "${var.service}-ecs-service"
  role = aws_iam_role.ecs_role.id

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": [
        "ec2:AttachNetworkInterface",
        "ec2:CreateNetworkInterface",
        "ec2:CreateNetworkInterfacePermission",
        "ec2:DeleteNetworkInterface",
        "ec2:DeleteNetworkInterfacePermission",
        "ec2:Describe*",
        "ec2:DetachNetworkInterface",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.service}-ecs-task-execution-role"
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
    }
  ],
  "Version": "2008-10-17"
}
POLICY

  max_session_duration = "3600"
  path                 = "/"

  tags = merge(var.common_tags, var.tags)

}

resource "aws_iam_role_policy" "ecs_task_execution_role_policy" {
  name   = "${var.service}-AmazonECSTaskExecutionRolePolicy"
  role   = aws_iam_role.ecs_task_execution_role.id
  policy = var.ecs_task_execution_role_policy
}

resource "aws_iam_role" "task_role" {
  count = var.enable_execute_command ? 1 : 0
  name               = "${var.service}-ecs-task-role"
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
    }
  ],
  "Version": "2008-10-17"
}
POLICY
  max_session_duration = "3600"
  path                 = "/"
  tags = merge(var.common_tags, var.tags)
}

resource "aws_iam_role_policy" "task_role_policy" {
  count = var.enable_execute_command ? 1 : 0
  name = "${var.service}-ecs-task-role"
  role = aws_iam_role.task_role[0].id

  policy = <<POLICY
{
   "Version": "2012-10-17",
   "Statement": [
       {
       "Effect": "Allow",
       "Action": [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
       ],
      "Resource": "*"
      }
   ]
}
POLICY
}