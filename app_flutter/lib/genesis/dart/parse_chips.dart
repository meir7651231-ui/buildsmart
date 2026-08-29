// ⚛️ אטום-Dart · parseChips — מנוע-נקי (מנגנון-בלבד, אפס-דאטה · הכרעת-בעלים "אפס-דאטה במנוע").
// מוצא: buildsmart/app_flutter/lib/data/chip_hierarchy.dart:196-315 (parseChips; טיפוס ChipPath :154-194; חוק-2).
// טוהר-מוחלט: פונקציית top-level, אפס import, **אפס דאטה צרובה**. 12 מילוני-הסיווג חולצו
// לדאטה חיה מחוץ למנוע (dart-data/chip-vocab.dart) ומוזרקים כ-12 שקעי-required:
//   chipTypes · compoundTypes · level1Connection · level2Shape · level3Feature ·
//   level4Thread · chipMaterial · chipUnits · l1Compounds · l2Compounds · l3Compounds · l4Compounds.
// התנהגות זהה-ביט למקור כשמזריקים את מילוני-המקור (הבוקס מזריק את chip-vocab.dart).
// נשמר במנוע (מנגנון/טיפוס, לא-דאטה): טיפוס-הפלט ChipPath + מתודת levelLabelOf — תוויות-רמה
//   מבניות (חיבור/צורה/תכונה/תבריג/מידה) הצמודות 1:1 ל-5 הרמות של הטיפוס עצמו.
//
// קלט:  nameHe + 12 מילוני-הסיווג (שקעים).
// פלט:  ChipPath — type + level1..level5 + leftover, לפי היררכיית-§21.

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

ChipPath parseChips(
  String nameHe, {
  required Set<String> chipTypes,
  required Set<String> compoundTypes,
  required Set<String> level1Connection,
  required Set<String> level2Shape,
  required Set<String> level3Feature,
  required Set<String> level4Thread,
  required Set<String> chipMaterial,
  required Set<String> chipUnits,
  required Set<String> l1Compounds,
  required Set<String> l2Compounds,
  required Set<String> l3Compounds,
  required Set<String> l4Compounds,
}) {
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
  // Lipski pipes label the bore explicitly as `DN40`/`DN110` — accept those
  // so they land in the size slot rather than leftover.
  final sizeRe = RegExp(r'^["”]?\d|^\d|^DN\d', caseSensitive: false);

  // Multi-word compounds, longest first per level. Walked at every position
  // BEFORE single-token classification, so "לנקודת מים" gets one chip even
  // though "מים" alone would land in L2.
  List<List<String>> sortByLen(Set<String> src) =>
      (src.map((s) => s.split(' ')).toList())
        ..sort((a, b) => b.length.compareTo(a.length));
  final l1c = sortByLen(l1Compounds);
  final l2c = sortByLen(l2Compounds);
  final l3c = sortByLen(l3Compounds);
  final l4c = sortByLen(l4Compounds);

  int i = 0;
  while (i < tokens.length) {
    final raw = tokens[i];
    // Strip surrounding parens for vocabulary lookup ("(סיפון)" → "סיפון")
    // but keep the original text so the reconstruction stays verbatim.
    final t = (raw.startsWith('(') && raw.endsWith(')') && raw.length > 2)
        ? raw.substring(1, raw.length - 1)
        : raw;
    if (chipMaterial.contains(t)) { i++; continue; }
    // Compound-type lookahead (e.g. 'מיכל הדחה', 'מושב אסלה'). Must precede
    // the single-token type check so that the leading word doesn't grab
    // half the compound and leave the rest stranded as leftover.
    if (type == null) {
      String? hit;
      int hitLen = 0;
      for (final ct in compoundTypes) {
        final parts = ct.split(' ');
        if (parts.length > tokens.length - i) continue;
        var ok = true;
        for (int j = 0; j < parts.length; j++) {
          if (tokens[i + j] != parts[j]) { ok = false; break; }
        }
        if (ok) { hit = ct; hitLen = parts.length; break; }
      }
      if (hit != null) { type = hit; i += hitLen; continue; }
    }
    if (type == null && chipTypes.contains(t)) { type = t; i++; continue; }
    // Size detection — but NOT for declared shape tokens that happen to start
    // with a digit (45° / 90°). Those are the elbow/tee ANGLE and belong in
    // level-2 (shape); letting sizeRe grab them would eat the angle and
    // silently drop the real diameter (e.g. "ברך 45° פ.פ 160" → 160 lost).
    if (sizeRe.hasMatch(t) && !level2Shape.contains(t)) {
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
    if (chipUnits.contains(t)) {
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
    if (level1Connection.contains(t)) { l1.add(t); i++; continue; }
    if (level2Shape.contains(t)) { l2.add(t); i++; continue; }
    if (level3Feature.contains(t)) { l3.add(t); i++; continue; }
    if (level4Thread.contains(t)) { l4.add(t); i++; continue; }
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

