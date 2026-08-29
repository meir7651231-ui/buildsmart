// ⚛️ אטום-Dart · projectQuoteText
// מוצא: buildsmart/app_flutter/lib/state/card_projects.dart:81-95
//        (‏projectQuoteText; חוק-2 — verbatim, לא-משופר).
// טיפוס-דומיין: ProjectItem (state/card_projects.dart:14).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק dart:core).
//
// שקעים שהוזרקו (קריאה-לשכן ⇒ פרמטר-שקע · חוק-3, דיבר-3):
//   • `catalogProductForSku(it.sku)` + `priceFor(prod)` (card_projects.dart:85-86)
//     קורסים לשקע-יחיד `unitPriceOf(String sku) → int?`: המקור מחשב
//     `unit = prod==null ? 0 : (priceFor(prod) ?? 0)` — שני מסלולי-ה-null
//     (אין-מוצר / מוצר-בלי-מחיר) נותנים 0. השקע מחזיר null ⇒ 0, ערך ⇒ הערך.
//     ברירת-מחדל null (⇒ 0 לכל שורה).
//   • `AppBrand.name` (config/app_brand.dart:35) ⇒ שקע `brandName` (זהות-מותג,
//     חוק-6). ברירת-מחדל 'BuildSmart'.
//   • המחלקה ProjectItem קורסת ל-`QuoteLineItem` — מחזיק-קלט טהור עם רק
//     השדות ש-projectQuoteText קורא בלולאה (location · brandName · sku · qty).
//
// קלט:  project — String (שם-הפרויקט).
//       items — List<QuoteLineItem>.
//       unitPriceOf/brandName — שקעים (ראה למעלה).
// פלט:  String — טקסט הצעת-מחיר לפרויקט רב-שורתי.

/// מחזיק-קלט טהור: השדות ש-projectQuoteText קורא מ-ProjectItem
/// (card_projects.dart:24-29). project הוא פרמטר-נפרד, לא שדה-הפריט.
class QuoteLineItem {
  final String location;
  final String brandName;
  final String sku;
  final int qty;
  const QuoteLineItem({
    required this.location,
    required this.brandName,
    required this.sku,
    this.qty = 1,
  });
}

int? _noPrice(String sku) => null;

/// טקסט הצעת-מחיר לפרויקט שלם — verbatim של card_projects.dart:81-95.
String projectQuoteText(
  String project,
  List<QuoteLineItem> items, {
  int? Function(String sku) unitPriceOf = _noPrice,
  String brandName = 'BuildSmart',
}) {
  final lines = <String>['הצעת מחיר — פרויקט "$project"'];
  var total = 0;
  for (final it in items) {
    final unit = unitPriceOf(it.sku) ?? 0;
    final sub = unit * it.qty;
    total += sub;
    lines.add('• ${it.location}: ${it.brandName} ×${it.qty} — ~₪$sub');
  }
  lines.add('סה"כ משוער: ~₪$total');
  lines.add('— נוצר ב-$brandName');
  return lines.join('\n');
}
