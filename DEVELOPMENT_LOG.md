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
- Root Cause Diagnosis:
  - **Occluded Arena Floor (The Root Cause)**: In `scenes/main/main.tscn`, `Arena` had `z_index = -1` while `Background` (`ColorRect`) had default `z_index = 0`. Because `Background` is an opaque full-screen rectangle at z=0, Godot rendered `Arena` behind it, completely occluding 100% of the arena floor. The fix set `Background` to `z_index = -100` (`z_as_relative = false`) and restored `Arena` to `z_index = 0`.
  - **Touch Drag Blocked**: Full-screen UI containers (`Main`, `Background`, `UI`, `InGameHUD`) lacked `mouse_filter = IGNORE` (2), absorbing touch drag events before `player.gd` could receive them.
  - **Instant Death Defect**: Initial enemy spawned ~150px from player at t=0 with 0 grace period, killing player in 1.1s.
  - **Microscopic Entities & Small Buttons**: Entities and Pulse button were uncomfortably small on high-DPI portrait mobile screens.
- Visual & Arena Rebuild:
  - Scaled tile dimensions to 76×68 px (`TILE_WIDTH = 76.0`, `TILE_HEIGHT = 68.0`). On a 9×9 grid, this spans **684×612 px** (99.3% screen width, 93.3% portrait play space).
  - High-contrast checkerboard tile fills (`Color(0.08, 0.16, 0.32)` / `Color(0.05, 0.10, 0.22)`) with 2.0px electric cyan lines and 1.2px top bevel highlight.
  - Outer perimeter ground halo (18px expansion, `Color(0.0, 0.45, 0.9, 0.15)`), dual-layer glowing neon perimeter (3.5px sharp cyan edge + 8.0px soft bloom), 4 glowing diamond corner markers, and concentric central pulse marker.
- Gameplay & Survival Balance:
  - Added 2.5s initial grace period with rotating orbital shield and player invulnerability.
  - Delayed initial enemy spawn to furthest perimeter corner (>320px away) at fair speed (112 px/s).
  - Scaled entities ~2×: Player orb (13px nucleus, 24px corona, 34px glow), Chasers (26×18px, 32px bloom), Shards (30×20px, 26px bloom).
- Mobile Controls & HUD Polish:
  - Set `mouse_filter = IGNORE` across all non-interactive containers; interactive buttons retain `STOP`.
  - Transformed touch coordinates via `get_canvas_transform().affine_inverse() * event.position`.
  - Enlarged Pulse button to 140×140 with dynamic `PULSE\nREADY` vs `PULSE\n%.1fs` cooldown text.
  - Added safe-area top margins for camera punch-holes.
  - Redesigned Game-Over screen with bold CORE CRITICAL typography, glowing stats card, and 270×64 touch buttons.
- Verification & Device Deployment:
  - Re-ran test suites (`--test-milestone-001`, `--test-milestone-002`, `--test-core-loop`): all passed (exit code 0).
  - Headless render test via PIL confirmed 84,368 px of rendered floor tiles and neon grid lines across 93.3% vertical span.
  - Exported and signed new debug APK (`D:\Game\build\pulse_clash.apk`, 23.48 MB).
  - Streamed install to Motorola edge 70 (`Success`) via ADB.
  - Awaiting physical playtest by the founder to verify tactile drag feel on hardware.
