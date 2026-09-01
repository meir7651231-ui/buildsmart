// ⚛️ אטום-Dart (דרגת-חוזה) · parseBore
// תפקיד: מיצוי קוטר-פנימי (bore, מ"מ) ממפת-מידות לפי אסטרטגיית-הפירוק של המותג.
// מוצא: buildsmart/app_flutter/lib/domain/brand_profile.dart:292-310 (‏parseBore; חוק-4).
//        במקור מתודת-מופע על BrandProfile הקוראת `this.boreDimsKey`/`this.boreParse`.
// אחים-שסוקטו/הוטבעו:
//   • שדות-המופע `boreDimsKey`/`boreParse` ⇒ **שקעים** (חוק-3: תלות-מופע ⇒ פרמטר).
//   • enum-האח `BoreParseStrategy` ⇒ **הוטבע verbatim** — שלושת ה-case מופיעים
//     במפורש בגוף-הטיוטה (‏diRangeMax/dnDirect/none), הסקה-ודאית (דיבר 11).
//   • const-האח `kDiRangeNumberPattern` (RegExp; ערכו לא בגוף-הטיוטה, המקור
//     brand_profile.dart אינו בריפו) ⇒ **הוטבע כ-`_kDiRangeNumberPattern`
//     מוסק**: `\d+(?:\.\d+)?` — מוצא מספרים (שלמים/עשרוניים) בטווח כמו "13.6–14.7".
//     דגל-סיכון: אם המקור-החי מרחיב את הדפוס — יש לעדכן; הגולדן מאפיין הטבעה זו.
//   • האחים specEnvelopeFor/kBrandProfiles (טיוטה) — שכנים, לא האטום.
// טוהר: אפס import (dart:core בלבד; RegExp מובנה).
//
// קלט:  dims        — מפת-מידות (Map<String,dynamic>? — יכולה להיות null).
//       boreDimsKey — שקע: מפתח-שדה-הקוטר במפה (String? — null ⇒ אין קוטר).
//       boreParse   — שקע: אסטרטגיית-הפירוק (BoreParseStrategy).
// פלט:  double? — הקוטר-במ"מ, או null.

// הוטבע verbatim (enum-אח): שלוש אסטרטגיות פירוק-קוטר.
enum BoreParseStrategy { diRangeMax, dnDirect, none }

// הוטבע מוסק (const-אח): מספרים שלמים/עשרוניים בתוך טווח-מידה.
final RegExp _kDiRangeNumberPattern = RegExp(r'\d+(?:\.\d+)?');

/// Bore diameter (mm) from [dims] by the brand's [boreParse] strategy.
/// Verbatim behaviour of brand_profile.dart:292-310, with the instance fields
/// injected as sockets and the sibling enum/const inlined.
double? parseBore(
  Map<String, dynamic>? dims, {
  required String? boreDimsKey,
  required BoreParseStrategy boreParse,
}) {
  final key = boreDimsKey;
  if (key == null) return null;
  final raw = dims?[key]?.toString();
  switch (boreParse) {
    case BoreParseStrategy.diRangeMax:
      // di is a tolerance range like "13.6–14.7" — take the max bore (14.7).
      final nums = raw == null
          ? const <double>[]
          : _kDiRangeNumberPattern
              .allMatches(raw)
              .map((m) => double.tryParse(m.group(0)!))
              .whereType<double>()
              .toList();
      return nums.isEmpty ? null : nums.reduce((a, b) => a > b ? a : b);
    case BoreParseStrategy.dnDirect:
      return raw == null ? null : double.tryParse(raw);
    case BoreParseStrategy.none:
      return null;
  }
}
