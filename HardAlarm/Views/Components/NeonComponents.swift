import SwiftUI

// MARK: - Neon Glass Card Container

struct NeonCard<Content: View>: View {
    var accentColor: Color = Theme.neonBlue
    var cornerRadius: CGFloat = 20
    var content: () -> Content
    
    init(accentColor: Color = Theme.neonBlue, cornerRadius: CGFloat = 20, @ViewBuilder content: @escaping () -> Content) {
        self.accentColor = accentColor
        self.cornerRadius = cornerRadius
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Theme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        accentColor.opacity(0.4),
                                        Theme.cardBorder.opacity(0.8),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 5)
            )
    }
}

// MARK: - Glowing Neon Action Button

struct NeonButton: View {
    let title: String
    var icon: String? = nil
    var color: Color = Theme.neonOrange
    var isPulsing: Bool = false
    let action: () -> Void
    
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            Haptics.heavy()
            action()
        }) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .bold))
                }
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    if isPulsing {
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(color, lineWidth: 2)
                            .scaleEffect(pulseScale)
                            .opacity(2.0 - Double(pulseScale))
                    }
                }
            )
            .shadow(color: color.opacity(0.5), radius: 12, x: 0, y: 6)
        }
        .onAppear {
            if isPulsing {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false)) {
                    pulseScale = 1.15
                }
            }
        }
    }
}

// MARK: - Circular Progress Ring

struct CircularProgressRing: View {
    var progress: Double // 0.0 to 1.0
    var color: Color = Theme.neonOrange
    var lineWidth: CGFloat = 14
    var centerContent: AnyView? = nil
    
    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(Theme.cardBorder, lineWidth: lineWidth)
            
            // Progress
            Circle()
                .trim(from: 0.0, to: CGFloat(min(1.0, max(0.0, progress))))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [color.opacity(0.6), color]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress)
                .shadow(color: color.opacity(0.6), radius: 6)
            
            if let center = centerContent {
                center
            }
        }
    }
}

// MARK: - Pulsing Radar Alert Ring

struct PulseRingView: View {
    var color: Color = Theme.neonRed
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.8
    
    var body: some View {
        Circle()
            .stroke(color.opacity(opacity), lineWidth: 3)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                    scale = 2.4
                    opacity = 0.0
                }
            }
    }
}

// MARK: - Mission Badge Chip

struct MissionBadge: View {
    let mission: MissionConfig
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: mission.type.icon)
                .font(.system(size: 13, weight: .bold))
            Text(mission.summaryText)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .foregroundColor(mission.type.accentColor)
        .background(
            Capsule()
                .fill(mission.type.accentColor.opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(mission.type.accentColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Confetti Particle View

struct ConfettiBurstView: View {
    @State private var particles: [ConfettiParticle] = []
    
    struct ConfettiParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var color: Color
        var rotation: Double
        var opacity: Double
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(particles) { p in
                    Circle()
                        .fill(p.color)
                        .frame(width: p.size, height: p.size)
                        .position(x: p.x, y: p.y)
                        .rotationEffect(.degrees(p.rotation))
                        .opacity(p.opacity)
                }
            }
            .onAppear {
                generateParticles(in: proxy.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func generateParticles(in size: CGSize) {
        let colors = [Theme.neonOrange, Theme.neonBlue, Theme.neonGreen, Theme.neonYellow, Theme.neonPurple]
        var initial: [ConfettiParticle] = []
        
        for _ in 0..<70 {
            let startX = size.width / 2
            let startY = size.height / 2
            let particle = ConfettiParticle(
                x: startX,
                y: startY,
                size: CGFloat.random(in: 6...14),
                color: colors.randomElement() ?? .orange,
                rotation: Double.random(in: 0...360),
                opacity: 1.0
            )
            initial.append(particle)
        }
        particles = initial
        
        withAnimation(.easeOut(duration: 2.2)) {
            for i in 0..<particles.count {
                let angle = Double.random(in: 0...(2 * .pi))
                let distance = CGFloat.random(in: 80...size.width * 0.7)
                particles[i].x += cos(angle) * distance
                particles[i].y += sin(angle) * distance - CGFloat.random(in: 50...200)
                particles[i].opacity = 0.0
                particles[i].rotation += Double.random(in: 180...720)
            }
        }
    }
}
