import SwiftUI

enum Theme {
    // Exact background from reference image: deep dark midnight blue/black
    static let background = Color(red: 0.051, green: 0.059, blue: 0.098) // #0D0F19
    static let cardBackground = Color(red: 0.098, green: 0.106, blue: 0.165) // #191B2A
    static let cardBorder = Color(red: 0.161, green: 0.173, blue: 0.255) // #292C41
    static let cardInner = Color(red: 0.125, green: 0.137, blue: 0.208) // #202335
    
    // Warm vibrant orange/amber from reference image
    static let primaryOrange = Color(red: 1.0, green: 0.655, blue: 0.149) // #FFA726
    static let brightOrange = Color(red: 1.0, green: 0.573, blue: 0.0) // #FF9200
    static let darkOrange = Color(red: 0.85, green: 0.45, blue: 0.0)
    static let glowingGold = Color(red: 1.0, green: 0.76, blue: 0.28)
    
    // Text colors from reference
    static let textPrimary = Color.white
    static let textMuted = Color(red: 0.58, green: 0.60, blue: 0.72) // #9499B8
    static let textSubtle = Color(red: 0.42, green: 0.44, blue: 0.56) // #6B708F
    
    // Glowing tile puzzle colors
    static let tileOrange = Color(red: 1.0, green: 0.58, blue: 0.0)
    static let tileCyan = Color(red: 0.0, green: 0.72, blue: 1.0)
    static let tileGreen = Color(red: 0.16, green: 0.90, blue: 0.45)
    static let tileYellow = Color(red: 1.0, green: 0.85, blue: 0.18)
    static let tileInactive = Color(red: 0.14, green: 0.15, blue: 0.23)
    
    // Status & Compatibility Colors
    static let neonGreen = Color(red: 0.0, green: 0.90, blue: 0.45)
    static let neonRed = Color(red: 1.0, green: 0.28, blue: 0.28)
    static let neonOrange = primaryOrange
    static let neonBlue = tileCyan
    static let neonYellow = tileYellow
    static let neonPurple = Color(red: 0.74, green: 0.38, blue: 1.0)
    static let cardSubtle = cardInner
    
    // Gradients
    static let cardGlowGradient = LinearGradient(
        colors: [primaryOrange.opacity(0.8), primaryOrange.opacity(0.2), Color.clear],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let buttonGradient = LinearGradient(
        colors: [primaryOrange, brightOrange],
        startPoint: .top,
        endPoint: .bottom
    )
}

struct Haptics {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
