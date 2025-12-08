#!/usr/bin/env python3
"""
Generate launch screen images for iOS
This script creates properly sized launch images from the app icon
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_gradient_background(width, height):
    """Create a gradient background from purple to blue"""
    img = Image.new('RGB', (width, height))
    draw = ImageDraw.Draw(img)
    
    # Create gradient from top to bottom
    for y in range(height):
        # Interpolate between purple (102, 51, 204) and blue (51, 102, 204)
        ratio = y / height
        r = int(102 + (51 - 102) * ratio)
        g = int(51 + (102 - 51) * ratio)
        b = int(204)
        draw.line([(0, y), (width, y)], fill=(r, g, b))
    
    return img

def create_launch_image(icon_path, output_path, size, scale):
    """Create a launch screen image with gradient background and centered icon"""
    # Calculate actual dimensions
    actual_width = size[0] * scale
    actual_height = size[1] * scale
    
    print(f"Creating launch image: {actual_width}x{actual_height} for {output_path}")
    
    # Create gradient background
    img = create_gradient_background(actual_width, actual_height)
    
    # Load and resize icon
    try:
        icon = Image.open(icon_path)
        icon = icon.convert('RGBA')
        
        # Resize icon to 1/3 of the height
        icon_size = int(actual_height * 0.25)
        icon = icon.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
        
        # Calculate position to center the icon
        icon_x = (actual_width - icon_size) // 2
        icon_y = (actual_height - icon_size) // 2 - int(actual_height * 0.1)
        
        # Paste icon onto background
        img.paste(icon, (icon_x, icon_y), icon)
        
    except Exception as e:
        print(f"Warning: Could not load icon: {e}")
    
    # Save the image
    img.save(output_path, 'PNG', quality=95, optimize=True)
    print(f"✓ Created: {output_path}")

def main():
    # Paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    icon_path = os.path.join(script_dir, 'app_icon.png')
    output_dir = os.path.join(script_dir, 'ios', 'Runner', 'Assets.xcassets', 'LaunchImage.imageset')
    
    # Check if icon exists
    if not os.path.exists(icon_path):
        print(f"Error: Icon not found at {icon_path}")
        return
    
    # Ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)
    
    print("\n🚀 Generating iOS Launch Screen Images...\n")
    
    # Create launch images at different scales
    # Using a reasonable base size that works for most devices
    base_size = (200, 200)
    
    images = [
        ('LaunchImage.png', base_size, 1),    # @1x
        ('LaunchImage@2x.png', base_size, 2),  # @2x
        ('LaunchImage@3x.png', base_size, 3),  # @3x
    ]
    
    for filename, size, scale in images:
        output_path = os.path.join(output_dir, filename)
        create_launch_image(icon_path, output_path, size, scale)
    
    print("\n✅ All launch images generated successfully!")
    print(f"📁 Location: {output_dir}")
    print("\n💡 Note: Launch images are now ready for use in Xcode.")

if __name__ == '__main__':
    main()


