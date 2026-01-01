#!/bin/bash
# Build script for FuliTrack release builds

set -e  # Exit on error

echo "================================================"
echo "FuliTrack Release Build Script"
echo "================================================"
echo ""

# Check if key.properties exists
if [ ! -f "android/key.properties" ]; then
    echo "❌ ERROR: android/key.properties not found!"
    echo ""
    echo "Please create android/key.properties from the template:"
    echo "  cp android/key.properties.template android/key.properties"
    echo ""
    echo "Then edit it with your keystore details."
    echo "See PLAY_STORE_GUIDE.md for instructions on creating a keystore."
    exit 1
fi

echo "✅ Keystore configuration found"
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Run code generation if needed
if grep -q "build_runner" pubspec.yaml; then
    echo "🔨 Running code generation..."
    flutter pub run build_runner build --delete-conflicting-outputs
fi

# Build based on user choice
echo ""
echo "Select build type:"
echo "  1) Android App Bundle (AAB) - Recommended for Play Store"
echo "  2) APK - For testing or direct distribution"
echo "  3) Both AAB and APK"
echo ""
read -p "Enter choice (1-3): " choice

case $choice in
    1)
        echo ""
        echo "🏗️  Building Android App Bundle (AAB)..."
        flutter build appbundle --release
        echo ""
        echo "✅ Build complete!"
        echo "📦 Output: build/app/outputs/bundle/release/app-release.aab"
        ;;
    2)
        echo ""
        echo "🏗️  Building APK..."
        flutter build apk --release
        echo ""
        echo "✅ Build complete!"
        echo "📦 Output: build/app/outputs/flutter-apk/app-release.apk"
        ;;
    3)
        echo ""
        echo "🏗️  Building Android App Bundle (AAB)..."
        flutter build appbundle --release
        echo ""
        echo "🏗️  Building APK..."
        flutter build apk --release
        echo ""
        echo "✅ Both builds complete!"
        echo "📦 AAB: build/app/outputs/bundle/release/app-release.aab"
        echo "📦 APK: build/app/outputs/flutter-apk/app-release.apk"
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "================================================"
echo "Build process completed successfully! 🎉"
echo "================================================"
echo ""
echo "Next steps:"
echo "  • Test the release build on a physical device"
echo "  • Check app size and performance"
echo "  • Upload to Play Console for internal testing"
echo ""
