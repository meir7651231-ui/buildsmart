// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 4 — the master gate.
//
// [kStudioFlag] is the ONE compile-time switch that turns the whole No-Code Studio
// on. Default **false** — flipping it (`--dart-define=STUDIO=true`) is the only
// thing that changes behavior; OFF ⇒ answer-equivalent / zero-regression (and with
// no consumer yet, compiler-guaranteed inert). Clones the `backend.dart:12`
// `bool.fromEnvironment` invariant verbatim.
//
// [kStudioFlagName] is the RUNTIME flag-name handed to the owner-only no-rebuild
// flag-set (`feature_flags.dart` pattern, e.g. `kKbLiveMirrorFlag = 'kKbLiveMirror'`).
// Note the deliberate asymmetry: the COMPILE define is `STUDIO`; the RUNTIME flag
// name is `kStudio` — two different lookups, one master concept (trouble (א)).
// ─────────────────────────────────────────────────────────────────────────────

/// Master compile-time gate for the Studio. Default OFF. `--dart-define=STUDIO=true`.
const bool kStudioFlag = bool.fromEnvironment('STUDIO');

/// Runtime flag-name for the owner-only no-rebuild flag-set (staging without a build).
const String kStudioFlagName = 'kStudio';
