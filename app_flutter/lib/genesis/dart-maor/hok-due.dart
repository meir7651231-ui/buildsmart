// ⚛️ אטום-Dart (דרגת-חוזה) · hokDue — תור-ההו"ק הממתין לחודש:
// מסונן (פעיל-אפקטיבית וטרם-נרשם) וממוין לפי יום-חיוב (hok.day; חסר ⇒ 0 ⇒ ראשון).
// מוצא: maor/src/components/supporters/lib.ts:726-730 · המקור: new/atoms/hok-due.mjs
// חוזה: new/atoms/hok-due.contract.md · טוהר: פונקציית top-level, אפס import (dart-core).
// חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// שקעים (חוק-1, הוזרקו כפרמטרים במקום קריאות-שכן):
//   hokEffectivelyActive : (sp, todayIso) ⇒ bool (הו"ק-סליקה שפגה לא נספרת).
//   hokRecordedThisMonth : (sp, todayIso) ⇒ bool (חיוב-החודש כבר נרשם).
//
// הערות-המרה (מקור→Dart · DART-PORTING-RULES):
//  · אובייקטי-JS (sp, hok) ⇒ Map<String, Object?>; גישת-שדה sp.hok?.day ⇒ _day.
//  · `a.hok?.day ?? 0` — hok חסר/null או day חסר/null ⇒ 0 (כלל-2, null≠undefined:
//    בודקים סוג ולא נוכחות; day שאינו-מספר נופל ל-0 בדיוק כמו `?? 0` על undefined).
//  · מיון-יציב (כלל-1): JS `.sort` יציב, Dart `List.sort` אינו-יציב ל-≥32 ⇒
//    decorate-sort-undecorate עם אינדקס-מקורי כשובר-שוויון (יומי-חיוב שווים
//    שומרים סדר-קלט — סמנטיקת-JS).
//  · אי-מוטביליות (דוגמה 5): `.where().toList()` יוצר עותק חדש; המיון על העותק,
//    מערך-הקלט לא נוגע (filter-יוצר-עותק במקור).

/// יום-החיוב של תומך: `sp.hok?.day ?? 0` — hok/day חסר או לא-מספר ⇒ 0.
num _day(Map<String, Object?> sp) {
  final hok = sp['hok'];
  if (hok is Map) {
    final d = hok['day'];
    if (d is num) return d;
  }
  return 0;
}

/// Returns supporters whose standing-order for this month is still pending —
/// effectively-active and not-yet-recorded — sorted ascending by billing day.
/// Verbatim behaviour of the JS source `hokDue`. Input list is never mutated.
List<Map<String, Object?>> hokDue(
  List<Map<String, Object?>> supporters,
  String todayIso,
  bool Function(Map<String, Object?>, String) hokEffectivelyActive,
  bool Function(Map<String, Object?>, String) hokRecordedThisMonth,
) {
  final filtered = supporters
      .where((sp) =>
          hokEffectivelyActive(sp, todayIso) &&
          !hokRecordedThisMonth(sp, todayIso))
      .toList();

  final indexed = <MapEntry<int, Map<String, Object?>>>[
    for (var i = 0; i < filtered.length; i++) MapEntry(i, filtered[i])
  ];
  indexed.sort((a, b) {
    final c = _day(a.value).compareTo(_day(b.value));
    return c != 0 ? c : a.key.compareTo(b.key);
  });
  return [for (final e in indexed) e.value];
}
