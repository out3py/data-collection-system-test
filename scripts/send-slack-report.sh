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

# Helper function to detect if this was the first run
# First run = daily_pages directory is empty or has no content-* subdirectories
# Note: At the time this script runs, daily_pages may already be populated,
# so we check if there's only one content-* directory (the one just created)
is_first_run() {
    local daily_pages_dir="daily_pages"
    if [[ ! -d "${daily_pages_dir}" ]]; then
        return 0  # First run - directory doesn't exist
    fi
    
    # Check if there are any content-* subdirectories
    local content_dirs=$(find "${daily_pages_dir}" -mindepth 1 -maxdepth 1 -type d -name "content-*" 2>/dev/null | wc -l | tr -d ' ')
    if [[ ${content_dirs:-0} -eq 0 ]]; then
        return 0  # First run - no content directories
    fi
    
    return 1  # Not first run
}

# Account for Jekyll's automatic generation of feed.xml and home_page (index.html)
# Extract EXPECTED_UPDATED from report file if available, otherwise calculate it
# Try to extract from the Updated vs UpdatedLinks line first
EXPECTED_UPDATED=$(grep "Updated vs UpdatedLinks" "$REPORT_FILE" | sed -E 's/.*\*\*([0-9]+).*/\1/' | head -1)
if [[ -z "${EXPECTED_UPDATED}" ]] || ! [[ "${EXPECTED_UPDATED}" =~ ^[0-9]+$ ]]; then
    # Fallback: Calculate based on same logic as compare.sh
    EXPECTED_UPDATED=${FILES_UPDATED}
    JEKYLL_ADJUSTMENT=0
    
    if ! is_first_run && [[ ${NEW_LINKS} -gt 0 ]]; then
        # Subsequent runs with new_links > 0: Add +1 (home_page only, feed.xml not updated)
        # Based on real data: feed.xml is not updated when new_links > 0
        JEKYLL_ADJUSTMENT=1
        EXPECTED_UPDATED=$((FILES_UPDATED + JEKYLL_ADJUSTMENT))
    fi
fi

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

if [ "$CREATED_MATCH" = "OK" ] && [ "$UPDATED_MATCH" = "OK" ]; then
  HEADER_TEXT="✅ Auto-test Passed (QA)"
else
  HEADER_TEXT="🚨 Auto-test Failed (QA)"
fi

SANITIZED_GRAFANA_URL="${GRAFANA_DASH_URL-}"
if [ -n "$SANITIZED_GRAFANA_URL" ]; then
  SANITIZED_GRAFANA_URL="${SANITIZED_GRAFANA_URL#@}"
  if [ "$REVISION_ID" != "N/A" ]; then
    DASHBOARD_URL="${SANITIZED_GRAFANA_URL}${REVISION_ID}"
  else
    DASHBOARD_URL="${SANITIZED_GRAFANA_URL}"
  fi
  DASHBOARD_LINE="\n<${DASHBOARD_URL}|Dashboard>"
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
        "text": "${HEADER_TEXT}"
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Comparison Results:*\n${CREATED_EMOJI} *Created vs NewLinks:* \`${FILES_CREATED}\` vs \`${NEW_LINKS}\` → *${CREATED_MATCH}*\n${UPDATED_EMOJI} *Updated vs UpdatedLinks:* \`${EXPECTED_UPDATED}\` vs \`${UPDATED_LINKS}\` → *${UPDATED_MATCH}*"
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
          "text": "_RevisionID:_ \`$REVISION_ID\`\n_Report file:_ \`$REPORT_FILE\`${DASHBOARD_LINE}"
        }
      ]
    }
  ]
}
EOF

echo "Report sent to Slack!"
