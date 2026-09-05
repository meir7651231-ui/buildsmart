// ⚛️ אטום-Dart · restoreFinal
// מוצא: buildsmart/app_flutter/lib/features/global_search/hebrew_morph.dart:25-39 (חצב-בינה · מפל-מינימום · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core). הפרטי `_restoreFinal`→ציבורי.
//   מפל: הקבוע `finalForm` (:16-24) הוטבע verbatim (String→String).

/// Non-final Hebrew letter → its word-FINAL form. Stripping a plural suffix
/// exposes a letter that must take its final shape to match the singular in the
/// catalog ("אטמים" → strip "ים" → "אטמ" → restore → "אטם").

/// מחזיר את [w] כשאותו-הסוף מומר לצורתו-הסופית (אם קיימת המרה); אחרת ללא-שינוי.
String restoreFinal(String w, {required Map<String, dynamic> finalForm}) {
  if (w.isEmpty) return w;
  final last = w[w.length - 1];
  final f = finalForm[last];
  return f == null ? w : '${w.substring(0, w.length - 1)}$f';
}
