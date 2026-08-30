// ⚛️ אטום-Dart (דרגת-חוזה) · pushAuditRing — דחיפת טבעת-הלוג של המחובר למסמכו
// (auditlog/{uid}) באוסף הסקופי. auditUid ריק (לא-מחובר) ⇒ יציאה שקטה, אפס-ענן.
// מוצא: maor/src/lib/cloud.ts:149-157 → new/atoms/push-audit-ring.mjs (חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS, לא-משופרת). auditUid/db/scopedCol/fs/
//        encryptDoc הוזרקו כשקעים (חוק-1 — אפס import פנימי); AUDIT_CAP=500 הוטמע.
// טוהר: פונקציית top-level אסינכרונית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: !auditUid ⇒ יציאה. אחרת ring = 500 הרשומות האחרונות (slice(-500)); dek
//        קיים ⇒ encryptDoc({entries:ring}, dek), אחרת {entries:ring} כפשוטו;
//        setDoc(doc(db, scopedCol('auditlog'), auditUid), body).
// קלט:  entries · dek (CryptoKey|null) · auditUid · db · scopedCol · fs · encryptDoc.
// פלט:  Future<void>.
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//  • כלל-7 (truthiness): JS `if (!auditUid)` ו-`dek ? …` — falsy מחקה ב-`_falsy`.
//    auditUid הוא string|undefined; '' ⇒ falsy ⇒ יציאה שקטה (זהה למקור). dek הוא
//    CryptoKey|null; null ⇒ falsy ⇒ plaintext, אחרת הצפנה (זהה למקור).
//  • `entries.slice(-AUDIT_CAP)` של JS: מחזיר עותק; אורך ≤ AUDIT_CAP ⇒ הכל, אחרת
//    500 האחרונות. `entries.sublist(0)` = עותק-מלא (slice(0)); שלילי זורק ב-Dart ⇒
//    חישוב-אינדקס מפורש `entries.length - AUDIT_CAP` (הטיוטה `sublist(-AUDIT_CAP)` שגויה).
//  • זהות-האובייקט: המקור בונה literal יחיד `{entries:ring}` שנמסר ל-encryptDoc
//    ומוחזר בתוך המעטפה (`of`) — משמר בשקע-Dart ע"י payload יחיד המשותף לשני הענפים.
//  • fs/encryptDoc/scopedCol = שקעים dynamic (מקביל להיעדר-טיפוס של JS):
//    fs.doc(...) / fs.setDoc(...) / scopedCol(...) / encryptDoc(...) — dispatch-דינמי;
//    await נאמן לסמנטיקת JS await (Future או ערך-מיידי).

/// כפייה-לבוליאני נאמנה ל-JS `!x` / `x ?`: null/false/0/NaN/'' ⇒ true (falsy).

/// ‏truthiness של JS (חוק 7): '' / 0 / -0 / NaN / null / false כוזבים. (הוזרק ע"י מתקן-ההסגר)
bool _rqTruthy(dynamic v) =>
    !(v == null || v == false || v == '' || (v is num && (v == 0 || v.isNaN)));

bool _falsy(Object? v) {
  if (v == null) return true;
  if (v is bool) return !v;
  if (v is num) return v == 0 || v.isNaN;
  if (v is String) return v.isEmpty;
  return false; // Map / List / כל אובייקט = truthy במקור-ה-JS
}

const int _auditCap = 500;

/// Push the connected user's audit-log ring to their scoped `auditlog/{uid}`
/// document. An empty `auditUid` (not connected) returns immediately with zero
/// cloud calls. The ring is trimmed to the last 500 entries; when a `dek` is
/// present the body is encrypted first. Verbatim behaviour of the JS source
/// new/atoms/push-audit-ring.mjs.
Future<void> pushAuditRing(
  dynamic entries,
  dynamic dek,
  dynamic auditUid,
  dynamic db,
  dynamic scopedCol,
  dynamic fs,
  dynamic encryptDoc,
) async {
  if (_falsy(auditUid)) return;
  final ring = _rqTruthy(entries.length <= _auditCap)
      ? entries.sublist(0)
      : entries.sublist(entries.length - _auditCap);
  final payload = {'entries': ring};
  final body = _falsy(dek) ? payload : await encryptDoc(payload, dek);
  await fs.setDoc(fs.doc(db, scopedCol('auditlog'), auditUid), body);
}
