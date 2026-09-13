import SwiftUI

enum Theme {
    // Backgrounds
    static let background = Color(red: 0.05, green: 0.06, blue: 0.08)
    static let cardBackground = Color(red: 0.10, green: 0.12, blue: 0.16)
    static let cardBorder = Color(red: 0.18, green: 0.21, blue: 0.28)
    static let cardSubtle = Color(red: 0.14, green: 0.16, blue: 0.22)
    
    // Neon Accents
    static let neonOrange = Color(red: 1.0, green: 0.38, blue: 0.20)
    static let neonBlue = Color(red: 0.0, green: 0.82, blue: 1.0)
    static let neonGreen = Color(red: 0.0, green: 0.94, blue: 0.52)
    static let neonPurple = Color(red: 0.74, green: 0.38, blue: 1.0)
    static let neonYellow = Color(red: 1.0, green: 0.85, blue: 0.18)
    static let neonRed = Color(red: 1.0, green: 0.23, blue: 0.23)
    
    // Typography Gradients
    static let fireGradient = LinearGradient(
        colors: [neonOrange, neonRed],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cyanGradient = LinearGradient(
        colors: [neonBlue, Color(red: 0.0, green: 0.5, blue: 1.0)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let emeraldGradient = LinearGradient(
        colors: [neonGreen, Color(red: 0.0, green: 0.7, blue: 0.4)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
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
