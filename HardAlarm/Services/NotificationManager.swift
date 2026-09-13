import Foundation
import UserNotifications

@MainActor
final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    @Published var isAuthorized: Bool = false
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkAuthorization()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            Task { @MainActor in
                self?.isAuthorized = granted
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
    
    func scheduleAlarmNotification(alarm: Alarm) {
        guard alarm.isEnabled else {
            cancelNotification(for: alarm.id)
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "⏰ ALARM: \(alarm.label.isEmpty ? "Wake Up!" : alarm.label)"
        content.body = "Mission Required: \(alarm.mission.summaryText). Dismiss challenge to silence!"
        content.sound = .defaultCritical
        content.categoryIdentifier = "ALARM_CATEGORY"
        content.userInfo = ["alarmId": alarm.id.uuidString]
        
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
    
    // Present notification while app is in foreground
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
