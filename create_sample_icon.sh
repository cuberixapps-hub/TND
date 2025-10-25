#!/bin/bash

# Create a sample app icon using macOS built-in tools
echo "Creating sample app icon..."

# Create a 1024x1024 blue image with text using ImageMagick alternative
# Since we don't have ImageMagick, we'll create a simple colored square using sips

# First, let's create a simple image using Python without PIL
python3 << 'EOF'
import struct
import zlib

def create_png(width, height, rgb_color):
    """Create a simple PNG file with a solid color"""
    
    # PNG header
    header = b'\x89PNG\r\n\x1a\n'
    
    # IHDR chunk
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)
    ihdr_crc = zlib.crc32(b'IHDR' + ihdr_data)
    ihdr = struct.pack('>I', 13) + b'IHDR' + ihdr_data + struct.pack('>I', ihdr_crc)
    
    # IDAT chunk (image data)
    raw_data = b''
    for y in range(height):
        # Add filter byte (0 = None)
        raw_data += b'\x00'
        # Add RGB pixels
        for x in range(width):
            # Create a gradient effect
            r = min(255, rgb_color[0] + (y * 30 // height))
            g = max(0, rgb_color[1] - (y * 30 // height))
            b = max(0, rgb_color[2] - (y * 50 // height))
            raw_data += struct.pack('BBB', r, g, b)
    
    compressed_data = zlib.compress(raw_data)
    idat_crc = zlib.crc32(b'IDAT' + compressed_data)
    idat = struct.pack('>I', len(compressed_data)) + b'IDAT' + compressed_data + struct.pack('>I', idat_crc)
    
    # IEND chunk
    iend_crc = zlib.crc32(b'IEND')
    iend = struct.pack('>I', 0) + b'IEND' + struct.pack('>I', iend_crc)
    
    return header + ihdr + idat + iend

# Create a 1024x1024 blue gradient image
width, height = 1024, 1024
rgb_color = (0, 180, 255)  # Light blue

png_data = create_png(width, height, rgb_color)

with open('app_icon_temp.png', 'wb') as f:
    f.write(png_data)

print("✅ Created temporary blue gradient image")
EOF

# Now let's add text using Core Graphics via a small Swift script
cat > add_text.swift << 'EOF'
import Cocoa
import CoreGraphics

// Load the base image
guard let baseImage = NSImage(contentsOfFile: "app_icon_temp.png") else {
    print("Failed to load base image")
    exit(1)
}

// Create a new image with text
let size = NSSize(width: 1024, height: 1024)
let newImage = NSImage(size: size)

newImage.lockFocus()

// Draw the base image
baseImage.draw(in: NSRect(origin: .zero, size: size))

// Set up text attributes
let attributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.boldSystemFont(ofSize: 150),
    .foregroundColor: NSColor.white,
    .strokeColor: NSColor(red: 0, green: 0.4, blue: 0.6, alpha: 1.0),
    .strokeWidth: -8.0
]

// Draw text
let texts = ["TRUTH", "OR", "DARE"]
var yOffset: CGFloat = 150

for text in texts {
    let attributedString = NSAttributedString(string: text, attributes: attributes)
    let textSize = attributedString.size()
    let textRect = NSRect(
        x: (size.width - textSize.width) / 2,
        y: size.height - yOffset - textSize.height,
        width: textSize.width,
        height: textSize.height
    )
    attributedString.draw(in: textRect)
    yOffset += textSize.height + 30
}

// Draw a simple bottle shape
let bottleColor = NSColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0)
bottleColor.setFill()

// Bottle body
let bottleRect = NSRect(x: 362, y: 200, width: 300, height: 400)
let bottlePath = NSBezierPath(roundedRect: bottleRect, xRadius: 50, yRadius: 50)
bottlePath.fill()

// Bottle neck
let neckRect = NSRect(x: 452, y: 580, width: 120, height: 150)
NSBezierPath(rect: neckRect).fill()

// Bottle cap
let capColor = NSColor(red: 0.8, green: 0.6, blue: 0.2, alpha: 1.0)
capColor.setFill()
let capRect = NSRect(x: 442, y: 710, width: 140, height: 60)
let capPath = NSBezierPath(roundedRect: capRect, xRadius: 20, yRadius: 20)
capPath.fill()

newImage.unlockFocus()

// Save the image
if let tiffData = newImage.tiffRepresentation,
   let bitmapImage = NSBitmapImageRep(data: tiffData),
   let pngData = bitmapImage.representation(using: .png, properties: [:]) {
    try? pngData.write(to: URL(fileURLWithPath: "app_icon.png"))
    print("✅ Sample app icon created: app_icon.png")
} else {
    print("Failed to save image")
    exit(1)
}
EOF

# Compile and run the Swift script
swiftc add_text.swift -o add_text
./add_text

# Clean up temporary files
rm -f app_icon_temp.png add_text.swift add_text

echo "Sample icon created successfully!"
echo "You can now run: ./generate_icons_macos.sh app_icon.png"
echo ""
echo "Remember to replace app_icon.png with your actual icon later!"
