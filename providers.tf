# Every AWS customer should have a "providers.tf" file that represents the
# connection to the customer's AWS environments. Normally API keys
# are specified here for access, but we're using IAM roles and
# cross account access.

# This sets up Terraform to use the AWS provider, which fetches the AWS
# specific modules for use with our templates. We specify the ARN used to
# switch roles into the target account. Read more here:
# https://www.terraform.io/docs/providers/aws/index.html

provider "aws" {
  region = "eu-north-1"
}
