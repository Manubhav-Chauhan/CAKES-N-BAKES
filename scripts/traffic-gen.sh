#!/usr/bin/env bash
while true; do
  curl -s http://localhost:4000/api/menu > /dev/null
  curl -s http://localhost:4000/api/health > /dev/null
  # Simulate some 5xx for baseline
  curl -s http://localhost:4000/api/invalid-route > /dev/null
  sleep 0.1
done
