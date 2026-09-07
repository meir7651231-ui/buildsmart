// ⚛️ אטום-Dart (דרגת-חוזה) · siteDonateUrl — קישור-התרומה האפקטיבי של עמוד-השיווק.
// מוצא: maor/src/lib/publicSite.ts:247-254 · המקור: new/atoms/site-donate-url.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core). חוק-1 — אטום לא-מייבא
//        (העוזרים מוזרקים inline). חוק-4 — התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: site.donateUrl הישיר (רק מחרוזת לא-ריקה) גובר; נפילה ל-
//        integrations.payments.payUrl (רק מחרוזת לא-ריקה); אחרת null.
//
// 🔧 תיקון-הסגר (FIXES.md · "ריכוך-יתר על config=null"):
//   ‏JS: `config.site?.donateUrl` — ה-‎?.‎ הוא **אחרי** ‏.site, לכן `config.site`
//   עצמו אינו משורשר-אופציונלית. על config=null/undefined ⇒ JS זורק TypeError
//   ("Cannot read properties of null"). הפורט-השבור ריכך זאת ל-null דרך _get.
//   התיקון: גישות-העליונות (config.site / config.integrations) דרך **_getT**
//   הזורק — נאמן-JS: null/undefined ⇒ זריקה; פרימיטיב ⇒ null (≡undefined, בלי
//   זריקה); Map ⇒ הערך. הגישות המשורשרות (‎?.donateUrl / ?.payments) נשארות
//   דרך _get הרך (שרשור-אופציונלי אמיתי ⇒ null בלי זריקה).
//
// הערות-המרה (מקור→Dart):
//  • `typeof direct === 'string' && direct` → `direct is String && direct.isNotEmpty`
//    ('' falsy ב-JS ⇒ נפסל — דוגמה 2 בחוזה).
//  • `pay && typeof pay.payUrl === 'string'` → `_truthy(pay) && raw is String`.
//  • `payUrl || null` → payUrl תמיד String בנקודה זו ⇒ ריק=null, אחרת המחרוזת.
//  • פלט dynamic: String או null — כמו במקור.

/// גישת-שדה **זורקת** נאמנת-JS (גישה לא-משורשרת): null/undefined ⇒ TypeError
/// (כמו קריאת-שדה על null ב-JS); פרימיטיב אחר ⇒ null (≡undefined); Map ⇒ הערך.
dynamic _getT(dynamic obj, String key) {
  if (obj == null) {
    throw StateError("TypeError: Cannot read properties of null (reading '$key')");
  }
  return obj is Map ? obj[key] : null;
}

/// גישת-שדה **רכה** (שרשור-אופציונלי ‎?.‎): על לא-Map (כולל null) ⇒ null≡undefined.
dynamic _get(dynamic obj, String key) => obj is Map ? obj[key] : null;

/// truthiness של JS (כלל-7): null/false/0/-0/NaN/'' = falsy; כל השאר truthy.
bool _truthy(dynamic v) {
  if (v == null || v == false) return false;
  if (v is num) return !(v == 0 || v.isNaN);
  if (v is String) return v.isNotEmpty;
  return true;
}

/// The effective donation link of the public marketing page:
/// site.donateUrl (non-empty string only), falling back to
/// integrations.payments.payUrl (non-empty string only), else null.
/// Verbatim port of new/atoms/site-donate-url.mjs (`siteDonateUrl`).
dynamic siteDonateUrl(dynamic config) {
  final direct = _get(_getT(config, 'site'), 'donateUrl');
  if (direct is String && direct.isNotEmpty) return direct;
  final pay = _get(_getT(config, 'integrations'), 'payments');
  final raw = _get(pay, 'payUrl');
  final payUrl = _truthy(pay) && raw is String ? raw : '';
  return payUrl.isNotEmpty ? payUrl : null;
}
