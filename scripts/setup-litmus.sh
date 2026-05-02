#!/usr/bin/env bash
set -euo pipefail

# ────────────────────────────────────────────────
# setup-litmus.sh — Install LitmusChaos 3.x on the cluster
#
# Prerequisites:
#   - A running Kubernetes cluster
#   - kubectl configured
#   - Helm 3.x installed
#
# Usage:
#   ./scripts/setup-litmus.sh
# ────────────────────────────────────────────────

NAMESPACE="cakesnbakes"

echo "============================================"
echo "  LitmusChaos Setup"
echo "============================================"

# Step 1: Install LitmusChaos operator via Helm
echo ""
echo "[1/4] Adding LitmusChaos Helm repo..."
helm repo add litmuschaos https://litmuschaos.github.io/litmus-helm/
helm repo update

echo ""
echo "[2/4] Installing LitmusChaos operator..."
kubectl create namespace litmus 2>/dev/null || true
helm upgrade --install litmus litmuschaos/litmus \
  --namespace litmus \
  --set portal.frontend.service.type=NodePort \
  --wait --timeout 180s

echo "  ✓ LitmusChaos operator installed"

# Step 2: Install generic chaos experiments
echo ""
echo "[3/4] Installing chaos experiments from ChaosHub..."
kubectl apply -f https://hub.litmuschaos.io/api/chaos/3.0.0?file=charts/generic/experiments.yaml -n "$NAMESPACE"
echo "  ✓ Generic experiments installed"

# Step 3: Create RBAC for chaos experiments
echo ""
echo "[4/4] Creating litmus-admin ServiceAccount in $NAMESPACE..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: litmus-admin
  namespace: $NAMESPACE
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: litmus-admin
rules:
  - apiGroups: [""]
    resources: ["pods", "pods/exec", "pods/log", "events", "services", "configmaps", "secrets"]
    verbs: ["create", "get", "list", "patch", "update", "delete", "deletecollection"]
  - apiGroups: ["apps"]
    resources: ["deployments", "statefulsets", "replicasets", "daemonsets"]
    verbs: ["list", "get", "patch", "update", "delete"]
  - apiGroups: ["batch"]
    resources: ["jobs"]
    verbs: ["create", "list", "get", "delete", "deletecollection"]
  - apiGroups: ["litmuschaos.io"]
    resources: ["chaosengines", "chaosexperiments", "chaosresults"]
    verbs: ["create", "list", "get", "patch", "update", "delete"]
  - apiGroups: ["networking.k8s.io"]
    resources: ["networkpolicies"]
    verbs: ["create", "get", "list", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: litmus-admin-binding
subjects:
  - kind: ServiceAccount
    name: litmus-admin
    namespace: $NAMESPACE
roleRef:
  kind: ClusterRole
  name: litmus-admin
  apiGroup: rbac.authorization.k8s.io
EOF

echo "  ✓ litmus-admin ServiceAccount and RBAC created"

echo ""
echo "============================================"
echo "  LitmusChaos setup complete!"
echo "============================================"
echo ""
echo "To run chaos experiments:"
echo "  kubectl apply -f devops/chaos/pod-delete-backend.yaml"
echo "  kubectl apply -f devops/chaos/pod-delete-db.yaml"
echo "  kubectl apply -f devops/chaos/network-latency-backend.yaml"
echo "  kubectl apply -f devops/chaos/network-loss-db.yaml"
echo ""
echo "To check experiment status:"
echo "  kubectl get chaosengines -n $NAMESPACE"
echo "  kubectl get chaosresults -n $NAMESPACE"
echo ""
echo "To stop/clean up a running experiment:"
echo "  kubectl delete chaosengine <name> -n $NAMESPACE"
