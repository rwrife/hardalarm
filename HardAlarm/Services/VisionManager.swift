import Foundation
import AVFoundation
import Vision
import SwiftUI
import Combine

@MainActor
final class VisionManager: ObservableObject {
    static let shared = VisionManager()
    
    @Published var isCameraAuthorized: Bool = false
    @Published var isRunning: Bool = false
    @Published var detectedLabels: [String] = []
    @Published var targetConfidence: Double = 0.0 // 0.0 to 1.0
    @Published var isTargetFound: Bool = false
    @Published var statusMessage: String = "Point camera at target item"
    
    private let cameraService = CameraClassificationService()
    
    init() {
        checkCameraPermission()
    }
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isCameraAuthorized = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                Task { @MainActor in
                    self?.isCameraAuthorized = granted
                }
            }
        default:
            isCameraAuthorized = false
        }
    }
    
    func startCamera(for target: PhotoTarget) {
        self.targetConfidence = 0.0
        self.isTargetFound = false
        self.detectedLabels = []
        self.statusMessage = "Looking for \(target.rawValue)..."
        self.isRunning = true
        
        cameraService.start(target: target) { [weak self] labels, highestConfidence in
            Task { @MainActor in
                guard let self = self else { return }
                self.detectedLabels = labels
                self.targetConfidence = highestConfidence
                
                if highestConfidence >= 0.35 {
                    self.isTargetFound = true
                    self.statusMessage = "🎯 Target Confirmed! (\(Int(highestConfidence * 100))%)"
                    Haptics.success()
                } else if highestConfidence > 0.15 {
                    self.statusMessage = "Getting closer... (\(Int(highestConfidence * 100))%)"
                } else {
                    self.statusMessage = "Searching for \(target.rawValue)..."
                }
            }
        }
    }
    
    func stopCamera() {
        cameraService.stop()
        self.isRunning = false
    }
    
    // Simulator and manual fallback
    func simulateTargetFound() {
        self.targetConfidence = 0.95
        self.isTargetFound = true
        self.statusMessage = "🎯 Simulated Target Confirmed (95%)"
        Haptics.success()
    }
}

// MARK: - Dedicated Camera Classification Service (Thread-safe)

final class CameraClassificationService: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {
    private var captureSession: AVCaptureSession?
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "com.hardalarm.cameraQueue")
    private var targetKeywords: [String] = []
    private var lastProcessTime: Date = Date()
    private var onResults: (([String], Double) -> Void)?
    
    func start(target: PhotoTarget, onResults: @escaping ([String], Double) -> Void) {
        self.targetKeywords = target.visionKeywords
        self.onResults = onResults
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.setupSession()
            self.captureSession?.startRunning()
        }
    }
    
    func stop() {
        sessionQueue.async { [weak self] in
            self?.captureSession?.stopRunning()
            self?.captureSession = nil
        }
    }
    
    private func setupSession() {
        guard captureSession == nil else { return }
        let session = AVCaptureSession()
        session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            return
        }
        
        session.addInput(input)
        
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        self.captureSession = session
    }
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let now = Date()
        guard now.timeIntervalSince(lastProcessTime) > 0.3 else { return }
        lastProcessTime = now
        
        let request = VNClassifyImageRequest { [weak self] req, _ in
            guard let self = self, let results = req.results as? [VNClassificationObservation] else { return }
            self.analyzeObservations(results)
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
        try? handler.perform([request])
    }
    
    private func analyzeObservations(_ results: [VNClassificationObservation]) {
        let topResults = results.prefix(6)
        let labels = topResults.map { "\($0.identifier) (\(Int($0.confidence * 100))%)" }
        
        var highestMatch: Double = 0.0
        for obs in topResults {
            let id = obs.identifier.lowercased()
            for kw in targetKeywords {
                if id.contains(kw) {
                    let c = Double(obs.confidence)
                    if c > highestMatch {
                        highestMatch = c
                    }
                }
            }
        }
        
        onResults?(labels, highestMatch)
    }
}
