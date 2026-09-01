// ✨ חריץ-העיצוב · Layer C בארכיטקטורת-ההטמעה — מזריק את שפת-Pure הפעילה לעץ-הווידג'טים.
// חוק-6 (הזהות בחיווט, לא באטום) + חוק-7 (החלפה הפיכה): בהיעדר PureScope, of() נופל לברירת-המחדל
// ⇒ פלט ביט-זהה, דורמנטי. הנייטרל/הסמנטי קבועים (DsPure.*); רק ערכת-האקצנט זורמת דרך החריץ. material בלבד.
import 'package:flutter/material.dart';
import 'ds_pure.dart';

/// PureScope — עוטף תת-עץ בערכת-אקצנט פעילה. אטום קורא DsSeam.of(context) ולא יודע איזו ערכה (חוק-5).
class PureScope extends InheritedWidget {
  final DsPureTheme theme;
  const PureScope({super.key, required this.theme, required super.child});

  @override
  bool updateShouldNotify(PureScope old) => old.theme != theme;
}

/// גישת-החריץ: הערכה הפעילה מ-PureScope, או ברירת-המחדל של DsPure כשאין (דורמנטי, הפיך).
class DsSeam {
  const DsSeam._();

  static DsPureTheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PureScope>()?.theme ??
      DsPure.themes[DsPure.defaultTheme]!;
}
