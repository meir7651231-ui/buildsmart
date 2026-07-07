// ─────────────────────────────────────────────────────────────────────────────
// consent_gate — Studio Pillar 3 · step 86. PURE, version-gated consent logic
// for the customer-intelligence forward. No widgets, no I/O, no Firebase calls
// at import time. DORMANT: the full forward gate ANDs [kIntelLive] (const-false
// in every demo/test build) with the live backend, so it is INERT until step
// 100 flips it — the local on-device ring buffer is the only always-on piece.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/legal_texts.dart' show kCurrentPolicyVersion;
import 'package:buildsmart/data/repositories/backend.dart'
    show kIntelLive, useFirebaseBackend;
import 'package:buildsmart/state/app_settings.dart' show AppSettings;

/// The version+consent pieces of the analytics-forward gate, decoupled from the
/// backend so it is DETERMINISTIC in tests: the user has opted [privAnalytics]
/// IN *and* their recorded consent is for the CURRENT policy version. A future
/// [kCurrentPolicyVersion] bump makes this false again until re-opt-in
/// (Amendment-13 de-facto consent reset).
bool analyticsConsentCurrent(AppSettings s) =>
    s.consentedPolicyVersion >= kCurrentPolicyVersion && s.privAnalytics;

/// True while the one-time consent modal should still be shown: the user has
/// not yet consented to the CURRENT policy version (a bump re-opens it). This is
/// INDEPENDENT of the [AppSettings.privAnalytics] toggle — the prompt is about
/// the current policy VERSION, not the current opt-in state.
bool needsConsentPrompt(AppSettings s) =>
    s.consentedPolicyVersion < kCurrentPolicyVersion;

/// The FULL analytics-forward gate — the single predicate step 100 flips the
/// live remote forward on. It ANDs the current-version consent with the live
/// backend ([useFirebaseBackend]) AND the [kIntelLive] master switch, so it is
/// const-false in every demo/test build (mirrors `useCatalogServerSearch`).
/// NO live consumer yet (step 100 wires the forward); defining it now keeps the
/// gate in ONE place. A version bump de-facto resets consent (Amendment-13).
bool analyticsForwardEnabled(AppSettings s) =>
    analyticsConsentCurrent(s) && useFirebaseBackend && kIntelLive;
