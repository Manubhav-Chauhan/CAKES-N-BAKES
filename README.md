# 🍰 Cakes n Bakes 365 — Final Year DevOps Project

Hey! This is my final year B.Tech project where I built a full-stack bakery ordering app and deployed it using various DevOps tools and practices.

The idea is simple — a local bakery called **Cakes n Bakes 365** needs an online ordering system. I built the app from scratch and then focused on containerizing it, setting up CI/CD pipelines, and deploying it on different platforms.

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | HTML, CSS, Vanilla JS |
| Backend | Node.js, Express |
| Database | PostgreSQL |
| Containerization | Docker, Docker Compose |
| CI/CD | GitHub Actions, Jenkins |
| Orchestration | Kubernetes (manifests + Helm) |
| IaC | Terraform (AWS EC2) |
| Config Mgmt | Ansible |
| Monitoring | Prometheus, Grafana |
| Reverse Proxy | Nginx (with self-signed SSL) |

## 🚀 How to Run (Quick Start)

This is the easiest way to get everything running locally:

```bash
# 1. clone the repo
git clone https://github.com/your-username/cakesnbakes365.git
cd cakesnbakes365

# 2. the .env file already has demo defaults, so just run:
docker compose up -d --build
```

Once it's up, open these URLs:

- **App**: https://localhost
- **Health check**: https://localhost/api/health
- **Admin panel**: https://localhost/admin (username/password from .env)

To run smoke tests:

```bash
./scripts/smoke-test.sh
```

To stop everything:

```bash
docker compose down
```

## 📁 Project Structure

```
.
├── backend/          # Node.js API server
├── frontend/         # Static HTML/CSS/JS served by Nginx
├── proxy/            # Nginx reverse proxy (SSL + admin auth)
├── devops/
│   ├── k8s/          # Kubernetes manifests
│   ├── helm/         # Helm chart
│   ├── terraform/    # Terraform config for AWS EC2
│   ├── ansible/      # Ansible playbook for deployment
│   └── monitoring/   # Prometheus + Grafana setup
├── scripts/          # Helper scripts (smoke test, devops checks)
├── ci/               # CI helper scripts
├── .github/workflows/  # GitHub Actions pipeline
├── Jenkinsfile       # Jenkins pipeline
├── docker-compose.yml
├── Makefile
└── .env
```

## 🔄 CI/CD Pipelines

### GitHub Actions (`.github/workflows/ci-cd.yml`)

Runs on every push/PR to main:
1. Install backend deps + syntax check
2. Validate docker-compose file
3. Build all containers + run smoke tests
4. Push images to GitHub Container Registry (on main branch only)

### Jenkins (`Jenkinsfile`)

Same idea but for Jenkins:
1. Checkout code
2. Copy env file
3. Check backend syntax
4. Build Docker images
5. Deploy with docker compose
6. Run smoke tests

## ☸️ Kubernetes Deployment

I wrote raw K8s manifests in `devops/k8s/`:

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

There's also a Helm chart for easier deployment:

```bash
helm upgrade --install cnb devops/helm/cakesnbakes -n cakesnbakes --create-namespace
```

## ☁️ Terraform + Ansible (VM Deployment)

For deploying on a real VM:

```bash
# provision EC2 instance
cd devops/terraform/aws-ec2
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your AWS details
terraform init && terraform apply

# deploy app using Ansible
cd /path/to/project
cp devops/ansible/inventory.ini.example devops/ansible/inventory.ini
# update the server IP and key path
ansible-playbook -i devops/ansible/inventory.ini devops/ansible/deploy.yml
```

## 📊 Monitoring

```bash
cd devops/monitoring
docker compose -f docker-compose.monitoring.yml up -d
```

- Prometheus: http://localhost:9090
- Grafana: http://localhost:3001 (login: admin / admin123)

## 🧰 Makefile Commands

```bash
make help       # see all commands
make up         # start the app
make down       # stop the app
make logs       # follow logs
make smoke      # run smoke tests
make ci-check   # run local devops checks
```

## 📚 What I Learned

- How to containerize a multi-service app with Docker
- Setting up CI/CD pipelines with GitHub Actions and Jenkins
- Writing Kubernetes manifests and Helm charts
- Infrastructure as Code with Terraform
- Server configuration with Ansible
- Monitoring with Prometheus and Grafana
- Nginx reverse proxy with SSL termination
- Managing secrets and environment variables properly

## ⚠️ Notes

- The `secret.example.yaml` has dummy values — don't use in production
- Replace image names (`ghcr.io/your-github-username/...`) with your own before deploying
- The SSL cert is self-signed (browsers will show a warning, that's normal)
- For real production use managed secrets (AWS Secrets Manager, HashiCorp Vault, etc.)

---

Made with ❤️ as part of my B.Tech Final Year Project
