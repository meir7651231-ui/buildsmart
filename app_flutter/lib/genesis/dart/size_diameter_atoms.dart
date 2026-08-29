// ⚛️ אטום-Dart · sizeDiameterAtoms
// מוצא: buildsmart/app_flutter/lib/data/variant_families.dart:187-215 (חצב-בינה · מפל-מינימום · חוק-4).

/// נרמול-אטום-מידה: 1½" ו-11/2" נחשבים לאותו אטום לצורך קיבוץ-שבבים. (מוטבע verbatim.)
String _normAtom(String s) {
  return s
      .replaceAll('½', '/2')
      .replaceAll('¼', '/4')
      .replaceAll('¾', '/4')
      .trim();
}

/// פירוק מחרוזת-מידה לאטומי-קוטר ייחודיים.
/// כל chunk מופרד-רווח נושא קטרים (עם פיצולי ×) או זנב-אורך חשוף.
List<String> sizeDiameterAtoms(String size) {
  final out = <String>{};
  final chunks = size.trim().split(' ').where((s) => s.isNotEmpty).toList();
  for (int i = 0; i < chunks.length; i++) {
    final chunk = chunks[i];
    if (chunk.contains('×') || chunk.contains('x')) {
      for (final p in chunk.split(RegExp(r'[×x]'))) {
        if (p.isNotEmpty) out.add(_normAtom(p));
      }
    } else if (i == 0) {
      out.add(_normAtom(chunk));
    } else {
      // זנב-מספרי חשוף (200, 250) → אטום-אורך.
      if (RegExp(r'^\d+$').hasMatch(chunk)) {
        out.add('${chunk} ס"מ');
      } else {
        out.add(_normAtom(chunk));
      }
    }
  }
  return out.toList();
}
