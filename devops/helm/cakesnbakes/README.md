# Helm Quick Start

```bash
# from project root
helm upgrade --install cnb devops/helm/cakesnbakes -n cakesnbakes --create-namespace
```

Useful commands:

```bash
helm list -n cakesnbakes
helm get values cnb -n cakesnbakes
helm rollback cnb 1 -n cakesnbakes
```

For database migration, first create configmap from schema:

```bash
kubectl -n cakesnbakes create configmap cnb-schema \
  --from-file=schema.sql=backend/sql/schema.sql
```

Then enable migration once:

```bash
helm upgrade --install cnb devops/helm/cakesnbakes \
  -n cakesnbakes \
  --set migration.enabled=true
```
