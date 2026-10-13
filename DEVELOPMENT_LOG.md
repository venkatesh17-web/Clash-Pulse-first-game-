# PULSE CLASH — DEVELOPMENT LOG

## Session 1: Autonomous Execution Through Offline MVP (Milestones 001–012)

### Milestone 001: Project Audit & Baseline
- Verified Godot 4.3 installation (`D:\Tools\Godot\godot.exe`) and User PATH availability.
- Created project folder structure, `.gitignore`, and vector `icon.svg`.
- Configured `project.godot`: portrait viewport (720x1280), `gl_compatibility` renderer for Intel UHD 620, touch from mouse enabled.
- Implemented `GameManager` autoload with offline JSON save/load (`user://pulse_clash_save.json`) and Android back button handling.
- Implemented `AudioManager` with pooled `AudioStreamPlayer` nodes.
- Implemented `IsometricHelper` for 2:1 dimetric coordinates.

### Milestone 002: Player Entity & Movement
- Created `Player` entity scene (`scenes/entities/player.tscn`) and controller (`scripts/entities/player.gd`).
- Continuous tap-and-drag destination tracking for desktop & mobile.
- Smooth acceleration, deceleration, and stopping distance.
- Implemented `PlayerOrbRenderer`: 5-layer procedural cyan energy orb with high-contrast silhouette and subtle pulse glow.
- Added non-destructive squash and stretch on movement start/stop.
- Added lightweight top-level `Line2D` motion trail.
- Added diamond boundary clamping in `Arena` (`clamp_to_arena`).

### Milestone 003: 9×9 Isometric Arena
- Upgraded arena grid dimensions to 9×9 logical diamond layout.
- Enabled `y_sort_enabled = true` on `IsometricWorldPlaceholder` for proper depth sorting.
- Configured `z_index = -1` on arena grid floor so entities always render cleanly above tiles.

### Milestone 004: Collectibles & Scoring
- Created `EnergyShard` entity (`scenes/entities/energy_shard.tscn` and `scripts/entities/energy_shard.gd`).
- Procedural golden crystal visual (`EnergyShardVisual`) with bobbing and pulse.
- Connected scoring (+10 points per shard), pickup feedback, and safe respawn away from player.

### Milestone 005: Enemies & Survival
- Created `Enemy` entity (`scenes/entities/enemy.tscn` and `scripts/entities/enemy.gd`).
- Implemented pursuit AI tracking the player, constrained to the arena perimeter.
- Created `EnemyVisual` procedural crimson predator with sharp silhouette and electric stun state visuals.
- Implemented stun state: halts enemy velocity and pauses movement until stun duration expires.
- Connected player collision to trigger run termination.

### Milestone 006: Pulse Signature Ability
- Created `PulseShockwave` expanding concentric ring VFX (`scenes/entities/pulse_shockwave.tscn` and `scripts/entities/pulse_shockwave.gd`).
- Implemented stun shockwave: stuns all enemies within 140px radius for 1.5 seconds.
- Implemented magnetic attraction: pulls all shards within 180px radius toward player.
- Configured 5.0 second cooldown with on-screen HUD button and cooldown timer indicator.

### Milestone 007: Complete Game Loop & User Interface
- Created `GameplayManager` orchestrator (`scripts/game/gameplay_manager.gd`).
- Built complete UI flow: Title Menu -> Active Gameplay HUD -> Game-Over Overlay -> Quick Restart.
- Added survival timer, score counters, chaser count indicators, and personal best persistence.

### Milestone 008: Game Feel, Audio Synthesis & Polish
- Implemented `SoundSynth` (`scripts/utils/sound_synth.gd`): 100% procedural 16-bit PCM audio generation in code (zero asset files, zero disk overhead).
- Pre-synthesized crystal pickup chime, deep bass pulse sweep, and crunch game-over tone.
- Added dynamic screenshake on pulse detonation and run termination.
- Calibrated visual contrast for readability under rapid movement.

### Milestone 009: Offline Quality Assurance
- Automated test suites executed via Godot 4.3 CLI (`--test-core-loop`, `--test-milestone-001`, `--test-milestone-002`).
- All tests passed with exit code 0.

### Milestone 010: Android Export Pipeline & Debug APK Build
- Confirmed Java JDK 17 on Windows host (`C:\Program Files\Eclipse Adoptium\jdk-17.0.19.10-hotspot\`).
- Installed Android SDK Command-line Tools in `D:\Tools\AndroidSDK`:
  - `platform-tools` (`adb.exe`)
  - `build-tools/34.0.0` (`aapt.exe`, `apksigner.bat`, `zipalign.exe`)
  - `platforms/android-34` (`android.jar`)
- Generated standard debug keystore at `D:\Tools\AndroidSDK\debug.keystore` (alias: `androiddebugkey`, validity: 9999 days).
- Verified and extracted official Godot 4.3 export templates archive (`templates.tpz`) to `%APPDATA%\Godot\export_templates\4.3.stable\`.
- Resolved Godot 4.3 configuration lookup by linking SDK path and keystore directly in `%APPDATA%\Godot\editor_settings-4.3.tres`.
- Configured Android export preset in `export_presets.cfg` (`arm64-v8a`, Target SDK 34, Min SDK 21, package `org.godotengine.pulseclash`, immersive mode, vibration enabled, zero network permissions).
- Successfully exported signed, aligned Android debug package (`D:\Game\build\pulse_clash.apk`, 23.48 MB).
- Validated cryptographic signature with `apksigner` (v1, v2, v3 verified).
- Queried ADB and deployed to physical target hardware (`motorola edge 70`, Android 16) with `adb install -r D:\Game\build\pulse_clash.apk` (Result: `Success`).


### Milestone 011: Online Multiplayer Architecture
- Completed comprehensive technical design document (`MULTIPLAYER_DESIGN.md`).
- Recommended zero-budget Peer-to-Peer / LAN ENet model with host authority.

### Milestone 012: Handoff & Final Delivery
- Maintained all documentation files in `D:\Game`.
- Offline game is complete, playable, and validated.

### Milestone 013: Visual & Gameplay Recovery (Phone Screen Recording Repair)
- Root Cause Diagnosis & Fixes:
  - **Occluded Arena Floor**: In `scenes/main/main.tscn`, `Arena` had `z_index = -1` while `Background` (`ColorRect`) had default `z_index = 0`. Fixed `Background` to `z_index = -100` (`z_as_relative = false`) and restored `Arena` to `z_index = 0`.
  - **Touch Glide Interrupted on Release**: In `player.gd`, `target_position = position` on finger release was killing the selected destination prematurely. Removed destination wipe; tapping a destination now allows full glide travel, and dragging tracks smoothly before natural deceleration.
  - **Screen-to-World Vertical Offset on 20:9 Screens**: `IsometricWorldPlaceholder` position was hardcoded at `(360, 640)`, causing a 160px vertical touch discrepancy on tall mobile displays. Added dynamic viewport centering (`get_viewport_rect().size * 0.5`) in `main.gd`.
  - **7-Second Run Termination Balance**: Initial enemy count kept strictly at 1; initial grace period set to 2.0s with rotating orbital shield. Initial enemy spawns >300px away with 2.0s materialization warmup, and fair pursuit speed (105 px/s, acceleration 380 px/s²). Subsequent wave interval widened to 14.0s.
  - **Collision & Stun Feedback**: Added `DeathBurst` particle core detonation VFX on player-enemy contact, white-hot hit flash, and camera screenshake (14.0). Stunned enemies now display rotating electric yellow/cyan stun arcs and wing lightning sparks while paralyzed.
  - **Arena Presentation**: Added 10px 3D floating stage plinth along bottom perimeter edges, double-perimeter boundary inset line (4px inside), and center nexus platform tint.
  - **Mobile HUD & Pulse Button**: Enlarge Score (font size 44), Timer (font size 26), and PulseButton (150×150 px thumb target) with high-contrast `PULSE\nREADY` vs `PULSE\n%.1fs`.
- Verification & Device Deployment:
  - Headless test suites (`--test-milestone-001`, `--test-milestone-002`, `--test-core-loop`, `--test-milestone-013`): all passed with exit code 0.
  - Exported and signed replacement Android debug APK (`D:\Game\build\pulse_clash.apk`, 24.63 MB, v1/v2/v3 verified).
  - Streamed install to Motorola edge 70 (`Success`) via ADB.
  - Launched app via monkey intent; logcat confirms clean initialization on Qualcomm Adreno 722.

### Milestone 014: Master Game Creation Directive (Production Polish, Audio Suite, & QA)
- **Atmospheric Void Background (`scripts/ui/background_stars.gd`):**
  - Implemented vertical void background with deep midnight-navy linear gradient (`#06080F` to `#0A111F`).
  - Added 32 floating ambient energy particles with sinusoidal pulsation, gentle vertical drifting, and subtle vanishing perspective lines anchoring the isometric world in deep space.
- **Isometric Grounded Shadows:**
  - Added semi-transparent 2D isometric contact shadows (`Color(0.0, 0.0, 0.0, 0.35 - 0.45)`) beneath:
    - Player orb (`scripts/entities/player_orb_renderer.gd`): dynamic ellipse matching squish/stretch state.
    - Enemies (`scripts/entities/enemy_visual.gd`): red-tinted contact shadow.
    - Energy shards (`scripts/entities/energy_shard_visual.gd`): ground shadow that breathes with floating bob.
- **Shard Pickup Burst Effect & Popup (`scenes/entities/shard_pickup_effect.tscn`):**
  - Integrated 8 radial golden spark motes, expanding shock ring, and floating, rising, fading `+10` score popup label upon collection.
- **Dual-Ring Pulse Shockwave Upgrade (`scripts/entities/pulse_shockwave.gd`):**
  - Dual concentric rings (electric cyan 230px, violet 180px) with 8 radiating energy spokes and rotational impulse.
- **Zero-Asset Procedural Audio Suite (`scripts/utils/sound_synth.gd` & `scripts/autoload/audio_manager.gd`):**
  - 100% RAM-synthesized 16-bit PCM procedural audio for zero asset footprint.
  - Added UI click chirps, electric stun zap buzz, low and high pitch countdown beeps, alongside gem chime, pulse hum, and game-over crunch.
  - Added audio mute toggle button (`SoundButton`) to Title Menu with JSON save/load persistence in `user://pulse_clash_save.json`.
- **Countdown Start Flow:**
  - Added 3... 2... 1... ENGAGE! visual countdown overlay with punchy scale and fade tweens and audio beeps before run start. Automated test suites bypass this countdown delay cleanly.
- **Master Automated QA Suite (`scenes/main/main.gd` `--test-master-qa`):**
  - Built comprehensive 11-step integration test:
    1. Isometric grid <-> world roundtrip conversion
    2. Arena diamond boundary clamping
    3. Run start: 6 shards, 1 enemy, player centered
    4. 2.0s grace period invulnerability
    5. Shard collection (+10 score)
    6. Pulse 5s cooldown, stun, shockwave VFX
    7. Active enemy pursuit physics
    8. Unprotected collision & Game Over transition
    9. Quick restart clean state reset
    10. Offline high score JSON persistence
    11. Sound toggle preference JSON persistence
  - All automated test suites (`--test-milestone-001`, `--test-milestone-002`, `--test-core-loop`, `--test-milestone-013`, `--test-master-qa`) exit with code 0.
- **Android Production Debug Export:**
  - Re-exported and signed `D:\Game\build\pulse_clash.apk` (24.65 MB, v1/v2/v3 verified, targetSdk 34, minSdk 21).
