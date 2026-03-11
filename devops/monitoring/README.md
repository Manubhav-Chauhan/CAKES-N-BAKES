# Monitoring Stack

This gives a basic observability setup for demo and learning.

Tools included:

- Prometheus (metrics + alerts)
- Grafana (dashboard)
- Node Exporter (host metrics)
- cAdvisor (container metrics)
- Blackbox Exporter (HTTP uptime probes)

## Run

```bash
cd devops/monitoring
docker compose -f docker-compose.monitoring.yml up -d
```

## Access

- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3001` (user: `admin`, pass: `admin123`)

## Stop

```bash
docker compose -f docker-compose.monitoring.yml down
```
