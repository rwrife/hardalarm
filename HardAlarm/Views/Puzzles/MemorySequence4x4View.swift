import SwiftUI

enum MemoryPhase {
    case memorize
    case recall
    case solved
}

struct MemoryTarget {
    let index: Int // 0..<16
    let colorName: String
    let color: Color
}

struct MemorySequence4x4View: View {
    let onSolveCompleted: () -> Void
    
    // 4 Distinct Active Tiles
    @State private var activeTargets: [MemoryTarget] = []
    @State private var revealedIndices: Set<Int> = []
    
    // Recall Targets Sequence (e.g. 2 target colors to find)
    @State private var recallQueue: [MemoryTarget] = []
    @State private var currentTargetIndex: Int = 0
    
    @State private var phase: MemoryPhase = .memorize
    @State private var memorizeTimeRemaining: Int = 3
    @State private var timer: Timer?
    @State private var isSolved: Bool = false
    @State private var wrongTileTapped: Int? = nil
    
    var currentPromptTarget: MemoryTarget? {
        if phase == .recall && currentTargetIndex < recallQueue.count {
            return recallQueue[currentTargetIndex]
        }
        return nil
    }
    
    var body: some View {
        VStack(spacing: 14) {
            // Puzzle Title
            Text("Memory Sequence")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.top, 4)
            
            // 4x4 Grid of Tiles
            VStack(spacing: 6) {
                ForEach(0..<4, id: \.self) { row in
                    HStack(spacing: 6) {
                        ForEach(0..<4, id: \.self) { col in
                            let index = row * 4 + col
                            tileView(index: index)
                        }
                    }
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.12, green: 0.13, blue: 0.20))
            )
            .frame(width: 208, height: 208)
            
            // Phase Prompts & Status
            VStack(spacing: 6) {
                switch phase {
                case .memorize:
                    Text("Watch closely!")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.primaryOrange)
                    
                    Text("Memorize colors: 0:0\(memorizeTimeRemaining)")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(Theme.textMuted)
                    
                case .recall:
                    if let target = currentPromptTarget {
                        HStack(spacing: 6) {
                            Text("Press the")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(target.colorName.uppercased())
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundColor(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(target.color)
                                        .shadow(color: target.color.opacity(0.8), radius: 6)
                                )
                            
                            Text("tile!")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        HStack(spacing: 10) {
                            Text("Target \(currentTargetIndex + 1) of \(recallQueue.count)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Theme.textMuted)
                            
                            // Peek Fallback button
                            Button(action: peekColorsBriefly) {
                                HStack(spacing: 3) {
                                    Image(systemName: "eye.fill")
                                    Text("Peek")
                                }
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Theme.primaryOrange)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Theme.cardBackground))
                            }
                        }
                    }
                    
                case .solved:
                    Text("Pattern Solved!")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.neonGreen)
                    
                    Text("Great memory!")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.textMuted)
                }
            }
            .frame(height: 54)
            .padding(.top, 2)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .onAppear {
            initializeGame()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // MARK: - Tile Component
    
    private func tileView(index: Int) -> some View {
        let matchingTarget = activeTargets.first(where: { $0.index == index })
        let isRevealed = revealedIndices.contains(index)
        let isWrong = wrongTileTapped == index
        
        let shouldShowColor: Bool
        let tileColor: Color
        
        if phase == .memorize {
            shouldShowColor = matchingTarget != nil
            tileColor = matchingTarget?.color ?? Theme.tileInactive
        } else if phase == .solved {
            shouldShowColor = matchingTarget != nil
            tileColor = matchingTarget?.color ?? Theme.tileInactive
        } else {
            // Recall phase: only show if already correctly identified
            shouldShowColor = isRevealed && matchingTarget != nil
            tileColor = matchingTarget?.color ?? Theme.tileInactive
        }
        
        return Button(action: {
            handleTileTap(index: index)
        }) {
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    isWrong
                        ? Theme.neonRed.opacity(0.8)
                        : (shouldShowColor ? tileColor : Color(red: 0.16, green: 0.17, blue: 0.25))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            isWrong
                                ? Theme.neonRed
                                : (shouldShowColor ? tileColor : Theme.cardBorder),
                            lineWidth: isWrong ? 2 : 1
                        )
                )
                .shadow(
                    color: isWrong
                        ? Theme.neonRed.opacity(0.8)
                        : (shouldShowColor ? tileColor.opacity(0.8) : Color.clear),
                    radius: 8
                )
        }
        .buttonStyle(.plain)
        .disabled(phase == .memorize || phase == .solved)
    }
    
    // MARK: - Game Logic
    
    private func initializeGame() {
        timer?.invalidate()
        
        // Pick 4 random distinct tile positions
        let shuffledIndices = Array(0..<16).shuffled()
        let p0 = shuffledIndices[0]
        let p1 = shuffledIndices[1]
        let p2 = shuffledIndices[2]
        let p3 = shuffledIndices[3]
        
        let targets: [MemoryTarget] = [
            MemoryTarget(index: p0, colorName: "Orange", color: Theme.tileOrange),
            MemoryTarget(index: p1, colorName: "Cyan", color: Theme.tileCyan),
            MemoryTarget(index: p2, colorName: "Green", color: Theme.tileGreen),
            MemoryTarget(index: p3, colorName: "Yellow", color: Theme.tileYellow)
        ]
        
        self.activeTargets = targets
        self.revealedIndices = []
        // Pick 2 target colors to ask the user
        self.recallQueue = Array(targets.shuffled().prefix(2))
        self.currentTargetIndex = 0
        self.phase = .memorize
        self.memorizeTimeRemaining = 3
        self.isSolved = false
        self.wrongTileTapped = nil
        
        startMemorizeCountdown()
    }
    
    private func startMemorizeCountdown() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak timer] _ in
            if memorizeTimeRemaining > 1 {
                memorizeTimeRemaining -= 1
            } else {
                timer?.invalidate()
                withAnimation(.easeInOut(duration: 0.3)) {
                    phase = .recall
                }
                Haptics.light()
            }
        }
    }
    
    private func handleTileTap(index: Int) {
        guard phase == .recall, let currentTarget = currentPromptTarget else { return }
        
        if index == currentTarget.index {
            // Correct tile!
            Haptics.success()
            revealedIndices.insert(index)
            wrongTileTapped = nil
            
            if currentTargetIndex + 1 < recallQueue.count {
                // Advance to next target color
                withAnimation {
                    currentTargetIndex += 1
                }
            } else {
                // All recall targets found!
                completePuzzle()
            }
        } else {
            // Wrong tile tapped
            Haptics.error()
            wrongTileTapped = index
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if wrongTileTapped == index {
                    wrongTileTapped = nil
                }
            }
        }
    }
    
    private func peekColorsBriefly() {
        guard phase == .recall else { return }
        Haptics.medium()
        withAnimation {
            phase = .memorize
            memorizeTimeRemaining = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if !isSolved {
                withAnimation {
                    phase = .recall
                }
            }
        }
    }
    
    private func completePuzzle() {
        guard !isSolved else { return }
        isSolved = true
        Haptics.success()
        timer?.invalidate()
        
        // Reveal all targets
        for t in activeTargets {
            revealedIndices.insert(t.index)
        }
        withAnimation {
            phase = .solved
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            onSolveCompleted()
        }
    }
}
