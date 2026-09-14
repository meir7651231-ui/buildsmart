// ⚛️ אטום-Dart (דרגת-חוזה) · elementShown
// מוצא: buildsmart/app_flutter/lib/config/org_config.dart:220 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// טיפוסים מוטבעים (חוק-1, verbatim מהמקור): OrgConfig.
// ייעוד-עברי (G63 · מקור: מונחי-מסך-הקורא screens__org_setup_wizard_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): מתוך · רכיבים · פעילים · סקציות · אבחון · סנכרון · למה · לא · מגיע · לאחרים · אדום · אזהרה

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
    this.accessPasswordHash = '',
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

  /// SHA-256 hash of the owner-set access password ('' = no lock). NEVER the
  /// literal password (config/access_lock.dart hashes it before it is stored,
  /// since this rides the public-read org-config doc). Enforced by
  /// [AccessLockGate] when [kAccessLock] is armed.
  final String accessPasswordHash;
}

/// Is the Studio element [id] SHOWN under [c]? The setup-wizard's per-element
/// show/hide axis — it recycles the element_registry as the toggle source.
/// Stored in [features] under an `element.<id>` key so it rides the EXISTING
/// codec + wizard/pack carry-through with ZERO schema change; ABSENT = visible
/// (byte-identical), only an explicit `false` hides. The kImmutable core-lock
/// (nav / mandatory screens can never be hidden) is enforced one layer up in
/// the gate [elementVisible], which has the Riverpod registry the pure model
/// here must not import.
bool elementShown(OrgConfig c, String id) => c.features['element.$id'] != false;
