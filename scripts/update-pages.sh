#!/bin/bash

set -e

# Source content templates library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/content-templates.sh"

PREV_DIR=$(find daily_pages -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)

if [ -z "${PREV_DIR}" ] || [ ! -d "${PREV_DIR}" ]; then
    echo "0"
    exit 0
fi

UPDATED_COUNT=0

for UPDATE_FILE in "${PREV_DIR}"/update_page_*.md; do
    if [ ! -f "${UPDATE_FILE}" ]; then
        continue
    fi
    
    # Extract front matter (only the first YAML block between ---)
    FRONT_MATTER=$(sed -n '1,/^---$/p' "${UPDATE_FILE}")
    
    # Generate updated content using meaningful update strategies
    UPDATED_CONTENT=$(generate_content_update "${UPDATE_FILE}")
    
    # Write updated file with front matter preserved
    echo "${FRONT_MATTER}" > "${UPDATE_FILE}"
    echo -e "${UPDATED_CONTENT}" >> "${UPDATE_FILE}"
    
    echo "Updated: ${UPDATE_FILE}"
    UPDATED_COUNT=$((UPDATED_COUNT + 1))
done

echo "${UPDATED_COUNT}"

