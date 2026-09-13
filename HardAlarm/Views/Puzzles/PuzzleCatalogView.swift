import SwiftUI

struct PuzzleCatalogView: View {
    @State private var activePracticePuzzle: PuzzleType? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Wake-Up Puzzles")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Interactive challenges that unlock the morning alarm")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.textMuted)
                }
                .padding(.top, 10)
                
                VStack(spacing: 14) {
                    ForEach(PuzzleType.allCases) { puzzle in
                        Button(action: {
                            Haptics.medium()
                            activePracticePuzzle = puzzle
                        }) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Theme.primaryOrange.opacity(0.15))
                                        .frame(width: 48, height: 48)
                                    Image(systemName: puzzle.icon)
                                        .font(.system(size: 22))
                                        .foregroundColor(Theme.primaryOrange)
                                }
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(puzzle.title)
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    Text(puzzle.subtitle)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Theme.textMuted)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Text("Play")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(Theme.primaryOrange)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(Theme.primaryOrange)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Theme.primaryOrange.opacity(0.12)))
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Theme.cardBackground)
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.cardBorder, lineWidth: 1))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 20)
        }
        .sheet(item: $activePracticePuzzle) { puzzle in
            ZStack {
                Theme.background.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            activePracticePuzzle = nil
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Theme.primaryOrange)
                    }
                    .padding()
                    
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Theme.cardBackground)
                            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.cardBorder, lineWidth: 1.5))
                        
                        switch puzzle {
                        case .mathMatch:
                            MathMatchPuzzleView {
                                activePracticePuzzle = nil
                            }
                        case .memorySequence:
                            MemorySequence4x4View {
                                activePracticePuzzle = nil
                            }
                        case .shakePhone:
                            ShakePhonePuzzleView {
                                activePracticePuzzle = nil
                            }
                        case .patternConnect:
                            MemorySequence4x4View {
                                activePracticePuzzle = nil
                            }
                        }
                    }
                    .frame(maxHeight: 380)
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
        }
    }
}
