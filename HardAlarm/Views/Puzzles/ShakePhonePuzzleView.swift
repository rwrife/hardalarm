import SwiftUI

struct ShakePhonePuzzleView: View {
    let onSolveCompleted: () -> Void
    
    @StateObject private var motion = MotionManager.shared
    @State private var shakeOffset: CGFloat = 0
    @State private var isSolved: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("Puzzle 3")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.textMuted)
                
                Text("Vigorous Shake")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.top, 4)
            
            // Animated Shaking Phone Icon & Energy Gauge
            ZStack {
                // Background Track
                Circle()
                    .stroke(Color(red: 0.16, green: 0.17, blue: 0.25), lineWidth: 12)
                    .frame(width: 170, height: 170)
                
                // Progress Arc
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(1.0, motion.shakeEnergy)))
                    .stroke(
                        AngularGradient(
                            colors: [Theme.primaryOrange, Theme.brightOrange],
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 170, height: 170)
                    .animation(.spring(response: 0.3), value: motion.shakeEnergy)
                
                // Shaking Phone Graphic
                VStack(spacing: 4) {
                    Image(systemName: "iphone.radiowaves.left.and.right")
                        .font(.system(size: 44))
                        .foregroundColor(Theme.primaryOrange)
                        .offset(x: shakeOffset)
                    
                    Text("\(Int(motion.shakeEnergy * 100))%")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            
            VStack(spacing: 4) {
                Text("Shake vigorously until full!")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.primaryOrange)
                
                Text("Physical motion wakes your nervous system.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.textMuted)
            }
            
            // Simulator Shake Trigger
            Button(action: {
                triggerShakePulse()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "waveform.path.ecg")
                    Text("Tap to Shake (Simulator)")
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color(red: 0.18, green: 0.20, blue: 0.32))
                        .overlay(Capsule().stroke(Theme.cardBorder, lineWidth: 1))
                )
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 14)
        .onAppear {
            motion.startShakeTracking()
        }
        .onDisappear {
            motion.stopShakeTracking()
        }
        .onChange(of: motion.shakeEnergy) { _, newEnergy in
            if newEnergy >= 0.98 && !isSolved {
                isSolved = true
                Haptics.success()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    onSolveCompleted()
                }
            }
        }
    }
    
    private func triggerShakePulse() {
        motion.simulateShake()
        withAnimation(.easeInOut(duration: 0.08).repeatCount(3, autoreverses: true)) {
            shakeOffset = 6
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            shakeOffset = 0
        }
    }
}
