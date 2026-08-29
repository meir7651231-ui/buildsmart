// ⚛️ אטום-Dart (דרגת-חוזה) · pullAuditRing — משיכת כל טבעות-הלוג מאוסף auditlog
// הסקופי ומיזוגן (מנהל/מייל-על בלבד). עובד/ת (canRead=false) ⇒ null מיד, אפס-ענן.
// מוצא: maor/src/lib/cloud.ts:158-174 → new/atoms/pull-audit-ring.mjs (חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS, לא-משופרת). auditReadable/db/scopedCol/fs/
//        decryptDoc הוזרקו כשקעים (חוק-1 — אפס import פנימי); AUDIT_CAP=500 הוטמע.
// טוהר: פונקציית top-level אסינכרונית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: canRead=false ⇒ null. אחרת getDocs(collection(db, scopedCol('auditlog'))),
//        כל doc.entries (רק כשהוא מערך) נשפך לרשימה אחת, ממוין עולה לפי at
//        (השוואת-מחרוזות ISO), נגזם ל-500 האחרונות. dek קיים ⇒ פענוח פר-מסמך.
// קלט:  dek (CryptoKey|null) · auditReadable · db · scopedCol · fs · decryptDoc.
// פלט:  Future<List|null>.
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//  • כלל-1 (מיון-יציב): JS `sort` יציב, Dart `List.sort` לא-יציב ל-≥32. הקומפרטור
//    מחזיר 0 על at-שווה ⇒ decorate-sort עם אינדקס-מקורי כשובר-שוויון (שימור-סדר).
//  • כלל-7 (truthiness): JS `if (!auditReadable)` ו-`dek ? …` — falsy מחקה ב-`_falsy`.
//    dek הוא CryptoKey|null; null ⇒ falsy ⇒ בלי-פענוח, אחרת פענוח (זהה למקור).
//  • גישת-תכונה `data.entries` של JS ⇒ חיפוש-מפה `data['entries']` ב-Dart. שים לב:
//    ל-Map של Dart יש getter מובנה בשם `entries` — לכן חובה גישת-מפתח, לא `.entries`,
//    אחרת נקרא ה-getter-של-השפה במקום מפתח-הנתונים. `Array.isArray` ⇒ `is List`.
//  • `all.slice(-AUDIT_CAP)` של JS: כשהאורך ≤ AUDIT_CAP מחזיר הכל; אחרת 500 האחרונות.
//    (הטיוטה `all.sublist(-AUDIT_CAP)` שגויה — sublist שלילי זורק ב-Dart.)
//  • השוואת at: JS `<`/`>` על מחרוזות = לקסיקוגרפי לפי code-unit; Dart `compareTo`
//    זהה. הקומפרטור מוחזר לסימן {-1,0,1} כמו המקור.
//  • fs/doc/scopedCol/decryptDoc = שקעים dynamic (מקביל להיעדר-טיפוס של JS):
//    fs.getDocs / fs.collection / doc.data() / scopedCol(...) / decryptDoc(...)
//    כולם dispatch-דינמי; await נאמן לסמנטיקת JS await (Future או ערך-מיידי).

/// כפייה-לבוליאני נאמנה ל-JS `!x` / `x ?`: null/false/0/NaN/'' ⇒ true (falsy).
bool _falsy(Object? v) {
  if (v == null) return true;
  if (v is bool) return !v;
  if (v is num) return v == 0 || v.isNaN;
  if (v is String) return v.isEmpty;
  return false; // Map / List / כל אובייקט = truthy במקור-ה-JS
}

const int _auditCap = 500;

/// Pull every audit-log ring from the scoped `auditlog` collection and merge
/// them (manager / super-admin only). A non-readable context (worker) returns
/// null immediately with zero cloud calls. Merged entries are sorted ascending
/// by `at` and trimmed to the last 500. Verbatim behaviour of the JS source
/// new/atoms/pull-audit-ring.mjs.
Future<List<dynamic>?> pullAuditRing(
  dynamic dek,
  dynamic auditReadable,
  dynamic db,
  dynamic scopedCol,
  dynamic fs,
  dynamic decryptDoc,
) async {
  if (_falsy(auditReadable)) return null;
  final snap = await fs.getDocs(fs.collection(db, scopedCol('auditlog')));
  final all = <dynamic>[];
  for (final doc in snap.docs) {
    final data = _falsy(dek) ? doc.data() : await decryptDoc(doc.data(), dek);
    final entries = data['entries'];
    if (entries is List) all.addAll(entries);
  }
  // מיון-יציב (כלל-1): decorate עם אינדקס-מקורי, כדי לשמר את סדר-ההוספה על at-שווה.
  final indexed = <List<dynamic>>[];
  for (var i = 0; i < all.length; i++) {
    indexed.add(<dynamic>[all[i], i]);
  }
  indexed.sort((x, y) {
    final a = x[0]['at'];
    final b = y[0]['at'];
    final c = (a as String).compareTo(b as String);
    final byAt = c < 0 ? -1 : (c > 0 ? 1 : 0);
    if (byAt != 0) return byAt;
    return (x[1] as int).compareTo(y[1] as int);
  });
  final sorted = <dynamic>[for (final pair in indexed) pair[0]];
  if (sorted.length <= _auditCap) return sorted;
  return sorted.sublist(sorted.length - _auditCap);
}
