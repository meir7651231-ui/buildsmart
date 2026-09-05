// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// SegmentedPillToggle — seam:fields · 2 חריצים
class ForgeSegmentedPillToggle extends StatelessWidget {
  /// תפר-דאטה (G12a): 2 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 2;
  static const List<String> fieldDemo = <String>["Label", "Label"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  static Widget _hide(String s, Widget w) => s.isEmpty ? const SizedBox.shrink() : w;   // G13a · חריץ-ריק ⇒ הקופסה נעלמת
  /// G13a · קבוצת-פריטים: items[i] = חריצי-הטקסט של פריט i (1 חריצים · 2 בדמו · לחיץ: onSelect(i) · selected = הפריטים-הפעילים). null ⇒ פריטי-העיצוב.
  final List<List<String>>? items;
  final Set<int>? selected;
  final void Function(int)? onSelect;
  static const int itemSlots = 1;
  static const int itemDemo = 2;
  String _it(List<String> r, int j, String d) => items == null ? d : (j < r.length ? r[j] : '');
  const ForgeSegmentedPillToggle({super.key, this.fields, this.child, this.items, this.selected, this.onSelect});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = SizedBox(width: double.infinity, child: Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: _withChild(Stack(clipBehavior: Clip.none, children: [Positioned(top: 3, bottom: 3, left: 0, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.raised2, skin.raised], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: const Color(0x66000000), offset: const Offset(0, 2), blurRadius: 6, spreadRadius: 0)]))), Padding(padding: const EdgeInsets.fromLTRB(3, 3, 3, 3), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [...(items == null ? <Widget>[Expanded(child: _hide(_f(0, "Label"), Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(8, 8, 8, 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text(_f(0, "Label"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 12, fontWeight: FontWeight.w600)))))), Expanded(child: _hide(_f(1, "Label"), Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(8, 8, 8, 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text(_f(1, "Label"), style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 12, fontWeight: FontWeight.w600))))))] : List<Widget>.generate(items!.length, (i) => ((selected?.contains(i) ?? false) ? Expanded(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onSelect == null ? null : () => onSelect!(i), child: _hide(_it(items![i], 0, "Label"), Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(8, 8, 8, 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text(_it(items![i], 0, "Label"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 12, fontWeight: FontWeight.w600))))))) : Expanded(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onSelect == null ? null : () => onSelect!(i), child: _hide(_it(items![i], 0, "Label"), Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(8, 8, 8, 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text(_it(items![i], 0, "Label"), style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 12, fontWeight: FontWeight.w600))))))))))]))]), child)));
    return body;
  }
}
