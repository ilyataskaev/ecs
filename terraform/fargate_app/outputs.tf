output "ecs_task_execution_role_policy" {
  value = var.ecs_task_execution_role_policy
}
output "ecr_repo_url" {
  value = module.ecr.repo_url
}
output "log_group_name" {
  value = module.ecs.log_group_name
}
