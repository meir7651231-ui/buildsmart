// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "nav" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/nav-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// ImageFacePager — seam:collection
class ForgeImageFacePagerNav extends StatelessWidget {
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  /// G13a · קבוצת-פריטים: items[i] = חריצי-הטקסט של פריט i (0 חריצים · 4 בדמו · selected = הפריטים-הפעילים). null ⇒ פריטי-העיצוב.
  final List<List<String>>? items;
  final Set<int>? selected;
  static const int itemSlots = 0;
  static const int itemDemo = 4;
  String _it(List<String> r, int j, String d) => items == null ? d : (j < r.length ? r[j] : '');
  const ForgeImageFacePagerNav({super.key, this.child, this.items, this.selected});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final Widget body = Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(14)), child: _withChild(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 11, children: [Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [...(items == null ? <Widget>[Container(width: 22, height: 8, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(999)), child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: const SizedBox.shrink())])), Container(width: 8, height: 8, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(999)), child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: const SizedBox.shrink())])), Container(width: 8, height: 8, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(999)), child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: const SizedBox.shrink())])), Container(width: 8, height: 8, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(999)), child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: const SizedBox.shrink())]))] : List<Widget>.generate(items!.length, (i) => Flexible(child: ((selected?.contains(i) ?? false) ? Container(width: 22, height: 8, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(999)), child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: const SizedBox.shrink())])) : Container(width: 8, height: 8, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(999)), child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: const SizedBox.shrink())]))))))]), Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: skin.raised2, border: Border.all(color: theme.a, width: 2), borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 3)])), Container(width: 40, height: 40, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(10))), Container(width: 40, height: 40, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(10))), Container(width: 40, height: 40, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(10)))])]), child));
    return body;
  }
}
