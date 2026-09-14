// ⚛️ אטום-Dart (דרגת-חוזה) · facetTokens
// מוצא: buildsmart/app_flutter/lib/screens/catalog_screen.dart:596 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__catalog_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): מוצרים · בעץ · גרסאות · מים · חמים · בלבד · מתכת · ליפסקי · ברקן · משפחות · וריאנטים · שונה

/// Meaningful words of a product name — drops sizes/numbers, punctuation and
/// very short tokens, so facets split by real characterizing words.
List<String> facetTokens(String name) {
  final cleaned = name.replaceAll(RegExp('[()"׳\'*.,/+\\-־–—]'), ' ');
  return cleaned
      .split(RegExp(r'\s+'))
      .map((w) => w.trim())
      .where((w) =>
          w.length >= 2 &&
          !w.contains('"') &&
          !w.contains('″') &&
          !RegExp(r'[0-9]').hasMatch(w))
      .toList();
}
