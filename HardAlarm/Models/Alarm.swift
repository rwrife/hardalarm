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
    var label: String
    var isEnabled: Bool = true
    var repeatDays: Set<Int> = [] // 1=Sun, 2=Mon, ..., 7=Sat. Empty means one-time.
    var mission: MissionConfig = MissionConfig()
    var sound: AlarmSound = .nuclear
    var volume: Float = 0.9
    var isProgressiveVolume: Bool = true
    var snoozeAllowed: Bool = true
    var snoozeMinutes: Int = 5
    var maxSnoozeCount: Int = 2
    
    // Formatted time string (e.g., "06:30 AM")
    var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: time)
    }
    
    var hourMinute: (hour: Int, minute: Int) {
        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute], from: time)
        return (comps.hour ?? 7, comps.minute ?? 0)
    }
    
    var repeatDescription: String {
        if repeatDays.isEmpty {
            return "Once"
        }
        if repeatDays.count == 7 {
            return "Every day"
        }
        let weekdays: Set<Int> = [2, 3, 4, 5, 6]
        let weekends: Set<Int> = [1, 7]
        if repeatDays == weekdays {
            return "Weekdays"
        }
        if repeatDays == weekends {
            return "Weekends"
        }
        
        let sortedDays = repeatDays.sorted().compactMap { Weekday(rawValue: $0)?.shortName }
        return sortedDays.joined(separator: ", ")
    }
    
    /// Calculates next trigger date based on repeat days and current time
    func nextTriggerDate(from referenceDate: Date = Date()) -> Date {
        let calendar = Calendar.current
        let (alarmHour, alarmMinute) = self.hourMinute
        
        if repeatDays.isEmpty {
            // One-time alarm
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
        
        // Recurring alarm: find nearest matching weekday
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
        
        if let next = nextDate {
            return next
        }
        
        // Fallback: 7 days from next matching weekday
        return referenceDate.addingTimeInterval(3600 * 24)
    }
    
    static var sampleAlarms: [Alarm] {
        let cal = Calendar.current
        var comps1 = cal.dateComponents([.year, .month, .day], from: Date())
        comps1.hour = 6
        comps1.minute = 30
        let date1 = cal.date(from: comps1) ?? Date()
        
        var comps2 = cal.dateComponents([.year, .month, .day], from: Date())
        comps2.hour = 7
        comps2.minute = 15
        let date2 = cal.date(from: comps2) ?? Date()
        
        var comps3 = cal.dateComponents([.year, .month, .day], from: Date())
        comps3.hour = 8
        comps3.minute = 0
        let date3 = cal.date(from: comps3) ?? Date()
        
        return [
            Alarm(
                time: date1,
                label: "Rise & Grind",
                isEnabled: true,
                repeatDays: [2, 3, 4, 5, 6],
                mission: MissionConfig(type: .pushups, pushupTargetReps: 15),
                sound: .nuclear,
                volume: 1.0,
                snoozeAllowed: false // HARDCORE: no snooze!
            ),
            Alarm(
                time: date2,
                label: "Morning Brain Sharpener",
                isEnabled: true,
                repeatDays: [2, 3, 4, 5, 6],
                mission: MissionConfig(type: .math, mathDifficulty: .hard, mathProblemCount: 3),
                sound: .hyperBeep,
                volume: 0.9,
                snoozeAllowed: true,
                snoozeMinutes: 5,
                maxSnoozeCount: 1
            ),
            Alarm(
                time: date3,
                label: "Coffee Hunt Wake-Up",
                isEnabled: false,
                repeatDays: [1, 7],
                mission: MissionConfig(type: .photoHunt, photoTarget: .coffeeMug),
                sound: .electroPulse,
                volume: 0.8,
                snoozeAllowed: true
            )
        ]
    }
}
