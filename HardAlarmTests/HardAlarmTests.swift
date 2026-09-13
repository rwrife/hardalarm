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
}
