// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// PickerOptionsPanel — seam:fields · 4 חריצים
class ForgePickerOptionsPanel extends StatelessWidget {
  /// תפר-דאטה (G12a): 4 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 4;
  static const List<String> fieldDemo = <String>["Label", "Meta", "Label", "Meta"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  /// G13a · קבוצת-פריטים: items[i] = חריצי-הטקסט של פריט i (2 חריצים · 2 בדמו · לחיץ: onSelect(i) · selected = הפריטים-הפעילים). null ⇒ פריטי-העיצוב.
  final List<List<String>>? items;
  final Set<int>? selected;
  final void Function(int)? onSelect;
  static const int itemSlots = 2;
  static const int itemDemo = 2;
  String _it(List<String> r, int j, String d) => items == null ? d : (j < r.length ? r[j] : '');
  const ForgePickerOptionsPanel({super.key, this.fields, this.child, this.items, this.selected, this.onSelect});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Container(padding: const EdgeInsets.fromLTRB(8, 8, 8, 8), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(12)), child: _withChild(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 7, children: [...(items == null ? <Widget>[Container(padding: const EdgeInsets.fromLTRB(13, 11, 13, 11), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.100), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 11, children: [Container(width: 19, height: 19, alignment: Alignment.center, decoration: BoxDecoration(border: Border.all(color: skin.hair, width: 2), borderRadius: BorderRadius.circular(999))), Expanded(child: Text(_f(0, "Label"), textAlign: TextAlign.right, style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w600))), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text(_f(1, "Meta"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5), overflow: TextOverflow.ellipsis, softWrap: false)))])), Container(padding: const EdgeInsets.fromLTRB(13, 11, 13, 11), decoration: BoxDecoration(color: skin.raised, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 11, children: [Container(width: 19, height: 19, alignment: Alignment.center, decoration: BoxDecoration(border: Border.all(color: skin.hair, width: 2), borderRadius: BorderRadius.circular(999))), Expanded(child: Text(_f(2, "Label"), textAlign: TextAlign.right, style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w600))), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text(_f(3, "Meta"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5), overflow: TextOverflow.ellipsis, softWrap: false)))]))] : List<Widget>.generate(items!.length, (i) => ((selected?.contains(i) ?? false) ? GestureDetector(behavior: HitTestBehavior.opaque, onTap: onSelect == null ? null : () => onSelect!(i), child: Container(padding: const EdgeInsets.fromLTRB(13, 11, 13, 11), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.100), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 11, children: [Container(width: 19, height: 19, alignment: Alignment.center, decoration: BoxDecoration(border: Border.all(color: skin.hair, width: 2), borderRadius: BorderRadius.circular(999))), Expanded(child: Text(_it(items![i], 0, "Label"), textAlign: TextAlign.right, style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w600))), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text(_it(items![i], 1, "Meta"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5), overflow: TextOverflow.ellipsis, softWrap: false)))]))) : GestureDetector(behavior: HitTestBehavior.opaque, onTap: onSelect == null ? null : () => onSelect!(i), child: Container(padding: const EdgeInsets.fromLTRB(13, 11, 13, 11), decoration: BoxDecoration(color: skin.raised, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 11, children: [Container(width: 19, height: 19, alignment: Alignment.center, decoration: BoxDecoration(border: Border.all(color: skin.hair, width: 2), borderRadius: BorderRadius.circular(999))), Expanded(child: Text(_it(items![i], 0, "Label"), textAlign: TextAlign.right, style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w600))), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text(_it(items![i], 1, "Meta"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5), overflow: TextOverflow.ellipsis, softWrap: false)))]))))))]), child));
    return body;
  }
}
