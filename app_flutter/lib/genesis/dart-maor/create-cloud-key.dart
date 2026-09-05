// ⚛️ אטום-Dart (דרגת-חוזה) · createCloudKey — יצירת envelope-מפתח לענן + DEK חי.
// מוצא: maor/src/lib/cloudCrypto.ts:64-71 → new/atoms/create-cloud-key.mjs
//        (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת). השכנים encryptDb/openDek
//        הוזרקו כשקעים (חוק-1 — אפס import פנימי).
// טוהר: פונקציית top-level אסינכרונית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: מצפין envelope ריק עם הסיסמה+מפתח-שחזור, פותח ממנו DEK; DEK ריק/null ⇒ זריקה.
//        הסדר בלבד — encryptDb ואז openDek ואז שער-ה-null.
// קלט:  password · recoveryKey · 2 שקעים (encryptDb · openDek).
// פלט:  Future<Map> {env, dek}; DEK falsy ⇒ זריקת שגיאה בעברית (StateError בעל message).
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//  • truthiness (כלל 7): JS `if (!dek)` — null/undefined/''/0/false נחשבים falsy;
//    ב-Dart שקע-`_falsy` מפורש (במקור ה-DEK הוא ערך-אטום/מחרוזת, אך נשמר ביט-זהה).
//  • Error של JS ⇒ StateError של Dart (נושא `message` לצורך רתמת-הזהב).
//  • שגיאת encryptDb/openDek מבעבעת כלשונה (אין catch) — כמו במקור-ה-JS.

typedef EncryptDb = dynamic Function(
    String json, dynamic password, dynamic recoveryKey);
typedef OpenDek = dynamic Function(dynamic env, dynamic secret, String via);

bool _falsy(Object? v) {
  if (v == null) return true;
  if (v is bool) return !v;
  if (v is num) return v == 0 || v.isNaN;
  if (v is String) return v.isEmpty;
  return false;
}

/// Build a cloud-key envelope and open a live DEK from it: encrypt an empty
/// payload with the password + recovery key, then open the DEK. A falsy DEK
/// throws a Hebrew error. Verbatim behaviour of the JS source
/// new/atoms/create-cloud-key.mjs.
Future<Map<String, dynamic>> createCloudKey(dynamic password,
  dynamic recoveryKey,
  EncryptDb encryptDb,
  OpenDek openDek, Map<String, String> T) async {
  final env = await encryptDb('', password, recoveryKey);
  final dek = await openDek(env, password, 'pass');
  if (_falsy(dek)) throw StateError(T['k2']!);
  return {'env': env, 'dek': dek};
}
