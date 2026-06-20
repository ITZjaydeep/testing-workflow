#!/usr/bin/env bash

set -Eeuo pipefail

INFO_PLIST=$(find ios -name Info.plist | head -1)

if [[ -z "$INFO_PLIST" ]]; then
    echo "❌ Info.plist not found."
    exit 1
fi

VERSION_NAME=$(/usr/libexec/PlistBuddy \
    -c "Print :CFBundleShortVersionString" \
    "$INFO_PLIST")

BUILD_NUMBER=$(/usr/libexec/PlistBuddy \
    -c "Print :CFBundleVersion" \
    "$INFO_PLIST")

echo "VERSION_NAME=$VERSION_NAME" >> "$GITHUB_ENV"
echo "BUILD_NUMBER=$BUILD_NUMBER" >> "$GITHUB_ENV"

echo "iOS Version : $VERSION_NAME"
echo "iOS Build   : $BUILD_NUMBER"