#!/bin/bash

# Script to bump version number
# Usage: ./bump_version.sh [major|minor|patch]

set -e

VERSION_FILE="version.txt"
PUBSPEC_FILE="pubspec.yaml"

# Check if version file exists
if [ ! -f "$VERSION_FILE" ]; then
    echo "1.0.0" > "$VERSION_FILE"
fi

# Read current version
CURRENT_VERSION=$(cat "$VERSION_FILE")

# Parse version components
IFS='.' read -r -a VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR="${VERSION_PARTS[0]}"
MINOR="${VERSION_PARTS[1]}"
PATCH="${VERSION_PARTS[2]}"

# Determine bump type (default to patch if not specified)
BUMP_TYPE="${1:-patch}"

# Bump the appropriate version component
case "$BUMP_TYPE" in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
    *)
        echo "Invalid bump type: $BUMP_TYPE"
        echo "Usage: $0 [major|minor|patch]"
        exit 1
        ;;
esac

# Create new version
NEW_VERSION="$MAJOR.$MINOR.$PATCH"

# Update version.txt
echo "$NEW_VERSION" > "$VERSION_FILE"

# Update pubspec.yaml
# Extract current build number from pubspec.yaml
CURRENT_BUILD=$(grep "^version:" "$PUBSPEC_FILE" | sed -E 's/^version: [0-9]+\.[0-9]+\.[0-9]+\+([0-9]+)$/\1/' || echo "1")

# If extraction failed (no build number found), default to 1
if [ -z "$CURRENT_BUILD" ] || [ "$CURRENT_BUILD" = "1" ]; then
    CURRENT_BUILD=1
fi

# Increment build number
NEW_BUILD=$((CURRENT_BUILD + 1))

# Update pubspec.yaml with new version and build number
sed -i "s/^version: .*/version: $NEW_VERSION+$NEW_BUILD/" "$PUBSPEC_FILE"

echo "Version bumped from $CURRENT_VERSION to $NEW_VERSION (build: $NEW_BUILD)"
echo "$NEW_VERSION"
