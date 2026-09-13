import SwiftUI

enum AlarmPuzzleChoice: String, CaseIterable, Codable, Identifiable {
    case random = "Random"
    case mathMatch = "Math Match"
    case memorySequence = "Memory Sequence"
    case shakePhone = "Vigorous Shake"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .random: return "dice.fill"
        case .mathMatch: return "function"
        case .memorySequence: return "square.grid.3x3.topleft.filled"
        case .shakePhone: return "iphone.radiowaves.left.and.right"
        }
    }
    
    var displayName: String {
        switch self {
        case .random: return "Random (Day by Day)"
        case .mathMatch: return "Math Match"
        case .memorySequence: return "Memory Sequence"
        case .shakePhone: return "Vigorous Shake"
        }
    }
    
    var subtitle: String {
        switch self {
        case .random: return "Randomly changes puzzle day by day"
        case .mathMatch: return "Missing number arithmetic"
        case .memorySequence: return "4x4 color recall pattern"
        case .shakePhone: return "Physical kinetic shake challenge"
        }
    }
    
    // Deterministically resolve puzzle type day by day
    func resolvePuzzleType(for date: Date = Date()) -> PuzzleType {
        switch self {
        case .mathMatch:
            return .mathMatch
        case .memorySequence:
            return .memorySequence
        case .shakePhone:
            return .shakePhone
        case .random:
            let calendar = Calendar.current
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? calendar.component(.day, from: date)
            let year = calendar.component(.year, from: date)
            let available: [PuzzleType] = [.mathMatch, .memorySequence, .shakePhone]
            let seed = (dayOfYear * 73856093) ^ (year * 19349663)
            let index = abs(seed) % available.count
            return available[index]
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
