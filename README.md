# PULSE CLASH

**PULSE CLASH** is a lightweight, offline-first 2D isometric arcade survival game built with Godot 4 and GDScript.

The game is designed for rapid replayability, smooth responsive controls, and high performance on mobile devices and lower-spec hardware (such as Intel UHD 620 integrated graphics).

---

## Gameplay Concept

You control a glowing cyan energy orb inside a diamond-shaped isometric arena:
- **Move:** Tap or drag anywhere on screen to glide smoothly across the arena.
- **Collect:** Gather golden energy shards scattered across the floor (+10 points each).
- **Avoid:** Red pursuer enemies will hunt you down; direct contact destroys your core.
- **Pulse:** Activate your signature shockwave ability to stun nearby enemies and magnetically draw nearby energy shards into your core.
- **Survive:** Last as long as possible as enemy numbers and speeds scale upwards!

---

## How to Play / Run

### On Desktop (Windows):
1. Launch via Godot 4.3: `& 'D:\Tools\Godot\godot.exe' --path 'D:\Game'`
2. Tap **TAP TO START** on the title screen.
3. Left-click or drag with mouse to glide your cyan orb across the arena.
4. Press the large cyan **PULSE** button (or Spacebar / Right-click) to trigger the shockwave.
5. Toggle sound on/off with the top-right **SOUND** button.

### On Android Mobile:
1. Debug APK is pre-built at `D:\Game\build\pulse_clash.apk` (Signed with v1/v2/v3 schemes).
2. Connect your device via USB with USB Debugging enabled, and run:
   `& "D:\Tools\AndroidSDK\platform-tools\adb.exe" install -r "D:\Game\build\pulse_clash.apk"`
3. Launch **Pulse Clash** from your app drawer.

---

## Automated QA & Test Commands

Run any of the built-in automated test suites headlessly:
```powershell
# Master QA integration suite (11 end-to-end verifications)
& 'D:\Tools\Godot\Godot_v4.3-stable_win64_console.exe' --path 'D:\Game' --headless ++ --test-master-qa

# Core gameplay loop test
& 'D:\Tools\Godot\Godot_v4.3-stable_win64_console.exe' --path 'D:\Game' --headless ++ --test-core-loop

# Touch, viewport centering & balance verification
& 'D:\Tools\Godot\Godot_v4.3-stable_win64_console.exe' --path 'D:\Game' --headless ++ --test-milestone-013
```

---

## Technology Stack

- **Engine:** Godot Engine 4.3 (Standard 64-bit portable)
- **Language:** GDScript
- **Renderer:** GL Compatibility (OpenGL ES 3.2 on Android, OpenGL 3.3 on PC) — optimized for Intel UHD 620 and Qualcomm Adreno GPUs.
- **Art Style:** Pure procedural 2D canvas drawing (`_draw()`), 0 external image memory overhead.
- **Audio:** 100% RAM-synthesized 16-bit PCM procedural audio (zero audio asset files).
- **Persistence:** Local offline JSON save file (`user://pulse_clash_save.json`) for high scores and preferences.
