# PULSE CLASH — KNOWN ISSUES & LIMITATIONS

## Current Status (Offline MVP Delivered)

1. **Android Export Requirements Pending Founder Approval:**
   - **Current State:** Java JDK 17 is already installed on the Windows system.
   - **Missing Components:** Android Command-line Tools (`adb.exe`, Android SDK build-tools ~400MB) and the official Godot 4.3 Android Export Templates package (~1.2GB).
   - **Action Required:** Under the safety rules, downloading these large tools requires explicit founder authorization before proceeding with `.apk` generation.
2. **Physical Android Touch Device Validation:**
   - Touch drag, screen scaling, and portrait layout have been verified via Godot's touch emulation mode on Windows.
   - Real-world multi-touch responsiveness, frame consistency under mobile battery saver, and hardware vibration must be validated once exported to a physical device.
3. **Multiplayer Online Servers:**
   - Offline MVP is complete and independent of network connections.
   - Multiplayer architecture is fully documented in `MULTIPLAYER_DESIGN.md`. Online peer-to-peer or server hosting is deferred to future online phases to maintain the ₹0 budget.
