// 🧠 מנוע-אביזרים · E-lite slice 3 — ייצוא-מסמך (build-plan export). מרכיב תוכנית-קו
// למסמך-טקסט מובנֶה (רצף-אביזרים + כתב-חיתוך) — מוכן להעתקה/שיתוף. מגודר · off-live.
//
// 🔒 טהור (מחרוזת בלבד · אפס I/O · אפס תלות חדשה) · אף מסך-חי אינו מייבא `intel/`
// ⇒ tree-shaken ⇒ byte-identical. מרכיב `cutListUniform` (D5, מקורקע ב-cut_list).

import 'package:buildsmart/features/fittings/intel/line_cuts.dart';
import 'package:buildsmart/features/fittings/intel/line_planner.dart';

/// מייצא תוכנית-קו למסמך-טקסט (Markdown-lite · עברית): כותרת · רצף-אביזרים ממוספר ·
/// כתב-חיתוך פר-מרווח. מרחק-מרכזים [spacing] נומינלי. טהור · דטרמיניסטי.
String exportBuildPlanText(FittingLinePlan plan, {double spacing = 200}) {
  final b = StringBuffer()
    ..writeln('# תוכנית-בנייה')
    ..writeln()
    ..writeln('## רצף (${plan.route.length} אביזרים)');
  if (plan.route.isEmpty) {
    b.writeln('- (רצף ריק)');
  } else {
    for (var i = 0; i < plan.route.length; i++) {
      final el = plan.route[i];
      final od2 = el.od2 != null ? '→${el.od2}' : '';
      b.writeln('${i + 1}. ${el.family.label} ${el.od}$od2');
    }
  }

  final cuts = cutListUniform(plan.route, spacing);
  b
    ..writeln()
    ..writeln('## כתב-חיתוך (מרחק-מרכזים ${spacing.toStringAsFixed(0)} מ״מ)');
  if (cuts.isEmpty) {
    b.writeln('- (אין מרווחי-צינור)');
  } else {
    for (final c in cuts) {
      b.writeln(
          '- ${c.fromFamily} → צינור OD${c.od} → ${c.toFamily}: '
          '${c.cutLength.toStringAsFixed(1)} מ״מ',);
    }
  }

  return b.toString();
}
