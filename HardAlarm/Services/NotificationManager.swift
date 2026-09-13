import Foundation
import UserNotifications

@MainActor
final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    @Published var isAuthorized: Bool = false
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        setupCategories()
        checkAuthorization()
    }
    
    // MARK: - Categories & Actions
    
    private func setupCategories() {
        let solveAction = UNNotificationAction(
            identifier: "START_MISSION_ACTION",
            title: "⚡ Solve Mission to Silence",
            options: [.foreground]
        )
        
        let alarmCategory = UNNotificationCategory(
            identifier: "ALARM_CATEGORY",
            actions: [solveAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() {
        // Standard notification authorization (alert, sound, badge) - no restricted profile needed
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { [weak self] granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
            Task { @MainActor in
                self?.checkAuthorization()
            }
        }
    }
    
    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            let isAuth = (settings.authorizationStatus == .authorized)
            Task { @MainActor in
                self?.isAuthorized = isAuth
            }
        }
    }
    
    // MARK: - Sound Resolution
    
    private func resolveNotificationSound(for sound: AlarmSound) -> UNNotificationSound {
        let filename = "\(sound.rawValue).wav"
        if let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first {
            let soundPath = libraryURL.appendingPathComponent("Sounds").appendingPathComponent(filename).path
            if FileManager.default.fileExists(atPath: soundPath) {
                return UNNotificationSound(named: UNNotificationSoundName(filename))
            }
        }
        return .default
    }
    
    // MARK: - Scheduling (Safety Net Notifications)
    
    func scheduleAlarmNotification(alarm: Alarm) {
        guard alarm.isEnabled else {
            cancelNotification(for: alarm.id)
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "⏰ ALARM: \(alarm.label.isEmpty ? "Wake Up!" : alarm.label)"
        content.body = "Mission Required: \(alarm.mission.summaryText). Dismiss challenge to silence!"
        content.categoryIdentifier = "ALARM_CATEGORY"
        content.userInfo = ["alarmId": alarm.id.uuidString]
        content.interruptionLevel = .timeSensitive // Bypasses Focus / Do Not Disturb on iOS 15+ without special profile
        content.sound = resolveNotificationSound(for: alarm.sound)
        
        let triggerDate = alarm.nextTriggerDate()
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: alarm.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    func cancelNotification(for alarmId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarmId.uuidString])
    }
    
    // MARK: - Immediate Alarm Fired Notification (when triggered by background audio)
    
    func postAlarmFiredNotification(alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "⏰ ALARM RINGING: \(alarm.label.isEmpty ? "Wake Up!" : alarm.label)"
        content.body = "Tap to solve \(alarm.mission.summaryText) and silence alarm!"
        content.categoryIdentifier = "ALARM_CATEGORY"
        content.userInfo = ["alarmId": alarm.id.uuidString]
        content.interruptionLevel = .timeSensitive
        // Background audio is already playing loud sound through AVAudioPlayer,
        // so standard default sound or vibration accompanies the visual banner
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "ACTIVE_\(alarm.id.uuidString)",
            content: content,
            trigger: nil // Immediate delivery
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to post immediate alarm notification: \(error)")
            }
        }
    }
    
    // MARK: - Delegate Callbacks
    
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge, .list])
    }
    
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let alarmIdString = userInfo["alarmId"] as? String
        
        DispatchQueue.main.async {
            let alarmId = alarmIdString.flatMap { UUID(uuidString: $0) }
            let targetAlarm = (alarmId != nil ? AlarmManager.shared.alarms.first(where: { $0.id == alarmId }) : nil)
                ?? AlarmManager.shared.ringingAlarm
                ?? AlarmManager.shared.activeAlarm
                ?? AlarmManager.shared.alarms.first
                ?? Alarm.sampleAlarms[0]
            
            AlarmManager.shared.triggerAlarm(targetAlarm, fromNotificationTap: true)
        }
        completionHandler()
    }
}
