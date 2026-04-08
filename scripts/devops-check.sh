#!/usr/bin/env bash
set -euo pipefail

# Local DevOps checks for Cakes n Bakes 365
# Run this before pushing to make sure everything is valid

# Check 1: Make sure all backend JS files have valid syntax
echo "[1/5] Node syntax check"
npm ci --prefix backend >/dev/null
find backend/src -type f -name "*.js" -print0 | xargs -0 -r -n1 node --check

# Check 2: Validate docker-compose.yml
echo "[2/5] Docker compose validation"
docker compose config >/dev/null

# Check 3: Validate Kubernetes manifests (if kubectl is installed)
echo "[3/5] Kubernetes manifest validation (if kubectl available)"
if command -v kubectl >/dev/null 2>&1; then
  kubectl kustomize devops/k8s >/dev/null
else
  echo "kubectl not installed, skipping"
fi

# Check 4: Lint the Helm chart (if helm is installed)
echo "[4/5] Helm lint (if helm available)"
if command -v helm >/dev/null 2>&1; then
  helm lint devops/helm/cakesnbakes >/dev/null
else
  echo "helm not installed, skipping"
fi

# Check 5: Check Terraform formatting (if terraform is installed)
echo "[5/5] Terraform fmt check (if terraform available)"
if command -v terraform >/dev/null 2>&1; then
  terraform -chdir=devops/terraform/aws-ec2 fmt -check
else
  echo "terraform not installed, skipping"
fi

echo "DevOps checks completed"
