import Foundation
import CoreMotion
import UIKit
import Combine

@MainActor
final class MotionManager: ObservableObject {
    static let shared = MotionManager()
    
    private let motionManager = CMMotionManager()
    private var proximityObserver: AnyCancellable?
    
    // Mission Counters & Metrics
    @Published var pushupCount: Int = 0
    @Published var squatCount: Int = 0
    @Published var shakeEnergy: Double = 0.0 // 0.0 to 1.0 (0% to 100%)
    @Published var rawShakeCount: Int = 0
    @Published var stepCount: Int = 0
    
    // Real-time sensor statuses
    @Published var isProximityActive: Bool = false
    @Published var accelerationMagnitude: Double = 1.0
    @Published var isSquatDown: Bool = false
    @Published var isCalibrated: Bool = false
    
    // Internal state tracking
    private var lastShakeTime: Date = Date()
    private var shakeDecayTimer: Timer?
    private var pushupStateDown: Bool = false
    private var lastSquatTime: Date = Date()
    private var lastStepTime: Date = Date()
    
    init() {}
    
    // MARK: - Push-Up Detection
    // Pushups can be detected by placing the device face-up on the floor under the chest.
    // When the user descends, the proximity sensor triggers (chest near phone screen) or Z acceleration shifts.
    
    func startPushupTracking() {
        pushupCount = 0
        pushupStateDown = false
        UIDevice.current.isProximityMonitoringEnabled = true
        
        NotificationCenter.default.removeObserver(self, name: UIDevice.proximityStateDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleProximityChange),
            name: UIDevice.proximityStateDidChangeNotification,
            object: nil
        )
        
        startMotionUpdates()
    }
    
    func stopPushupTracking() {
        UIDevice.current.isProximityMonitoringEnabled = false
        NotificationCenter.default.removeObserver(self, name: UIDevice.proximityStateDidChangeNotification, object: nil)
        stopMotionUpdates()
    }
    
    @objc private func handleProximityChange() {
        let isClose = UIDevice.current.proximityState
        isProximityActive = isClose
        
        if isClose {
            // Chest is down close to phone
            pushupStateDown = true
            Haptics.light()
        } else if pushupStateDown {
            // Chest moved away from phone -> Rep completed!
            pushupStateDown = false
            pushupCount += 1
            Haptics.success()
        }
    }
    
    func simulatePushup() {
        pushupCount += 1
        Haptics.success()
    }
    
    // MARK: - Squat Detection
    
    func startSquatTracking() {
        squatCount = 0
        isSquatDown = false
        startMotionUpdates()
    }
    
    func stopSquatTracking() {
        stopMotionUpdates()
    }
    
    func simulateSquat() {
        squatCount += 1
        Haptics.success()
    }
    
    // MARK: - Shake Detection
    
    func startShakeTracking() {
        shakeEnergy = 0.0
        rawShakeCount = 0
        lastShakeTime = Date()
        
        startMotionUpdates()
        
        // Timer to decay shake energy if user rests
        shakeDecayTimer?.invalidate()
        shakeDecayTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if self.shakeEnergy > 0.0 {
                    // Decay energy slightly over time
                    self.shakeEnergy = max(0.0, self.shakeEnergy - 0.015)
                }
            }
        }
    }
    
    func stopShakeTracking() {
        shakeDecayTimer?.invalidate()
        shakeDecayTimer = nil
        stopMotionUpdates()
    }
    
    func simulateShake() {
        shakeEnergy = min(1.0, shakeEnergy + 0.08)
        rawShakeCount += 1
        Haptics.medium()
    }
    
    // MARK: - Step Detection
    
    func startStepTracking() {
        stepCount = 0
        startMotionUpdates()
    }
    
    func stopStepTracking() {
        stopMotionUpdates()
    }
    
    func simulateStep() {
        stepCount += 1
        Haptics.light()
    }
    
    // MARK: - CoreMotion Engine
    
    private func startMotionUpdates() {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = 0.05
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self = self, let data = data else { return }
            self.processMotion(x: data.acceleration.x, y: data.acceleration.y, z: data.acceleration.z)
        }
    }
    
    private func stopMotionUpdates() {
        motionManager.stopAccelerometerUpdates()
    }
    
    private func processMotion(x: Double, y: Double, z: Double) {
        let magnitude = sqrt(x * x + y * y + z * z)
        self.accelerationMagnitude = magnitude
        let deltaFrom1G = abs(magnitude - 1.0)
        
        // Shake processing: high delta adds energy
        if deltaFrom1G > 0.6 {
            let energyGain = min(0.06, deltaFrom1G * 0.03)
            shakeEnergy = min(1.0, shakeEnergy + energyGain)
            rawShakeCount += 1
            if rawShakeCount % 5 == 0 {
                Haptics.light()
            }
        }
        
        // Squat motion processing: vertical movement cycle
        let now = Date()
        if now.timeIntervalSince(lastSquatTime) > 0.8 {
            if magnitude < 0.75 {
                isSquatDown = true
            } else if magnitude > 1.25 && isSquatDown {
                isSquatDown = false
                squatCount += 1
                lastSquatTime = now
                Haptics.success()
            }
        }
        
        // Step processing: rhythmic walking impact spikes
        if now.timeIntervalSince(lastStepTime) > 0.35 && deltaFrom1G > 0.45 && deltaFrom1G < 1.2 {
            stepCount += 1
            lastStepTime = now
            Haptics.light()
        }
    }
}
