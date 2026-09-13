import SwiftUI

struct AlarmListView: View {
    @StateObject private var alarmManager = AlarmManager.shared
    @State private var editingAlarm: Alarm?
    @State private var isAddingAlarm: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 18) {
                        // Top Branding Header
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(Theme.neonOrange)
                                        .font(.system(size: 24))
                                    Text("HardAlarm")
                                        .font(.system(size: 32, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Text("iOS 26")
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundColor(Theme.neonOrange)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Capsule().fill(Theme.neonOrange.opacity(0.18)))
                                }
                                Text("Wake-up challenges that break morning inertia")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                Haptics.medium()
                                isAddingAlarm = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Circle().fill(Theme.neonOrange))
                                    .shadow(color: Theme.neonOrange.opacity(0.4), radius: 8)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                        
                        // Countdown Banner if test is triggered
                        if let count = alarmManager.testCountdown {
                            HStack(spacing: 10) {
                                Image(systemName: "timer")
                                    .font(.system(size: 18))
                                    .foregroundColor(Theme.neonRed)
                                Text("ALARM RINGING IN \(count) SECONDS...")
                                    .font(.system(size: 14, weight: .black, design: .monospaced))
                                    .foregroundColor(Theme.neonRed)
                                Spacer()
                                Button("Cancel") {
                                    alarmManager.cancelTestCountdown()
                                }
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Theme.neonRed.opacity(0.2))
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.neonRed, lineWidth: 1.5))
                            )
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Snooze Active Banner
                        if let snoozeRemaining = alarmManager.snoozeRemainingSeconds {
                            HStack(spacing: 10) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .foregroundColor(Theme.neonYellow)
                                Text("SNOOZED: Resumes in \(snoozeRemaining / 60)m \(snoozeRemaining % 60)s")
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundColor(Theme.neonYellow)
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Theme.neonYellow.opacity(0.15))
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.neonYellow, lineWidth: 1))
                            )
                        }
                        
                        // Stats & Next Alarm Header
                        StatsHeaderView(
                            nextAlarmString: alarmManager.timeUntilNextAlarmString,
                            stats: alarmManager.stats,
                            onQuickTest: {
                                alarmManager.testAlarmInThreeSeconds()
                            }
                        )
                        
                        // Section Header
                        HStack {
                            Text("ACTIVE ALARMS")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.5))
                            Spacer()
                            Text("\(alarmManager.alarms.count) Configured")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .padding(.top, 8)
                        
                        // Alarms List
                        if alarmManager.alarms.isEmpty {
                            emptyStateView
                        } else {
                            VStack(spacing: 14) {
                                ForEach(alarmManager.alarms) { alarm in
                                    AlarmRowView(
                                        alarm: alarm,
                                        onToggle: {
                                            alarmManager.toggleAlarm(alarm)
                                        },
                                        onTest: {
                                            alarmManager.testAlarmInThreeSeconds(alarm: alarm)
                                        }
                                    )
                                    .onTapGesture {
                                        editingAlarm = alarm
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            alarmManager.deleteAlarm(id: alarm.id)
                                        } label: {
                                            Label("Delete Alarm", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                        
                        Spacer().frame(height: 50)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
            }
            .navigationBarHidden(true)
            // Add Alarm Sheet
            .sheet(isPresented: $isAddingAlarm) {
                AlarmEditView(
                    alarm: Alarm(
                        time: Date().addingTimeInterval(3600),
                        label: "Morning Mission",
                        mission: MissionConfig(type: .pushups, pushupTargetReps: 10)
                    ),
                    isNew: true,
                    onSave: { newAlarm in
                        alarmManager.addAlarm(newAlarm)
                    }
                )
            }
            // Edit Alarm Sheet
            .sheet(item: $editingAlarm) { alarm in
                AlarmEditView(
                    alarm: alarm,
                    isNew: false,
                    onSave: { updated in
                        alarmManager.updateAlarm(updated)
                    },
                    onDelete: { id in
                        alarmManager.deleteAlarm(id: id)
                    }
                )
            }
            // Full Screen Ringing Alert
            .fullScreenCover(isPresented: $alarmManager.isRinging) {
                if let alarm = alarmManager.ringingAlarm {
                    if alarmManager.isMissionActive {
                        MissionActiveView(
                            mission: alarm.mission,
                            onMissionComplete: {
                                alarmManager.completeMission()
                            },
                            onCancel: nil
                        )
                    } else {
                        AlarmRingingView(
                            alarm: alarm,
                            onStartMission: {
                                alarmManager.startMission()
                            },
                            onSnooze: {
                                alarmManager.snoozeAlarm()
                            }
                        )
                    }
                }
            }
            // Full Screen Celebration
            .fullScreenCover(isPresented: $alarmManager.isCelebrationPresented) {
                AlarmSuccessView(
                    record: alarmManager.lastCompletedRecord,
                    streakDays: alarmManager.stats.streakDays,
                    onDismiss: {
                        alarmManager.dismissCelebration()
                    }
                )
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            NotificationManager.shared.requestAuthorization()
            if CommandLine.arguments.contains("-testEditor") {
                editingAlarm = alarmManager.alarms.first
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "alarm.waves.left.and.right.fill")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.3))
                .padding(.top, 40)
            
            Text("No Alarms Scheduled")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text("Tap the + button to create your first wake-up challenge alarm.")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                isAddingAlarm = true
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Alarm")
                }
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Theme.neonOrange)
                )
            }
            .padding(.top, 8)
        }
    }
}
