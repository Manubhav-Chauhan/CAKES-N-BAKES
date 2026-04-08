# Makefile for Cakes n Bakes 365
# Quick commands to manage the app

.PHONY: help up down logs smoke ci-check

help:
	@echo "Available commands:"
	@echo "  make up       - Start the app"
	@echo "  make down     - Stop the app"
	@echo "  make logs     - View logs"
	@echo "  make smoke    - Run smoke tests"
	@echo "  make ci-check - Run devops checks"

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
