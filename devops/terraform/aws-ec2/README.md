# Terraform AWS EC2 (Student Friendly)

This Terraform module creates:

- 1 EC2 instance
- 1 security group (22, 80, 443)
- Bootstrapping for Docker + app deployment

## Steps

```bash
cd devops/terraform/aws-ec2
cp terraform.tfvars.example terraform.tfvars
# fill actual values
terraform init
terraform plan
terraform apply
```

To remove infra:

```bash
terraform destroy
```

## Good practice notes

- Use least-privilege IAM user for Terraform.
- Restrict `allowed_ssh_cidr` to your own IP, not `0.0.0.0/0`.
- Keep secrets out of git (use SSM/Secrets Manager in production).
