# Infrastructure
This folder contains Terraform configuration files to create AWS resources in predefined MAX Digital accounts & VPCs, to enable the launch of a container-based application using the following services:
* Elastic Container Registry (ECR) - to host the Docker image (and its versions) of the application.
* Elastic Container Service (ECS) - to run one or more instances of the application's container.
  * Specifically, using a Fargate Service with auto-scaling configuration to ensure capacity (and expenses) match the demand/usage of the application in the different environments.
  * **Note:** There is no support for Windows applications/containers.
* API Gateway - to route public traffic to the ECS service (which is running in private subnets).
  *  To launch the application using an API Gateway, set `var.use_api_gateway = true`.  
  *  `var.use_api_gateway` is set to `false` by default.
* Application Load Balancer (ALB) - an alternative method to route incoming public traffic, useful when the application should handle both HTTP and HTTPS or when path- and header-based routing is required.
* Route53 - to map a public subdomain to the application.
  * **Note:** Route53 supports both API Gateway and ALB respectively, depends what set by variable `var.use_api_gateway`

## Prerequisites

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |

The following resources are assumed to exist prior to deploying any instance of this configuration. They are the specific settings for MAX Digital's environments that could serve as deployment-targets for this application.
* **max-ito** AWS account to manage shared/cross-environment resources, such as ECR, Route53 & IAM access (i.e. the `github_actions` IAM user in max-ito, which is used for deployment automation).
* **max-production** AWS account, VPC, private & public subnets for the Production environment.
  * Will make this application available at `<app_name>.max.firstlook.biz`.
* **max-staging** AWS account, VPC, private & public subnets for the Staging environment.
  * Will make this application available at `<app_name>.maxstage.firstlook.biz`.
* **max-development** AWS account, VPC, private & public subnets for the Development environment.
  * Will make this application available at `<app_name>.maxdev.firstlook.biz`.
* **max-sandbox** AWS account, VPC, private & public subnets for the Sandbox environment.
  * Will make this application available at `<app_name>.sandbox.maxdigital.com`.
  * Only used for prototyping, _not_ appropriate for long-term deployments.


## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecr"></a> [ecr](#module\_ecr) | ./modules/ecr | Module responsible for ECR creation |
| <a name="module_ecs"></a> [ecs](#module\_ecs) | ./modules/ecs | Module responsible for ECS and related resources creation |
| <a name="module_max-ito_dns"></a> [max-ito\_dns](#module\_max-ito\_dns) | ./modules/dns | Creates Route53 DNS record in ITO account, by default. |
| <a name="module_sandbox_dns"></a> [sandbox\_dns](#module\_sandbox\_dns) | ./modules/dns | Creates Route53 DNS record in ITO account, only if workspace is sandbox. |
| <a name="module_subnets"></a> [subnets](#module\_subnets) | ../shared/subnets_lookup | Return VPC ID, Private and Public subnets, IP addresses of DNS servers |


## Inputs, Variables and Outputs
The main set of variables can be found in [variables.tf](variables.tf). Everything is set to desirable defaults, so it shouldn't have to be modified. However, it's a good place to start when reviewing or troubleshooting this configuration.

The most important thing to remember is that almost all resources will use the project's name as part of their naming-convention. This is configured in `var.app_name` and by default uses the Git repository's name (see [terraform.yml](../.github/workflows/terraform.yml#L52)).

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Almost all resources contains in their names this variable, and by default uses the Git repository's name | `string` | `"CHANGE_ME"` | yes |
| <a name="input_certificate_arns"></a> [certificate\_arns](#input\_certificate\_arns) | Certificate ARNS for ALB and API gateway, selected by terraform workspace | `map(string)` | <pre>{<br>  "dev": "arn:aws:acm:us-east-1:899639894121:certificate/d26d6fe7-d7a2-42bb-a76f-acb15c7b3b95",<br>  "prod": "arn:aws:acm:us-east-1:840741539732:certificate/ed02fced-37c5-411e-bcef-adf06b8417a4",<br>  "sandbox": "arn:aws:acm:us-east-1:862906408407:certificate/e818d7d4-b66d-4d9f-9a54-4559e9adffca",<br>  "stage": "arn:aws:acm:us-east-1:209591047112:certificate/e7a109dc-2d98-44cc-9c52-1bda4a8ab1c3"<br>}</pre> | no |
| <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu) | The number of cpu units reserved for the container | `map(number)` | <pre>{<br>  "dev": 512,<br>  "prod": 512,<br>  "sandbox": 512,<br>  "stage": 512<br>}</pre> | no |
| <a name="input_container_definitions"></a> [container\_definitions](#input\_container\_definitions) | Json document with preconfigured container_definitions, better to generate it by <a name="container_definition_generator"></a> [container_definition_generator](../shared/container_definition_generator) module  | `string` | `null` | yes |
| <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory) | The amount (in MiB) of memory to present to the container | `map(number)` | <pre>{<br>  "dev": 2048,<br>  "prod": 2048,<br>  "sandbox": 2048,<br>  "stage": 2048<br>}</pre> | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Port on the container to associate with the load balancer, port of the container which is listen to. | `number` | `80` | no |
| <a name="input_custom_domain_root"></a> [custom\_domain\_root](#input\_custom\_domain\_root) | Route53 domain root for environment | `map(string)` | <pre>{<br>  "dev": "maxdev.firstlook.biz",<br>  "prod": "max.firstlook.biz",<br>  "sandbox": "sandbox.maxdigital.com",<br>  "stage": "maxstage.firstlook.biz"<br>}</pre> | no |
| <a name="input_domain_name_prefix"></a> [domain\_name\_prefix](#input\_domain\_name\_prefix) | Domain name prefix, by default `var.app_name`, but if needed you can specify different one. If your DNS name needs to be different from repository name, for example, DNS for `max-reports` starts from `reports`. | `string` | `null` | no |
| <a name="input_ecs_task_execution_role_policy"></a> [ecs\_task\_execution\_role\_policy](#input\_ecs\_task\_execution\_role\_policy) | Amazon ECS task execution IAM role [Documentation link](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html) You should use data `aws_iam_policy_document` resource to generate the document. | `string` | `null` | yes |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Workaround to specify full name of the environment | `map(string)` | <pre>{<br>  "dev": "development",<br>  "prod": "production",<br>  "sandbox": "sandbox",<br>  "stage": "staging"<br>}</pre> | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | The image used to start a container. You should take Image name from the ECR. | `string` | `"commandcenter"` | no |
| <a name="input_ingress_ports"></a> [ingress\_ports](#input\_ingress\_ports) | List of ingress ports assigned to the ALB | `list(number)` | <pre>[<br>  80,<br>  443<br>]</pre> | no |
| <a name="input_newrelic_license_key"></a> [newrelic\_license\_key](#input\_newrelic\_license\_key) | Newrelic license key | `string` | `null` | no |
| <a name="input_route53_zone_ids"></a> [route53\_zone\_ids](#input\_route53\_zone\_ids) | List of route53 zone ids | `map(string)` | <pre>{<br>  "dev": "Z097218625LSHYVAYZ5S5",<br>  "prod": "Z065749312GIJ4QYWCK53",<br>  "sandbox": "ZGTCIV9SV2BXO",<br>  "stage": "Z08955942K9GN1UACOHT6"<br>}</pre> | no |
| <a name="input_use_api_gateway"></a> [use\_api\_gateway](#input\_use\_api\_gateway) | Select what you application will be use ALB or API gateway, ALB by default  | `bool` | `false` | no |
| <a name="input_use_newrelic_logs"></a> [use\_newrelic\_logs](#input\_use\_newrelic\_logs) | Select support of newrelic log, several resources will be created. | `bool` | `false` | no |
| <a name="input_workspace_iam_roles"></a> [workspace\_iam\_roles](#input\_workspace\_iam\_roles) | Manage access from MAX ITO account to other environments, by using AWS assume role. | `map(string)` | <pre>{<br>  "dev": "arn:aws:iam::899639894121:role/maxdigital-terraform-role",<br>  "prod": "arn:aws:iam::840741539732:role/maxdigital-terraform-role",<br>  "sandbox": "arn:aws:iam::862906408407:role/maxdigital-terraform-role",<br>  "stage": "arn:aws:iam::209591047112:role/maxdigital-terraform-role"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_repo_url"></a> [ecr\_repo\_url](#output\_ecr\_repo\_url) | ECR repo URL |

## How to use this module and minimal configuration

To use this module you should use module resource in terrafrom (Example for SNS, for more examples please look at examples [folder](./examples/)).
 * **Note:** `source` is refer to this repository, `//` to the folder inside the repository and `?ref=` to the branch.

```hcl
module "fargate_app" {
  source                         = "git::https://github.com/maxsystems/terraform-max-modules.git//fargate_app/?ref=MAX-9127"
  app_name                       = var.app_name
  container_definitions          = module.container.json_map_encoded_list
  ecs_task_execution_role_policy = data.aws_iam_policy_document.ecs_task_execution_role_policy.json
}
data "aws_iam_policy_document" "ecs_task_execution_role_policy" { 
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sns:GetTopicAttributes"
    ]
    resources = [
      "arn:aws:sns:us-east-1:*:${var.app_name}-*",
    ]
  }
}
module "container" {
  source          = "git::https://github.com/maxsystems/terraform-max-modules.git//shared/container_definition_generator/?ref=MAX-9127"
  container_name  = var.app_name
  container_image = module.fargate_app.ecr_repo_url
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

```

## Caveats
While the Terraform configuration here specifically targets the max-ito account for creating the ECR repository, it still attempts to create it whenever a new environment is initialized. Therefore, after successfully applying the configuration in the first environment, you must import the ECR repository whenever you initialize a new workspace/environment:
```terraform import module.fargete_app.module.ecr.aws_ecr_repository.ecr_repo <app_name>```

This is only necessary for new environments. If you are reading this more than a few days after the project was created, it's probably already done.

## Automation
There are two GitHub Actions workflows that work hand-in-hand with the Terraform configuration:
* [terraform.yml](../.github/workflows/terraform.yml) - for deploying Terraform changes, accepts parameters for branch, environment and Terraform Action (`plan` or `apply`).
  * You can run this workflow with `plan` at any time and watch the output to find if there are any differences between the target environment and the configuration in your branch.
  * If you run with `apply` ***it will automatically deploy the config to the environment*** - there are no more confirmation steps or any warnings.
  * This project uses `fargate_app` and `container_definition_generator` modules, which are placed in the [terraform-max-modules](https://github.com/maxsystems/terraform-max-modules/tree/MAX-9127/) repository
* [docker-ecs.yml](../.github/workflows/docker-ecs.yml) - for building a Docker image with the current version of the code, pushing it to ECR and deploying it to the selected environment.
  * This is what should be used to deploy updates to the app.
  * It is currently configured for manual-trigger only, but the workflow can be updated to trigger automatic deployments per the desired SDLC.
  * The workflow uses the [Dockerfile](../Dockerfile) located at the root of the project.
    * **Note:** If the port exposed by the container ever changes, make sure to update `container_port` in [variables.tf](variables.tf) and apply the Terraform changes in all relevant environments.