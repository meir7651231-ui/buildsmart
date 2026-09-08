// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// DsToggleTile — seam:fields · 2 חריצים
class ForgeDsToggleTile extends StatelessWidget {
  /// תפר-דאטה (G12a): 2 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 2;
  static const List<String> fieldDemo = <String>["Label", "tile"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
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
  const ForgeDsToggleTile({super.key, this.fields, this.child, this.onAction});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = SizedBox(width: double.infinity, child: Container(padding: const EdgeInsets.fromLTRB(12, 10, 12, 10), decoration: BoxDecoration(color: skin.raised, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: _withChild(Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, spacing: 10, children: [Expanded(child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 10, children: [Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 1, children: [Text(_f(0, "Label"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w600)), Directionality(textDirection: TextDirection.ltr, child: Text(_f(1, "tile"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9)))])])), GestureDetector(behavior: HitTestBehavior.opaque, onTap: onAction == null ? null : () => onAction!(0), child: Container(width: 46, height: 27, alignment: Alignment.center, decoration: BoxDecoration(color: skin.raised, border: Border.all(color: skin.hi.withValues(alpha: 0.18)), borderRadius: BorderRadius.circular(999)), child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: const SizedBox.shrink()), Positioned(top: 2, right: 2, width: 21, child: Container(width: 21, height: 21, decoration: BoxDecoration(color: skin.hi, borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: skin.shade.withValues(alpha: 0.35), offset: const Offset(0, 2), blurRadius: 4, spreadRadius: 0)])))])))]), child)));
    return body;
  }
}
