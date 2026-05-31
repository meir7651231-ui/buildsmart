// Variant-family detection over the lipskey catalog.
// A "family" is a set of 2+ products that are identical EXCEPT for one
// attribute (size / color / brand-model / subtype). The catalog tab renders
// these families in the new "וריאנטים" section.

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';

enum AttrKind { size, color, model, subtype }

const Map<AttrKind, String> kAttrKindLabel = {
  AttrKind.size: 'מידה',
  AttrKind.color: 'צבע',
  AttrKind.model: 'דגם',
  AttrKind.subtype: 'תת-סוג',
};

const Map<AttrKind, String> kAttrKindEmoji = {
  AttrKind.size: '📐',
  AttrKind.color: '🎨',
  AttrKind.model: '🏷',
  AttrKind.subtype: '📋',
};

bool _isSizeToken(String w) {
  if (RegExp(r'^DN', caseSensitive: false).hasMatch(w)) return true;
  return RegExp(r'^[\d]+([./×x\-"׳״⅛¼½¾⅜⅝⅞]+[\d"׳״]*)*[\"׳״]?$')
          .hasMatch(w) &&
      RegExp(r'\d').hasMatch(w);
}

AttrKind? kindOf(String w) {
  if (_isSizeToken(w)) return AttrKind.size;
  if (kLipskeyColors.contains(w)) return AttrKind.color;
  if (kLipskeyModels.contains(w)) return AttrKind.model;
  if (kLipskeySubtypes.contains(w)) return AttrKind.subtype;
  return null;
}

String _stripKind(String name, AttrKind k) => name
    .split(RegExp(r'\s+'))
    .where((w) => w.isNotEmpty && kindOf(w) != k)
    .join(' ');

/// The differing-attribute value(s) in a product's name, joined by space.
String variantValue(LipskeyCatalogProduct p, AttrKind kind) => p.nameHe
    .split(RegExp(r'\s+'))
    .where((w) => kindOf(w) == kind)
    .join(' ');

class VariantFamily {
  /// The "frame" — product name with the differing attribute words removed.
  final String frame;
  final AttrKind kind;
  final String brand;
  final String categoryHe;
  final int page;
  final List<LipskeyCatalogProduct> products;

  VariantFamily({
    required this.frame,
    required this.kind,
    required this.brand,
    required this.categoryHe,
    required this.page,
    required this.products,
  });

  String get label => frame;
  int get count => products.length;
  String get emoji => kAttrKindEmoji[kind] ?? '';
}

List<VariantFamily>? _cache;

/// Compute all variant families across the catalog. Memoised after first call.
List<VariantFamily> allVariantFamilies() {
  if (_cache != null) return _cache!;
  final out = <VariantFamily>[];

  for (final kind in AttrKind.values) {
    // Group key: frame + brand + categoryHe + page + qtyPack + qtyPallet
    final groups = <String, List<LipskeyCatalogProduct>>{};
    // Search the unified catalog (Lipskey + Polyroll) so PPR products get
    // variant families just like Lipskey products. Grouping by brand keeps
    // PPR families distinct from Lipskey families — no cross-pollination.
    for (final p in kCatalogProducts) {
      final hasKind = p.nameHe
          .split(RegExp(r'\s+'))
          .any((w) => kindOf(w) == kind);
      if (!hasKind) continue;
      final frame = _stripKind(p.nameHe, kind);
      if (frame.length < 3) continue;
      final key = [
        frame,
        p.brand,
        p.categoryHe,
        p.page,
        p.qtyPack ?? '-',
        p.qtyPallet ?? '-',
      ].join('||');
      groups.putIfAbsent(key, () => []).add(p);
    }
    for (final e in groups.entries) {
      if (e.value.length < 2) continue;
      // Need at least 2 distinct attribute values
      final distinct = e.value.map((p) => variantValue(p, kind)).toSet();
      if (distinct.length < 2) continue;
      final parts = e.key.split('||');
      out.add(VariantFamily(
        frame: parts[0],
        kind: kind,
        brand: parts[1],
        categoryHe: parts[2],
        page: int.tryParse(parts[3]) ?? 0,
        products: [...e.value]
          ..sort((a, b) =>
              variantValue(a, kind).compareTo(variantValue(b, kind))),
      ));
    }
  }

  // Sort by attribute kind then by count desc
  const kindOrder = {
    AttrKind.size: 0,
    AttrKind.color: 1,
    AttrKind.subtype: 2,
    AttrKind.model: 3,
  };
  out.sort((a, b) {
    final kc = (kindOrder[a.kind] ?? 0).compareTo(kindOrder[b.kind] ?? 0);
    if (kc != 0) return kc;
    return b.count.compareTo(a.count);
  });

  _cache = out;
  return out;
}

/// Families that match an attribute-kind filter (or all when kind is null).
List<VariantFamily> familiesByKind(AttrKind? kind) {
  final all = allVariantFamilies();
  if (kind == null) return all;
  return all.where((f) => f.kind == kind).toList();
}

// ─── Size-only sub-facets ───────────────────────────────────────────────────
// A size value carries three orthogonal facets that we expose as chips:
//   1. structurePattern — A · A×A · A×B · A×A×A · A×B×A …
//   2. diameter — the numeric atom(s) (16, 20, 1/2", DN50…)
//   3. system — אינץ' / HDPE / DN / חופשי

/// Structural pattern of a size string, e.g. "16×16" → "A×A", "16×1/2"×16" →
/// "A×B×A". Returns "1" for single-value sizes.
String sizeStructurePattern(String size) {
  final main = size.trim().split(' ').firstWhere((s) => s.isNotEmpty,
      orElse: () => size);
  final parts =
      main.split(RegExp(r'[×x]')).where((s) => s.isNotEmpty).toList();
  if (parts.length == 1) return '1';
  if (parts.length == 2) return parts[0] == parts[1] ? 'A×A' : 'A×B';
  if (parts.length == 3) {
    final distinct = parts.toSet();
    if (distinct.length == 1) return 'A×A×A';
    if (parts[0] == parts[2]) return 'A×B×A';
    if (distinct.length == 2) return 'A×A×B';
    return 'A×B×C';
  }
  return '${parts.length}×';
}

/// Diameter atoms inside a size string. Examples:
///   "16×1/2"" → ["16", "1/2\""]
///   "DN50"    → ["DN50"]
///   "200"     → ["200"]
String _normAtom(String s) {
  // Treat 1½" and 11/2" as the same atom for chip grouping
  return s
      .replaceAll('½', '/2')
      .replaceAll('¼', '/4')
      .replaceAll('¾', '/4')
      .trim();
}

List<String> sizeDiameterAtoms(String size) {
  final out = <String>{};
  // Each space-separated chunk could carry diameters (with × splits) OR a
  // bare length tail (e.g. "DN50 200" → "DN50", "200ס"מ").
  final chunks = size.trim().split(' ').where((s) => s.isNotEmpty).toList();
  for (int i = 0; i < chunks.length; i++) {
    final chunk = chunks[i];
    if (chunk.contains('×') || chunk.contains('x')) {
      for (final p in chunk.split(RegExp(r'[×x]'))) {
        if (p.isNotEmpty) out.add(_normAtom(p));
      }
    } else if (i == 0) {
      out.add(_normAtom(chunk));
    } else {
      // Plain numeric tail (e.g. 200, 250) → treat as length atom.
      if (RegExp(r'^\d+$').hasMatch(chunk)) {
        out.add('${chunk} ס"מ');
      } else {
        out.add(_normAtom(chunk));
      }
    }
  }
  return out.toList();
}

/// Canonical key identifying a product's "family" — every variant (size,
/// color, brand-model, subtype) of the same product yields the same key. Two
/// products with equal canonical keys belong to the same family and should
/// collapse into a single row in any product list.
String productCanonicalKey(LipskeyCatalogProduct p) {
  final stripped = p.nameHe
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty && kindOf(w) == null)
      .join(' ');
  return [
    stripped,
    p.brand,
    p.categoryHe,
    p.page,
    p.qtyPack ?? '-',
    p.qtyPallet ?? '-',
  ].join('||');
}

/// Material of the product, inferred from category + name. Every product
/// belongs to exactly one material bucket (used as the 4th-level grouping
/// under "קוטר" — diameter).
String productMaterial(LipskeyCatalogProduct p) {
  final c = p.categoryHe;
  final n = p.nameHe;
  if (c.contains('HDPE')) return 'HDPE';
  if (c.contains('PVC') || n.contains('PVC')) return 'PVC';
  if (c.contains('PP') || n.contains('PP')) return 'PP';
  if (c.contains('רב שכבתי') || n.contains('רב שכבתי')) return 'רב שכבתי';
  if (c.contains('NTM') || n.contains('NTM')) return 'NTM';
  if (c.contains('נחושת') || n.contains('נחושת')) return 'נחושת';
  if (c.contains('תבריג') || n.contains('תבריג')) return 'פליז (תבריג)';
  if (c.contains('גמיש')) return 'גמיש';
  if (c.contains('אפור')) return 'אפור (PVC ניקוז)';
  if (c.contains('חבק') || c.contains('עוגן')) return 'מתכת/חבקים';
  if (c.contains('ברז') || c.contains('מקלח') || c.contains('מזלף')) return 'ברזים/מקלחות';
  if (c.contains('מחסום') || c.contains('סיפון') || c.contains('כיור') || c.contains('אסל')) return 'קרמיקה/פלסטיק';
  return 'אחר';
}

/// Gender pattern of a product name based on זכר/נקבה/חיצוני/פנימי mentions.
/// Returns one of:
///   - "ח.ח" / "ז.ז" — both ends male
///   - "פ.פ" / "נ.נ" — both ends female
///   - "פ.ח" / "ז.נ" — mixed (transition / one of each)
///   - "ח" — single male end
///   - "פ" — single female end
///   - "—" — no gender mentioned in name
String genderPattern(String name) {
  final male = RegExp(r'זכר|חיצוני', caseSensitive: false)
      .allMatches(name)
      .length;
  final female = RegExp(r'נקבה|פנימי', caseSensitive: false)
      .allMatches(name)
      .length;
  if (male == 0 && female == 0) return '—';
  if (male > 0 && female > 0) return 'ז.נ';
  if (male >= 2 && female == 0) return 'ז.ז';
  if (female >= 2 && male == 0) return 'נ.נ';
  if (male == 1 && female == 0) return 'ז';
  if (female == 1 && male == 0) return 'נ';
  return '—';
}

/// Detect the "size system" of a value: אינץ' (inch), HDPE (mm whole numbers),
/// DN (ניקוז), or אחר.
String sizeSystem(String size) {
  final s = size.trim();
  if (s.contains('DN') || s.contains('dn')) return 'DN ניקוז';
  if (s.contains('"') || s.contains('½') || s.contains('¼') || s.contains('¾') ||
      RegExp(r'\d/\d').hasMatch(s)) {
    return 'תבריג (אינץ\')';
  }
  if (RegExp(r'^\d+(?:[×x]\d+)*( \d+)?$').hasMatch(s)) {
    final firstNum = int.tryParse(RegExp(r'^\d+').firstMatch(s)?.group(0) ?? '');
    if (firstNum != null) {
      if (firstNum >= 16 && firstNum <= 63) return 'HDPE (מ"מ)';
      if (firstNum >= 75) return 'DN ניקוז';
    }
  }
  return 'אחר';
}

/// Group the values of a kind into "sub-groups" where two values belong to the
/// same sub-group iff they appear together in at least one family. Practically:
/// (יחיד, כפול) form one sub-group and (מרובע, עגול) form a different one —
/// because no family mixes them. Same for (ברקת, ספיר) vs (גרנדה, מלודי).
/// Each sub-group is sorted by value-frequency desc, and the sub-groups
/// themselves are sorted by total value count desc.
List<List<(String value, int count)>> valueSubGroupsForKind(AttrKind kind) {
  final fams = familiesByKind(kind);
  if (fams.isEmpty) return const [];

  // Collect all distinct values and per-value frequency across products
  final freq = <String, int>{};
  for (final fam in fams) {
    for (final p in fam.products) {
      final v = variantValue(p, kind);
      if (v.isEmpty) continue;
      freq[v] = (freq[v] ?? 0) + 1;
    }
  }
  if (freq.isEmpty) return const [];

  // Union-Find over the value space.
  final parent = <String, String>{};
  for (final v in freq.keys) {
    parent[v] = v;
  }
  String find(String x) {
    var cur = x;
    while (parent[cur] != cur) {
      parent[cur] = parent[parent[cur]!]!;
      cur = parent[cur]!;
    }
    return cur;
  }
  void union(String a, String b) {
    final ra = find(a), rb = find(b);
    if (ra != rb) parent[ra] = rb;
  }
  // For each family, union all its values together
  for (final fam in fams) {
    final vs = fam.products
        .map((p) => variantValue(p, kind))
        .where((v) => v.isNotEmpty)
        .toSet();
    if (vs.length < 2) continue;
    final first = vs.first;
    for (final other in vs.skip(1)) {
      union(first, other);
    }
  }

  // Bucket values by their root
  final groups = <String, List<(String value, int count)>>{};
  for (final entry in freq.entries) {
    final r = find(entry.key);
    groups.putIfAbsent(r, () => []).add((entry.key, entry.value));
  }

  // Sort values inside each sub-group by count desc
  final out = groups.values.map((g) {
    final sorted = [...g]..sort((a, b) => b.$2.compareTo(a.$2));
    return sorted;
  }).toList();

  // Sort sub-groups by total count desc, then by member count desc
  out.sort((a, b) {
    final ta = a.fold<int>(0, (s, e) => s + e.$2);
    final tb = b.fold<int>(0, (s, e) => s + e.$2);
    if (tb != ta) return tb.compareTo(ta);
    return b.length.compareTo(a.length);
  });
  return out;
}
