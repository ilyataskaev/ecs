## Terraform
To run this example execute terraform:

```sh
cd terraform
export APP_NAME=interns-party
export TF_VAR_app_name=interns-party
terraform init -backend-config "workspace_key_prefix=${APP_NAME}"
terraform apply
```

## 2048

To build and run this docker container locally:

```sh
docker build -t nginx_2048:0.1 .
docker run -p 8080:80 -d --name nginx_2048 nginx_2048:0.1
```
