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

echo "Step 2: Deleting files (disabled)..."
DELETED_COUNT=0
DELETED_FILES="- None"
echo "Deleted ${DELETED_COUNT} files"
echo ""

echo "Step 3: Creating new pages (created_, update_)..."
CREATED_OUTPUT=$(bash scripts/create-pages.sh)
CREATED_COUNT=$(echo "${CREATED_OUTPUT}" | tail -1)
CREATED_FILES=$(echo "${CREATED_OUTPUT}" | grep "Created:" | sed 's/Created: /- /' || echo "- None")
if [ -z "${CREATED_FILES}" ] || [ "${CREATED_FILES}" = "- " ]; then
    CREATED_FILES="- None"
fi
echo "Created ${CREATED_COUNT} files"
echo ""

echo "Step 3a: Checking for files that should be classified as Modified (same title in previous revision)..."
# Get the current revision directory (most recent)
CURRENT_DIR=$(find daily_pages -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)
# Get the previous revision directory (second most recent) - compare against previous revision specifically
PREV_DIR=$(find daily_pages -mindepth 1 -maxdepth 1 -type d | sort | tail -n 2 | head -n 1)

# Extract created file paths and check their titles
TRULY_NEW_FILES=""
MODIFIED_FROM_NEW_FILES=""
TRULY_NEW_COUNT=0
MODIFIED_FROM_NEW_COUNT=0

if [ -n "${CREATED_FILES}" ] && [ "${CREATED_FILES}" != "- None" ] && [ -n "${PREV_DIR}" ] && [ "${PREV_DIR}" != "${CURRENT_DIR}" ]; then
    while IFS= read -r file_line; do
        if [ -z "${file_line}" ] || [ "${file_line}" = "- None" ]; then
            continue
        fi
        # Extract file path (remove "- " prefix)
        file_path=$(echo "${file_line}" | sed 's/^- //')
        if [ ! -f "${file_path}" ]; then
            continue
        fi
        # Extract title from front matter
        title=$(grep -E '^title:' "${file_path}" | sed -E 's/^title: "(.+)"$/\1/' | head -1)
        if [ -z "${title}" ]; then
            # If no title found, treat as new
            TRULY_NEW_FILES="${TRULY_NEW_FILES}${file_line}\n"
            TRULY_NEW_COUNT=$((TRULY_NEW_COUNT + 1))
            continue
        fi
        # Check if this title exists in the previous revision directory
        title_found_in_prev=false
        if [ -d "${PREV_DIR}" ]; then
            for prev_file in "${PREV_DIR}"/*.md; do
                if [ ! -f "${prev_file}" ]; then
                    continue
                fi
                prev_title=$(grep -E '^title:' "${prev_file}" | sed -E 's/^title: "(.+)"$/\1/' | head -1)
                if [ "${prev_title}" = "${title}" ]; then
                    title_found_in_prev=true
                    break
                fi
            done
        fi
        # Classify based on whether title was found in previous revision
        if [ "${title_found_in_prev}" = "true" ]; then
            MODIFIED_FROM_NEW_FILES="${MODIFIED_FROM_NEW_FILES}${file_line}\n"
            MODIFIED_FROM_NEW_COUNT=$((MODIFIED_FROM_NEW_COUNT + 1))
        else
            TRULY_NEW_FILES="${TRULY_NEW_FILES}${file_line}\n"
            TRULY_NEW_COUNT=$((TRULY_NEW_COUNT + 1))
        fi
    done <<< "${CREATED_FILES}"
else
    # If no previous revision or no created files, keep as-is
    TRULY_NEW_COUNT=${CREATED_COUNT}
fi

# Update counts and file lists
CREATED_COUNT=${TRULY_NEW_COUNT}
UPDATED_COUNT=$((UPDATED_COUNT + MODIFIED_FROM_NEW_COUNT))

# Format file lists
if [ ${TRULY_NEW_COUNT} -eq 0 ]; then
    CREATED_FILES="- None"
else
    CREATED_FILES=$(echo -e "${TRULY_NEW_FILES}" | grep -v '^$' || echo "- None")
fi

if [ ${MODIFIED_FROM_NEW_COUNT} -gt 0 ]; then
    MODIFIED_FILES_LIST=$(echo -e "${MODIFIED_FROM_NEW_FILES}" | grep -v '^$' || echo "")
    if [ -n "${MODIFIED_FILES_LIST}" ]; then
        if [ "${UPDATED_FILES}" = "- None" ]; then
            UPDATED_FILES="${MODIFIED_FILES_LIST}"
        else
            UPDATED_FILES="${UPDATED_FILES}"$'\n'"${MODIFIED_FILES_LIST}"
        fi
    fi
fi

if [ -z "${UPDATED_FILES}" ] || [ "${UPDATED_FILES}" = "- " ]; then
    UPDATED_FILES="- None"
fi

if [ ${MODIFIED_FROM_NEW_COUNT} -gt 0 ]; then
    echo "Reclassified ${MODIFIED_FROM_NEW_COUNT} files from Created to Modified (same title in previous revision)"
    echo ""
fi

echo "Step 4: Generating statistics..."
bash scripts/generate-stats.sh "${CREATED_COUNT}" "${UPDATED_COUNT}" "${DELETED_COUNT}" "${CREATED_FILES}" "${UPDATED_FILES}" "${DELETED_FILES}"
echo ""

echo "=== Content Management Completed ==="
echo "Created: ${CREATED_COUNT}, Updated: ${UPDATED_COUNT}, Deleted: ${DELETED_COUNT}"

