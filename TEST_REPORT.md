# PULSE CLASH — TEST REPORT

**Execution Environment:**
- OS: Windows 11 64-bit
- Engine: Godot Engine v4.3.stable.official (Win64)
- CPU: Intel Core i5-8365U
- GPU: Intel UHD Graphics 620 (GL Compatibility Mode)
- Memory: 8 GB RAM

---

## Automated Test Results

### 1. Core Gameplay Loop Test Suite
- Command: `& 'D:\Tools\Godot\Godot_v4.3-stable_win64_console.exe' --path 'd:\Game' --headless ++ --test-core-loop`
- **Result:** PASSED (Exit code 0)
- Verified Features:
  - `[PASS]` New run started: 6 shards and initial enemy spawned
  - `[PASS]` Shard collection awarded +10 points (Current: 10)
  - `[PASS]` Pulse ability triggered: Shockwave spawned, enemy stunned, cooldown active
  - `[PASS]` Enemy contact ends run, GAME_OVER state activated, overlay displayed
  - `[PASS]` Quick restart successfully initiated new run with fresh state
  - `[PASS]` Menu return verified

### 2. Milestone 002 Player & Movement Test Suite
- Command: `& 'D:\Tools\Godot\Godot_v4.3-stable_win64_console.exe' --path 'd:\Game' --headless ++ --test-milestone-002`
- **Result:** PASSED (Exit code 0)
- Verified Features:
  - `[PASS]` Player entity structure verified (CharacterBody2D, Visuals, Trail)
  - `[PASS]` Player starts centered and stationary
  - `[PASS]` Menu state gate verified (Movement inhibited in MENU)
  - `[PASS]` Continuous movement physics verified (Target=(80, 40), Velocity > 0)
  - `[PASS]` Arena boundary clamping verified: (5000, 5000) clamped to arena diamond
  - `[PASS]` Stopping distance and squash/stretch recovery verified
  - `[PASS]` Return to menu verified (Player reset to center, UI restored)

### 3. Milestone 001 Arena & Base Transition Test Suite
- Command: `& 'D:\Tools\Godot\Godot_v4.3-stable_win64_console.exe' --path 'd:\Game' --headless ++ --test-milestone-001`
- **Result:** PASSED (Exit code 0)
- Verified Features:
  - `[PASS]` Arena is valid Node2D
  - `[PASS]` Arena coordinate conversions verified for (2, 3)
  - `[PASS]` StartButton state transition verified
  - `[PASS]` Menu return transition verified

### 4. Normal Engine Boot Test
- Command: `& 'D:\Tools\Godot\Godot_v4.3-stable_win64_console.exe' --path 'd:\Game' --headless --quit-after 60`
- **Result:** PASSED (Exit code 0, clean launch and 60-frame run without errors)

### 5. Android Debug APK Export & Validation
- Command: `& 'D:\Tools\Godot\Godot_v4.3-stable_win64_console.exe' --headless --path 'D:\Game' --export-debug "Android" 'D:\Game\build\pulse_clash.apk'`
- **Result:** PASSED (Exit code 0)
- **Artifact:** `D:\Game\build\pulse_clash.apk`
- **Binary Size:** 23.48 MB (24,619,975 bytes)
- **AAPT Package Inspection:**
  - Package Name: `org.godotengine.pulseclash`
  - Version: Code 1, Name 1.0.0
  - Min SDK / Target SDK: `21` / `34` (Android 14)
  - Architecture ABI: `arm64-v8a`
  - Launchable Activity: `com.godot.game.GodotApp`
  - Application Label: `Pulse Clash`
- **Signature Verification (`apksigner verify --verbose`):**
  - Result: `Verifies`
  - Scheme v1 (JAR signing): `true`
  - Scheme v2 (APK Signature Scheme v2): `true`
  - Scheme v3 (APK Signature Scheme v3): `true`
  - Signer: 1 (Debug keystore: `D:\Tools\AndroidSDK\debug.keystore`)
- **ADB Physical Device Status & Installation:**
  - `adb devices`: Detected connected authorized physical device: `motorola edge 70` (`ZA223LWKNP`, Android 16).
  - Installation Command: `adb install -r D:\Game\build\pulse_clash.apk`
  - Installation Result: **Success** (`Performing Incremental Install`, `Performing Streamed Install` -> `Success`).
  - Target Hardware: Motorola edge 70 (Android 16).
  - Status: Debug APK successfully deployed and present in device app drawer as **Pulse Clash**.

---

## Manual & Environmental Testing Summary

| Test Category | Target Platform | Test Status | Notes |
| :--- | :--- | :--- | :--- |
| **Mouse Drag & Destination** | Windows 11 PC | **Verified** | Continuous movement follows cursor smoothly |
| **Touch Emulation** | Windows 11 PC | **Verified** | `emulate_touch_from_mouse` responsive |
| **UI Touch Bleed-through** | Windows 11 PC | **Verified** | Clicking Pulse/Menu buttons does NOT trigger movement |
| **Procedural Audio Output** | Windows 11 PC | **Verified** | 16-bit PCM synth buffers play with zero latency |
| **Screenshake Decay** | Windows 11 PC | **Verified** | Linear decay without viewport clipping |
| **Android Export Build** | Android OS | **Verified** | Debug APK built, signed, aligned, and verified (23.48 MB) |
| **Device Deployment** | Motorola edge 70 | **Verified** | Debug APK successfully installed on physical device via ADB (`Success`) |
| **Multi-touch Gameplay** | Physical Android | **Ready for Playtest** | Installed on hardware; ready for live founder touch testing |


