import SwiftUI

struct StatsHeaderView: View {
    let nextAlarmString: String
    let stats: UserWakeStats
    let onQuickTest: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Next Alarm Banner
            HStack(spacing: 10) {
                Image(systemName: "bell.badge.fill")
                    .foregroundColor(Theme.neonOrange)
                    .font(.system(size: 16))
                
                Text(nextAlarmString)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: onQuickTest) {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                        Text("Test (3s)")
                    }
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Theme.neonOrange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Theme.neonOrange.opacity(0.15))
                            .overlay(Capsule().stroke(Theme.neonOrange.opacity(0.4), lineWidth: 1))
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Theme.cardBackground)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.cardBorder, lineWidth: 1))
            )
            
            // Streak & Wake Badges
            HStack(spacing: 10) {
                statBadge(
                    icon: "flame.fill",
                    color: Theme.neonOrange,
                    label: "Streak",
                    value: "\(stats.streakDays) Days"
                )
                
                statBadge(
                    icon: "checkmark.circle.fill",
                    color: Theme.neonGreen,
                    label: "Silenced",
                    value: "\(stats.totalAlarmsDismissed)"
                )
                
                statBadge(
                    icon: "figure.core.training",
                    color: Theme.neonYellow,
                    label: "Pushups",
                    value: "\(stats.totalPushupsCompleted)"
                )
            }
        }
    }
    
    private func statBadge(icon: String, color: Color, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
                Text(value)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Theme.cardBackground)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.cardBorder, lineWidth: 1))
        )
    }
}
