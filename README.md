# Cakes n Bakes 365 - Final Year DevOps Project

This is a full-stack bakery + fast-food ordering app.

Main goal of this version: project should look like a realistic fresher final-year submission, but still follow proper DevOps practices for deployment.

## Application Stack

- Frontend: HTML, CSS, Vanilla JS + Nginx
- Backend: Node.js + Express
- Database: PostgreSQL
- Reverse Proxy: Nginx (HTTPS + admin route protection)

## DevOps Tools Used

- Git + GitHub (source control)
- GitHub Actions (`.github/workflows/ci-cd.yml`)
- Jenkins (`Jenkinsfile`)
- Docker + Docker Compose
- Kubernetes manifests (`devops/k8s`)
- Helm chart (`devops/helm/cakesnbakes`)
- Terraform (AWS EC2 provisioning, `devops/terraform/aws-ec2`)
- Ansible (configuration + deployment, `devops/ansible`)
- Prometheus + Grafana + Exporters (`devops/monitoring`)
- Dependabot (`.github/dependabot.yml`)

## Quick Start (Docker Compose)

```bash
cp .env.ci.example .env
# update required values in .env
docker compose up -d --build
```

App endpoints:

- `https://localhost`
- `https://localhost/api/health`
- `https://localhost/admin` (basic auth protected)

Smoke test:

```bash
./scripts/smoke-test.sh
```

## CI/CD Pipelines

### 1) GitHub Actions

File: `.github/workflows/ci-cd.yml`

Pipeline stages:

1. Backend install + syntax check
2. Docker compose validation
3. Helm lint + Terraform fmt check
4. Docker build + smoke test
5. Publish backend/frontend images to GHCR (on push to `main`/`master`)

### 2) Jenkins

File: `Jenkinsfile`

Pipeline stages:

1. Checkout
2. Preflight checks
3. Prepare env
4. Backend static checks
5. Build images
6. Deploy with compose
7. Smoke tests (`scripts/smoke-test.sh`)

## Kubernetes Deployment

Basic manifests are in `devops/k8s`.

```bash
kubectl apply -f devops/k8s/namespace.yaml
kubectl apply -f devops/k8s/configmap.yaml
kubectl apply -f devops/k8s/secret.example.yaml
kubectl apply -f devops/k8s/postgres.yaml
kubectl apply -f devops/k8s/backend.yaml
kubectl apply -f devops/k8s/frontend.yaml
kubectl apply -f devops/k8s/ingress.yaml
kubectl apply -f devops/k8s/hpa.yaml
```

DB migration job:

```bash
kubectl -n cakesnbakes create configmap cnb-schema \
  --from-file=schema.sql=backend/sql/schema.sql
kubectl apply -f devops/k8s/db-migration-job.yaml
```

## Helm Deployment

```bash
helm upgrade --install cnb devops/helm/cakesnbakes -n cakesnbakes --create-namespace
```

## Terraform + Ansible Deployment (VM based)

1. Provision EC2 using Terraform:

```bash
cd devops/terraform/aws-ec2
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

2. Deploy app on VM using Ansible:

```bash
cd /home/rakshit/new-project
cp devops/ansible/inventory.ini.example devops/ansible/inventory.ini
# update server IP and key path
ansible-galaxy collection install -r devops/ansible/requirements.yml
ansible-playbook -i devops/ansible/inventory.ini devops/ansible/deploy.yml
```

## Monitoring Setup

```bash
cd devops/monitoring
docker compose -f docker-compose.monitoring.yml up -d
```

Dashboards:

- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3001` (admin/admin123)

## Makefile Commands

```bash
make help
make up
make smoke
make ci-check
make monitor-up
make helm-install
```

## DevOps Practices Implemented

- CI on every PR and push
- CD pipeline for image publishing
- Containerized app and environment parity
- IaC for infra (Terraform)
- Config management (Ansible)
- Orchestration (Kubernetes + Helm)
- Health checks + smoke tests
- Basic observability and alert rules
- Dependency update automation
- Secret separation using env/secret files

## Project Structure

```text
.
├── backend/
├── frontend/
├── proxy/
├── ci/
├── scripts/
├── devops/
│   ├── ansible/
│   ├── helm/
│   ├── k8s/
│   ├── monitoring/
│   └── terraform/
├── .github/workflows/
├── Jenkinsfile
└── docker-compose.yml
```

## Important Notes

- `secret.example.yaml` is only sample; do not use sample secrets in production.
- Replace image names (`ghcr.io/your-github-username/...`) before deployment.
- For real production, use managed secret tools (AWS Secrets Manager, Vault, etc.).
