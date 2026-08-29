// ⚛️ אטום-Dart (דרגת-חוזה) · matchSegment — פרדיקט-סגמנט בודד לתומך.
// מוצא: maor-system/src/components/supporters/segments.ts:104 · המקור: new/atoms/segments-match-segment.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import-אטום (dart:core בלבד). חוק-4 — זהה-ביט למקור-JS.
//        עוזרים/דאטה-פרטיים (SEGMENTS · totalIls · הספים) מוטבעים inline; שקעים = כמו segment-counts.
//
// הערות-המרה (JS→Dart):
//  • 'atrisk' עוטף cockpitAtRisk: `.some((s)=>s.id===sp.id)` ⇒ `.any((s)=>s['id']==sp['id'])`.
//  • `SEGMENTS.find((s)=>s.key===key)` ⇒ `firstWhere` עם `orElse` שמחזיר null ⇒ `def ? match : false`.
//  • שאר ההמרות זהות ל-segment-counts (Map · falsy-email · hok?.active===true · daysSince-Infinity).

/// Single-segment predicate for a supporter. 'atrisk' wraps the injected
/// [cockpitAtRisk]; the rest evaluate inline. Verbatim port of
/// new/atoms/segments-match-segment.mjs (`matchSegment`).
bool matchSegment(
  dynamic sp,
  String key,
  List supporters,
  String todayIso, {
  dynamic rate = 3.7,
  required List Function(List, String) cockpitAtRisk,
  required num Function(dynamic) supIls,
  required num Function(dynamic) supUsd,
  required dynamic Function(dynamic) supLast,
  required num Function(dynamic, String) daysSince,
}) {
  const goldIls = 5000, goldSilent = 60;
  num totalIls(dynamic s) => supIls(s) + supUsd(s) * (rate as num);
  final segments = <Map<String, dynamic>>[
    {'key': 'atrisk', 'match': (dynamic s) => false},
    {
      'key': 'goldsilent',
      'match': (dynamic s) =>
          totalIls(s) >= goldIls &&
          daysSince(supLast(s), todayIso) >= goldSilent,
    },
    {
      'key': 'hok',
      'match': (dynamic s) => s['hok'] is Map && s['hok']['active'] == true,
    },
    {
      'key': 'gave12m',
      'match': (dynamic s) {
        final last = supLast(s);
        return last != null && last != '' && daysSince(last, todayIso) <= 365;
      },
    },
    {'key': 'noemail', 'match': (dynamic s) => s['email'] == null || s['email'] == ''},
  ];
  if (key == 'atrisk') {
    return cockpitAtRisk(supporters, todayIso).any((s) => s['id'] == sp['id']);
  }
  Map<String, dynamic>? def;
  for (final s in segments) {
    if (s['key'] == key) {
      def = s;
      break;
    }
  }
  return def != null ? (def['match'] as bool Function(dynamic))(sp) : false;
}
