#!/bin/bash
# Quick build script for APK (testing/distribution)

set -e

echo "Building release APK for testing..."
echo ""

# Check key.properties
if [ ! -f "android/key.properties" ]; then
    echo "⚠️  WARNING: android/key.properties not found!"
    echo "Building with debug keys. For production, set up key.properties."
    echo ""
fi

# Build
flutter clean
flutter pub get
flutter build apk --release

echo ""
echo "✅ Success! APK ready for testing:"
echo "📦 build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "To install on device:"
echo "  adb install build/app/outputs/flutter-apk/app-release.apk"
