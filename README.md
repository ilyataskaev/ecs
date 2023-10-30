## Terraform
To run this example execute terraform:

Add Secrets to  GitHub:

```
AWS_ACCESS_KEY
AWS_SECRET_KEY
```

```sh
cd terraform
export TF_VAR_app_name=ecs
terraform init
terraform apply
```

Deploy locally

(Article)[https://docs.aws.amazon.com/AmazonECR/latest/userguide/getting-started-cli.html]

```
aws ecr get-login-password --region region | docker login --username AWS --password-stdin aws_account_id.dkr.ecr.region.amazonaws.com
```
## 2048

To build and run this docker container locally:

```sh
cd docker
docker build -t aws_account_id.dkr.ecr.region.amazonaws.com/interns-party:latest .
docker push 385379752235.dkr.ecr.eu-north-1.amazonaws.com/interns-party:latest
```
