import SwiftUI

enum ChallengeSelectionMode: String, CaseIterable, Codable, Identifiable {
    case random = "Random"
    case sequential = "Fixed"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .random: return "dice.fill"
        case .sequential: return "list.number"
        }
    }
    
    var description: String {
        switch self {
        case .random: return "Surprise mix of challenges every morning"
        case .sequential: return "Math Match → Memory → Shake"
        }
    }
}

enum PuzzleType: String, CaseIterable, Codable, Identifiable {
    case mathMatch = "Math Match"
    case memorySequence = "Memory Sequence"
    case shakePhone = "Shake Phone"
    case patternConnect = "Pattern Connect"
    
    var id: String { rawValue }
    
    var title: String { rawValue }
    
    var icon: String {
        switch self {
        case .mathMatch: return "function"
        case .memorySequence: return "square.grid.3x3.topleft.filled"
        case .shakePhone: return "iphone.radiowaves.left.and.right"
        case .patternConnect: return "point.topleft.down.to.point.bottomright.curvepath.fill"
        }
    }
    
    var subtitle: String {
        switch self {
        case .mathMatch: return "Solve missing number arithmetic"
        case .memorySequence: return "Recall the 4x4 glowing tile pattern"
        case .shakePhone: return "Shake phone vigorously to fill energy"
        case .patternConnect: return "Connect numbered points in ascending order"
        }
    }
}

struct MathMatchEquation: Identifiable, Equatable {
    let id = UUID()
    let leftNum: Int
    let op: String // "+", "-", "×"
    let targetNum: Int
    let correctAnswer: Int
    let options: [Int] // 3 choices on the right
    var selectedAnswer: Int? = nil
    var isSolved: Bool {
        selectedAnswer == correctAnswer
    }
}

struct AlarmPuzzlePlan: Codable, Hashable {
    var puzzleCount: Int = 3
    var puzzleTypes: [PuzzleType] = [.mathMatch, .memorySequence, .shakePhone]
    
    var summary: String {
        "Puzzles: \(puzzleCount)"
    }
}
