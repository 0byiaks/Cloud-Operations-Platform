#!/bin/bash
# Traffic spike simulation script
# Simulates sustained load against the ALB to trigger ASG scaling
# Usage: ./simulate_load.sh <duration_minutes> <concurrency>

TARGET_URL="https://titotest.co.uk"
DURATION=${1:-10}
CONCURRENCY=${2:-50}
END_TIME=$((SECONDS + DURATION * 60))

echo "============================================"
echo "COP Traffic Spike Simulation"
echo "============================================"
echo "Target:      $TARGET_URL"
echo "Duration:    ${DURATION} minutes"
echo "Concurrency: ${CONCURRENCY} parallel requests"
echo "Start time:  $(date)"
echo "============================================"
echo ""
echo "Sending requests... Press Ctrl+C to stop early"
echo ""

REQUEST_COUNT=0
ERROR_COUNT=0

while [ $SECONDS -lt $END_TIME ]; do
  for i in $(seq 1 $CONCURRENCY); do
    curl -sk -o /dev/null -w "%{http_code}" "$TARGET_URL" | grep -q "200" && \
      REQUEST_COUNT=$((REQUEST_COUNT + 1)) || \
      ERROR_COUNT=$((ERROR_COUNT + 1)) &
  done
  wait

  ELAPSED=$(( (SECONDS - (END_TIME - DURATION * 60)) / 60 ))
  echo "[$( date +%H:%M:%S)] Elapsed: ${ELAPSED}m | Requests: ${REQUEST_COUNT} | Errors: ${ERROR_COUNT}"
done

echo ""
echo "============================================"
echo "Simulation complete"
echo "End time:        $(date)"
echo "Total requests:  ${REQUEST_COUNT}"
echo "Total errors:    ${ERROR_COUNT}"
echo "============================================"