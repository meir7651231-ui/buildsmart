// 🧠 מנוע-אביזרים · פאזה D slice 5 — כתב-חיתוך (cut-list). לכל קטע-צינור בין שני
// אביזרים ברצף: אורך-החיתוך = מרחק-מרכזים − ניכוי-שקע-A − ניכוי-שקע-B. מקורקע ב-
// `cut_list.dart` (פאזה B: `cutDeductionFor`/`pipeCutLength`). מגודר · off-live.
//
// 🔒 טהור · אף מסך-חי אינו מייבא `intel/` ⇒ tree-shaken ⇒ הזרימה החיה byte-identical.
// זו גיאומטריה (אורכי-צינור) — אין ערכי-בטיחות-מחייבים (אין צורך בביקורת-M5).

import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/plan/cut_list.dart';
import 'package:flutter/foundation.dart' show immutable;

/// קטע-צינור-לחיתוך בין שני אביזרים סמוכים: הקצוות, הקוטר, מרחק-המרכזים, ואורך-
/// החיתוך המחושב (מרכז↔מרכז פחות ניכויי-שני-השקעים).
@immutable
class CutSegment {
  const CutSegment({
    required this.fromFamily,
    required this.toFamily,
    required this.od,
    required this.centerToCenter,
    required this.cutLength,
  });

  final String fromFamily;
  final String toFamily;
  final int od;
  final double centerToCenter;
  final double cutLength;
}

/// ניכוי-השקע (מ״מ) שאביזר "אוכל" מקטע-הצינור — 0 כשלא-מוגדר (M1 · fallback שפוי).
double _deduction(RunElement el) =>
    cutDeductionFor(el.family.label, el.od, od2: el.od2) ?? 0;

/// **כתב-חיתוך** (D5): רצף-אביזרים + מרחקי-מרכזים פר-מרווח → אורכי-חיתוך פר-צינור.
/// `centerToCenters[i]` = המרחק בין מרכז אביזר i למרכז i+1. אם חסר מרווח → מדולג.
/// אין זריקה (M1): רצף קצר-מ-2 → רשימה ריקה.
List<CutSegment> cutList(List<RunElement> route, List<double> centerToCenters) {
  final out = <CutSegment>[];
  for (var i = 0; i + 1 < route.length; i++) {
    if (i >= centerToCenters.length) break;
    final a = route[i];
    final b = route[i + 1];
    final c2c = centerToCenters[i];
    out.add(CutSegment(
      fromFamily: a.family.label,
      toFamily: b.family.label,
      od: b.od,
      centerToCenter: c2c,
      cutLength: pipeCutLength(c2c, _deduction(a), _deduction(b)),
    ),);
  }
  return out;
}

/// נוחות: מרחק-מרכזים אחיד לכל המרווחים (למסך-דמו/preview).
List<CutSegment> cutListUniform(List<RunElement> route, double centerToCenter) =>
    cutList(route, List<double>.filled(route.length, centerToCenter));
