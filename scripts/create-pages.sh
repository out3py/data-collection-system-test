#!/bin/bash

set -e

# Source content templates library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/content-templates.sh"

TIMESTAMP=$(date +%s)
CONTENT_ID="content-${TIMESTAMP}"
DAY_DIR="daily_pages/${CONTENT_ID}"

mkdir -p "${DAY_DIR}"

NUM_CREATED=$((1 + RANDOM % 3))
NUM_UPDATE=$((1 + RANDOM % 3))
NUM_DELETE=$((1 + RANDOM % 3))

for i in $(seq 1 ${NUM_CREATED}); do
    FILENAME="${DAY_DIR}/created_page_${i}.md"
    CREATED_DATE=$(date '+%Y-%m-%d %H:%M:%S')
    
    PAGE_CONTENT=$(generate_blog_content "$i")
    
    cat > "${FILENAME}" << EOF
---
layout: page
title: "Created Page ${i}"
created_date: "${CREATED_DATE}"
---

${PAGE_CONTENT}
EOF

    echo "Created: ${FILENAME}"
done

for i in $(seq 1 ${NUM_UPDATE}); do
    FILENAME="${DAY_DIR}/update_page_${i}.md"
    CREATED_DATE=$(date '+%Y-%m-%d %H:%M:%S')
    
    PAGE_CONTENT=$(generate_blog_content "$i")
    
    cat > "${FILENAME}" << EOF
---
layout: page
title: "Update Page ${i}"
created_date: "${CREATED_DATE}"
---

${PAGE_CONTENT}
EOF

    echo "Created: ${FILENAME}"
done

for i in $(seq 1 ${NUM_DELETE}); do
    FILENAME="${DAY_DIR}/delete_page_${i}.md"
    CREATED_DATE=$(date '+%Y-%m-%d %H:%M:%S')
    
    PAGE_CONTENT=$(generate_blog_content "$i")
    
    cat > "${FILENAME}" << EOF
---
layout: page
title: "Delete Page ${i}"
created_date: "${CREATED_DATE}"
---

${PAGE_CONTENT}
EOF

    echo "Created: ${FILENAME}"
done

TOTAL=$((NUM_CREATED + NUM_UPDATE + NUM_DELETE))
echo "${TOTAL}"

