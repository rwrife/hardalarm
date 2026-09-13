import SwiftUI

struct AlarmRowView: View {
    let alarm: Alarm
    let onToggle: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Left Status Circle (Filled glowing orange if enabled, dark inactive if disabled)
            Button(action: onToggle) {
                ZStack {
                    if alarm.isEnabled {
                        Circle()
                            .fill(Theme.primaryOrange)
                            .frame(width: 14, height: 14)
                            .shadow(color: Theme.primaryOrange.opacity(0.6), radius: 6)
                    } else {
                        Circle()
                            .fill(Color(red: 0.22, green: 0.24, blue: 0.35))
                            .frame(width: 14, height: 14)
                    }
                }
                .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            
            // Alarm Title & Puzzle count
            VStack(alignment: .leading, spacing: 3) {
                Text(alarm.cardTitle)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(alarm.isEnabled ? .white : .white.opacity(0.45))
                
                HStack(spacing: 6) {
                    Text("Puzzles: \(alarm.puzzlesRequired)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.textMuted.opacity(alarm.isEnabled ? 1.0 : 0.5))
                    
                    if alarm.challengeMode == .random {
                        Text("• Random 🎲")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Theme.primaryOrange.opacity(alarm.isEnabled ? 0.9 : 0.45))
                    }
                }
            }
            
            Spacer()
            
            // Right Gear Icon (Edit Alarm)
            Button(action: onEdit) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Theme.textMuted.opacity(0.85))
                    .padding(8)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Theme.cardBorder, lineWidth: 1)
                )
        )
    }
}
