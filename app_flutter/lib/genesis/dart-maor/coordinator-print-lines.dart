// ⚛️ אטום-Dart (דרגת-חוזה) · coordinatorPrintLines — תדפיס-שטח לרכז (רשימת קופות לסבב).
// מוצא: maor/src/components/tzedaka/lib.ts:250-280 · המקור: new/atoms/coordinator-print-lines.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). שלושת השכנים הוזרקו כשקעים (חוק-1/חוק-3):
//        termOf(config, key, fb) · coordinatorBoxes(boxes, coordId) · lastCollectionIso(box).
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נטה לפספס):
//  • `config ? termOf(...) : fb` → truthiness של JS על undefined/אובייקט ⇒ `config != null`.
//  • `.find(...)` של JS מחזיר undefined כשאין ⇒ `_find` (מחזיר null; firstWhere-עם-orElse
//    נופל על טיפוס-הרשימה המ-reified). זה מכסה גם רכז-לא-מוכר וגם משפחה-לא-מוכרת.
//  • `coord?.name ?? ''` → coord עשוי null ⇒ null-safe מפורש.
//  • `'='.repeat(30)` → `'=' * 30` (המנוע פלט `._repeat` שגוי).
//  • `fam ? ... : ...` truthiness של אובייקט/undefined ⇒ `fam != null`.
//  • `'#' + b.num` — JS מצרף מספר-למחרוזת; Dart אינו ⇒ `.toString()`.
//  • `.filter(Boolean)` של JS ⇒ `.where(_truthy)` (מחרוזת-ריקה/null/false/0 = מסונן).
//  • `last ? ... : 'טרם רוקנה'` — last היא מחרוזת ('' כשאין ריקון) ⇒ `_truthy(last)`.
//  • הגישה לשדות = Map (`db['x']`/`b['x']`) — הנתונים הם Map, לא record.
//  • מוטביליות: `lines` final (מוטבל דרך add); הפורמט/locale-של-המונח חי בשקע termOf.

bool _truthy(dynamic v) => v != null && v != false && v != '' && v != 0;

// מחקה .find של JS: מחזיר את הראשון-התואם או null (לא זורק).
dynamic _find(dynamic list, bool Function(dynamic) pred) {
  for (final x in (list as List)) {
    if (pred(x)) return x;
  }
  return null;
}

/// A coordinator's field print-out (boxes to visit this round). Verbatim port of
/// new/atoms/coordinator-print-lines.mjs; the neighbours termOf, coordinatorBoxes
/// and lastCollectionIso are injected as sockets (Law 1/3).
List<String> coordinatorPrintLines(Map<String, dynamic> db,
  String coordinatorId,
  Map<String, dynamic>? config,
  String Function(Map<String, dynamic> config, String key, String fb) termOf,
  List<dynamic> Function(dynamic boxes, String coordId) coordinatorBoxes,
  String Function(dynamic box) lastCollectionIso, Map<String, dynamic> T2) {
  String T(String k, String fb) => config != null ? termOf(config, k, fb) : fb;
  final coord = _find(db['tzCoordinators'], (c) => (c as Map)['id'] == coordinatorId);
  final boxes = coordinatorBoxes(db['tzBoxes'], coordinatorId)
      .where((b) => (b as Map)['status'] == 'home' || b['status'] == 'office')
      .toList();
  final lines = <String>[
    (T2['k3'] as String) + (((coord as dynamic)?['name']) ?? '').toString(),
    '=' * 30,
  ];
  for (final b in boxes) {
    final bm = b as Map;
    final fam = _find(db['families'], (f) => (f as Map)['id'] == bm['famId']);
    final last = lastCollectionIso(b);
    final parts = <dynamic>[
      '#' + bm['num'].toString(),
      fam != null ? T('entity.familyOf', (T2['k5'] as String)) + ' ' + fam['name'].toString() : (T2['k6'] as String),
      fam != null ? [fam['address'], fam['city']].where(_truthy).join(', ') : '',
      ((fam as dynamic)?['phone']) ?? '',
      _truthy(last) ? (T2['k7'] as String) + last : (T2['k8'] as String),
    ];
    lines.add(parts.where(_truthy).join(' · '));
  }
  if (boxes.isEmpty) lines.add((T2['k9'] as String));
  return lines;
}
