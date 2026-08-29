// ⚛️ אטום-Dart (דרגת-חוזה) · colorHe
// תפקיד: תרגום token-צבע אנגלי לשם-צבע עברי (עם ברירת-מחדל = ה-token עצמו).
// מוצא: buildsmart/app_flutter/lib/logic/studio/diff_preview.dart:196-206 (‏_colorHe; חוק-4).
// אחים: אין — switch טהור, אפס שקע, אפס טיפוס-שכן.
// טוהר: dart:core בלבד.

/// token → שם-צבע עברי; token לא-מוכר ⇒ מוחזר כמות-שהוא. verbatim diff_preview.dart:196-206.
String colorHe(String token, {required String Function(String) term}) => switch (token) {
      'success' => term('yrvk'),
      'danger' => term('advm'),
      'warn' => term('ktvm'),
      'muted' => term('apvr'),
      'ink' => term('khh'),
      'brand' => term('mvtg'),
      'brandDark' => term('mvtg-khh'),
      _ => token,
    };
