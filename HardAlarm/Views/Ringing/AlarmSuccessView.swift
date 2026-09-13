import SwiftUI

struct AlarmSuccessView: View {
    let record: WakeRecord?
    let streakDays: Int
    let onDismiss: () -> Void
    
    private let motivationalQuotes = [
        "\"The secret of getting ahead is getting started.\" — Mark Twain",
        "\"Today is an opportunity to build the tomorrow you want.\" — Ken Poirot",
        "\"Energy flows where attention goes.\" — Tony Robbins",
        "\"Wake up with determination, go to bed with satisfaction.\"",
        "\"Your morning sets the trajectory for your entire day. Conquer it!\""
    ]
    
    var randomQuote: String {
        motivationalQuotes.randomElement() ?? motivationalQuotes[0]
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            // Confetti Explosion
            ConfettiBurstView()
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                Spacer()
                
                // Trophy / Success Icon
                ZStack {
                    Circle()
                        .fill(Theme.neonGreen.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Circle()
                                .stroke(Theme.neonGreen.opacity(0.4), lineWidth: 2)
                        )
                    
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 64))
                        .foregroundColor(Theme.neonGreen)
                        .shadow(color: Theme.neonGreen.opacity(0.8), radius: 16)
                }
                
                // Titles
                VStack(spacing: 8) {
                    Text("MISSION ACCOMPLISHED!")
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundColor(Theme.neonGreen)
                        .tracking(2)
                    
                    Text("You're Wide Awake.")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
                
                // Wake Stats Card
                NeonCard(accentColor: Theme.neonGreen) {
                    VStack(spacing: 16) {
                        HStack(spacing: 24) {
                            VStack(spacing: 4) {
                                Text("WAKE TIME")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.5))
                                Text(record?.formattedDuration ?? "24s")
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            
                            Divider()
                                .frame(height: 36)
                                .background(Theme.cardBorder)
                            
                            VStack(spacing: 4) {
                                Text("WAKE STREAK")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.5))
                                HStack(spacing: 4) {
                                    Text("🔥")
                                    Text("\(streakDays) Days")
                                        .font(.system(size: 24, weight: .black, design: .rounded))
                                        .foregroundColor(Theme.neonOrange)
                                }
                            }
                        }
                        
                        Divider()
                            .background(Theme.cardBorder)
                        
                        Text(randomQuote)
                            .font(.system(size: 14, weight: .medium, design: .serif))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Dismiss Button
                NeonButton(
                    title: "GOOD MORNING! (DISMISS)",
                    icon: "sun.max.fill",
                    color: Theme.neonGreen,
                    action: onDismiss
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
            }
        }
    }
}
