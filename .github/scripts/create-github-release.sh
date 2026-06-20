#!/usr/bin/env bash

set -Eeuo pipefail

########################################
# Required Environment Variables
#
# PLATFORM        -> android | ios
# VERSION_NAME
# BUILD_NUMBER
#
# Optional
# RELEASE_NOTES
# STORE_LINK
########################################

required=(
  PLATFORM
  VERSION_NAME
  BUILD_NUMBER
)

for var in "${required[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "❌ Missing required environment variable: ${var}"
    exit 1
  fi
done

PLATFORM=$(echo "$PLATFORM" | tr '[:upper:]' '[:lower:]')

if [[ "$PLATFORM" != "android" && "$PLATFORM" != "ios" ]]; then
  echo "❌ PLATFORM must be 'android' or 'ios'"
  exit 1
fi

RELEASE_NOTES="${RELEASE_NOTES:-No release notes provided.}"
STORE_LINK="${STORE_LINK:-Not Available}"

TAG="${PLATFORM}-v${VERSION_NAME}-${BUILD_NUMBER}"
TITLE="${PLATFORM^} ${VERSION_NAME} (${BUILD_NUMBER})"

WORKFLOW_URL="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"
COMMIT_URL="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}"

DATE=$(date -u +"%d %b %Y %H:%M UTC")

cat > release_notes.md <<EOF
# 🚀 ${TITLE}

---

## 📦 Release

| Item | Value |
|------|-------|
| Platform | ${PLATFORM^} |
| Version | ${VERSION_NAME} |
| Build | ${BUILD_NUMBER} |
| Status | ✅ Successful |
| Released At | ${DATE} |

---

## 👨‍💻 Source

| Item | Value |
|------|-------|
| Repository | ${GITHUB_REPOSITORY} |
| Branch | ${GITHUB_REF_NAME} |
| Commit | ${GITHUB_SHA} |
| Triggered By | ${GITHUB_ACTOR} |

---

## 📝 What's Changed

${RELEASE_NOTES}

---

## 🔗 Links

### GitHub Actions

${WORKFLOW_URL}

### Commit

${COMMIT_URL}

### Store

${STORE_LINK}
EOF

echo "========================================"
echo "Processing GitHub Release..."
echo "========================================"

echo "Creating release..."
    gh release create "$TAG" \
        --title "$TITLE" \
        --notes-file release_notes.md

    STATUS="Created"

echo ""
echo "========================================"
echo "✅ GitHub Release ${STATUS}"
echo "========================================"
echo "Platform    : ${PLATFORM}"
echo "Tag         : ${TAG}"
echo "Title       : ${TITLE}"
echo "Version     : ${VERSION_NAME}"
echo "Build       : ${BUILD_NUMBER}"
echo "Branch      : ${GITHUB_REF_NAME}"
echo "Commit      : ${GITHUB_SHA}"
echo "Workflow    : ${WORKFLOW_URL}"
echo "Store Link  : ${STORE_LINK}"
echo "========================================"