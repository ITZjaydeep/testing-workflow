#!/usr/bin/env bash

set -Eeuo pipefail

########################################
# Required Environment Variables
########################################
#
# VERSION_NAME
# VERSION_CODE
# RELEASE_NOTES
# PLAY_STORE_LINK
#
########################################

if [[ -z "${VERSION_NAME:-}" ]]; then
  echo "❌ VERSION_NAME is missing"
  exit 1
fi

if [[ -z "${VERSION_CODE:-}" ]]; then
  echo "❌ VERSION_CODE is missing"
  exit 1
fi

if [[ -z "${RELEASE_NOTES:-}" ]]; then
  RELEASE_NOTES="No release notes provided."
fi

PLAY_STORE_LINK="${PLAY_STORE_LINK:-Not Available}"

TAG="android-v${VERSION_NAME}-${VERSION_CODE}"

TITLE="Android ${VERSION_NAME} (${VERSION_CODE})"

WORKFLOW_URL="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"

COMMIT_URL="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}"

DATE=$(date -u +"%d %b %Y %H:%M UTC")

cat <<EOF > release_notes.md
# 🚀 Android Internal Testing Release

---

## 📦 Release

| Item | Value |
|------|-------|
| Version Name | ${VERSION_NAME} |
| Version Code | ${VERSION_CODE} |
| Environment | Internal Testing |
| Status | ✅ Successful |
| Released At | ${DATE} |

---

## 👨‍💻 Source

| Item | Value |
|------|-------|
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

### Google Play Internal Testing

${PLAY_STORE_LINK}

EOF

echo "Creating GitHub Release..."

gh release create "${TAG}" \
    --title "${TITLE}" \
    --notes-file release_notes.md

echo ""
echo "======================================="
echo "✅ GitHub Release Created Successfully"
echo "======================================="
echo "Tag      : ${TAG}"
echo "Version  : ${VERSION_NAME}"
echo "Build    : ${VERSION_CODE}"
echo ""