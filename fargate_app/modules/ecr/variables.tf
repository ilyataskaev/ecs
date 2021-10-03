variable "repo_name" {
  type    = string
  default = "CHANGE_ME"
}
variable "common_tags" {
  type    = map(string)
  default = { IaC = "Terraform" }
}
variable "tags" { type = map(string) }