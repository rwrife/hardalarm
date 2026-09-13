import Foundation
import SwiftUI
import Combine

@MainActor
final class AlarmManager: ObservableObject {
    static let shared = AlarmManager()
    
    @Published var alarms: [Alarm] = []
    @Published var stats: UserWakeStats = UserWakeStats()
    
    // Active Ringing State
    @Published var ringingAlarm: Alarm?
    @Published var isRinging: Bool = false
    @Published var isMissionActive: Bool = false
    @Published var isCelebrationPresented: Bool = false
    @Published var testCountdown: Int? = nil
    
    // Timing & Stats
    @Published var wakeStartTime: Date? = nil
    @Published var lastCompletedRecord: WakeRecord? = nil
    @Published var currentSnoozesUsed: Int = 0
    @Published var snoozeRemainingSeconds: Int? = nil
    
    private var clockTimer: Timer?
    private var snoozeTimer: Timer?
    private var testTimer: Timer?
    
    private let alarmsKey = "HardAlarm_Alarms_Storage_v1"
    private let statsKey = "HardAlarm_Stats_Storage_v1"
    
    init() {
        loadData()
        startClockMonitor()
    }
    
    // MARK: - Persistence
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: alarmsKey),
           let decoded = try? JSONDecoder().decode([Alarm].self, from: data) {
            self.alarms = decoded
        } else {
            self.alarms = Alarm.sampleAlarms
            saveAlarms()
        }
        
        if let data = UserDefaults.standard.data(forKey: statsKey),
           let decoded = try? JSONDecoder().decode(UserWakeStats.self, from: data) {
            self.stats = decoded
        } else {
            self.stats = UserWakeStats()
            saveStats()
        }
    }
    
    func saveAlarms() {
        if let encoded = try? JSONEncoder().encode(alarms) {
            UserDefaults.standard.set(encoded, forKey: alarmsKey)
        }
    }
    
    func saveStats() {
        if let encoded = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(encoded, forKey: statsKey)
        }
    }
    
    // MARK: - Alarm Operations
    
    func addAlarm(_ alarm: Alarm) {
        alarms.append(alarm)
        alarms.sort { $0.time < $1.time }
        saveAlarms()
        NotificationManager.shared.scheduleAlarmNotification(alarm: alarm)
        Haptics.success()
    }
    
    func updateAlarm(_ alarm: Alarm) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index] = alarm
            alarms.sort { $0.time < $1.time }
            saveAlarms()
            NotificationManager.shared.scheduleAlarmNotification(alarm: alarm)
            Haptics.medium()
        }
    }
    
    func deleteAlarm(id: UUID) {
        NotificationManager.shared.cancelNotification(for: id)
        alarms.removeAll { $0.id == id }
        saveAlarms()
        Haptics.medium()
    }
    
    func toggleAlarm(_ alarm: Alarm) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index].isEnabled.toggle()
            saveAlarms()
            if alarms[index].isEnabled {
                NotificationManager.shared.scheduleAlarmNotification(alarm: alarms[index])
            } else {
                NotificationManager.shared.cancelNotification(for: alarm.id)
            }
            Haptics.light()
        }
    }
    
    // MARK: - Next Upcoming Alarm
    
    var nextAlarm: Alarm? {
        let enabledAlarms = alarms.filter { $0.isEnabled }
        guard !enabledAlarms.isEmpty else { return nil }
        
        let now = Date()
        return enabledAlarms.min {
            $0.nextTriggerDate(from: now) < $1.nextTriggerDate(from: now)
        }
    }
    
    var timeUntilNextAlarmString: String {
        guard let next = nextAlarm else { return "No active alarms" }
        let interval = next.nextTriggerDate().timeIntervalSince(Date())
        guard interval > 0 else { return "Ringing soon" }
        
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "Alarm in \(hours)h \(minutes)m"
        } else {
            return "Alarm in \(minutes) minutes"
        }
    }
    
    // MARK: - Clock Monitor
    
    private func startClockMonitor() {
        clockTimer?.invalidate()
        clockTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkAlarmTriggers()
            }
        }
    }
    
    private func checkAlarmTriggers() {
        guard !isRinging, snoozeRemainingSeconds == nil else { return }
        let now = Date()
        let cal = Calendar.current
        let currentHour = cal.component(.hour, from: now)
        let currentMin = cal.component(.minute, from: now)
        let currentSec = cal.component(.second, from: now)
        let currentWeekday = cal.component(.weekday, from: now)
        
        // Trigger right at the 00 second mark
        guard currentSec == 0 else { return }
        
        for alarm in alarms where alarm.isEnabled {
            let (aHour, aMin) = alarm.hourMinute
            if aHour == currentHour && aMin == currentMin {
                if alarm.repeatDays.isEmpty || alarm.repeatDays.contains(currentWeekday) {
                    triggerAlarm(alarm)
                    break
                }
            }
        }
    }
    
    // MARK: - Ringing & Missions
    
    func triggerAlarm(_ alarm: Alarm) {
        ringingAlarm = alarm
        isRinging = true
        isMissionActive = false
        isCelebrationPresented = false
        wakeStartTime = Date()
        currentSnoozesUsed = 0
        snoozeRemainingSeconds = nil
        
        SoundManager.shared.playAlarm(
            sound: alarm.sound,
            volume: alarm.volume,
            progressive: alarm.isProgressiveVolume
        )
        Haptics.heavy()
    }
    
    func startMission() {
        guard isRinging else { return }
        isMissionActive = true
        // Lower sound slightly during mission so user can hear cues/instructions
        // but still maintains urgency!
        Haptics.medium()
    }
    
    func completeMission() {
        guard let alarm = ringingAlarm else { return }
        
        let duration: Int
        if let start = wakeStartTime {
            duration = max(1, Int(Date().timeIntervalSince(start)))
        } else {
            duration = 30
        }
        
        SoundManager.shared.stopAlarm()
        
        stats.recordDismissal(
            alarmLabel: alarm.label.isEmpty ? "Morning Alarm" : alarm.label,
            mission: alarm.mission,
            durationSeconds: duration,
            snoozes: currentSnoozesUsed
        )
        saveStats()
        
        lastCompletedRecord = stats.records.first
        isMissionActive = false
        isRinging = false
        isCelebrationPresented = true
        
        Haptics.success()
    }
    
    func dismissCelebration() {
        isCelebrationPresented = false
        ringingAlarm = nil
        wakeStartTime = nil
    }
    
    // MARK: - Snooze Logic
    
    func snoozeAlarm() {
        guard let alarm = ringingAlarm, alarm.snoozeAllowed else { return }
        guard currentSnoozesUsed < alarm.maxSnoozeCount else { return }
        
        currentSnoozesUsed += 1
        isRinging = false
        isMissionActive = false
        SoundManager.shared.stopAlarm()
        
        let totalSeconds = alarm.snoozeMinutes * 60
        snoozeRemainingSeconds = totalSeconds
        
        snoozeTimer?.invalidate()
        snoozeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if let remaining = self.snoozeRemainingSeconds, remaining > 1 {
                    self.snoozeRemainingSeconds = remaining - 1
                } else {
                    self.snoozeTimer?.invalidate()
                    self.snoozeTimer = nil
                    self.snoozeRemainingSeconds = nil
                    if let alarm = self.ringingAlarm {
                        self.triggerAlarm(alarm)
                    }
                }
            }
        }
        Haptics.warning()
    }
    
    // MARK: - Testing / Simulator Utility
    
    func testAlarmInThreeSeconds(alarm: Alarm? = nil) {
        let target = alarm ?? alarms.first ?? Alarm.sampleAlarms[0]
        testCountdown = 3
        
        testTimer?.invalidate()
        testTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if let count = self.testCountdown, count > 1 {
                    self.testCountdown = count - 1
                } else {
                    self.testTimer?.invalidate()
                    self.testTimer = nil
                    self.testCountdown = nil
                    self.triggerAlarm(target)
                }
            }
        }
    }
    
    func cancelTestCountdown() {
        testTimer?.invalidate()
        testTimer = nil
        testCountdown = nil
    }
}
