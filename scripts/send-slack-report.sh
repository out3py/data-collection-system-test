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
REVISION_ID=$(grep -E '^\- \*\*revision_id\*\*: ' "$REPORT_FILE" | sed -E 's/.*: (.+)/\1/' || echo "")
if [ -z "$REVISION_ID" ]; then
  REVISION_ID=$(grep -E '^\- \*\*RevisionID\*\*: ' "$REPORT_FILE" | sed -E 's/.*: (.+)/\1/' || echo "")
fi
REVISION_ID=${REVISION_ID:-"N/A"}
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

SANITIZED_GRAFANA_URL="${GRAFANA_DASH_URL-}"
if [ -n "$SANITIZED_GRAFANA_URL" ]; then
  SANITIZED_GRAFANA_URL="${SANITIZED_GRAFANA_URL#@}"
  if [ "$REVISION_ID" != "N/A" ]; then
    DASHBOARD_URL="${SANITIZED_GRAFANA_URL}${REVISION_ID}"
  else
    DASHBOARD_URL="${SANITIZED_GRAFANA_URL}"
  fi
  DASHBOARD_LINE="\n*Dashboard:* <${DASHBOARD_URL}|Dashboard>"
else
  DASHBOARD_LINE=""
fi

cat <<EOF | curl -fsS -X POST -H 'Content-type: application/json' -d @- "$SLACK_WEBHOOK_URL"
{
  "blocks": [
    {
      "type": "header",
      "text": {
        "type": "plain_text",
        "text": "🚨 Auto-test Failed (QA)"
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Comparison Results:*\n${CREATED_EMOJI} *Created vs NewLinks:* \`${FILES_CREATED}\` vs \`${NEW_LINKS}\` → *${CREATED_MATCH}*\n${UPDATED_EMOJI} *Updated vs UpdatedLinks:* \`${FILES_UPDATED}\` vs \`${UPDATED_LINKS}\` → *${UPDATED_MATCH}*"
      }
    },
    {
      "type": "divider"
    },
    {
      "type": "context",
      "elements": [
        {
          "type": "mrkdwn",
          "text": "*RevisionID:* \`$REVISION_ID\`\n_Report file:_ \`$REPORT_FILE\`${DASHBOARD_LINE}"
        }
      ]
    }
  ]
}
EOF

echo "Report sent to Slack!"
