variable "vpc" { type = string }
variable "common_tags" {
  type    = map(string)
  default = { IaC = "Terraform" }
}
variable "tags" { type = map(string) }
variable "service" { type = string }
variable "container_port" { type = number }
variable "container_cpu" {}
variable "container_memory" {}
variable "container_definitions" {}
variable "public_subnets" {}
variable "private_subnets" {}
variable "cluster_name" { type = string }
variable "health_check_path" {
  type    = string
  default = "/"
}
variable "use_api_gateway" { type = bool }
variable "newrelic_license_key" {
  type    = string
  default = null
}
variable "log_group_name" {
  default     = ""
  description = "name of the Log group, if not set will be default"
}
variable "ecs_task_execution_role_policy" {
  description = "Role policy for the Task execution role"
}
#TODO add this var on higher level
variable "ingress_ports" {
  type    = list(number)
  default = [80, 443]
}
variable "enable_execute_command" {
  description = "Specifies whether to enable Amazon ECS Exec for the tasks within the service."
  type        = bool
  default     = false
}
variable "use_https_listener" {
  description = "use https listener oe not"
  type = bool
  default = true
}