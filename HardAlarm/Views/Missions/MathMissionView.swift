import SwiftUI

struct MathMissionView: View {
    let difficulty: MathDifficulty
    let targetProblems: Int
    let onComplete: () -> Void
    
    @State private var currentEquation: String = ""
    @State private var expectedAnswer: Int = 0
    @State private var userInput: String = ""
    @State private var solvedCount: Int = 0
    @State private var totalProblemsRequired: Int
    @State private var isErrorFlashing: Bool = false
    @State private var errorMessage: String? = nil
    
    init(difficulty: MathDifficulty, targetProblems: Int, onComplete: @escaping () -> Void) {
        self.difficulty = difficulty
        self.targetProblems = targetProblems
        self.onComplete = onComplete
        _totalProblemsRequired = State(initialValue: targetProblems)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 6) {
                HStack {
                    Image(systemName: "function")
                        .foregroundColor(Theme.neonBlue)
                    Text("MATH ALERT (\(difficulty.rawValue.uppercased()))")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.neonBlue)
                }
                
                Text("Problem \(solvedCount + 1) of \(totalProblemsRequired)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 10)
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.cardBorder)
                        .frame(height: 8)
                    Capsule()
                        .fill(Theme.neonBlue)
                        .frame(width: geo.size.width * CGFloat(Double(solvedCount) / Double(max(1, totalProblemsRequired))), height: 8)
                        .animation(.spring(), value: solvedCount)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Equation Display Card
            VStack(spacing: 12) {
                Text(currentEquation)
                    .font(.system(size: 44, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                    .shadow(color: Theme.neonBlue.opacity(0.5), radius: 8)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                
                // User Input Slot
                HStack {
                    Text(userInput.isEmpty ? "?" : userInput)
                        .font(.system(size: 38, weight: .bold, design: .monospaced))
                        .foregroundColor(userInput.isEmpty ? .white.opacity(0.3) : Theme.neonBlue)
                }
                .frame(minWidth: 160, minHeight: 56)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isErrorFlashing ? Theme.neonRed.opacity(0.25) : Theme.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isErrorFlashing ? Theme.neonRed : Theme.cardBorder, lineWidth: 2)
                        )
                )
                
                if let error = errorMessage {
                    Text(error)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Theme.neonRed)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Custom Keypad
            VStack(spacing: 12) {
                ForEach([[1, 2, 3], [4, 5, 6], [7, 8, 9]], id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { num in
                            keypadButton(label: "\(num)", action: { appendDigit("\(num)") })
                        }
                    }
                }
                
                HStack(spacing: 12) {
                    keypadButton(label: "C", color: Theme.neonRed, action: { clearInput() })
                    keypadButton(label: "0", action: { appendDigit("0") })
                    keypadButton(label: "⌫", color: Theme.neonOrange, action: { backspace() })
                }
                
                // Enter Button
                Button(action: checkAnswer) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("SUBMIT ANSWER")
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Theme.neonBlue)
                    )
                    .shadow(color: Theme.neonBlue.opacity(0.4), radius: 8)
                }
                .disabled(userInput.isEmpty)
                .opacity(userInput.isEmpty ? 0.5 : 1.0)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .onAppear {
            generateNewEquation()
        }
    }
    
    private func keypadButton(label: String, color: Color = .white, action: @escaping () -> Void) -> some View {
        Button(action: {
            Haptics.light()
            action()
        }) {
            Text(label)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Theme.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Theme.cardBorder, lineWidth: 1)
                        )
                )
        }
    }
    
    private func appendDigit(_ digit: String) {
        if userInput.count < 6 {
            userInput.append(digit)
        }
    }
    
    private func backspace() {
        if !userInput.isEmpty {
            userInput.removeLast()
        }
    }
    
    private func clearInput() {
        userInput = ""
    }
    
    private func generateNewEquation() {
        userInput = ""
        errorMessage = nil
        isErrorFlashing = false
        
        switch difficulty {
        case .easy:
            let a = Int.random(in: 12...49)
            let b = Int.random(in: 11...49)
            if Bool.random() {
                currentEquation = "\(a) + \(b)"
                expectedAnswer = a + b
            } else {
                let maxVal = max(a, b)
                let minVal = min(a, b)
                currentEquation = "\(maxVal) - \(minVal)"
                expectedAnswer = maxVal - minVal
            }
            
        case .medium:
            let a = Int.random(in: 25...80)
            let b = Int.random(in: 15...60)
            let c = Int.random(in: 10...40)
            if Bool.random() {
                currentEquation = "\(a) + \(b) - \(c)"
                expectedAnswer = a + b - c
            } else {
                let x = Int.random(in: 6...12)
                let y = Int.random(in: 4...12)
                let z = Int.random(in: 10...30)
                currentEquation = "\(x) × \(y) + \(z)"
                expectedAnswer = x * y + z
            }
            
        case .hard:
            let a = Int.random(in: 13...29)
            let b = Int.random(in: 6...16)
            let c = Int.random(in: 25...95)
            if Bool.random() {
                currentEquation = "(\(a) × \(b)) + \(c)"
                expectedAnswer = (a * b) + c
            } else {
                currentEquation = "(\(a) × \(b)) - \(c)"
                expectedAnswer = (a * b) - c
            }
            
        case .evil:
            let a = Int.random(in: 16...35)
            let b = Int.random(in: 12...25)
            let c = Int.random(in: 45...150)
            currentEquation = "(\(a) × \(b)) - \(c)"
            expectedAnswer = (a * b) - c
        }
    }
    
    private func checkAnswer() {
        guard let answer = Int(userInput) else { return }
        
        if answer == expectedAnswer {
            Haptics.success()
            solvedCount += 1
            if solvedCount >= totalProblemsRequired {
                onComplete()
            } else {
                generateNewEquation()
            }
        } else {
            // Wrong answer! Add penalty
            Haptics.error()
            isErrorFlashing = true
            totalProblemsRequired += 1
            errorMessage = "Incorrect! +1 Problem Penalty Added!"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.isErrorFlashing = false
                self.userInput = ""
            }
        }
    }
}
