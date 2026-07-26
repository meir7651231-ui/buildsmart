// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · ORG-CONFIG — the giant-system's RUNTIME-config layer OVER the
// compile-time profile (giant-system Phase 1 / verticals V1): Maor's config.ts
// logic — per-org modules · features · terms — re-expressed in Dart.
// APP_PROFILE answers "which BUILD is this?" at compile time; an [OrgConfig]
// answers "which ORG rides this build?" at runtime, with no rebuild.
//
// ZERO REGRESSION BY CONSTRUCTION: [kOrgConfigFlag] ships OFF (an ARMING-layer
// define — already classified in app_profile_flags_test's closed-set sweep;
// rollback = drop the define), and [kDefaultOrgConfig] is EMPTY under
// absent=on semantics — so flag-OFF + default = the live app byte-identical
// WITHOUT enumerating a single module/feature name that could drift. And NO
// live consumer exists in V1 by design (the trades_store.dart:10 precedent —
// "NOT consumed by any live screen yet ⇒ zero regression"); V2 adds the
// loader + the gates, V3 the surfaces.
//
// The loader channels: the OWNER's device prefs (key [kOrgConfigKey]) now;
// company/server config later through the RESERVED companyJson slot of
// [resolveOrgConfig] — the owner → company → default precedence is frozen
// today, so the server swap adds a CHANNEL, never a semantic.
//
// PURE Dart (dart:convert + nothing else — no Flutter, no I/O):
//   · [decodeOrgConfig] — the {"v":1,…} envelope, TOLERANT per stage-2
//     iron-rule-1 ("לא קורס לעולם"): null ONLY on structural corruption; a
//     wrong-typed FIELD drops to its empty default and a wrong-typed map
//     ENTRY is skipped — siblings survive either way; NEVER throws;
//   · [encodeOrgConfig] — empties OMITTED (the A4 omit-empty idiom, "omitted
//     when empty → byte-identical"), so the default encodes to the bare
//     envelope and encode→decode→encode is byte-stable;
//   · [moduleOn] · [featureOn] · [termOf] — the read API the V2 gates consume
//     (absent=on · only false=off · module-off cascades · core never off).
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert' show jsonDecode, jsonEncode;

/// The giant-system ARMING flag — `--dart-define=ORG_CONFIG=true` arms the V2
/// loader/gates; ships OFF, so today's builds carry zero behavior. Registered
/// in the arming layer of app_profile_flags_test (the closed-set sweep): a
/// profile never expands to it, per-flag rollback = drop the define.
const bool kOrgConfigFlag = bool.fromEnvironment('ORG_CONFIG');

/// The owner-prefs persistence key the V2 loader reads/writes (the
/// `bs.<domain>.v1` key family — trades_store's `bs.trades.v1`). Unused in
/// V1: reserving the name now is what keeps the V2 loader a pure addition.
const String kOrgConfigKey = 'bs.org-config.v1';

/// One org's runtime configuration. Immutable; every field DEFAULTS EMPTY, so
/// `const OrgConfig()` under the absent=on semantics IS the all-on live app —
/// byte-identity by construction, no name enumeration to drift.
class OrgConfig {
  const OrgConfig({
    this.slug = '',
    this.orgName = '',
    this.theme = const {},
    this.modules = const {},
    this.features = const {},
    this.terms = const {},
  });

  /// The org's stable machine handle ('' = the unbranded default build).
  final String slug;

  /// The org's display name ('' = unbranded — the compiled brand wording
  /// stands).
  final String orgName;

  /// Freeform theme overrides (colors, logo refs, …) — carried OPAQUE in V1
  /// (whatever JSON rode in); the V2 theme layer interprets it, this module
  /// never does.
  final Map<String, dynamic> theme;

  /// Module toggles by module id. ABSENT = ON; only an explicit false turns
  /// a module off ([kCoreModules] excepted) — see [moduleOn].
  final Map<String, bool> modules;

  /// Feature toggles by '<module>.<feature>' key. ABSENT = ON; only an
  /// explicit false turns a feature off; module-off cascades — see
  /// [featureOn].
  final Map<String, bool> features;

  /// Vocabulary overrides by term key (''/absent = the built-in wording) —
  /// see [termOf].
  final Map<String, String> terms;
}

/// The unbranded all-on default: EMPTY maps + absent=on ⇒ every module and
/// feature reads ON and every term falls back — byte-identity with the live
/// app by construction (no name enumeration). [resolveOrgConfig] returns THIS
/// object — `identical` — when no layer decodes.
const OrgConfig kDefaultOrgConfig = OrgConfig();

/// Modules the app is meaningless without: [moduleOn] reads these true NO
/// MATTER what a config says — a hostile/garbled config can dark a wing,
/// never the spine. The SET ITSELF (name · type · always-true semantics) is
/// the frozen V1 API; its CONTENTS are owner-tunable in V2 (today: the two
/// capabilities a supply app cannot lose). A core module's individual
/// features CAN still read false — see [featureOn].
const Set<String> kCoreModules = {'catalog', 'orders'};

/// Persistence codec — decode the `{"v":1,…}` envelope. TOLERANT (stage-2
/// iron-rule-1, "לא קורס לעולם"): null ONLY on STRUCTURAL corruption — not
/// JSON at all, not a map, wrong/missing version. Below the envelope the
/// tolerance is PER FIELD: a wrong-typed field (`"modules":"not-a-map"`)
/// drops to its empty default while its siblings survive, and inside a map a
/// wrong-typed ENTRY (a non-bool toggle, a non-string term) is skipped while
/// its sibling entries survive. NEVER throws.
OrgConfig? decodeOrgConfig(String raw) {
  final Object? root;
  try {
    root = jsonDecode(raw);
  } on Object {
    return null; // not JSON at all — structural corruption
  }
  if (root is! Map) return null;
  final version = root['v'];
  if (version is! num || version != 1) return null;
  return OrgConfig(
    slug: _stringField(root['slug']),
    orgName: _stringField(root['orgName']),
    theme: _jsonMapField(root['theme']),
    modules: _boolMapField(root['modules']),
    features: _boolMapField(root['features']),
    terms: _stringMapField(root['terms']),
  );
}

/// Persistence codec — encode. Compact `{"v":1,…}` JSON with every empty
/// field OMITTED (the A4 omit-empty idiom — "omitted when empty →
/// byte-identical"): the default encodes to the bare envelope `{"v":1}` and
/// encode→decode→encode is byte-stable.
String encodeOrgConfig(OrgConfig c) => jsonEncode(<String, dynamic>{
      'v': 1,
      if (c.slug.isNotEmpty) 'slug': c.slug,
      if (c.orgName.isNotEmpty) 'orgName': c.orgName,
      if (c.theme.isNotEmpty) 'theme': c.theme,
      if (c.modules.isNotEmpty) 'modules': c.modules,
      if (c.features.isNotEmpty) 'features': c.features,
      if (c.terms.isNotEmpty) 'terms': c.terms,
    });

/// The TOTAL layer resolver — never null, never throws. The OWNER layer
/// (device prefs, [kOrgConfigKey]) wins when it decodes; else the COMPANY
/// layer (the reserved server slot — nothing feeds it in V1); else
/// [kDefaultOrgConfig], the SAME object (`identical`). A corrupt layer is a
/// SKIPPED layer, not an error — and selection is per LAYER, whole: an owner
/// doc REPLACES the company doc, it never field-merges over it.
OrgConfig resolveOrgConfig({String? ownerJson, String? companyJson}) {
  if (ownerJson != null) {
    final owner = decodeOrgConfig(ownerJson);
    if (owner != null) return owner;
  }
  if (companyJson != null) {
    final company = decodeOrgConfig(companyJson);
    if (company != null) return company;
  }
  return kDefaultOrgConfig;
}

/// Is [module] on under [c]? ABSENT = ON — a config that never mentions a
/// module leaves it exactly as the live app ships it (the byte-identity
/// semantics); only an EXPLICIT false turns one off; and [kCoreModules] read
/// true ALWAYS.
bool moduleOn(OrgConfig c, String module) {
  if (kCoreModules.contains(module)) return true;
  return c.modules[module] != false;
}

/// Is [feature] of [module] on under [c]? Module-off CASCADES false — a
/// feature never leaks out of a dark module, not even an explicitly-true one;
/// otherwise `features['$module.$feature']` decides with absent=on, only
/// false=off. Core modules: the MODULE can't be off ([moduleOn]) but a
/// specific feature of it CAN still be false.
bool featureOn(OrgConfig c, String module, String feature) {
  if (!moduleOn(c, module)) return false;
  return c.features['$module.$feature'] != false;
}

// ── V3 term-key registry — the map is OPEN (any key rides the codec); these
// are the keys the app actually consults, so a wizard/pack knows what works:
//   brand.name · brand.club — the brand wordage (runtime label sites)
//   nav.home · nav.catalog · nav.updates · nav.store — the 4 bottom tabs
//   <any CfgText id> — site-level: every Studio-wrapped label terms by its
//     own id, UNDER a published Studio override and above the fallback
//   RESERVED (plan V3.2 — wired by V4 vertical packs): nav.customers ·
//   entity.customer · entity.order · entity.supplier
/// The org's wording for [key]: a non-empty `terms[key]` wins; anything else
/// returns the SAME [fallback] object — identity, not a copy (cheap AND
/// provable: `identical(termOf(c, k, fb), fb)` holds on the unbranded path).
String termOf(OrgConfig c, String key, String fallback) {
  final term = c.terms[key];
  return term == null || term.isEmpty ? fallback : term;
}

// ── internals ────────────────────────────────────────────────────────────────

/// A string field: a String rides, anything else drops to '' (per-field
/// tolerance — a garbled slug never costs its siblings).
String _stringField(Object? v) => v is String ? v : '';

/// A freeform map field (theme): string-keyed entries ride opaque; a
/// non-string KEY is skipped; not-a-map drops the whole field to empty.
Map<String, dynamic> _jsonMapField(Object? v) {
  if (v is! Map) return const {}; // wrong-typed FIELD — dropped, not fatal
  final out = <String, dynamic>{};
  for (final e in v.entries) {
    final k = e.key;
    if (k is String) out[k] = e.value;
  }
  return out;
}

/// A toggle map field (modules/features): only String→bool entries ride; a
/// wrong-typed ENTRY is skipped, its siblings survive (the per-item iron
/// rule, map edition); not-a-map drops the whole field to empty.
Map<String, bool> _boolMapField(Object? v) {
  if (v is! Map) return const {};
  final out = <String, bool>{};
  for (final e in v.entries) {
    final k = e.key;
    final val = e.value;
    if (k is String && val is bool) out[k] = val;
  }
  return out;
}

/// A vocabulary map field (terms): only String→String entries ride; the same
/// per-entry tolerance as [_boolMapField].
Map<String, String> _stringMapField(Object? v) {
  if (v is! Map) return const {};
  final out = <String, String>{};
  for (final e in v.entries) {
    final k = e.key;
    final val = e.value;
    if (k is String && val is String) out[k] = val;
  }
  return out;
}
