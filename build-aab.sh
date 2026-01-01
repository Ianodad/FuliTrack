#!/bin/bash
# Quick build script for Android App Bundle (Play Store format)

set -e

echo "Building Android App Bundle for Play Store..."
echo ""

# Check key.properties
if [ ! -f "android/key.properties" ]; then
    echo "❌ ERROR: android/key.properties not found!"
    echo "Copy android/key.properties.template and configure it first."
    exit 1
fi

# Build
flutter clean
flutter pub get
flutter build appbundle --release

echo ""
echo "✅ Success! App Bundle ready for Play Store upload:"
echo "📦 build/app/outputs/bundle/release/app-release.aab"
