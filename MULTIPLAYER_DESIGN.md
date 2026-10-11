# PULSE CLASH — MULTIPLAYER ARCHITECTURE & TECHNICAL DESIGN

**Status:** Technical Specification & Feasibility Study (Milestone 011)  
**Author:** Lead Developer  
**Game:** PULSE CLASH (Godot 4.3 GDScript)  

---

## 1. Executive Summary

PULSE CLASH is currently an offline-first arcade survival game. This document outlines the technical path for expanding into competitive / cooperative multiplayer while adhering to the **₹0 development budget** and avoiding recurring server infrastructure costs.

---

## 2. Match Structure & Player Limits

- **Target Match Size:** 2 to 4 players per match (maximum 4 players to maintain visual clarity on the 9×9 isometric arena).
- **Game Modes:**
  1. **Dual Survival (Co-op):** Players share the arena, collect from a shared shard pool, and use synchronized Pulses to rescue each other from scaling pursuer waves.
  2. **Pulse Clash (Versus):** Collecting shards charges a player's Pulse. Activating a Pulse stuns opponent players for 1.0 second and redirects pursuer aggro toward opponents. Last orb standing wins.
- **Match Duration:** 2 to 4 minutes per round.

---

## 3. Network Architecture & Synchronization

### A. Topology Options:
1. **Peer-to-Peer via WebRTC / ENet (Recommended for ₹0 budget):**
   * One player's device acts as the Authoritative Host using Godot's built-in `ENetMultiplayerPeer` (for local Wi-Fi / LAN) or `WebRTCMultiplayerPeer` (for internet play).
   * **Cost:** ₹0. No dedicated game server required.
   * **Limitation:** Internet play requires a free STUN server (e.g., Google's public STUN `stun:stun.l.google.com:19302`) and a lightweight signaling channel (e.g., free Firebase Realtime Database or WebSocket relay).
2. **Dedicated Headless Server (Future Commercial Option):**
   * Running `godot --headless` on a cloud VPS (AWS Lightsail, Hetzner, DigitalOcean).
   * **Cost:** ~$4–$6/month. Not recommended during initial zero-budget phase.

### B. State Synchronization & Authority:
- **Host Authority:**
  - Shard spawn locations and collection validation.
  - Enemy pursuit AI targeting and wave spawn timers.
  - Pulse shockwave radius hits and stun timers.
- **Client Prediction & Interpolation:**
  - Local player inputs move immediately on the client (zero input lag).
  - Client sends target position to host via RPC (`@rpc("any_peer", "call_remote", "unreliable")`).
  - Remote players and enemies are smoothed via linear interpolation (`lerp`) over 50ms snapshots.

---

## 4. Disconnection & Latency Handling

- **Snapshot Rate:** 20 Hz tick rate (lightweight on mobile data and CPU).
- **Grace Period:** 5.0 seconds reconnection window before an inactive player's orb fades and forfeits.
- **Host Migration:** If the host disconnects in a LAN match, the player with the lowest ping takes over state authority.

---

## 5. Security & Anti-Cheat

- Clients never report "I collected a shard" or "I destroyed an enemy".
- Clients only submit movement inputs / destination vectors and "Activate Pulse" requests.
- The host validates:
  1. Movement speed does not exceed `max_speed * delta * 1.15`.
  2. Pulse activation occurs only if cooldown has elapsed.
  3. Shard pickup occurs only when player position is within collision radius.

---

## 6. Implementation Milestones for Multiplayer

1. **Phase 1 (LAN / Local Wi-Fi):**
   * Implement Godot 4 `ENetMultiplayerPeer` lobby on local subnet.
   * Host discovers peers via UDP broadcast (`PacketPeerUDP`).
2. **Phase 2 (Signaling & NAT Traversal):**
   * Hook WebRTC peer connection using free public STUN servers.
3. **Phase 3 (Global Leaderboards):**
   * Free-tier Supabase or Firebase Auth/Postgres for verified global high-score tables.
