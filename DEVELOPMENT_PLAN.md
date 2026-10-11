# PULSE CLASH — DEVELOPMENT PLAN

**Game:** PULSE CLASH  
**Genre:** 2D Isometric Arcade Survival  
**Engine:** Godot 4.3 (GL Compatibility Renderer)  
**Target Platform:** Android (with Windows 11 PC dev environment)  
**Budget:** ₹0 (Free tools, procedural vector art, offline-first)  

---

## 1. Architecture Overview

- **View & Projection:** 2D Dimetric Isometric projection (2:1 ratio) centered at screen coordinates `(360, 640)` on a `720x1280` portrait viewport with `canvas_items` stretch mode. Desktop override is `405x720` for convenient phone-proportioned window testing.
- **Rendering Approach:** Procedural 2D canvas drawing (`_draw()`) and lightweight 2D nodes (`Line2D`, `CircleShape2D`, `Polygon2D`). Avoids heavy texture assets, maximizes battery life on mobile, and guarantees 60+ FPS on Intel UHD 620 graphics.
- **Audio Approach:** Procedural 16-bit PCM sound synthesis (`SoundSynth`) executed at launch. Zero external sound files, instant playback, zero disk footprint.
- **State Management:** Centralized `GameManager` autoload singleton managing `MENU`, `PLAYING`, `PAUSED`, `GAME_OVER`, offline high-score persistence via `user://pulse_clash_save.json`, and Android back-button navigation.
- **Input Strategy:** Continuous touch/mouse drag input via `_unhandled_input()`, completely decoupled from UI elements so button presses never cause accidental player movement.

---

## 2. Milestone Roadmap & Status

| Milestone | Title | Scope | Status |
| :--- | :--- | :--- | :--- |
| **001** | Project Audit & Baseline | Inspection, environment setup, Godot 4.3 configuration | **Completed** |
| **002** | Player Entity & Movement | Cyan orb, continuous tap/drag, squash/stretch, trail | **Completed** |
| **003** | 9x9 Isometric Arena | 9x9 diamond grid, Y-sort depth ordering, boundary math | **Completed** |
| **004** | Collectibles & Scoring | 6 golden shards, respawning, attraction, scoring | **Completed** |
| **005** | Enemies & Survival | Red chasing pursuers, wave scaling, max 8 enemies | **Completed** |
| **006** | Pulse Ability | Shockwave stun (140px), shard attract (180px), 5s cooldown | **Completed** |
| **007** | Game Loop & UI | Start menu, Game-Over, restart, HUD, timer, high scores | **Completed** |
| **008** | Game Feel & Polish | Screenshake, procedural audio SFX, particle shockwaves | **Completed** |
| **009** | Offline QA Suite | Comprehensive headless verification suite | **Completed** |
| **010** | Android Readiness | Audit Android SDK/build tools, manifest & export config | **Audited (Action Req.)** |
| **011** | Multiplayer Architecture | Technical design document, state sync, local prototype | **Documented** |
| **012** | Final Delivery | Comprehensive README, play instructions, handoff report | **Completed** |
