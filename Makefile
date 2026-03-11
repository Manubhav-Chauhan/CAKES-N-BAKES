.PHONY: help up down logs smoke ci-check monitor-up monitor-down k8s-apply helm-install terraform-init terraform-plan ansible-deploy

help:
	@echo "Available targets:"
	@echo "  up             - Start app stack with docker compose"
	@echo "  down           - Stop app stack"
	@echo "  logs           - Follow compose logs"
	@echo "  smoke          - Run smoke tests"
	@echo "  ci-check       - Run local DevOps checks"
	@echo "  monitor-up     - Start monitoring stack"
	@echo "  monitor-down   - Stop monitoring stack"
	@echo "  k8s-apply      - Apply Kubernetes manifests"
	@echo "  helm-install   - Install/upgrade Helm release"
	@echo "  terraform-init - Terraform init"
	@echo "  terraform-plan - Terraform plan"
	@echo "  ansible-deploy - Run ansible deployment"

up:
	docker compose up -d --build

down:
	docker compose down

logs:
	docker compose logs -f --tail=100

smoke:
	./scripts/smoke-test.sh

ci-check:
	./scripts/devops-check.sh

monitor-up:
	cd devops/monitoring && docker compose -f docker-compose.monitoring.yml up -d

monitor-down:
	cd devops/monitoring && docker compose -f docker-compose.monitoring.yml down

k8s-apply:
	kubectl apply -k devops/k8s

helm-install:
	helm upgrade --install cnb devops/helm/cakesnbakes -n cakesnbakes --create-namespace

terraform-init:
	terraform -chdir=devops/terraform/aws-ec2 init

terraform-plan:
	terraform -chdir=devops/terraform/aws-ec2 plan

ansible-deploy:
	ansible-playbook -i devops/ansible/inventory.ini devops/ansible/deploy.yml
