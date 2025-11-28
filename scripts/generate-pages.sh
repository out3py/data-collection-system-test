#!/bin/bash

# Generate content pages
# Creates new pages with unique permalinks and updates existing pages preserving their permalinks
#
# For system testing with random number of pages (0 to MAX):
#   NUM_PAGES=500 bash scripts/generate-pages.sh  # Random 0-500 pages
#   or
#   export NUM_PAGES=500
#   bash scripts/generate-pages.sh
#
# Default: Random 0-10 pages (each run will have different count)

set -e

TIMESTAMP=$(date +%s)
CONTENT_ID="content-${TIMESTAMP}"
DAY_DIR="daily_pages/${CONTENT_ID}"

# Find previous directory BEFORE creating new one
PREV_DIR=$(find daily_pages -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort | tail -n 1)

# Check if this is first revision (no previous directories)
IS_FIRST_REVISION=false
if [ -z "${PREV_DIR}" ] || [ ! -d "${PREV_DIR}" ]; then
    IS_FIRST_REVISION=true
fi

# Now create the new directory
mkdir -p "${DAY_DIR}"

# Generate random number of pages for system test (0-10 by default)
# Default max is 10 pages, but allow override via NUM_PAGES environment variable
MAX_PAGES=${NUM_PAGES:-10}  # Maximum pages (default: 10)
NUM_NEW=$((RANDOM % (MAX_PAGES + 1)))  # Random 0 to MAX_PAGES
NUM_UPDATED=0

# Only update pages if NOT first revision
if [ "${IS_FIRST_REVISION}" = "false" ]; then
    # Count existing files in previous directory
    EXISTING_COUNT=$(find "${PREV_DIR}" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    if [ ${EXISTING_COUNT} -gt 0 ]; then
        # For system testing: update random number (0 to half of NUM_NEW) if enough pages exist
        # Otherwise update half of existing pages
        HALF_NUM_NEW=$((NUM_NEW / 2))
        HALF_EXISTING=$((1 + EXISTING_COUNT / 2))
        
        # If we have enough existing pages, update random amount up to half of NUM_NEW
        if [ ${EXISTING_COUNT} -ge ${HALF_NUM_NEW} ] && [ ${HALF_NUM_NEW} -gt 0 ]; then
            # Random between 0 and HALF_NUM_NEW
            NUM_UPDATED=$((RANDOM % (HALF_NUM_NEW + 1)))
        else
            NUM_UPDATED=${HALF_EXISTING}  # Update half of existing (if fewer than half of NUM_NEW exist)
        fi
    fi
fi

generate_semantic_content() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local semantic_gen="${script_dir}/generate-semantic-content.py"
    
    if [ ! -f "${semantic_gen}" ]; then
        echo "Error: ${semantic_gen} not found" >&2
        exit 1
    fi
    
    local num_paragraphs=$((5 + RANDOM % 10))  # 5-14 paragraphs
    python3 "${semantic_gen}" --paragraphs "${num_paragraphs}"
}

generate_semantic_update() {
    local existing_file="$1"
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local semantic_gen="${script_dir}/generate-semantic-content.py"
    
    if [ ! -f "${semantic_gen}" ]; then
        echo "Error: ${semantic_gen} not found" >&2
        exit 1
    fi
    
    # Extract content from existing file (skip front matter)
    local temp_content=$(mktemp)
    if grep -q '^---$' "${existing_file}"; then
        # Extract content after front matter (everything after second ---)
        awk '/^---$/{if(++count==2) next} count>=2' "${existing_file}" > "${temp_content}"
    else
        cat "${existing_file}" > "${temp_content}"
    fi
    
    # Generate update using semantic generator
    local update_type=$(python3 -c "import random; print(random.choice(['expand', 'refine', 'add_section', 'update']))")
    python3 "${semantic_gen}" --update --update-type "${update_type}" --existing-content "${temp_content}"
    local exit_code=$?
    rm -f "${temp_content}"
    return $exit_code
}

# Update existing pages FIRST (only if not first revision)
# This needs to happen before creating new pages to preserve numbering
if [ "${IS_FIRST_REVISION}" = "false" ] && [ ${NUM_UPDATED} -gt 0 ]; then
    echo "Random count: Updating ${NUM_UPDATED} existing pages..."
    UPDATE_COUNTER=0
    for prev_file in "${PREV_DIR}"/*.md; do
        # Skip if not a regular file or we've reached the update limit
        if [ ! -f "${prev_file}" ]; then
            continue
        fi
        if [ ${UPDATE_COUNTER} -ge ${NUM_UPDATED} ]; then
            break
        fi
        
        CREATED_DATE=$(date '+%Y-%m-%d %H:%M:%S')
        
        # Extract title and original permalink from previous file
        TITLE=$(grep -E '^title:' "${prev_file}" 2>/dev/null | sed -E 's/^title: "(.+)"$/\1/' | head -1)
        if [ -z "${TITLE}" ]; then
            TITLE="Updated Page"
        fi
        
        # Extract original permalink
        ORIG_PERMALINK=$(grep -E '^permalink:' "${prev_file}" 2>/dev/null | sed -E 's/^permalink: (.+)$/\1/' | head -1)
        
        # Extract original filename (simple index-based name)
        PREV_BASENAME=$(basename "${prev_file}" .md)
        
        # Use same filename as original (preserve simple index name and permalink)
        FILENAME="${DAY_DIR}/${PREV_BASENAME}.md"
        
        # Preserve original permalink (same URL, updated content)
        if [ -n "${ORIG_PERMALINK}" ]; then
            PERMALINK="${ORIG_PERMALINK}"
        else
            # Fallback: generate from filename
            PERMALINK="/${PREV_BASENAME}.html"
        fi
        
        SEMANTIC_CONTENT=$(generate_semantic_update "${prev_file}")
        
        cat > "${FILENAME}" << EOF
---
layout: page
title: "${TITLE}"
created_date: "${CREATED_DATE}"
permalink: ${PERMALINK}
---

${SEMANTIC_CONTENT}
EOF

        # Show progress every 50 pages or on last page
        UPDATE_COUNTER=$((UPDATE_COUNTER + 1))
        if [ $((UPDATE_COUNTER % 50)) -eq 0 ] || [ ${UPDATE_COUNTER} -eq ${NUM_UPDATED} ]; then
            echo "Updated: ${UPDATE_COUNTER}/${NUM_UPDATED} pages (latest: ${FILENAME})"
        fi
    done
    echo "Finished updating ${NUM_UPDATED} pages"
    
    # Copy remaining pages that weren't updated (preserve all pages from previous revision)
    for prev_file in "${PREV_DIR}"/*.md; do
        if [ ! -f "${prev_file}" ]; then
            continue
        fi
        
        PREV_BASENAME=$(basename "${prev_file}" .md)
        FILENAME="${DAY_DIR}/${PREV_BASENAME}.md"
        
        # Skip if already updated
        if [ -f "${FILENAME}" ]; then
            continue
        fi
        
        # Copy the file as-is (preserve content and metadata)
        cp "${prev_file}" "${FILENAME}"
        echo "Copied: ${FILENAME} (preserved from previous revision)"
    done
fi

# Count copied pages (for statistics)
NUM_COPIED=0
if [ "${IS_FIRST_REVISION}" = "false" ] && [ -d "${DAY_DIR}" ]; then
    # Count files that were copied but not updated
    for prev_file in "${PREV_DIR}"/*.md; do
        if [ ! -f "${prev_file}" ]; then
            continue
        fi
        PREV_BASENAME=$(basename "${prev_file}" .md)
        FILENAME="${DAY_DIR}/${PREV_BASENAME}.md"
        # If file exists but wasn't in update output, it was copied
        if [ -f "${FILENAME}" ]; then
            NUM_COPIED=$((NUM_COPIED + 1))
        fi
    done
    # Subtract updated pages from copied count
    NUM_COPIED=$((NUM_COPIED - NUM_UPDATED))
fi

# Now create new pages
# Find max page number from previous directory + updated files
MAX_PAGE_NUM=0
if [ "${IS_FIRST_REVISION}" = "false" ]; then
    # Check previous directory for max page number
    for prev_file in "${PREV_DIR}"/*.md; do
        if [ -f "${prev_file}" ]; then
            PREV_BASENAME=$(basename "${prev_file}" .md)
            # Extract number from filename like "page_1" -> "1"
            PAGE_NUM=$(echo "${PREV_BASENAME}" | sed 's/page_//')
            # Convert to number and compare
            if echo "${PAGE_NUM}" | grep -qE '^[0-9]+$'; then
                if [ ${PAGE_NUM} -gt ${MAX_PAGE_NUM} ] 2>/dev/null; then
                    MAX_PAGE_NUM=${PAGE_NUM}
                fi
            fi
        fi
    done
    # Check already created files in current directory (updates)
    if [ -d "${DAY_DIR}" ]; then
        for curr_file in "${DAY_DIR}"/page_*.md; do
            if [ -f "${curr_file}" ]; then
                CURR_BASENAME=$(basename "${curr_file}" .md)
                PAGE_NUM=$(echo "${CURR_BASENAME}" | sed 's/page_//')
                if echo "${PAGE_NUM}" | grep -qE '^[0-9]+$'; then
                    if [ ${PAGE_NUM} -gt ${MAX_PAGE_NUM} ] 2>/dev/null; then
                        MAX_PAGE_NUM=${PAGE_NUM}
                    fi
                fi
            fi
        done
    fi
fi

# Start new page numbering from max + 1
NEXT_PAGE_NUM=$((MAX_PAGE_NUM + 1))

# Create new pages
# Use simple sequential numbering for permalinks
PAGE_NUM=${NEXT_PAGE_NUM}
if [ ${NUM_NEW} -eq 0 ]; then
    echo "Random count: 0 new pages (skipping creation)"
else
    echo "Random count: Generating ${NUM_NEW} new pages (random 0-${MAX_PAGES})..."
    for i in $(seq 1 ${NUM_NEW}); do
        # Simple filename with index
        FILENAME="${DAY_DIR}/page_${PAGE_NUM}.md"
        CREATED_DATE=$(date '+%Y-%m-%d %H:%M:%S')
        
        # Simple permalink: page_1, page_2, etc.
        PERMALINK="/page_${PAGE_NUM}.html"
        
        SEMANTIC_CONTENT=$(generate_semantic_content)
        
        cat > "${FILENAME}" << EOF
---
layout: page
title: "Page ${PAGE_NUM}"
created_date: "${CREATED_DATE}"
permalink: ${PERMALINK}
---

${SEMANTIC_CONTENT}
EOF

        # Show progress every 50 pages or on last page
        if [ $((i % 50)) -eq 0 ] || [ ${i} -eq ${NUM_NEW} ]; then
            echo "Created: ${i}/${NUM_NEW} pages (latest: ${FILENAME})"
        fi
        PAGE_NUM=$((PAGE_NUM + 1))
    done
    echo "Finished generating ${NUM_NEW} new pages"
fi

# Output counts separately for proper statistics
# Format: NEW_COUNT:UPDATED_COUNT:COPIED_COUNT:TOTAL
echo "${NUM_NEW}:${NUM_UPDATED}:${NUM_COPIED}:$((NUM_NEW + NUM_UPDATED + NUM_COPIED))"

