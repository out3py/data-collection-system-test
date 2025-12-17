#!/bin/bash

set -euo pipefail

die() {
  echo "Error: $*" >&2
  exit 1
}

extract_first_match() {
  local grep_regex="$1"
  local sed_expr="$2"
  local file="$3"
  grep -m 1 -E "${grep_regex}" "${file}" 2>/dev/null | sed -nE "${sed_expr}" || true
}

extract_int_or_default() {
  local grep_regex="$1"
  local sed_expr="$2"
  local file="$3"
  local def="$4"

  local v
  v="$(extract_first_match "${grep_regex}" "${sed_expr}" "${file}")"
  if [[ -z "${v}" || ! "${v}" =~ ^[0-9]+$ ]]; then
    echo "${def}"
    return 0
  fi
  echo "${v}"
}

if [ -z "${SLACK_WEBHOOK_URL:-}" ]; then
  die "SLACK_WEBHOOK_URL environment variable is not set"
fi

REPORT_FILE=$(ls -t reports/restart_revision_*.md 2>/dev/null | head -n 1 || true)
if [ -z "$REPORT_FILE" ]; then
  die "No report file found in reports/ directory"
fi

echo "Sending report: $REPORT_FILE"

FILES_CREATED="$(extract_int_or_default '^\- \*\*Files Created\*\*:' 's/[^0-9]*([0-9]+).*/\1/p' "$REPORT_FILE" "0")"
FILES_UPDATED="$(extract_int_or_default '^\- \*\*Files Updated\*\*:' 's/[^0-9]*([0-9]+).*/\1/p' "$REPORT_FILE" "0")"
NEW_LINKS="$(extract_int_or_default '^\- \*\*new_links\*\*:' 's/[^0-9]*([0-9]+).*/\1/p' "$REPORT_FILE" "0")"
UPDATED_LINKS="$(extract_int_or_default '^\- \*\*updated_links\*\*:' 's/[^0-9]*([0-9]+).*/\1/p' "$REPORT_FILE" "0")"

REVISION_ID="$(extract_first_match '^\- \*\*revision_id\*\*:' 's/.*: (.+)/\1/p' "$REPORT_FILE")"
if [ -z "$REVISION_ID" ]; then
  REVISION_ID="$(extract_first_match '^\- \*\*RevisionID\*\*:' 's/.*: (.+)/\1/p' "$REPORT_FILE")"
fi
REVISION_ID=${REVISION_ID:-"N/A"}
CREATED_MATCH="$(extract_first_match 'Created vs NewLinks' 's/.*→ \*\*([^*]+)\*\*.*/\1/p' "$REPORT_FILE")"
UPDATED_MATCH="$(extract_first_match 'Updated vs UpdatedLinks' 's/.*→ \*\*([^*]+)\*\*.*/\1/p' "$REPORT_FILE")"
CREATED_MATCH="${CREATED_MATCH:-UNKNOWN}"
UPDATED_MATCH="${UPDATED_MATCH:-UNKNOWN}"

is_first_run() {
    local daily_pages_dir="daily_pages"
    if [[ ! -d "${daily_pages_dir}" ]]; then
        return 0
    fi
    
    local content_dirs=$(find "${daily_pages_dir}" -mindepth 1 -maxdepth 1 -type d -name "content-*" 2>/dev/null | wc -l | tr -d ' ')
    if [[ ${content_dirs:-0} -eq 0 ]]; then
        return 0
    fi
    
    return 1
}

EXPECTED_UPDATED="$(extract_first_match 'Updated vs UpdatedLinks' 's/.*Updated vs UpdatedLinks: \*\*([0-9]+).*/\1/p' "$REPORT_FILE")"
if [[ -z "${EXPECTED_UPDATED}" ]] || ! [[ "${EXPECTED_UPDATED}" =~ ^[0-9]+$ ]]; then
    EXPECTED_UPDATED="${FILES_UPDATED}"
    JEKYLL_ADJUSTMENT=0
    
    if ! is_first_run && [[ ${NEW_LINKS} -gt 0 ]]; then
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

payload_file="$(mktemp)"
resp_file="$(mktemp)"
trap 'rm -f "${payload_file}" "${resp_file}"' EXIT

cat >"${payload_file}" <<EOF
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

curl_exit=0
http_code="$(curl -sS -o "${resp_file}" -w "%{http_code}" -X POST -H 'Content-type: application/json' --data @"${payload_file}" "$SLACK_WEBHOOK_URL" || curl_exit=$?)"

if [[ "${curl_exit}" -ne 0 ]]; then
  echo "Error: failed to POST to Slack webhook (curl exit ${curl_exit})" >&2
  echo "Response body:" >&2
  cat "${resp_file}" >&2 || true
  exit 1
fi

if [[ ! "${http_code}" =~ ^2 ]]; then
  echo "Error: Slack webhook returned HTTP ${http_code}" >&2
  echo "Response body:" >&2
  cat "${resp_file}" >&2 || true
  exit 1
fi

echo "Report sent to Slack!"
