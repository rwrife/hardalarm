import SwiftUI

struct ShakeMissionView: View {
    let goalShakes: Int
    let onComplete: () -> Void
    
    @StateObject private var motion = MotionManager.shared
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "iphone.radiowaves.left.and.right")
                        .foregroundColor(Theme.neonRed)
                    Text("VIGOROUS SHAKE")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.neonRed)
                }
                
                Text("Shake your phone vigorously to charge the wake reactor to 100%!")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Reactor Core / Battery
            ZStack {
                CircularProgressRing(
                    progress: motion.shakeEnergy,
                    color: Theme.neonRed,
                    lineWidth: 20,
                    centerContent: AnyView(
                        VStack(spacing: 6) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 38))
                                .foregroundColor(Theme.neonRed)
                            Text("\(Int(motion.shakeEnergy * 100))%")
                                .font(.system(size: 48, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            Text("CHARGE")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(Theme.neonRed)
                        }
                    )
                )
                .frame(width: 240, height: 240)
            }
            
            Text("Keep shaking! Resting will cause the charge to deplete.")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer()
            
            // Simulator / Manual Shake Trigger
            VStack(spacing: 8) {
                Button(action: {
                    motion.simulateShake()
                }) {
                    HStack {
                        Image(systemName: "waveform.path.ecg")
                        Text("Tap to Shake (Simulator / Test)")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Theme.cardSubtle)
                            .overlay(Capsule().stroke(Theme.neonRed.opacity(0.5), lineWidth: 1))
                    )
                }
            }
            .padding(.bottom, 16)
        }
        .padding()
        .onAppear {
            motion.startShakeTracking()
        }
        .onDisappear {
            motion.stopShakeTracking()
        }
        .onChange(of: motion.shakeEnergy) { _, newEnergy in
            if newEnergy >= 0.99 {
                Haptics.success()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onComplete()
                }
            }
        }
    }
}
