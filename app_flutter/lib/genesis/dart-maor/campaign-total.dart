// ⚛️ אטום-Dart (דרגת-חוזה) · campaignTotal — סכום איסופי-קמפיין על-פני כל הקופות.
// מוצא: maor/src/components/tzedaka/lib.ts:68-73 (מודול קופות-הצדקה) · המקור:
//        new/atoms/campaign-total.mjs (חוזה: campaign-total.contract.md).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מריצים על כל קופה (box) ועל כל איסוף (collection) שבה; מסכמים את
//        c.amount של האיסופים ששייכים ל-campaignId המבוקש. לא-סופי מדולג (מוסיף 0).
// שקעים (חוק-1): boxes — רשימת-קופות (כל אחת עם collections) · campaignId — מזהה-הקמפיין.
// קלט: השקעים. פלט: הסכום (num). ריק/לא-קיים ⇒ 0.
//
// הערות-המרה (מקור→Dart), מה שהמנוע פספס:
//  • Number.isFinite(c.amount) → `_isFinite` (num && isFinite) — ב-JS false לכל לא-מספר/NaN/∞,
//    לכן ב-Dart בודקים `x is num && x.isFinite`. המנוע קרא ל-`_isFinite` בלי להגדירו.
//  • גישת-שדה JS (b.collections / c.campaignId / c.amount) → גישת-Map (b['collections'] …),
//    כי מבני-הנתונים בבדיקה הם Map (המנוע השאיר גישת-נקודה שאינה חוקית ל-Map ב-Dart).
//  • `let sum = 0` → `num sum = 0` (מוטביליות var/final: sum משתנה ⇒ נשאר mutable, מוטבע num).
//  • `===` על מחרוזות → `==` ב-Dart (מחרוזות: שוויון-ערך, זהה לסמנטיקת === של JS על strings).

/// Number.isFinite של JS: false לכל לא-מספר, NaN ו-∞ (בלי המרה).
bool _isFinite(dynamic x) => x is num && x.isFinite;

/// Sums `amount` across every collection (over all boxes) whose `campaignId`
/// matches. Non-finite amounts are skipped (contribute 0). Verbatim behaviour of
/// the JS source `campaignTotal`.
num campaignTotal(dynamic boxes, dynamic campaignId) {
  num sum = 0;
  for (final b in boxes as Iterable) {
    for (final c in (b as Map)['collections'] as Iterable) {
      if ((c as Map)['campaignId'] == campaignId) {
        sum += _isFinite(c['amount']) ? c['amount'] as num : 0;
      }
    }
  }
  return sum;
}
