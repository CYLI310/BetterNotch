#!/bin/bash

# BetterNotch Build Script
# This script helps build and run BetterNotch

set -e

echo "🚀 Building BetterNotch..."
echo ""

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode command line tools not found"
    echo "Please install Xcode from the App Store"
    exit 1
fi

# Navigate to project directory
cd "$(dirname "$0")"

# Clean build folder
echo "🧹 Cleaning build folder..."
rm -rf build/

# Build the project
echo "🔨 Building project..."
xcodebuild -project BetterNotch.xcodeproj \
    -scheme BetterNotch \
    -configuration Debug \
    -derivedDataPath build \
    build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "📦 App location: build/Build/Products/Debug/BetterNotch.app"
    echo ""
    echo "To run the app:"
    echo "  open build/Build/Products/Debug/BetterNotch.app"
    echo ""
else
    echo ""
    echo "❌ Build failed. Please check the errors above."
    exit 1
fi
