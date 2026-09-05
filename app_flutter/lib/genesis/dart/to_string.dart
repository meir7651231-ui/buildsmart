// ⚛️ אטום-Dart (דרגת-חוזה) · pressureDropToString
// מוצא: buildsmart/app_flutter/lib/logic/pressure_drop.dart:183-187 (‏PressureDropResult.toString; חוק-4).
//        מתודת-מופע ⇒ פורקה לפורמטר-טהור top-level: השדות-שנקראו (dropBar/totalK/frictionMetres/
//        minBoreMm — double; bottleneck?.sku — String?) הוזרקו כפרמטרים (חוק-3/דיבר-3). מחרוזת-הפורמט
//        verbatim (כולל הרווח-הכפול אחרי "bar" והמקף "—" ברירת-המחדל ל-sku נעדר).
//
// קלט:  dropBar, totalK — double; frictionMetres, minBoreMm — double; bottleneckSku — String? (‏null ⇒ "—").
// פלט:  שורת-סיכום: 'ΔP = <2ספרות> bar  (K=<2>, L=<1>m, minBore=<1>mm, bottleneck=<sku|—>)'.

/// The one-line human summary of a pressure-drop result.
/// Verbatim behaviour of pressure_drop.dart:183-187 (the instance `toString`),
/// with the read instance fields injected as parameters.
String pressureDropToString({
  required double dropBar,
  required double totalK,
  required double frictionMetres,
  required double minBoreMm,
  required String? bottleneckSku,
}) =>
    'ΔP = ${dropBar.toStringAsFixed(2)} bar  (K=${totalK.toStringAsFixed(2)}, '
    'L=${frictionMetres.toStringAsFixed(1)}m, '
    'minBore=${minBoreMm.toStringAsFixed(1)}mm, '
    'bottleneck=${bottleneckSku ?? "—"})';
