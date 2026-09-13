import SwiftUI

enum AlarmChallengeChoice: String, CaseIterable, Codable, Identifiable {
    case random = "Random"
    case pushups = "Push-ups"
    case photoHunt = "Photo Hunt"
    case mathMatch = "Math Match"
    case memorySequence = "Memory Sequence"
    case squats = "Morning Squats"
    case shakePhone = "Vigorous Shake"
    case steps = "Step Walkout"
    case dualSliders = "Dual Sliders"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .random: return "dice.fill"
        case .pushups: return "figure.core.training"
        case .photoHunt: return "camera.viewfinder"
        case .mathMatch: return "function"
        case .memorySequence: return "square.grid.3x3.topleft.filled"
        case .squats: return "figure.cross.training"
        case .shakePhone: return "iphone.radiowaves.left.and.right"
        case .steps: return "shoeprints.fill"
        case .dualSliders: return "slider.vertical.3"
        }
    }
    
    var displayName: String {
        switch self {
        case .random: return "Random (Day by Day)"
        case .pushups: return "Push-Up Counter"
        case .photoHunt: return "Photo Hunt"
        case .mathMatch: return "Math Match"
        case .memorySequence: return "Memory Sequence"
        case .squats: return "Morning Squats"
        case .shakePhone: return "Vigorous Shake"
        case .steps: return "Step Walkout"
        case .dualSliders: return "Dual Sliders"
        }
    }
    
    var subtitle: String {
        switch self {
        case .random: return "Randomly changes challenge every morning"
        case .pushups: return "10 reps detected with chest sensor"
        case .photoHunt: return "Snap a photo of household object"
        case .mathMatch: return "Missing number arithmetic equations"
        case .memorySequence: return "4x4 color recall pattern game"
        case .squats: return "10 squats detected with motion sensors"
        case .shakePhone: return "Physical kinetic shake challenge"
        case .steps: return "Walk 20 steps away from bed"
        case .dualSliders: return "Slide knobs in matching random directions"
        }
    }
    
    // Deterministically resolve challenge type day by day across all physical tasks and puzzles
    func resolveChallengeType(for date: Date = Date()) -> ChallengeType {
        switch self {
        case .pushups:
            return .pushups
        case .photoHunt:
            return .photoHunt
        case .mathMatch:
            return .mathMatch
        case .memorySequence:
            return .memorySequence
        case .squats:
            return .squats
        case .shakePhone:
            return .shakePhone
        case .steps:
            return .steps
        case .dualSliders:
            return .dualSliders
        case .random:
            let calendar = Calendar.current
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? calendar.component(.day, from: date)
            let year = calendar.component(.year, from: date)
            // Available pool includes BOTH physical exercises and cognitive puzzles
            let available: [ChallengeType] = [
                .pushups,
                .photoHunt,
                .mathMatch,
                .memorySequence,
                .squats,
                .shakePhone,
                .steps,
                .dualSliders
            ]
            let seed = (dayOfYear * 73856093) ^ (year * 19349663)
            let index = abs(seed) % available.count
            return available[index]
        }
    }
    
    // Backward compatibility alias
    func resolvePuzzleType(for date: Date = Date()) -> ChallengeType {
        resolveChallengeType(for: date)
    }
}

typealias AlarmPuzzleChoice = AlarmChallengeChoice

enum ChallengeType: String, CaseIterable, Codable, Identifiable {
    case pushups = "Push-Up Counter"
    case photoHunt = "Photo Hunt"
    case mathMatch = "Math Match"
    case memorySequence = "Memory Sequence"
    case squats = "Morning Squats"
    case shakePhone = "Vigorous Shake"
    case steps = "Step Walkout"
    case dualSliders = "Dual Sliders"
    case patternConnect = "Pattern Connect"
    
    var id: String { rawValue }
    var title: String { rawValue }
    
    var icon: String {
        switch self {
        case .pushups: return "figure.core.training"
        case .photoHunt: return "camera.viewfinder"
        case .mathMatch: return "function"
        case .memorySequence: return "square.grid.3x3.topleft.filled"
        case .squats: return "figure.cross.training"
        case .shakePhone: return "iphone.radiowaves.left.and.right"
        case .steps: return "shoeprints.fill"
        case .dualSliders: return "slider.vertical.3"
        case .patternConnect: return "point.topleft.down.to.point.bottomright.curvepath.fill"
        }
    }
    
    var subtitle: String {
        switch self {
        case .pushups: return "10 reps detected with chest sensor"
        case .photoHunt: return "Snap a photo of household object"
        case .mathMatch: return "Solve missing number arithmetic"
        case .memorySequence: return "Recall the 4x4 glowing tile pattern"
        case .squats: return "10 squats detected with motion sensors"
        case .shakePhone: return "Shake phone vigorously to fill energy"
        case .steps: return "Walk 20 steps away from bed"
        case .dualSliders: return "Follow random direction instructions on dual sliders"
        case .patternConnect: return "Connect numbered points in ascending order"
        }
    }
}

typealias PuzzleType = ChallengeType

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
