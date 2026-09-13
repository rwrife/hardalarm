import SwiftUI

struct WakeUpRingingView: View {
    @ObservedObject var alarmManager: AlarmManager
    
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: currentTime)
    }
    
    var alarmTimeFormatted: String {
        guard let alarm = alarmManager.ringingAlarm else { return "07:30 AM" }
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: alarm.time)
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Top Header
                VStack(spacing: 4) {
                    if alarmManager.currentPuzzleIndex == 1 {
                        Text("WAKE UP!")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    } else {
                        Text("Puzzle \(alarmManager.currentPuzzleIndex) of \(alarmManager.totalPuzzlesRequired)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Text("(\(alarmTimeFormatted) Alarm)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.textMuted)
                }
                .padding(.top, 16)
                
                // Card Container
                if alarmManager.currentPuzzleIndex == 1 {
                    // Screen 2: Golden Glowing Border & Sparkles Box
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Theme.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Theme.glowingGold, Theme.primaryOrange.opacity(0.8), Theme.glowingGold],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .shadow(color: Theme.glowingGold.opacity(0.4), radius: 20, x: 0, y: 4)
                        
                        sparklesOverlay
                        
                        VStack(spacing: 12) {
                            Text("Solve \(alarmManager.totalPuzzlesRequired) Puzzles to Stop Alarm")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.top, 14)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color(red: 0.11, green: 0.12, blue: 0.19))
                                
                                MathMatchPuzzleView {
                                    alarmManager.completeCurrentPuzzle()
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.bottom, 14)
                        }
                    }
                    .padding(.horizontal, 24)
                    .frame(height: 380)
                    
                    // Screen 2 Progress Bar
                    VStack(spacing: 6) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color(red: 0.18, green: 0.20, blue: 0.30))
                                    .frame(height: 8)
                                
                                Capsule()
                                    .fill(Theme.primaryOrange)
                                    .frame(width: max(24, geo.size.width * 0.33), height: 8)
                            }
                        }
                        .frame(height: 8)
                        .padding(.horizontal, 28)
                        
                        Text("1 of \(alarmManager.totalPuzzlesRequired) Puzzles Solved")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Theme.textMuted)
                    }
                    
                    Spacer()
                    
                    // Screen 2 Bottom Status Bar: Volume & Current Time
                    HStack(spacing: 16) {
                        HStack(spacing: 10) {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .font(.system(size: 22))
                                .foregroundColor(Theme.primaryOrange)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Volume:")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(Theme.textMuted)
                                Text("Maximum")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Current:")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Theme.textMuted)
                            Text(timeFormatted)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Theme.cardBackground)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.cardBorder, lineWidth: 1))
                    )
                    .padding(.horizontal, 24)
                    
                    // Screen 2 Bottom Action Buttons
                    HStack(spacing: 12) {
                        Button(action: {
                            Haptics.light()
                            alarmManager.completeCurrentPuzzle()
                        }) {
                            Text("Solve First")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Theme.primaryOrange)
                                )
                        }
                        
                        Button(action: {
                            Haptics.warning()
                        }) {
                            Text("Can't Stop yet")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(Theme.textMuted.opacity(0.6))
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 0.14, green: 0.15, blue: 0.23))
                                )
                        }
                        .disabled(true)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    
                } else {
                    // Screen 3: Memory Sequence / Shake Challenge Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Theme.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Theme.cardBorder, lineWidth: 1)
                            )
                        
                        if alarmManager.currentPuzzleType == .memorySequence || alarmManager.currentPuzzleType == .patternConnect {
                            MemorySequence4x4View {
                                alarmManager.completeCurrentPuzzle()
                            }
                        } else {
                            ShakePhonePuzzleView {
                                alarmManager.completeCurrentPuzzle()
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .frame(height: 380)
                    
                    // Screen 3 Encouragement Text
                    Text("Keep going to deactivate!")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 4)
                    
                    // Screen 3 Progress Bar
                    VStack(spacing: 6) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color(red: 0.18, green: 0.20, blue: 0.30))
                                    .frame(height: 8)
                                
                                let progress = Double(alarmManager.currentPuzzleIndex) / Double(max(1, alarmManager.totalPuzzlesRequired))
                                Capsule()
                                    .fill(Theme.primaryOrange)
                                    .frame(width: max(24, geo.size.width * CGFloat(progress)), height: 8)
                                    .animation(.spring(response: 0.4), value: alarmManager.currentPuzzleIndex)
                            }
                        }
                        .frame(height: 8)
                        .padding(.horizontal, 28)
                        
                        Text("\(alarmManager.currentPuzzleIndex) of \(alarmManager.totalPuzzlesRequired) Puzzles Solved")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Theme.textMuted)
                    }
                    
                    Spacer()
                    
                    // Screen 3 Bottom Audio Melody Toggle Bar
                    HStack(spacing: 14) {
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Theme.primaryOrange)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Alarm Sound:")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Theme.textMuted)
                            Text(alarmManager.ringingAlarm?.soundDescriptionTitle ?? "Vibrate + Melody")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { alarmManager.isAlarmSoundActive },
                            set: { _ in alarmManager.toggleAlarmSound() }
                        ))
                        .labelsHidden()
                        .tint(Theme.primaryOrange)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Theme.cardBackground)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.cardBorder, lineWidth: 1))
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                }
            }
        }
        .onReceive(timer) { input in
            currentTime = input
        }
    }
    
    // Gold sparkle particle decoration
    private var sparklesOverlay: some View {
        ZStack {
            Circle()
                .fill(Theme.glowingGold)
                .frame(width: 4, height: 4)
                .offset(x: -120, y: -80)
            Circle()
                .fill(Theme.primaryOrange)
                .frame(width: 6, height: 6)
                .offset(x: 130, y: -40)
            Circle()
                .fill(Theme.glowingGold)
                .frame(width: 5, height: 5)
                .offset(x: -140, y: 60)
            Circle()
                .fill(Theme.glowingGold)
                .frame(width: 4, height: 4)
                .offset(x: 125, y: 90)
            Circle()
                .fill(Theme.primaryOrange)
                .frame(width: 5, height: 5)
                .offset(x: -130, y: 120)
        }
        .opacity(0.8)
        .allowsHitTesting(false)
    }
}
