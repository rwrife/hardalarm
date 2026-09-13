import SwiftUI

struct SquatsMissionView: View {
    let targetReps: Int
    let onComplete: () -> Void
    
    @StateObject private var motion = MotionManager.shared
    
    var body: some View {
        VStack(spacing: 24) {
            // Header instructions
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "figure.cross.training")
                        .foregroundColor(Theme.neonYellow)
                    Text("MORNING SQUATS")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.neonYellow)
                }
                
                Text("Hold device firmly in hand or pocket. Squat down and stand fully up.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Circular Rep Counter
            ZStack {
                CircularProgressRing(
                    progress: Double(motion.squatCount) / Double(max(1, targetReps)),
                    color: Theme.neonYellow,
                    lineWidth: 18,
                    centerContent: AnyView(
                        VStack(spacing: 4) {
                            Text("\(motion.squatCount)")
                                .font(.system(size: 64, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            Text("OF \(targetReps) SQUATS")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(Theme.neonYellow)
                        }
                    )
                )
                .frame(width: 230, height: 230)
            }
            
            // Depth visualizer
            HStack(spacing: 12) {
                Circle()
                    .fill(motion.isSquatDown ? Theme.neonGreen : Theme.neonYellow)
                    .frame(width: 14, height: 14)
                
                Text(motion.isSquatDown ? "DEEP SQUAT DETECTED - NOW STAND UP" : "SQUAT DOWN DEEP")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(motion.isSquatDown ? Theme.neonGreen : .white.opacity(0.8))
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
                Text("Simulator / Manual Control:")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                
                Button(action: {
                    motion.simulateSquat()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Tap to Count Squat (Simulator)")
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
            motion.startSquatTracking()
        }
        .onDisappear {
            motion.stopSquatTracking()
        }
        .onChange(of: motion.squatCount) { _, newCount in
            if newCount >= targetReps {
                onComplete()
            }
        }
    }
}
