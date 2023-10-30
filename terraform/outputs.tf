output "ecr_repo_url" {
  value = module.fargate_app.ecr_repo_url
}
output "lb_dns_name" {
  value = module.fargate_app.lb_dns_name
}