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
        XCTAssertEqual(AlarmChallengeChoice.mathMatch.resolveChallengeType(), .mathMatch)
        XCTAssertEqual(AlarmChallengeChoice.memorySequence.resolveChallengeType(), .memorySequence)
        XCTAssertEqual(AlarmChallengeChoice.shakePhone.resolveChallengeType(), .shakePhone)
        XCTAssertEqual(AlarmChallengeChoice.pushups.resolveChallengeType(), .pushups)
        XCTAssertEqual(AlarmChallengeChoice.photoHunt.resolveChallengeType(), .photoHunt)
        XCTAssertEqual(AlarmChallengeChoice.squats.resolveChallengeType(), .squats)
        XCTAssertEqual(AlarmChallengeChoice.steps.resolveChallengeType(), .steps)
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
        
        let challenge1 = AlarmChallengeChoice.random.resolveChallengeType(for: day1)
        let challenge2 = AlarmChallengeChoice.random.resolveChallengeType(for: day2)
        let challenge3 = AlarmChallengeChoice.random.resolveChallengeType(for: day3)
        let challenge4 = AlarmChallengeChoice.random.resolveChallengeType(for: day4)
        let challenge5 = AlarmChallengeChoice.random.resolveChallengeType(for: day5)
        
        // Ensure that the challenge resolved is one of the valid pool containing both physical and cognitive challenges
        let validPool: [ChallengeType] = [
            .pushups, .photoHunt, .mathMatch, .memorySequence, .squats, .shakePhone, .steps
        ]
        XCTAssertTrue(validPool.contains(challenge1))
        XCTAssertTrue(validPool.contains(challenge2))
        XCTAssertTrue(validPool.contains(challenge3))
        
        // Ensure day-by-day stability (same day returns same challenge)
        let challenge1Again = AlarmChallengeChoice.random.resolveChallengeType(for: day1)
        XCTAssertEqual(challenge1, challenge1Again, "The same calendar date should deterministically resolve to the same challenge")
        
        // Across multiple sequential days, ensure variety across physical and cognitive challenges
        let sequence = [challenge1, challenge2, challenge3, challenge4, challenge5]
        let uniqueCount = Set(sequence).count
        XCTAssertGreaterThan(uniqueCount, 1, "Random challenge selection should vary across days")
    }
    
    func testAlarmSinglePuzzleDefaultAndDecoding() throws {
        let alarm = Alarm(time: Date(), label: "Single Challenge Test")
        XCTAssertEqual(alarm.puzzlesRequired, 1)
        XCTAssertEqual(alarm.selectedChallenge, .random)
        
        // Test decoding legacy JSON without selectedChallenge
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
        XCTAssertEqual(decoded.selectedChallenge, .random)
        XCTAssertEqual(decoded.puzzlesRequired, 1)
        XCTAssertEqual(decoded.label, "Old Alarm")
    }
}
