// synonym_bridge.dart — query-time alias folding for the unified finder's text +
// voice input (P4 step 54). kQuerySynonyms maps a typed/spoken alias to its
// canonical token (a kMaterials key, a colour/finish, or an everyday noun like
// מרפק→ברך). normalizeQuery folds them: LATIN aliases via an ASCII word-boundary
// regex (so 'PP' never fires inside 'PPR'), HEBREW aliases by WHOLE-TOKEN equality
// (Dart \b is ASCII-only, so it can't bound a Hebrew word). PURE — no IO.

/// Latin aliases (ASCII keys) → canonical, matched with a `\b` word-boundary.
const Map<String, String> _kLatinQuerySynonyms = {
  'copper': 'נחושת',
  'brass': 'נחושת',
  'pex': 'פקס',
  'stainless': 'נירוסטה',
  'steel': 'פלדה',
  'hdpe': 'HDPE',
  'pe': 'HDPE',
  'ppr': 'PPR',
  'multilayer': 'רב-שכבתי',
};

/// Hebrew aliases (non-ASCII keys) → canonical, matched by WHOLE-TOKEN equality.
const Map<String, String> _kHebrewQuerySynonyms = {
  'פליז': 'נחושת',
  'פוליאתילן': 'HDPE',
  'פקסגול': 'פקס',
  'מרפק': 'ברך',
};

/// Every query alias → its canonical token. The canonical VALUES cover the
/// distinct kMaterials keys, so a material query can route to productsOfMaterial.
const Map<String, String> kQuerySynonyms = {
  ..._kLatinQuerySynonyms,
  ..._kHebrewQuerySynonyms,
};

/// Folds the aliases in [raw] to their canonical tokens — Latin via a `\b` regex,
/// Hebrew via whole-token equality. Pure & idempotent.
String normalizeQuery(String raw) {
  var s = raw;
  for (final e in _kLatinQuerySynonyms.entries) {
    s = s.replaceAll(RegExp('\\b${e.key}\\b', caseSensitive: false), e.value);
  }
  final tokens = s
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty)
      .map((t) => _kHebrewQuerySynonyms[t] ?? t)
      .toList();
  return tokens.join(' ');
}
