#!/bin/bash

# SillyLoops - Quick Launch Script
# Runs the Flutter app directly (development mode)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🥁 SillyLoops - Quick Launch"
echo "============================"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo ""
    echo "Please install Flutter:"
    echo "  macOS: brew install --cask flutter"
    echo "  Or visit: https://docs.flutter.dev/get-started/install"
    exit 1
fi

# Show Flutter version
flutter --version
echo ""

# Get dependencies
echo "📥 Installing dependencies..."
flutter pub get
echo ""

# Check for available devices
echo "📱 Checking available devices..."
flutter devices
echo ""

# Ask user for target
echo "Select launch target:"
echo "  1) Chrome (Web)"
echo "  2) iOS Simulator"
echo "  3) Android Emulator"
echo "  4) Connected Device"
echo ""
read -p "Enter choice (1-4): " choice

case $choice in
    1)
        echo "🚀 Launching on Chrome..."
        flutter run -d chrome
        ;;
    2)
        echo "🚀 Launching on iOS Simulator..."
        flutter run -d ios
        ;;
    3)
        echo "🚀 Launching on Android Emulator..."
        flutter run -d android
        ;;
    4)
        echo "🚀 Launching on connected device..."
        flutter run
        ;;
    *)
        echo "Invalid choice. Defaulting to Chrome..."
        flutter run -d chrome
        ;;
esac
