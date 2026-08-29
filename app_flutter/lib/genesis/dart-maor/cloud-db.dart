// ⚛️ אטום-Dart (דרגת-חוזה) · cloudDb — שער-ידית Firestore: מחזיר את הידית או
// זורק בעברית כשהענן לא אותחל.
// מוצא: maor/src/lib/cloud.ts:266-275 (cloudDb + העוזר הפרטי requireDb אוחד פנימה)
//        · המקור: new/atoms/cloud-db.mjs. משתנה-המודול fsDb הוזרק כשקע-קלט
//        (חוק-1 — אפס import פנימי; חוק-6 — החזקת-הידית = חיווט-הצבה של הקופסה).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). המנוע-האוטומטי לא הפיק טיוטה ⇒ פורט ידני.
//
// תפקיד: fsDb אמיתי ⇒ מחזיר אותו (זהות-הפניה); fsDb falsy ⇒ זורק עברית מדויקת.
// קלט:  fsDb — ידית-Firestore (שקע-הצבה) או כל ערך falsy.
// פלט:  הידית עצמה (===) · falsy ⇒ StateError בעל message עברי מדויק.
//
// הערת-המרה (מקור→Dart, DART-PORTING-RULES כלל-7 · truthiness):
//   • JS `if (!fsDb)` — null/undefined/false/0/NaN/'' נחשבים falsy ⇒ זורק.
//     ב-Dart אין `!obj` על Object? ⇒ שקע `_falsy` מפורש שמחקה בדיוק את `!x` של JS.
//   • Error של JS ⇒ StateError של Dart (נושא `message` לצורך רתמת-הזהב).

/// כפייה-לבוליאני נאמנה ל-JS `!x`: null/false/0/NaN/'' ⇒ true (falsy), השאר false.
bool _falsy(Object? v) {
  if (v == null) return true;
  if (v is bool) return !v;
  if (v is num) return v == 0 || v.isNaN;
  if (v is String) return v.isEmpty;
  return false; // Map / List / כל אובייקט = truthy במקור-ה-JS
}

/// שער-ידית Firestore. פורט מילולי של new/atoms/cloud-db.mjs (`cloudDb`):
/// ידית אמיתית ⇒ מוחזרת כמות-שהיא; falsy ⇒ זריקת שגיאה בעברית.
Object cloudDb(Object? fsDb) {
  if (_falsy(fsDb)) {
    throw StateError('הענן לא אותחל — פנו למנהל המערכת');
  }
  return fsDb!;
}
