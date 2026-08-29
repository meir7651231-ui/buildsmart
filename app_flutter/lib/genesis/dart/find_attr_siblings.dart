// ⚛️ אטום-Dart · findAttrSiblings — מנוע-נקי (מנגנון-בלבד, אפס-דאטה · הכרעת-בעלים "אפס-דאטה במנוע").
// מוצא: buildsmart/.../screens/lipskey_products_screen.dart:1839-1910 (findAttrSiblings; חוק-2).
// טוהר-מוחלט: אפס import. **מילון-אוצר-המילים חולץ לדאטה** (dart-data/lipskey-vocab.dart) ומוזרק
// כ-7 שקעי-required: models · types · subtypes · colors · pprMaterials · colorModifiers · polyrollBrand.
// הנגזרות (colorWords/modelWords/subtypeWords) = **מנגנון** (פיצול-מילים≥2) ⇒ מחושבות במנוע מהרשימות המוזרקות.
// שקע-קטלוג: `catalog` (⇔ resolvedCatalogProducts). התנהגות זהה-ביט כשמזריקים את vocab-המקור.
//
// קלט:  p · word(רפאים) · kind · catalog · 7 שקעי-מילון.
// פלט:  List<LipRow> — אחי-הממד; [p] כשאין חלופה אמיתית.

/// מחזיק-קלט טהור: רק השדות ש-findAttrSiblings + עוזריו קוראים.
class LipRow {
  final String nameHe;
  final String brand;
  final String categoryHe;
  final Map<String, dynamic>? dims;
  const LipRow({
    required this.nameHe,
    this.brand = 'ליפסקי',
    this.categoryHe = '',
    this.dims,
  });
}


enum AttrKind { size, color, colorMod, model, subtype, type, material, pressure, sdr, maker }

/// מחזיק-מילון פנימי (מנגנון-הרכבה): עוטף את 7 השקעים המוזרקים + מחשב 3 נגזרות-מילים
/// (פיצול-מילים≥2). נבנה פעם-אחת בכניסת-המנוע ומושחל לעוזרים — לא-דאטה, לא-שקע-חיצוני.
class _LipVocab {
  final List<String> models, types, subtypes, colors;
  final Set<String> pprMaterials, colorModifiers, colorWords, modelWords, subtypeWords;
  final String polyrollBrand;
  _LipVocab({
    required this.models,
    required this.types,
    required this.subtypes,
    required this.colors,
    required this.pprMaterials,
    required this.colorModifiers,
    required this.polyrollBrand,
  })  : colorWords = {
          for (final s in colors) ...s.split(RegExp(r'\s+')).where((w) => w.length >= 2)
        },
        modelWords = {
          for (final s in models) ...s.split(RegExp(r'\s+')).where((w) => w.length >= 2)
        },
        subtypeWords = {
          for (final s in subtypes) ...s.split(RegExp(r'\s+')).where((w) => w.length >= 2)
        };
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

String _stripWordsOfKind(String name, AttrKind kind, _LipVocab vocab) {
  var result = name;
  // Strip multi-word subtype/color entries first (e.g. "דו כיווני", "ניקל מוברש").
  if (kind == AttrKind.subtype) {
    for (final s in vocab.subtypes) {
      if (s.contains(' ')) result = result.replaceAll(s, ' ');
    }
  } else if (kind == AttrKind.color) {
    for (final c in vocab.colors) {
      if (c.contains(' ')) result = result.replaceAll(c, ' ');
    }
  }
  final Set<String> wordSet = switch (kind) {
    AttrKind.color => vocab.colorWords,
    AttrKind.colorMod => vocab.colorModifiers,
    AttrKind.model => vocab.modelWords,
    AttrKind.subtype => vocab.subtypeWords,
    AttrKind.size => const {},
    AttrKind.type => <String>{for (final v in vocab.types) v},
    AttrKind.material => vocab.pprMaterials,
    AttrKind.pressure => const {},
    AttrKind.sdr => const {},
    AttrKind.maker => const {},
  };
  return result
      .split(RegExp(r'\s+'))
      .where((w) =>
          w.isNotEmpty &&
          (kind == AttrKind.size
              ? !isSizeToken(w)
              : (kind == AttrKind.pressure || kind == AttrKind.sdr)
                  ? _attrKindFor(w, vocab) != kind
                  : !wordSet.contains(w)))
      .join(' ')
      .trim();
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

/// Stored in dims (not the name), so the maker chip is synthetic.
String _makerOf(LipRow p) =>
    (p.dims?['יצרן'] as String?)?.trim() ?? '';

/// Nominal bore (dn) used to match the same product across manufacturers.
String _nominalBore(LipRow p) {
  final d = p.dims;
  final raw = (d?['dn נומינלי'] ?? d?['קוטר חיצוני'] ?? d?['de קוטר חיצוני'])
      ?.toString();
  final src = raw ?? p.nameHe;
  return RegExp(r'\d+(?:\.\d+)?').firstMatch(src)?.group(0) ?? '';
}

/// Spec signature identical for the same product from different manufacturers,
/// so the maker picker pairs e.g. the Heliroma and Aquatherm faser 20×2.8.
String _makerSignature(LipRow p, _LipVocab vocab) =>
    '${p.categoryHe}|${_getCompoundType(p, vocab)}|${_nominalBore(p)}'
    '|${p.dims?['PN'] ?? ''}|${p.dims?['SDR'] ?? ''}';

/// Find sibling products for a given attribute kind.
/// (verbatim · lipskey_products_screen.dart:1839-1910; `resolvedCatalogProducts`⇒`catalog`.)
List<LipRow> findAttrSiblings(
  LipRow p,
  String word,
  AttrKind kind, {
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
  // Manufacturer: same spec from a different maker (cross-line, cross-category).
  if (kind == AttrKind.maker) {
    final sig = _makerSignature(p, vocab);
    final seen = <String>{};
    final res = <LipRow>[];
    // stage-3.1 — follows the ACTIVE catalog source (v2-aware).
    for (final q in catalog) {
      if (q.brand != vocab.polyrollBrand || _makerSignature(q, vocab) != sig) continue;
      final m = _makerOf(q);
      if (m.isEmpty || !seen.add(m)) continue;
      res.add(q);
    }
    return res.length <= 1 ? [p] : res;
  }
  // PPR: every chip is a pickable dimension. Scope = whole brand within the
  // same product type, so the picker offers the real alternatives — material
  // (PPR/PPRCT), line/subtype (פייזר ↔ אספקת מים), size, etc. — even across the
  // separate per-line categories.
  if (p.brand == vocab.polyrollBrand) {
    final pType = _getCompoundType(p, vocab);
    // Size is a within-line dimension: a faser pipe's size variants are the
    // other faser sizes — never another line's (drainage 160/200…). Restrict
    // it to the same category so the picker isn't flooded with every pipe
    // size in the brand. Material/subtype stay cross-line so the picker can
    // still switch PPR↔PPRCT or faser↔supply.
    final sameLineOnly = kind == AttrKind.size;
    final seen = <String>{};
    final res = <LipRow>[];
    for (final q in catalog) {
      if (q.brand != vocab.polyrollBrand || _getCompoundType(q, vocab) != pType) continue;
      if (sameLineOnly && q.categoryHe != p.categoryHe) continue;
      final v = q.nameHe
          .split(RegExp(r'\s+'))
          .where((w) => _attrKindFor(w, vocab) == kind)
          .join(' ');
      if (v.isEmpty || !seen.add(v)) continue;
      res.add(q);
    }
    return res.length <= 1 ? [p] : res;
  }
  if (kind == AttrKind.model) {
    // Category-wide: one representative per distinct model word.
    final seen = <String>{};
    final result = <LipRow>[];
    for (final q in catalog) {
      if (q.categoryHe != p.categoryHe) continue;
      final modelWord = q.nameHe
          .split(RegExp(r'\s+'))
          .firstWhere((w) => _attrKindFor(w, vocab) == AttrKind.model,
              orElse: () => '');
      if (modelWord.isEmpty) continue;
      if (seen.add(modelWord)) result.add(q);
    }
    return result.length <= 1 ? [p] : result;
  }

  final pFrame = _stripWordsOfKind(p.nameHe, kind, vocab);
  if (pFrame.length < 2) return [p];
  return catalog.where((q) {
    if (q.categoryHe != p.categoryHe) return false;
    if (_stripWordsOfKind(q.nameHe, kind, vocab) != pFrame) return false;
    if (kind == AttrKind.colorMod) return true;
    return q.nameHe
        .split(RegExp(r'\s+'))
        .any((w) => _attrKindFor(w, vocab) == kind);
  }).toList();
}
