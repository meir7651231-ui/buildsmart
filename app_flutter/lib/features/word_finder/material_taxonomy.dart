// material_taxonomy.dart — canonicalMaterial: ONE material space across the
// lexicon (kMaterials) and the verified-spec strings (P1 step 43). Brass folds
// into copper; the stainless / steel / PEX / PE spellings each collapse to one
// bucket, so the material axis and the compat-material display never split one
// material across two names. ADDITIVE + PURE: kMaterials is untouched; an
// unknown string resolves to itself (never throws). The kMaterials keys are
// fixed points, so canonicalMaterial(materialOf(p)) never reclassifies a hit.

/// Synonyms / alloys / cross-language spellings folded to their canonical
/// material bucket. A string already canonical resolves to itself (absent here).
const Map<String, String> _kMaterialSynonyms = {
  'פליז': 'נחושת', 'brass': 'נחושת', 'copper': 'נחושת',
  'stainless': 'נירוסטה', 'stainless steel': 'נירוסטה', 'inox': 'נירוסטה',
  'steel': 'פלדה',
  'PEX': 'פקס', 'pex': 'פקס', 'פקסגול': 'פקס',
  'רב שכבתי': 'רב-שכבתי', 'multilayer': 'רב-שכבתי',
  'פוליאתילן': 'HDPE', 'PE': 'HDPE',
};

/// Folds [raw] to its canonical material bucket (brass to copper, stainless to
/// one bucket, PEX to one bucket). Pure and idempotent; an unknown string
/// returns itself (never throws), so any verified-spec material value resolves.
String canonicalMaterial(String raw) {
  final r = raw.trim();
  return _kMaterialSynonyms[r] ?? r;
}
