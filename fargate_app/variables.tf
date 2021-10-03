variable "workspace_iam_roles" {
  type = map(string)
  default = {
    sandbox = "arn:aws:iam::862906408407:role/maxdigital-terraform-role"
    dev     = "arn:aws:iam::899639894121:role/maxdigital-terraform-role"
    stage   = "arn:aws:iam::209591047112:role/maxdigital-terraform-role"
    prod    = "arn:aws:iam::840741539732:role/maxdigital-terraform-role"
  }
}
variable "container_port" {
  type    = number
  default = 80
}
variable "ingress_ports" {
  type    = list(number)
  default = [80, 443]
}
variable "container_cpu" {
  type = number
  default = 512
}
variable "container_memory" {
  type = number
  default = 2048
}
variable "app_name" {
  type    = string
  default = "CHANGE_ME"
}
variable "use_api_gateway" {
  type    = bool
  default = false
}
variable "use_newrelic_logs" {
  type    = bool
  default = false
}
variable "newrelic_license_key" {
  type    = string
  default = null
}
variable "container_definitions" {
  type    = string
  default = null
}
variable "ecs_task_execution_role_policy" {
  type    = string
  default = null
}
variable "domain_name_prefix" {
  type    = string
  default = null
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