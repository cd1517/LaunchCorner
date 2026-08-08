#!/bin/bash
set -e

echo "🚀 Building LaunchCorner Universal 2 Binary (Apple Silicon + Intel)..."

# Ensure output directory exists
mkdir -p build

# Clean and archive build
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
    echo "📦 Packaging LaunchCorner.app into LaunchCorner.zip..."
    cd build/DerivedData/Build/Products/Release
    zip -r -9 "../../../../../build/LaunchCorner.zip" "LaunchCorner.app"
    cd - > /dev/null
    
    echo "✅ Release build successful!"
    echo "📂 Artifact created at: build/LaunchCorner.zip"
    file "build/DerivedData/Build/Products/Release/LaunchCorner.app/Contents/MacOS/LaunchCorner"
else
    echo "❌ Build failed: LaunchCorner.app not found."
    exit 1
fi
