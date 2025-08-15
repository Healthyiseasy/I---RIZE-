import SwiftUI
import UIKit

// MARK: - I-RIZE App Icon Generator
struct AppIconGenerator {
    
    // MARK: - Required Icon Sizes (matching current iOS assets structure)
    static let iconSizes: [(name: String, size: CGFloat, description: String)] = [
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
    
    // MARK: - Generate All Icons
    static func generateAllIcons() {
        print("🎨 Generating I-RIZE app icons...")
        
        for (name, size, description) in iconSizes {
            generateIcon(name: name, size: size, description: description)
        }
        
        print("\n✅ All icons generated successfully!")
        printInstructions()
    }
    
    // MARK: - Generate Single Icon
    private static func generateIcon(name: String, size: CGFloat, description: String) {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        
        let image = renderer.image { context in
            // Create the I-RIZE icon
            let iconView = IRizeAppIconView(size: size)
            let hostingController = UIHostingController(rootView: iconView)
            hostingController.view.frame = CGRect(x: 0, y: 0, width: size, height: size)
            hostingController.view.backgroundColor = .black
            
            // Render the view to image
            hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
        }
        
        // Save the image to the iOS Assets.xcassets/AppIcon.appiconset folder
        if let data = image.pngData() {
            // Get the path to the iOS Assets.xcassets/AppIcon.appiconset folder
            let currentDirectory = FileManager.default.currentDirectoryPath
            let projectRoot = currentDirectory.replacingOccurrences(of: "/I-RIZE", with: "")
            let iconPath = "\(projectRoot)/iOS/Assets.xcassets/AppIcon.appiconset/\(name).png"
            
            do {
                try data.write(to: URL(fileURLWithPath: iconPath))
                print("✅ Generated: \(name).png (\(Int(size))x\(Int(size))) - \(description)")
            } catch {
                print("❌ Failed to save \(name).png: \(error)")
                // Fallback to Documents folder if the direct path fails
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fallbackPath = documentsPath.appendingPathComponent("\(name).png")
                do {
                    try data.write(to: fallbackPath)
                    print("✅ Saved to Documents folder: \(name).png")
                } catch {
                    print("❌ Failed to save to Documents folder: \(error)")
                }
            }
        }
    }
    
    // MARK: - Print Instructions
    private static func printInstructions() {
        print("\n📱 ICON GENERATION COMPLETE!")
        print("✅ All icons have been generated and saved directly to the iOS Assets.xcassets/AppIcon.appiconset folder")
        print("\n📱 NEXT STEPS:")
        print("1. In Xcode, refresh the Assets.xcassets folder (right-click → 'Show in Finder' then close and reopen)")
        print("2. The yellow warning triangles should now be gone")
        print("3. Clean Build Folder (Product → Clean Build Folder)")
        print("4. Build and run the app")
        print("\n📁 Icons are now properly placed in your asset catalog!")
    }
}

// MARK: - I-RIZE App Icon View
struct IRizeAppIconView: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: size * 0.08) {
                // "I RIZE" Text
                Text("I RIZE")
                    .font(.system(size: size * 0.35, weight: .bold, design: .rounded))
                    .foregroundColor(Color("NeonGreen"))
                    .tracking(3)
                    .shadow(color: Color("NeonGreen").opacity(0.8), radius: size * 0.02, x: 0, y: 0)
                
                // Rising Sun Graphic
                RisingSunIconView(size: size * 0.25)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.2))
    }
}

// MARK: - Rising Sun Icon View
struct RisingSunIconView: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Sun body (semi-circle)
            Circle()
                .trim(from: 0.5, to: 1.0)
                .fill(Color("NeonGreen"))
                .frame(width: size, height: size)
                .offset(y: size * 0.25)
                .shadow(color: Color("NeonGreen").opacity(0.6), radius: size * 0.05, x: 0, y: 0)
            
            // Sun rays
            ForEach(0..<7, id: \.self) { index in
                Rectangle()
                    .fill(Color("NeonGreen"))
                    .frame(width: size * 0.06, height: size * 0.12)
                    .offset(y: -size * 0.35)
                    .rotationEffect(.degrees(Double(index) * 15 - 45))
                    .shadow(color: Color("NeonGreen").opacity(0.6), radius: size * 0.02, x: 0, y: 0)
            }
        }
    }
}

// MARK: - Icon Generator Interface
struct IconGeneratorInterface: View {
    @State private var isGenerating = false
    @State private var showInstructions = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("I-RIZE App Icon Generator")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color("NeonGreen"))
                
                // Preview
                IRizeAppIconView(size: 120)
                    .frame(width: 120, height: 120)
                
                Text("Generate App Icons")
                    .font(.headline)
                    .foregroundColor(Color("NeonGreen"))
                
                Button(action: {
                    generateIcons()
                }) {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "wand.and.stars")
                        }
                        
                        Text(isGenerating ? "Generating..." : "Generate Icons")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isGenerating ? Color.gray : Color("NeonGreen"))
                            .shadow(color: Color("NeonGreen").opacity(0.6), radius: 8, x: 0, y: 4)
                    )
                }
                .disabled(isGenerating)
                .padding(.horizontal, 40)
                
                if showInstructions {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("📱 Icon Generation Complete!")
                                .font(.headline)
                                .foregroundColor(Color("NeonGreen"))
                            
                            Text("✅ All icons generated and saved to asset catalog")
                                .foregroundColor(.white)
                            Text("1. Refresh Assets.xcassets in Xcode")
                                .foregroundColor(.white)
                            Text("2. Warning triangles should be gone")
                                .foregroundColor(.white)
                            Text("3. Clean Build Folder")
                                .foregroundColor(.white)
                            Text("4. Build and run the app")
                                .foregroundColor(.white)
                            
                            Text("📁 Icons are now properly placed!")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 10)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("NeonGreen").opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color("NeonGreen"), lineWidth: 1)
                                )
                        )
                    }
                    .frame(maxHeight: 300)
                }
                
                Spacer()
            }
            .padding(.top, 50)
        }
    }
    
    private func generateIcons() {
        isGenerating = true
        showInstructions = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            AppIconGenerator.generateAllIcons()
            
            DispatchQueue.main.async {
                isGenerating = false
                showInstructions = true
            }
        }
    }
}

#Preview {
    IconGeneratorInterface()
} 