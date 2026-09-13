import SwiftUI

struct VoiceMissionView: View {
    let affirmation: String
    let onComplete: () -> Void
    
    @StateObject private var speech = SpeechManager.shared
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "waveform.badge.mic")
                        .foregroundColor(Theme.neonOrange)
                    Text("MORNING AFFIRMATION")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.neonOrange)
                }
                
                Text("Speak this phrase clearly aloud to wake your voice and mind:")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Quote Card
            NeonCard(accentColor: Theme.neonOrange) {
                VStack(spacing: 16) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 32))
                        .foregroundColor(Theme.neonOrange)
                    
                    Text(affirmation)
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                    
                    Image(systemName: "quote.closing")
                        .font(.system(size: 32))
                        .foregroundColor(Theme.neonOrange)
                }
                .padding()
            }
            .padding(.horizontal, 20)
            
            // Real-time voice transcript & match bar
            VStack(spacing: 8) {
                HStack {
                    Text("Vocal Clarity Score")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    Text("\(Int(speech.matchPercentage * 100))%")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.neonOrange)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Theme.cardSubtle)
                            .frame(height: 10)
                        Capsule()
                            .fill(Theme.neonOrange)
                            .frame(width: geo.size.width * CGFloat(speech.matchPercentage), height: 10)
                            .animation(.spring(), value: speech.matchPercentage)
                    }
                }
                .frame(height: 10)
                
                if !speech.recognizedText.isEmpty {
                    Text("Heard: \"\(speech.recognizedText)\"")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Simulator button
            VStack(spacing: 8) {
                Button(action: {
                    speech.simulateSpeechMatch()
                }) {
                    HStack {
                        Image(systemName: "mic.fill")
                        Text("Simulate Spoken Affirmation (Simulator)")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Theme.neonOrange.opacity(0.25))
                            .overlay(Capsule().stroke(Theme.neonOrange, lineWidth: 1))
                    )
                }
            }
            .padding(.bottom, 16)
        }
        .padding()
        .onAppear {
            speech.startListening(target: affirmation)
        }
        .onDisappear {
            speech.stopListening()
        }
        .onChange(of: speech.isAffirmationCompleted) { _, completed in
            if completed {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete()
                }
            }
        }
    }
}
