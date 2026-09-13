import SwiftUI

struct PushupsMissionView: View {
    let targetReps: Int
    let onComplete: () -> Void
    
    @StateObject private var motion = MotionManager.shared
    
    var body: some View {
        VStack(spacing: 24) {
            // Header instructions
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "figure.core.training")
                        .foregroundColor(Theme.neonOrange)
                    Text("PUSH-UP CHALLENGE")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.neonOrange)
                }
                
                Text("Place phone on floor face up under your chest.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Circular Rep Counter
            ZStack {
                CircularProgressRing(
                    progress: Double(motion.pushupCount) / Double(max(1, targetReps)),
                    color: Theme.neonOrange,
                    lineWidth: 18,
                    centerContent: AnyView(
                        VStack(spacing: 4) {
                            Text("\(motion.pushupCount)")
                                .font(.system(size: 64, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            Text("OF \(targetReps) REPS")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(Theme.neonOrange)
                        }
                    )
                )
                .frame(width: 230, height: 230)
            }
            
            // Chest Sensor Status
            HStack(spacing: 12) {
                Circle()
                    .fill(motion.isProximityActive ? Theme.neonGreen : Theme.cardBorder)
                    .frame(width: 14, height: 14)
                    .overlay(
                        Circle()
                            .stroke(motion.isProximityActive ? Theme.neonGreen.opacity(0.5) : Color.clear, lineWidth: 6)
                    )
                
                Text(motion.isProximityActive ? "CHEST DOWN - PUSH UP NOW!" : "LOWER YOUR CHEST TO PHONE")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(motion.isProximityActive ? Theme.neonGreen : .white.opacity(0.7))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Theme.cardBackground)
                    .overlay(Capsule().stroke(Theme.cardBorder, lineWidth: 1))
            )
            
            Spacer()
            
            // Simulator / Manual Rep Trigger
            VStack(spacing: 8) {
                Text("Sensor / Simulator Control:")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                
                Button(action: {
                    motion.simulatePushup()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Tap to Count Rep (Simulator)")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Theme.cardSubtle)
                            .overlay(Capsule().stroke(Theme.cardBorder, lineWidth: 1))
                    )
                }
            }
        }
        .padding()
        .onAppear {
            motion.startPushupTracking()
        }
        .onDisappear {
            motion.stopPushupTracking()
        }
        .onChange(of: motion.pushupCount) { _, newCount in
            if newCount >= targetReps {
                onComplete()
            }
        }
    }
}
