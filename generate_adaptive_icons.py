#!/usr/bin/env python3
"""
Enhanced App Icon Generator with proper Android Adaptive Icon support
Generates foreground layers with correct padding for adaptive icons
"""

import os
import sys
from PIL import Image, ImageDraw

def create_adaptive_foreground(source_path, output_path, size):
    """
    Create an adaptive icon foreground with proper padding.
    
    Android adaptive icons need padding because they can be displayed in
    various shapes (circle, rounded square, squircle) depending on the OEM.
    
    Safe zone: The inner 66% (2/3) of the icon should contain important content.
    This leaves 17% padding on each side.
    """
    # Open and resize the source image
    img = Image.open(source_path)
    img = img.convert('RGBA')  # Ensure RGBA mode for transparency
    
    # Calculate the safe zone size (66% of target size)
    safe_zone_size = int(size * 0.66)
    
    # Resize the source to fit in the safe zone
    img = img.resize((safe_zone_size, safe_zone_size), Image.Resampling.LANCZOS)
    
    # Create a new transparent canvas
    canvas = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    
    # Calculate position to center the resized image
    position = ((size - safe_zone_size) // 2, (size - safe_zone_size) // 2)
    
    # Paste the resized image onto the center of the canvas
    canvas.paste(img, position, img)
    
    # Save the result
    canvas.save(output_path, 'PNG', optimize=True)
    print(f"  ✓ Created {os.path.basename(output_path)} ({size}x{size})")

def generate_standard_icon(source_path, output_path, size):
    """Generate a standard icon by resizing"""
    img = Image.open(source_path)
    img = img.convert('RGBA')
    img = img.resize((size, size), Image.Resampling.LANCZOS)
    img.save(output_path, 'PNG', optimize=True)

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 generate_adaptive_icons.py <source_icon.png>")
        sys.exit(1)
    
    source_icon = sys.argv[1]
    
    if not os.path.exists(source_icon):
        print(f"Error: Source icon not found: {source_icon}")
        sys.exit(1)
    
    print(f"\n🎨 Generating Android adaptive icon foregrounds from: {source_icon}\n")
    
    # Android icon sizes for adaptive foregrounds (108dp units)
    android_sizes = {
        'mipmap-mdpi': 108,
        'mipmap-hdpi': 162,
        'mipmap-xhdpi': 216,
        'mipmap-xxhdpi': 324,
        'mipmap-xxxhdpi': 432,
    }
    
    android_base = "android/app/src/main/res"
    
    # Generate adaptive foregrounds
    print("🤖 Generating Android adaptive icon foregrounds...")
    for density, size in android_sizes.items():
        output_dir = os.path.join(android_base, density)
        os.makedirs(output_dir, exist_ok=True)
        
        foreground_path = os.path.join(output_dir, 'ic_launcher_foreground.png')
        create_adaptive_foreground(source_icon, foreground_path, size)
    
    print("\n✅ Adaptive icon foregrounds generated successfully!")
    print("\n📱 These icons will:")
    print("  • Display properly in circular shapes")
    print("  • Have proper padding for all Android devices")
    print("  • Look consistent across different manufacturers")
    print("\n💡 Tip: The icon content is placed in the safe 66% zone")
    print("         with 17% padding on all sides for adaptive clipping.\n")

if __name__ == '__main__':
    main()









