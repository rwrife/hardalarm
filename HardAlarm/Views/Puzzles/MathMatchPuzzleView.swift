import SwiftUI

struct MathProblem: Identifiable, Equatable {
    let id = UUID()
    let leftNum: Int
    let op: String
    let targetNum: Int
    let correctAnswer: Int
    let choices: [Int] // 3 choices sorted
    
    static func generateEquation1() -> MathProblem {
        let isAddition = Bool.random()
        if isAddition {
            let left = Int.random(in: 11...24)
            let answer = Int.random(in: 5...14)
            let target = left + answer
            let d1 = answer + (Bool.random() ? 2 : 3)
            let d2 = max(1, answer - (Bool.random() ? 2 : 3))
            var options = Array(Set([answer, d1, d2]))
            while options.count < 3 {
                let candidate = max(1, answer + Int.random(in: -4...4))
                if !options.contains(candidate) { options.append(candidate) }
            }
            return MathProblem(leftNum: left, op: "+", targetNum: target, correctAnswer: answer, choices: options.sorted())
        } else {
            let left = Int.random(in: 20...38)
            let answer = Int.random(in: 5...14)
            let target = left - answer
            let d1 = answer + (Bool.random() ? 2 : 3)
            let d2 = max(1, answer - (Bool.random() ? 2 : 3))
            var options = Array(Set([answer, d1, d2]))
            while options.count < 3 {
                let candidate = max(1, answer + Int.random(in: -4...4))
                if !options.contains(candidate) { options.append(candidate) }
            }
            return MathProblem(leftNum: left, op: "-", targetNum: target, correctAnswer: answer, choices: options.sorted())
        }
    }
    
    static func generateEquation2() -> MathProblem {
        let left = Int.random(in: 4...9)
        let answer = Int.random(in: 3...9)
        let target = left * answer
        let d1 = answer + (Bool.random() ? 1 : 2)
        let d2 = max(2, answer - (Bool.random() ? 1 : 2))
        var options = Array(Set([answer, d1, d2]))
        while options.count < 3 {
            let candidate = max(2, answer + Int.random(in: -3...3))
            if !options.contains(candidate) { options.append(candidate) }
        }
        return MathProblem(leftNum: left, op: "×", targetNum: target, correctAnswer: answer, choices: options.sorted())
    }
}

struct MathMatchPuzzleView: View {
    let onSolveCompleted: () -> Void
    
    @State private var eq1: MathProblem = MathProblem.generateEquation1()
    @State private var eq2: MathProblem = MathProblem.generateEquation2()
    
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
                // Equation 1
                equationRow(problem: eq1, selectedAnswer: eq1Answer) { choice in
                    Haptics.light()
                    eq1Answer = choice
                    checkSolved()
                }
                
                Divider()
                    .background(Theme.cardBorder)
                
                // Equation 2
                equationRow(problem: eq2, selectedAnswer: eq2Answer) { choice in
                    Haptics.light()
                    eq2Answer = choice
                    checkSolved()
                }
            }
            
            // Bottom prompt
            Text("You must solve.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Theme.glowingGold)
                .padding(.top, 6)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .onAppear {
            generateFreshEquations()
        }
    }
    
    private func equationRow(problem: MathProblem, selectedAnswer: Int?, onSelect: @escaping (Int) -> Void) -> some View {
        let isCorrect = selectedAnswer == problem.correctAnswer
        
        return HStack(spacing: 12) {
            HStack(spacing: 8) {
                Text("\(problem.leftNum)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(problem.op)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                // Answer Box
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(selectedAnswer != nil ? Theme.primaryOrange.opacity(0.2) : Color(red: 0.16, green: 0.18, blue: 0.28))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isCorrect ? Theme.primaryOrange : Theme.cardBorder, lineWidth: 1.5)
                        )
                        .frame(width: 44, height: 44)
                    
                    Text(selectedAnswer != nil ? "\(selectedAnswer!)" : "?")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(isCorrect ? Theme.primaryOrange : .white)
                }
                
                Text("=")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("\(problem.targetNum)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Choice options stack on right
            VStack(spacing: 6) {
                ForEach(problem.choices, id: \.self) { choice in
                    let isThisChoiceSelected = selectedAnswer == choice
                    let isThisChoiceCorrect = choice == problem.correctAnswer
                    
                    Button(action: {
                        onSelect(choice)
                    }) {
                        Text("\(choice)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(isThisChoiceSelected ? (isThisChoiceCorrect ? .black : .white) : .white)
                            .frame(width: 40, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        isThisChoiceSelected
                                            ? (isThisChoiceCorrect ? Theme.primaryOrange : Theme.neonRed)
                                            : Color(red: 0.18, green: 0.20, blue: 0.32)
                                    )
                            )
                    }
                }
            }
        }
        .padding(.horizontal, 8)
    }
    
    private func generateFreshEquations() {
        eq1 = MathProblem.generateEquation1()
        eq2 = MathProblem.generateEquation2()
        eq1Answer = nil
        eq2Answer = nil
        isSolved = false
    }
    
    private func checkSolved() {
        if eq1Answer == eq1.correctAnswer && eq2Answer == eq2.correctAnswer && !isSolved {
            isSolved = true
            Haptics.success()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                onSolveCompleted()
            }
        } else if (eq1Answer != nil && eq1Answer != eq1.correctAnswer) || (eq2Answer != nil && eq2Answer != eq2.correctAnswer) {
            Haptics.error()
        }
    }
}
