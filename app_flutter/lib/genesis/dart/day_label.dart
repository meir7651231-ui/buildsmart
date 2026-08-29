// ⚛️ אטום-Dart (דרגת-חוזה) · dayLabel
// מוצא: buildsmart/app_flutter/lib/services/weather.dart:61-69 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).

String dayLabel(int i, {required String Function(String) term}) => switch (i) {
      0 => term('hyvm'),
      1 => term('mchr'),
      2 => term('mchrtyym'),
      _ => '${term('xi_bavd')}$i${term('xi_ymym')}',
    };
