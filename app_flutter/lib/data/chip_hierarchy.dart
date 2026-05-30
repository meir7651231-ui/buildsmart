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
};

const Set<String> kChipLevel1Connection = {
  'לריתוך', 'ריתוך', 'הברגה',
  // EF compound: when we see 'חשמלי' adjacent we promote to "ריתוך חשמלי"
  'חשמלי', 'אלקטרופיוזן',
};

const Set<String> kChipLevel2Shape = {
  '45°', '90°', '45', '90',
  'מצרה', 'שווה', 'סמוי', 'פרפר', 'כדורי',
  'מעבר', 'ישר', 'אלכסוני',
  'בין', 'אוגנים', // compound "בין אוגנים"
  'עגול', 'משושה', 'רקורד',
  'פייזר', 'אספקת', 'מים', // pipe sub-types: "אספקת מים", "פייזר"
  'מיזוג', 'אוויר',
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
  'מ"מ',
  'סופי', 'גשר',
  'הולירומה', // sub-brand qualifier
  'מצופה', 'פלדה', // for "אוגן פלדה מצופה PP"
  'PP',
};

const Set<String> kChipLevel4Thread = {
  'פ.פ', 'פ.ח', 'ח.ח', 'ח.פ',
  'פנימי', 'חיצוני', 'תבריג',
  'שקע', 'תקע',
  'פנים', 'חוץ', // alternates
};

// Material tokens — shown as image badge, not in chip path.
const Set<String> kChipMaterial = {'PPR', 'PPRCT', 'PP-RCT'};

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
}

ChipPath parseChips(String nameHe) {
  // Tokenize, keep size-tokens intact (e.g. "25x½\"", "63x32", "20×2.8").
  final tokens = nameHe.split(RegExp(r'\s+'))
      .where((t) => t.trim().isNotEmpty)
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
    final t = tokens[i];
    if (kChipMaterial.contains(t)) { i++; continue; }
    if (type == null && kChipTypes.contains(t)) { type = t; i++; continue; }
    if (sizeRe.hasMatch(t)) { l5 ??= t; i++; continue; }

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

const _l1Compounds = {'ריתוך חשמלי', 'לריתוך חשמלי'};
const _l2Compounds = {
  'בין אוגנים', 'מעבר ישר', 'מיזוג אוויר', 'אספקת מים',
};
const _l3Compounds = {
  'משטח ריסון', 'ללא ידית', 'לנקודת מים',
  'עם מניעת זרימה חוזרת', 'עם מניעת זרימה', 'מניעת זרימה',
  'ציפוי כרום', 'כולל אטם', 'מפלסטיק פוליפרופילן',
  'לעבודה בגובה', 'לתיקון חורים',
  'פלדה מצופה PP', 'פלדה מצופה',
  'מכונת פיגורות', 'פיגורות שולחני', 'פיגורות קלה',
  'לקטרים', 'מקדח לרוכבים', 'תותב ריתוך',
  'לריתוך רוכב',
  '(לעבודה בגובה)',
};
const _l4Compounds = {'שקע תקע', 'שקע-תקע'};

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
