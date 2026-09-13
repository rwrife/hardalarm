import Foundation

enum AlarmSound: String, CaseIterable, Codable, Identifiable {
    case nuclear = "nuclear"
    case hyperBeep = "hyperBeep"
    case electroPulse = "electroPulse"
    case radar = "radar"
    case aggressiveStrobe = "aggressiveStrobe"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .nuclear: return "Nuclear Alert"
        case .hyperBeep: return "Hyper Pulse"
        case .electroPulse: return "Cyber Siren"
        case .radar: return "Radar Ping"
        case .aggressiveStrobe: return "Aggressive Strobe"
        }
    }
    
    var icon: String {
        switch self {
        case .nuclear: return "exclamationmark.triangle.fill"
        case .hyperBeep: return "bolt.horizontal.fill"
        case .electroPulse: return "waveform.path.ecg"
        case .radar: return "antenna.radiowaves.left.and.right"
        case .aggressiveStrobe: return "light.beacon.max.fill"
        }
    }
    
    var soundDescription: String {
        switch self {
        case .nuclear: return "Piercing alternating high/low dual emergency tone."
        case .hyperBeep: return "Rapid triple-burst high-frequency digital beeps."
        case .electroPulse: return "Aggressive sweeping futuristic alarm synth."
        case .radar: return "Submarine radar pulse designed to snap deep sleepers."
        case .aggressiveStrobe: return "Hard-hitting pulse rhythm that cannot be ignored."
        }
    }
}
