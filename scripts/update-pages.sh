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

generate_random_words() {
    local words=""
    for i in {1..5}; do
        local word=""
        for j in {1..7}; do
            local char_code=$((97 + RANDOM % 26))
            word="${word}$(printf "\\$(printf '%03o' ${char_code})")"
        done
        words="${words}${word} "
    done
    echo "${words}"
}

for UPDATE_FILE in "${YESTERDAY_DIR}"/update_page_*.md; do
    if [ ! -f "${UPDATE_FILE}" ]; then
        continue
    fi
    
    if [ ${UPDATED_COUNT} -ge ${MAX_UPDATES} ]; then
        break
    fi
    
    RANDOM_WORDS=$(generate_random_words)
    
    FRONT_MATTER=$(sed -n '/^---$/,/^---$/p' "${UPDATE_FILE}")
    
    echo "${FRONT_MATTER}" > "${UPDATE_FILE}"
    echo "" >> "${UPDATE_FILE}"
    echo "${RANDOM_WORDS}" >> "${UPDATE_FILE}"
    
    echo "Updated: ${UPDATE_FILE}"
    UPDATED_COUNT=$((UPDATED_COUNT + 1))
done

echo "${UPDATED_COUNT}"

