// ✨ חריץ-העיצוב · Layer C בארכיטקטורת-ההטמעה — מזריק את שפת-Pure הפעילה לעץ-הווידג'טים.
// חוק-6 (הזהות בחיווט, לא באטום) + חוק-7 (החלפה הפיכה): בהיעדר PureScope, of() נופל לברירת-המחדל
// ⇒ פלט ביט-זהה, דורמנטי. הנייטרל/הסמנטי קבועים (DsPure.*); רק ערכת-האקצנט זורמת דרך החריץ. material בלבד.
import 'package:flutter/material.dart';
import 'ds_pure.dart';

/// PureScope — עוטף תת-עץ בערכת-אקצנט פעילה **ובחבילת-פונט**. אטום קורא DsSeam.of/fontsOf(context)
/// ולא יודע איזו ערכה/פונט (חוק-5). הפונט הוא פרמטר הפיך: היעדר-הזרקה ⇒ פונטי-Pure (חוק-7).
class PureScope extends InheritedWidget {
  final DsPureTheme theme;
  final DsPureFonts fonts;
  final DsPureSkin skin;
  const PureScope({
    super.key,
    required this.theme,
    this.fonts = DsPure.fonts,
    this.skin = DsPure.skin,
    required super.child,
  });

  @override
  bool updateShouldNotify(PureScope old) => old.theme != theme || old.fonts != fonts || old.skin != skin;
}

/// גישת-החריץ: הערכה/הפונט/העור הפעילים מ-PureScope, או ברירות-המחדל של DsPure כשאין (דורמנטי, הפיך).
class DsSeam {
  const DsSeam._();

  static DsPureTheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PureScope>()?.theme ??
      DsPure.themes[DsPure.defaultTheme]!;

  /// חבילת-הפונט הפעילה — פרמטר הפיך. אין PureScope ⇒ DsPure.fonts (ברירת-מחדל Pure).
  static DsPureFonts fontsOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PureScope>()?.fonts ?? DsPure.fonts;

  /// עור-העיצוב הפעיל (נייטרל+סמנטי) — פרמטר הפיך. אין PureScope ⇒ DsPure.skin (ברירת-מחדל Pure).
  static DsPureSkin skinOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PureScope>()?.skin ?? DsPure.skin;
}
