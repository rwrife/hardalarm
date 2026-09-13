import SwiftUI

enum MissionType: String, CaseIterable, Codable, Identifiable {
    case pushups = "pushups"
    case squats = "squats"
    case math = "math"
    case photoHunt = "photoHunt"
    case shake = "shake"
    case memory = "memory"
    case steps = "steps"
    case voice = "voice"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .pushups: return "Push-Up Counter"
        case .squats: return "Morning Squats"
        case .math: return "Math Alert"
        case .photoHunt: return "Photo Hunt"
        case .shake: return "Vigorous Shake"
        case .memory: return "Memory Matrix"
        case .steps: return "Step Walkout"
        case .voice: return "Morning Voice"
        }
    }
    
    var icon: String {
        switch self {
        case .pushups: return "figure.core.training"
        case .squats: return "figure.cross.training"
        case .math: return "function"
        case .photoHunt: return "camera.viewfinder"
        case .shake: return "iphone.radiowaves.left.and.right"
        case .memory: return "square.grid.3x3.topleft.filled"
        case .steps: return "shoeprints.fill"
        case .voice: return "waveform.badge.mic"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .pushups: return Theme.neonOrange
        case .squats: return Theme.neonYellow
        case .math: return Theme.neonBlue
        case .photoHunt: return Theme.neonGreen
        case .shake: return Theme.neonRed
        case .memory: return Theme.neonPurple
        case .steps: return Theme.neonBlue
        case .voice: return Theme.neonOrange
        }
    }
    
    var shortDescription: String {
        switch self {
        case .pushups:
            return "Place phone on floor under chest; do push-ups to dismiss."
        case .squats:
            return "Hold phone in hand; squat down & up to wake your legs."
        case .math:
            return "Solve mental arithmetic problems to activate prefrontal cortex."
        case .photoHunt:
            return "Get out of bed and snap a photo of a household object."
        case .shake:
            return "Vigorously shake device until energy battery reaches 100%."
        case .memory:
            return "Remember and repeat the glowing Simon-style tile pattern."
        case .steps:
            return "Walk 20 steps away from bed to trigger wakefulness."
        case .voice:
            return "Speak a morning affirmation aloud with clear vocal tone."
        }
    }
    
    var morningBenefit: String {
        switch self {
        case .pushups:
            return "Forces oxygen and blood to rush through your upper body."
        case .squats:
            return "Engages the body's largest muscle groups for instant adrenaline."
        case .math:
            return "Banishes morning brain fog by stimulating active logic."
        case .photoHunt:
            return "Forces you to physically stand up and walk to another room."
        case .shake:
            return "High kinetic energy bursts wake up your nervous system."
        case .memory:
            return "Tests and sharpens short-term working memory."
        case .steps:
            return "Breaks sleep inertia by getting you on your feet."
        case .voice:
            return "Wakes your vocal cords, breathing, and morning mindset."
        }
    }
}

enum MathDifficulty: String, CaseIterable, Codable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case evil = "Evil"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .easy: return "Single & double digit addition (e.g. 24 + 19)"
        case .medium: return "Double digit mix (e.g. 58 + 37 - 24)"
        case .hard: return "Multiplication + addition (e.g. 14 × 7 + 38)"
        case .evil: return "Triple operations (e.g. 26 × 13 - 147)"
        }
    }
}

enum PhotoTarget: String, CaseIterable, Codable, Identifiable {
    case coffeeMug = "Coffee Mug / Cup"
    case sink = "Bathroom Sink / Faucet"
    case shoe = "Shoes / Sneakers"
    case bottle = "Water Bottle"
    case keyboard = "Laptop / Keyboard"
    case book = "Book / Journal"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .coffeeMug: return "cup.and.saucer.fill"
        case .sink: return "sink.fill"
        case .shoe: return "shoe.fill"
        case .bottle: return "waterbottle.fill"
        case .keyboard: return "keyboard.fill"
        case .book: return "book.fill"
        }
    }
    
    var destinationHint: String {
        switch self {
        case .coffeeMug: return "Walk to kitchen and find a coffee mug"
        case .sink: return "Walk to bathroom and point camera at the sink"
        case .shoe: return "Find your morning shoes or sneakers"
        case .bottle: return "Find your water bottle to hydrate"
        case .keyboard: return "Walk to your workspace or desk"
        case .book: return "Find a book or notebook"
        }
    }
    
    var visionKeywords: [String] {
        switch self {
        case .coffeeMug:
            return ["cup", "mug", "coffee", "tea", "espresso", "beaker", "pitcher"]
        case .sink:
            return ["sink", "washbasin", "basin", "faucet", "tap", "bathroom", "plumbing"]
        case .shoe:
            return ["shoe", "sneaker", "running shoe", "boot", "sandal", "footwear", "loafer"]
        case .bottle:
            return ["bottle", "water bottle", "flask", "thermos", "container"]
        case .keyboard:
            return ["keyboard", "laptop", "computer", "notebook", "screen", "monitor"]
        case .book:
            return ["book", "comic book", "notebook", "novel", "binder", "booklet"]
        }
    }
}

struct MissionConfig: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var type: MissionType = .pushups
    
    // Configurable parameters
    var pushupTargetReps: Int = 10
    var squatTargetReps: Int = 10
    var mathDifficulty: MathDifficulty = .medium
    var mathProblemCount: Int = 3
    var photoTarget: PhotoTarget = .coffeeMug
    var shakeGoal: Int = 50
    var memoryLength: Int = 5
    var stepGoal: Int = 20
    var voiceAffirmation: String = "I am awake, energized, and ready to conquer the day!"
    
    var summaryText: String {
        switch type {
        case .pushups:
            return "\(pushupTargetReps) Push-ups"
        case .squats:
            return "\(squatTargetReps) Squats"
        case .math:
            return "\(mathProblemCount) Problems (\(mathDifficulty.rawValue))"
        case .photoHunt:
            return photoTarget.rawValue
        case .shake:
            return "\(shakeGoal) Shakes"
        case .memory:
            return "\(memoryLength) Steps Pattern"
        case .steps:
            return "\(stepGoal) Steps"
        case .voice:
            return "Vocal Affirmation"
        }
    }
    
    var morningBenefit: String {
        type.morningBenefit
    }
}
