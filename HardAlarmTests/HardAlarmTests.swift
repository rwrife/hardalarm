import XCTest
@testable import HardAlarm

final class HardAlarmTests: XCTestCase {
    
    func testAlarmNextTriggerDateOneTime() {
        let calendar = Calendar.current
        let now = Date()
        var comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        comps.hour = (comps.hour ?? 12) + 2 // 2 hours in the future
        comps.minute = 30
        let targetDate = calendar.date(from: comps)!
        
        let alarm = Alarm(
            time: targetDate,
            label: "Test One Time",
            isEnabled: true,
            repeatDays: []
        )
        
        let nextDate = alarm.nextTriggerDate(from: now)
        XCTAssertGreaterThan(nextDate, now, "Trigger date should be in the future")
        let resultHour = calendar.component(.hour, from: nextDate)
        let resultMinute = calendar.component(.minute, from: nextDate)
        XCTAssertEqual(resultHour, comps.hour)
        XCTAssertEqual(resultMinute, 30)
    }
    
    func testMissionSummaries() {
        let pushupMission = MissionConfig(type: .pushups, pushupTargetReps: 15)
        XCTAssertEqual(pushupMission.summaryText, "15 Push-ups")
        
        let mathMission = MissionConfig(type: .math, mathDifficulty: .hard, mathProblemCount: 3)
        XCTAssertEqual(mathMission.summaryText, "3 Problems (Hard)")
        
        let photoMission = MissionConfig(type: .photoHunt, photoTarget: .coffeeMug)
        XCTAssertEqual(photoMission.summaryText, "Coffee Mug / Cup")
    }
    
    func testUserWakeStatsRecording() {
        var stats = UserWakeStats(streakDays: 2, totalAlarmsDismissed: 5, totalPushupsCompleted: 20, totalMathSolved: 10, records: [])
        let mission = MissionConfig(type: .pushups, pushupTargetReps: 15)
        
        stats.recordDismissal(alarmLabel: "Early Rise", mission: mission, durationSeconds: 28, snoozes: 0)
        
        XCTAssertEqual(stats.streakDays, 3)
        XCTAssertEqual(stats.totalAlarmsDismissed, 6)
        XCTAssertEqual(stats.totalPushupsCompleted, 35)
        XCTAssertEqual(stats.records.count, 1)
        XCTAssertEqual(stats.records[0].formattedDuration, "28s")
    }
    
    @MainActor
    func testSoundManagerWavGeneration() {
        let soundManager = SoundManager.shared
        // Playing all alarm sounds verifies audio player initialization and WAV generation without crash
        for sound in AlarmSound.allCases {
            soundManager.playAlarm(sound: sound, volume: 0.5, progressive: false)
            XCTAssertTrue(soundManager.isPlaying)
            soundManager.stopAlarm()
            XCTAssertFalse(soundManager.isPlaying)
        }
    }
    
    func testAlarmRepeatDescriptions() {
        var alarm = Alarm(time: Date(), label: "Repeat Test")
        alarm.repeatDays = []
        XCTAssertEqual(alarm.repeatDescription, "Once")
        
        alarm.repeatDays = [1, 2, 3, 4, 5, 6, 7]
        XCTAssertEqual(alarm.repeatDescription, "Every day")
        
        alarm.repeatDays = [2, 3, 4, 5, 6]
        XCTAssertEqual(alarm.repeatDescription, "Weekdays")
        
        alarm.repeatDays = [1, 7]
        XCTAssertEqual(alarm.repeatDescription, "Weekends")
    }
    
    func testPhotoTargetKeywords() {
        for target in PhotoTarget.allCases {
            XCTAssertFalse(target.visionKeywords.isEmpty, "Target \(target) must define classification keywords")
            XCTAssertFalse(target.destinationHint.isEmpty, "Target \(target) must have a hint")
        }
    }
    
    func testPuzzleChoiceDirectResolution() {
        XCTAssertEqual(AlarmPuzzleChoice.mathMatch.resolvePuzzleType(), .mathMatch)
        XCTAssertEqual(AlarmPuzzleChoice.memorySequence.resolvePuzzleType(), .memorySequence)
        XCTAssertEqual(AlarmPuzzleChoice.shakePhone.resolvePuzzleType(), .shakePhone)
    }
    
    func testPuzzleChoiceRandomChangesDayByDay() {
        let calendar = Calendar.current
        var baseComponents = DateComponents()
        baseComponents.year = 2026
        baseComponents.month = 9
        baseComponents.day = 12
        baseComponents.hour = 7
        
        guard let day1 = calendar.date(from: baseComponents),
              let day2 = calendar.date(byAdding: .day, value: 1, to: day1),
              let day3 = calendar.date(byAdding: .day, value: 2, to: day1),
              let day4 = calendar.date(byAdding: .day, value: 3, to: day1),
              let day5 = calendar.date(byAdding: .day, value: 4, to: day1) else {
            XCTFail("Failed to construct dates")
            return
        }
        
        let puzzle1 = AlarmPuzzleChoice.random.resolvePuzzleType(for: day1)
        let puzzle2 = AlarmPuzzleChoice.random.resolvePuzzleType(for: day2)
        let puzzle3 = AlarmPuzzleChoice.random.resolvePuzzleType(for: day3)
        let puzzle4 = AlarmPuzzleChoice.random.resolvePuzzleType(for: day4)
        let puzzle5 = AlarmPuzzleChoice.random.resolvePuzzleType(for: day5)
        
        // Ensure that the puzzle resolved is one of the valid playable types
        let validPool: [PuzzleType] = [.mathMatch, .memorySequence, .shakePhone]
        XCTAssertTrue(validPool.contains(puzzle1))
        XCTAssertTrue(validPool.contains(puzzle2))
        XCTAssertTrue(validPool.contains(puzzle3))
        
        // Ensure day-by-day stability (same day returns same puzzle)
        let puzzle1Again = AlarmPuzzleChoice.random.resolvePuzzleType(for: day1)
        XCTAssertEqual(puzzle1, puzzle1Again, "The same calendar date should deterministically resolve to the same puzzle")
        
        // Across multiple sequential days, ensure there is variety (not just stuck on 1 puzzle)
        let sequence = [puzzle1, puzzle2, puzzle3, puzzle4, puzzle5]
        let uniqueCount = Set(sequence).count
        XCTAssertGreaterThan(uniqueCount, 1, "Random puzzle selection should vary across days")
    }
    
    func testAlarmSinglePuzzleDefaultAndDecoding() throws {
        let alarm = Alarm(time: Date(), label: "Single Puzzle Test")
        XCTAssertEqual(alarm.puzzlesRequired, 1)
        XCTAssertEqual(alarm.selectedPuzzle, .random)
        
        // Test decoding legacy JSON without selectedPuzzle
        let legacyJSON = """
        {
            "id": "12345678-1234-1234-1234-1234567890AB",
            "time": 0,
            "label": "Old Alarm",
            "isEnabled": true,
            "repeatDays": [2, 3]
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Alarm.self, from: legacyJSON)
        XCTAssertEqual(decoded.selectedPuzzle, .random)
        XCTAssertEqual(decoded.puzzlesRequired, 1)
        XCTAssertEqual(decoded.label, "Old Alarm")
    }
}
