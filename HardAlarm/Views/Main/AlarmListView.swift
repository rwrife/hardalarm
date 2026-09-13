import SwiftUI

struct AlarmListView: View {
    @StateObject private var alarmManager = AlarmManager.shared
    @State private var editingAlarm: Alarm?
    @State private var isAddingAlarm: Bool = false
    @State private var currentTime = Date()
    let clockTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        return formatter.string(from: currentTime)
    }
    
    var activeAlarmString: String {
        if let active = alarmManager.activeAlarm {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return "Active Alarm: \(formatter.string(from: active.time))"
        }
        return "No Active Alarm"
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Header Clock: "07:15", "Rise & Shine!"
                VStack(spacing: 6) {
                    Text(timeFormatted)
                        .font(.system(size: 68, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(1)
                    
                    Text("Rise & Shine!")
                        .font(.system(size: 19, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.textMuted)
                }
                .padding(.top, 18)
                .padding(.bottom, 20)
                
                // Horizontal Navigation Tab Bar with Underline & Pip Dot
                TopTabBarView(selectedTab: $alarmManager.selectedTab)
                    .padding(.bottom, 20)
                
                // Tab Content Switcher
                switch alarmManager.selectedTab {
                case .alarms:
                    alarmsListContent
                case .challenges:
                    PuzzleCatalogView()
                case .history:
                    HistoryView(alarmManager: alarmManager)
                case .settings:
                    SettingsView(alarmManager: alarmManager)
                }
            }
            
            // Bottom Right Floating Action Button (+)
            if alarmManager.selectedTab == .alarms {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            Haptics.medium()
                            isAddingAlarm = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 58, height: 58)
                                .background(Circle().fill(Theme.primaryOrange))
                                .shadow(color: Theme.primaryOrange.opacity(0.4), radius: 10, x: 0, y: 4)
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            
            // Countdown Banner if test is triggered
            if let count = alarmManager.testCountdown {
                VStack {
                    HStack(spacing: 10) {
                        Image(systemName: "timer")
                            .font(.system(size: 18))
                            .foregroundColor(Theme.primaryOrange)
                        Text("ALARM RINGING IN \(count)...")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                        Spacer()
                        Button("Cancel") {
                            alarmManager.cancelTestCountdown()
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Theme.primaryOrange)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Theme.cardBackground)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.primaryOrange, lineWidth: 1.5))
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onReceive(clockTimer) { input in
            currentTime = input
        }
        .onAppear {
            if CommandLine.arguments.contains("-testEditor") || CommandLine.arguments.contains("-testEditorScroll") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isAddingAlarm = true
                }
            }
        }
        .sheet(isPresented: $isAddingAlarm) {
            AlarmEditView(
                alarm: Alarm(
                    time: Date().addingTimeInterval(3600),
                    label: "Work",
                    selectedChallenge: .random,
                    puzzlesRequired: 1
                ),
                isNew: true,
                onSave: { newAlarm in
                    alarmManager.addAlarm(newAlarm)
                }
            )
        }
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
        // Full Screen Ringing Alarm (reproducing Screen 2 & Screen 3)
        .fullScreenCover(isPresented: $alarmManager.isRinging) {
            WakeUpRingingView(alarmManager: alarmManager)
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
        .preferredColorScheme(.dark)
        .onAppear {
            NotificationManager.shared.requestAuthorization()
        }
    }
    
    // MARK: - Alarms List Content (Screen 1)
    
    private var alarmsListContent: some View {
        ScrollView {
            VStack(spacing: 14) {
                // Alarms List Cards
                ForEach(alarmManager.alarms) { alarm in
                    AlarmRowView(
                        alarm: alarm,
                        onToggle: {
                            alarmManager.toggleAlarm(alarm)
                        },
                        onEdit: {
                            editingAlarm = alarm
                        }
                    )
                }
                
                // Quick Test Pill
                Button(action: {
                    alarmManager.testAlarmInThreeSeconds()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 13))
                        Text("Test Ringing Alarm (3s)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(Theme.primaryOrange)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Theme.primaryOrange.opacity(0.12))
                            .overlay(Capsule().stroke(Theme.primaryOrange.opacity(0.3), lineWidth: 1))
                    )
                }
                .padding(.top, 4)
                
                Spacer().frame(height: 30)
                
                // Bottom Active Alarm Banner (from Screen 1)
                HStack {
                    Text(activeAlarmString)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Theme.cardBackground)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.cardBorder, lineWidth: 1))
                )
                .padding(.top, 10)
                
                Spacer().frame(height: 90)
            }
            .padding(.horizontal, 20)
        }
    }
}
