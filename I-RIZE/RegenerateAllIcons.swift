import Foundation
import AppKit

// Regenerate all I-RIZE app icons
print("🎨 Regenerating all I-RIZE app icons...")

// Icon sizes and names matching the asset catalog
let iconSizes: [(name: String, size: CGFloat, description: String)] = [
    // iPhone Icons
    ("Icon-Notify@2x", 40, "iPhone Notification 2x"),
    ("Icon-Notify@3x", 60, "iPhone Notification 3x"),
    ("Icon-Small@2x", 58, "iPhone Settings 2x"),
    ("Icon-Small@3x", 87, "iPhone Settings 3x"),
    ("Icon-40@2x", 80, "iPhone Spotlight 2x"),
    ("Icon-40@3x", 120, "iPhone Spotlight 3x"),
    ("Icon-60@2x", 120, "iPhone App 2x"),
    ("Icon-60@3x", 180, "iPhone App 3x"),
    
    // iPad Icons
    ("Icon-Notify@1x", 20, "iPad Notification 1x"),
    ("Icon-Notify@2x", 40, "iPad Notification 2x"),
    ("Icon-Small", 29, "iPad Settings 1x"),
    ("Icon-Small@2x", 58, "iPad Settings 2x"),
    ("Icon-40", 40, "iPad Spotlight 1x"),
    ("Icon-40@2x", 80, "iPad Spotlight 2x"),
    ("Icon-76", 76, "iPad App 1x"),
    ("Icon-76@2x", 152, "iPad App 2x"),
    ("Icon-83.5@2x", 167, "iPad Pro App 2x"),
    
    // App Store Icon
    ("Icon-1024", 1024, "App Store")
]

func generateIcon(name: String, size: CGFloat, description: String) {
    let image = NSImage(size: NSSize(width: size, height: size))
    
    image.lockFocus()
    
    // Black background
    NSColor.black.setFill()
    NSRect(x: 0, y: 0, width: size, height: size).fill()
    
    // "I RIZE" Text
    let text = "I RIZE"
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: size * 0.35, weight: .bold),
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
        let iconPath = "\(currentDirectory)/Assets.xcassets/AppIcon.appiconset/\(name).png"
        
        do {
            try pngData.write(to: URL(fileURLWithPath: iconPath))
            print("✅ Generated: \(name).png (\(Int(size))x\(Int(size))) - \(description)")
        } catch {
            print("❌ Failed to save \(name).png: \(error)")
        }
    } else {
        print("❌ Failed to generate PNG data for \(name)")
    }
}

// Generate all icons
for (name, size, description) in iconSizes {
    generateIcon(name: name, size: size, description: description)
}

print("\n✅ All icons regenerated successfully!")
        print("📁 Icons saved to main Assets.xcassets/AppIcon.appiconset/")
print("🔄 Refresh Xcode Assets.xcassets to see the changes")
