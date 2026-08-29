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
const bool _c2 = kAppProfile == 'company2';

/// Shipped-UX capabilities are ON for every non-demo profile (stage-5: the
/// second-company proof rides the same capability set as clean).
const bool _ux = _bs || _clean || _c2;

/// Guard for typos: an unknown profile string silently behaves as 'demo'
/// (every derived default below is the demo value) — the proof test asserts
/// this const so CI catches a misspelled profile early.
const bool kAppProfileKnown =
    kAppProfile == 'demo' || _bs || _clean || _c2;

// ── shipped-UX capability flags (buildsmart + clean ON · demo OFF) ───────────

const bool kProfileWordFinder = _ux;
const bool kProfileKbLiveMirror = _ux;
const bool kProfileKbGlobal = _ux;
const bool kProfileRingDive = _ux;
const bool kProfilePlainDive = _ux;
const bool kProfileAxisDive = _ux;
const bool kProfileGlobalSearch = _ux;
const bool kProfileStoreComparisonUi = _ux;
const bool kProfileSmartInput = _ux;
const bool kProfileAppKbOnly = _ux;

// ── buildsmart-only: the owner's published-Studio mirror ─────────────────────

const bool kProfileStudioSharedSync = _bs;

// ── company VALUE defines ────────────────────────────────────────────────────

/// Server catalog/config API base — buildsmart's Firebase host on the
/// buildsmart profile; empty (server catalog OFF, gate_123 load-bearing)
/// otherwise.
const String kProfileCatalogBaseUrl =
    _bs ? 'https://buildsmart-il.com' : '';

/// Image CDN base — the buildsmart R2 bucket for demo+buildsmart, served via
/// the approved custom domain (12.8: filtered-network fix — kosher filters
/// block the shared `pub-…r2.dev` host; `cdn.buildsmart-il.com` is a
/// subdomain of the already-approved business domain). Same bucket, same
/// keys — only the public hostname changed. Empty on clean (a generic app
/// bundles its assets until a company CDN is configured).
const String kProfileImageBaseUrl =
    (_clean || _c2) ? '' : 'https://cdn.buildsmart-il.com';

// ── content gates (owner directive 2026-07-25 · empty-shell clean) ───────────

/// clean ships NO product catalog — an empty shell; company2/BuildMax KEEPS
/// one (the own-catalog proof, riding CATALOG_SOURCE=v2 in the two-links
/// workflow); demo+buildsmart keep today's catalog byte-identical. A derived
/// const, NOT a dart-define — no `fromEnvironment`, so the closed-set flag
/// sweep is untouched.
const bool kProfileEmptyCatalog = _clean;

/// Raw shell: clean ships NO BuildSmart content CHROME (trade picker,
/// departments taxonomy, teasers, marketing copy) — engine chrome only;
/// company2/BuildMax stays FALSE (it ships the plumbing catalog as the
/// own-catalog proof); demo+buildsmart keep today's chrome byte-identical.
const bool kProfileRawShell = _clean;

/// clean + company2 ship NO demo record seeds (orders · tasks · rewards ·
/// site · chat · notifications) — a company's app starts life empty and fills
/// through real use; demo+buildsmart keep today's seeds byte-identical.
const bool kProfileEmptySeeds = _clean || _c2;

// ── pure test mirror ─────────────────────────────────────────────────────────

/// The per-profile default matrix, re-stated at runtime for the proof test
/// (mirror ↔ const self-consistency + the documented workflow columns).
/// NOT consumed by app code — the consts above are the single source at
/// compile time.
Map<String, Object> profileDefaultsFor(String profile) {
  final bs = profile == 'buildsmart';
  final clean = profile == 'clean';
  final c2 = profile == 'company2';
  final ux = bs || clean || c2;
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
    'CATALOG_BASE_URL': bs ? 'https://buildsmart-il.com' : '',
    'IMAGE_BASE_URL': (clean || c2) ? '' : 'https://cdn.buildsmart-il.com',
  };
}

/// Pure mirrors of the two content gates, re-stated per profile string for
/// the proof test. NOT consumed by app code — the consts above are the single
/// source at compile time.
bool catalogEmptyForProfile(String profile) => profile == 'clean';
bool seedsEmptyForProfile(String profile) =>
    profile == 'clean' || profile == 'company2';

/// Pure mirror of the raw-shell gate, re-stated per profile string for the
/// proof test. NOT consumed by app code — the consts above are the single
/// source at compile time.
bool rawShellForProfile(String profile) => profile == 'clean';
