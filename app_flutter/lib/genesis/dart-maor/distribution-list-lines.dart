// ⚛️ אטום-Dart (דרגת-חוזה) · distributionListLines — רשימת-חלוקה מודפסת לחבילה.
// מוצא: maor/src/components/shop/lib.ts:627-645 · המקור: new/atoms/distribution-list-lines.mjs
// חוזה: new/atoms/distribution-list-lines.contract.md · רתמת-זהב: distribution-list-lines_test.dart
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// שקעים (חוק-1, הוזרקו כפרמטרים — אפס import פנימי):
//   itemOf(db, c)            → פותר רכיב-חבילה לפריט-קטלוג (Map עם 'name').
//   beneficiaryLabel(db,a,c) → תווית-הנהנה (שם-המשפחה) כמחרוזת.
//
// הערות-המרה (מקור→Dart):
//   • `Array.filter(Boolean)` של JS מסנן ערכים falsy (null / '' בעיקר כאן) —
//     ממומש דרך `_truthy` מפורש (כלל-המרה 7: truthiness ≠ בין השפות).
//   • `product?.name ?? ''` / `fam?.phone ?? ''` — null-safe; שדה-חסר או null ⇒ ''.
//   • `'='.repeat(30)` ⇒ `'=' * 30`. אין locale/פורמט/getMonth/תאריך-מגלגל/substring.

/// True iff the JS `Boolean(v)` would be truthy for the values that reach the
/// distribution list (strings / null). Empty string, null, false, 0 → falsy.
bool _truthy(Object? v) {
  if (v == null) return false;
  if (v is String) return v.isNotEmpty;
  if (v is bool) return v;
  if (v is num) return v != 0;
  return true;
}

/// Builds the printable distribution list for a shop product package.
/// Verbatim behaviour of the JS source `distributionListLines`.
List<String> distributionListLines(Map<String, dynamic> db,
  Object? productId,
  Object? config,
  Map<String, dynamic> Function(Map<String, dynamic> db, dynamic component) itemOf,
  String Function(Map<String, dynamic> db, dynamic assignment, Object? config) beneficiaryLabel, Map<String, dynamic> T) {
  final products = (db['shopProducts'] as List?) ?? const [];
  Map<String, dynamic>? product;
  for (final p in products) {
    if ((p as Map)['id'] == productId) {
      product = p.cast<String, dynamic>();
      break;
    }
  }

  final lines = <String>[
    (T['k1'] as String) + ((product?['name'] as String?) ?? ''),
    '=' * 30,
  ];

  final assignments = (db['shopAssignments'] as List?) ?? const [];
  final active = <Map<String, dynamic>>[];
  for (final a in assignments) {
    final am = (a as Map).cast<String, dynamic>();
    if (am['productId'] == productId && am['status'] == 'active') active.add(am);
  }

  final families = (db['families'] as List?) ?? const [];
  for (final a in active) {
    Map<String, dynamic>? fam;
    for (final f in families) {
      if ((f as Map)['id'] == a['famId']) {
        fam = f.cast<String, dynamic>();
        break;
      }
    }

    final components = (product?['components'] as List?) ?? const [];
    final compNames = <String>[];
    for (final c in components) {
      final name = itemOf(db, c)['name'];
      if (_truthy(name)) compNames.add(name as String);
    }
    final comps = compNames.join(' + ');

    final famAddr = fam == null
        ? ''
        : [fam['address'], fam['city']].where(_truthy).map((e) => e as String).join(', ');

    final parts = <Object?>[
      beneficiaryLabel(db, a, config),
      famAddr,
      (fam?['phone'] as String?) ?? '',
      comps,
      (T['k3'] as String),
    ];
    lines.add(parts.where(_truthy).map((e) => e as String).join(' · '));
  }

  if (active.isEmpty) lines.add((T['k4'] as String));
  return lines;
}
