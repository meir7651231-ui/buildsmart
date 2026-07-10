// ~120 verified field-slang entries (owner-contributed, 10/7).
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
  'רדוקטור': ['מעבר', 'מצמצם', 'מקטין'],
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
  // ── field slang contributed by the owner (a working plumber), each VERIFIED
  //    against the live catalog: the key finds ~0 products today (so the rescue
  //    fires and isn't already covered) and every target below is a real catalog
  //    word. Terms the owner offered that already hit (קו, שרשור, צוואר, מסנן,
  //    כיסוי, מכל, קונוס, כניסה, גלי) or were too generic (קופסת, סיט) were dropped.
  'צינורית': ['צינור'],
  'קוברה': ['צינור'],
  'אוכף': ['רוכב'],
  'טאפ': ['פקק'],
  'טאפא': ['פקק'],
  'קאפ': ['מכסה', 'פקק', 'כפה'],
  'קולר': ['צווארון', 'מתלה'],
  'פלאנג': ['אוגן'],
  'פילטר': ['רשת', 'מסנן'],
  'סקרין': ['רשת'],
  'תושבת': ['מושב'],
  'שרול': ['שרוול', 'מאריך'],
  'סליב': ['שרוול'],
  'הארכה': ['מאריך'],
  'אקסטנשן': ['מאריך', 'הגבהה'],
  'גריקן': ['מיכל'],
  'טנק': ['מיכל'],
  'קופלונג': ['מקשר', 'מצמד'],
  'שלייף': ['אומגה', 'חבק', 'מתלה'],
  'תפס': ['חבק', 'אומגה'],
  'דיזה': ['מצרה'],
  'חונק': ['מצרה'],
  'רסטריקטור': ['מצרה'],
  'מנקז': ['מאסף'],
  'וידיה': ['מקדח'],
  'אינלט': ['מבוא'],
  'מניפולד': ['מסעף', 'מחלק'],
  'חנוכייה': ['מחלק', 'מסעף'],
  'אוברפלואו': ['אביק'],
  'פופאפ': ['אביק'],
  'פלוטר': ['מצוף'],
  'קלמזי': ['מצוף'],
  'בוקסה': ['תותב', 'בושינג'],
  'מצרף': ['מחבר', 'מופה'],
  'מושפה': ['מופה'],
  'גבקה': ['מפתח'],
  'סטילסון': ['מפתח'],
  'תוכי': ['חותך'],
  'קרטוש': ['מנגנון'],
  'קרטרידג': ['מנגנון'],
  'פרלטור': ['פיה', 'מעדן'],
  'קולטן': ['קולט'],
  'דריין': ['ניקוז'],
  'מנומטר': ['שעון'],
  'ספרטור': ['משחרר'],
  'קיט': ['ערכה'],
  // ── owner field-slang, batch 2 (verified). Tool/consumable terms this catalog
  //    doesn't stock (טפלון, סיליקון, סיקא, פומפה, ונטוזה, שיער) were DROPPED — no
  //    product to point at, אין המצאות. Terms that already hit (מפצל, בנד, סוללה,
  //    ספירלה, קונוס) or are too generic (מוליך=conductor, כרטיס=card) were skipped.
  'קלנבו': ['זווית', 'ברך'], // old distortion of Elbow
  'קנט': ['זווית', 'ברך'],
  'תה': ['הסתעפות'], // "tee"
  'טיפי': ['הסתעפות'], // T-piece
  'שיבר': ['ברז'], // Schieber — gate/main valve
  'מיקסר': ['ברז', 'סוללה'],
  'סייפטי': ['משחרר', 'שסתום'], // safety / pressure-relief
  'קלינגרית': ['אטם'],
  'אורינג': ['אטם', 'טבעת'], // O-ring
  'פשתן': ['אטם'], // sealing flax
  'מרזב': ['קולט'],
  'שפופרת': ['מזלף'], // shower handset
  'מקלחון': ['מזלף'],
  'גיברית': ['צינור'], // Geberit → black drainage pipe
  'גיבריט': ['צינור'],
  'חסכם': ['פיה'], // water-saver aerator
  'כוסית': ['רוזטה'],
  'מנהול': ['תא'], // manhole → chamber
  'קופסת': ['מחסום'], // inspection box → floor trap
  'סטאב': ['צווארון'], // stub end
  // ── owner field-slang, batch 3 (the last uncovered types). שרשורי dropped — it
  //    already finds סיפון on its own; זרוע/אקדח keep their own name (their field
  //    terms were all multi-word). ──
  'פנל': ['משפך'], // funnel
  'לוחץ': ['ונטיל'], // sink drain outlet
  'קולקטור': ['מסעף', 'מחלק', 'סעפת'], // collector / manifold
  'חנוכיית': ['מחלק', 'מסעף'], // water-meter manifold
  'פטרייה': ['כובע'], // roof vent cap
  'ווסת': ['מקטין'], // pressure regulator
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
  'cap': ['מכסה', 'פקק'],
  'seat': ['מושב'],
  'sleeve': ['שרוול'],
  'tank': ['מיכל'],
  'collar': ['צווארון'],
  'filter': ['רשת'],
  'screen': ['רשת'],
  'inlet': ['מבוא'],
  'overflow': ['אביק'],
  'drain': ['ניקוז'],
  'extension': ['מאריך'],
  'cartridge': ['מנגנון'],
  'aerator': ['פיה'],
  'floater': ['מצוף'],
  // ── owner glossary batch (מעודכן.xlsx): the slang + English aliases from the
  //    owner's technical|slang|English dictionary whose target has REAL products.
  //    Tool/sealant/adhesive rows (מפתח שוודי, טפלון, סיליקון, דבק) were dropped —
  //    no catalog product to point at (owner: "מה שאין מוצר לא צריך").
  'פולירול': ['PPR'],
  'טאפה': ['פקק'],
  'פעמון': ['מנגנון'], // niagara flush mechanism
  'float': ['מצוף'],
  'check': ['אל חוזר'],
  'flush': ['מנגנון'],
  'monobloc': ['אסלה'],
  'toilet': ['אסלה'],
  'trap': ['סיפון', 'מחסום'],
  'pipe': ['צינור'],
  'saddle': ['רוכב'],
  'plug': ['פקק'],
  'bushing': ['תותב', 'בושינג'],
};

/// Multi-word slang PHRASES — mostly the inch-size colloquialisms a plumber
/// speaks ("חצי צול", "צול וחצי", "4 צול") → the token the catalog actually uses
/// (½" is written "1/2", 1½" is "1 1/2", 4" is "DN110"). [slangVariants] swaps the
/// phrase as a substring, so "ברז חצי צול" → "ברז 1/2". Every target below was
/// verified to match real products.
const Map<String, List<String>> kPlumberSlangPhrases = <String, List<String>>{
  'חצי צול': ['1/2'],
  'שלושת רבעי צול': ['3/4'],
  '3/4 צול': ['3/4'],
  'צול ורבע': ['1 1/4', '32'],
  'צול וחצי': ['1 1/2', 'DN40'],
  '2 צול': ['2"', 'DN50'],
  'שני צול': ['2"', 'DN50'],
  '4 צול': ['DN110', '110'],
  'ארבעה צול': ['DN110', '110'],
  '6 צול': ['DN160', '160'],
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
  final out = <String>[];
  // (1) Multi-word inch-size phrases: swap the whole colloquialism as a substring
  // ("ברז חצי צול" → "ברז 1/2"), so the size finds the catalog's real notation.
  // Keys are Hebrew (case-free), so a plain contains/replace preserves the rest of
  // the query and the target's own casing (DN40).
  kPlumberSlangPhrases.forEach((phrase, targets) {
    if (q.contains(phrase)) {
      for (final t in targets) {
        out.add(q.replaceAll(phrase, t));
      }
    }
  });
  // (2) Per-token single-word slang: swap one slang token for its canonical.
  final words = q.split(_ws);
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
