#!/bin/bash

set -e

PREV_DIR=$(find daily_pages -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)

if [ -z "${PREV_DIR}" ] || [ ! -d "${PREV_DIR}" ]; then
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
    
    # Generate much richer content - multiple paragraphs with many words (same as create-pages.sh)
    local random_words=""
    local num_paragraphs=$((5 + RANDOM % 10))  # 5-14 paragraphs
    
    for para in $(seq 1 ${num_paragraphs}); do
        local words_per_para=$((50 + RANDOM % 100))  # 50-150 words per paragraph
        for i in $(seq 1 ${words_per_para}); do
            local random_index=$((RANDOM % total_words))
            random_words="${random_words}${words_array[$random_index]} "
        done
        random_words="${random_words}\n\n"
    done
    
    echo -e "${random_words}"
}

for UPDATE_FILE in "${PREV_DIR}"/update_page_*.md; do
    if [ ! -f "${UPDATE_FILE}" ]; then
        continue
    fi
    
    # Get existing content (preserve front matter, modify body)
    FRONT_MATTER=$(sed -n '/^---$/,/^---$/p' "${UPDATE_FILE}")
    
    # Generate new rich content to append (creates meaningful changes)
    RANDOM_WORDS=$(generate_random_words)
    
    # Write file with front matter and NEW content (replaces old content with new)
    echo "${FRONT_MATTER}" > "${UPDATE_FILE}"
    echo "" >> "${UPDATE_FILE}"
    echo "${RANDOM_WORDS}" >> "${UPDATE_FILE}"
    
    echo "Updated: ${UPDATE_FILE}"
    UPDATED_COUNT=$((UPDATED_COUNT + 1))
done

echo "${UPDATED_COUNT}"

