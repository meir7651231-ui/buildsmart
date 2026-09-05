// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "feedback" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/feedback-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// SkeletonCard — seam:fields
class ForgeSkeletonCard extends StatelessWidget {
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  /// G13a · קבוצת-פריטים: items[i] = חריצי-הטקסט של פריט i (0 חריצים · 2 בדמו). null ⇒ פריטי-העיצוב.
  final List<List<String>>? items;
  static const int itemSlots = 0;
  static const int itemDemo = 2;
  String _it(List<String> r, int j, String d) => items == null ? d : (j < r.length ? r[j] : '');
  /// G13a · מילויי-אחוז (0..1) לפי סדר-הופעה/פריט (2 בדמו). null ⇒ ערכי-העיצוב; חסר ⇒ 0 (אין המצאה).
  final List<double>? values;
  double _v(int i, double d) => values == null ? d : (i < values!.length ? values![i].clamp(0.0, 1.0) : 0.0);
  const ForgeSkeletonCard({super.key, this.child, this.items, this.values});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final Widget body = _withChild(Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 12, children: [Container(width: 44, height: 44, decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.raised, skin.raised2, skin.raised], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(12))), Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 10, children: [...(items == null ? <Widget>[FractionallySizedBox(widthFactor: _v(0, 0.600), alignment: Alignment.centerRight, child: Container(height: 12, decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.raised, skin.raised2, skin.raised], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(7)))), FractionallySizedBox(widthFactor: _v(1, 0.900), alignment: Alignment.centerRight, child: Container(height: 12, decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.raised, skin.raised2, skin.raised], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(7))))] : List<Widget>.generate(items!.length, (i) => FractionallySizedBox(widthFactor: _v(i, 0.600), alignment: Alignment.centerRight, child: Container(height: 12, decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.raised, skin.raised2, skin.raised], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(7))))))]))]), child);
    return body;
  }
}
