import SwiftUI

struct SoundPickerView: View {
    @Binding var selectedSound: AlarmSound
    @Binding var volume: Float
    @Binding var isProgressive: Bool
    
    @StateObject private var soundManager = SoundManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("ALARM TONE & VOLUME")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(Theme.neonOrange)
            
            // Sounds List
            VStack(spacing: 8) {
                ForEach(AlarmSound.allCases) { sound in
                    let isSelected = selectedSound == sound
                    let isPlayingThis = soundManager.activePreviewSound == sound && soundManager.isPreviewing
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            Haptics.light()
                            selectedSound = sound
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: sound.icon)
                                    .font(.system(size: 18))
                                    .foregroundColor(isSelected ? Theme.neonOrange : .white.opacity(0.6))
                                    .frame(width: 26)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(sound.displayName)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                    Text(sound.soundDescription)
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                
                                Spacer()
                                
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Theme.neonOrange)
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                        }
                        
                        // Audio Preview Play/Stop Button
                        Button(action: {
                            Haptics.medium()
                            soundManager.previewSound(sound)
                        }) {
                            Image(systemName: isPlayingThis ? "stop.circle.fill" : "play.circle.fill")
                                .font(.system(size: 26))
                                .foregroundColor(isPlayingThis ? Theme.neonRed : Theme.neonOrange)
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(isSelected ? Theme.cardSubtle : Theme.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(isSelected ? Theme.neonOrange.opacity(0.8) : Theme.cardBorder, lineWidth: 1)
                            )
                    )
                }
            }
            
            // Volume and Progressive Volume
            NeonCard(accentColor: Theme.neonOrange) {
                VStack(spacing: 14) {
                    HStack {
                        Image(systemName: "speaker.wave.3.fill")
                            .foregroundColor(Theme.neonOrange)
                        Text("Volume Level: \(Int(volume * 100))%")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    Slider(value: $volume, in: 0.2...1.0, step: 0.05)
                        .tint(Theme.neonOrange)
                    
                    Divider().background(Theme.cardBorder)
                    
                    Toggle(isOn: $isProgressive) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Progressive Volume Escalation")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                            Text("Starts at 20% and escalates to maximum over 30s.")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .tint(Theme.neonOrange)
                }
            }
        }
        .onDisappear {
            soundManager.stopPreview()
        }
    }
}
