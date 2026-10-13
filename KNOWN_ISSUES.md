# PULSE CLASH — KNOWN ISSUES & LIMITATIONS

## Current Status (Master Production Polish & Offline QA Verified)

1. **Physical On-Device Playtest Re-Validation:**
   - **Current State:** Freshly signed production debug APK (`D:\Game\build\pulse_clash.apk`, 24.65 MB, v1/v2/v3 verified) is compiled and ready for deployment.
   - **Verified in this Build:**
     - Atmospheric void space background with drifting energy motes and perspective depth.
     - Grounded isometric contact shadows beneath player, enemies, and floating shards.
     - Shard pickup juice with 8 radial spark bursts and floating `+10` score popup.
     - Dual-ring cyan/violet pulse shockwave with radial energy spokes.
     - Zero-asset 16-bit PCM procedural audio suite (UI chirps, stun zap, countdown beeps, shard chime, pulse hum, game-over crunch).
     - Audio mute toggle with persistent JSON storage (`user://pulse_clash_save.json`).
     - 3... 2... 1... ENGAGE! countdown flow before run start.
     - Touch drag continuous gliding with dynamic viewport centering.
     - 2.0-second initial grace period + invulnerability orbital shield.
     - 1 starting enemy spawning >300px away with 2.0s materialization warmup.
     - Master automated QA test suite (`--test-master-qa`) passes 11/11 verifications with exit code 0.
   - **Next Action:** When the Motorola edge 70 is re-connected over USB, run `adb install -r D:\Game\build\pulse_clash.apk` to push the fresh APK, or sideload `D:\Game\build\pulse_clash.apk` directly on device.

2. **Multiplayer Online Servers:**
   - Offline game loop is 100% complete, robust, and completely independent of network connections.
   - Multiplayer architecture is fully documented in `MULTIPLAYER_DESIGN.md`. Online peer-to-peer or server hosting is deferred to future online phases to maintain the ₹0 budget.


