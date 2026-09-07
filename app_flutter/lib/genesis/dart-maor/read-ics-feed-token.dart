// ⚛️ אטום-Dart (דרגת-חוזה) · readIcsFeedToken — קריאת ה-token של פיד-היומן
//    (icsFeeds/{slug}) מהענן, כדי שרענון-פיד ישמור token קיים במקום להנפיק חדש.
// מוצא: maor/src/lib/icsFeed.ts:24-29 → new/atoms/read-ics-feed-token.mjs
//        (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת). cloudDb + ערכת-Firestore
//        (doc/getDoc) הוזרקו כשקעים (חוק-1/6 — אפס import פנימי, אפס זהות).
// טוהר: פונקציית top-level אסינכרונית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: מחזיר token תקין (מחרוזת לא-ריקה) ממסמך-הפיד; כל השאר ⇒ null.
//        שגיאות-ענן מבעבעות (אין try/catch במקור).
// קלט:  slug · 3 שקעים (db · doc · getDoc). פלט: Future<String?>.
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//  • truthiness (כלל 7): JS `d && typeof d.token === 'string' && d.token` —
//    d חייב להיות אובייקט-קיים, token חייב להיות מחרוזת **לא-ריקה** (''=falsy).
//    ב-Dart במפורש: `d != null && t is String && t.isNotEmpty`.
//    ⚠️ טיוטת-המנוע השאירה `d.token` חשוף (בלי בדיקת-ריקות) — תוקן.
//  • snap.exists() ⇒ bool; `exists() ? data() : null` נשמר כלשונו.
//  • data() של Firestore = מפת-שדות ⇒ Map<String,dynamic>?; גישה d['token'].
//  • השקע getDoc זורק ⇒ ה-await מבעבע (אין catch) — זהה לדחיית-Promise.

typedef DocFn = dynamic Function(dynamic db, String col, String id);
typedef GetDocFn = Future<dynamic> Function(dynamic ref);

/// Read the existing ics-feed token for [slug] from the cloud feed document
/// icsFeeds/{slug}. Valid = non-empty string; anything else ⇒ null. Errors
/// bubble. Verbatim behaviour of new/atoms/read-ics-feed-token.mjs.
Future<String?> readIcsFeedToken(
  String slug,
  dynamic db,
  DocFn doc,
  GetDocFn getDoc,
) async {
  final dynamic snap = await getDoc(doc(db, 'icsFeeds', slug));
  final Map<String, dynamic>? d =
      snap.exists() == true ? (snap.data() as Map<String, dynamic>?) : null;
  final dynamic t = d == null ? null : d['token'];
  return (t is String && t.isNotEmpty) ? t : null;
}
