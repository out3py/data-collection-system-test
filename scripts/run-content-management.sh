#!/bin/bash

set -e

cd "$(dirname "$0")/.."

echo "=== Starting Content Management ==="
echo ""

echo "Step 1: Checking for updated pages from previous run..."
# Updates are now handled in generate-pages.sh, so just initialize
UPDATED_COUNT=0
UPDATED_FILES="- None"
echo "Updates will be processed in generation step"
echo ""

echo "Step 2: Deleting files (disabled)..."
DELETED_COUNT=0
DELETED_FILES="- None"
echo "Deleted ${DELETED_COUNT} files"
echo ""

echo "Step 3: Generating new and updated pages..."
CREATED_OUTPUT=$(bash scripts/generate-pages.sh)
CREATED_COUNT=$(echo "${CREATED_OUTPUT}" | tail -1 | tr -d ' ')
CREATED_FILES=$(echo "${CREATED_OUTPUT}" | grep "Created:" | sed 's/Created: /- /' || echo "- None")
UPDATED_FILES=$(echo "${CREATED_OUTPUT}" | grep "Updated:" | sed 's/Updated: /- /' || echo "- None")
UPDATED_COUNT=$(echo "${CREATED_OUTPUT}" | grep -c "Updated:" 2>/dev/null | tr -d ' ' || echo "0")
UPDATED_COUNT=${UPDATED_COUNT:-0}

if [ -z "${CREATED_FILES}" ] || [ "${CREATED_FILES}" = "- " ]; then
    CREATED_FILES="- None"
fi
if [ -z "${UPDATED_FILES}" ] || [ "${UPDATED_FILES}" = "- " ]; then
    UPDATED_FILES="- None"
fi

# Calculate new pages count (total - updated)
NEW_COUNT=$((CREATED_COUNT - UPDATED_COUNT))
echo "Generated ${CREATED_COUNT} files (Created: ${NEW_COUNT}, Updated: ${UPDATED_COUNT})"
echo ""

# Use counts directly from generation (no reclassification needed)
CREATED_COUNT=${NEW_COUNT}

echo "Step 4: Generating statistics..."
bash scripts/generate-stats.sh "${CREATED_COUNT}" "${UPDATED_COUNT}" "${DELETED_COUNT}" "${CREATED_FILES}" "${UPDATED_FILES}" "${DELETED_FILES}"
echo ""

echo "=== Content Management Completed ==="
echo "Created: ${CREATED_COUNT}, Updated: ${UPDATED_COUNT}, Deleted: ${DELETED_COUNT}"

