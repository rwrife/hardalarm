import SwiftUI

struct MemorySequence4x4View: View {
    let onSolveCompleted: () -> Void
    
    // Target sequence coordinates: (row, col)
    private let targetSequence: [(Int, Int, Color)] = [
        (0, 0, Theme.tileOrange),
        (1, 1, Theme.tileCyan),
        (2, 2, Theme.tileGreen),
        (2, 3, Theme.tileYellow)
    ]
    
    @State private var litTiles: Set<Int> = [0, 5, 10, 11] // 4x4 indices
    @State private var timeRemaining: Int = 48
    @State private var userTappedIndices: [Int] = []
    @State private var timer: Timer?
    @State private var isSolved: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
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
                            tileView(index: index, row: row, col: col)
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
            
            // Status prompts
            VStack(spacing: 4) {
                Text("Watch closely!")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.primaryOrange)
                    .onTapGesture {
                        completePuzzle()
                    }
                
                Text("Time Remaining: 0:\(String(format: "%02d", timeRemaining))")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(Theme.textMuted)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .onAppear {
            startCountdown()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func tileView(index: Int, row: Int, col: Int) -> some View {
        let isHighlighted = litTiles.contains(index)
        let tileColor: Color
        if index == 0 {
            tileColor = Theme.tileOrange
        } else if index == 5 {
            tileColor = Theme.tileCyan
        } else if index == 10 {
            tileColor = Theme.tileGreen
        } else if index == 11 {
            tileColor = Theme.tileYellow
        } else {
            tileColor = Theme.tileInactive
        }
        
        return Button(action: {
            handleTap(index: index)
        }) {
            RoundedRectangle(cornerRadius: 10)
                .fill(isHighlighted ? tileColor : Color(red: 0.16, green: 0.17, blue: 0.25))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isHighlighted ? tileColor : Theme.cardBorder, lineWidth: 1)
                )
                .shadow(color: isHighlighted ? tileColor.opacity(0.8) : Color.clear, radius: 10)
        }
        .buttonStyle(.plain)
    }
    
    private func handleTap(index: Int) {
        Haptics.light()
        if litTiles.contains(index) {
            userTappedIndices.append(index)
            if userTappedIndices.count >= 3 && !isSolved {
                completePuzzle()
            }
        }
    }
    
    private func completePuzzle() {
        guard !isSolved else { return }
        isSolved = true
        Haptics.success()
        timer?.invalidate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onSolveCompleted()
        }
    }
    
    private func startCountdown() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak timer] _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
            }
        }
    }
}
