import SwiftUI

enum SliderDirection: String, CaseIterable, Equatable {
    case up = "UP"
    case down = "DOWN"
    case stay = "STAY"
    
    var arrow: String {
        switch self {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .stay: return "minus"
        }
    }
}

struct SliderInstruction: Equatable {
    let left: SliderDirection
    let right: SliderDirection
    
    var title: String {
        switch (left, right) {
        case (.up, .down):
            return "LEFT UP  ⬆️   •   RIGHT DOWN  ⬇️"
        case (.down, .up):
            return "LEFT DOWN  ⬇️   •   RIGHT UP  ⬆️"
        case (.up, .up):
            return "SLIDE BOTH SLIDERS UP  ⬆️ ⬆️"
        case (.down, .down):
            return "SLIDE BOTH SLIDERS DOWN  ⬇️ ⬇️"
        case (.up, .stay):
            return "SLIDE LEFT UP ONLY  ⬆️"
        case (.down, .stay):
            return "SLIDE LEFT DOWN ONLY  ⬇️"
        case (.stay, .up):
            return "SLIDE RIGHT UP ONLY  ⬆️"
        case (.stay, .down):
            return "SLIDE RIGHT DOWN ONLY  ⬇️"
        default:
            return "FOLLOW TARGET ARROWS"
        }
    }
    
    static func generate(excluding: SliderInstruction? = nil) -> SliderInstruction {
        let pool: [SliderInstruction] = [
            SliderInstruction(left: .up, right: .down),
            SliderInstruction(left: .down, right: .up),
            SliderInstruction(left: .up, right: .up),
            SliderInstruction(left: .down, right: .down),
            SliderInstruction(left: .up, right: .stay),
            SliderInstruction(left: .down, right: .stay),
            SliderInstruction(left: .stay, right: .up),
            SliderInstruction(left: .stay, right: .down)
        ]
        let filtered = pool.filter { $0 != excluding }
        return filtered.randomElement() ?? pool[0]
    }
}

struct DualSlidersPuzzleView: View {
    let onSolveCompleted: () -> Void
    
    // Game configuration: 3 quick rounds
    private let totalRounds: Int = 3
    @State private var currentRound: Int = 1
    @State private var instruction: SliderInstruction = SliderInstruction.generate()
    
    // Slider state
    @State private var leftOffset: CGFloat = 0
    @State private var rightOffset: CGFloat = 0
    @State private var isLeftLocked: Bool = false
    @State private var isRightLocked: Bool = false
    
    // Visual feedback
    @State private var isRoundSolved: Bool = false
    @State private var isPuzzleSolved: Bool = false
    @State private var pulsePrompt: Bool = false
    
    // Slider geometry
    private let maxTravel: CGFloat = 58
    private let threshold: CGFloat = 46
    
    var body: some View {
        VStack(spacing: 12) {
            // Header & Round Progress
            HStack {
                Text("Dual Sliders")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Step \(currentRound) of \(totalRounds)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Theme.primaryOrange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Theme.primaryOrange.opacity(0.15)))
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)
            
            // Instruction Banner
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.14, green: 0.16, blue: 0.25))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isRoundSolved ? Theme.neonGreen : (pulsePrompt ? Theme.primaryOrange : Theme.cardBorder),
                                lineWidth: 1.5
                            )
                    )
                
                if isRoundSolved {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Theme.neonGreen)
                        Text(currentRound >= totalRounds ? "ALARM DISMISSED!" : "STEP COMPLETE!")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundColor(Theme.neonGreen)
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    Text(instruction.title)
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
            }
            .frame(height: 38)
            .padding(.horizontal, 16)
            .animation(.easeInOut(duration: 0.2), value: isRoundSolved)
            
            // Sliders Container
            HStack(spacing: 48) {
                // LEFT SLIDER
                sliderColumn(
                    label: "LEFT",
                    accentColor: Theme.tileCyan,
                    targetDirection: instruction.left,
                    offset: $leftOffset,
                    isLocked: isLeftLocked,
                    onDragChanged: { val in
                        handleDrag(isLeft: true, translationY: val)
                    },
                    onDragEnded: {
                        handleDragEnd(isLeft: true)
                    }
                )
                
                // RIGHT SLIDER
                sliderColumn(
                    label: "RIGHT",
                    accentColor: Theme.primaryOrange,
                    targetDirection: instruction.right,
                    offset: $rightOffset,
                    isLocked: isRightLocked,
                    onDragChanged: { val in
                        handleDrag(isLeft: false, translationY: val)
                    },
                    onDragEnded: {
                        handleDragEnd(isLeft: false)
                    }
                )
            }
            .padding(.vertical, 4)
            
            // Simulator Quick-Action Assist
            Button(action: {
                solveCurrentStepAutomatically()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "hand.draw.fill")
                    Text("Auto-Slide (Demo)")
                }
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Theme.textMuted)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color(red: 0.16, green: 0.18, blue: 0.28)))
            }
            .padding(.bottom, 6)
        }
        .onAppear {
            setupRound()
        }
    }
    
    // MARK: - Single Slider Column View
    
    private func sliderColumn(
        label: String,
        accentColor: Color,
        targetDirection: SliderDirection,
        offset: Binding<CGFloat>,
        isLocked: Bool,
        onDragChanged: @escaping (CGFloat) -> Void,
        onDragEnded: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 8) {
            // Label & Direction Pip
            HStack(spacing: 4) {
                Circle()
                    .fill(accentColor)
                    .frame(width: 8, height: 8)
                Text(label)
                    .font(.system(size: 12, weight: .black, design: .monospaced))
                    .foregroundColor(accentColor)
            }
            
            // Vertical Track Container
            ZStack {
                // Background Track Pill
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color(red: 0.12, green: 0.13, blue: 0.20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(isLocked ? Theme.neonGreen : Theme.cardBorder, lineWidth: 1.5)
                    )
                    .frame(width: 58, height: 180)
                
                // Center Rest Line
                Rectangle()
                    .fill(Theme.cardBorder)
                    .frame(width: 32, height: 2)
                
                // Top Target Indicator
                VStack {
                    ZStack {
                        Circle()
                            .fill(targetDirection == .up ? (isLocked ? Theme.neonGreen : accentColor.opacity(0.25)) : Color.clear)
                            .frame(width: 34, height: 34)
                        
                        Image(systemName: isLocked && targetDirection == .up ? "checkmark" : "arrow.up")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(targetDirection == .up ? (isLocked ? .black : accentColor) : Theme.textMuted.opacity(0.3))
                    }
                    .padding(.top, 8)
                    Spacer()
                }
                .frame(width: 58, height: 180)
                
                // Bottom Target Indicator
                VStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(targetDirection == .down ? (isLocked ? Theme.neonGreen : accentColor.opacity(0.25)) : Color.clear)
                            .frame(width: 34, height: 34)
                        
                        Image(systemName: isLocked && targetDirection == .down ? "checkmark" : "arrow.down")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(targetDirection == .down ? (isLocked ? .black : accentColor) : Theme.textMuted.opacity(0.3))
                    }
                    .padding(.bottom, 8)
                }
                .frame(width: 58, height: 180)
                
                // Draggable Thumb Knob
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isLocked ? [Theme.neonGreen, Color.green] : [accentColor, accentColor.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(color: (isLocked ? Theme.neonGreen : accentColor).opacity(0.4), radius: 8, x: 0, y: 2)
                    
                    // Grip Icon
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                    } else {
                        VStack(spacing: 3) {
                            RoundedRectangle(cornerRadius: 1).fill(Color.black.opacity(0.7)).frame(width: 16, height: 2.5)
                            RoundedRectangle(cornerRadius: 1).fill(Color.black.opacity(0.7)).frame(width: 16, height: 2.5)
                            RoundedRectangle(cornerRadius: 1).fill(Color.black.opacity(0.7)).frame(width: 16, height: 2.5)
                        }
                    }
                }
                .offset(y: offset.wrappedValue)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            guard !isLocked else { return }
                            onDragChanged(value.translation.height)
                        }
                        .onEnded { _ in
                            guard !isLocked else { return }
                            onDragEnded()
                        }
                )
            }
            
            // Sub-status text
            Text(isLocked ? "LOCKED" : (targetDirection == .stay ? "HOLD CENTER" : targetDirection.rawValue))
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(isLocked ? Theme.neonGreen : Theme.textMuted)
        }
    }
    
    // MARK: - Drag Logic & Target Validation
    
    private func setupRound() {
        isLeftLocked = (instruction.left == .stay)
        isRightLocked = (instruction.right == .stay)
        leftOffset = 0
        rightOffset = 0
        isRoundSolved = false
        
        withAnimation(.easeInOut(duration: 0.6).repeatCount(2, autoreverses: true)) {
            pulsePrompt = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            pulsePrompt = false
        }
    }
    
    private func handleDrag(isLeft: Bool, translationY: CGFloat) {
        let clamped = max(-maxTravel, min(maxTravel, translationY))
        
        if isLeft {
            leftOffset = clamped
            checkLockCondition(isLeft: true, offset: clamped)
        } else {
            rightOffset = clamped
            checkLockCondition(isLeft: false, offset: clamped)
        }
    }
    
    private func checkLockCondition(isLeft: Bool, offset: CGFloat) {
        let target = isLeft ? instruction.left : instruction.right
        
        if target == .up && offset <= -threshold {
            Haptics.medium()
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                if isLeft {
                    leftOffset = -maxTravel
                    isLeftLocked = true
                } else {
                    rightOffset = -maxTravel
                    isRightLocked = true
                }
            }
            evaluateRoundCompletion()
        } else if target == .down && offset >= threshold {
            Haptics.medium()
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                if isLeft {
                    leftOffset = maxTravel
                    isLeftLocked = true
                } else {
                    rightOffset = maxTravel
                    isRightLocked = true
                }
            }
            evaluateRoundCompletion()
        }
    }
    
    private func handleDragEnd(isLeft: Bool) {
        let isLocked = isLeft ? isLeftLocked : isRightLocked
        if !isLocked {
            // Spring back to center if target was not locked in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                if isLeft {
                    leftOffset = 0
                } else {
                    rightOffset = 0
                }
            }
            Haptics.light()
        }
    }
    
    private func evaluateRoundCompletion() {
        guard isLeftLocked && isRightLocked && !isRoundSolved else { return }
        
        isRoundSolved = true
        Haptics.success()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            if currentRound < totalRounds {
                currentRound += 1
                instruction = SliderInstruction.generate(excluding: instruction)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    setupRound()
                }
            } else {
                isPuzzleSolved = true
                Haptics.success()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onSolveCompleted()
                }
            }
        }
    }
    
    private func solveCurrentStepAutomatically() {
        Haptics.medium()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if instruction.left == .up {
                leftOffset = -maxTravel
                isLeftLocked = true
            } else if instruction.left == .down {
                leftOffset = maxTravel
                isLeftLocked = true
            } else {
                leftOffset = 0
                isLeftLocked = true
            }
            
            if instruction.right == .up {
                rightOffset = -maxTravel
                isRightLocked = true
            } else if instruction.right == .down {
                rightOffset = maxTravel
                isRightLocked = true
            } else {
                rightOffset = 0
                isRightLocked = true
            }
        }
        evaluateRoundCompletion()
    }
}
