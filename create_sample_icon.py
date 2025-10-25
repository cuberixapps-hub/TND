#!/usr/bin/env python3

from PIL import Image, ImageDraw, ImageFont
import os

# Create a 1024x1024 image with a blue gradient background
width, height = 1024, 1024
image = Image.new('RGB', (width, height))
draw = ImageDraw.Draw(image)

# Create a gradient background (similar to the Truth or Dare icon)
for y in range(height):
    # Gradient from light blue to darker blue
    r = int(0 + (30 * y / height))
    g = int(180 - (30 * y / height))
    b = int(255 - (50 * y / height))
    draw.rectangle([(0, y), (width, y+1)], fill=(r, g, b))

# Draw a bottle shape (simplified)
bottle_color = (50, 200, 50)  # Green
bottle_x = width // 2
bottle_y = height // 2

# Bottle body
body_width = 300
body_height = 500
body_left = bottle_x - body_width // 2
body_top = bottle_y - body_height // 4
draw.rounded_rectangle(
    [(body_left, body_top), (body_left + body_width, body_top + body_height)],
    radius=50,
    fill=bottle_color
)

# Bottle neck
neck_width = 120
neck_height = 200
neck_left = bottle_x - neck_width // 2
neck_top = body_top - neck_height + 50
draw.rectangle(
    [(neck_left, neck_top), (neck_left + neck_width, neck_top + neck_height)],
    fill=bottle_color
)

# Bottle cap
cap_width = 140
cap_height = 60
cap_left = bottle_x - cap_width // 2
cap_top = neck_top - cap_height + 20
draw.rounded_rectangle(
    [(cap_left, cap_top), (cap_left + cap_width, cap_top + cap_height)],
    radius=20,
    fill=(200, 150, 50)  # Golden/brown cap
)

# Add text
try:
    # Try to use a system font
    font_size = 120
    font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
except:
    # Fallback to default font
    font = ImageFont.load_default()

# Draw "TRUTH OR DARE" text
text_lines = ["TRUTH", "OR", "DARE"]
text_color = (255, 255, 255)
text_outline_color = (0, 100, 150)

y_offset = 100
for line in text_lines:
    # Get text size
    bbox = draw.textbbox((0, 0), line, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    # Center the text
    text_x = (width - text_width) // 2
    text_y = y_offset
    
    # Draw text outline
    for dx in [-3, -2, -1, 0, 1, 2, 3]:
        for dy in [-3, -2, -1, 0, 1, 2, 3]:
            if dx != 0 or dy != 0:
                draw.text((text_x + dx, text_y + dy), line, font=font, fill=text_outline_color)
    
    # Draw main text
    draw.text((text_x, text_y), line, font=font, fill=text_color)
    
    y_offset += text_height + 20

# Save the image
image.save('app_icon.png', 'PNG')
print("✅ Sample app icon created: app_icon.png")
print("Size: 1024x1024 pixels")
print("You can now run: ./generate_icons_macos.sh app_icon.png")
