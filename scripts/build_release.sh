#!/bin/bash
set -e

echo "Building LaunchCorner Universal 2 Binary (Apple Silicon + Intel)..."

# Ensure output directory exists
mkdir -p build

# Clean and build release
xcodebuild clean -project LaunchCorner.xcodeproj -scheme LaunchCorner
xcodebuild build \
  -project LaunchCorner.xcodeproj \
  -scheme LaunchCorner \
  -configuration Release \
  -derivedDataPath build/DerivedData \
  ARCHS="arm64 x86_64" \
  ONLY_ACTIVE_ARCH=NO

# Locate built app
BUILT_APP="build/DerivedData/Build/Products/Release/LaunchCorner.app"

if [ -d "$BUILT_APP" ]; then
    if command -v create-dmg &> /dev/null; then
        echo "Generating LaunchCorner.dmg with create-dmg..."
        rm -f build/LaunchCorner.dmg
        create-dmg \
          --volname "LaunchCorner Installer" \
          --window-pos 200 120 \
          --window-size 600 400 \
          --icon-size 100 \
          --icon "LaunchCorner.app" 175 190 \
          --hide-extension "LaunchCorner.app" \
          --app-drop-link 425 190 \
          "build/LaunchCorner.dmg" \
          "$BUILT_APP"
    else
        echo "Error: create-dmg is required to generate LaunchCorner.dmg. Install it with: brew install create-dmg"
        exit 1
    fi
    
    echo "Release build successful!"
    echo "Artifact created at: build/LaunchCorner.dmg"
    ls -lh build/LaunchCorner.dmg
else
    echo "Build failed: LaunchCorner.app not found."
    exit 1
fi
