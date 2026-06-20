#!/usr/bin/env bash

set -Eeuo pipefail

VERSION_NAME=""
VERSION_CODE=""

if [[ -f "android/app/build.gradle" ]]; then
    VERSION_NAME=$(grep -oP 'versionName\s*=?\s*"\K[^"]+' android/app/build.gradle | head -1)
    VERSION_CODE=$(grep -oP 'versionCode\s*=?\s*\K[0-9]+' android/app/build.gradle | head -1)

elif [[ -f "android/app/build.gradle.kts" ]]; then
    VERSION_NAME=$(grep -oP 'versionName\s*=\s*"\K[^"]+' android/app/build.gradle.kts | head -1)
    VERSION_CODE=$(grep -oP 'versionCode\s*=\s*\K[0-9]+' android/app/build.gradle.kts | head -1)

else
    echo "❌ Android build.gradle not found."
    exit 1
fi

VERSION_NAME=${VERSION_NAME:-0.0.0}
VERSION_CODE=${VERSION_CODE:-0}

echo "VERSION_NAME=$VERSION_NAME" >> "$GITHUB_ENV"
echo "BUILD_NUMBER=$VERSION_CODE" >> "$GITHUB_ENV"

echo "Android Version : $VERSION_NAME"
echo "Android Build   : $VERSION_CODE"