#!/bin/bash

# App Icon Generator Script
# This script generates all required app icon sizes from a single source image
# Usage: ./generate_icons.sh source_icon.png

if [ -z "$1" ]; then
    echo "Usage: $0 <source_icon.png>"
    echo "Please provide a source icon file (recommended: 1024x1024 PNG)"
    exit 1
fi

SOURCE_ICON="$1"

if [ ! -f "$SOURCE_ICON" ]; then
    echo "Error: Source icon file not found: $SOURCE_ICON"
    exit 1
fi

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is not installed"
    echo "Install it using: brew install imagemagick"
    exit 1
fi

echo "Generating app icons from: $SOURCE_ICON"

# iOS Icons Directory
IOS_DIR="ios/Runner/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$IOS_DIR"

# Generate iOS Icons
echo "Generating iOS icons..."
convert "$SOURCE_ICON" -resize 20x20 "$IOS_DIR/Icon-App-20x20@1x.png"
convert "$SOURCE_ICON" -resize 40x40 "$IOS_DIR/Icon-App-20x20@2x.png"
convert "$SOURCE_ICON" -resize 60x60 "$IOS_DIR/Icon-App-20x20@3x.png"
convert "$SOURCE_ICON" -resize 29x29 "$IOS_DIR/Icon-App-29x29@1x.png"
convert "$SOURCE_ICON" -resize 58x58 "$IOS_DIR/Icon-App-29x29@2x.png"
convert "$SOURCE_ICON" -resize 87x87 "$IOS_DIR/Icon-App-29x29@3x.png"
convert "$SOURCE_ICON" -resize 40x40 "$IOS_DIR/Icon-App-40x40@1x.png"
convert "$SOURCE_ICON" -resize 80x80 "$IOS_DIR/Icon-App-40x40@2x.png"
convert "$SOURCE_ICON" -resize 120x120 "$IOS_DIR/Icon-App-40x40@3x.png"
convert "$SOURCE_ICON" -resize 120x120 "$IOS_DIR/Icon-App-60x60@2x.png"
convert "$SOURCE_ICON" -resize 180x180 "$IOS_DIR/Icon-App-60x60@3x.png"
convert "$SOURCE_ICON" -resize 76x76 "$IOS_DIR/Icon-App-76x76@1x.png"
convert "$SOURCE_ICON" -resize 152x152 "$IOS_DIR/Icon-App-76x76@2x.png"
convert "$SOURCE_ICON" -resize 167x167 "$IOS_DIR/Icon-App-83.5x83.5@2x.png"
convert "$SOURCE_ICON" -resize 1024x1024 "$IOS_DIR/Icon-App-1024x1024@1x.png"

# Android Icons Directories
ANDROID_BASE="android/app/src/main/res"
mkdir -p "$ANDROID_BASE/mipmap-mdpi"
mkdir -p "$ANDROID_BASE/mipmap-hdpi"
mkdir -p "$ANDROID_BASE/mipmap-xhdpi"
mkdir -p "$ANDROID_BASE/mipmap-xxhdpi"
mkdir -p "$ANDROID_BASE/mipmap-xxxhdpi"

# Generate Android Icons
echo "Generating Android icons..."
convert "$SOURCE_ICON" -resize 48x48 "$ANDROID_BASE/mipmap-mdpi/ic_launcher.png"
convert "$SOURCE_ICON" -resize 72x72 "$ANDROID_BASE/mipmap-hdpi/ic_launcher.png"
convert "$SOURCE_ICON" -resize 96x96 "$ANDROID_BASE/mipmap-xhdpi/ic_launcher.png"
convert "$SOURCE_ICON" -resize 144x144 "$ANDROID_BASE/mipmap-xxhdpi/ic_launcher.png"
convert "$SOURCE_ICON" -resize 192x192 "$ANDROID_BASE/mipmap-xxxhdpi/ic_launcher.png"

echo "✅ Icon generation complete!"
echo ""
echo "Next steps:"
echo "1. Run 'flutter clean'"
echo "2. Run 'flutter pub get'"
echo "3. Rebuild your app"
echo ""
echo "iOS icons generated in: $IOS_DIR"
echo "Android icons generated in: $ANDROID_BASE/mipmap-*/"
