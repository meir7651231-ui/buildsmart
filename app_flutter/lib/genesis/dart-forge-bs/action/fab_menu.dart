// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// FabMenu — seam:items · 4 חריצים
class ForgeFabMenu extends StatelessWidget {
  /// תפר-דאטה (G12a): 4 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 4;
  static const List<String> fieldDemo = <String>["Action", "Action", "Action", "＋"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  static Widget _hide(String s, Widget w) => s.isEmpty ? const SizedBox.shrink() : w;   // G13a · חריץ-ריק ⇒ הקופסה נעלמת
  /// G13a · הקשה על כפתור/קישור k (סדר-הופעה, 4 פעולות).
  final void Function(int)? onAction;
  static const int actionSlots = 4;
  const ForgeFabMenu({super.key, this.fields, this.child, this.onAction});
  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = _withChild(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [GestureDetector(behavior: HitTestBehavior.opaque, onTap: onAction == null ? null : () => onAction!(0), child: Container(height: 44, decoration: BoxDecoration(color: theme.aHi.withValues(alpha: 0.150), border: Border.all(color: theme.aHi.withValues(alpha: 0.300)), borderRadius: BorderRadius.circular(11)), child: Center(widthFactor: 1.0, child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 0), child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Text(_f(0, "Action"), style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700))])), Positioned(top: 0, left: 0, right: 0, child: Container(height: 1.2, decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0x00000000), const Color(0xB3FFFFFF), const Color(0x00000000)], begin: Alignment.centerLeft, end: Alignment.centerRight))))])))), GestureDetector(behavior: HitTestBehavior.opaque, onTap: onAction == null ? null : () => onAction!(1), child: Container(height: 44, decoration: BoxDecoration(color: theme.aHi.withValues(alpha: 0.150), border: Border.all(color: theme.aHi.withValues(alpha: 0.300)), borderRadius: BorderRadius.circular(11)), child: Center(widthFactor: 1.0, child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 0), child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Text(_f(1, "Action"), style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700))])), Positioned(top: 0, left: 0, right: 0, child: Container(height: 1.2, decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0x00000000), const Color(0xB3FFFFFF), const Color(0x00000000)], begin: Alignment.centerLeft, end: Alignment.centerRight))))])))), GestureDetector(behavior: HitTestBehavior.opaque, onTap: onAction == null ? null : () => onAction!(2), child: Container(height: 44, decoration: BoxDecoration(color: theme.aHi.withValues(alpha: 0.150), border: Border.all(color: theme.aHi.withValues(alpha: 0.300)), borderRadius: BorderRadius.circular(11)), child: Center(widthFactor: 1.0, child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 0), child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Text(_f(2, "Action"), style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700))])), Positioned(top: 0, left: 0, right: 0, child: Container(height: 1.2, decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0x00000000), const Color(0xB3FFFFFF), const Color(0x00000000)], begin: Alignment.centerLeft, end: Alignment.centerRight))))])))), GestureDetector(behavior: HitTestBehavior.opaque, onTap: onAction == null ? null : () => onAction!(3), child: _hide(_f(3, "＋"), Container(width: 52, height: 52, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 12), blurRadius: 26, spreadRadius: 0)]), foregroundDecoration: BoxDecoration(gradient: RadialGradient(center: Alignment(-0.60, -1.20), radius: 1.20, colors: [theme.aHi, const Color(0x00000000)], stops: [0.0, 0.55]), borderRadius: BorderRadius.circular(999)), child: Text(_f(3, "＋"), style: TextStyle(color: const Color(0xFF0B0B0D), fontSize: 23, fontFamily: fonts.he)))))]), child);
    return body;
  }
}
