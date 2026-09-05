// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "selection" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/selection-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// UnitSegmentToggle — seam:exclusive · 3 חריצים
class ForgeUnitSegmentToggleSelection extends StatelessWidget {
  /// תפר-דאטה (G12a): 3 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 3;
  static const List<String> fieldDemo = <String>["Label", "Label", "Label"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  static Widget _hide(String s, Widget w) => s.isEmpty ? const SizedBox.shrink() : w;   // G13a · חריץ-ריק ⇒ הקופסה נעלמת
  /// G13b · bare=true ⇒ ליבת-הבקרה בלי מסגרת-הגלריה של Pure (.ctl/.body/.stage); child נכנס לליבה. false ⇒ ביט-זהה לגלריה.
  final bool bare;
  /// G13a · קבוצת-פריטים: items[i] = חריצי-הטקסט של פריט i (1 חריצים · 3 בדמו · לחיץ: onSelect(i) · selected = הפריטים-הפעילים). null ⇒ פריטי-העיצוב.
  final List<List<String>>? items;
  final Set<int>? selected;
  final void Function(int)? onSelect;
  static const int itemSlots = 1;
  static const int itemDemo = 3;
  String _it(List<String> r, int j, String d) => items == null ? d : (j < r.length ? r[j] : '');
  const ForgeUnitSegmentToggleSelection({super.key, this.fields, this.child, this.bare = false, this.items, this.selected, this.onSelect});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget core = Container(margin: const EdgeInsets.fromLTRB(0, 0, 0, 0), child: Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Stack(clipBehavior: Clip.none, children: [Positioned(top: 3, bottom: 3, left: 0, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 2), blurRadius: 8, spreadRadius: 0)]))), Padding(padding: const EdgeInsets.fromLTRB(3, 3, 3, 3), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [...(items == null ? <Widget>[_hide(_f(0, "Label"), Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text(_f(0, "Label"), style: TextStyle(color: const Color(0xFF0A0A0C), fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11, fontWeight: FontWeight.w600))))), _hide(_f(1, "Label"), Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text(_f(1, "Label"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11, fontWeight: FontWeight.w600))))), _hide(_f(2, "Label"), Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text(_f(2, "Label"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11, fontWeight: FontWeight.w600)))))] : List<Widget>.generate(items!.length, (i) => Flexible(child: ((selected?.contains(i) ?? false) ? GestureDetector(behavior: HitTestBehavior.opaque, onTap: onSelect == null ? null : () => onSelect!(i), child: _hide(_it(items![i], 0, "Label"), Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text(_it(items![i], 0, "Label"), style: TextStyle(color: const Color(0xFF0A0A0C), fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11, fontWeight: FontWeight.w600)))))) : GestureDetector(behavior: HitTestBehavior.opaque, onTap: onSelect == null ? null : () => onSelect!(i), child: _hide(_it(items![i], 0, "Label"), Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text(_it(items![i], 0, "Label"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11, fontWeight: FontWeight.w600))))))))))]))])));
    final Widget body = bare ? _withChild(core, child) : Container(height: 130, padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: _withChild(Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, spacing: 11, children: [core]), child));
    return body;
  }
}
