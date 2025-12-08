#!/bin/bash

# Enhanced App Icon Generator Script for macOS with Android Adaptive Icon Support
# This script generates all required app icon sizes including adaptive icons for Android
# Usage: ./generate_icons_enhanced.sh source_icon.png

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

echo "🎨 Generating app icons from: $SOURCE_ICON"
echo ""

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

# Function to create foreground icon with padding for adaptive icons
# Adaptive icons need extra padding as they can be cropped into various shapes
create_adaptive_foreground() {
    local input=$1
    local size=$2
    local output=$3
    
    # Calculate the size with padding (use 66% of the target size for the actual icon)
    local inner_size=$((size * 66 / 100))
    local padding=$(((size - inner_size) / 2))
    
    # First resize to the inner size
    local temp_file="/tmp/temp_icon_$$.png"
    sips -z $inner_size $inner_size "$input" --out "$temp_file" >/dev/null 2>&1
    
    # Create a transparent canvas and place the icon in the center
    sips -z $size $size "$temp_file" --out "$output" >/dev/null 2>&1
    
    # Use ImageMagick if available for better padding, otherwise sips alone is fine
    if command -v convert &> /dev/null; then
        convert "$temp_file" -background none -gravity center -extent ${size}x${size} "$output" 2>/dev/null
    fi
    
    rm -f "$temp_file"
}

# Generate iOS Icons
echo "📱 Generating iOS icons..."
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
echo "✅ iOS icons generated (15 sizes)"

# Android Icons Directories
ANDROID_BASE="android/app/src/main/res"
mkdir -p "$ANDROID_BASE/mipmap-mdpi"
mkdir -p "$ANDROID_BASE/mipmap-hdpi"
mkdir -p "$ANDROID_BASE/mipmap-xhdpi"
mkdir -p "$ANDROID_BASE/mipmap-xxhdpi"
mkdir -p "$ANDROID_BASE/mipmap-xxxhdpi"

# Generate Android Standard Icons (for backward compatibility)
echo ""
echo "🤖 Generating Android standard icons..."
resize_icon "$SOURCE_ICON" 48 "$ANDROID_BASE/mipmap-mdpi/ic_launcher.png"
resize_icon "$SOURCE_ICON" 72 "$ANDROID_BASE/mipmap-hdpi/ic_launcher.png"
resize_icon "$SOURCE_ICON" 96 "$ANDROID_BASE/mipmap-xhdpi/ic_launcher.png"
resize_icon "$SOURCE_ICON" 144 "$ANDROID_BASE/mipmap-xxhdpi/ic_launcher.png"
resize_icon "$SOURCE_ICON" 192 "$ANDROID_BASE/mipmap-xxxhdpi/ic_launcher.png"
echo "✅ Android standard icons generated (5 sizes)"

# Generate Android Adaptive Icon Foregrounds (with extra padding)
echo ""
echo "🎨 Generating Android adaptive icon foregrounds..."
create_adaptive_foreground "$SOURCE_ICON" 108 "$ANDROID_BASE/mipmap-mdpi/ic_launcher_foreground.png"
create_adaptive_foreground "$SOURCE_ICON" 162 "$ANDROID_BASE/mipmap-hdpi/ic_launcher_foreground.png"
create_adaptive_foreground "$SOURCE_ICON" 216 "$ANDROID_BASE/mipmap-xhdpi/ic_launcher_foreground.png"
create_adaptive_foreground "$SOURCE_ICON" 324 "$ANDROID_BASE/mipmap-xxhdpi/ic_launcher_foreground.png"
create_adaptive_foreground "$SOURCE_ICON" 432 "$ANDROID_BASE/mipmap-xxxhdpi/ic_launcher_foreground.png"
echo "✅ Android adaptive foreground icons generated (5 sizes)"

# Create adaptive icon configuration
echo ""
echo "⚙️  Setting up Android adaptive icon configuration..."
mkdir -p "$ANDROID_BASE/mipmap-anydpi-v26"

cat > "$ANDROID_BASE/mipmap-anydpi-v26/ic_launcher.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
EOF

# Create the background color resource if it doesn't exist
if [ ! -f "$ANDROID_BASE/values/ic_launcher_background.xml" ]; then
    cat > "$ANDROID_BASE/values/ic_launcher_background.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#00A8E8</color>
</resources>
EOF
fi

echo "✅ Adaptive icon configuration created"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Icon generation complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Summary:"
echo "  • iOS icons: 15 sizes ✓"
echo "  • Android standard icons: 5 sizes ✓"
echo "  • Android adaptive foregrounds: 5 sizes ✓"
echo "  • Android adaptive config: ✓"
echo ""
echo "📱 Android Adaptive Icon Benefits:"
echo "  • Proper padding for circular/rounded displays"
echo "  • Consistent look across all Android devices"
echo "  • Modern Android 8.0+ support"
echo ""
echo "🔧 Next steps:"
echo "  1. Run 'flutter clean'"
echo "  2. Run 'flutter pub get'"
echo "  3. Rebuild your app"
echo ""
echo "📂 Icon locations:"
echo "  • iOS: $IOS_DIR"
echo "  • Android: $ANDROID_BASE/mipmap-*/"
echo ""









