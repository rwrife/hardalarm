import Foundation

struct WakeRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var date: Date = Date()
    var alarmLabel: String
    var missionType: MissionType
    var timeTakenSeconds: Int
    var snoozesUsed: Int
    var success: Bool
    
    var formattedDuration: String {
        let minutes = timeTakenSeconds / 60
        let seconds = timeTakenSeconds % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

struct UserWakeStats: Codable {
    var streakDays: Int = 3
    var totalAlarmsDismissed: Int = 14
    var totalPushupsCompleted: Int = 90
    var totalMathSolved: Int = 36
    var records: [WakeRecord] = []
    
    mutating func recordDismissal(alarmLabel: String, mission: MissionConfig, durationSeconds: Int, snoozes: Int) {
        let newRecord = WakeRecord(
            alarmLabel: alarmLabel,
            missionType: mission.type,
            timeTakenSeconds: durationSeconds,
            snoozesUsed: snoozes,
            success: true
        )
        records.insert(newRecord, at: 0)
        totalAlarmsDismissed += 1
        streakDays += 1
        
        switch mission.type {
        case .pushups:
            totalPushupsCompleted += mission.pushupTargetReps
        case .math:
            totalMathSolved += mission.mathProblemCount
        default:
            break
        }
    }
}
