# Privacy Policy for HardAlarm

**Effective Date:** September 13, 2026  
**Developer:** InfinityBall / Ryan Rife  
**Application:** HardAlarm: Wake-Up Challenges (`com.infinityball.hardalarm`)

HardAlarm is designed with a strict **local-first, privacy-by-design** philosophy. We believe your morning routine, home environment, and personal health metrics belong exclusively to you.

---

### 1. No Data Collection or Tracking
- **Zero Remote Tracking:** HardAlarm does not collect, transmit, sell, or share any personal information, telemetry, or analytics with third parties or external servers.
- **No User Accounts:** You do not need to register, log in, or provide an email address, phone number, or name to use the app.
- **Offline Operation:** HardAlarm operates completely offline. An internet connection is not required to set alarms, detect challenges, or track wake habits.

---

### 2. Device Permissions & On-Device Processing
HardAlarm requests specific iOS hardware permissions strictly to enable morning challenge verification:

- **Camera (`NSCameraUsageDescription`):**
  - Used exclusively during the **Photo Hunt** challenge to detect whether a morning household object (such as a coffee mug or bathroom sink) is in view.
  - Camera frames are analyzed in real-time in memory using Apple's on-device Vision and CoreML frameworks.
  - **No images or videos are ever saved to your photo library, written to disk, or transmitted over any network.**
- **Motion Sensors (`NSMotionUsageDescription`):**
  - CoreMotion accelerometer and gyroscope data are processed in real-time to detect physical push-up proximity, squat depth, and phone shakes.
  - Motion sensor data is discarded immediately upon challenge completion.
- **Microphone & Speech (`NSMicrophoneUsageDescription`, `NSSpeechRecognitionUsageDescription`):**
  - If voice affirmations are enabled, audio is processed on-device using Apple Speech framework. No audio recordings are stored or transmitted.
- **Notifications & Audio:**
  - Local notifications and background audio modes are utilized solely to ensure alarms sound reliably at your scheduled wake-up time.

---

### 3. Local Data Storage
- Your scheduled alarms, repeat preferences, sound choices, and wake streaks are stored locally on your device in standard iOS Application Sandbox storage (`UserDefaults`).
- You can reset or delete this data at any time by deleting individual alarms or uninstalling the app.

---

### 4. Children's Privacy
HardAlarm does not knowingly collect or solicit any personal information from children under the age of 13.

---

### 5. Changes to This Policy
Any future updates to this policy will be posted directly to this repository.

---

### 6. Contact & Support
If you have questions about this privacy policy or the application, please open an issue at:  
[https://github.com/rwrife/hardalarm/issues](https://github.com/rwrife/hardalarm/issues)
