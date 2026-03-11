# Kubernetes Deployment (Simple Version)

This folder is intentionally simple so it is easy to demo in college viva.

## Apply resources

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

## Run DB migration/seed script

The migration job uses `backend/sql/schema.sql`.

```bash
kubectl -n cakesnbakes create configmap cnb-schema \
  --from-file=schema.sql=backend/sql/schema.sql
kubectl apply -f devops/k8s/db-migration-job.yaml
kubectl -n cakesnbakes logs job/cnb-db-migration
```

## Quick check

```bash
kubectl -n cakesnbakes get pods,svc,ingress,hpa
```

## Notes

- Replace image names in `backend.yaml` and `frontend.yaml` before production.
- Replace values in `secret.example.yaml` with real secrets.
- Host `cakes.local` should be mapped in local `/etc/hosts` for local ingress testing.
