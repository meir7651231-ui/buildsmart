// ⚛️ אטום-Dart · findTypeSiblings — מנוע-נקי (מנגנון-בלבד, אפס-דאטה · הכרעת-בעלים "אפס-דאטה במנוע").
// מוצא: buildsmart/.../screens/lipskey_products_screen.dart:1972-1992 (findTypeSiblings; חוק-2).
// טוהר-מוחלט: אפס import. **מילון-אוצר-המילים חולץ לדאטה** (dart-data/lipskey-vocab.dart, משותף עם
// findAttrSiblings) ומוזרק כ-7 שקעי-required. שקע-קטלוג: `catalog`. התנהגות זהה-ביט כשמזריקים את vocab-המקור.
//
// קלט:  p · catalog · 7 שקעי-מילון.
// פלט:  List<LipRow> — נציג-יחיד לכל סוג-מורכב שונה באותה קטגוריה; [p] אם ≤1.

/// מחזיק-קלט טהור: רק שלושת השדות ש-findTypeSiblings/‏_getCompoundType/‏_leadingType קוראים.
class LipRow {
  final String nameHe;
  final String brand;
  final String categoryHe;
  const LipRow({
    required this.nameHe,
    this.brand = 'ליפסקי',
    this.categoryHe = '',
  });
}

enum AttrKind { size, color, colorMod, model, subtype, type, material, pressure, sdr, maker }

/// מחזיק-מילון פנימי (מנגנון-הרכבה): עוטף את 7 השקעים המוזרקים ומושחל לעוזרים.
class _LipVocab {
  final List<String> models, types, subtypes, colors;
  final Set<String> pprMaterials, colorModifiers;
  final String polyrollBrand;
  const _LipVocab({
    required this.models,
    required this.types,
    required this.subtypes,
    required this.colors,
    required this.pprMaterials,
    required this.colorModifiers,
    required this.polyrollBrand,
  });
}

bool isSizeToken(String w) {
  if (RegExp(r'^DN', caseSensitive: false).hasMatch(w)) return true;
  // A leading Ø (diameter symbol) is a noise prefix on inch sizes —
  // strip it and re-test so `Ø1/2"` is recognised the same as `1/2"`.
  final stripped = w.startsWith('Ø') ? w.substring(1) : w;
  // numbers, fractions, ratios, inch marks, degrees, with × / x / X /
  // - separators (capital X appears in PPR product names like `160X25X1/2"`).
  // A leading bare fraction glyph counts as numeric too, so `½"` (no leading
  // digit) is recognised the same as `parseSizeTokens` does — keeping the two
  // tokenizers in agreement (no chip the finder surfaces that the card's
  // word-classifier would treat as a plain link).
  return RegExp(r'^[\d¼½¾⅛⅜⅝⅞]+([./×xX\-"׳״⅛¼½¾⅜⅝⅞°]+[\d"׳״°]*)*[\"׳״°]?$')
          .hasMatch(stripped) &&
      RegExp(r'[\d¼½¾⅛⅜⅝⅞]').hasMatch(stripped);
}

AttrKind? _attrKindFor(String word, _LipVocab vocab) {
  if (isSizeToken(word)) return AttrKind.size;
  if (vocab.pprMaterials.contains(word)) return AttrKind.material;
  if (RegExp(r'^PN\d').hasMatch(word)) return AttrKind.pressure;
  if (RegExp(r'^SDR', caseSensitive: false).hasMatch(word)) return AttrKind.sdr;
  if (vocab.colorModifiers.contains(word)) return AttrKind.colorMod;
  if (vocab.colors.contains(word)) return AttrKind.color;
  if (vocab.models.contains(word)) return AttrKind.model;
  if (vocab.subtypes.contains(word)) return AttrKind.subtype;
  return null;
}

String _getCompoundType(LipRow p, _LipVocab vocab) {
  final name = p.nameHe;
  final words = name.split(RegExp(r'\s+'));

  // Multi-word types — longest match first.
  final multiWord = vocab.types.where((t) => t.contains(' ')).toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  for (final t in multiWord) {
    if (name.contains(t)) return t;
  }

  // Single-word types + optional trailing qualifier.
  for (final typeWord in vocab.types) {
    if (typeWord.contains(' ')) continue;
    final idx = words.indexOf(typeWord);
    if (idx < 0) continue;
    if (idx + 1 >= words.length) return typeWord;
    final next = words[idx + 1];
    if (_attrKindFor(next, vocab) != null) return typeWord;
    if (vocab.colorModifiers.contains(next)) return typeWord;
    if (next.length > 2 && (next.startsWith('ל') || next.startsWith('ב'))) return typeWord;
    return '$typeWord $next';
  }
  return '';
}

String _leadingType(LipRow p, _LipVocab vocab) {
  for (final w in p.nameHe.split(RegExp(r'\s+'))) {
    if (vocab.types.contains(w)) return w;
  }
  return _getCompoundType(p, vocab);
}

/// Type siblings: one representative per distinct compound type in the same
/// category. Type is the top-level dimension — no frame restriction needed.
/// (verbatim · lipskey_products_screen.dart:1972-1992; `resolvedCatalogProducts`⇒`catalog`.)
List<LipRow> findTypeSiblings(
  LipRow p, {
  required List<LipRow> catalog,
  required List<String> models,
  required List<String> types,
  required List<String> subtypes,
  required List<String> colors,
  required Set<String> pprMaterials,
  required Set<String> colorModifiers,
  required String polyrollBrand,
}) {
  final vocab = _LipVocab(
    models: models,
    types: types,
    subtypes: subtypes,
    colors: colors,
    pprMaterials: pprMaterials,
    colorModifiers: colorModifiers,
    polyrollBrand: polyrollBrand,
  );
  final compound = _getCompoundType(p, vocab);
  if (compound.isEmpty) return [p];
  // Same category only — no cross-product (pipe→valve→drill). For PPR, key by
  // the LEADING type word (not _getCompoundType, which matches whichever
  // vocab.types word comes first in list-order and so fragments e.g. "מתאם …
  // רקורד" into fake types). This keeps real splits (collar↔flange) but collapses
  // duplicates.
  final ppr = p.brand == vocab.polyrollBrand;
  String keyOf(LipRow q) => ppr ? _leadingType(q, vocab) : _getCompoundType(q, vocab);
  final byCompound = <String, LipRow>{};
  byCompound[keyOf(p)] = p;
  for (final q in catalog) {
    if (q.categoryHe != p.categoryHe) continue;
    final qc = keyOf(q);
    if (qc.isEmpty) continue;
    if (!byCompound.containsKey(qc)) byCompound[qc] = q;
  }
  if (byCompound.length <= 1) return [p];
  return byCompound.values.toList();
}
