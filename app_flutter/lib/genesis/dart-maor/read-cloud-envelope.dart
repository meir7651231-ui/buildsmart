// ⚛️ אטום-Dart (דרגת-חוזה) · readCloudEnvelope — קריאת מעטפת-ההצפנה מ-_enc/envelope,
// failure-safe מוחלט: כל שגיאה ⇒ null (הקורא ממשיך plaintext — לא שובר את הלקוח החי).
// מוצא: maor/src/lib/cloud.ts:458-470 · המקור: new/atoms/read-cloud-envelope.mjs.
//        requireDb⇒db · scopedEnv · ערכת-Firestore(getDoc/doc)⇒fs — כולם שקעים (חוק-1).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט
//        למקור-ה-JS (המקור קדוש). ⚠️ המנוע-האוטומטי לא הפיק טיוטה (dart-from-maor ריק) ⇒
//        פורט ידני מן המקור לפי DART-PORTING-RULES.
//
// תפקיד: doc(db, scopedEnv()) ⇒ getDoc ⇒ snap. לא-קיים ⇒ null. אחרת ולידציה רזה:
//        אובייקט עם $enc===2 מוחזר כמות-שהוא (זהות-הפניה); כל השאר ⇒ null.
// שקעים (חוק-1 — קריאות-החוץ הוזרקו כפרמטרים):
//   • db          — ידית-הענן (במקור: requireDb()); אטומה, מועברת כלשונה ל-doc.
//   • scopedEnv() ⇒ String — נתיב מסמך-המעטפה הסקופי-לארגון.
//   • fs          — ערכת-Firestore דינמית: fs.doc(db,path) ⇒ ref · fs.getDoc(ref) ⇒
//                   snap אסינכרוני עם snap.exists()/snap.data() (duck-typing כמו JS).
// קלט: השקעים בלבד. פלט: Future<Object? envelope|null>.
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//   • כלל-7 (truthiness): JS `if (!snap.exists())` — שקע `_falsy` מפורש שמחקה בדיוק `!x`.
//   • הפרדיקט `d && typeof d === 'object' && d.$enc === 2`: (א) d truthy ⇒ `!_falsy(d)`;
//     (ב) typeof-object ⇒ `d is Map || d is List` (Map/List = 'object' ב-JS; null כבר
//     נופל ב-(א)); (ג) גישה ל-`$enc` — רק Map נושאת מפתח, List/פרימיטיב ⇒ undefined!==2
//     ⇒ null (נאמן לכך שגישת-שדה על לא-Map מחזירה undefined). `== 2` שקול ל-`=== 2` של
//     JS על מספר (2.0==2, '2'!=2). זהות-ההפניה של d נשמרת (=== של JS ⇒ identical).
//   • fs/snap = dynamic (מקביל להיעדר-הטיפוס של JS); `await` על ערך-לא-Future עוטף כמו JS.
//   • catch-all בולע כל זריקה (כולל getDoc שנכשל) ⇒ null — ה-failure-safe של המקור.
//   • אין locale/פורמט/getMonth/מודולו-שלילי/substring/מיון שהמנוע היה יכול לפספס.

/// כפייה-לבוליאני נאמנה ל-JS `!x`: null/false/0/NaN/'' ⇒ true (falsy), השאר false.
bool _falsy(Object? v) {
  if (v == null) return true;
  if (v is bool) return !v;
  if (v is num) return v == 0 || v.isNaN;
  if (v is String) return v.isEmpty;
  return false; // Map / List / כל אובייקט = truthy במקור-ה-JS
}

/// קריאת מעטפת-ההצפנה מהענן. פורט מילולי של new/atoms/read-cloud-envelope.mjs:
/// מסמך-לא-קיים / פורמט-זר / כל שגיאה ⇒ null; מעטפה תקינה ($enc===2) ⇒ מוחזרת כמות-שהיא.
Future<Object?> readCloudEnvelope(
  Object? db,
  String Function() scopedEnv,
  dynamic fs,
) async {
  try {
    final snap = await fs.getDoc(fs.doc(db, scopedEnv()));
    if (_falsy(snap.exists())) return null; // JS: if (!snap.exists()) return null
    final d = snap.data();
    // d && typeof d === 'object' && d.$enc === 2 ? d : null
    if (!_falsy(d) && (d is Map || d is List)) {
      if (d is Map && d[r'$enc'] == 2) return d;
    }
    return null;
  } catch (_) {
    return null;
  }
}
