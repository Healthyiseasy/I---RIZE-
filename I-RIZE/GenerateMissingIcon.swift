import Foundation
import AppKit

// Generate just the missing App Store icon
print("🎨 Generating missing App Store icon (Icon-1024.png)...")

// Create a simple 1024x1024 icon
let size: CGFloat = 1024
let image = NSImage(size: NSSize(width: size, height: size))

image.lockFocus()

// Black background
NSColor.black.setFill()
NSRect(x: 0, y: 0, width: size, height: size).fill()

// Simple "I RIZE" text in white for now
let text = "I RIZE"
let attributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: size * 0.2, weight: .bold),
    .foregroundColor: NSColor.white
]

let textSize = text.size(withAttributes: attributes)
let textRect = NSRect(
    x: (size - textSize.width) / 2,
    y: (size - textSize.height) / 2,
    width: textSize.width,
    height: textSize.height
)

text.draw(in: textRect, withAttributes: attributes)

image.unlockFocus()

// Save the image
if let tiffData = image.tiffRepresentation,
   let bitmapImage = NSBitmapImageRep(data: tiffData),
   let pngData = bitmapImage.representation(using: .png, properties: [:]) {
    
    let currentDirectory = FileManager.default.currentDirectoryPath
    let projectRoot = currentDirectory.replacingOccurrences(of: "/I-RIZE", with: "")
    let iconPath = "\(projectRoot)/iOS/Assets.xcassets/AppIcon.appiconset/Icon-1024.png"
    
    do {
        try pngData.write(to: URL(fileURLWithPath: iconPath))
        print("✅ Generated: Icon-1024.png (1024x1024) - App Store")
        print("📁 Icon saved to: \(iconPath)")
    } catch {
        print("❌ Failed to save Icon-1024.png: \(error)")
    }
} else {
    print("❌ Failed to generate PNG data")
}
