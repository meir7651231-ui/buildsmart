// ⚛️ אטום-Dart · estimatePrice — מנוע-נקי (מנגנון-בלבד, אפס-דאטה · הכרעת-בעלים "טהור כמו בתולה").
// מוצא: buildsmart/app_flutter/lib/logic/price_estimate.dart:90-109 (‏estimatePrice; חוק-4).
// טוהר-מוחלט: פונקציית top-level, אפס import, **אפס דאטה צרובה**. כל הנתונים מוזרקים:
//   • `priceTable`  — טבלת מחיר-פר-קטגוריה. **דאטה — חיה מחוץ למנוע** (dart-data/pipe-prices.dart).
//   • `fallbackIls` — מחיר-ברירת-מחדל לקטגוריה-לא-מוכרת. **דאטה מוזרקת** (במקור 25).
//   • `categoryHe`  — שקע-ריאדר: T ⇒ שם-קטגוריה (במקור p.categoryHe).
// התנהגות זהה-ביט למקור כשמזריקים את טבלת-המקור + fallback=25 (הבוקס מזריק).
//
// קלט:  items · categoryHe · priceTable · fallbackIls.
// פלט:  PriceEstimate(totalILS, itemCount, lowConfidence).

/// תוצאת-האמדן — מחזיק-פלט טהור (price_estimate.dart:74-85, verbatim).
class PriceEstimate {
  const PriceEstimate({
    required this.totalILS,
    required this.itemCount,
    required this.lowConfidence,
  });
  final int totalILS;
  final int itemCount;

  /// True when more than half the items had no category match — total is a
  /// very rough lower bound and the UI should label it accordingly.
  final bool lowConfidence;
}

/// סכום המחיר-המשוער לפי קטגוריה. **מנוע-בלבד**: הטבלה וה-fallback מוזרקים.
PriceEstimate estimatePrice<T>(
  List<T> items, {
  required String Function(T) categoryHe,
  required Map<String, int> priceTable,
  required int fallbackIls,
}) {
  if (items.isEmpty) {
    return const PriceEstimate(totalILS: 0, itemCount: 0, lowConfidence: true);
  }
  var total = 0;
  var matched = 0;
  for (final p in items) {
    final v = priceTable[categoryHe(p)];
    if (v != null) {
      total += v;
      matched++;
    } else {
      total += fallbackIls; // fallback מוזרק — לא-דאטה-במנוע
    }
  }
  final lowConf = matched < items.length / 2;
  return PriceEstimate(
      totalILS: total, itemCount: items.length, lowConfidence: lowConf);
}
