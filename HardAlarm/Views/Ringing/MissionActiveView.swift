import SwiftUI

struct MissionActiveView: View {
    let mission: MissionConfig
    let onMissionComplete: () -> Void
    let onCancel: (() -> Void)? // Optional preview cancel
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    if let cancel = onCancel {
                        Button("Cancel Preview") {
                            cancel()
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    } else {
                        // In real ringing alarm, no easy way out!
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Theme.neonRed)
                                .frame(width: 8, height: 8)
                            Text("ACTIVE WAKE-UP MISSION")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(Theme.neonRed)
                        }
                    }
                    
                    Spacer()
                    
                    MissionBadge(mission: mission)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Mission Body
                Group {
                    switch mission.type {
                    case .pushups:
                        PushupsMissionView(
                            targetReps: mission.pushupTargetReps,
                            onComplete: onMissionComplete
                        )
                    case .squats:
                        SquatsMissionView(
                            targetReps: mission.squatTargetReps,
                            onComplete: onMissionComplete
                        )
                    case .math:
                        MathMissionView(
                            difficulty: mission.mathDifficulty,
                            targetProblems: mission.mathProblemCount,
                            onComplete: onMissionComplete
                        )
                    case .photoHunt:
                        PhotoHuntMissionView(
                            target: mission.photoTarget,
                            onComplete: onMissionComplete
                        )
                    case .shake:
                        ShakeMissionView(
                            goalShakes: mission.shakeGoal,
                            onComplete: onMissionComplete
                        )
                    case .memory:
                        MemoryMissionView(
                            targetLength: mission.memoryLength,
                            onComplete: onMissionComplete
                        )
                    case .steps:
                        StepsMissionView(
                            targetSteps: mission.stepGoal,
                            onComplete: onMissionComplete
                        )
                    case .voice:
                        VoiceMissionView(
                            affirmation: mission.voiceAffirmation,
                            onComplete: onMissionComplete
                        )
                    }
                }
            }
        }
    }
}
