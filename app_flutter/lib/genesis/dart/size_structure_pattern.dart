// ⚛️ אטום-Dart (דרגת-חוזה) · sizeStructurePattern
// מוצא: buildsmart/app_flutter/lib/data/variant_families.dart:157 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// ייעוד-עברי (G63 · מקור: מונחי-מסך-הקורא screens__catalog_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): מוצרים · בעץ · גרסאות · מים · חמים · בלבד · מתכת · ליפסקי · ברקן · משפחות · וריאנטים · שונה

/// Structural pattern of a size string, e.g. "16×16" → "A×A", "16×1/2"×16" →
/// "A×B×A". Returns "1" for single-value sizes.
String sizeStructurePattern(String size) {
  final main = size.trim().split(' ').firstWhere((s) => s.isNotEmpty,
      orElse: () => size);
  final parts =
      main.split(RegExp(r'[×x]')).where((s) => s.isNotEmpty).toList();
  if (parts.length == 1) return '1';
  if (parts.length == 2) return parts[0] == parts[1] ? 'A×A' : 'A×B';
  if (parts.length == 3) {
    final distinct = parts.toSet();
    if (distinct.length == 1) return 'A×A×A';
    if (parts[0] == parts[2]) return 'A×B×A';
    if (distinct.length == 2) return 'A×A×B';
    return 'A×B×C';
  }
  return '${parts.length}×';
}
