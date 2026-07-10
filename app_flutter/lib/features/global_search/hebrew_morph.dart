// Light Hebrew morphology for the product finder. Plumbers type the way they
// speak — "ברזים", "צינורות", "מצמדים" (plurals) — but the catalog names the
// product in the singular ("ברז", "צינור", "מצמד"). Without help a plural query
// finds NOTHING. This turns the query's head word back into its singular so the
// literal search still lands.
//
// RESCUE-ONLY by contract: the caller tries these variants ONLY after the literal
// query has already returned zero results, so an over-eager singular can never
// bury or reorder a real match — the worst case is that a variant also finds
// nothing. That safety is why this can stay deliberately simple (just the two
// productive plural suffixes + final-letter restoration) instead of a full
// morphological analyser. Pure + deterministic → directly unit-testable.

/// Non-final Hebrew letter → its word-FINAL form. Stripping a plural suffix
/// exposes a letter that must take its final shape to match the singular in the
/// catalog ("אטמים" → strip "ים" → "אטמ" → restore → "אטם").
const Map<String, String> _finalForm = {
  'כ': 'ך',
  'מ': 'ם',
  'נ': 'ן',
  'פ': 'ף',
  'צ': 'ץ',
};

String _restoreFinal(String w) {
  if (w.isEmpty) return w;
  final last = w[w.length - 1];
  final f = _finalForm[last];
  return f == null ? w : '${w.substring(0, w.length - 1)}$f';
}

final RegExp _ws = RegExp(r'\s+');

/// The fully-singular variant of [query] — EVERY plural word folded to its
/// singular (the noun can sit anywhere: "ברזים 16" or "16 ברזים" or "צינורות
/// פקסגול"). Returns an empty list when nothing productive applies (already
/// singular, too short, blank) so the caller cleanly skips the rescue. Sizes and
/// non-plural words pass through untouched. Deterministic; never returns [query]
/// itself.
List<String> hebrewSearchVariants(String query) {
  final q = query.trim();
  if (q.isEmpty) return const [];
  var changed = false;
  final singular = <String>[];
  for (final w in q.split(_ws)) {
    // The two productive masculine/feminine plural suffixes. Guard on length so a
    // short word like "מים" (water — length 3) is never gutted to a stub.
    if (w.length >= 4 && (w.endsWith('ים') || w.endsWith('ות'))) {
      final s = _restoreFinal(w.substring(0, w.length - 2));
      if (s.length >= 2 && s != w) {
        singular.add(s);
        changed = true;
        continue;
      }
    }
    singular.add(w);
  }
  if (!changed) return const [];
  final v = singular.join(' ');
  return v == q ? const [] : [v];
}
