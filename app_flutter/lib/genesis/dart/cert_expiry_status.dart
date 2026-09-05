// ⚛️ אטום-Dart (דרגת-חוזה) · certExpiryStatus
// מוצא: buildsmart/app_flutter/lib/state/worker_certs.dart:64-72
//        (‏WorkerCert.statusAt — הכלל ש-courier_certs_screen.dart:627 ו-:50
//         נשענים עליו: מיון-לפי-תפוגה + באדג׳ הרמזור פג/פג-בקרוב/בתוקף).
//        חוק-4 — התנהגות verbatim, לא-משופרת.
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק dart:core — DateTime).
//
// שקעים שהוזרקו (שעון ⇒ פרמטר-שקע · חוק-6, דיבר-8):
//   • DateTime.now() (הנקרא ב-courier_certs_screen.dart:627 ← statusAt) ⇒ שקע
//     `now`. שעון אסור באטום — המחשב-הקורא מזריק את הרגע.
//   • שדה-המחלקה WorkerCert.expiry ⇒ פרמטר `expiry` ישיר (תאריך-תפוגה).
//
// קלט:  expiry — DateTime, תאריך-תפוגת-התעודה (סמנטיקת יום-לוח).
//       now    — שקע-שעון: הרגע-הנוכחי.
// פלט:  CertExpiryStatus — expired / expiringSoon / valid.

/// סטטוס-הרמזור של תפוגת-תעודה (worker_certs.dart:23).
enum CertExpiryStatus { expired, expiringSoon, valid }

/// אדום=פג · צהוב=פג בתוך 31 יום · אחרת ירוק — verbatim של worker_certs.dart:64-72.
/// ההשוואה ביום-לוח בלבד (מנרמל את שני-הצדדים לחצות).
CertExpiryStatus certExpiryStatus(DateTime expiry, {required DateTime now}) {
  final today = DateTime(now.year, now.month, now.day);
  final exp = DateTime(expiry.year, expiry.month, expiry.day);
  if (exp.isBefore(today)) return CertExpiryStatus.expired;
  if (exp.difference(today).inDays <= 31) {
    return CertExpiryStatus.expiringSoon;
  }
  return CertExpiryStatus.valid;
}
