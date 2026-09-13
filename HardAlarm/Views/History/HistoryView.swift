import SwiftUI

struct HistoryView: View {
    @ObservedObject var alarmManager: AlarmManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Wake History")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Track your morning wake-up streak and records")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.textMuted)
                }
                .padding(.top, 10)
                
                // Streak Card
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CURRENT STREAK")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(Theme.textMuted)
                        HStack(spacing: 6) {
                            Text("🔥")
                            Text("\(alarmManager.stats.streakDays) Days")
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundColor(Theme.primaryOrange)
                        }
                    }
                    
                    Divider().frame(height: 38).background(Theme.cardBorder)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ALARMS DEACTIVATED")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(Theme.textMuted)
                        Text("\(alarmManager.stats.totalAlarmsDismissed)")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Theme.cardBackground)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.cardBorder, lineWidth: 1))
                )
                
                // Past Sessions
                Text("RECENT SESSIONS")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Theme.textMuted)
                    .padding(.top, 6)
                
                if alarmManager.stats.records.isEmpty {
                    VStack(spacing: 8) {
                        Text("No Wake Records Yet")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                        Text("Solve your first morning alarm puzzle to start your streak!")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textMuted)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(32)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.cardBackground))
                } else {
                    VStack(spacing: 10) {
                        ForEach(alarmManager.stats.records) { rec in
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(rec.alarmLabel)
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    Text(rec.missionType.title)
                                        .font(.system(size: 13))
                                        .foregroundColor(Theme.textMuted)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 3) {
                                    Text(rec.formattedDuration)
                                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                                        .foregroundColor(Theme.primaryOrange)
                                    Text("Solved")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Theme.neonGreen)
                                }
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Theme.cardBackground)
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.cardBorder, lineWidth: 1))
                            )
                        }
                    }
                }
                
                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 20)
        }
    }
}
