// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// CourierFormsPillButton — seam:fields · 1 חריצים
class ForgeCourierFormsPillButton extends StatelessWidget {
  /// תפר-דאטה (G12a): 1 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 1;
  static const List<String> fieldDemo = <String>["Action"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  /// G13a · הקשה על כפתור/קישור k (סדר-הופעה, 1 פעולות).
  final void Function(int)? onAction;
  static const int actionSlots = 1;
  const ForgeCourierFormsPillButton({super.key, this.fields, this.child, this.onAction});
  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = GestureDetector(behavior: HitTestBehavior.opaque, onTap: onAction == null ? null : () => onAction!(0), child: Container(height: 44, decoration: BoxDecoration(border: Border.all(color: theme.a, width: 1.5), borderRadius: BorderRadius.circular(999)), child: Center(widthFactor: 1.0, child: _withChild(Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 0), child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Text(_f(0, "Action"), style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700))])), Positioned(top: 0, left: 0, right: 0, child: Container(height: 1.2, decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0x00000000), const Color(0xB3FFFFFF), const Color(0x00000000)], begin: Alignment.centerLeft, end: Alignment.centerRight))))]), child))));
    return body;
  }
}
