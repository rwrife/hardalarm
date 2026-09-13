import Foundation
import AVFoundation

@MainActor
final class SoundManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var previewPlayer: AVAudioPlayer?
    private var silentAudioPlayer: AVAudioPlayer?
    private var volumeTimer: Timer?
    private var isProgressive: Bool = false
    private var targetVolume: Float = 1.0
    private var currentRampedVolume: Float = 0.2
    
    @Published var isPlaying: Bool = false
    @Published var isPreviewing: Bool = false
    @Published var isSilentKeepAliveActive: Bool = false
    @Published var activePreviewSound: AlarmSound?
    
    override init() {
        super.init()
        configureAudioSession()
        exportSoundsForNotificationsIfNeeded()
    }
    
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    // MARK: - Background Silent Audio Keep-Alive
    
    func startSilentKeepAlive() {
        guard silentAudioPlayer == nil else { return }
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            
            // 5 seconds of inaudible PCM silence
            let sampleRate = 44100
            let silentSamples = [Int16](repeating: 0, count: sampleRate * 5)
            let silentWavData = Self.createWavHeaderAndData(samples: silentSamples, sampleRate: sampleRate)
            
            silentAudioPlayer = try AVAudioPlayer(data: silentWavData)
            silentAudioPlayer?.numberOfLoops = -1 // Loop indefinitely in background
            silentAudioPlayer?.volume = 0.0 // Completely inaudible
            silentAudioPlayer?.prepareToPlay()
            silentAudioPlayer?.play()
            isSilentKeepAliveActive = true
            print("Background audio keep-alive started")
        } catch {
            print("Failed to start silent audio keep-alive: \(error)")
        }
    }
    
    func stopSilentKeepAlive() {
        silentAudioPlayer?.stop()
        silentAudioPlayer = nil
        isSilentKeepAliveActive = false
        print("Background audio keep-alive stopped")
    }
    
    // MARK: - Alarm Playback
    
    func playAlarm(sound: AlarmSound, volume: Float = 1.0, progressive: Bool = true) {
        stopSilentKeepAlive()
        stopPreview()
        stopAlarm()
        
        targetVolume = max(0.1, min(1.0, volume))
        isProgressive = progressive
        currentRampedVolume = progressive ? 0.2 : targetVolume
        
        let wavData = Self.generateWavData(for: sound)
        
        do {
            configureAudioSession()
            audioPlayer = try AVAudioPlayer(data: wavData)
            audioPlayer?.numberOfLoops = -1 // Infinite loop
            audioPlayer?.volume = currentRampedVolume
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
            
            if isProgressive {
                startVolumeRamp()
            }
        } catch {
            print("Failed to play alarm: \(error)")
        }
    }
    
    func stopAlarm() {
        volumeTimer?.invalidate()
        volumeTimer = nil
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
    
    private func startVolumeRamp() {
        volumeTimer?.invalidate()
        // Ramp up over 30 seconds (steps every 1s)
        let step = (targetVolume - 0.2) / 30.0
        volumeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, let player = self.audioPlayer else { return }
                self.currentRampedVolume = min(self.targetVolume, self.currentRampedVolume + step)
                player.volume = self.currentRampedVolume
                if self.currentRampedVolume >= self.targetVolume {
                    self.volumeTimer?.invalidate()
                    self.volumeTimer = nil
                }
            }
        }
    }
    
    // MARK: - Preview Playback
    
    func previewSound(_ sound: AlarmSound) {
        if activePreviewSound == sound && isPreviewing {
            stopPreview()
            return
        }
        
        stopPreview()
        let wavData = Self.generateWavData(for: sound)
        do {
            previewPlayer = try AVAudioPlayer(data: wavData)
            previewPlayer?.delegate = self
            previewPlayer?.volume = 0.8
            previewPlayer?.numberOfLoops = 1 // 2 loops then stop
            previewPlayer?.play()
            isPreviewing = true
            activePreviewSound = sound
        } catch {
            print("Failed to preview sound: \(error)")
        }
    }
    
    func stopPreview() {
        previewPlayer?.stop()
        previewPlayer = nil
        isPreviewing = false
        activePreviewSound = nil
    }
    
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.stopPreview()
        }
    }
    
    // MARK: - Notification Sound Export
    
    func exportSoundsForNotificationsIfNeeded() {
        Task.detached(priority: .utility) {
            guard let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else { return }
            let soundsURL = libraryURL.appendingPathComponent("Sounds", isDirectory: true)
            let fm = FileManager.default
            
            if !fm.fileExists(atPath: soundsURL.path) {
                try? fm.createDirectory(at: soundsURL, withIntermediateDirectories: true)
            }
            
            for sound in AlarmSound.allCases {
                let fileURL = soundsURL.appendingPathComponent("\(sound.rawValue).wav")
                if !fm.fileExists(atPath: fileURL.path) {
                    // Generate 15-second loop for notification ringing
                    let data = SoundManager.generateWavData(for: sound, duration: 15.0)
                    try? data.write(to: fileURL, options: .atomic)
                }
            }
        }
    }
    
    // MARK: - Synthetic Audio Tone Generator
    
    nonisolated static func generateWavData(for sound: AlarmSound, duration: Double = 1.6) -> Data {
        let sampleRate: Double = 44100.0
        let totalSamples = Int(sampleRate * duration)
        
        var samples = [Int16](repeating: 0, count: totalSamples)
        
        for i in 0..<totalSamples {
            let t = Double(i) / sampleRate
            var sampleVal: Double = 0.0
            
            switch sound {
            case .nuclear:
                // Alternating harsh siren: 880Hz for 0.4s, 1174Hz for 0.4s, with square distortion
                let cyclePhase = t.truncatingRemainder(dividingBy: 0.8)
                let freq = (cyclePhase < 0.4) ? 880.0 : 1174.0
                let sinVal = sin(2.0 * .pi * freq * t)
                let squareVal = sinVal > 0 ? 0.7 : -0.7
                sampleVal = (sinVal * 0.4 + squareVal * 0.6)
                
            case .hyperBeep:
                // Rapid triple beep: 3 beeps of 0.1s beep, 0.05s gap, then 0.5s pause
                let subTime = t.truncatingRemainder(dividingBy: 0.8)
                let beepFreq = 1760.0
                if subTime < 0.1 || (subTime >= 0.15 && subTime < 0.25) || (subTime >= 0.3 && subTime < 0.4) {
                    let env = sin(.pi * (subTime.truncatingRemainder(dividingBy: 0.15) / 0.1))
                    sampleVal = sin(2.0 * .pi * beepFreq * t) * env
                } else {
                    sampleVal = 0.0
                }
                
            case .electroPulse:
                // Futuristic sweeping FM synth
                let sweep = 500.0 + 900.0 * sin(2.0 * .pi * 2.5 * t)
                let mod = sin(2.0 * .pi * 30.0 * t) * 50.0
                sampleVal = sin(2.0 * .pi * (sweep + mod) * t) * 0.85
                
            case .radar:
                // Deep submarine radar pulse with resonant decay
                let radarPeriod = 0.8
                let pingTime = t.truncatingRemainder(dividingBy: radarPeriod)
                let freq = 1200.0 * exp(-pingTime * 3.0)
                let envelope = exp(-pingTime * 4.0)
                sampleVal = sin(2.0 * .pi * freq * pingTime) * envelope
                
            case .aggressiveStrobe:
                // Aggressive industrial strobe beats
                let beatFreq = 4.0 // 4 pulses per second
                let beatPhase = (t * beatFreq).truncatingRemainder(dividingBy: 1.0)
                if beatPhase < 0.5 {
                    let carrier = sin(2.0 * .pi * 950.0 * t)
                    let grit = sin(2.0 * .pi * 316.0 * t)
                    sampleVal = (carrier * 0.6 + grit * 0.4)
                } else {
                    sampleVal = 0.0
                }
            }
            
            // Clamp and convert to 16-bit PCM
            let clamped = max(-1.0, min(1.0, sampleVal))
            samples[i] = Int16(clamped * 32767.0)
        }
        
        return createWavHeaderAndData(samples: samples, sampleRate: Int(sampleRate))
    }
    
    nonisolated static func createWavHeaderAndData(samples: [Int16], sampleRate: Int) -> Data {
        var data = Data()
        let numChannels: Int16 = 1
        let bitsPerSample: Int16 = 16
        let byteRate = Int32(sampleRate * Int(numChannels) * Int(bitsPerSample / 8))
        let blockAlign = Int16(numChannels * (bitsPerSample / 8))
        let dataSize = Int32(samples.count * MemoryLayout<Int16>.size)
        let chunkSize = 36 + dataSize
        
        // RIFF header
        data.append(contentsOf: "RIFF".utf8)
        data.append(withUnsafeBytes(of: chunkSize.littleEndian) { Data($0) })
        data.append(contentsOf: "WAVE".utf8)
        
        // fmt subchunk
        data.append(contentsOf: "fmt ".utf8)
        let subchunk1Size: Int32 = 16
        data.append(withUnsafeBytes(of: subchunk1Size.littleEndian) { Data($0) })
        let audioFormat: Int16 = 1 // PCM
        data.append(withUnsafeBytes(of: audioFormat.littleEndian) { Data($0) })
        data.append(withUnsafeBytes(of: numChannels.littleEndian) { Data($0) })
        data.append(withUnsafeBytes(of: Int32(sampleRate).littleEndian) { Data($0) })
        data.append(withUnsafeBytes(of: byteRate.littleEndian) { Data($0) })
        data.append(withUnsafeBytes(of: blockAlign.littleEndian) { Data($0) })
        data.append(withUnsafeBytes(of: bitsPerSample.littleEndian) { Data($0) })
        
        // data subchunk
        data.append(contentsOf: "data".utf8)
        data.append(withUnsafeBytes(of: dataSize.littleEndian) { Data($0) })
        
        // PCM samples
        samples.withUnsafeBufferPointer { buffer in
            data.append(Data(buffer: buffer))
        }
        
        return data
    }
}
