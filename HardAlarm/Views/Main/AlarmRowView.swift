import SwiftUI

struct AlarmRowView: View {
    let alarm: Alarm
    let onToggle: () -> Void
    let onTest: () -> Void
    
    var body: some View {
        NeonCard(accentColor: alarm.isEnabled ? alarm.mission.type.accentColor : Theme.cardBorder) {
            VStack(alignment: .leading, spacing: 14) {
                // Top row: Time + Toggle
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(alarm.timeFormatted)
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundColor(alarm.isEnabled ? .white : .white.opacity(0.4))
                        
                        if !alarm.label.isEmpty {
                            Text(alarm.label)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(alarm.isEnabled ? .white.opacity(0.85) : .white.opacity(0.3))
                        }
                    }
                    
                    Spacer()
                    
                    // Toggle
                    Toggle("", isOn: Binding(
                        get: { alarm.isEnabled },
                        set: { _ in onToggle() }
                    ))
                    .labelsHidden()
                    .tint(alarm.mission.type.accentColor)
                }
                
                Divider()
                    .background(Theme.cardBorder)
                
                // Bottom row: Repeat, Mission Badge, Test Button
                HStack(spacing: 8) {
                    // Repeat badge
                    HStack(spacing: 4) {
                        Image(systemName: "repeat")
                            .font(.system(size: 11))
                        Text(alarm.repeatDescription)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.white.opacity(alarm.isEnabled ? 0.7 : 0.3))
                    
                    Spacer()
                    
                    // Mission badge
                    MissionBadge(mission: alarm.mission)
                        .opacity(alarm.isEnabled ? 1.0 : 0.4)
                    
                    // Instant Test Button
                    Button(action: onTest) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 12))
                            .foregroundColor(alarm.mission.type.accentColor)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(alarm.mission.type.accentColor.opacity(0.15))
                            )
                    }
                }
            }
        }
    }
}
