#!/usr/bin/env bash

set -euo pipefail

TAG="${PLATFORM}-v${VERSION_NAME}+${BUILD_NUMBER}"

echo "Updating GitHub Release: ${TAG}"

# Fetch current release notes
CURRENT_BODY=$(gh release view "$TAG" --json body --jq '.body')

# Avoid appending twice
if echo "$CURRENT_BODY" | grep -q "## 🚀 Production"; then
  echo "Production section already exists. Skipping update."
  exit 0
fi

PROMOTION_DATE=$(date -u +"%Y-%m-%d %H:%M UTC")

NEW_BODY="${CURRENT_BODY}

---

## 🚀 Production

**Status:** Live on Google Play Production

**Promoted:** ${PROMOTION_DATE}
"

gh release edit "$TAG" \
  --notes "$NEW_BODY"

echo "✅ GitHub Release updated successfully."