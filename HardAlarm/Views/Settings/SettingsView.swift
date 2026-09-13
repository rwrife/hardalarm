import SwiftUI

struct SettingsView: View {
    @ObservedObject var alarmManager: AlarmManager
    @StateObject private var soundManager = SoundManager.shared
    @ObservedObject private var notificationManager = NotificationManager.shared
    
    @State private var defaultVolume: Double = 1.0
    @State private var vibrateEnabled: Bool = true
    @State private var selectedMelody: AlarmSound = .nuclear
    @State private var testCountdown: Int? = nil
    @State private var testTimer: Timer?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Settings")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Alarm volume, background audio, and melodies")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.textMuted)
                }
                .padding(.top, 10)
                
                // Background Audio & Mute Bypass Section
                backgroundAudioCard
                
                // Sound & Volume Section
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "speaker.wave.3.fill")
                            .foregroundColor(Theme.primaryOrange)
                        Text("Default Volume")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(Int(defaultVolume * 100))%")
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
                                Image(systemName: sound.icon)
                                    .foregroundColor(isSelected ? Theme.primaryOrange : Theme.textMuted)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(sound.displayName)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                    Text(sound.soundDescription)
                                        .font(.system(size: 11))
                                        .foregroundColor(Theme.textMuted)
                                        .lineLimit(1)
                                }
                                
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
        .onAppear {
            notificationManager.checkAuthorization()
        }
    }
    
    // MARK: - Background Audio & Mute Bypass Card
    
    private var backgroundAudioCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "speaker.wave.3.fill")
                    .foregroundColor(Theme.neonGreen)
                    .font(.system(size: 18))
                Text("BACKGROUND AUDIO & MUTE BYPASS")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(Theme.neonGreen)
                Spacer()
                
                Text(soundManager.isSilentKeepAliveActive ? "KEEP-ALIVE ACTIVE" : "ENABLED")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Theme.neonGreen))
            }
            
            Text("HardAlarm uses an inaudible background audio keep-alive when alarms are active. This prevents iOS from suspending the app and blares the siren directly through the speakers at alarm time—overriding the hardware Silent/Mute switch without needing special Apple profiles.")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(2)
            
            if !notificationManager.isAuthorized {
                Button(action: {
                    Haptics.medium()
                    notificationManager.requestAuthorization()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "bell.badge.fill")
                        Text("Enable Notifications (for Screen Banner)")
                    }
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Theme.neonOrange))
                }
            }
            
            // Test Background Alarm Trigger
            VStack(alignment: .leading, spacing: 6) {
                if let countdown = testCountdown {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(Theme.primaryOrange)
                        Text("Lock screen or toggle Mute! Ringing in \(countdown)s...")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Theme.primaryOrange)
                    }
                    .padding(.vertical, 6)
                } else {
                    Button(action: {
                        triggerTestBackgroundAlarm()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "play.circle.fill")
                            Text("Test Background Ringing (5s delay)")
                        }
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.primaryOrange)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Theme.primaryOrange.opacity(0.12))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.primaryOrange.opacity(0.3), lineWidth: 1))
                        )
                    }
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Theme.neonGreen.opacity(0.4), lineWidth: 1.2)
                )
        )
    }
    
    private func triggerTestBackgroundAlarm() {
        Haptics.medium()
        testCountdown = 5
        
        // Start background silent keep alive immediately so it stays awake if user locks screen
        soundManager.startSilentKeepAlive()
        
        testTimer?.invalidate()
        testTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                if let current = testCountdown, current > 1 {
                    testCountdown = current - 1
                } else {
                    testTimer?.invalidate()
                    testTimer = nil
                    testCountdown = nil
                    
                    var testAlarm = alarmManager.alarms.first ?? Alarm.sampleAlarms[0]
                    testAlarm.sound = selectedMelody
                    testAlarm.volume = Float(defaultVolume)
                    alarmManager.triggerAlarm(testAlarm)
                }
            }
        }
    }
}
