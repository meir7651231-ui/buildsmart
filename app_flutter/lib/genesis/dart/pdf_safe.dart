// ⚛️ אטום-Dart (דרגת-חוזה) · pdfSafe
// תפקיד: סינון-מחרוזת ל-PDF — משאיר עברית + ASCII-נדפס + ₪, זורק כל השאר; trim.
// מוצא: buildsmart/app_flutter/lib/logic/finance_report_pdf.dart:38-48
//        (‏_pdfSafe, פרטי-במקור). מקודם ל-public (כלל-הגלגול). חוק-4.
// אחים-שסוקטו/הוטבעו: אין. האטום קורא רק String/StringBuffer (runes).
//        (האח בטיוטה — buildFinanceReportPdf, תלוי-Flutter/pw — שכן, לא האטום.)
// טוהר: אפס import (dart:core בלבד).
//
// קלט:  s — טקסט חופשי (שם-סעיף וכו').
// פלט:  String — רק תווים בטווחים: עברית U+0590..U+05FF · ASCII-נדפס U+0020..U+007E
//        · ₪ (U+20AA). כל תו אחר מושמט. התוצאה עוברת trim.

/// PDF-safe filter: keep Hebrew, printable ASCII, and ₪; drop everything else;
/// trim. Verbatim behaviour of finance_report_pdf.dart:38-48.
String pdfSafe(String s) {
  final buf = StringBuffer();
  for (final rune in s.runes) {
    final keep = (rune >= 0x0590 && rune <= 0x05FF) || // Hebrew
        (rune >= 0x0020 && rune <= 0x007E) || // ASCII printable
        rune == 0x20AA; // ₪
    if (keep) buf.writeCharCode(rune);
  }
  return buf.toString().trim();
}
