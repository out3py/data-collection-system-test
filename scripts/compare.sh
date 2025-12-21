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

# Helper function to detect if this was the first run
# Note: compare.sh runs AFTER run-content-management.sh, so daily_pages is already populated
# We use found_links=0 as an indicator of first run (no existing links found)
# Alternatively, check if stats.md shows this was the first run by checking if FILES_CREATED equals all content
is_first_run() {
    # If found_links is 0, it's likely the first run (no existing links to compare against)
    if [[ ${FOUND_LINKS:-0} -eq 0 ]]; then
        return 0
    fi
    
    # Also check if daily_pages directory doesn't exist or is empty (shouldn't happen at this point, but safety check)
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

# Account for Jekyll's automatic generation of feed.xml and home_page (index.html)
# stats.md contains raw file counts (actual files created/updated)
# We need to add Jekyll adjustment to calculate expected updated_links value
# Based on real data: first run with 1 file created → new_links=2 (1 file + 1 home_page), updated_links=0
# Subsequent runs:
#   - new_links > 0: Add +1 (home_page only, feed.xml not updated on subsequent runs)
EXPECTED_UPDATED=${FILES_UPDATED}
JEKYLL_ADJUSTMENT=0

if ! is_first_run && [[ ${NEW_LINKS} -gt 0 ]]; then
    # Subsequent runs with new_links > 0: Add +1 (home_page only, feed.xml not updated)
    # Based on real data:
    #   - new_links=6, files_updated=0 → updated_links=1 (only home_page)
    #   - new_links=8, files_updated=3 → updated_links=4 (3 files + 1 home_page, feed not updated)
    JEKYLL_ADJUSTMENT=1
    EXPECTED_UPDATED=$((FILES_UPDATED + JEKYLL_ADJUSTMENT))
fi

UPDATED_MATCH=$([[ "${EXPECTED_UPDATED}" -eq "${UPDATED_LINKS}" ]] && echo "OK" || echo "MISMATCH")

# Build description for updated comparison
if [[ ${JEKYLL_ADJUSTMENT} -eq 2 ]]; then
    UPDATED_DESC="${EXPECTED_UPDATED} (${FILES_UPDATED} files + ${JEKYLL_ADJUSTMENT} jekyll-generated: feed + home_page)"
elif [[ ${JEKYLL_ADJUSTMENT} -eq 1 ]]; then
    UPDATED_DESC="${EXPECTED_UPDATED} (${FILES_UPDATED} files + ${JEKYLL_ADJUSTMENT} jekyll-generated: home_page)"
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
