// Studio Pillar-3 · step 95 — the SINGLE source of truth for the intel
// stuck / abandon / dead-end DETECTOR thresholds.
//
// Every threshold the pure detectors in `funnels.dart` test against is declared
// HERE and ONLY here (§2/§4: NO magic numbers scattered through the detector
// code). Each constant is named + documented, so tuning is a one-line edit in
// one place, and `test/intel/funnels_test.dart` references these exact consts —
// proving the thresholds are SOURCED from this file, never hard-coded inside the
// detectors (§5 anti-magic-number check).
//
// §6 (forward-looking): a later Pillar-1 Studio-config layer can OVERRIDE these
// at runtime by passing explicit arguments to the detectors; these consts are
// the deterministic DEFAULTS and keep the tests reproducible.
//
// PURE DATA. No Firebase, no widgets, no providers, and NO wall-clock read —
// the current time is INJECTED into the detectors, never read here (§4). Dormant
// until step 98 wires the manager dashboard.

/// Idle horizon after which a session that emitted a `checkout_start` but no
/// `order_placed` is DERIVED as an abandoned checkout. Compared against an
/// INJECTED `now` (never the wall clock), so the signal is deterministic and a
/// flaky client cannot fake — or suppress — it. 180 s = 3 minutes of silence.
const Duration kIdleEnd = Duration(seconds: 180);

/// Minimum number of `search_no_result` events in one session that flags a user
/// as stuck searching (repeated-no-result). Inclusive — the detector fires on
/// `>=` this count.
const int kRepeatNoResult = 3;

/// Minimum number of two-screen back-and-forth returns (an A → B → A ping-pong,
/// counted per return) in one session that flags a dead-end navigation loop.
/// Inclusive — the detector fires on `>=` this count.
const int kBackLoop = 4;

// ── Pillar-3 STUDIO · step 97 — presence heartbeat cadence + TTL ─────────────

/// Presence heartbeat CADENCE: while a customer session is live AND the presence
/// gate holds, the tracker re-writes `presence/{actorKey}` once per [kHeartbeat].
/// A peer is judged LIVE only while `now - lastBeat < kHeartbeat * 2.5`
/// (`presenceLive`, presence.dart) — a 2.5× freshness tolerance so a SINGLE
/// dropped beat does not flip a live tab to "offline". 30 s balances promptness
/// against write cost. INJECTED into the tracker/liveness, never read as a wall
/// clock here (the deterministic-default discipline of this file).
const Duration kHeartbeat = Duration(seconds: 30);

/// Presence-doc SELF-EXPIRY horizon — deliberately in MINUTES, NOT the 30–90-DAY
/// `events/` retention: presence is ephemeral "who is online NOW". Each heartbeat
/// re-stamps `expireAt = serverTs + kPresenceTtl`; if the app dies WITHOUT a clean
/// `session_end` delete, the Firestore-TTL sweep (Pillar 5) reaps the stale doc
/// within a few minutes so a crashed tab never lingers as falsely "online".
/// 3 min = 6× [kHeartbeat] (survives a handful of missed beats before TTL bites).
const Duration kPresenceTtl = Duration(minutes: 3);
