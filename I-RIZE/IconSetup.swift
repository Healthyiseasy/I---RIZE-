import SwiftUI
import UIKit

// MARK: - I-RIZE Icon Setup Helper
struct IconSetupHelper {
    
    static func generateAndSetupIcons() {
        print("🎨 Generating I-RIZE app icons...")
        
        // Generate all required icon sizes
        let iconSizes = [
            ("Icon-20@2x", 40),
            ("Icon-20@3x", 60),
            ("Icon-29@2x", 58),
            ("Icon-29@3x", 87),
            ("Icon-40@2x", 80),
            ("Icon-40@3x", 120),
            ("Icon-60@2x", 120),
            ("Icon-60@3x", 180),
            ("Icon-20@1x", 20),
            ("Icon-29@1x", 29),
            ("Icon-40@1x", 40),
            ("Icon-76@2x", 152),
            ("Icon-83.5@2x", 167),
            ("Icon-1024", 1024)
        ]
        
        for (name, size) in iconSizes {
            generateIcon(name: name, size: size)
        }
        
        printInstructions()
    }
    
    private static func generateIcon(name: String, size: CGFloat) {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        
        let image = renderer.image { context in
            // Create the I-RIZE icon
            let iconView = IRizeIconView(size: size)
            let hostingController = UIHostingController(rootView: iconView)
            hostingController.view.frame = CGRect(x: 0, y: 0, width: size, height: size)
            hostingController.view.backgroundColor = .black
            
            // Render the view to image
            hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
        }
        
        // Save the image
        if let data = image.pngData() {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let iconPath = documentsPath.appendingPathComponent("\(name).png")
            
            do {
                try data.write(to: iconPath)
                print("✅ Generated: \(name).png (\(Int(size))x\(Int(size)))")
            } catch {
                print("❌ Failed to save \(name).png: \(error)")
            }
        }
    }
    
    private static func printInstructions() {
        print("\n📱 HOW TO ADD ICONS TO XCODE:")
        print("1. Open Xcode")
        print("2. In the Project Navigator, click on 'Assets.xcassets'")
        print("3. Click on 'AppIcon'")
        print("4. Drag and drop the generated PNG files from your Documents folder:")
        print("   - Icon-20@2x.png → iPhone Settings 2x")
        print("   - Icon-20@3x.png → iPhone Settings 3x")
        print("   - Icon-29@2x.png → iPhone Settings 2x")
        print("   - Icon-29@3x.png → iPhone Settings 3x")
        print("   - Icon-40@2x.png → iPhone Spotlight 2x")
        print("   - Icon-40@3x.png → iPhone Spotlight 3x")
        print("   - Icon-60@2x.png → iPhone App 2x")
        print("   - Icon-60@3x.png → iPhone App 3x")
        print("   - Icon-20@1x.png → iPad Settings 1x")
        print("   - Icon-29@1x.png → iPad Settings 1x")
        print("   - Icon-40@1x.png → iPad Spotlight 1x")
        print("   - Icon-76@2x.png → iPad App 2x")
        print("   - Icon-83.5@2x.png → iPad Pro App 2x")
        print("   - Icon-1024.png → App Store")
        print("\n5. Clean and rebuild your project")
        print("6. Run the app to see your new icons!")
    }
}

// MARK: - I-RIZE Icon View
struct IRizeIconView: View {
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
                    .foregroundColor(.neonGreen)
                    .tracking(3)
                    .shadow(color: .neonGreen.opacity(0.8), radius: size * 0.02, x: 0, y: 0)
                
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
                .fill(Color.neonGreen)
                .frame(width: size, height: size)
                .offset(y: size * 0.25)
                .shadow(color: .neonGreen.opacity(0.6), radius: size * 0.05, x: 0, y: 0)
            
            // Sun rays
            ForEach(0..<7, id: \.self) { index in
                Rectangle()
                    .fill(Color.neonGreen)
                    .frame(width: size * 0.06, height: size * 0.12)
                    .offset(y: -size * 0.35)
                    .rotationEffect(.degrees(Double(index) * 15 - 45))
                    .shadow(color: .neonGreen.opacity(0.6), radius: size * 0.02, x: 0, y: 0)
            }
        }
    }
}

// MARK: - Icon Setup View
struct IconSetupView: View {
    @State private var isGenerating = false
    @State private var showInstructions = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("I-RIZE Icon Setup")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.neonGreen)
                
                // Preview
                IRizeIconView(size: 120)
                    .frame(width: 120, height: 120)
                
                Text("Generate App Icons")
                    .font(.headline)
                    .foregroundColor(.neonGreen)
                
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
                            .fill(isGenerating ? Color.gray : Color.neonGreen)
                            .shadow(color: .neonGreen.opacity(0.6), radius: 8, x: 0, y: 4)
                    )
                }
                .disabled(isGenerating)
                .padding(.horizontal, 40)
                
                if showInstructions {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("📱 How to Add Icons to Xcode:")
                                .font(.headline)
                                .foregroundColor(.neonGreen)
                            
                            Text("1. Open Xcode")
                                .foregroundColor(.white)
                            Text("2. Click on 'Assets.xcassets' in Project Navigator")
                                .foregroundColor(.white)
                            Text("3. Click on 'AppIcon'")
                                .foregroundColor(.white)
                            Text("4. Drag PNG files from Documents folder to matching slots")
                                .foregroundColor(.white)
                            Text("5. Clean and rebuild project")
                                .foregroundColor(.white)
                            Text("6. Run app to see new icons!")
                                .foregroundColor(.white)
                            
                            Text("📁 Icons saved to Documents folder")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 10)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.neonGreen.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.neonGreen, lineWidth: 1)
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
            IconSetupHelper.generateAndSetupIcons()
            
            DispatchQueue.main.async {
                isGenerating = false
                showInstructions = true
            }
        }
    }
}

#Preview {
    IconSetupView()
} 