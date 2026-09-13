import SwiftUI

struct MemoryMissionView: View {
    let targetLength: Int
    let onComplete: () -> Void
    
    @State private var sequence: [Int] = []
    @State private var userIndex: Int = 0
    @State private var activeFlashingTile: Int? = nil
    @State private var isPlayingSequence: Bool = true
    @State private var statusText: String = "Watch the pattern..."
    @State private var currentRound: Int = 3
    
    let colors = [Theme.neonBlue, Theme.neonYellow, Theme.neonGreen, Theme.neonPurple]
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "square.grid.3x3.topleft.filled")
                        .foregroundColor(Theme.neonPurple)
                    Text("MEMORY MATRIX")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.neonPurple)
                }
                
                Text(statusText)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                
                Text("Length: \(sequence.count) / \(targetLength)")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(Theme.neonPurple)
            }
            .padding(.top, 10)
            
            Spacer()
            
            // 2x2 Grid of Glowing Tiles
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    tileButton(index: 0, color: Theme.neonBlue)
                    tileButton(index: 1, color: Theme.neonYellow)
                }
                HStack(spacing: 16) {
                    tileButton(index: 2, color: Theme.neonGreen)
                    tileButton(index: 3, color: Theme.neonPurple)
                }
            }
            .frame(width: 280, height: 280)
            
            Spacer()
            
            // Simulator / Skip Button
            Button(action: {
                onComplete()
            }) {
                Text("Pass Memory Check (Simulator)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Theme.cardBackground))
            }
            .padding(.bottom, 16)
        }
        .padding()
        .onAppear {
            startNewGame()
        }
    }
    
    private func tileButton(index: Int, color: Color) -> some View {
        let isLit = activeFlashingTile == index
        
        return Button(action: {
            userTapped(index: index)
        }) {
            RoundedRectangle(cornerRadius: 22)
                .fill(isLit ? color : color.opacity(0.25))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(color, lineWidth: isLit ? 3 : 1)
                )
                .shadow(color: isLit ? color.opacity(0.8) : Color.clear, radius: 16)
        }
        .disabled(isPlayingSequence)
    }
    
    private func startNewGame() {
        sequence = []
        for _ in 0..<currentRound {
            sequence.append(Int.random(in: 0..<4))
        }
        playSequence()
    }
    
    private func playSequence() {
        isPlayingSequence = true
        statusText = "Watch carefully..."
        userIndex = 0
        
        for (step, tile) in sequence.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(step + 1) * 0.6) {
                self.flashTile(tile)
            }
        }
        
        let totalDuration = Double(sequence.count + 1) * 0.6 + 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            self.isPlayingSequence = false
            self.statusText = "Your turn! Repeat the pattern."
            Haptics.light()
        }
    }
    
    private func flashTile(_ tile: Int) {
        activeFlashingTile = tile
        Haptics.light()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            if self.activeFlashingTile == tile {
                self.activeFlashingTile = nil
            }
        }
    }
    
    private func userTapped(index: Int) {
        guard !isPlayingSequence else { return }
        
        flashTile(index)
        
        if sequence[userIndex] == index {
            userIndex += 1
            if userIndex >= sequence.count {
                // Completed current sequence!
                Haptics.success()
                if sequence.count >= targetLength {
                    statusText = "Sequence Mastered!"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onComplete()
                    }
                } else {
                    statusText = "Correct! Adding another step..."
                    sequence.append(Int.random(in: 0..<4))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                        self.playSequence()
                    }
                }
            }
        } else {
            // Wrong!
            Haptics.error()
            statusText = "Oops! Try again..."
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.playSequence()
            }
        }
    }
}
