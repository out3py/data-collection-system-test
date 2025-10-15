#!/bin/bash

set -e

PREV_DIR=$(find daily_pages -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)

if [ -z "${PREV_DIR}" ] || [ ! -d "${PREV_DIR}" ]; then
    echo "0"
    exit 0
fi

DELETED_COUNT=0

for DELETE_FILE in "${PREV_DIR}"/delete_page_*.md; do
    if [ ! -f "${DELETE_FILE}" ]; then
        continue
    fi
    
    rm -f "${DELETE_FILE}"
    
    echo "Deleted: ${DELETE_FILE}"
    DELETED_COUNT=$((DELETED_COUNT + 1))
done

echo "${DELETED_COUNT}"

