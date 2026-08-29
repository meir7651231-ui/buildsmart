// ⚛️ אטום-Dart (דרגת-חוזה) · siteLangs — רשימת השפות שהאתר-הציבורי מציע.
// מוצא: maor/src/lib/publicSite.ts:191-197 · המקור: new/atoms/site-langs.mjs ·
//        חוזה: new/atoms/site-langs.contract.md.
// טוהר: פונקציה top-level עצמאית, אפס import (רק dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: ‏site.langs מסונן לשפות-מוכרות בלבד, בלי כפולים, בשימור-סדר;
//        אין אף שפה תקינה (ריק/חסר/הכול-סונן) ⇒ ברירת-המחדל ['he'].
// שקעים (חוק-1): ‏knownLangs — הקבוע-השכן SITE_LANGS הוזרק כפרמטר-נתונים.
//
// הערות-המרה (מקור→Dart):
//  • ‏site הוא אובייקט-JS ⇒ ב-Dart מתקבל כ-Map (או null); ‏`site?.langs`
//    ממומש כ-`site['langs']` על Map. חסר-מפתח ו-null-מפורש שניהם ⇒ null,
//    בדיוק כמו ‏`?.filter … ?? []` ב-JS (undefined וגם null ⇒ []) — כלל-2
//    אינו רלוונטי כאן כי שני המסלולים מתמזגים לאותה תוצאה ([]).
//  • ‏`[...new Set(raw)]` — ‏Set של JS משמר סדר-הכנסה (ראשון-מנצח); ‏Dart
//    ‏toSet() = LinkedHashSet ⇒ אותו סדר-הכנסה בדיוק. שוויון-מחרוזות זהה.
//  • ‏`uniq.length ? … : …` — truthiness של JS על מספר (0 ⇒ falsy) ממומש
//    כ-`isNotEmpty` המפורש (כלל-7).
//  • אין locale/תאריך/מודולו/המרת-מספר — אין צורך בשקעים נוספים.

/// רשימת-השפות של האתר-הציבורי: `site.langs` מסונן ל-[knownLangs],
/// בלי כפולים (ראשון-מנצח), בשימור-סדר; ריק ⇒ `['he']`.
/// Verbatim port של new/atoms/site-langs.mjs (`siteLangs`).
dynamic siteLangs(dynamic site, dynamic knownLangs) {
  // JS: const raw = site?.langs?.filter((l) => knownLangs.includes(l)) ?? [];
  final dynamic langs = (site is Map) ? site['langs'] : null;
  final List<dynamic> raw = (langs == null)
      ? <dynamic>[]
      : (langs as List)
          .where((l) => (knownLangs as List).contains(l))
          .toList();
  // JS: const uniq = [...new Set(raw)];  (סדר-הכנסה נשמר בשתי השפות)
  final List<dynamic> uniq = raw.toSet().toList();
  // JS: return uniq.length ? uniq : ['he'];
  return uniq.isNotEmpty ? uniq : <dynamic>['he'];
}
