#!/usr/bin/env bash
set -euo pipefail

# ────────────────────────────────────────────────
# run-chaos-manual.sh — Manual chaos experiments using kubectl
#
# Use this if LitmusChaos is not installed. These commands achieve
# the same fault injection using basic kubectl and Linux tools.
#
# Usage:
#   ./scripts/run-chaos-manual.sh <experiment>
#
# Experiments:
#   pod-delete-backend    — Kill a backend pod
#   pod-delete-db         — Kill the database pod
#   network-latency       — Add 5s delay to a backend pod
#   network-loss-db       — Drop all packets on database pod
#   cpu-stress-backend    — Spike CPU on a backend pod
#   all                   — Run all experiments sequentially
# ────────────────────────────────────────────────

NAMESPACE="cakesnbakes"
DURATION=60
LATENCY_MS=5000

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[CHAOS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err() { echo -e "${RED}[ERROR]${NC} $1"; }

wait_for_ready() {
  log "Waiting for pods to be ready..."
  kubectl wait --for=condition=ready pod -l app="$1" -n "$NAMESPACE" --timeout=120s
}

# ── Experiment 1: Pod Delete — Backend ────────────────────────────

pod_delete_backend() {
  log "━━━ Experiment: Pod Delete (Backend) ━━━"
  log "Deleting a random cnb-backend pod..."
  log "Duration: ${DURATION}s | Target: cnb-backend"
  echo ""

  local start_time=$(date +%s)

  while true; do
    local elapsed=$(( $(date +%s) - start_time ))
    if [ $elapsed -ge $DURATION ]; then
      break
    fi

    local pod=$(kubectl get pods -l app=cnb-backend -n "$NAMESPACE" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    if [ -n "$pod" ]; then
      log "Killing pod: $pod (elapsed: ${elapsed}s)"
      kubectl delete pod "$pod" -n "$NAMESPACE" --force --grace-period=0 2>/dev/null || true
    fi

    sleep 10
  done

  log "Pod delete experiment complete."
  wait_for_ready "cnb-backend"
}

# ── Experiment 2: Pod Delete — Database ───────────────────────────

pod_delete_db() {
  log "━━━ Experiment: Pod Delete (Database) ━━━"
  log "Deleting the cnb-db pod..."
  log "Duration: one-shot | Target: cnb-db"
  echo ""

  local pod=$(kubectl get pods -l app=cnb-db -n "$NAMESPACE" -o jsonpath='{.items[0].metadata.name}')
  log "Killing pod: $pod"
  kubectl delete pod "$pod" -n "$NAMESPACE" --force --grace-period=0

  log "Database pod deleted. Waiting ${DURATION}s for impact observation..."
  sleep "$DURATION"

  log "Database pod delete experiment complete."
  wait_for_ready "cnb-db"
}

# ── Experiment 3: Network Latency — Backend ───────────────────────

network_latency() {
  log "━━━ Experiment: Network Latency (Backend) ━━━"
  log "Injecting ${LATENCY_MS}ms delay on backend pods..."
  log "Duration: ${DURATION}s | Target: cnb-backend (eth0)"
  echo ""

  local pods=$(kubectl get pods -l app=cnb-backend -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}')

  for pod in $pods; do
    log "Adding ${LATENCY_MS}ms latency to $pod"
    kubectl exec -n "$NAMESPACE" "$pod" -c backend -- \
      tc qdisc add dev eth0 root netem delay ${LATENCY_MS}ms 1000ms 2>/dev/null || \
      warn "tc command failed on $pod (may need NET_ADMIN capability)"
  done

  log "Latency injected. Waiting ${DURATION}s..."
  sleep "$DURATION"

  # Clean up
  for pod in $pods; do
    log "Removing latency from $pod"
    kubectl exec -n "$NAMESPACE" "$pod" -c backend -- \
      tc qdisc del dev eth0 root 2>/dev/null || true
  done

  log "Network latency experiment complete."
}

# ── Experiment 4: Network Loss — Database ─────────────────────────

network_loss_db() {
  log "━━━ Experiment: Network Loss (Database) ━━━"
  log "Injecting 100% packet loss on database pod..."
  log "Duration: ${DURATION}s | Target: cnb-db (eth0)"
  echo ""

  local pod=$(kubectl get pods -l app=cnb-db -n "$NAMESPACE" -o jsonpath='{.items[0].metadata.name}')
  log "Adding 100% packet loss to $pod"
  kubectl exec -n "$NAMESPACE" "$pod" -c postgres -- \
    tc qdisc add dev eth0 root netem loss 100% 2>/dev/null || \
    warn "tc command failed on $pod (may need NET_ADMIN capability)"

  log "Packet loss injected. Waiting ${DURATION}s..."
  sleep "$DURATION"

  # Clean up
  log "Removing packet loss from $pod"
  kubectl exec -n "$NAMESPACE" "$pod" -c postgres -- \
    tc qdisc del dev eth0 root 2>/dev/null || true

  log "Network loss experiment complete."
}

# ── Experiment 5: CPU Stress — Backend ────────────────────────────

cpu_stress_backend() {
  log "━━━ Experiment: CPU Stress (Backend) ━━━"
  log "Stressing CPU on backend pods for ${DURATION}s..."
  log "Duration: ${DURATION}s | Target: cnb-backend"
  echo ""

  local pods=$(kubectl get pods -l app=cnb-backend -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}')

  for pod in $pods; do
    log "Starting CPU stress on $pod"
    kubectl exec -n "$NAMESPACE" "$pod" -c backend -- \
      sh -c "timeout ${DURATION} yes > /dev/null &" 2>/dev/null || \
      warn "CPU stress command failed on $pod"
  done

  log "CPU stress running. Waiting ${DURATION}s..."
  sleep "$DURATION"

  log "CPU stress experiment complete (processes auto-terminated by timeout)."
}

# ── Run all experiments ───────────────────────────────────────────

run_all() {
  log "Running ALL chaos experiments sequentially..."
  echo ""

  pod_delete_backend
  echo ""
  sleep 30

  pod_delete_db
  echo ""
  sleep 30

  network_latency
  echo ""
  sleep 30

  network_loss_db
  echo ""
  sleep 30

  cpu_stress_backend

  echo ""
  log "━━━ All experiments complete ━━━"
}

# ── Main ──────────────────────────────────────────────────────────

case "${1:-help}" in
  pod-delete-backend)  pod_delete_backend ;;
  pod-delete-db)       pod_delete_db ;;
  network-latency)     network_latency ;;
  network-loss-db)     network_loss_db ;;
  cpu-stress-backend)  cpu_stress_backend ;;
  all)                 run_all ;;
  *)
    echo "Usage: $0 <experiment>"
    echo ""
    echo "Experiments:"
    echo "  pod-delete-backend    Kill a backend pod repeatedly"
    echo "  pod-delete-db         Kill the database pod"
    echo "  network-latency       Add 5s network delay to backend"
    echo "  network-loss-db       100% packet loss on database"
    echo "  cpu-stress-backend    Spike CPU on backend pods"
    echo "  all                   Run all experiments in sequence"
    exit 1
    ;;
esac
