import Foundation

enum Weekday: Int, CaseIterable, Codable, Identifiable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var id: Int { rawValue }
    
    var shortName: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }
    
    var singleLetter: String {
        switch self {
        case .sunday: return "S"
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        }
    }
}

struct Alarm: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var time: Date
    var label: String // e.g. "Work", "Gym"
    var isEnabled: Bool = true
    var repeatDays: Set<Int> = [] // 1=Sun, 2=Mon...
    var puzzlesRequired: Int = 3 // "Puzzles: 3"
    var challengeMode: ChallengeSelectionMode = .random
    var mission: MissionConfig = MissionConfig()
    var sound: AlarmSound = .nuclear
    var volume: Float = 1.0
    var isProgressiveVolume: Bool = false
    var snoozeAllowed: Bool = false
    var snoozeMinutes: Int = 5
    var maxSnoozeCount: Int = 1
    var soundDescriptionTitle: String = "Vibrate + Melody"
    
    // Display string as seen in reference: "7:30 AM (Work)"
    var cardTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let tStr = formatter.string(from: time)
        if !label.isEmpty {
            return "\(tStr) (\(label))"
        }
        return tStr
    }
    
    var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: time)
    }
    
    var hourMinute: (hour: Int, minute: Int) {
        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute], from: time)
        return (comps.hour ?? 7, comps.minute ?? 30)
    }
    
    var repeatDescription: String {
        if repeatDays.isEmpty { return "Once" }
        if repeatDays.count == 7 { return "Every day" }
        let weekdays: Set<Int> = [2, 3, 4, 5, 6]
        let weekends: Set<Int> = [1, 7]
        if repeatDays == weekdays { return "Weekdays" }
        if repeatDays == weekends { return "Weekends" }
        let sortedDays = repeatDays.sorted().compactMap { Weekday(rawValue: $0)?.shortName }
        return sortedDays.joined(separator: ", ")
    }
    
    func nextTriggerDate(from referenceDate: Date = Date()) -> Date {
        let calendar = Calendar.current
        let (alarmHour, alarmMinute) = self.hourMinute
        
        if repeatDays.isEmpty {
            var comps = calendar.dateComponents([.year, .month, .day], from: referenceDate)
            comps.hour = alarmHour
            comps.minute = alarmMinute
            comps.second = 0
            
            if let date = calendar.date(from: comps) {
                if date > referenceDate {
                    return date
                } else {
                    return calendar.date(byAdding: .day, value: 1, to: date) ?? date
                }
            }
        }
        
        var nextDate: Date?
        for dayOffset in 0..<7 {
            guard let candidateDay = calendar.date(byAdding: .day, value: dayOffset, to: referenceDate) else { continue }
            let candidateWeekday = calendar.component(.weekday, from: candidateDay)
            
            if repeatDays.contains(candidateWeekday) {
                var comps = calendar.dateComponents([.year, .month, .day], from: candidateDay)
                comps.hour = alarmHour
                comps.minute = alarmMinute
                comps.second = 0
                
                if let candidateDate = calendar.date(from: comps), candidateDate > referenceDate {
                    if nextDate == nil || candidateDate < nextDate! {
                        nextDate = candidateDate
                    }
                }
            }
        }
        
        return nextDate ?? referenceDate.addingTimeInterval(3600 * 24)
    }
    
    static var sampleAlarms: [Alarm] {
        let cal = Calendar.current
        var comps1 = cal.dateComponents([.year, .month, .day], from: Date())
        comps1.hour = 7
        comps1.minute = 30
        let date1 = cal.date(from: comps1) ?? Date()
        
        var comps2 = cal.dateComponents([.year, .month, .day], from: Date())
        comps2.hour = 8
        comps2.minute = 0
        let date2 = cal.date(from: comps2) ?? Date()
        
        return [
            Alarm(
                time: date1,
                label: "Work",
                isEnabled: true,
                repeatDays: [2, 3, 4, 5, 6],
                puzzlesRequired: 3,
                challengeMode: .random,
                soundDescriptionTitle: "Vibrate + Melody"
            ),
            Alarm(
                time: date2,
                label: "Gym",
                isEnabled: false,
                repeatDays: [2, 4, 6],
                puzzlesRequired: 2,
                challengeMode: .random,
                soundDescriptionTitle: "Vibrate + Melody"
            )
        ]
    }
}
