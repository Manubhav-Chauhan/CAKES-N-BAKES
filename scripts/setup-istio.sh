#!/usr/bin/env bash
set -euo pipefail

# ────────────────────────────────────────────────
# setup-istio.sh — Install Istio and apply resilience policies
#
# Prerequisites:
#   - A running Kubernetes cluster (Minikube, Kind, or cloud)
#   - kubectl configured and working
#   - istioctl installed (https://istio.io/latest/docs/setup/getting-started/)
#
# Usage:
#   ./scripts/setup-istio.sh
# ────────────────────────────────────────────────

NAMESPACE="cakesnbakes"
ISTIO_DIR="devops/istio"

echo "============================================"
echo "  Istio Setup for Cakes n Bakes 365"
echo "============================================"

# Step 1: Install Istio with the demo profile
echo ""
echo "[1/6] Installing Istio (demo profile)..."
if ! command -v istioctl &>/dev/null; then
  echo "istioctl not found. Installing..."
  curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.23.0 sh -
  export PATH="$PWD/istio-1.23.0/bin:$PATH"
fi

istioctl install --set profile=demo -y
echo "  ✓ Istio installed"

# Step 2: Enable sidecar injection on the namespace
echo ""
echo "[2/6] Enabling Istio sidecar injection on namespace '$NAMESPACE'..."
kubectl label namespace "$NAMESPACE" istio-injection=enabled --overwrite
echo "  ✓ Sidecar injection enabled"

# Step 3: Restart all deployments to inject sidecars
echo ""
echo "[3/6] Restarting deployments to inject Envoy sidecars..."
kubectl rollout restart deployment -n "$NAMESPACE"
echo "  Waiting for rollouts to complete..."
kubectl rollout status deployment/cnb-backend -n "$NAMESPACE" --timeout=120s
kubectl rollout status deployment/cnb-frontend -n "$NAMESPACE" --timeout=120s
kubectl rollout status deployment/cnb-db -n "$NAMESPACE" --timeout=120s
echo "  ✓ All pods have Envoy sidecars"

# Step 4: Apply mTLS policy
echo ""
echo "[4/6] Applying mTLS peer authentication..."
kubectl apply -f "$ISTIO_DIR/peer-authentication.yaml"
echo "  ✓ mTLS (PERMISSIVE) enabled"

# Step 5: Apply resilience policies
echo ""
echo "[5/6] Applying resilience policies (circuit breakers, timeouts, retries)..."
kubectl apply -f "$ISTIO_DIR/destination-rule.yaml"
kubectl apply -f "$ISTIO_DIR/virtual-service.yaml"
echo "  ✓ DestinationRules and VirtualServices applied"

# Step 6: Apply gateway
echo ""
echo "[6/6] Applying Istio Gateway..."
kubectl apply -f "$ISTIO_DIR/gateway.yaml"
echo "  ✓ Gateway applied"

# Verify
echo ""
echo "============================================"
echo "  Verification"
echo "============================================"
echo ""
echo "Istio sidecar status:"
kubectl get pods -n "$NAMESPACE" -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{range .spec.containers[*]}{.name}{" "}{end}{"\n"}{end}'
echo ""
echo "Istio policies:"
kubectl get destinationrules,virtualservices,gateways,peerauthentications -n "$NAMESPACE"
echo ""
echo "============================================"
echo "  Istio setup complete!"
echo "============================================"
echo ""
echo "To check Istio dashboard:"
echo "  istioctl dashboard kiali"
echo ""
echo "To disable Istio policies (for chaos-without-defense tests):"
echo "  kubectl delete -f $ISTIO_DIR/destination-rule.yaml"
echo "  kubectl delete -f $ISTIO_DIR/virtual-service.yaml"
echo ""
echo "To re-enable Istio policies:"
echo "  kubectl apply -f $ISTIO_DIR/destination-rule.yaml"
echo "  kubectl apply -f $ISTIO_DIR/virtual-service.yaml"
