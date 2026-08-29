// ⚛️ אטום-Dart · plainClassifications
// מוצא: buildsmart/app_flutter/lib/features/ring_dive/plain_dive.dart:186-198 (חצב-בינה · מפל-מינימום · חוק-4).

/// שורה בעץ-המילון של הבעלים (מוטבע-מינימום — רק שני השדות שהפונקציה נוגעת בהם).
class PlainNode {
  const PlainNode({
    required this.superCat,
    required this.classification,
  });

  final String superCat; // ring 1
  final String classification; // ring 2
}

/// Ring 2 — the classifications under [superCat] that reach products.
/// שקעים: [allNodes] (כל שורות-המילון) · [reaches] (הצומת מגיע-למוצר).
List<String> plainClassifications(
  String superCat, {
  required List<PlainNode> Function() allNodes,
  required bool Function(PlainNode) reaches,
}) {
  final out = <String>[];
  for (final n in allNodes()) {
    if (n.superCat == superCat &&
        !out.contains(n.classification) &&
        reaches(n)) {
      out.add(n.classification);
    }
  }
  return out;
}
