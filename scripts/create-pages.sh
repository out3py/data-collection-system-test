#!/bin/bash

set -e

TIMESTAMP=$(date +%s)
CONTENT_ID="content-${TIMESTAMP}"
DAY_DIR="daily_pages/${CONTENT_ID}"

mkdir -p "${DAY_DIR}"

NUM_CREATED=$((1 + RANDOM % 3))
NUM_UPDATE=$((1 + RANDOM % 3))
NUM_DELETE=$((1 + RANDOM % 3))

generate_random_words() {
    local lorem_file="lorem_words.txt"
    if [ ! -f "${lorem_file}" ]; then
        echo "Error: ${lorem_file} not found"
        exit 1
    fi
    
    local words_array=($(cat "${lorem_file}"))
    local total_words=${#words_array[@]}
    
    # Generate much richer content - multiple paragraphs with many words
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

for i in $(seq 1 ${NUM_CREATED}); do
    FILENAME="${DAY_DIR}/created_page_${i}.md"
    CREATED_DATE=$(date '+%Y-%m-%d %H:%M:%S')
    
    RANDOM_WORDS=$(generate_random_words)
    
    cat > "${FILENAME}" << EOF
---
layout: page
title: "Created Page ${i}"
created_date: "${CREATED_DATE}"
---

${RANDOM_WORDS}
EOF

    echo "Created: ${FILENAME}"
done

for i in $(seq 1 ${NUM_UPDATE}); do
    FILENAME="${DAY_DIR}/update_page_${i}.md"
    CREATED_DATE=$(date '+%Y-%m-%d %H:%M:%S')
    
    RANDOM_WORDS=$(generate_random_words)
    
    cat > "${FILENAME}" << EOF
---
layout: page
title: "Update Page ${i}"
created_date: "${CREATED_DATE}"
---

${RANDOM_WORDS}
EOF

    echo "Created: ${FILENAME}"
done

for i in $(seq 1 ${NUM_DELETE}); do
    FILENAME="${DAY_DIR}/delete_page_${i}.md"
    CREATED_DATE=$(date '+%Y-%m-%d %H:%M:%S')
    
    RANDOM_WORDS=$(generate_random_words)
    
    cat > "${FILENAME}" << EOF
---
layout: page
title: "Delete Page ${i}"
created_date: "${CREATED_DATE}"
---

${RANDOM_WORDS}
EOF

    echo "Created: ${FILENAME}"
done

TOTAL=$((NUM_CREATED + NUM_UPDATE + NUM_DELETE))
echo "${TOTAL}"

