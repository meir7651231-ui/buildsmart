// DN-SCALE — fold the catalog-config diameter axis onto ONE nominal-DN ladder.
//
// The catalog measures bore three incompatible ways — inch (½"), DN (DN40), and
// plastic/PE outer-diameter in mm (20 · 110) — plus noisy `odOf` integers. The
// owner wants the קוטר wheel to speak a single DN scale, with the REAL trade
// sizes preserved (DN110 ≠ DN100 — a different pipe type & use), only genuine
// parse-noise absorbed into the nearest real size.
//
// PURE (no Flutter, no state). Consumed by the catalog-config card layer
// (`product_chips`/`config_card`), which is LIVE on the home — so this shapes the
// production diameter wheels. (kCatalogConfig now gates only the standalone
// route, not the home card.)

/// Inch (nominal-BORE) → DN — the threaded/imperial trade table: ½" IS DN15
/// (owner). Keys are the folded labels the size tokenizer emits: the standalone
/// eighth folds to ASCII (`⅜"`→`3/8"`) while a compound like `2⅜"` keeps the
/// glyph, so both spellings are listed.
const Map<String, int> kInchToDn = <String, int>{
  '¼"': 8, '⅜"': 10, '3/8"': 10, '½"': 15, '¾"': 20, '1"': 25,
  '1¼"': 32, '1½"': 40, '2"': 50, '2⅜"': 50, '2½"': 65, '3"': 80,
  '4"': 100, '5"': 125, '6"': 150, '8"': 200, '10"': 250, '12"': 300,
};

/// The real trade sizes a number snaps to — the UNION of the plastic/PE
/// outer-diameter ladder (…63 · 75 · 90 · 110 · 160…) AND the ISO nominal-BORE
/// values the inch table also emits (65 · 80 · 100 · 150 · 300). Both conventions
/// coexist so each real size keeps its own step: a DN80 flange valve and a DN90
/// plastic pipe are distinct (the size names the pipe type & use), a legitimate
/// `DN80`/`DN100`/`DN150` stays itself (idempotent), and only parse-noise
/// (43 · 88 · 108 …) absorbs into the nearest rung.
const List<int> kDnRungs = <int>[
  8, 10, 15, 16, 20, 25, 32, 40, 50, 63, 65, 75, 80, 90, 100, 110, 125,
  140, 150, 160, 180, 200, 225, 250, 280, 300, 315, 355, 400,
];

/// Snap an outer-diameter magnitude to the nearest [kDnRungs] step.
int snapOdToDn(num od) {
  var best = kDnRungs.first;
  var bestDist = (od - best).abs();
  for (final rung in kDnRungs) {
    final dist = (od - rung).abs();
    if (dist < bestDist) {
      bestDist = dist;
      best = rung;
    }
  }
  return best;
}

final RegExp _kFirstNum = RegExp(r'(\d+(?:\.\d+)?)');

/// A raw diameter token — inch (`½"`), DN (`DN40`), plastic OD (`20`/`110`), mm
/// (`250 מ"מ`), or a bare `odOf` integer — to its canonical `DN<n>` on the one
/// ladder. Inch uses the bore table; every other number is treated as an OD and
/// snaps to the nearest real rung. An unparseable token passes through unchanged
/// (never blanks a wheel). Idempotent: `canonicalDn('DN40') == 'DN40'`.
String canonicalDn(String token) {
  final t = token.trim();
  final inch = kInchToDn[t];
  if (inch != null) return 'DN$inch';
  final m = _kFirstNum.firstMatch(t);
  if (m == null) return t;
  final n = num.tryParse(m.group(1)!);
  if (n == null) return t;
  return 'DN${snapOdToDn(n)}';
}

/// The integer of a `DN<n>` label, for ascending wheel sort (so DN15 precedes
/// DN110, not the lexical reverse). A non-DN label sorts last, deterministically.
int dnNumber(String label) {
  final m = _kFirstNum.firstMatch(label);
  if (m == null) return 1 << 30;
  return int.tryParse(m.group(1)!.split('.').first) ?? (1 << 30);
}
