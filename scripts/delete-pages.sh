#!/bin/bash

set -e

YESTERDAY=$(date -v-1d +%d.%m.%y 2>/dev/null || date -d "yesterday" +%d.%m.%y)
YESTERDAY_DIR="daily_pages/day-${YESTERDAY}"

if [ ! -d "${YESTERDAY_DIR}" ]; then
    echo "0"
    exit 0
fi

DELETED_COUNT=0

for DELETE_FILE in "${YESTERDAY_DIR}"/delete_page_*.md; do
    if [ ! -f "${DELETE_FILE}" ]; then
        continue
    fi
    
    rm -f "${DELETE_FILE}"
    
    echo "Deleted: ${DELETE_FILE}"
    DELETED_COUNT=$((DELETED_COUNT + 1))
done

echo "${DELETED_COUNT}"

