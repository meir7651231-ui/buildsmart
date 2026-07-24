// ─────────────────────────────────────────────────────────────────────────────
// APP_PROFILE — the single build-time profile define (stage-3.4,
// PLAN-buildsmart-clean-master · הפרדת מנוע↔דאטה).
//
// ONE define answers "which app is this build?":
//
//   flutter build web                                   → profile 'demo'
//   flutter build web --dart-define=APP_PROFILE=buildsmart
//   flutter build web --dart-define=APP_PROFILE=clean
//
// Each PROFILE-OWNED flag keeps its own `bool.fromEnvironment` declaration in
// place and merely gains `defaultValue: kProfile…` — so the THREE-LAYER
// precedence is the platform's own semantics, no runtime machinery:
//
//   1. an EXPLICIT --dart-define of the specific flag ALWAYS wins
//      (fromEnvironment: a present define beats defaultValue, including
//      `=false` over a profile-true default) — every existing workflow and
//      the owner's STUDIO_DART_DEFINES arming variable keep working unchanged;
//   2. otherwise the PROFILE default applies;
//   3. no profile (the define-less build and the whole test suite) ⇒ 'demo'
//      ⇒ every derived default equals today's literal — byte-identical.
//
// WHAT IS PROFILE-OWNED (13): the shipped-UX capability flags (word-finder,
// keyboard mirror/global, ring/plain/axis dives, global search, store
// comparison, smart-input, app-kb-only), the buildsmart-only Studio publish
// mirror, and the two company VALUE defines (catalog API base, image CDN
// base).
//
// WHAT IS DELIBERATELY NOT PROFILE-OWNED:
//   • the ARMING layer (USE_FIREBASE_BACKEND · UID_SCOPED_QUERIES ·
//     SERVER_CALLABLES · CLAUDE_AI · STUDIO_LIVE · STUDIO_CO_EDITOR ·
//     INTEL_LIVE · USER_SYSTEM · …) — the Studio-GA runbook stages those
//     flips one-by-one with per-flag rollback, and `studio_gating_test`
//     forbids baking them into workflows; a profile expanding to them would
//     bypass that governance.
//   • unshipped experiments (ENABLE_CARD_KEYBOARD · KB_BUTTONS_V2 ·
//     FINDER_FRONT · EMAIL_PASSWORD_AUTH) — "all capabilities" ≠ untested UX.
//   • launch dials (CATALOG_SOURCE · SERVER_CATALOG_ROLLOUT) and secret
//     values (APP_CHECK_RECAPTCHA_SITE_KEY).
//
// The pure mirror [profileDefaultsFor] exists ONLY for tests: it re-states
// each profile column at runtime so `app_profile_flags_test.dart` can pin
// mirror ↔ const consistency and the per-profile matrix without rebuilding.
// ─────────────────────────────────────────────────────────────────────────────

/// The active build profile: 'demo' (default) · 'buildsmart' · 'clean'.
const String kAppProfile =
    String.fromEnvironment('APP_PROFILE', defaultValue: 'demo');

const bool _bs = kAppProfile == 'buildsmart';
const bool _clean = kAppProfile == 'clean';

/// Guard for typos: an unknown profile string silently behaves as 'demo'
/// (every derived default below is the demo value) — the proof test asserts
/// this const so CI catches a misspelled profile early.
const bool kAppProfileKnown = kAppProfile == 'demo' || _bs || _clean;

// ── shipped-UX capability flags (buildsmart + clean ON · demo OFF) ───────────

const bool kProfileWordFinder = _bs || _clean;
const bool kProfileKbLiveMirror = _bs || _clean;
const bool kProfileKbGlobal = _bs || _clean;
const bool kProfileRingDive = _bs || _clean;
const bool kProfilePlainDive = _bs || _clean;
const bool kProfileAxisDive = _bs || _clean;
const bool kProfileGlobalSearch = _bs || _clean;
const bool kProfileStoreComparisonUi = _bs || _clean;
const bool kProfileSmartInput = _bs || _clean;
const bool kProfileAppKbOnly = _bs || _clean;

// ── buildsmart-only: the owner's published-Studio mirror ─────────────────────

const bool kProfileStudioSharedSync = _bs;

// ── company VALUE defines ────────────────────────────────────────────────────

/// Server catalog/config API base — buildsmart's Firebase host on the
/// buildsmart profile; empty (server catalog OFF, gate_123 load-bearing)
/// otherwise.
const String kProfileCatalogBaseUrl =
    _bs ? 'https://buildsmart-b0b78.firebaseapp.com' : '';

/// Image CDN base — the buildsmart R2 bucket for demo+buildsmart (today's
/// value, byte-identical); empty on clean (a generic app bundles its assets
/// until a company CDN is configured).
const String kProfileImageBaseUrl =
    _clean ? '' : 'https://pub-51f8c6ddf2de47e6b63e0f9588211cba.r2.dev';

// ── pure test mirror ─────────────────────────────────────────────────────────

/// The per-profile default matrix, re-stated at runtime for the proof test
/// (mirror ↔ const self-consistency + the documented workflow columns).
/// NOT consumed by app code — the consts above are the single source at
/// compile time.
Map<String, Object> profileDefaultsFor(String profile) {
  final bs = profile == 'buildsmart';
  final clean = profile == 'clean';
  final ux = bs || clean;
  return {
    'ENABLE_WORD_FINDER': ux,
    'KB_LIVE_MIRROR': ux,
    'KB_GLOBAL': ux,
    'ENABLE_RING_DIVE': ux,
    'PLAIN_DIVE': ux,
    'AXIS_DIVE': ux,
    'GLOBAL_SEARCH': ux,
    'STORE_COMPARISON_UI': ux,
    'SMART_INPUT': ux,
    'APP_KB_ONLY': ux,
    'STUDIO_SHARED_SYNC': bs,
    'CATALOG_BASE_URL': bs ? 'https://buildsmart-b0b78.firebaseapp.com' : '',
    'IMAGE_BASE_URL':
        clean ? '' : 'https://pub-51f8c6ddf2de47e6b63e0f9588211cba.r2.dev',
  };
}
