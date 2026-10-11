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

1. Open **Godot 4.3** (`D:\Tools\Godot\godot.exe`).
2. Import and select `D:\Game`.
3. Press **F5** (or Run Project).
4. Tap **TAP TO START** on the title screen.
5. Click or drag to move your cyan orb.

---

## Technology Stack

- **Engine:** Godot Engine 4.3 (Standard 64-bit portable)
- **Language:** GDScript
- **Renderer:** GL Compatibility (OpenGL 3.3) — optimized for Intel UHD 620 and Android battery/thermals
- **Art Style:** Pure procedural 2D canvas drawing (`_draw()`), 0 external image memory overhead
- **Audio:** Custom procedural synth audio pool
- **Persistence:** Local JSON save file (`user://pulse_clash_save.json`)
