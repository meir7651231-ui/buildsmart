// ⚛️ אטום-Dart (דרגת-חוזה) · filterCollections — סינון היסטוריית-ריקוני-קופה.
// מוצא: maor/src/components/tzedaka/lib.ts:233-249 · המקור: new/atoms/filter-collections.mjs —
//   `box.collections.filter((c) => dateInRange(c.date, fromIso, toIso) && (!campaignId || c.campaignId === campaignId))`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: טווח-תאריכים כוללני (שני הקצוות בפנים; קצה ריק = בלי גבול) + מבצע
//        (campaignId ריק = כל המבצעים). הסדר המקורי נשמר; הקלט לא משתנה.
// שקע (חוק-1): dateInRange(iso, fromIso, toIso) ⇒ bool — הוזרק כפרמטר, אפס import פנימי.
//
// הערות-המרה (מקור→Dart, לפי DART-PORTING-RULES):
//  · truthiness (כלל 7): JS `!campaignId` אמת על מחרוזת-ריקה ⇒ Dart `campaignId.isEmpty`.
//  · `===` על מחרוזות ⇒ `==` ב-Dart (השוואת-ערך למחרוזות).
//  · מוטביליות: `.where().toList()` יוצר רשימה חדשה — box.collections לא נוגע בו.
//  · אין מיון ⇒ כלל יציבות-המיון לא רלוונטי; `.where` שומר סדר-מקור.

/// Filters a charity-box collection history by an inclusive ISO date range and an
/// optional campaign id. Verbatim behaviour of the JS source `filterCollections`.
/// `dateInRange` is the injected socket (Law 1 — no internal import).
List<Map<String, dynamic>> filterCollections(
  Map<String, dynamic> box,
  String fromIso,
  String toIso,
  String campaignId,
  bool Function(String iso, String fromIso, String toIso) dateInRange,
) {
  final collections = (box['collections'] as List).cast<Map<String, dynamic>>();
  return collections
      .where((c) =>
          dateInRange(c['date'] as String, fromIso, toIso) &&
          (campaignId.isEmpty || c['campaignId'] == campaignId))
      .toList();
}
