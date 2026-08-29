// ⚛️ אטום-Dart · skuOf — חיפוש-מוצר O(1) לפי SKU עם מטמון בנוי-פעם-אחת.
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:11-17 (‏_skuCache + _skuOf; חוק-4).
// הכרעה 1 (🔌): השכנים הפכו לשקעים —
//   • `catalog` — במקור kCompatCatalog (install_engine.dart:15). **דאטה-מוזרקת** (מתחלף פר-ורטיקל).
//   • `sku`     — שקע-ריאדר: T ⇒ מפתח-ה-SKU (במקור p.sku — השדה היחיד שנגוע).
//   • `cache`   — במקור משתנה-מודול `Map<String, ...>? _skuCache` (install_engine.dart:13).
//     הוזרק כמחזיק-מטמון שהקופסה בעלת-החיים שלו; סמנטיקת `??=` נשמרת verbatim:
//     נבנה בקריאה הראשונה בלבד — שינוי-קטלוג אחרי-כן אינו נראה (התנהגות-המקור).
// כפל-SKU: האחרון-בקטלוג מנצח (map-comprehension דורסת — התנהגות-המקור).
//
// קלט:  sku · catalog · skuKey · cache (מחזיק, מתמלא-פעם-אחת).
// פלט:  T? — המוצר, או null כשה-SKU אינו בקטלוג.

/// מחזיק-המטמון — תחליף-השקע למשתנה-המודול `_skuCache` (install_engine.dart:13).
/// הקופסה יוצרת אחד ומעבירה אותו בכל קריאה; `map == null` ⇒ טרם-נבנה.
class SkuCache<T> {
  Map<String, T>? map;
}

/// מוצר לפי [sku] בקטלוג-המוזרק, O(1) אחרי הבנייה הראשונה; null אם אין.
/// verbatim install_engine.dart:14-17 (‏_skuOf) עם שקעים במקום שכנים.
T? skuOf<T>(
  String sku, {
  required List<T> catalog,
  required String Function(T) skuKey,
  required SkuCache<T> cache,
}) {
  cache.map ??= {for (final p in catalog) skuKey(p): p};
  return cache.map![sku];
}
