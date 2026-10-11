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

---

## Manual & Environmental Testing Summary

| Test Category | Target Platform | Test Status | Notes |
| :--- | :--- | :--- | :--- |
| **Mouse Drag & Destination** | Windows 11 PC | **Verified** | Continuous movement follows cursor smoothly |
| **Touch Emulation** | Windows 11 PC | **Verified** | `emulate_touch_from_mouse` responsive |
| **UI Touch Bleed-through** | Windows 11 PC | **Verified** | Clicking Pulse/Menu buttons does NOT trigger movement |
| **Procedural Audio Output** | Windows 11 PC | **Verified** | 16-bit PCM synth buffers play with zero latency |
| **Screenshake Decay** | Windows 11 PC | **Verified** | Linear decay without viewport clipping |
| **Multi-touch Hardware** | Physical Android | **Pending** | Requires live Android phone deployment |
| **APK Package Export** | Android OS | **Pending** | Requires Android SDK & export template download |
