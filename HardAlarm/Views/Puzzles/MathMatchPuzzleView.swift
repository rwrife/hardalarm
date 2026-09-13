import SwiftUI

struct MathMatchPuzzleView: View {
    let onSolveCompleted: () -> Void
    
    @State private var eq1Answer: Int? = nil
    @State private var eq2Answer: Int? = nil
    @State private var isSolved: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Puzzle Subtitle & Title
            VStack(spacing: 3) {
                Text("Puzzle 1")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.textMuted)
                
                Text("Math Match")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.top, 4)
            
            // Equations Container
            VStack(spacing: 18) {
                // Equation 1: 12 + [ ? ] = 19
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Text("12")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("+")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        // Answer Box
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(eq1Answer != nil ? Theme.primaryOrange.opacity(0.2) : Color(red: 0.16, green: 0.18, blue: 0.28))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(eq1Answer == 7 ? Theme.primaryOrange : Theme.cardBorder, lineWidth: 1.5)
                                )
                                .frame(width: 44, height: 44)
                            
                            Text(eq1Answer != nil ? "\(eq1Answer!)" : "?")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(eq1Answer == 7 ? Theme.primaryOrange : .white)
                        }
                        
                        Text("=")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("19")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Choice options stack on right
                    VStack(spacing: 6) {
                        ForEach([5, 7, 9], id: \.self) { choice in
                            Button(action: {
                                Haptics.light()
                                eq1Answer = choice
                                checkSolved()
                            }) {
                                Text("\(choice)")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(eq1Answer == choice ? .black : .white)
                                    .frame(width: 40, height: 32)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(eq1Answer == choice ? (choice == 7 ? Theme.primaryOrange : Theme.neonRed) : Color(red: 0.18, green: 0.20, blue: 0.32))
                                    )
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                
                Divider()
                    .background(Theme.cardBorder)
                
                // Equation 2: 8 × [ ? ] = 32
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Text("8")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("×")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        // Answer Box
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(eq2Answer != nil ? Theme.primaryOrange.opacity(0.2) : Color(red: 0.16, green: 0.18, blue: 0.28))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(eq2Answer == 4 ? Theme.primaryOrange : Theme.cardBorder, lineWidth: 1.5)
                                )
                                .frame(width: 44, height: 44)
                            
                            Text(eq2Answer != nil ? "\(eq2Answer!)" : "?")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(eq2Answer == 4 ? Theme.primaryOrange : .white)
                        }
                        
                        Text("=")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("32")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Choice options stack on right
                    VStack(spacing: 6) {
                        ForEach([3, 4, 6], id: \.self) { choice in
                            Button(action: {
                                Haptics.light()
                                eq2Answer = choice
                                checkSolved()
                            }) {
                                Text("\(choice)")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(eq2Answer == choice ? .black : .white)
                                    .frame(width: 40, height: 32)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(eq2Answer == choice ? (choice == 4 ? Theme.primaryOrange : Theme.neonRed) : Color(red: 0.18, green: 0.20, blue: 0.32))
                                    )
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
            
            // Bottom prompt
            Text("You must solve.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Theme.glowingGold)
                .padding(.top, 6)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
    }
    
    private func checkSolved() {
        if eq1Answer == 7 && eq2Answer == 4 && !isSolved {
            isSolved = true
            Haptics.success()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                onSolveCompleted()
            }
        } else if (eq1Answer != nil && eq1Answer != 7) || (eq2Answer != nil && eq2Answer != 4) {
            Haptics.error()
        }
    }
}
