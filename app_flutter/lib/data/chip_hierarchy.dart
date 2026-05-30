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
  final tokens = nameHe.split(RegExp(r'\s+'));
  String? type;
  var l1 = <String>[];
  var l2 = <String>[];
  var l3 = <String>[];
  var l4 = <String>[];
  String? l5;
  final leftover = <String>[];
  // Size tokens: usually start with a digit but RTL quoting can prefix
  // tokens like `"32x1` (the trailing quote got pulled to the start by bidi).
  final sizeRe = RegExp(r'^["”]?\d|^\d');

  for (final t0 in tokens) {
    final t = t0.trim();
    if (t.isEmpty) continue;
    if (kChipMaterial.contains(t)) continue;
    if (type == null && kChipTypes.contains(t)) {
      type = t;
      continue;
    }
    if (sizeRe.hasMatch(t)) {
      l5 ??= t;
      continue;
    }
    if (kChipLevel1Connection.contains(t)) { l1.add(t); continue; }
    if (kChipLevel2Shape.contains(t)) { l2.add(t); continue; }
    if (kChipLevel3Feature.contains(t)) { l3.add(t); continue; }
    if (kChipLevel4Thread.contains(t)) { l4.add(t); continue; }
    leftover.add(t);
  }

  List<String> mergePair(List<String> src, Set<String> dual) {
    final out = <String>[];
    for (int i = 0; i < src.length; i++) {
      if (i + 1 < src.length) {
        final pair = '${src[i]} ${src[i + 1]}';
        if (dual.contains(pair)) {
          out.add(pair);
          i++;
          continue;
        }
      }
      out.add(src[i]);
    }
    return out;
  }

  l1 = mergePair(l1, _l1Compounds);
  l2 = mergePair(l2, _l2Compounds);
  l3 = mergePair(l3, _l3Compounds);
  l4 = mergePair(l4, _l4Compounds);

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
  'לעבודה בגובה', 'לתיקון חורים', 'פלדה מצופה',
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
