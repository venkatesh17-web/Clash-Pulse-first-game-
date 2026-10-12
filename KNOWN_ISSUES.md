# PULSE CLASH — KNOWN ISSUES & LIMITATIONS

## Current Status (Offline MVP & Android Debug APK Complete)

1. **Physical Android Touch Device Testing:**
   - **Current State:** The debug APK (`D:\Game\build\pulse_clash.apk`) is built, signed, and verified.
   - **Pending Action:** No physical Android device was connected via USB/ADB at build time (`adb devices: none attached`).
   - **Next Action:** When a physical device is connected with USB Debugging enabled, the APK can be installed via `adb install -r D:\Game\build\pulse_clash.apk` to validate multi-touch responsiveness, hardware vibration, and framerate stability on real hardware.
2. **Multiplayer Online Servers:**
   - Offline MVP is complete and independent of network connections.
   - Multiplayer architecture is fully documented in `MULTIPLAYER_DESIGN.md`. Online peer-to-peer or server hosting is deferred to future online phases to maintain the ₹0 budget.

