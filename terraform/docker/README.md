# Docker via Terraform

Creates docker container via Terraform

## Usage

```bash
# to login to GCP as human user
make init-terraform
# sping nginx container via Terraform
make nginx.tfvars [MODE=apply] [DEBUG=false]


# test whether Nginx is running
make test

# close nginx container
make nginx.tfvars MODE=destroy
```
