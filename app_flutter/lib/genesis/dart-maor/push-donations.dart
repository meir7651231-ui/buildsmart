// ⚛️ אטום-Dart (דרגת-חוזה) · pushDonations — דחיפת diff אוסף-התרומות (מסלול-B) באצוות ≤400.
// מוצא: maor/src/lib/cloud.ts:175-200 (תורגם TS→JS) · המקור: new/atoms/push-donations.mjs —
//        `export async function pushDonations(diff, dek, db, scopedDonations, fs, encryptDoc) { ... }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-1 — כל
//        השכנים שקעים (db · scopedDonations · fs=ערכת-Firestore doc/writeBatch · encryptDoc).
//        חוק-4 — התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: בונה רשימת-פעולות (set לכל d ב-diff.sets, delete לכל id ב-diff.deletes),
//        ואז דוחף אותן באצוות של ≤400 (writeBatch → פעולות → commit לפני האצווה הבאה).
//        pkey נשמר plaintext מחוץ למעטפה (where-pkey-in + Rules יעבדו גם בארגון-מוצפן).
// קלט:  diff ({sets:[{id,supporterId,pkey,donation}], deletes:[id]}) · dek (מפתח|null) ·
//        db · scopedDonations (()->String) · fs (doc/writeBatch) · encryptDoc ((payload,dek)->Future<Map>).
// פלט:  Future<void> — תופעות-לוואי דרך שקעי-ה-fs בלבד.
//
// הערות-המרה (מקור→Dart):
//  • שקעים דינמיים: fs.doc/fs.writeBatch/batch.set/delete/commit נקראים על `dynamic`
//    (dispatch בזמן-ריצה) ⇒ אין תלות בטיפוסי-Firestore הקונקרטיים.
//  • סדר-מפתחות: `{pkey, ...payload}` ב-JS ⇒ pkey ראשון. ‏Dart-Map (LinkedHashMap)
//    שומר סדר-הכנסה ⇒ `{'pkey': ..., ...payload}` שומר pkey כשדה-ראשון (כלל-החוזה).
//  • ה-spread `{supporterId, ...donation}` ⇒ `{'supporterId': ..., ...donation}`.
//  • truthiness (כלל-המרה 7): המקור `dek ? …` — משתקף ב-`_truthy(dek)` (null/''/0/false/NaN=falsy),
//    לא `dek != null` בלבד, כדי לשקף את סמנטיקת-ה-JS במדויק.
//  • חיתוך-אצווה: `ops.slice(i, i+400)` ⇒ לולאה עם קצה `min(i+400, length)`
//    (אין substring-שלילי; slice סלחן לקצה-חורג — כלל-המרה 5).
//  • מוטביליות: `ops` בונה חד-פעמי; `i`/`batch` מקומיים — כמו במקור.

/// Truthiness matching JS `dek ? …`: null / false / 0 / '' / NaN are falsy.
bool _truthy(dynamic v) =>
    !(v == null || v == false || v == 0 || v == '' || (v is num && v.isNaN));

/// Pushes the donation-collection diff (route-B) in batches of ≤400.
/// Verbatim behaviour of the JS source new/atoms/push-donations.mjs (`pushDonations`).
/// All neighbours are injected sockets (law-1); side-effects flow only through [fs].
Future<void> pushDonations(
  Map diff,
  dynamic dek,
  dynamic db,
  String Function() scopedDonations,
  dynamic fs,
  Future<Map> Function(Map, dynamic)? encryptDoc,
) async {
  final List<void Function(dynamic)> ops = [];
  for (final d in (diff['sets'] as List)) {
    // pkey נשמר plaintext (מחוץ למעטפה) כדי ש-where-pkey-in + Rules יעבדו גם בארגון-מוצפן.
    final Map payload = {'supporterId': d['supporterId'], ...(d['donation'] as Map)};
    final Map body = _truthy(dek)
        ? {'pkey': d['pkey'], ...(await encryptDoc!(payload, dek))}
        : {'pkey': d['pkey'], ...payload};
    ops.add((b) => b.set(fs.doc(db, scopedDonations(), d['id']), body));
  }
  for (final id in (diff['deletes'] as List)) {
    ops.add((b) => b.delete(fs.doc(db, scopedDonations(), id)));
  }
  for (var i = 0; i < ops.length; i += 400) {
    final batch = fs.writeBatch(db);
    final int end = (i + 400 < ops.length) ? i + 400 : ops.length;
    for (var j = i; j < end; j++) {
      ops[j](batch);
    }
    await batch.commit();
  }
}
