// External-card chip hierarchy (protocol §21). Classifies tokens from
// nameHe into a 5-level path: connection method → shape → feature →
// thread → size. The leading kind-noun (ברך/מסעף/מצמד/…) is the title;
// everything else falls into a level by vocabulary lookup. Words we
// haven't seen surface in the `leftover` field and fail the §14 test.

const Set<String> kChipTypes = {
  'ברך', 'מסעף', 'מצמד', 'מתאם', 'רוכב', 'ברז', 'צווארון', 'אוגן', 'פקק',
  'אומגה', 'שרוול', 'צינור', 'מחבר', 'סעפת', 'לוחית',
  // tool nouns — keep as standalone type
  'מזוודת', 'פלטת', 'מכונת', 'מברגה', 'תותב', 'מקדח',
  // Huliot SmartLock — drainage system types
  'סיפון', 'מחסום', 'מאסף', 'אום', 'אטם', 'משפך', 'אביק', 'רוזטה', 'מבוא',
  'מכלול', 'מצרה', 'חותך', 'מערכת', 'מצחיה', 'ונטיל', 'מפתח', 'חיבור',
  'מאריך', 'הגבהה', 'מכסה', 'רשת', 'סט', 'פס',
};

const Set<String> kChipLevel1Connection = {
  'לריתוך', 'ריתוך', 'הברגה',
  'ריתוך/הברגה', 'ריתוך/רקורד',
  // EF compound: when we see 'חשמלי' adjacent we promote to "ריתוך חשמלי"
  'חשמלי', 'אלקטרופיוזן',
};

const Set<String> kChipLevel2Shape = {
  // Angles carry the degree symbol in this catalog (45° / 90°). The bare
  // '45'/'90' are intentionally NOT here — those would collide with the
  // diameters 45mm/90mm and steal them from the size slot.
  '45°', '90°',
  // Huliot SmartLock — drainage angles. 15°/30° = single-side elbows; 87.5°
  // = telescopic elbow per the SmartLock catalog (pages 12, 15).
  '15°', '30°', '87.5°',
  'מצרה', 'שווה', 'סמוי', 'פרפר', 'כדורי',
  'מעבר', 'ישר', 'אלכסוני',
  'בין', 'אוגנים', // compound "בין אוגנים"
  'עגול', 'משושה', 'רקורד',
  'פייזר', 'אספקת', 'מים', // pipe sub-types: "אספקת מים", "פייזר"
  'מיזוג', 'אוויר',
  // Huliot SmartLock shape qualifiers
  'חלק', 'טלסקופית', 'גלילית', 'כפול', 'נפילה', 'קומקום',
  'זווית', 'ריבועי', 'מוגבה', 'קבוע', 'זמני', 'אמריקאי',
  'אוניברסלית',
};

const Set<String> kChipLevel3Feature = {
  'משטח', 'ריסון', // "משטח ריסון"
  'לנקודת', 'נקודת', 'למיקום',
  'ללא', 'ידית',
  'עם', 'מניעת', 'זרימה', 'חוזרת',
  'כולל', 'אטם',
  'ציפוי', 'כרום',
  'מתוברג', 'מפורק', 'מפלסטיק', 'פוליפרופילן',
  'קטנה', 'גדולה', 'קלה', 'שולחני',
  'לעבודה', 'בגובה', '(לעבודה', 'בגובה)',
  'לתיקון', 'חורים', 'לצינורות', 'לרוכבים', 'רוכב',
  'למונים', 'פיגורות', 'לקטרים',
  // ('מ"מ' moved to _kChipUnits — folded into the size chip, not a level-3 word)
  'סופי', 'גשר',
  'הולירומה', // sub-brand qualifier
  'מצופה', 'פלדה', // for "אוגן פלדה מצופה PP"
  'PP',
  // ─── Huliot SmartLock features (qualifiers, suffixes, contexts) ─────────
  // open/closed access
  'סגור', 'פתוח',
  // accessory targets ("ל…")
  'לג\'וקר', 'למחסום/מאסף', 'למאסף', 'למחסום', 'לכיור', 'לאמבט', 'למזגן',
  'למדיח', 'למכונת', 'לסיפון', 'לאגנית', 'לאביק', 'לברז', 'לסילוק',
  // installation contexts
  'מטבח', 'רחצה', 'כביסה', 'מדיח', 'כלים', 'מקלחת', 'אמבט',
  // joiner words / connectors
  'אורך', 'ארוך', 'קצר', 'קומפלט', 'משלימים', 'מדידה', 'יציאה', 'כניסה',
  'חיבור', 'אקוסטית',
  // catalog suffixes — model/series numbers + parens
  'מספר', 'דגם', 'מערכת',
  'AQUA', 'SLIM', 'SmartLock', 'Aqua', 'Slim',  // brand series identifiers
  'מתאם', 'ניקוז',  'הורקה', 'תקע', 'ראש',
  'ABS', 'TPE', 'SBR', 'PP+ABS',
  // parens (size variants from catalog headers like (6) (1) (3) (4) (5))
  '(1)', '(2)', '(3)', '(4)', '(5)', '(6)', '(8)', '(10)',
  '(70)', '(17)', '(שרשרת+10)', '(ללא',
  // colors / decorative
  'ירוק', 'שחור', 'אפור', 'בז\'', 'לבן', 'כחול', 'נירוסטה', 'ניירוסטה',
  'נילון', '66',
  'ניקל', 'פסים', 'ריבועים', 'מלא/אריח', 'משפך)',
  'אינטגרלי', '+',
  // shape feminine forms / Huliot stragglers
  'רבועה', 'כיור', 'זחיח', 'למבוא', 'קומפלקט',
  // Type words that already-took-the-leading-type may appear again as features
  // ('סט חיבור למדיח / מכונת כביסה' — type='סט', then 'מכונת' is a feature).
  'מכונת', 'מצרה', 'סיפון', 'מחסום', 'מבוא', 'משפך',
  // joiner/list words
  'שרשרת', 'פקקים', 'ושבלונה', 'לאום',
  '1¼', '1½', '½"',  // size variants seen as feature tokens
  'J', 'H', 'Top', 'Floor',
  // joker/SmartLock specific
  'ג\'וקר',
  // 2002 = bathtub drain model number
  '2002',
  // catalog row helpers (size pair label)
  'דלוחין',
  // ─── parser-aid vocab for Huliot ───────────────────────────────────────
  'צינורות', 'קוטר',  // 'חותך צינורות קוטר 40' (אורך already above)
  'מעביר', 'SL',  // 'אטם מעביר SL 40/32'
  'מברזל', 'למעבר',  // 'אום מעבר מברזל'
  'פתח', 'רבוע', 'לאריח',  // 'הגבהה פתח רבוע'
  'מוגבהת', 'עגולה',  // 'רשת מוגבהת עגולה'
  'אחד', '(צד', 'חלק)',  // '(צד אחד חלק)' tokenization with parens
  // SmartLock-specific contexts
  'נחושת',
};

const Set<String> kChipLevel4Thread = {
  'פ.פ', 'פ.ח', 'ח.ח', 'ח.פ',
  'פנימי', 'חיצוני', 'תבריג',
  'שקע', 'תקע',
  'פנים', 'חוץ', // alternates
};

// Material tokens — shown as image badge, not in chip path.
const Set<String> kChipMaterial = {'PPR', 'PPRCT', 'PP-RCT'};

// Unit tokens — folded INTO the size chip rather than dropped or shown as a
// standalone chip, so the size reads "20-63 מ"מ" and the full catalog name is
// recoverable from the chips alone (E2E §21.B).
const Set<String> _kChipUnits = {'מ"מ', 'מ”מ', 'mm'};

/// Returns chip components per the §21 hierarchy.
/// type: leading product noun (kChipTypes word).
/// level1..level5: ordered chip tokens (level5 = the size).
/// leftover: tokens the parser couldn't classify — should be empty.
class ChipPath {
  ChipPath({
    required this.type,
    required this.level1,
    required this.level2,
    required this.level3,
    required this.level4,
    required this.level5,
    required this.leftover,
  });
  final String? type;
  final List<String> level1;
  final List<String> level2;
  final List<String> level3;
  final List<String> level4;
  final String? level5;
  final List<String> leftover;

  List<String> get path =>
      [...level1, ...level2, ...level3, ...level4, if (level5 != null) level5!];

  /// §21.C — semantic level label for the chip at [pathIndex] in [path].
  /// Used by the UI to show "חיבור / צורה / תכונה / תבריג / מידה" above each
  /// chip and as the picker header, so the user knows what dimension they're
  /// picking instead of seeing a generic "בחר ערך" and identical-looking pills.
  /// Returns '' for an out-of-range index.
  String levelLabelOf(int pathIndex) {
    if (pathIndex < 0) return '';
    var i = pathIndex;
    if (i < level1.length) return 'חיבור';
    i -= level1.length;
    if (i < level2.length) return 'צורה';
    i -= level2.length;
    if (i < level3.length) return 'תכונה';
    i -= level3.length;
    if (i < level4.length) return 'תבריג';
    i -= level4.length;
    if (i == 0 && level5 != null) return 'מידה';
    return '';
  }
}

ChipPath parseChips(String nameHe) {
  // Tokenize, keep size-tokens intact (e.g. "25x½\"", "63x32", "20×2.8").
  final tokens = nameHe.split(RegExp(r'\s+'))
      .where((t) => t.trim().isNotEmpty)
      .where((t) => t != '-' && t != '—' && t != '/') // skip cosmetic seps
      .toList();
  String? type;
  final l1 = <String>[];
  final l2 = <String>[];
  final l3 = <String>[];
  final l4 = <String>[];
  String? l5;
  final leftover = <String>[];
  // Size tokens: usually start with a digit but RTL quoting can prefix
  // tokens like `"32x1` (the trailing quote got pulled to the start by bidi).
  final sizeRe = RegExp(r'^["”]?\d|^\d');

  // Multi-word compounds, longest first per level. Walked at every position
  // BEFORE single-token classification, so "לנקודת מים" gets one chip even
  // though "מים" alone would land in L2.
  List<List<String>> sortByLen(Set<String> src) =>
      (src.map((s) => s.split(' ')).toList())
        ..sort((a, b) => b.length.compareTo(a.length));
  final l1c = sortByLen(_l1Compounds);
  final l2c = sortByLen(_l2Compounds);
  final l3c = sortByLen(_l3Compounds);
  final l4c = sortByLen(_l4Compounds);

  int i = 0;
  while (i < tokens.length) {
    final raw = tokens[i];
    // Strip surrounding parens for vocabulary lookup ("(סיפון)" → "סיפון")
    // but keep the original text so the reconstruction stays verbatim.
    final t = (raw.startsWith('(') && raw.endsWith(')') && raw.length > 2)
        ? raw.substring(1, raw.length - 1)
        : raw;
    if (kChipMaterial.contains(t)) { i++; continue; }
    if (type == null && kChipTypes.contains(t)) { type = t; i++; continue; }
    // Size detection — but NOT for declared shape tokens that happen to start
    // with a digit (45° / 90°). Those are the elbow/tee ANGLE and belong in
    // level-2 (shape); letting sizeRe grab them would eat the angle and
    // silently drop the real diameter (e.g. "ברך 45° פ.פ 160" → 160 lost).
    if (sizeRe.hasMatch(t) && !kChipLevel2Shape.contains(t)) {
      // First numeric → main size. Subsequent numerics → folded INTO the size
      // chip ("130 50/50/50" → "130 50/50/50") so the full catalog name stays
      // recoverable from the chips alone (E2E §21.B).
      l5 = l5 == null ? t : '$l5 $t';
      i++;
      continue;
    }

    // Unit token (מ"מ / mm) — fold it INTO the size chip instead of dropping
    // it or showing it standalone, so the size reads "20-63 מ"מ" and the full
    // catalog name stays recoverable from the chips alone (E2E §21.B).
    if (_kChipUnits.contains(t)) {
      if (l5 != null) l5 = '$l5 $t';
      i++;
      continue;
    }

    // Try compound match (look ahead). Probe levels in priority order so
    // a substring that's ambiguous picks the most-specific level.
    bool tryCompound(List<List<String>> comps, List<String> out) {
      for (final comp in comps) {
        if (comp.length > tokens.length - i) continue;
        var ok = true;
        for (int j = 0; j < comp.length; j++) {
          if (tokens[i + j] != comp[j]) { ok = false; break; }
        }
        if (ok) {
          out.add(comp.join(' '));
          i += comp.length;
          return true;
        }
      }
      return false;
    }
    if (tryCompound(l3c, l3)) continue;
    if (tryCompound(l2c, l2)) continue;
    if (tryCompound(l1c, l1)) continue;
    if (tryCompound(l4c, l4)) continue;

    // Single-token level lookups.
    if (kChipLevel1Connection.contains(t)) { l1.add(t); i++; continue; }
    if (kChipLevel2Shape.contains(t)) { l2.add(t); i++; continue; }
    if (kChipLevel3Feature.contains(t)) { l3.add(t); i++; continue; }
    if (kChipLevel4Thread.contains(t)) { l4.add(t); i++; continue; }
    leftover.add(t);
    i++;
  }

  return ChipPath(
    type: type,
    level1: l1,
    level2: l2,
    level3: l3,
    level4: l4,
    level5: l5,
    leftover: leftover,
  );
}

const _l1Compounds = {
  'ריתוך חשמלי', 'לריתוך חשמלי',
  'לריתוך הברגה',
};
const _l2Compounds = {
  'בין אוגנים', 'מעבר ישר', 'מיזוג אוויר', 'אספקת מים',
};
const _l3Compounds = {
  'משטח ריסון', 'עם משטח ריסון',
  'ללא ידית', 'לנקודת מים',
  // "לוחית למיקום נקודת מים" — keep the whole positioning phrase as ONE chip
  // so it reads in order; otherwise מים→L2, למיקום/נקודת→L3 and the breadcrumb
  // scrambles to "מים ‹ למיקום ‹ נקודת".
  'למיקום נקודת מים',
  'עם מניעת זרימה חוזרת', 'עם מניעת זרימה', 'מניעת זרימה',
  'ציפוי כרום', 'כולל אטם', 'מפלסטיק פוליפרופילן',
  'לעבודה בגובה', 'לתיקון חורים',
  'פלדה מצופה PP', 'פלדה מצופה',
  'מכונת פיגורות', 'פיגורות שולחני', 'פיגורות קלה',
  'לקטרים', 'מקדח לרוכבים', 'תותב ריתוך',
  'לריתוך רוכב', 'עם רקורד',
  '(לעבודה בגובה)',
  // §22.E finish parentheticals (verbatim from catalog page headers — dashes
  // are stripped by tokenizer so compound match expects tokens WITHOUT '-').
  '(ציפוי כרום)',
  '(ציפוי כרום ללא ידית)',
  '(ציפוי כרום כולל ידית)',
  // ─── Huliot SmartLock compounds (multi-word qualifiers from catalog) ───
  'צד אחד חלק', 'צד אחד שקע תקע',
  'AQUA SLIM', 'Aqua Slim',
  'מערכת ניקוז',
  'לכיור רחצה', 'לכיור מטבח', 'לכיור אמריקאי',
  'למכונת כביסה', 'למדיח כלים', 'למדיח/מ.כביסה',
  'עם כניסה למדיח/מ.כביסה', 'עם כניסה למדיח', 'עם כניסה למזגן',
  'עם 2 מבואים צידיים', 'עם מבוא צידי וכניסה למ.כלים/מ.כביסה',
  'עם יציאה למדיח', 'יציאה למדיח',
  '+ צינור מדידה',
  'מצרה (צד אחד חלק)', 'מצרה (צד אחד חלק) חיבור ברזל ופלסטיק',
  'מתאם זווית - ג\'וקר', 'מתאם זווית',
  'אום מעבר מברזל', 'אום מעבר מברזל למעבר מברזל',
  'מתאם זחיח לכיור אמריקאי', 'מתאם זחיח',
  'מבוא זחיח עם חיבור למזגן', 'מבוא זחיח',
  'מאריך למבוא זחיח', 'ראש שקע תקע', 'ראש שקע תקע + אטם',
  'מאסף קווי AQUA SLIM',
  'סט פקקים לברז ושבלונה', 'סט פקקים לברז',
  'מצחיה קומפלט לאביק לאמבט',
  'מערכת ניקוז לאמבט',
  'ונטיל לכיור אמריקאי J', 'ונטיל לכיור אמריקאי',
  'מחסום הורקה למכונת כביסה',
  'סיפון הורקה קומפלקט J', 'סיפון הורקה קומפלקט',
  'מחסום H למכונת כביסה',
  'הגבהה אוניברסלית לאריח עם מכסה אטום מונע ריחות',
  'הגבהה אוניברסלית לאריח', 'מכסה אטום מונע ריחות',
  'אביזרים משלימים',
  'דגם פסים', 'דגם ריבועים', 'דגם מלא/אריח',
  'חיבור ברזל ופלסטיק', 'חיבור קצר לאגנית', 'חיבור ארוך לאגנית',
  'סט חיבור למדיח / מכונת כביסה', 'סט חיבור למדיח',
  'הגבהה פתח רבוע',
  'מצרה לסיפון', 'ברך מצרה לסיפון',
  'פקק לאביק', 'פקק לברז',
  'מבוא לכיור אמריקאי', 'מבוא לכיור',
  'מכלול לסיפון', 'צינור זחיח לסיפון',
  'אטם מעביר SL',
  'גומי אלסטומרי',
  'מפתח לאום תבריג',
  'Top Floor',
  // catalog notes
  '(ללא משפך)', '(שרשרת+10)', '(שחור)',
  'מאסף נפילה',
};
const _l4Compounds = {
  'שקע תקע', 'שקע-תקע',
  'תבריג פנימי', 'תבריג חיצוני',
  'תבריג פנים', 'תבריג חוץ',
};

/// Faceted filter for the hierarchy chips: returns all products that share
/// [product]'s type AND match its values for every level **strictly left of**
/// [chipLevelIndex] (0 = the first chip in the path). The result is the
/// candidate set when a user taps the chip at position [chipLevelIndex] —
/// it lets them pivot only on that one chip while everything to the left
/// is fixed.
List<P> findHierarchySiblings<P>(
  P product,
  int chipLevelIndex, {
  required Iterable<P> all,
  required String Function(P) nameOf,
  required String Function(P) brandOf,
  required String Function(P) polyrollBrand,
}) {
  final pol = polyrollBrand(product);
  if (brandOf(product) != pol) return [];
  final src = parseChips(nameOf(product)).path;
  // Build the "fixed prefix" up to (but excluding) chipLevelIndex.
  final prefix = src.take(chipLevelIndex).toList();
  final type = parseChips(nameOf(product)).type;
  final out = <P>[];
  for (final q in all) {
    if (brandOf(q) != pol) continue;
    final qc = parseChips(nameOf(q));
    if (qc.type != type) continue;
    final qPath = qc.path;
    if (qPath.length <= chipLevelIndex) continue; // q has no chip at that level
    // All prefix levels must match.
    var ok = true;
    for (int i = 0; i < prefix.length; i++) {
      if (i >= qPath.length || qPath[i] != prefix[i]) { ok = false; break; }
    }
    if (!ok) continue;
    out.add(q);
  }
  return out;
}
