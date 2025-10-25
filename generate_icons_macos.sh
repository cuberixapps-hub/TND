#!/bin/bash

# App Icon Generator Script for macOS using sips
# This script generates all required app icon sizes from a single source image
# Usage: ./generate_icons_macos.sh source_icon.png

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

echo "Generating app icons from: $SOURCE_ICON"

# iOS Icons Directory
IOS_DIR="ios/Runner/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$IOS_DIR"

# Function to resize image using sips
resize_icon() {
    local input=$1
    local size=$2
    local output=$3
    sips -z $size $size "$input" --out "$output" >/dev/null 2>&1
}

# Generate iOS Icons
echo "Generating iOS icons..."
resize_icon "$SOURCE_ICON" 20 "$IOS_DIR/Icon-App-20x20@1x.png"
resize_icon "$SOURCE_ICON" 40 "$IOS_DIR/Icon-App-20x20@2x.png"
resize_icon "$SOURCE_ICON" 60 "$IOS_DIR/Icon-App-20x20@3x.png"
resize_icon "$SOURCE_ICON" 29 "$IOS_DIR/Icon-App-29x29@1x.png"
resize_icon "$SOURCE_ICON" 58 "$IOS_DIR/Icon-App-29x29@2x.png"
resize_icon "$SOURCE_ICON" 87 "$IOS_DIR/Icon-App-29x29@3x.png"
resize_icon "$SOURCE_ICON" 40 "$IOS_DIR/Icon-App-40x40@1x.png"
resize_icon "$SOURCE_ICON" 80 "$IOS_DIR/Icon-App-40x40@2x.png"
resize_icon "$SOURCE_ICON" 120 "$IOS_DIR/Icon-App-40x40@3x.png"
resize_icon "$SOURCE_ICON" 120 "$IOS_DIR/Icon-App-60x60@2x.png"
resize_icon "$SOURCE_ICON" 180 "$IOS_DIR/Icon-App-60x60@3x.png"
resize_icon "$SOURCE_ICON" 76 "$IOS_DIR/Icon-App-76x76@1x.png"
resize_icon "$SOURCE_ICON" 152 "$IOS_DIR/Icon-App-76x76@2x.png"
resize_icon "$SOURCE_ICON" 167 "$IOS_DIR/Icon-App-83.5x83.5@2x.png"
resize_icon "$SOURCE_ICON" 1024 "$IOS_DIR/Icon-App-1024x1024@1x.png"

# Android Icons Directories
ANDROID_BASE="android/app/src/main/res"
mkdir -p "$ANDROID_BASE/mipmap-mdpi"
mkdir -p "$ANDROID_BASE/mipmap-hdpi"
mkdir -p "$ANDROID_BASE/mipmap-xhdpi"
mkdir -p "$ANDROID_BASE/mipmap-xxhdpi"
mkdir -p "$ANDROID_BASE/mipmap-xxxhdpi"

# Generate Android Icons
echo "Generating Android icons..."
resize_icon "$SOURCE_ICON" 48 "$ANDROID_BASE/mipmap-mdpi/ic_launcher.png"
resize_icon "$SOURCE_ICON" 72 "$ANDROID_BASE/mipmap-hdpi/ic_launcher.png"
resize_icon "$SOURCE_ICON" 96 "$ANDROID_BASE/mipmap-xhdpi/ic_launcher.png"
resize_icon "$SOURCE_ICON" 144 "$ANDROID_BASE/mipmap-xxhdpi/ic_launcher.png"
resize_icon "$SOURCE_ICON" 192 "$ANDROID_BASE/mipmap-xxxhdpi/ic_launcher.png"

echo "✅ Icon generation complete!"
echo ""
echo "Next steps:"
echo "1. Run 'flutter clean'"
echo "2. Run 'flutter pub get'"
echo "3. Rebuild your app"
echo ""
echo "iOS icons generated in: $IOS_DIR"
echo "Android icons generated in: $ANDROID_BASE/mipmap-*/"
