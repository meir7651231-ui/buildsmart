// ⚛️ אטום-Dart (דרגת-חוזה) · isBrightImage
// מוצא: buildsmart/app_flutter/lib/features/catalog_config/image_quality.dart:83-93 (חצב-בינה · חוק-3/4).
// שקע: imageBrightness ← השכן `imageBrightness(assetPath)` — בהירות 0-255 (‏-1 = אין תמונה).
// מוטבע verbatim (ערך-נתונים, כלל-1): הקבוע kDarkFloor (image_quality.dart:63).

const int kDarkFloor = 100;

bool isBrightImage(String? assetPath,
        {required int Function(String?) imageBrightness}) =>
    imageBrightness(assetPath) >= kDarkFloor;
