import SwiftUI

struct MissionSelectorView: View {
    @Binding var mission: MissionConfig
    @State private var previewingMission: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("CHOOSE WAKE-UP MISSION")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(Theme.neonOrange)
            
            // Grid of Missions
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(MissionType.allCases) { type in
                    let isSelected = mission.type == type
                    
                    Button(action: {
                        Haptics.light()
                        mission.type = type
                    }) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(type.accentColor.opacity(isSelected ? 0.3 : 0.15))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: type.icon)
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(type.accentColor)
                                }
                                Spacer()
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(type.accentColor)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(type.title)
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Text(type.shortDescription)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                    .lineLimit(2)
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isSelected ? Theme.cardSubtle : Theme.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(isSelected ? type.accentColor : Theme.cardBorder, lineWidth: isSelected ? 1.8 : 1)
                                )
                        )
                    }
                }
            }
            
            // Tailored Mission Parameter Controls
            NeonCard(accentColor: mission.type.accentColor) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(mission.type.accentColor)
                        Text("MISSION SETTINGS: \(mission.type.title.uppercased())")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(mission.type.accentColor)
                    }
                    
                    switch mission.type {
                    case .pushups:
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Repetitions")
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(mission.pushupTargetReps) reps")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.neonOrange)
                            }
                            Slider(
                                value: Binding(
                                    get: { Double(mission.pushupTargetReps) },
                                    set: { mission.pushupTargetReps = Int($0) }
                                ),
                                in: 5...30,
                                step: 1
                            )
                            .tint(Theme.neonOrange)
                            Text("Sensors detect chest lowering to floor.")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                    case .squats:
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Squat Count")
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(mission.squatTargetReps) squats")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.neonYellow)
                            }
                            Slider(
                                value: Binding(
                                    get: { Double(mission.squatTargetReps) },
                                    set: { mission.squatTargetReps = Int($0) }
                                ),
                                in: 5...30,
                                step: 1
                            )
                            .tint(Theme.neonYellow)
                        }
                        
                    case .math:
                        VStack(alignment: .leading, spacing: 14) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Difficulty")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Picker("Difficulty", selection: $mission.mathDifficulty) {
                                    ForEach(MathDifficulty.allCases) { diff in
                                        Text(diff.rawValue).tag(diff)
                                    }
                                }
                                .pickerStyle(.segmented)
                                
                                Text(mission.mathDifficulty.description)
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.top, 2)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("Number of Problems")
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(mission.mathProblemCount) problems")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(Theme.neonBlue)
                                }
                                Stepper("", value: $mission.mathProblemCount, in: 1...10)
                            }
                        }
                        
                    case .photoHunt:
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Required Household Target:")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Picker("Target Item", selection: $mission.photoTarget) {
                                ForEach(PhotoTarget.allCases) { target in
                                    Text(target.rawValue).tag(target)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(Theme.neonGreen)
                            
                            Text(mission.photoTarget.destinationHint)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Theme.neonGreen)
                        }
                        
                    case .shake:
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Target Energy / Shakes")
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(mission.shakeGoal) shakes")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.neonRed)
                            }
                            Slider(
                                value: Binding(
                                    get: { Double(mission.shakeGoal) },
                                    set: { mission.shakeGoal = Int($0) }
                                ),
                                in: 20...100,
                                step: 5
                            )
                            .tint(Theme.neonRed)
                        }
                        
                    case .memory:
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Pattern Sequence Length")
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(mission.memoryLength) steps")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.neonPurple)
                            }
                            Slider(
                                value: Binding(
                                    get: { Double(mission.memoryLength) },
                                    set: { mission.memoryLength = Int($0) }
                                ),
                                in: 3...8,
                                step: 1
                            )
                            .tint(Theme.neonPurple)
                        }
                        
                    case .steps:
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Step Goal")
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(mission.stepGoal) steps")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.neonBlue)
                            }
                            Slider(
                                value: Binding(
                                    get: { Double(mission.stepGoal) },
                                    set: { mission.stepGoal = Int($0) }
                                ),
                                in: 10...50,
                                step: 5
                            )
                            .tint(Theme.neonBlue)
                        }
                        
                    case .voice:
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Morning Affirmation Phrase:")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            
                            TextField("Enter affirmation quote", text: $mission.voiceAffirmation)
                                .textFieldStyle(.plain)
                                .padding(10)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Theme.cardSubtle))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Divider().background(Theme.cardBorder)
                    
                    // Preview Button
                    Button(action: {
                        previewingMission = true
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Preview This Challenge Now")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(mission.type.accentColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(mission.type.accentColor.opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(mission.type.accentColor.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $previewingMission) {
            MissionActiveView(
                mission: mission,
                onMissionComplete: {
                    previewingMission = false
                },
                onCancel: {
                    previewingMission = false
                }
            )
        }
    }
}
