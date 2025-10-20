#!/bin/bash

set -euo pipefail

if [ -z "${SLACK_WEBHOOK_URL:-}" ]; then
  echo "Error: SLACK_WEBHOOK_URL environment variable is not set"
  exit 1
fi

REPORT_FILE=$(ls -t reports/restart_revision_*.md 2>/dev/null | head -n 1)

if [ -z "$REPORT_FILE" ]; then
  echo "Error: No report file found in reports/ directory"
  exit 1
fi

echo "Sending report: $REPORT_FILE"

REPORT=$(cat "$REPORT_FILE")

HEADER="*Auto-test failed*\n\n"
FULL_MESSAGE="${HEADER}${REPORT}"

PAYLOAD=$(printf '%s' "$FULL_MESSAGE" | jq -Rs .)

curl -fsS -X POST -H 'Content-type: application/json' \
  --data "{\"text\": ${PAYLOAD}}" \
  "$SLACK_WEBHOOK_URL"

echo "Report sent successfully to Slack!"

