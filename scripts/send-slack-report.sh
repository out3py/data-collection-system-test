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

FILES_CREATED=$(grep "Files Created" "$REPORT_FILE" | sed -E 's/.*: ([0-9]+)/\1/')
FILES_UPDATED=$(grep "Files Updated" "$REPORT_FILE" | sed -E 's/.*: ([0-9]+)/\1/')
NEW_LINKS=$(grep "new_links" "$REPORT_FILE" | sed -E 's/.*: ([0-9]+)/\1/')
UPDATED_LINKS=$(grep "updated_links" "$REPORT_FILE" | sed -E 's/.*: ([0-9]+)/\1/')
CREATED_MATCH=$(grep "Created vs NewLinks" "$REPORT_FILE" | sed -E 's/.*→ \*\*(.+)\*\*/\1/')
UPDATED_MATCH=$(grep "Updated vs UpdatedLinks" "$REPORT_FILE" | sed -E 's/.*→ \*\*(.+)\*\*/\1/')

if [ "$CREATED_MATCH" = "OK" ]; then
  CREATED_EMOJI=":white_check_mark:"
else
  CREATED_EMOJI=":x:"
fi

if [ "$UPDATED_MATCH" = "OK" ]; then
  UPDATED_EMOJI=":white_check_mark:"
else
  UPDATED_EMOJI=":x:"
fi

MESSAGE=":rotating_light: *Auto-test Failed*\n\n*Comparison Results:*\n${CREATED_EMOJI} Created vs NewLinks: \`${FILES_CREATED}\` vs \`${NEW_LINKS}\` → *${CREATED_MATCH}*\n${UPDATED_EMOJI} Updated vs UpdatedLinks: \`${FILES_UPDATED}\` vs \`${UPDATED_LINKS}\` → *${UPDATED_MATCH}*"

PAYLOAD=$(jq -n --arg text "$MESSAGE" '{text: $text, mrkdwn: true}')

curl -fsS -X POST -H 'Content-type: application/json' \
  --data "$PAYLOAD" \
  "$SLACK_WEBHOOK_URL"

echo "Report sent successfully to Slack!"

