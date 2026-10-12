# PULSE CLASH — GAMEPLAY GAP ANALYSIS & REPAIR PLAN

**Date:** 2026-10-12  
**Target Hardware:** Motorola edge 70 (Android 16, 1220×2712 OLED)  
**Baseline Build:** Godot 4.3 (GL Compatibility)  

---

## 1. Problem Observations & Root Cause Analysis

### Defect 1: Touch & Drag Input Not Moving Player
- **Observation:** Player does not follow touch/drag reliably on the phone.
- **Root Cause:** In `main.tscn`, full-screen `Control` containers (`Main`, `Background`, `UI`, `InGameHUD`) defaulted to `mouse_filter = MOUSE_FILTER_STOP` (0). In Godot 4, Controls with `STOP` absorb all touch events in `_gui_input`, entirely preventing `_unhandled_input` in `player.gd` from firing.
- **Resolution:** Set `mouse_filter = MOUSE_FILTER_IGNORE` (2) on all non-interactive full-screen overlays, containers, and labels. Handle touch input cleanly with canvas coordinate transformation so finger dragging anywhere in the arena converts directly to world coordinates without interference.

### Defect 2: Dark Background & Barely Visible Arena
- **Observation:** Arena is nearly pitch dark; diamond shape is barely recognizable.
- **Root Cause:** 
  1. `grid_size = 9x9`, `tile_width = 64.0`, `tile_height = 32.0` produced a total diamond footprint of only 576×288 pixels on a 720×1280 screen (only 22% of screen height).
  2. `cell_fill_color` was `Color(0.04, 0.08, 0.16, 0.6)` over dark background `Color(0.047, 0.055, 0.086)`, creating almost zero visual contrast.
  3. Wireframe lines were 1.0px thin with 0.4 alpha, disappearing on high-DPI phone displays.
- **Resolution:**
  1. Scale arena tile dimensions to `tile_width = 76.0`, `tile_height = 38.0` (span 684×342px), properly occupying the central portrait playable area.
  2. Implement rich alternating tile fills (deep midnight navy with subtle checkerboard contrast).
  3. Draw prominent 2.0px electric cyan grid lines with 3.5px glowing outer neon diamond boundary and corner vertex accents.

### Defect 3: Microscopic Entities
- **Observation:** Player orb, enemies, and shards appear tiny and disconnected.
- **Root Cause:**
  - Player orb nucleus was 6.5px radius; core 2.8px.
  - Chaser enemy was 12×8px.
  - Energy shard was 14×20px.
- **Resolution:**
  - Scale player visual radius to ~20px with multi-layer glowing corona (up to 40px glow).
  - Scale enemy visual to 28×20px with aggressive crimson silhouette and bold stun effects.
  - Scale shards to 28×20px with vibrant golden facets and floating bobbing.
  - Update collision shapes accordingly.

### Defect 4: Instant Death in ~1.0 Second (Zero Grace Period)
- **Observation:** Game enters CORE CRITICAL immediately after pressing START.
- **Root Cause:**
  - Initial enemy spawned on perimeter cell `(4, 0)` at only ~150px distance from player `(4.5, 4.5)`.
  - Enemy moved at 135px/s. With stationary player, collision occurred at t = 1.1s.
  - Zero grace period or spawn delay existed.
- **Resolution:**
  - Add a 2.5-second initial grace period upon run start.
  - Initial enemy spawns with 2.5s delay and guaranteed safe distance (minimum 320px).
  - Player has invulnerability shield during the grace period.

### Defect 5: Small Mobile HUD & Pulse Button
- **Observation:** Pulse button is small (110×110) in the corner; text is hard to read.
- **Root Cause:** Hardcoded small pixel dimensions without accounting for mobile thumb reach and high-DPI viewing distance.
- **Resolution:**
  - Enlarge Pulse button to 130×130 with high-contrast glowing states (READY vs COOLDOWN).
  - Add top safe-area padding for notch/camera punch-holes.
  - Increase typography sizes for Score (40pt), Timer (22pt), and Chaser count (20pt).

### Defect 6: Sparse Game-Over Screen
- **Observation:** Basic card with minimal hierarchy.
- **Root Cause:** Plain vertical stack with basic fonts and small buttons.
- **Resolution:**
  - Restructure Game-Over overlay with bold CORE CRITICAL warning title, glowing stats card (Final Score, Best Score, Survived Time), and large thumb-friendly PLAY AGAIN (260×64) and MAIN MENU buttons.

---

## 2. Implementation Plan

1. **Arena Redesign (`arena.gd`, `isometric_helper.gd`):** Scale tile dimensions, enhance neon grid lines, alternating tiles, glowing perimeter.
2. **Touch Input & UI Pass-Through (`main.tscn`, `main.gd`, `player.gd`):** Set `mouse_filter = IGNORE` on all non-interactive Controls. Refactor touch capture in `player.gd`.
3. **Entity Visuals & Physics Scale (`player_orb_renderer.gd`, `player.tscn`, `enemy_visual.gd`, `enemy.tscn`, `energy_shard_visual.gd`, `energy_shard.tscn`):** Enlarge visuals and collision shapes ~2× for crisp mobile visibility.
4. **Gameplay Tuning & Grace Period (`gameplay_manager.gd`, `player.gd`):** Add 2.5s grace period, invulnerability indicator, safe spawn distance, progressive wave timing.
5. **HUD & Game-Over Polish (`main.tscn`, `main.gd`):** Enlarge Pulse button, enhance typography, polish Game-Over hierarchy.
6. **Automated Verification:** Run Godot headless self-tests and test suite.
7. **Export & Deploy:** Build debug APK, verify signatures, install to connected Motorola edge 70.
