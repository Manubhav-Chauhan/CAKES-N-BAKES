<p align="center">
  <img src="https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white" />
  <img src="https://img.shields.io/badge/Express-000000?style=for-the-badge&logo=express&logoColor=white" />
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" />
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" />
  <img src="https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white" />
  <img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" />
  <img src="https://img.shields.io/badge/Ansible-EE0000?style=for-the-badge&logo=ansible&logoColor=white" />
  <img src="https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white" />
  <img src="https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white" />
  <img src="https://img.shields.io/badge/Istio-466BB0?style=for-the-badge&logo=istio&logoColor=white" />
  <img src="https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white" />
  <img src="https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white" />
  <img src="https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=jenkins&logoColor=white" />
  <img src="https://img.shields.io/badge/Helm-0F1689?style=for-the-badge&logo=helm&logoColor=white" />
  <img src="https://img.shields.io/badge/LitmusChaos-451FDB?style=for-the-badge&logo=litmus&logoColor=white" />
</p>

<h1 align="center">Cakes n Bakes 365</h1>

<p align="center">
  <strong>A Production-Grade Full-Stack Bakery Ordering Platform with End-to-End DevOps Pipeline</strong>
</p>

<p align="center">
  <a href="https://github.com/rakshitmalik136/Final-year_Project/actions"><img src="https://github.com/rakshitmalik136/Final-year_Project/actions/workflows/ci-cd.yml/badge.svg" alt="CI/CD" /></a>
  <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License" />
  <img src="https://img.shields.io/badge/node-%3E%3D20-brightgreen" alt="Node" />
  <img src="https://img.shields.io/badge/docker--compose-v2-blue" alt="Docker Compose" />
  <img src="https://img.shields.io/badge/k8s-1.28+-326CE5" alt="Kubernetes" />
</p>

<p align="center">
  <a href="#-quick-start">Quick Start</a> •
  <a href="#-architecture">Architecture</a> •
  <a href="#-deployment-methods">Deployment</a> •
  <a href="#-monitoring--observability">Monitoring</a> •
  <a href="#-chaos-engineering--resilience">Resilience</a> •
  <a href="#-cicd-pipelines">CI/CD</a>
</p>

---

## About The Project

**Cakes n Bakes 365** is a B.Tech final year project that builds a real-world, full-stack bakery ordering application for a family-run bakery in Mehrauli, New Delhi — and then deploys it using **industry-standard DevOps practices**.

The project serves a dual purpose:

1. **Functional Application** — A complete e-commerce storefront with menu browsing, cart management, order placement, admin dashboard, and WhatsApp order notifications via Twilio.
2. **DevOps Showcase** — A comprehensive demonstration of containerization, CI/CD, orchestration, IaC, configuration management, monitoring, service mesh, and chaos engineering.

### Key Features

| Feature | Description |
|---------|-------------|
| **Online Ordering** | Browse menu by category, add to cart with quantity selection (kg/piece/item), and checkout |
| **WhatsApp Notifications** | Order confirmations sent to customers & admin via Twilio WhatsApp API |
| **Admin Dashboard** | Protected admin panel for managing orders (accept/reject/complete) |
| **Shop Hours Banner** | Time-aware UI that shows shop status and disables ordering when closed |
| **SSL/TLS** | Self-signed certificate with automatic generation via Nginx reverse proxy |
| **Prometheus Metrics** | Built-in `/metrics` endpoint exposing request latency, throughput, and error rates |
| **HPA Auto-scaling** | Horizontal Pod Autoscaler for backend (2-5 pods) and frontend (2-4 pods) |

---

## Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        CLIENTS                              │
│                   (Browser / Mobile)                        │
└──────────────────────┬──────────────────────────────────────┘
                       │ HTTPS (443) / HTTP (80 → 301)
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   NGINX REVERSE PROXY                       │
│          SSL Termination • Basic Auth (/admin)              │
│              HTTP→HTTPS Redirect • Routing                  │
└──────┬─────────────────────────────────┬────────────────────┘
       │ /api/*                          │ /*
       ▼                                 ▼
┌──────────────┐                ┌─────────────────┐
│   BACKEND    │                │    FRONTEND      │
│  Express.js  │                │  Nginx + Static  │
│  Port 4000   │                │  HTML/CSS/JS     │
│              │                │  Port 80         │
│  • REST API  │                │                  │
│  • /metrics  │                │  • SPA Router    │
│  • Zod valid.│                │  • Cart logic    │
│  • Helmet    │                │  • Admin panel   │
└──────┬───────┘                └──────────────────┘
       │
       ▼
┌──────────────┐       ┌───────────────────┐
│  PostgreSQL  │       │   Twilio WhatsApp  │
│  Port 5432   │       │   (External API)   │
│              │       └───────────────────┘
│  • Products  │
│  • Carts     │
│  • Orders    │
└──────────────┘
```

### Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | HTML5, CSS3, Vanilla JS | SPA with hash routing, responsive design |
| **Backend** | Node.js 20, Express 4 | RESTful API with Zod validation |
| **Database** | PostgreSQL 16 Alpine | Relational storage with indexed queries |
| **Reverse Proxy** | Nginx | SSL termination, routing, basic auth |
| **Containerization** | Docker, Docker Compose | Multi-service orchestration |
| **CI/CD** | GitHub Actions, Jenkins | Automated build, test, and publish |
| **Orchestration** | Kubernetes, Helm | Production-grade container orchestration |
| **IaC** | Terraform (AWS) | EC2 instance provisioning |
| **Config Management** | Ansible | Automated server setup and deployment |
| **Monitoring** | Prometheus, Grafana | Metrics, dashboards, alerting |
| **Exporters** | Node Exporter, cAdvisor, Blackbox | Host, container, and HTTP probe metrics |
| **Service Mesh** | Istio | Circuit breaking, retries, timeouts, mTLS |
| **Chaos Engineering** | LitmusChaos | Pod deletion, network latency/loss experiments |
| **Security** | Dependabot, Helmet.js | Automated dependency updates, HTTP hardening |

### API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/health` | Health check |
| `GET` | `/api/categories` | List all menu categories |
| `GET` | `/api/menu` | List all products (filterable) |
| `GET` | `/api/cart/:sessionId` | Get cart contents |
| `POST` | `/api/cart` | Add item to cart |
| `PUT` | `/api/cart/:id` | Update cart item quantity |
| `DELETE` | `/api/cart/:id` | Remove item from cart |
| `POST` | `/api/orders` | Place an order |
| `GET` | `/api/orders/:sessionId` | Get order history |
| `POST` | `/api/whatsapp/send` | Send WhatsApp notification |
| `POST` | `/api/admin/login` | Admin authentication |
| `GET` | `/api/admin/orders` | List all orders (admin) |
| `PUT` | `/api/admin/orders/:id` | Update order status (admin) |
| `GET` | `/metrics` | Prometheus metrics endpoint |

### Database Schema

```
categories ──< products ──< cart_items >── carts
                   │
                   └──< order_items >── orders
```

**6 tables**: `categories`, `products`, `carts`, `cart_items`, `orders`, `order_items`
**5 categories**: Cakes, Pastries, Fast Food, Snacks, Drinks — with **50+ products** pre-seeded.

---

## Project Structure

```
cakesnbakes365/
├── backend/                          # Node.js API Server
│   ├── Dockerfile                    #   Container image definition
│   ├── package.json                  #   Dependencies (express, pg, zod, helmet, prom-client)
│   ├── sql/
│   │   └── schema.sql                #   Database schema + seed data (50+ products)
│   └── src/
│       ├── server.js                 #   Express app entry point
│       ├── db.js                     #   PostgreSQL connection pool
│       ├── routes/                   #   API route handlers
│       │   ├── categories.js         #     GET /api/categories
│       │   ├── menu.js               #     GET /api/menu
│       │   ├── cart.js               #     CRUD /api/cart
│       │   ├── orders.js             #     POST/GET /api/orders
│       │   ├── whatsapp.js           #     POST /api/whatsapp/send
│       │   └── admin.js              #     Admin order management
│       ├── middleware/
│       │   ├── metrics.js            #     Prometheus metrics (latency histograms, counters)
│       │   ├── error.js              #     Global error handler
│       │   ├── validate.js           #     Zod schema validation
│       │   └── adminAuth.js          #     JWT-based admin auth middleware
│       ├── services/
│       │   └── whatsapp.js           #     Twilio WhatsApp integration
│       └── utils/
│           ├── adminAuth.js          #     Token generation & verification
│           └── asyncHandler.js       #     Async route error wrapper
│
├── frontend/                         # Static Frontend (Nginx-served)
│   ├── Dockerfile                    #   Multi-stage: envsubst + nginx
│   ├── index.html                    #   SPA shell (hash-based routing)
│   ├── admin.html                    #   Admin dashboard
│   ├── css/styles.css                #   Full stylesheet (Fraunces + Manrope fonts)
│   ├── js/
│   │   ├── app.js                    #   Main app logic (30KB — cart, menu, checkout, routing)
│   │   └── admin.js                  #   Admin panel logic
│   ├── assets/                       #   51 product images (PNG/JPEG)
│   └── nginx.conf                    #   Frontend Nginx config
│
├── proxy/                            # Nginx Reverse Proxy
│   ├── Dockerfile                    #   Auto-generates self-signed SSL certs
│   ├── nginx.conf                    #   SSL, routing, /admin basic auth
│   └── entrypoint.sh                 #   SSL cert generation + htpasswd setup
│
├── devops/                           # DevOps Infrastructure
│   ├── k8s/                          #   Raw Kubernetes manifests
│   │   ├── namespace.yaml            #     cakesnbakes namespace
│   │   ├── configmap.yaml            #     App configuration
│   │   ├── secret.example.yaml       #     Secrets template
│   │   ├── postgres.yaml             #     StatefulSet + Service + PVC
│   │   ├── backend.yaml              #     Deployment + Service (2 replicas)
│   │   ├── frontend.yaml             #     Deployment + Service (2 replicas)
│   │   ├── ingress.yaml              #     Ingress (host: cakes.local)
│   │   ├── hpa.yaml                  #     HorizontalPodAutoscaler
│   │   ├── db-migration-job.yaml     #     One-shot schema migration Job
│   │   └── kustomization.yaml        #     Kustomize overlay
│   │
│   ├── helm/cakesnbakes/             #   Helm Chart (v0.1.0)
│   │   ├── Chart.yaml
│   │   ├── values.yaml               #     Configurable replicas, images, env
│   │   └── templates/                #     9 templated K8s resources
│   │
│   ├── terraform/aws-ec2/            #   Terraform (AWS EC2)
│   │   ├── main.tf                   #     Security group + EC2 instance
│   │   ├── variables.tf              #     Parameterized inputs
│   │   ├── outputs.tf                #     Public IP output
│   │   ├── providers.tf              #     AWS provider config
│   │   ├── terraform.tfvars.example  #     Example variable values
│   │   └── user_data.sh.tftpl        #     Bootstrap script (Docker + app)
│   │
│   ├── ansible/                      #   Ansible Playbook
│   │   ├── deploy.yml                #     Full deployment (apt → docker → git → compose)
│   │   ├── inventory.ini.example     #     Inventory template
│   │   └── requirements.yml          #     Galaxy dependencies
│   │
│   ├── monitoring/                   #   Observability Stack
│   │   ├── docker-compose.monitoring.yml  # Prometheus + Grafana + exporters
│   │   ├── prometheus/               #     Prometheus config + alert rules
│   │   ├── grafana-dashboard.json    #     Pre-built Grafana dashboard
│   │   └── blackbox/                 #     HTTP probe configuration
│   │
│   ├── istio/                        #   Istio Service Mesh
│   │   ├── gateway.yaml              #     Istio ingress gateway
│   │   ├── virtual-service.yaml      #     Timeouts + retries + routing
│   │   ├── destination-rule.yaml     #     Circuit breakers (backend, db, frontend)
│   │   └── peer-authentication.yaml  #     mTLS policy
│   │
│   └── chaos/                        #   LitmusChaos Experiments
│       ├── pod-delete-backend.yaml   #     Kill backend pods every 10s
│       ├── pod-delete-db.yaml        #     Kill database pods
│       ├── network-latency-backend.yaml  # Inject 2s latency
│       └── network-loss-db.yaml      #     Inject packet loss to DB
│
├── scripts/                          # Utility Scripts
│   ├── smoke-test.sh                 #   End-to-end health checks
│   ├── devops-check.sh               #   Local validation (syntax, compose, k8s, helm, tf)
│   ├── collect-metrics.sh            #   Prometheus metrics collector for research
│   ├── setup-istio.sh                #   Istio installation script
│   ├── setup-litmus.sh               #   LitmusChaos installation script
│   ├── run-chaos-manual.sh           #   Manual chaos experiment runner
│   └── traffic-gen.sh                #   Load generation for testing
│
├── ci/                               # CI Helper Scripts
│   └── wait_for_url.sh               #   URL readiness checker with retries
│
├── data/                             # Research Experiment Data
│   ├── baseline.txt                  #   Metrics: healthy system
│   ├── chaos-no-istio.txt            #   Metrics: chaos without Istio
│   └── chaos-with-istio.txt          #   Metrics: chaos with Istio
│
├── .github/
│   ├── workflows/ci-cd.yml           # GitHub Actions pipeline
│   └── dependabot.yml                # Automated dependency updates
│
├── docker-compose.yml                # 4-service local deployment
├── Jenkinsfile                       # Jenkins pipeline (6 stages)
├── Makefile                          # Developer shortcuts
├── .env                              # Environment variables (gitignored)
├── .env.ci.example                   # CI-safe env template
├── LICENSE                           # MIT License
└── README.md                         # You are here!
```

---

## Quick Start

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (v20+) and [Docker Compose](https://docs.docker.com/compose/) (v2+)
- [Git](https://git-scm.com/)

### 1. Clone & Run

```bash
git clone https://github.com/rakshitmalik136/Final-year_Project.git
cd Final-year_Project

# The .env file ships with safe defaults — just run:
docker compose up -d --build
```

### 2. Access the Application

| Service | URL | Notes |
|---------|-----|-------|
| App | https://localhost | Accept the self-signed cert warning |
| love Health Check | https://localhost/api/health | Returns `{"status":"ok"}` |
| Admin Panel | https://localhost/admin | Basic Auth protected |
| Metrics | http://localhost:4000/metrics | Prometheus format |

### 3. Verify with Smoke Tests

```bash
./scripts/smoke-test.sh
```

### 4. Stop

```bash
docker compose down        # Stop containers
docker compose down -v     # Stop + delete volumes (fresh start)
```

---

## Deployment Methods

This project supports **6 different deployment methods**, each demonstrating a different DevOps tool:

### Method 1: Docker Compose (Local Development)

```bash
docker compose up -d --build
```

### Method 2: Makefile Shortcuts

```bash
make help       # Show all commands
make up         # Start the app (docker compose up -d --build)
make down       # Stop the app
make logs       # Tail container logs
make smoke      # Run smoke tests
make ci-check   # Run full devops validation suite
```

### Method 3: Kubernetes (Raw Manifests)

```bash
# Apply resources in order
kubectl apply -f devops/k8s/namespace.yaml
kubectl apply -f devops/k8s/configmap.yaml
kubectl apply -f devops/k8s/secret.example.yaml
kubectl apply -f devops/k8s/postgres.yaml
kubectl apply -f devops/k8s/backend.yaml
kubectl apply -f devops/k8s/frontend.yaml
kubectl apply -f devops/k8s/ingress.yaml
kubectl apply -f devops/k8s/hpa.yaml

# Run database migration
kubectl -n cakesnbakes create configmap cnb-schema \
  --from-file=schema.sql=backend/sql/schema.sql
kubectl apply -f devops/k8s/db-migration-job.yaml

# Verify
kubectl -n cakesnbakes get pods,svc,ingress,hpa
```

> **Note:** Add `127.0.0.1 cakes.local` to `/etc/hosts` for local ingress testing.

### Method 4: Helm Chart

```bash
# Install/upgrade with a single command
helm upgrade --install cnb devops/helm/cakesnbakes \
  -n cakesnbakes --create-namespace

# Customize values
helm upgrade --install cnb devops/helm/cakesnbakes \
  -n cakesnbakes --create-namespace \
  --set backend.replicas=3 \
  --set frontend.replicas=2
```

### Method 5: Terraform + Ansible (Cloud VM)

```bash
# Step 1: Provision AWS EC2 instance
cd devops/terraform/aws-ec2
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your AWS credentials
terraform init && terraform apply

# Step 2: Deploy app via Ansible
cd /path/to/project
cp devops/ansible/inventory.ini.example devops/ansible/inventory.ini
# Update the server IP and SSH key path in inventory.ini
ansible-playbook -i devops/ansible/inventory.ini devops/ansible/deploy.yml
```

The Ansible playbook automates: `apt install` → Docker setup → Git clone → env config → `docker compose up`.

### Method 6: CI/CD Auto-Deploy (Push to Main)

Simply push to `main` — GitHub Actions automatically:
1. Validates code syntax
2. Builds all containers
3. Runs smoke tests
4. Publishes images to GitHub Container Registry (GHCR)

---

## CI/CD Pipelines

### GitHub Actions (`.github/workflows/ci-cd.yml`)

```
push/PR to main
      │
      ▼
┌─────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Quality     │────▶│  Build & Smoke   │────▶│  Publish Images │
│  Check       │     │  Test            │     │  (main only)    │
│              │     │                  │     │                 │
│ • npm ci     │     │ • docker compose │     │ • GHCR login    │
│ • syntax     │     │   up --build     │     │ • Push backend  │
│ • compose    │     │ • smoke-test.sh  │     │ • Push frontend │
│   config     │     │ • logs on fail   │     │ • Tag: latest   │
└─────────────┘     └──────────────────┘     │ • Tag: sha      │
                                              └─────────────────┘
```

### Jenkins (`Jenkinsfile`)

6-stage pipeline: **Checkout → Prepare Env → Backend Check → Build → Deploy → Smoke Test**

### Dependabot

Automated weekly dependency updates for: npm packages, Docker base images, and GitHub Actions.

---

## Monitoring & Observability

### Start the Monitoring Stack

```bash
cd devops/monitoring
docker compose -f docker-compose.monitoring.yml up -d
```

| Tool | URL | Credentials |
|------|-----|-------------|
| **Prometheus** | http://localhost:9090 | — |
| **Grafana** | http://localhost:3001 | `admin` / `admin123` |

### What's Monitored

| Exporter | Metrics |
|----------|---------|
| **App (`/metrics`)** | HTTP request latency (p50/p95/p99), request rate, error rate, status codes |
| **Node Exporter** | CPU, memory, disk, network (host-level) |
| **cAdvisor** | Container CPU/memory usage, network I/O |
| **Blackbox Exporter** | HTTP probe success, response time, SSL certificate expiry |

### Collect Metrics for Research

```bash
./scripts/collect-metrics.sh http://localhost:9090 5m > data/baseline.txt
```

---

## Chaos Engineering & Resilience

This project includes a full **chaos engineering lifecycle** using LitmusChaos and Istio to empirically validate system resilience — a core part of the research paper.

### Istio Service Mesh Configuration

| Policy | Backend | Database | Frontend |
|--------|---------|----------|----------|
| **Circuit Breaker** | 3 consecutive 5xx → eject 60s | 2 gateway errors → eject 30s | 5 consecutive 5xx → eject 30s |
| **Connection Pool** | 100 TCP / 50 pending HTTP | 50 TCP | 200 TCP / 100 pending HTTP |
| **Timeout** | 2s per request | 3s per request | 5s per request |
| **Retries** | 3 attempts, 1s per-try | 2 attempts | 2 attempts, 2s per-try |
| **mTLS** | STRICT | STRICT | STRICT |

### Chaos Experiments (LitmusChaos)

| Experiment | Target | What It Does |
|------------|--------|-------------|
| `pod-delete-backend` | Backend pods | Kills 50% of pods every 10s for 60s |
| `pod-delete-db` | Database pods | Kills database pods |
| `network-latency-backend` | Backend | Injects 2000ms network latency |
| `network-loss-db` | Database | Injects packet loss to DB connections |

### Setup & Run

```bash
# Install Istio
./scripts/setup-istio.sh

# Apply Istio policies
kubectl apply -f devops/istio/

# Install LitmusChaos
./scripts/setup-litmus.sh

# Run chaos experiments
kubectl apply -f devops/chaos/pod-delete-backend.yaml
```

### Research Results (3-Phase Testing)

| Metric | Baseline | Chaos (No Istio) | Chaos (With Istio) |
|--------|----------|-------------------|---------------------|
| **Error Rate (5xx)** | 0% | High | ~32.6% (circuit breaker active) |
| **Success Rate (2xx)** | 100% | Low | ~34.7% (graceful degradation) |
| **Backend Uptime** | UP | Intermittent | UP (auto-recovery) |

---

## Development

### Environment Variables

Copy the example env file and customize:

```bash
cp .env.ci.example .env
```

Key variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `ADMIN_USERNAME` | Admin panel login | `admin` |
| `ADMIN_PASSWORD` | Admin panel password | `password` |
| `WHATSAPP_ENABLED` | Enable WhatsApp notifications | `true` |
| `WHATSAPP_ACCOUNT_SID` | Twilio Account SID | (empty) |
| `WHATSAPP_AUTH_TOKEN` | Twilio Auth Token | (empty) |
| `SSL_CN` | SSL certificate common name | `localhost` |

### Local DevOps Validation

Run all checks before pushing:

```bash
./scripts/devops-check.sh
```

This validates: Node.js syntax → Docker Compose config → K8s manifests (kustomize) → Helm lint → Terraform fmt

---

## Important Notes

- **SSL Certificate**: Self-signed — browsers will show a security warning (expected behavior)
- **Secrets**: `secret.example.yaml` contains dummy values — replace before production use
- **Images**: Replace `ghcr.io/rakshitmalik136/...` with your own registry before deploying
- **WhatsApp**: Requires a Twilio account with WhatsApp sandbox configured
- **Production**: Use managed secrets (AWS Secrets Manager, HashiCorp Vault) instead of `.env` files
- **Shop Hours**: The frontend enforces operating hours (12PM–4PM, 5:30PM–10PM IST)

---

## Academic Context

This project was developed as a **B.Tech Final Year Project** at **GGSIPU** (Guru Gobind Singh Indraprastha University), demonstrating the practical application of DevOps principles to a real-world full-stack application.

### Research Focus

> *"Enhancing Microservice Resilience: A Chaos Engineering Approach with Istio Service Mesh"*

The research validates that Istio's traffic management policies (circuit breaking, retries, timeouts) significantly improve system resilience under failure conditions induced by LitmusChaos experiments.

### Documents

| Document | Description |
|----------|-------------|
| Dissertation Report | Full B.Tech project report (LaTeX-formatted) |
| Synopsis | Project overview and methodology |
| Research Paper | Chaos engineering findings with empirical data |

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## Author

**Rakshit Malik**

- GitHub: [@rakshitmalik136](https://github.com/rakshitmalik136)

---

<p align="center">
  Made as a part of B.Tech Final Year Project at GGSIPU
</p>
