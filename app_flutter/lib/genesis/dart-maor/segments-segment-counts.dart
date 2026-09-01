// ⚛️ אטום-Dart (דרגת-חוזה) · segmentCounts — מונה-חי ל-5 סגמנטים של תורמים.
// מוצא: maor-system/src/components/supporters/segments.ts:86 · המקור: new/atoms/segments-segment-counts.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import-אטום (dart:core בלבד). חוק-4 — זהה-ביט למקור-JS.
//        עוזרים/דאטה-פרטיים (SEGMENTS · totalIls · הספים GOLD_ILS/GOLD_SILENT) מוטבעים inline.
//        שקעים (חוק-1/3, הוזרקו כפרמטרים): cockpitAtRisk (אח) · supIls/supUsd/supLast (Genesis) · daysSince (אח).
//
// הערות-המרה (JS→Dart):
//  • תומך = Map (אובייקט-JS); `sp.email` ⇒ `sp['email']`, `sp.hok?.active` ⇒ בדיקת-null+גישה.
//  • `!sp.email` (falsy: '' או חסר) ⇒ `sp['email'] == null || sp['email'] == ''`.
//  • `sp.hok?.active === true` ⇒ `sp['hok'] is Map && sp['hok']['active'] == true` (strict-true).
//  • `!!last && daysSince(last) <= 365` ⇒ `last != null && last != '' && daysSince(...) <= 365`.
//  • daysSince מחזיר Infinity על ריק ⇒ `<= 365` / `>= 60` על double.infinity = false, זהה-JS.
//  • `.reduce((n,sp)=>n + (match?1:0), 0)` ⇒ `.fold<int>(0, ...)`.
//  • rate=3.7 (ברירת-מחדל אמצעית ב-JS) ⇒ פרמטר named עם default (מגבלת-Dart: אין optional-positional+named).

/// Live counts for the 5 donor segments. 'atrisk' delegates to the injected
/// [cockpitAtRisk] (single source of truth); the rest count via predicates.
/// Verbatim port of segments-segment-counts.mjs (`segmentCounts`).
List<Map<String, dynamic>> segmentCounts(
  List supporters,
  String todayIso, {required String Function(String) term, 
  dynamic rate = 3.7,
  required List Function(List, String) cockpitAtRisk,
  required num Function(dynamic) supIls,
  required num Function(dynamic) supUsd,
  required dynamic Function(dynamic) supLast,
  required num Function(dynamic, String) daysSince,
}) {
  const goldIls = 5000, goldSilent = 60;
  num totalIls(dynamic sp) => supIls(sp) + supUsd(sp) * (rate as num);
  final segments = <Map<String, dynamic>>[
    {
      'key': 'atrisk',
      'label': term('bsykvn-ntyshh'),
      'dot': '#b45309',
      'match': (dynamic sp) => false,
    },
    {
      'key': 'goldsilent',
      'label': term('zhb-shktym-yvm'),
      'dot': '#a05008',
      'match': (dynamic sp) =>
          totalIls(sp) >= goldIls &&
          daysSince(supLast(sp), todayIso) >= goldSilent,
    },
    {
      'key': 'hok',
      'label': term('hvk-paylvt'),
      'dot': '#2e7d32',
      'match': (dynamic sp) =>
          sp['hok'] is Map && sp['hok']['active'] == true,
    },
    {
      'key': 'gave12m',
      'label': term('trmv-b-hchvdshym'),
      'dot': '#1d4ed8',
      'match': (dynamic sp) {
        final last = supLast(sp);
        return last != null &&
            last != '' &&
            daysSince(last, todayIso) <= 365;
      },
    },
    {
      'key': 'noemail',
      'label': term('lla-aymyyl'),
      'dot': '#8a8172',
      'match': (dynamic sp) => sp['email'] == null || sp['email'] == '',
    },
  ];
  final atRiskCount = cockpitAtRisk(supporters, todayIso).length;
  return segments.map((seg) {
    final match = seg['match'] as bool Function(dynamic);
    return <String, dynamic>{
      'key': seg['key'],
      'label': seg['label'],
      'dot': seg['dot'],
      'count': seg['key'] == 'atrisk'
          ? atRiskCount
          : supporters.fold<int>(0, (n, sp) => n + (match(sp) ? 1 : 0)),
    };
  }).toList();
}
