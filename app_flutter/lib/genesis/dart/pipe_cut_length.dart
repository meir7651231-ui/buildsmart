// ⚛️ אטום-Dart (דרגת-חוזה) · pipeCutLength
// מוצא: buildsmart/app_flutter/lib/features/fittings/plan/cut_list.dart:40 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, ייבוא-מדף בלבד (אומת ע"י פותר-המזהים).
// ייבוא-מדף (G69/G70 — אטום משותף מיובא, לא עותק מוטבע ולא שקע): r1 ← r1.dart.

import 'r1.dart';

/// אורך-הצינור לחיתוך בין שני מרכזי-אביזר במרחק [centerToCenter], בהינתן
/// הניכויים בשני הקצוות. `אורך = מרכז↔מרכז − Z₁ − Z₂`, מעוגל ל-מ״מ-עשירון.
double pipeCutLength(double centerToCenter, double deduction1, double deduction2) =>
    r1(centerToCenter - deduction1 - deduction2);
