import '../dart-data/quote_text_for-data.dart';
// ⚛️ אטום-Dart · quoteTextFor
// מוצא: buildsmart/app_flutter/lib/data/related_info.dart:1259-1279
//        (‏quoteTextFor; חוק-2 — verbatim, לא-משופר).
// טיפוס-דומיין: SmartProduct (data/smart_tree.dart:116) + SmartBrand (:78).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק dart:core).
//
// שקעים שהוזרקו (קריאה-לשכן ⇒ פרמטר-שקע · חוק-3, דיבר-3):
//   • `lineCostEstimateFor(sp, idx)` (related_info.dart:1265,1550) ⇒ שקע
//     `lineCostEstimate(int idx)` שמחזיר `({int product,accessories,labour,total})?`.
//     sp קבוע-בקריאה ⇒ נלכד ע"י המזמן; ברירת-מחדל null (אין אומדן-קו).
//   • `deepLinkFor(sp, idx)` (related_info.dart:1275,1249) ⇒ שקע `deepLink(int idx)`
//     שמחזיר String. משתמש ב-AppBrand.shareDomain ⇒ נשאר מחוץ-לאטום (חוק-6, זהות).
//   • `AppBrand.name` (config/app_brand.dart:35) ⇒ שקע `brandName` (זהות-מותג,
//     חוק-6). ברירת-מחדל 'BuildSmart' (ערך-ברירת-המחדל של הפרופיל).
//   • המחלקות SmartProduct/SmartBrand קורסות ל-`QuoteProduct`/`QuoteBrand` —
//     מחזיקי-קלט טהורים עם רק השדות ש-quoteTextFor קורא (name/brands · name/price/rec).
//
// קלט:  sp — QuoteProduct (name · brands · recBrand).
//       brandIndex — int (אינדקס-המותג הנבחר; מחוץ-לטווח ⇒ recBrand).
//       lineCostEstimate/deepLink/brandName — שקעים (ראה למעלה).
// פלט:  String — טקסט הצעת-מחיר רב-שורתי מוכן-לשיתוף.

/// מחזיק-קלט טהור: השדות ש-quoteTextFor קורא מ-SmartBrand (smart_tree.dart:72-77).
class QuoteBrand {
  final String name;
  final int? price; // null = מחיר לפי ספק
  final bool rec;
  const QuoteBrand({required this.name, this.price, this.rec = false});
}

/// מחזיק-קלט טהור: השדות ש-quoteTextFor קורא מ-SmartProduct (smart_tree.dart:126-137).
/// `recBrand` = verbatim מ-smart_tree.dart:137.
class QuoteProduct {
  final String name;
  final List<QuoteBrand> brands;
  const QuoteProduct({required this.name, required this.brands});
  QuoteBrand get recBrand =>
      brands.firstWhere((b) => b.rec, orElse: () => brands.first);
}

/// אומדן-עלות-קו (related_info.dart:1550): מוצר · אביזרים · עבודה · סה"כ.
typedef _Cost = ({int product, int accessories, int labour, int total});

_Cost? _noCost(int idx) => null;
String _noLink(int idx) => '';

/// טקסט הצעת-מחיר למותג הנבחר — verbatim של related_info.dart:1259-1279.
String quoteTextFor(
  QuoteProduct sp,
  int brandIndex, {
  _Cost? Function(int idx) lineCostEstimate = _noCost,
  String Function(int idx) deepLink = _noLink,
  String brandName = 'BuildSmart',
}) {
  final idx = (brandIndex >= 0 && brandIndex < sp.brands.length)
      ? brandIndex
      : sp.brands.indexOf(sp.recBrand);
  final b = sp.brands[idx];
  final lines = <String>['${kqTitle}${sp.name}', '${kqBrand}${b.name}'];
  final cost = lineCostEstimate(idx);
  if (cost != null) {
    lines.add('${kqProduct}${cost.product}');
    if (cost.accessories > 0) lines.add('${kqAccessories}${cost.accessories}');
    if (cost.labour > 0) lines.add('${kqLabour}${cost.labour}');
    lines.add('${kqTotal}${cost.total}');
  } else if (b.price != null) {
    lines.add('${kqPrice}${b.price}');
  }
  lines.add('🔗 ${deepLink(idx)}');
  lines.add('${kqMadeBy}$brandName');
  return lines.join('\n');
}
