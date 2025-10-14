#!/bin/bash

set -e

CREATED_COUNT=$1
UPDATED_COUNT=$2
DELETED_COUNT=$3
CREATED_FILES=$4
UPDATED_FILES=$5
DELETED_FILES=$6

TODAY=$(date +%d.%m.%y)
CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S')
TOTAL=$((CREATED_COUNT + UPDATED_COUNT + DELETED_COUNT))

cat > stats.md << EOF
---
layout: page
title: "Stats ${TODAY}"
---

# Content Management Statistics

**Date**: ${TODAY}

## Summary

- **Files Created**: ${CREATED_COUNT}
- **Files Updated**: ${UPDATED_COUNT}  
- **Files Deleted**: ${DELETED_COUNT}
- **Total Operations**: ${TOTAL}

## Created Files

${CREATED_FILES}

## Updated Files

${UPDATED_FILES}

## Deleted Files

${DELETED_FILES}

---
*Generated: ${CURRENT_TIME}*
EOF

echo "Statistics generated: stats.md"

