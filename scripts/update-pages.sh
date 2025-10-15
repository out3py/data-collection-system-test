#!/bin/bash

set -e

YESTERDAY=$(date -v-1d +%d.%m.%y 2>/dev/null || date -d "yesterday" +%d.%m.%y)
YESTERDAY_DIR="daily_pages/day-${YESTERDAY}"

if [ ! -d "${YESTERDAY_DIR}" ]; then
    echo "0"
    exit 0
fi

UPDATED_COUNT=0

generate_random_words() {
    local lorem_file="lorem_words.txt"
    if [ ! -f "${lorem_file}" ]; then
        echo "Error: ${lorem_file} not found"
        exit 1
    fi
    
    local words_array=($(cat "${lorem_file}"))
    local total_words=${#words_array[@]}
    
    local random_words=""
    for i in {1..5}; do
        local random_index=$((RANDOM % total_words))
        random_words="${random_words}${words_array[$random_index]} "
    done
    
    echo "${random_words}"
}

for UPDATE_FILE in "${YESTERDAY_DIR}"/update_page_*.md; do
    if [ ! -f "${UPDATE_FILE}" ]; then
        continue
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

