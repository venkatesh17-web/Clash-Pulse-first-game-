# PULSE CLASH — TASK BACKLOG

**Status Codes:**
- `[PAS]` Tested & Passing
- `[DOC]` Documented / Specification Complete
- `[FND]` Requires Founder Action / Approval

---

## Milestone 001: Project Audit & Baseline
- [PAS] Verify Godot 4.3 installation and User PATH availability
- [PAS] Verify project settings, compatibility renderer, 720x1280 portrait viewport
- [PAS] Create folder structure, .gitignore, and icon.svg
- [PAS] Autoloads registered: GameManager & AudioManager
- [PAS] Headless test validation

## Milestone 002: Player Entity & Movement
- [PAS] Reusable Player entity scene (`scenes/entities/player.tscn`)
- [PAS] Continuous tap/drag destination tracking for desktop & mobile
- [PAS] Smooth acceleration, deceleration, and stopping distance
- [PAS] Arena boundary clamping
- [PAS] Procedural cyan energy orb renderer with high-contrast silhouette
- [PAS] Squash & stretch animation on start/stop with smooth return
- [PAS] Lightweight Line2D motion trail

## Milestone 003: 9x9 Isometric Arena
- [PAS] Upgrade arena grid dimensions to 9x9 logical diamond layout
- [PAS] Depth ordering support (Y-sort) for isometric entities
- [PAS] Responsive isometric boundaries and perimeter glow
- [PAS] Verified grid-to-world and world-to-grid coordinate transforms

## Milestone 004: Collectibles & Scoring
- [PAS] Create Golden Shard entity (`scenes/entities/energy_shard.tscn`)
- [PAS] Procedural golden diamond crystal visual with gentle hover pulse
- [PAS] Shard Spawner: spawn exactly 6 shards on valid arena cells
- [PAS] Collision detection: collect shard -> +10 points -> respawn safely away from player
- [PAS] Floating collection feedback text/burst
- [PAS] Score persistence & high-score updates

## Milestone 005: Enemies & Survival
- [PAS] Create Red Enemy entity (`scenes/entities/enemy.tscn`)
- [PAS] Aggressive pursuit AI moving toward player's position
- [PAS] Enemy Spawner: dynamic wave timer scaling up to max 8 enemies
- [PAS] Stun state handling: pause movement while stunned
- [PAS] Player contact detection -> triggers Game Over

## Milestone 006: Pulse Ability
- [PAS] On-screen mobile Pulse button in HUD
- [PAS] Shockwave expanding ring visual effect
- [PAS] Enemy stun logic (140px radius, 1.5s duration)
- [PAS] Energy shard magnetic attraction (180px radius)
- [PAS] 5.0 second cooldown timer with radial/bar cooldown indicator
- [PAS] Touch conflict avoidance (pulse button does not issue movement)

## Milestone 007: Game Loop & User Interface
- [PAS] Full lifecycle: Title -> Play -> Game Over -> Restart
- [PAS] HUD: Score counter, High Score, Survival Timer, Pulse Cooldown
- [PAS] Game-Over overlay: Final score, survival time, best score, quick restart
- [PAS] Android back-button support across all screens

## Milestone 008: Game Feel & Polish
- [PAS] Screen shake on Pulse shockwave and game over
- [PAS] Procedural synthesized sound effects (coin chime, pulse hum, game over crunch)
- [PAS] Audio pooling via AudioManager
- [PAS] Smooth color palette, contrast calibration, and 60 FPS performance on Intel UHD 620

## Milestone 009: Offline Quality Assurance
- [PAS] End-to-end automated verification script in Godot headless (`--test-core-loop`)
- [PAS] Backward compatibility regression checks (`--test-milestone-001`, `--test-milestone-002`)
- [PAS] Zero-dependency offline verification

## Milestone 010: Android Preparation & APK Export
- [PAS] Verified Java JDK 17 installed on system (`C:\Program Files\Eclipse Adoptium\jdk-17.0.19.10-hotspot\`)
- [PAS] Installed Android SDK Command-line Tools (`adb`, `aapt`, `apksigner`, `zipalign`, `android-34`)
- [PAS] Generated debug signing keystore (`D:\Tools\AndroidSDK\debug.keystore`)
- [PAS] Installed Godot 4.3 official export templates in `%APPDATA%\Godot\export_templates\4.3.stable\`
- [PAS] Configured Android export preset in `export_presets.cfg`
- [PAS] Exported debug APK (`D:\Game\build\pulse_clash.apk`, 23.48 MB)
- [PAS] Validated APK signature and manifest badging with `apksigner` and `aapt`
- [DOC] Physical on-device deployment documented; ready for connection

## Milestone 011: Online Multiplayer Architecture
- [DOC] Complete technical design specification (`MULTIPLAYER_DESIGN.md`)
- [DOC] Peer-to-peer / LAN zero-cost architecture documented

## Milestone 012: Final Delivery
- [PAS] Project fully documented: README, DEVELOPMENT_LOG, TEST_REPORT, KNOWN_ISSUES
- [PAS] Clean handoff ready for founder testing

## Milestone 013: Visual & Gameplay Repair (Phone Screen Recording Recovery)
- [PAS] Diagnose touch input swallowing bug and configure `mouse_filter = IGNORE` on non-interactive overlays
- [PAS] Scale diamond arena dimensions to 76×38 px tiles with high-contrast checkerboard fills
- [PAS] Dual-layer neon boundary, glowing corner vertices, and center pulse pad
- [PAS] Scale player orb, chaser enemy, and golden shard visuals ~2× for mobile legibility
- [PAS] Implement 2.5s initial grace period, safe corner spawn, and player shield invulnerability
- [PAS] Enlarge Pulse button to 130×130 with high-contrast thumb-friendly READY/COOLDOWN states
- [PAS] Polish Game-Over screen hierarchy, stats breakdown, and 270×64 restart buttons
- [PAS] Automated verification passing across all suites (`--test-milestone-001`, `--test-milestone-002`, `--test-core-loop`, `--test-milestone-013`)
- [PAS] Export, sign, and install repaired APK onto Motorola edge 70 via ADB

## Milestone 014: Master Game Creation Directive (Production Polish & QA)
- [PAS] Atmospheric Void Background (`background_stars.gd`): deep midnight navy gradient, 32 drifting energy motes, vanishing perspective lines
- [PAS] Grounded 2D Isometric Contact Shadows: soft elliptical ambient occlusion beneath player, enemies, and floating energy shards
- [PAS] Shard Collection Juice (`shard_pickup_effect.tscn`): 8 radial golden spark motes, expanding ring, and floating "+10" score popup
- [PAS] Dual-Ring Pulse Shockwave: concentric 230px cyan and violet shockwave rings, 8 radiating spokes, and dynamic screen shake
- [PAS] Procedural 16-bit PCM Audio Suite (`sound_synth.gd`): synthesized UI clicks, electric stun zaps, chime, pulse, game over, and countdown beeps
- [PAS] Audio Preference & JSON Persistence: Sound toggle button on TitleMenu persisting to `user://pulse_clash_save.json`
- [PAS] Countdown Start Transition: 3... 2... 1... ENGAGE! punchy scale/fade tween with SFX beeps and automated test bypass
- [PAS] Master Automated QA Suite (`--test-master-qa`): 11 end-to-end integration verifications passing with exit code 0
- [PAS] Android Production Debug APK exported, signed (v1/v2/v3), and verified at `D:\Game\build\pulse_clash.apk` (24.65 MB)
