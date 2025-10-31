#!/bin/bash

set -e

cd "$(dirname "$0")/.."

echo "=== Starting Content Management ==="
echo ""

echo "Step 1: Updating pages with update_ prefix from previous run..."
UPDATED_OUTPUT=$(bash scripts/update-pages.sh)
UPDATED_COUNT=$(echo "${UPDATED_OUTPUT}" | tail -1)
UPDATED_FILES=$(echo "${UPDATED_OUTPUT}" | grep "Updated:" | sed 's/Updated: /- /' || echo "- None")
if [ -z "${UPDATED_FILES}" ] || [ "${UPDATED_FILES}" = "- " ]; then
    UPDATED_FILES="- None"
fi
echo "Updated ${UPDATED_COUNT} pages"
echo ""

echo "Step 2: Deleting files with delete_ prefix from previous run..."
DELETED_OUTPUT=$(bash scripts/delete-pages.sh)
DELETED_COUNT=$(echo "${DELETED_OUTPUT}" | tail -1)
DELETED_FILES=$(echo "${DELETED_OUTPUT}" | grep "Deleted:" | sed 's/Deleted: /- /' || echo "- None")
if [ -z "${DELETED_FILES}" ] || [ "${DELETED_FILES}" = "- " ]; then
    DELETED_FILES="- None"
fi
echo "Deleted ${DELETED_COUNT} files"
echo ""

echo "Step 3: Creating new pages (created_, update_, delete_)..."
CREATED_OUTPUT=$(bash scripts/create-pages.sh)
CREATED_COUNT=$(echo "${CREATED_OUTPUT}" | tail -1)
CREATED_FILES=$(echo "${CREATED_OUTPUT}" | grep "Created:" | sed 's/Created: /- /' || echo "- None")
if [ -z "${CREATED_FILES}" ] || [ "${CREATED_FILES}" = "- " ]; then
    CREATED_FILES="- None"
fi
echo "Created ${CREATED_COUNT} files"
echo ""

echo "Step 4: Generating statistics..."
bash scripts/generate-stats.sh "${CREATED_COUNT}" "${UPDATED_COUNT}" "${DELETED_COUNT}" "${CREATED_FILES}" "${UPDATED_FILES}" "${DELETED_FILES}"
echo ""

echo "=== Content Management Completed ==="
echo "Created: ${CREATED_COUNT}, Updated: ${UPDATED_COUNT}, Deleted: ${DELETED_COUNT}"

