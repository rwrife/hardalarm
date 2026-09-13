import SwiftUI

struct AlarmEditView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var alarm: Alarm
    let isNew: Bool
    let onSave: (Alarm) -> Void
    let onDelete: ((UUID) -> Void)?
    
    init(alarm: Alarm, isNew: Bool = false, onSave: @escaping (Alarm) -> Void, onDelete: ((UUID) -> Void)? = nil) {
        self._alarm = State(initialValue: alarm)
        self.isNew = isNew
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                ScrollView {
                    ScrollViewReader { proxy in
                        VStack(spacing: 24) {
                        // Time Picker Wheel
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Theme.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Theme.cardBorder, lineWidth: 1)
                                )
                            
                            DatePicker("", selection: $alarm.time, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .colorScheme(.dark)
                                .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
                        // Repeat Schedule Picker
                        repeatDaysCard
                            .padding(.horizontal)
                        
                        // Alarm Label & Quick Presets
                        NeonCard(accentColor: Theme.primaryOrange) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "tag.fill")
                                        .foregroundColor(Theme.primaryOrange)
                                    TextField("Label (e.g. Work, Gym)", text: $alarm.label)
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                
                                HStack(spacing: 8) {
                                    ForEach(["Work", "Gym", "Rise & Shine", "Study"], id: \.self) { preset in
                                        Button(action: {
                                            Haptics.light()
                                            alarm.label = preset
                                        }) {
                                            Text(preset)
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(alarm.label == preset ? .black : Theme.textMuted)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(
                                                    Capsule()
                                                        .fill(alarm.label == preset ? Theme.primaryOrange : Theme.cardInner)
                                                )
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Wake-Up Challenge Picker Card (Only need to select one)
                        NeonCard(accentColor: Theme.primaryOrange) {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(Theme.primaryOrange)
                                    Text("Wake-Up Challenge")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("Select 1 to Complete")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Theme.primaryOrange)
                                }
                                
                                Text("Complete this challenge to turn off the alarm in the morning")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Theme.textMuted)
                                
                                Divider().background(Theme.cardBorder)
                                
                                // Selectable Challenge Options (Physical & Cognitive)
                                VStack(spacing: 8) {
                                    ForEach(AlarmChallengeChoice.allCases) { choice in
                                        let isSelected = alarm.selectedChallenge == choice
                                        Button(action: {
                                            Haptics.light()
                                            alarm.selectedChallenge = choice
                                            alarm.puzzlesRequired = 1
                                        }) {
                                            HStack(spacing: 12) {
                                                ZStack {
                                                    Circle()
                                                        .fill(isSelected ? Theme.primaryOrange : Theme.cardInner)
                                                        .frame(width: 38, height: 38)
                                                    Image(systemName: choice.icon)
                                                        .font(.system(size: 16, weight: .bold))
                                                        .foregroundColor(isSelected ? .black : Theme.primaryOrange)
                                                }
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(choice.displayName)
                                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                                        .foregroundColor(isSelected ? .white : .white.opacity(0.85))
                                                    
                                                    Text(choice.subtitle)
                                                        .font(.system(size: 11, weight: .medium))
                                                        .foregroundColor(isSelected ? Theme.primaryOrange : Theme.textMuted)
                                                }
                                                
                                                Spacer()
                                                
                                                if isSelected {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.system(size: 20))
                                                        .foregroundColor(Theme.primaryOrange)
                                                } else {
                                                    Circle()
                                                        .stroke(Theme.cardBorder, lineWidth: 1.5)
                                                        .frame(width: 20, height: 20)
                                                }
                                            }
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .fill(isSelected ? Color(red: 0.16, green: 0.18, blue: 0.28) : Theme.cardInner)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 14)
                                                            .stroke(isSelected ? Theme.primaryOrange : Theme.cardBorder, lineWidth: 1)
                                                    )
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .id("challenges_card")
                        
                        // Sound & Volume Picker
                        SoundPickerView(
                            selectedSound: $alarm.sound,
                            volume: $alarm.volume,
                            isProgressive: $alarm.isProgressiveVolume
                        )
                        .padding(.horizontal)
                        
                        // Snooze / Hardcore Mode Card
                        snoozeSettingsCard
                            .padding(.horizontal)
                        
                        // Delete Button (if editing existing)
                        if !isNew, let onDelete = onDelete {
                            Button(role: .destructive, action: {
                                Haptics.warning()
                                onDelete(alarm.id)
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                    Text("Delete Alarm")
                                }
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Theme.neonRed)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Theme.neonRed.opacity(0.12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(Theme.neonRed.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                        
                        Spacer().frame(height: 40)
                    }
                    .onAppear {
                        if CommandLine.arguments.contains("-testEditorScroll") {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                withAnimation {
                                    proxy.scrollTo("challenges_card", anchor: .top)
                                }
                            }
                        }
                    }
                }
            }
            }
            .navigationTitle(isNew ? "New Alarm" : "Edit Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Haptics.success()
                        onSave(alarm)
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Theme.neonOrange)
                }
            }
        }
    }
    
    // MARK: - Repeat Days Card
    
    private var repeatDaysCard: some View {
        NeonCard(accentColor: Theme.neonBlue) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: "repeat")
                        .foregroundColor(Theme.neonBlue)
                    Text("REPEAT SCHEDULE")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.neonBlue)
                    Spacer()
                    Text(alarm.repeatDescription)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Day chips
                HStack(spacing: 8) {
                    ForEach(Weekday.allCases) { day in
                        let isSelected = alarm.repeatDays.contains(day.rawValue)
                        Button(action: {
                            Haptics.light()
                            if isSelected {
                                alarm.repeatDays.remove(day.rawValue)
                            } else {
                                alarm.repeatDays.insert(day.rawValue)
                            }
                        }) {
                            Text(day.singleLetter)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(isSelected ? .black : .white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 38)
                                .background(
                                    Circle()
                                        .fill(isSelected ? Theme.neonBlue : Theme.cardSubtle)
                                )
                        }
                    }
                }
                
                // Preset buttons
                HStack(spacing: 8) {
                    presetButton(title: "Weekdays") {
                        alarm.repeatDays = [2, 3, 4, 5, 6]
                    }
                    presetButton(title: "Weekends") {
                        alarm.repeatDays = [1, 7]
                    }
                    presetButton(title: "Every day") {
                        alarm.repeatDays = [1, 2, 3, 4, 5, 6, 7]
                    }
                    presetButton(title: "Once") {
                        alarm.repeatDays = []
                    }
                }
            }
        }
    }
    
    private func presetButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            Haptics.light()
            action()
        }) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Theme.cardSubtle)
                        .overlay(Capsule().stroke(Theme.cardBorder, lineWidth: 1))
                )
        }
    }
    
    // MARK: - Snooze / Hardcore Card
    
    private var snoozeSettingsCard: some View {
        NeonCard(accentColor: alarm.snoozeAllowed ? Theme.neonYellow : Theme.neonRed) {
            VStack(alignment: .leading, spacing: 14) {
                Toggle(isOn: $alarm.snoozeAllowed) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(alarm.snoozeAllowed ? "Allow Snooze" : "Hardcore Mode (No Snooze)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text(alarm.snoozeAllowed ? "Gives emergency grace periods" : "No snooze allowed. Mission must be solved immediately!")
                            .font(.system(size: 12))
                            .foregroundColor(alarm.snoozeAllowed ? .white.opacity(0.6) : Theme.neonRed)
                    }
                }
                .tint(Theme.neonYellow)
                
                if alarm.snoozeAllowed {
                    Divider().background(Theme.cardBorder)
                    
                    HStack {
                        Text("Snooze Duration")
                            .foregroundColor(.white)
                        Spacer()
                        Picker("Minutes", selection: $alarm.snoozeMinutes) {
                            Text("3 min").tag(3)
                            Text("5 min").tag(5)
                            Text("9 min").tag(9)
                            Text("15 min").tag(15)
                        }
                        .pickerStyle(.menu)
                        .tint(Theme.neonYellow)
                    }
                    
                    HStack {
                        Text("Max Snoozes Allowed")
                            .foregroundColor(.white)
                        Spacer()
                        Picker("Count", selection: $alarm.maxSnoozeCount) {
                            Text("1 time").tag(1)
                            Text("2 times").tag(2)
                            Text("3 times").tag(3)
                        }
                        .pickerStyle(.menu)
                        .tint(Theme.neonYellow)
                    }
                }
            }
        }
    }
}
