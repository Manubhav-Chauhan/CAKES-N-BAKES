#!/usr/bin/env bash
echo "Starting simulated customer traffic..."
while true; do 
  # Hit the frontend
  curl -s -o /dev/null -w "Frontend HTTP: %{http_code}\n" http://localhost:80
  # Hit the backend API health/menu route
  curl -s -o /dev/null -w "Backend  HTTP: %{http_code}\n" http://localhost:4000/api/health
  sleep 0.5
done
