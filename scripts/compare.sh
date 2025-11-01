#!/bin/bash
set -euo pipefail

REPORTS_DIR="reports"
mkdir -p "${REPORTS_DIR}"

EVENT_JSON="${GITHUB_EVENT_PATH:-}"
if [[ -z "${EVENT_JSON}" || ! -f "${EVENT_JSON}" ]]; then
  echo "ERROR: GITHUB_EVENT_PATH is empty or file not found"
  exit 1
fi

URL=$(jq -r '.client_payload.url // ""' "${EVENT_JSON}")
REVISION_ID=$(jq -r '.client_payload.revision_id // ""' "${EVENT_JSON}")
FOUND_LINKS=$(jq -r '.client_payload.found_links // 0' "${EVENT_JSON}")
NEW_LINKS=$(jq -r '.client_payload.new_links // 0' "${EVENT_JSON}")
UPDATED_LINKS=$(jq -r '.client_payload.updated_links // 0' "${EVENT_JSON}")
EVENT_TYPE=$(jq -r '.event_type // ""' "${EVENT_JSON}")

STATS_FILE="stats.md"
if [[ ! -f "${STATS_FILE}" ]]; then
  echo "WARN: ${STATS_FILE} not found. Using zeros for comparison."
  FILES_CREATED=0
  FILES_UPDATED=0
else
  FILES_CREATED=$(grep -E '^\- \*\*Files Created\*\*:' "${STATS_FILE}" | head -1 | sed -E 's/[^0-9]+([0-9]+).*/\1/')
  FILES_UPDATED=$(grep -E '^\- \*\*Files Updated\*\*:' "${STATS_FILE}" | head -1 | sed -E 's/[^0-9]+([0-9]+).*/\1/')
  FILES_CREATED=${FILES_CREATED:-0}
  FILES_UPDATED=${FILES_UPDATED:-0}
fi

CREATED_MATCH=$([[ "${FILES_CREATED}" -eq "${NEW_LINKS}" ]] && echo "OK" || echo "MISMATCH")

# Account for landing page update when new links are added
# When new links are detected, the landing page (index.md) is also updated
# So we need to add 1 to FILES_UPDATED for comparison if there are new links
EXPECTED_UPDATED=${FILES_UPDATED}
if [[ ${NEW_LINKS} -gt 0 ]]; then
    EXPECTED_UPDATED=$((FILES_UPDATED + 1))
fi

UPDATED_MATCH=$([[ "${EXPECTED_UPDATED}" -eq "${UPDATED_LINKS}" ]] && echo "OK" || echo "MISMATCH")

# Build description for updated comparison
if [[ ${NEW_LINKS} -gt 0 ]]; then
    UPDATED_DESC="${EXPECTED_UPDATED} (${FILES_UPDATED} files + 1 landing page)"
else
    UPDATED_DESC="${EXPECTED_UPDATED}"
fi

TS=$(date '+%Y-%m-%d %H:%M:%S')
TS_ID=$(date '+%Y%m%d-%H%M%S')
REPORT_FILE="${REPORTS_DIR}/restart_revision_${TS_ID}.md"

cat > "${REPORT_FILE}" <<EOF
---
layout: page
title: "Restart Revision Compare ${TS_ID}"
---

# Restart Revision Compare

## Payload
- **url**: ${URL}
- **RevisionID**: ${REVISION_ID}
- **found_links**: ${FOUND_LINKS}
- **new_links**: ${NEW_LINKS}
- **updated_links**: ${UPDATED_LINKS}

## Current stats.md
- **Files Created**: ${FILES_CREATED}
- **Files Updated**: ${FILES_UPDATED}

## Comparison
- Created vs NewLinks: **${FILES_CREATED}** ?= **${NEW_LINKS}** → **${CREATED_MATCH}**
- Updated vs UpdatedLinks: **${UPDATED_DESC}** ?= **${UPDATED_LINKS}** → **${UPDATED_MATCH}**

---
EOF

echo "Report written to: ${REPORT_FILE}"

if [[ "${CREATED_MATCH}" != "OK" || "${UPDATED_MATCH}" != "OK" ]]; then
  echo "Mismatch detected — failing the job."
  exit 2
fi

echo "Matches OK — numbers are consistent."
