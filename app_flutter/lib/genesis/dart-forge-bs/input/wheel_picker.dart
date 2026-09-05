// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// WheelPicker — seam:self
class ForgeWheelPicker extends StatelessWidget {
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  /// G13a · קבוצת-פריטים: items[i] = חריצי-הטקסט של פריט i (0 חריצים · 2 בדמו · לחיץ: onSelect(i)). null ⇒ פריטי-העיצוב.
  final List<List<String>>? items;
  final void Function(int)? onSelect;
  static const int itemSlots = 0;
  static const int itemDemo = 2;
  String _it(List<String> r, int j, String d) => items == null ? d : (j < r.length ? r[j] : '');
  const ForgeWheelPicker({super.key, this.child, this.items, this.onSelect});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final Widget body = Container(padding: const EdgeInsets.fromLTRB(0, 2, 0, 2), child: _withChild(Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 14, children: [...(items == null ? <Widget>[Container(width: 132, height: 264, decoration: BoxDecoration(gradient: RadialGradient(center: Alignment(0.00, 0.00), radius: 1.20, colors: [skin.surface, skin.sunken], stops: [0.0, 1.0]), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: const SizedBox.shrink()), Positioned(left: 0, right: 0, child: Opacity(opacity: 0.6, child: Container(height: 48, padding: const EdgeInsets.fromLTRB(0, 22, 0, 22), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.080), border: Border(top: BorderSide(color: theme.a, width: 1), bottom: BorderSide(color: theme.a, width: 1))))))])), Container(width: 132, height: 264, decoration: BoxDecoration(gradient: RadialGradient(center: Alignment(0.00, 0.00), radius: 1.20, colors: [skin.surface, skin.sunken], stops: [0.0, 1.0]), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: const SizedBox.shrink()), Positioned(left: 0, right: 0, child: Opacity(opacity: 0.6, child: Container(height: 48, padding: const EdgeInsets.fromLTRB(0, 22, 0, 22), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.080), border: Border(top: BorderSide(color: theme.a, width: 1), bottom: BorderSide(color: theme.a, width: 1))))))]))] : List<Widget>.generate(items!.length, (i) => Flexible(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onSelect == null ? null : () => onSelect!(i), child: Container(width: 132, height: 264, decoration: BoxDecoration(gradient: RadialGradient(center: Alignment(0.00, 0.00), radius: 1.20, colors: [skin.surface, skin.sunken], stops: [0.0, 1.0]), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: const SizedBox.shrink()), Positioned(left: 0, right: 0, child: Opacity(opacity: 0.6, child: Container(height: 48, padding: const EdgeInsets.fromLTRB(0, 22, 0, 22), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.080), border: Border(top: BorderSide(color: theme.a, width: 1), bottom: BorderSide(color: theme.a, width: 1))))))]))))))]), child));
    return body;
  }
}
