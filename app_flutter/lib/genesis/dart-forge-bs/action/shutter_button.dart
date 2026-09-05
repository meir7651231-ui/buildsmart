// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// ShutterButton — seam:fields
class ForgeShutterButton extends StatelessWidget {
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  /// G13a · הקשה על כפתור/קישור k (סדר-הופעה, 1 פעולות).
  final void Function(int)? onAction;
  static const int actionSlots = 1;
  const ForgeShutterButton({super.key, this.child, this.onAction});
  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final Widget body = GestureDetector(behavior: HitTestBehavior.opaque, onTap: onAction == null ? null : () => onAction!(0), child: Container(width: 52, height: 52, alignment: Alignment.center, decoration: BoxDecoration(border: Border.all(color: theme.aHi, width: 3), borderRadius: BorderRadius.circular(999)), child: _withChild(Container(width: 37, height: 37, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(999))), child)));
    return body;
  }
}
