terraform {
  backend "s3" {
    bucket         = "terra-back-1339"
    key            = "terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform_lock"
  }
}
