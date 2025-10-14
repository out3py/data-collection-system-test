#!/bin/bash

set -e

TODAY=$(date +%d.%m.%y)
DAY_DIR="_daily_pages/day-${TODAY}"

mkdir -p "${DAY_DIR}"

NUM_CREATED=$((1 + RANDOM % 3))
NUM_UPDATE=$((1 + RANDOM % 3))
NUM_DELETE=$((1 + RANDOM % 3))

for i in $(seq 1 ${NUM_CREATED}); do
    FILENAME="${DAY_DIR}/created_page_${i}.md"
    CREATED_DATE=$(date '+%Y-%m-%d %H:%M:%S')
    
    RANDOM_WORDS=$(shuf -n 5 /usr/share/dict/words 2>/dev/null | tr '\n' ' ' || head -c 50 /dev/urandom | tr -dc 'a-z' | fold -w 5 | head -5 | tr '\n' ' ')
    
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
    
    RANDOM_WORDS=$(shuf -n 5 /usr/share/dict/words 2>/dev/null | tr '\n' ' ' || head -c 50 /dev/urandom | tr -dc 'a-z' | fold -w 5 | head -5 | tr '\n' ' ')
    
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
    
    RANDOM_WORDS=$(shuf -n 5 /usr/share/dict/words 2>/dev/null | tr '\n' ' ' || head -c 50 /dev/urandom | tr -dc 'a-z' | fold -w 5 | head -5 | tr '\n' ' ')
    
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

