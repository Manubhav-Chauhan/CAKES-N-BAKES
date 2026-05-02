#!/usr/bin/env bash
set -euo pipefail

# ────────────────────────────────────────────────
# collect-metrics.sh — Query Prometheus and generate a comparison table
#
# This script queries Prometheus HTTP API for the key metrics needed
# in your research paper: latency percentiles, error rates, and
# request throughput across three phases:
#   Phase 1: Baseline (healthy system)
#   Phase 2: Chaos without Istio
#   Phase 3: Chaos with Istio
#
# Usage:
#   ./scripts/collect-metrics.sh [prometheus-url] [duration]
#
# Example:
#   ./scripts/collect-metrics.sh http://localhost:9090 5m
# ────────────────────────────────────────────────

PROM_URL="${1:-http://localhost:9090}"
DURATION="${2:-5m}"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[METRICS]${NC} $1"; }

# ── Helper: Query Prometheus ──────────────────────────────────────

prom_query() {
  local query="$1"
  local result
  result=$(curl -sG "${PROM_URL}/api/v1/query" \
    --data-urlencode "query=${query}" \
    2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    results = data.get('data', {}).get('result', [])
    if results:
        print(results[0]['value'][1])
    else:
        print('N/A')
except:
    print('ERROR')
" 2>/dev/null)
  echo "$result"
}

# ── Collect Metrics ───────────────────────────────────────────────

collect_phase() {
  local phase_name="$1"

  echo ""
  echo -e "${CYAN}━━━ Phase: ${phase_name} ━━━${NC}"
  echo ""

  # Latency percentiles (from prom-client histogram)
  local p50=$(prom_query "histogram_quantile(0.50, rate(http_request_duration_seconds_bucket[${DURATION}]))")
  local p95=$(prom_query "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[${DURATION}]))")
  local p99=$(prom_query "histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[${DURATION}]))")

  # Average latency
  local avg_latency=$(prom_query "rate(http_request_duration_seconds_sum[${DURATION}]) / rate(http_request_duration_seconds_count[${DURATION}])")

  # Request rate (requests per second)
  local req_rate=$(prom_query "rate(http_requests_total[${DURATION}])")

  # Total requests
  local total_requests=$(prom_query "increase(http_requests_total[${DURATION}])")

  # Error rate (% of 5xx responses)
  local error_rate=$(prom_query "sum(rate(http_requests_total{status_code=~\"5..\"}[${DURATION}])) / sum(rate(http_requests_total[${DURATION}])) * 100")

  # Total 5xx errors
  local total_errors=$(prom_query "increase(http_requests_total{status_code=~\"5..\"}[${DURATION}])")

  # Success rate
  local success_rate=$(prom_query "sum(rate(http_requests_total{status_code=~\"2..\"}[${DURATION}])) / sum(rate(http_requests_total[${DURATION}])) * 100")

  # Blackbox probe success
  local backend_up=$(prom_query "probe_success{instance=~\".*4000.*\"}")
  local frontend_up=$(prom_query "probe_success{instance=~\".*8081.*\"}")

  # Blackbox probe duration
  local probe_latency=$(prom_query "probe_duration_seconds{instance=~\".*4000.*\"}")

  # Print results
  printf "  %-30s %s\n" "Metric" "Value"
  printf "  %-30s %s\n" "──────────────────────────────" "──────────"
  printf "  %-30s %s ms\n" "Latency (p50)" "$(echo "$p50 * 1000" | bc 2>/dev/null || echo "$p50")"
  printf "  %-30s %s ms\n" "Latency (p95)" "$(echo "$p95 * 1000" | bc 2>/dev/null || echo "$p95")"
  printf "  %-30s %s ms\n" "Latency (p99)" "$(echo "$p99 * 1000" | bc 2>/dev/null || echo "$p99")"
  printf "  %-30s %s ms\n" "Latency (avg)" "$(echo "$avg_latency * 1000" | bc 2>/dev/null || echo "$avg_latency")"
  printf "  %-30s %s req/s\n" "Request rate" "$req_rate"
  printf "  %-30s %s\n" "Total requests" "$total_requests"
  printf "  %-30s %s %%\n" "Error rate (5xx)" "$error_rate"
  printf "  %-30s %s\n" "Total 5xx errors" "$total_errors"
  printf "  %-30s %s %%\n" "Success rate (2xx)" "$success_rate"
  printf "  %-30s %s\n" "Backend probe (1=up)" "$backend_up"
  printf "  %-30s %s\n" "Frontend probe (1=up)" "$frontend_up"
  printf "  %-30s %s s\n" "Probe latency (backend)" "$probe_latency"
  echo ""
}

# ── Istio-specific metrics (if Istio is installed) ────────────────

collect_istio_metrics() {
  echo ""
  echo -e "${CYAN}━━━ Istio Metrics ━━━${NC}"
  echo ""

  local istio_req_rate=$(prom_query "sum(rate(istio_requests_total{destination_service_namespace=\"cakesnbakes\"}[${DURATION}]))")
  local istio_error_rate=$(prom_query "sum(rate(istio_requests_total{destination_service_namespace=\"cakesnbakes\",response_code=~\"5..\"}[${DURATION}])) / sum(rate(istio_requests_total{destination_service_namespace=\"cakesnbakes\"}[${DURATION}])) * 100")
  local istio_p50=$(prom_query "histogram_quantile(0.50, sum(rate(istio_request_duration_milliseconds_bucket{destination_service_namespace=\"cakesnbakes\"}[${DURATION}])) by (le))")
  local istio_p95=$(prom_query "histogram_quantile(0.95, sum(rate(istio_request_duration_milliseconds_bucket{destination_service_namespace=\"cakesnbakes\"}[${DURATION}])) by (le))")
  local istio_p99=$(prom_query "histogram_quantile(0.99, sum(rate(istio_request_duration_milliseconds_bucket{destination_service_namespace=\"cakesnbakes\"}[${DURATION}])) by (le))")

  printf "  %-30s %s\n" "Metric" "Value"
  printf "  %-30s %s\n" "──────────────────────────────" "──────────"
  printf "  %-30s %s req/s\n" "Istio request rate" "$istio_req_rate"
  printf "  %-30s %s %%\n" "Istio error rate (5xx)" "$istio_error_rate"
  printf "  %-30s %s ms\n" "Istio latency (p50)" "$istio_p50"
  printf "  %-30s %s ms\n" "Istio latency (p95)" "$istio_p95"
  printf "  %-30s %s ms\n" "Istio latency (p99)" "$istio_p99"
  echo ""
}

# ── Main ──────────────────────────────────────────────────────────

echo ""
echo "============================================"
echo "  Cakes n Bakes 365 — Metrics Collection"
echo "============================================"
echo ""
echo "  Prometheus:  $PROM_URL"
echo "  Duration:    $DURATION"
echo "  Timestamp:   $(date -Iseconds)"
echo ""

log "Collecting metrics..."
collect_phase "Current State"

# Try Istio metrics (will show N/A if Istio is not installed)
collect_istio_metrics

echo ""
echo "============================================"
echo "  Research Paper Data Collection Guide"
echo "============================================"
echo ""
echo "Run this script 3 times to collect data for your paper:"
echo ""
echo "  1. BASELINE (healthy system):"
echo "     ./scripts/collect-metrics.sh $PROM_URL 5m > data/baseline.txt"
echo ""
echo "  2. CHAOS WITHOUT ISTIO (delete Istio policies first):"
echo "     kubectl delete -f devops/istio/destination-rule.yaml"
echo "     kubectl delete -f devops/istio/virtual-service.yaml"
echo "     # Run chaos experiment, wait 2min, then:"
echo "     ./scripts/collect-metrics.sh $PROM_URL 5m > data/chaos-no-istio.txt"
echo ""
echo "  3. CHAOS WITH ISTIO (re-apply Istio policies):"
echo "     kubectl apply -f devops/istio/destination-rule.yaml"
echo "     kubectl apply -f devops/istio/virtual-service.yaml"
echo "     # Run same chaos experiment, wait 2min, then:"
echo "     ./scripts/collect-metrics.sh $PROM_URL 5m > data/chaos-with-istio.txt"
echo ""
