// ⚛️ אטום-Dart · catalogProductForBrand
// מוצא: buildsmart/app_flutter/lib/data/related_info.dart:98-99 (חצב-בינה · קטלוג-מוזרק · חוק-4).
// שקע: _skuIndex (אינדקס-מק"ט מעל kLipskeyCatalog) ← דאטה-מוזרקת (מתחלף פר-ורטיקל)
//
// טיפוס-מינימום SmartBrand: רק השדה `sku` (String?) שהפונקציה נוגעת בו + const ctor.
// טיפוס-מינימום LipskeyCatalogProduct: ערך-האינדקס בלבד (const ctor ריק).

/// צורת-מינימום של SmartBrand — רק מה ש-catalogProductForBrand קורא.
class SmartBrand {
  final String? sku;
  const SmartBrand({this.sku});
}

/// צורת-מינימום של LipskeyCatalogProduct — ערך-האינדקס בלבד.
class LipskeyCatalogProduct {
  const LipskeyCatalogProduct();
}

/// מוצר-הקטלוג ש-[brand] מצביע אליו, או null אם אין מק"ט / המק"ט לא באינדקס.
/// verbatim related_info.dart:98-99 (_skuIndex ⇒ שקע skuIndex).
LipskeyCatalogProduct? catalogProductForBrand(
  SmartBrand brand, {
  required Map<String, LipskeyCatalogProduct> skuIndex,
}) =>
    brand.sku == null ? null : skuIndex[brand.sku];
