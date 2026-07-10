// The plumber's own words. A tradesman asks for an "אלבו", a "רקורד", a "בול" —
// slang and foreign loan-words the catalog never uses (it says ברך, מחבר, ברז
// כדורי). Without help those queries find NOTHING. This maps each such term to the
// REAL catalog word(s) so the search still lands.
//
// VERIFIED, not invented (אין המצאות): every entry below was checked against the
// live catalog — the KEY finds zero products literally (so a rescue actually
// fires), and each VALUE is a word that DOES appear in real product names
// (`test/features/global_search/_slang_verify_dump` produced the counts:
// מחבר 205 · ברך 182 · מצמד 183 · מעבר 28 · אוגן 22 · ניפל 12 · ברז כדורי 46 …).
// Terms whose only target was empty (וסת, פטם) or dangerously broad (שוחה→תא) were
// dropped rather than guessed.
//
// RESCUE-ONLY by contract: [slangVariants] is tried by the dive ONLY after the
// literal query returned zero results, so expanding an ambiguous word (בול, צק)
// can never override a working search — the raw query already found nothing.
// Pure + deterministic.

/// Slang / loan-word → the catalog's real word(s), most-canonical first. Keys are
/// lower-case (Latin loan-words are matched case-insensitively via the caller's
/// fold). Every value is present in `kCatalogProducts`.
const Map<String, List<String>> kPlumberSlang = {
  // elbows / bends
  'אלבו': ['ברך', 'זווית'],
  'אלבוב': ['ברך', 'זווית'],
  'מרפק': ['ברך', 'זווית'],
  // reducers / adapters
  'רדוקציה': ['מעבר', 'מצמצם'],
  'רדוקטור': ['מעבר', 'מצמצם'],
  'אדפטר': ['מתאם', 'מעבר'],
  // couplers / connectors
  'קפלר': ['מצמד', 'מחבר'],
  'פטמה': ['ניפל'],
  'באגה': ['תותב', 'מעבר'],
  // valves / taps
  'ואלף': ['ברז', 'שסתום'],
  'וולב': ['ברז', 'שסתום'],
  'מגוף': ['ברז', 'שסתום'],
  'בול': ['ברז כדורי'],
  'צק': ['אל חוזר'],
  // pipe / riser / drainage
  'זקף': ['זקיף'],
  'אינטרפוץ': ['סמוי', 'נסתר'],
  // fixtures / small parts
  'טוש': ['מזלף', 'דוש'],
  'גומיה': ['אטם', 'טבעת'],
  'אגוז': ['אום'],
  'קליפס': ['חבק'],
  'פלנץ': ['אוגן'],
  // material spellings
  'פיביסי': ['פלסטיק'],
  'רבשכבתי': ['רב שכבתי'],
  // Latin loan-words
  'coupling': ['מצמד', 'מחבר'],
  'elbow': ['ברך', 'זווית'],
  'tee': ['הסתעפות', 'טי'],
  'valve': ['ברז', 'שסתום'],
  'nipple': ['ניפל'],
  'reducer': ['מעבר', 'מצמצם'],
  'flange': ['אוגן'],
  'gasket': ['אטם'],
  'union': ['מחבר', 'מצמד'],
  'adapter': ['מתאם', 'מעבר'],
  'socket': ['מצמד', 'שקע'],
  'manifold': ['מסעף', 'מחלק'],
};

final RegExp _ws = RegExp(r'\s+');

/// Every query variant produced by swapping ONE slang token for a real catalog
/// word — one variant per (slang token × its canonical), other tokens untouched
/// ("אלבו 1/2" → "ברך 1/2", "זווית 1/2"). Empty when the query holds no slang.
/// The caller (dive rescue) unions the matches, so all the real synonyms surface
/// together. Latin loan-words match case-insensitively. Deterministic.
List<String> slangVariants(String query) {
  final q = query.trim();
  if (q.isEmpty) return const [];
  final words = q.split(_ws);
  final out = <String>[];
  for (var i = 0; i < words.length; i++) {
    final canons = kPlumberSlang[words[i].toLowerCase()];
    if (canons == null) continue;
    for (final c in canons) {
      final v = [...words]..[i] = c;
      out.add(v.join(' '));
    }
  }
  return out;
}
