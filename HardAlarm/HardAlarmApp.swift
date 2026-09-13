import SwiftUI

@main
struct HardAlarmApp: App {
    @StateObject private var alarmManager = AlarmManager.shared
    @StateObject private var soundManager = SoundManager.shared
    
    var body: some Scene {
        WindowGroup {
            AlarmListView()
                .environmentObject(alarmManager)
                .environmentObject(soundManager)
                .onAppear {
                    if CommandLine.arguments.contains("-testRinging") {
                        alarmManager.triggerAlarm(Alarm.sampleAlarms[0])
                    } else if CommandLine.arguments.contains("-testMission") {
                        alarmManager.triggerAlarm(Alarm.sampleAlarms[0])
                        alarmManager.startMission()
                    }
                }
        }
    }
}
