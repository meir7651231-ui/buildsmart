// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "temporal" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/temporal-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// RangePicker — seam:fields · 7 חריצים
class ForgeRangePicker extends StatelessWidget {
  /// תפר-דאטה (G12a): 7 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 7;
  static const List<String> fieldDemo = <String>["א", "ב", "ג", "ד", "ה", "ו", "ש"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  const ForgeRangePicker({super.key, this.fields, this.child});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), child: _withChild(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Row(crossAxisAlignment: CrossAxisAlignment.center, spacing: 3, children: [Expanded(flex: 1, child: Text(_f(0, "א"), textAlign: TextAlign.center, style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5, letterSpacing: 0.48))), Expanded(flex: 1, child: Text(_f(1, "ב"), textAlign: TextAlign.center, style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5, letterSpacing: 0.48))), Expanded(flex: 1, child: Text(_f(2, "ג"), textAlign: TextAlign.center, style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5, letterSpacing: 0.48))), Expanded(flex: 1, child: Text(_f(3, "ד"), textAlign: TextAlign.center, style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5, letterSpacing: 0.48))), Expanded(flex: 1, child: Text(_f(4, "ה"), textAlign: TextAlign.center, style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5, letterSpacing: 0.48))), Expanded(flex: 1, child: Text(_f(5, "ו"), textAlign: TextAlign.center, style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5, letterSpacing: 0.48))), Expanded(flex: 1, child: Text(_f(6, "ש"), textAlign: TextAlign.center, style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5, letterSpacing: 0.48)))]), const SizedBox(height: 5), const SizedBox.shrink()]), child));
    return body;
  }
}
