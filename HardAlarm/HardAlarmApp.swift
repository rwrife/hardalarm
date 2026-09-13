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
                    } else if CommandLine.arguments.contains("-testPuzzle2") {
                        alarmManager.triggerAlarm(Alarm.sampleAlarms[0])
                        alarmManager.currentPuzzleIndex = 2
                        alarmManager.currentPuzzleType = .memorySequence
                    } else if CommandLine.arguments.contains("-testPuzzle3") {
                        alarmManager.triggerAlarm(Alarm.sampleAlarms[0])
                        alarmManager.currentPuzzleIndex = 3
                        alarmManager.currentPuzzleType = .shakePhone
                    }
                }
        }
    }
}
