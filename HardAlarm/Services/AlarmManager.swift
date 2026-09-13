import Foundation
import SwiftUI
import Combine

enum ActiveTab: String, CaseIterable, Identifiable {
    case alarms = "Alarms"
    case challenges = "Challenges"
    case history = "History"
    case settings = "Settings"
    
    var id: String { rawValue }
    
    static var puzzles: ActiveTab { .challenges }
}

@MainActor
final class AlarmManager: ObservableObject {
    static let shared = AlarmManager()
    
    @Published var selectedTab: ActiveTab = .alarms
    @Published var alarms: [Alarm] = []
    @Published var stats: UserWakeStats = UserWakeStats()
    
    // Active Ringing & Challenge Session State
    @Published var ringingAlarm: Alarm?
    @Published var isRinging: Bool = false
    @Published var currentPuzzleIndex: Int = 1 // 1, 2, 3...
    @Published var totalPuzzlesRequired: Int = 1
    @Published var currentChallengeType: ChallengeType = .mathMatch
    var currentPuzzleType: ChallengeType {
        get { currentChallengeType }
        set { currentChallengeType = newValue }
    }
    @Published var activeChallengeSequence: [ChallengeType] = []
    var activePuzzleSequence: [ChallengeType] {
        get { activeChallengeSequence }
        set { activeChallengeSequence = newValue }
    }
    @Published var isAlarmSoundActive: Bool = true
    @Published var isCelebrationPresented: Bool = false
    @Published var lastCompletedRecord: WakeRecord? = nil
    
    // Testing & Timers
    @Published var testCountdown: Int? = nil
    @Published var wakeStartTime: Date? = nil
    
    private var clockTimer: Timer?
    private var testTimer: Timer?
    
    private let alarmsKey = "HardAlarm_Alarms_Storage_v2"
    private let statsKey = "HardAlarm_Stats_Storage_v2"
    
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
    
    // MARK: - Alarms CRUD
    
    func addAlarm(_ alarm: Alarm) {
        alarms.append(alarm)
        alarms.sort { $0.time < $1.time }
        saveAlarms()
        NotificationManager.shared.scheduleAlarmNotification(alarm: alarm)
        Haptics.success()
    }
    
    func updateAlarm(_ alarm: Alarm) {
        if let idx = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[idx] = alarm
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
        if let idx = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[idx].isEnabled.toggle()
            saveAlarms()
            if alarms[idx].isEnabled {
                NotificationManager.shared.scheduleAlarmNotification(alarm: alarms[idx])
            } else {
                NotificationManager.shared.cancelNotification(for: alarm.id)
            }
            Haptics.light()
        }
    }
    
    var activeAlarm: Alarm? {
        alarms.first(where: { $0.isEnabled })
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
        guard !isRinging else { return }
        let now = Date()
        let cal = Calendar.current
        let currentHour = cal.component(.hour, from: now)
        let currentMin = cal.component(.minute, from: now)
        let currentSec = cal.component(.second, from: now)
        let currentWeekday = cal.component(.weekday, from: now)
        
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
    
    // MARK: - Background Audio Lifecycle Management
    
    func handleDidEnterBackground() {
        if alarms.contains(where: { $0.isEnabled }) {
            SoundManager.shared.startSilentKeepAlive()
        }
    }
    
    func handleWillEnterForeground() {
        if !isRinging {
            SoundManager.shared.stopSilentKeepAlive()
        }
    }
    
    // MARK: - Trigger Alarm
    
    func triggerAlarm(_ alarm: Alarm, fromNotificationTap: Bool = false) {
        ringingAlarm = alarm
        isRinging = true
        currentPuzzleIndex = 1
        totalPuzzlesRequired = 1
        
        // Resolve selected challenge (for .random, evaluates day-by-day deterministic choice across all physical tasks and puzzles)
        let resolved = alarm.selectedChallenge.resolveChallengeType(for: Date())
        activeChallengeSequence = [resolved]
        currentChallengeType = resolved
        isAlarmSoundActive = true
        isCelebrationPresented = false
        wakeStartTime = Date()
        
        // Only post notification banner if not already responding to a tap
        if !fromNotificationTap {
            NotificationManager.shared.postAlarmFiredNotification(alarm: alarm)
        }
        
        // Start playing loud siren (bypasses mute switch via .playback)
        SoundManager.shared.playAlarm(sound: alarm.sound, volume: alarm.volume, progressive: alarm.isProgressiveVolume)
        Haptics.heavy()
    }
    
    func toggleAlarmSound() {
        isAlarmSoundActive.toggle()
        if isAlarmSoundActive {
            if let alarm = ringingAlarm {
                SoundManager.shared.playAlarm(sound: alarm.sound, volume: 1.0, progressive: false)
            }
        } else {
            SoundManager.shared.stopAlarm()
        }
        Haptics.light()
    }
    
    // MARK: - Puzzle Progression
    
    func completeCurrentPuzzle() {
        Haptics.success()
        
        if currentPuzzleIndex < totalPuzzlesRequired {
            currentPuzzleIndex += 1
            if currentPuzzleIndex - 1 < activePuzzleSequence.count {
                currentPuzzleType = activePuzzleSequence[currentPuzzleIndex - 1]
            } else {
                currentPuzzleType = .mathMatch
            }
        } else {
            // All required puzzles conquered! Deactivate alarm!
            finishAlarmChallenge()
        }
    }
    
    private func finishAlarmChallenge() {
        guard let alarm = ringingAlarm else { return }
        
        SoundManager.shared.stopAlarm()
        
        let duration: Int
        if let start = wakeStartTime {
            duration = max(1, Int(Date().timeIntervalSince(start)))
        } else {
            duration = 35
        }
        
        stats.recordDismissal(
            alarmLabel: alarm.label.isEmpty ? "Wake Up" : alarm.label,
            mission: alarm.mission,
            durationSeconds: duration,
            snoozes: 0
        )
        saveStats()
        
        lastCompletedRecord = stats.records.first
        isRinging = false
        isCelebrationPresented = true
        Haptics.success()
    }
    
    func dismissCelebration() {
        isCelebrationPresented = false
        ringingAlarm = nil
        wakeStartTime = nil
    }
    
    // MARK: - Test Trigger
    
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
