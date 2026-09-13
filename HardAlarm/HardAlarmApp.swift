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
                    } else if CommandLine.arguments.contains("-testMath") {
                        alarmManager.triggerAlarm(Alarm.sampleAlarms[0])
                        alarmManager.currentChallengeType = .mathMatch
                    } else if CommandLine.arguments.contains("-testMemory") || CommandLine.arguments.contains("-testPuzzle2") {
                        alarmManager.triggerAlarm(Alarm.sampleAlarms[0])
                        alarmManager.currentChallengeType = .memorySequence
                    } else if CommandLine.arguments.contains("-testPushups") {
                        alarmManager.triggerAlarm(Alarm.sampleAlarms[0])
                        alarmManager.currentChallengeType = .pushups
                    } else if CommandLine.arguments.contains("-testPhoto") {
                        alarmManager.triggerAlarm(Alarm.sampleAlarms[0])
                        alarmManager.currentChallengeType = .photoHunt
                    } else if CommandLine.arguments.contains("-testSquats") {
                        alarmManager.triggerAlarm(Alarm.sampleAlarms[0])
                        alarmManager.currentChallengeType = .squats
                    } else if CommandLine.arguments.contains("-testShake") || CommandLine.arguments.contains("-testPuzzle3") {
                        alarmManager.triggerAlarm(Alarm.sampleAlarms[0])
                        alarmManager.currentChallengeType = .shakePhone
                    } else if CommandLine.arguments.contains("-testChallengesTab") {
                        alarmManager.selectedTab = .challenges
                    } else if CommandLine.arguments.contains("-testCelebration") {
                        alarmManager.stats.recordDismissal(
                            alarmLabel: "Rise & Shine",
                            mission: MissionConfig(type: .pushups, pushupTargetReps: 10),
                            durationSeconds: 42,
                            snoozes: 0
                        )
                        alarmManager.lastCompletedRecord = alarmManager.stats.records.first
                        alarmManager.isCelebrationPresented = true
                    }
                }
        }
    }
}
