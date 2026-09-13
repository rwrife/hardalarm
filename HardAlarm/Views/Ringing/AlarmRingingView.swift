import SwiftUI

struct AlarmRingingView: View {
    let alarm: Alarm
    let onStartMission: () -> Void
    let onSnooze: () -> Void
    
    @State private var currentTime = Date()
    @State private var pulseBorder = false
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        return formatter.string(from: currentTime)
    }
    
    var amPmString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        return formatter.string(from: currentTime)
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            // Pulsing Alarm Glow Rings in the background
            ZStack {
                PulseRingView(color: Theme.neonRed)
                    .frame(width: 200, height: 200)
                PulseRingView(color: Theme.neonOrange)
                    .frame(width: 260, height: 260)
            }
            
            // Red Urgent Border Flash
            RoundedRectangle(cornerRadius: 0)
                .stroke(Theme.neonRed.opacity(pulseBorder ? 0.8 : 0.2), lineWidth: 8)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulseBorder)
            
            VStack(spacing: 32) {
                // Urgent Header
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Theme.neonRed)
                    Text("ALARM RINGING")
                        .font(.system(size: 16, weight: .black, design: .monospaced))
                        .foregroundColor(Theme.neonRed)
                        .tracking(2)
                }
                .padding(.top, 40)
                
                // Giant Clock Display
                VStack(spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(timeString)
                            .font(.system(size: 76, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: Theme.neonOrange.opacity(0.6), radius: 16)
                        
                        Text(amPmString)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.neonOrange)
                    }
                    
                    Text(alarm.label.isEmpty ? "Wake Up!" : alarm.label)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // Mission Requirement Card
                NeonCard(accentColor: alarm.mission.type.accentColor) {
                    VStack(spacing: 14) {
                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(alarm.mission.type.accentColor)
                            Text("TASK REQUIRED TO SILENCE")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(alarm.mission.type.accentColor)
                            Spacer()
                        }
                        
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(alarm.mission.type.accentColor.opacity(0.2))
                                    .frame(width: 54, height: 54)
                                Image(systemName: alarm.mission.type.icon)
                                    .font(.system(size: 26))
                                    .foregroundColor(alarm.mission.type.accentColor)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(alarm.mission.type.title)
                                    .font(.system(size: 19, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Text(alarm.mission.summaryText)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(alarm.mission.type.accentColor)
                            }
                            Spacer()
                        }
                        
                        Text(alarm.mission.morningBenefit)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 14) {
                    NeonButton(
                        title: "START MISSION TO SILENCE",
                        icon: "bolt.fill",
                        color: alarm.mission.type.accentColor,
                        isPulsing: true,
                        action: onStartMission
                    )
                    
                    if alarm.snoozeAllowed {
                        Button(action: onSnooze) {
                            HStack(spacing: 6) {
                                Image(systemName: "clock.arrow.circlepath")
                                Text("Snooze (\(alarm.snoozeMinutes) min)")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.vertical, 8)
                        }
                    } else {
                        Text("⛔ HARDCORE MODE: NO SNOOZE ALLOWED")
                            .font(.system(size: 12, weight: .black, design: .monospaced))
                            .foregroundColor(Theme.neonRed)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
            }
        }
        .onAppear {
            pulseBorder = true
        }
        .onReceive(timer) { input in
            currentTime = input
        }
    }
}
