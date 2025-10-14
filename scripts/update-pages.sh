#!/bin/bash

set -e

YESTERDAY=$(date -v-1d +%d.%m.%y 2>/dev/null || date -d "yesterday" +%d.%m.%y)
YESTERDAY_DIR="_daily_pages/day-${YESTERDAY}"

if [ ! -d "${YESTERDAY_DIR}" ]; then
    echo "0"
    exit 0
fi

UPDATED_COUNT=0
MAX_UPDATES=$((1 + RANDOM % 3))

for UPDATE_FILE in "${YESTERDAY_DIR}"/update_page_*.md; do
    if [ ! -f "${UPDATE_FILE}" ]; then
        continue
    fi
    
    if [ ${UPDATED_COUNT} -ge ${MAX_UPDATES} ]; then
        break
    fi
    
    RANDOM_WORDS=$(LC_ALL=C tr -dc 'a-z' < /dev/urandom | fold -w 7 | head -5 | tr '\n' ' ')
    
    FRONT_MATTER=$(sed -n '/^---$/,/^---$/p' "${UPDATE_FILE}")
    
    echo "${FRONT_MATTER}" > "${UPDATE_FILE}"
    echo "" >> "${UPDATE_FILE}"
    echo "${RANDOM_WORDS}" >> "${UPDATE_FILE}"
    
    echo "Updated: ${UPDATE_FILE}"
    UPDATED_COUNT=$((UPDATED_COUNT + 1))
done

echo "${UPDATED_COUNT}"

