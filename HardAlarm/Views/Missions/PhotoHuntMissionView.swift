import SwiftUI
import AVFoundation

struct PhotoHuntMissionView: View {
    let target: PhotoTarget
    let onComplete: () -> Void
    
    @StateObject private var vision = VisionManager.shared
    @State private var showCameraUnavailableHint: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 6) {
                HStack {
                    Image(systemName: "camera.viewfinder")
                        .foregroundColor(Theme.neonGreen)
                    Text("PHOTO HUNT")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.neonGreen)
                }
                
                Text(target.destinationHint)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8)
            
            // Viewfinder / Target Card
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Theme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                vision.targetConfidence > 0.35 ? Theme.neonGreen : Theme.cardBorder,
                                lineWidth: 2
                            )
                    )
                
                VStack(spacing: 16) {
                    // Target Icon
                    ZStack {
                        Circle()
                            .fill(Theme.neonGreen.opacity(0.15))
                            .frame(width: 90, height: 90)
                        
                        Image(systemName: target.icon)
                            .font(.system(size: 44))
                            .foregroundColor(Theme.neonGreen)
                    }
                    
                    Text("Target: \(target.rawValue)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(vision.statusMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(vision.targetConfidence > 0.35 ? Theme.neonGreen : .white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Confidence Bar
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("AI Detection Match")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                            Spacer()
                            Text("\(Int(vision.targetConfidence * 100))%")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(Theme.neonGreen)
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Theme.cardSubtle)
                                    .frame(height: 10)
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Theme.neonGreen.opacity(0.7), Theme.neonGreen],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * CGFloat(min(1.0, vision.targetConfidence)), height: 10)
                                    .animation(.spring(), value: vision.targetConfidence)
                            }
                        }
                        .frame(height: 10)
                    }
                    .padding(.horizontal, 24)
                    
                    // Live detected objects list
                    if !vision.detectedLabels.isEmpty {
                        VStack(spacing: 4) {
                            Text("Realtime Vision Feed:")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.4))
                            Text(vision.detectedLabels.prefix(3).joined(separator: " • "))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .lineLimit(1)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding()
            }
            .frame(maxHeight: 340)
            .padding(.horizontal)
            
            Spacer()
            
            // Testing / Simulator Fallback Controls
            VStack(spacing: 12) {
                Button(action: {
                    vision.simulateTargetFound()
                }) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Simulate Target Found (Simulator / Quick Test)")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Theme.neonGreen.opacity(0.25))
                            .overlay(Capsule().stroke(Theme.neonGreen, lineWidth: 1.2))
                    )
                }
            }
            .padding(.bottom, 16)
        }
        .padding()
        .onAppear {
            vision.startCamera(for: target)
        }
        .onDisappear {
            vision.stopCamera()
        }
        .onChange(of: vision.isTargetFound) { _, found in
            if found {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    onComplete()
                }
            }
        }
    }
}
