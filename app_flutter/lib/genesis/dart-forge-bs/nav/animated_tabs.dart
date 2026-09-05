// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "nav" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/nav-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// AnimatedTabs — seam:collection · 4 חריצים
class ForgeAnimatedTabs extends StatelessWidget {
  /// תפר-דאטה (G12a): 4 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 4;
  static const List<String> fieldDemo = <String>["Label", "Label", "Label", "Label"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  static Widget _hide(String s, Widget w) => s.isEmpty ? const SizedBox.shrink() : w;   // G13a · חריץ-ריק ⇒ הקופסה נעלמת
  /// G13a · קבוצת-פריטים: items[i] = חריצי-הטקסט של פריט i (1 חריצים · 4 בדמו · לחיץ: onSelect(i) · selected = הפריטים-הפעילים). null ⇒ פריטי-העיצוב.
  final List<List<String>>? items;
  final Set<int>? selected;
  final void Function(int)? onSelect;
  static const int itemSlots = 1;
  static const int itemDemo = 4;
  String _it(List<String> r, int j, String d) => items == null ? d : (j < r.length ? r[j] : '');
  const ForgeAnimatedTabs({super.key, this.fields, this.child, this.items, this.selected, this.onSelect});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(14)), child: _withChild(Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: skin.hair, width: 1))), child: SizedBox(width: double.infinity, child: Stack(clipBehavior: Clip.none, children: [Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 4, children: [...(items == null ? <Widget>[_hide(_f(0, "Label"), Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(14, 11, 14, 11), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text(_f(0, "Label"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w600))))), _hide(_f(1, "Label"), Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(14, 11, 14, 11), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text(_f(1, "Label"), style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w600))))), _hide(_f(2, "Label"), Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(14, 11, 14, 11), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text(_f(2, "Label"), style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w600))))), _hide(_f(3, "Label"), Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(14, 11, 14, 11), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text(_f(3, "Label"), style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w600)))))] : List<Widget>.generate(items!.length, (i) => Flexible(child: ((selected?.contains(i) ?? false) ? GestureDetector(behavior: HitTestBehavior.opaque, onTap: onSelect == null ? null : () => onSelect!(i), child: _hide(_it(items![i], 0, "Label"), Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(14, 11, 14, 11), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text(_it(items![i], 0, "Label"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w600)))))) : GestureDetector(behavior: HitTestBehavior.opaque, onTap: onSelect == null ? null : () => onSelect!(i), child: _hide(_it(items![i], 0, "Label"), Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(14, 11, 14, 11), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text(_it(items![i], 0, "Label"), style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w600))))))))))]), Positioned(bottom: -1, left: 0, child: Container(height: 2.5, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(2), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 0), blurRadius: 10, spreadRadius: 0)])))]))), child));
    return body;
  }
}
