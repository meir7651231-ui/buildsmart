// The embedded manifest const must stay byte-identical to
// atom-engine/manifests/contractor-home.json (parity test enforces it), so its
// formatting (no leading newline, raw string) is deliberate and not lint-shaped.
// ignore_for_file: leading_newlines_in_multiline_strings, unnecessary_raw_strings, sort_constructors_first, prefer_constructors_over_static_methods
import 'dart:convert';

/// One atom slot in a screen manifest: a stable [id], the atom [type] the
/// resolver knows how to build, a [when] visibility-predicate key the
/// controller evaluates against live state, and layout flags.
class AtomSpec {
  const AtomSpec({
    required this.id,
    required this.type,
    required this.when,
    this.expanded = false,
  });

  final String id;
  final String type;
  final String when;
  final bool expanded;

  factory AtomSpec.fromJson(Map<String, dynamic> json) => AtomSpec(
        id: json['id'] as String,
        type: json['type'] as String,
        when: json['when'] as String,
        expanded: json['expanded'] as bool? ?? false,
      );
}

/// The parsed, typed form of a screen manifest.
class AtomSchema {
  const AtomSchema({
    required this.screen,
    required this.root,
    required this.atoms,
  });

  final String screen;
  final String root;
  final List<AtomSpec> atoms;

  factory AtomSchema.fromJson(Map<String, dynamic> json) => AtomSchema(
        screen: json['screen'] as String,
        root: json['root'] as String? ?? '',
        atoms: (json['atoms'] as List<dynamic>)
            .map((a) => AtomSpec.fromJson(a as Map<String, dynamic>))
            .toList(),
      );

  /// Parse a manifest JSON string.
  static AtomSchema parse(String manifestJson) =>
      AtomSchema.fromJson(jsonDecode(manifestJson) as Map<String, dynamic>);
}

/// Embedded, byte-identical copy of
/// `atom-engine/manifests/contractor-home.json`. Kept embedded (not loaded as
/// an async asset) so the engine renders synchronously with no blank first
/// frame — which would break pixel parity. `atom_home_parity_test.dart`
/// asserts this equals the file on disk, so the two can never drift.
const String kContractorHomeManifestJson = r'''{
  "screen": "contractor-home",
  "root": "finder",
  "version": 1,
  "description": "Contractor home = the product finder. 9 atoms + terminal results surface, assembled by the atom engine. See atom-engine/ENGINE-SPEC.md.",
  "atoms": [
    { "id": "type_grid",     "type": "type_grid",    "when": "landing", "expanded": true },
    { "id": "breadcrumb",    "type": "breadcrumb",   "when": "drilled" },
    { "id": "subtype_chips", "type": "chip_bar",     "when": "has_subs" },
    { "id": "narrow_chips",  "type": "chip_bar",     "when": "has_narrow" },
    { "id": "angle_chips",   "type": "chip_bar",     "when": "has_angles" },
    { "id": "letter_chips",  "type": "chip_bar",     "when": "has_letters" },
    { "id": "wall_chips",    "type": "chip_bar",     "when": "has_wall" },
    { "id": "result_count",  "type": "result_count", "when": "has_results" },
    { "id": "chip_tip",      "type": "chip_tip",     "when": "has_results_and_tip" },
    { "id": "results",       "type": "product_list", "when": "drilled", "expanded": true }
  ]
}
''';
