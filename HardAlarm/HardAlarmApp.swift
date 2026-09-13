import SwiftUI

@main
struct HardAlarmApp: App {
    @StateObject private var alarmManager = AlarmManager.shared
    @StateObject private var soundManager = SoundManager.shared
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        // Crucial: Initialize NotificationManager before launch completes
        // so UNUserNotificationCenter delegate is registered to handle notification taps
        _ = NotificationManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                AlarmListView()
                    .environmentObject(alarmManager)
                    .environmentObject(soundManager)
                
                // Overlay active ringing alarm challenge
                if alarmManager.isRinging {
                    WakeUpRingingView(alarmManager: alarmManager)
                        .transition(.opacity)
                        .zIndex(999)
                }
                
                // Overlay completion celebration
                if alarmManager.isCelebrationPresented {
                    AlarmSuccessView(
                        record: alarmManager.lastCompletedRecord,
                        streakDays: alarmManager.stats.streakDays,
                        onDismiss: {
                            alarmManager.dismissCelebration()
                        }
                    )
                    .transition(.opacity)
                    .zIndex(1000)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: alarmManager.isRinging)
            .animation(.easeInOut(duration: 0.25), value: alarmManager.isCelebrationPresented)
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .background {
                    alarmManager.handleDidEnterBackground()
                } else if newPhase == .active {
                    alarmManager.handleWillEnterForeground()
                }
            }
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
                } else if CommandLine.arguments.contains("-testSliders") || CommandLine.arguments.contains("-testDualSliders") {
                    alarmManager.triggerAlarm(Alarm.sampleAlarms[0])
                    alarmManager.currentChallengeType = .dualSliders
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
