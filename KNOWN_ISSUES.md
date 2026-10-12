# PULSE CLASH — KNOWN ISSUES & LIMITATIONS

## Current Status (Repaired Visuals & Mobile Gameplay Deployed)

1. **Physical On-Device Playtest Re-Validation:**
   - **Current State:** Repaired APK (`D:\Game\build\pulse_clash.apk`) is built, signed, installed, and launched on the owner's Motorola edge 70 (Android 16).
   - **Fixed in this Build:**
     - Touch drag pass-through unblocked by setting `mouse_filter = IGNORE` on non-interactive full-screen overlays.
     - Diamond arena scaled from 64×32 to 76×38 px with high-contrast checkerboard tiles and dual glowing neon perimeter.
     - 2.5-second initial grace period + invulnerability shield added to prevent immediate 1-second deaths.
     - Entities scaled ~2× for mobile viewing distance.
     - Pulse button enlarged to 130×130 with high-contrast thumb-friendly READY/COOLDOWN states.
   - **Next Action:** Founder manual playtest on the phone to experience the tactile feel of the drag controls and Pulse ability.
2. **Multiplayer Online Servers:**
   - Offline game loop is complete, robust, and completely independent of network connections.
   - Multiplayer architecture is fully documented in `MULTIPLAYER_DESIGN.md`. Online peer-to-peer or server hosting is deferred to future online phases to maintain the ₹0 budget.


