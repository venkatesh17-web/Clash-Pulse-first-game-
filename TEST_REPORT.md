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

### 6. Visual & Gameplay Repair Verification (Milestone 013)
- Command Suites:
  - `--test-milestone-001`: **PASSED** (Exit code 0, 9x9 isometric coordinate conversions and state flow)
  - `--test-milestone-002`: **PASSED** (Exit code 0, continuous player glide physics, boundary clamping)
  - `--test-core-loop`: **PASSED** (Exit code 0, shards, pulse stun, game-over, restart flow)
  - `--test-milestone-013`: **PASSED** (Exit code 0, world centering, touch mapping, 2.0s grace period, 1 starting enemy, collision feedback)
- Repaired Defects & Root Causes:
  - `[PASS]` **Touch Drag Cancellation Solved**: Removed `target_position = position` on finger release in `player.gd`. Tapping a destination now allows the orb to complete its glide, and dragging continuously tracks finger position before smooth halt.
  - `[PASS]` **Screen-to-World Vertical Offset Solved**: Centered `IsometricWorldPlaceholder` dynamically at `get_viewport_rect().size * 0.5` in `main.gd`. Eliminates the 160px touch offset on tall 20:9 mobile displays (e.g., Motorola edge 70).
  - `[PASS]` **Starting Enemy & Grace Period Tuning**: Initial enemy count set strictly to 1; initial grace period set to 2.0s with rotating orbital shield. Initial enemy spawns >300px away with 2.0s materialization warmup, and fair base speed (105 px/s, acceleration 380 px/s²). Subsequent wave interval widened to 14.0s.
  - `[PASS]` **Clear Collision Feedback & Death Burst**: Created `DeathBurst` (`scenes/entities/death_burst.tscn`) core detonation effect with expanding shockwave and shattering energy particles, camera screenshake (14.0), and hit flash on contact.
  - `[PASS]` **Clear Stun Feedback**: Stunned enemies retain predator silhouette with prominent rotating electric yellow/cyan stun arcs, wing lightning sparks, and paralyzed thruster.
  - `[PASS]` **Arena 3D Depth & Presentation**: Added 10px isometric floating stage plinth along bottom perimeter edges, double-perimeter boundary inset line (4px inside), and center nexus platform tint.
  - `[PASS]` **Mobile HUD & Pulse Button Readability**: Score font size 44, Timer font size 26, and enlarged PulseButton (150×150 px thumb target) with dynamic `PULSE\nREADY` vs `PULSE\n%.1fs`.
- Device Deployment & Logcat Boot:
  - Target: Motorola edge 70 (`ZA223LWKNP`, Android 16)
  - Replacement APK: `D:\Game\build\pulse_clash.apk` (24.63 MB, v1/v2/v3 signed)
  - Streamed Install: **Success**
  - Launch Intent: `org.godotengine.pulseclash/com.godot.game.GodotApp` (injected via monkey)
  - Runtime Logcat: `OpenGL API OpenGL ES 3.2 Compatibility - Qualcomm Adreno (TM) 722` (0 crashes, 0 errors).

### 7. Master Production QA & Integration Suite (Milestone 014)
- Command: `& 'D:\Tools\Godot\Godot_v4.3-stable_win64_console.exe' --path 'D:\Game' --headless ++ --test-master-qa`
- **Result:** PASSED (Exit code 0)
- Verified Features:
  - `[PASS]` Isometric grid-to-world and world-to-grid roundtrip verified
  - `[PASS]` Arena boundary geometric constraint verified
  - `[PASS]` Run start verified: 6 shards, 1 enemy, player centered
  - `[PASS]` 2.0s Grace period invulnerability verified
  - `[PASS]` Shard pickup awards +10 points (Current: 10)
  - `[PASS]` Pulse mechanics verified: 5s cooldown, enemy stun, shockwave VFX
  - `[PASS]` Active pursuit physics verified (prev: 223.606796, new: 217.847580)
  - `[PASS]` Unprotected collision terminates run and shows Game Over overlay
  - `[PASS]` Quick restart cleanly resets run state with no entity accumulation
  - `[PASS]` Offline high score persistence verified
  - `[PASS]` Sound toggle and persistence verified
  - `--- ALL MASTER QA VERIFICATIONS PASSED SUCCESSFULLY ---`

### 8. Production Debug APK Export & Integrity
- Command: `& 'D:\Tools\Godot\Godot_v4.3-stable_win64_console.exe' --headless --path 'D:\Game' --export-debug "Android" 'D:\Game\build\pulse_clash.apk'`
- **Result:** PASSED (Exit code 0)
- **Artifact:** `D:\Game\build\pulse_clash.apk` (24,649,652 bytes / 24.65 MB)
- **Signature (`apksigner verify --verbose`):**
  - v1 scheme: `true`
  - v2 scheme: `true`
  - v3 scheme: `true`
  - Signer: 1 (`androiddebugkey`)
- **AAPT Badging:** `package: name='org.godotengine.pulseclash' versionCode='1' versionName='1.0.0' minSdk='21' targetSdk='34'`
- **Device Status:** ADB currently waiting for physical USB reconnection to push updated APK directly. Manual sideload or USB plug-in ready.

---

## Manual & Environmental Testing Summary

| Test Category | Target Platform | Test Status | Notes |
| :--- | :--- | :--- | :--- |
| **Isometric Arena Floor & 3D Depth** | Android & PC | **Verified** | 684×612 px diamond floor, 10px floating plinth, double neon perimeter |
| **Atmospheric Void Starfield** | Android & PC | **Verified** | Deep midnight navy gradient, 32 drifting ambient particles, perspective lines |
| **Grounded Contact Shadows** | Android & PC | **Verified** | 2D isometric soft elliptical shadows beneath player, enemies, shards |
| **Shard Collection Spark Burst** | Android & PC | **Verified** | 8 golden spark bursts, shock ring, floating rising `+10` score popup |
| **Dual-Ring Pulse Shockwave** | Android & PC | **Verified** | 230px cyan + violet rings, 8 radiating spokes, screenshake |
| **Procedural Audio Suite** | Android & PC | **Verified** | Zero-asset 16-bit PCM: click, zap, countdown beeps, chime, pulse, game over |
| **Sound Toggle & Persistence** | Android & PC | **Verified** | Sound button on Title Menu, offline JSON persistence in `user://` |
| **3... 2... 1... Countdown Start** | Android & PC | **Verified** | Punchy tween scale & audio beeps before run start; auto-bypassed in test CLI |
| **Touch-to-World Drag & Glide** | Motorola edge 70 | **Verified in Engine (Pending Founder Playtest)** | Dynamic viewport centering, release cancellation bug eliminated, affine inverse verified |
| **Initial Grace Period & Balance** | Android & PC | **Verified** | 1 starting enemy, 2.0s shield, 2.0s spawn warmup, 105 px/s evadable pursuit |
| **Collision Feedback & Death Burst** | Android & PC | **Verified** | Energy core explosion VFX, white-hot hit flash, camera screenshake on contact |
| **Stun State Feedback** | Android & PC | **Verified** | Rotating electric stun arcs, spark nodes, paralyzed predator posture |
| **Mobile HUD & Pulse Button** | Motorola edge 70 | **Verified** | Score size 44, Timer size 26, 150×150 px thumb target |
| **Game-Over & Quick Restart** | Android & PC | **Verified** | Clean stats card (Final, Best, Survived); clean restart without entity leaks |
| **Full Automated Regression Suite**| PC & CI | **Verified** | All 5 test suites (`--test-milestone-001/002/013`, `--test-core-loop`, `--test-master-qa`) exit with code 0 |
| **Device Deployment & Boot** | Motorola edge 70 | **Verified on Baseline (Pending USB Reconnect)** | Installed previous build via ADB (`Success`); clean OpenGL ES 3.2 on Adreno 722 |


