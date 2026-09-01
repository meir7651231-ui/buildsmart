// ⚛️ אטום-Dart (דרגת-חוזה) · stripKind
// מוצא: buildsmart/app_flutter/lib/data/variant_families.dart:41-46 (חצב-בינה · חוק-3/4).
// שקע: kindOf ← השכן `kindOf(w)` — מסווג טוקן לסוג-מאפיין או null.
// מוטבע verbatim (enum מקומי, חוק-1): AttrKind (variant_families.dart:40).
// מסיר משם-מוצר את המילים ששייכות לסוג-המאפיין k ומחזיר את "המסגרת" (private→public).

enum AttrKind { size, color, model, subtype }

String stripKind(String name, AttrKind k,
        {required AttrKind? Function(String) kindOf}) =>
    name
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && kindOf(w) != k)
        .join(' ');
