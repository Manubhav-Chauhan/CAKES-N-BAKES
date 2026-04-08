#!/usr/bin/env bash
set -euo pipefail

# Smoke test script for Cakes n Bakes 365
# This checks if all the services are up and responding

# Check if backend API is healthy
./ci/wait_for_url.sh "http://localhost:4000/api/health" 60 2

# Check if frontend is serving pages
./ci/wait_for_url.sh "http://localhost:8081/" 60 2

# Check if proxy is working (HTTPS)
./ci/wait_for_url.sh "https://localhost/api/health" 60 2 --insecure

# Check if admin page is protected with basic auth (should return 401)
admin_status_code=$(curl --insecure --silent --output /dev/null --write-out "%{http_code}" https://localhost/admin)
if [ "$admin_status_code" != "401" ]; then
  echo "Expected /admin to be basic-auth protected (401), got HTTP $admin_status_code"
  exit 1
fi

echo "Smoke tests passed"
