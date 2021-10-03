locals {
  region = "eu-north-1"
  tags = {
    CreatedBy = "ilya_taskaev"
    Purpose   = var.app_name
  }
}

module "ecr" {
  source    = "./modules/ecr"
  repo_name = var.app_name
  tags      = local.tags
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2"

  name = var.app_name
  cidr = "10.99.0.0/18"

  azs              = ["${local.region}a", "${local.region}b"]
  public_subnets   = ["10.99.0.0/24", "10.99.1.0/24"]
  private_subnets  = ["10.99.3.0/24", "10.99.4.0/24"]
  tags = local.tags
}

module "ecs" {
  source                         = "./modules/ecs"
  vpc                            = module.vpc.vpc_id
  service                        = var.app_name
  cluster_name                   = var.app_name
  public_subnets                 = module.vpc.public_subnets
  private_subnets                = module.vpc.private_subnets
  use_api_gateway                = var.use_api_gateway
  container_port                 = var.container_port
  container_cpu                  = var.container_cpu
  container_memory               = var.container_memory
  container_definitions          = var.container_definitions
  enable_execute_command         = var.enable_execute_command
  ecs_task_execution_role_policy = var.ecs_task_execution_role_policy
  use_https_listener             = var.use_https_listener
  tags                           = local.tags
}