import SwiftUI

struct SettingsView: View {
    @ObservedObject var alarmManager: AlarmManager
    @StateObject private var soundManager = SoundManager.shared
    
    @State private var defaultVolume: Double = 1.0
    @State private var vibrateEnabled: Bool = true
    @State private var selectedMelody: AlarmSound = .nuclear
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Settings")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Alarm volume, audio melodies, and vibration")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.textMuted)
                }
                .padding(.top, 10)
                
                // Sound & Volume Section
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "speaker.wave.3.fill")
                            .foregroundColor(Theme.primaryOrange)
                        Text("Volume Level")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                        Text("Maximum (100%)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Theme.primaryOrange)
                    }
                    
                    Slider(value: $defaultVolume, in: 0.2...1.0)
                        .tint(Theme.primaryOrange)
                    
                    Divider().background(Theme.cardBorder)
                    
                    Toggle(isOn: $vibrateEnabled) {
                        HStack {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .foregroundColor(Theme.primaryOrange)
                            Text("Vibrate with Melody")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .tint(Theme.primaryOrange)
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Theme.cardBackground)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.cardBorder, lineWidth: 1))
                )
                
                // Tone Melodies
                VStack(alignment: .leading, spacing: 12) {
                    Text("ALARM TONES")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.textMuted)
                    
                    ForEach(AlarmSound.allCases) { sound in
                        let isSelected = selectedMelody == sound
                        Button(action: {
                            Haptics.light()
                            selectedMelody = sound
                        }) {
                            HStack {
                                Text(sound.displayName)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Theme.primaryOrange)
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isSelected ? Color(red: 0.16, green: 0.18, blue: 0.28) : Theme.cardBackground)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 20)
        }
    }
}
