// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "feedback" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/feedback-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// ModalDialog — seam:fields · 5 חריצים
class ForgeModalDialog extends StatelessWidget {
  /// תפר-דאטה (G12a): 5 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 5;
  static const List<String> fieldDemo = <String>["MODAL · OVER SCRIM", "Label", "Meta", "Action", "Action"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  static Widget _hide(String s, Widget w) => s.isEmpty ? const SizedBox.shrink() : w;   // G13a · חריץ-ריק ⇒ הקופסה נעלמת
  /// G13a · הקשה על כפתור/קישור k (סדר-הופעה, 2 פעולות).
  final void Function(int)? onAction;
  static const int actionSlots = 2;
  /// G13a · קבוצת-פריטים: items[i] = חריצי-הטקסט של פריט i (0 חריצים · 3 בדמו). null ⇒ פריטי-העיצוב.
  final List<List<String>>? items;
  static const int itemSlots = 0;
  static const int itemDemo = 3;
  String _it(List<String> r, int j, String d) => items == null ? d : (j < r.length ? r[j] : '');
  /// G13a · מילויי-אחוז (0..1) לפי סדר-הופעה/פריט (3 בדמו). null ⇒ ערכי-העיצוב; חסר ⇒ 0 (אין המצאה).
  final List<double>? values;
  double _v(int i, double d) => values == null ? d : (i < values!.length ? values![i].clamp(0.0, 1.0) : 0.0);
  const ForgeModalDialog({super.key, this.fields, this.child, this.onAction, this.items, this.values});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Container(height: 236, decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(14)), child: _withChild(SizedBox(width: double.infinity, child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: Opacity(opacity: 0.4, child: Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 9, children: [FractionallySizedBox(widthFactor: _v(0, 0.500), alignment: Alignment.centerRight, child: Container(height: 16, decoration: BoxDecoration(color: skin.raised, borderRadius: BorderRadius.circular(6)))), ...(items == null ? <Widget>[Container(height: 11, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(6))), FractionallySizedBox(widthFactor: _v(1, 0.850), alignment: Alignment.centerRight, child: Container(height: 11, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(6)))), FractionallySizedBox(widthFactor: _v(2, 0.700), alignment: Alignment.centerRight, child: Container(height: 11, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(6))))] : List<Widget>.generate(items!.length, (i) => Container(height: 11, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(6)))))])))), Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(0), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5), child: Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), decoration: BoxDecoration(color: const Color(0x94060608)), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: SizedBox(width: double.infinity, child: Container(padding: const EdgeInsets.fromLTRB(18, 18, 18, 18), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.raised, skin.surface], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xB3000000), offset: const Offset(0, 30), blurRadius: 80, spreadRadius: 0)]), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 12, children: [Text(_f(1, "Label"), style: TextStyle(color: skin.ink, fontFamily: fonts.serifHe, fontSize: 16, fontWeight: FontWeight.w700)), Text(_f(2, "Meta"), style: TextStyle(color: skin.mut, fontSize: 12.5, fontFamily: fonts.he)), Container(margin: const EdgeInsets.fromLTRB(0, 2, 0, 0), child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, spacing: 9, children: [GestureDetector(behavior: HitTestBehavior.opaque, onTap: onAction == null ? null : () => onAction!(0), child: _hide(_f(3, "Action"), Container(height: 44, padding: const EdgeInsets.fromLTRB(15, 0, 15, 0), decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 6), blurRadius: 16, spreadRadius: 0)]), child: Center(widthFactor: 1.0, child: Text(_f(3, "Action"), style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.he, fontSize: 12.5, fontWeight: FontWeight.w700)))))), GestureDetector(behavior: HitTestBehavior.opaque, onTap: onAction == null ? null : () => onAction!(1), child: _hide(_f(4, "Action"), Container(height: 44, padding: const EdgeInsets.fromLTRB(15, 0, 15, 0), decoration: BoxDecoration(color: skin.raised2, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(10)), child: Center(widthFactor: 1.0, child: Text(_f(4, "Action"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 12.5, fontWeight: FontWeight.w700))))))]))])))))))), Positioned(top: 8, left: 10, child: Directionality(textDirection: TextDirection.ltr, child: Text(_f(0, "MODAL · OVER SCRIM"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 8, letterSpacing: 1))))])), child));
    return body;
  }
}
