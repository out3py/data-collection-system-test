#!/bin/bash

set -e

TODAY=$(date +%d.%m.%y)
DAY_DIR="daily_pages/day-${TODAY}"

mkdir -p "${DAY_DIR}"

NUM_CREATED=$((1 + RANDOM % 3))
NUM_UPDATE=$((1 + RANDOM % 3))
NUM_DELETE=$((1 + RANDOM % 3))

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

