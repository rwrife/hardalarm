import Foundation
import Speech
import AVFoundation

@MainActor
final class SpeechManager: ObservableObject {
    static let shared = SpeechManager()
    
    @Published var isAuthorized: Bool = false
    @Published var isListening: Bool = false
    @Published var recognizedText: String = ""
    @Published var matchPercentage: Double = 0.0 // 0.0 to 1.0
    @Published var isAffirmationCompleted: Bool = false
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private var targetAffirmation: String = ""
    
    init() {
        checkPermission()
    }
    
    func checkPermission() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            Task { @MainActor in
                self?.isAuthorized = (authStatus == .authorized)
            }
        }
    }
    
    func startListening(target: String) {
        stopListening()
        
        self.targetAffirmation = target
        self.recognizedText = ""
        self.matchPercentage = 0.0
        self.isAffirmationCompleted = false
        
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        guard recordingFormat.sampleRate > 0 else {
            // Audio hardware not ready (e.g. simulator)
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let request = recognitionRequest else { return }
        request.shouldReportPartialResults = true
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isListening = true
        } catch {
            print("AudioEngine could not start: \(error)")
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                guard let self = self else { return }
                if let result = result {
                    self.recognizedText = result.bestTranscription.formattedString
                    self.evaluateMatch()
                }
                if error != nil {
                    self.stopListening()
                }
            }
        }
    }
    
    func stopListening() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        isListening = false
    }
    
    private func evaluateMatch() {
        let cleanTarget = targetAffirmation.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
        let cleanRecognized = recognizedText.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
        
        guard !cleanTarget.isEmpty else { return }
        
        var matchCount = 0
        for word in cleanTarget {
            if cleanRecognized.contains(word) {
                matchCount += 1
            }
        }
        
        let percentage = Double(matchCount) / Double(cleanTarget.count)
        self.matchPercentage = percentage
        
        if percentage >= 0.70 {
            self.isAffirmationCompleted = true
            Haptics.success()
            stopListening()
        }
    }
    
    func simulateSpeechMatch() {
        self.recognizedText = targetAffirmation
        self.matchPercentage = 1.0
        self.isAffirmationCompleted = true
        Haptics.success()
        stopListening()
    }
}
