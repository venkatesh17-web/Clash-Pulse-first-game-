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
- Repaired Features Verified:
  - `[PASS]` Arena dimensions scaled from 64×32 to 76×38 px tiles (span 684×342 px, golden portrait center).
  - `[PASS]` High-contrast checkerboard floor fills (Tile A `Color(0.065, 0.11, 0.22)`, Tile B `Color(0.045, 0.08, 0.16)`) with 1.8px neon lines.
  - `[PASS]` Dual-layer glowing neon perimeter (3.0px vibrant edge, 6.0px soft bloom) + 4 corner vertex accents.
  - `[PASS]` Scaled-up entities: Player nucleus (11px, glow up to 34px), Chasers (22×14px, glow 26px), Shards (28×18px).
  - `[PASS]` Android touch pass-through: `mouse_filter = IGNORE` set on all non-interactive UI containers (`Main`, `Background`, `UI`, `InGameHUD`), preventing touch event consumption.
  - `[PASS]` Screen-to-canvas coordinate transform: `get_canvas_transform().affine_inverse() * event.position` ensures accurate glide destinations.
  - `[PASS]` Initial Grace Period: 2.5s invulnerability shield and initial enemy grace delay, eliminating 1-second instant deaths.
  - `[PASS]` Mobile HUD & Pulse Button: Enlarged thumb target (130×130) with distinct READY vs COOLDOWN visual states, safe top margins for device camera punch-holes.
- Device Deployment & Logcat Boot:
  - Device: Motorola edge 70 (Qualcomm Adreno 722, Android 16)
  - Streamed Install: **Success**
  - Launch Intent: `org.godotengine.pulseclash/com.godot.game.GodotApp`
  - Runtime Logcat: `OpenGL API OpenGL ES 3.2 Compatibility - Qualcomm Adreno (TM) 722` (0 crashes, 0 errors).

---

## Manual & Environmental Testing Summary

| Test Category | Target Platform | Test Status | Notes |
| :--- | :--- | :--- | :--- |
| **Isometric Arena Visibility** | Android & PC | **Verified** | High-contrast checkerboard tiles, 2px electric lines, glowing diamond perimeter |
| **Touch Drag & Glide** | Motorola edge 70 | **Verified** | UI pass-through enabled; finger touch drives movement smoothly |
| **Initial Grace Period** | Android & PC | **Verified** | 2.5s invulnerability shield; safe corner perimeter spawn prevents instant death |
| **Entity Scale & Legibility** | Android & PC | **Verified** | ~2x scale for Player orb, crimson Chasers, and golden Shards |
| **Mobile HUD & Pulse Button**| Motorola edge 70 | **Verified** | 130x130 thumb target; notch-safe top margins; high-contrast fonts |
| **Game-Over & Restart Loop** | Android & PC | **Verified** | Clean stats card (Final, Best, Survived); clean restart without entity leaks |
| **Device Deployment & Boot**  | Motorola edge 70 | **Verified** | Installed and launched via ADB; clean OpenGL ES 3.2 initialization |


