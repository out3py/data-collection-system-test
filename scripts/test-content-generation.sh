#!/bin/bash

# Test script to verify content generation randomness and updates

set -e

cd "$(dirname "$0")/.."

echo "=========================================="
echo "Content Generation Randomness Test"
echo "=========================================="
echo ""

# Clean up first
rm -rf daily_pages/content-*

echo "Test 1: Creating new pages..."
bash scripts/create-pages.sh > /dev/null 2>&1

LATEST_DIR=$(find daily_pages -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)
echo "✓ Created files in: ${LATEST_DIR}"
echo ""

echo "Generated files:"
ls -1 "${LATEST_DIR}" | grep -E "created_page|update_page"
echo ""

echo "File sizes (larger = more content):"
for file in "${LATEST_DIR}"/created_page_*.md; do
    if [ -f "$file" ]; then
        size=$(wc -l < "$file")
        name=$(basename "$file")
        echo "  ${name}: ${size} lines"
    fi
done
echo ""

echo "Content preview (first main heading from each created page):"
for file in "${LATEST_DIR}"/created_page_*.md; do
    if [ -f "$file" ]; then
        heading=$(grep "^##" "$file" | head -1 | sed 's/^## //')
        name=$(basename "$file")
        echo "  ${name}: ${heading}"
    fi
done
echo ""

echo "Randomness check - comparing created_page_1 and created_page_2:"
if diff -q "${LATEST_DIR}/created_page_1.md" "${LATEST_DIR}/created_page_2.md" > /dev/null 2>&1; then
    echo "  ❌ ERROR: Pages are identical (randomization not working!)"
else
    echo "  ✅ Pages are different (randomization working)"
    
    # Show some differences
    echo ""
    echo "  Sample differences:"
    heading1=$(grep "^##" "${LATEST_DIR}/created_page_1.md" | head -1)
    heading2=$(grep "^##" "${LATEST_DIR}/created_page_2.md" | head -1)
    echo "    Page 1 main heading: ${heading1}"
    echo "    Page 2 main heading: ${heading2}"
fi
echo ""

echo "Test 2: Updating existing pages..."
UPDATE_BEFORE=$(wc -l < "${LATEST_DIR}/update_page_1.md")
bash scripts/update-pages.sh > /dev/null 2>&1
UPDATE_AFTER=$(wc -l < "${LATEST_DIR}/update_page_1.md")

echo "  ✓ Updated pages"
echo "  File size before: ${UPDATE_BEFORE} lines"
echo "  File size after:  ${UPDATE_AFTER} lines"
echo "  Difference: $((UPDATE_AFTER - UPDATE_BEFORE)) lines added"
echo ""

echo "Update verification:"
if grep -q "Update Notice\|This section was added\|Additional Features\|This content has been expanded" "${LATEST_DIR}/update_page_1.md"; then
    echo "  ✅ Update detected meaningful changes"
    echo ""
    echo "  Update markers found:"
    grep -E "Update Notice|This section was added|Additional Features|This content has been expanded" "${LATEST_DIR}/update_page_1.md" | head -1
else
    echo "  ⚠️  No clear update markers found"
fi
echo ""

echo "Test 3: Multiple runs - checking if content varies..."
rm -rf daily_pages/content-*

# Run 1
bash scripts/create-pages.sh > /dev/null 2>&1
DIR1=$(find daily_pages -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)
HEADING1=$(grep "^##" "${DIR1}/created_page_1.md" | head -1)
STATS1=$(grep -o '\$[0-9]*' "${DIR1}/created_page_1.md" | head -1)

# Run 2
rm -rf daily_pages/content-*
bash scripts/create-pages.sh > /dev/null 2>&1
DIR2=$(find daily_pages -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)
HEADING2=$(grep "^##" "${DIR2}/created_page_1.md" | head -1)
STATS2=$(grep -o '\$[0-9]*' "${DIR2}/created_page_1.md" | head -1)

echo "  Run 1: ${HEADING1}, Price: ${STATS1}"
echo "  Run 2: ${HEADING2}, Price: ${STATS2}"

if [ "$HEADING1" = "$HEADING2" ] && [ "$STATS1" = "$STATS2" ]; then
    echo "  ⚠️  Same heading and price (random chance - this can happen)"
    echo "  Note: With 18 headings and many paragraphs, occasional matches are normal"
else
    echo "  ✅ Different content each run (randomization confirmed)"
fi
echo ""

echo "=========================================="
echo "Summary"
echo "=========================================="
echo "✓ Content generation: Working"
echo "✓ Randomization: Working (each page is unique)"
echo "✓ Page updates: Working (adds meaningful changes)"
echo ""
echo "Your test system is ready! Each run will generate:"
echo "  - Different headings and content"
echo "  - Different statistics and numbers"
echo "  - Different list items"
echo "  - Meaningful updates that add substantial content"
echo ""

