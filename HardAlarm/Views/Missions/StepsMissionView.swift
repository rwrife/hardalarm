import SwiftUI

struct StepsMissionView: View {
    let targetSteps: Int
    let onComplete: () -> Void
    
    @StateObject private var motion = MotionManager.shared
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "shoeprints.fill")
                        .foregroundColor(Theme.neonBlue)
                    Text("STEP WALKOUT")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.neonBlue)
                }
                
                Text("Get out of bed and walk \(targetSteps) steps to silence the alarm.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Circular Step Counter
            ZStack {
                CircularProgressRing(
                    progress: Double(motion.stepCount) / Double(max(1, targetSteps)),
                    color: Theme.neonBlue,
                    lineWidth: 18,
                    centerContent: AnyView(
                        VStack(spacing: 4) {
                            Text("\(motion.stepCount)")
                                .font(.system(size: 64, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            Text("OF \(targetSteps) STEPS")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(Theme.neonBlue)
                        }
                    )
                )
                .frame(width: 230, height: 230)
            }
            
            Text("Walking breaks sleep inertia and increases blood circulation.")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer()
            
            // Simulator / Step Trigger
            VStack(spacing: 8) {
                Button(action: {
                    motion.simulateStep()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Tap to Count Step (Simulator)")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Theme.cardSubtle)
                            .overlay(Capsule().stroke(Theme.neonBlue.opacity(0.5), lineWidth: 1))
                    )
                }
            }
            .padding(.bottom, 16)
        }
        .padding()
        .onAppear {
            motion.startStepTracking()
        }
        .onDisappear {
            motion.stopStepTracking()
        }
        .onChange(of: motion.stepCount) { _, newCount in
            if newCount >= targetSteps {
                onComplete()
            }
        }
    }
}
