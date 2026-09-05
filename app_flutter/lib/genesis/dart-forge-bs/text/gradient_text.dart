// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "text" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/text-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// GradientText — seam:series · 2 חריצים
class ForgeGradientText extends StatelessWidget {
  /// תפר-דאטה (G12a): 2 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 2;
  static const List<String> fieldDemo = <String>["כותרת מדורגת", "GRADIENT · TEXT"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  /// G13d · וריאנט-פריט (טוקן-עיצוב: ["","mono"]) — variants[i] = אינדקס-הוריאנט של פריט i; null ⇒ הראשון.
  final List<int>? variants;
  static const List<String> variantIds = <String>["", "mono"];
  /// G13a · קבוצת-פריטים: items[i] = חריצי-הטקסט של פריט i (1 חריצים · 2 בדמו). null ⇒ פריטי-העיצוב.
  final List<List<String>>? items;
  static const int itemSlots = 1;
  static const int itemDemo = 2;
  String _it(List<String> r, int j, String d) => items == null ? d : (j < r.length ? r[j] : '');
  const ForgeGradientText({super.key, this.fields, this.child, this.items, this.variants});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Container(padding: const EdgeInsets.fromLTRB(24, 22, 24, 22), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: _withChild(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [...(items == null ? <Widget>[ShaderMask(shaderCallback: (b) => LinearGradient(colors: [theme.c2, theme.a, theme.c3], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(b), blendMode: BlendMode.srcIn, child: Text(_f(0, "כותרת מדורגת"), style: TextStyle(color: const Color(0xFFFFFFFF), fontFamily: fonts.serifHe, fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.34, height: 1.08, leadingDistribution: TextLeadingDistribution.even))), Directionality(textDirection: TextDirection.ltr, child: ShaderMask(shaderCallback: (b) => LinearGradient(colors: [theme.c2, theme.a, theme.c3], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(b), blendMode: BlendMode.srcIn, child: Text(_f(1, "GRADIENT · TEXT"), style: TextStyle(color: const Color(0xFFFFFFFF), fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 2, height: 1.08, leadingDistribution: TextLeadingDistribution.even))))] : List<Widget>.generate(items!.length, (i) => (switch ((variants != null && i < variants!.length) ? variants![i] : 0) { 0 => ShaderMask(shaderCallback: (b) => LinearGradient(colors: [theme.c2, theme.a, theme.c3], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(b), blendMode: BlendMode.srcIn, child: Text(_it(items![i], 0, "כותרת מדורגת"), style: TextStyle(color: const Color(0xFFFFFFFF), fontFamily: fonts.serifHe, fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.34, height: 1.08, leadingDistribution: TextLeadingDistribution.even))), 1 => Directionality(textDirection: TextDirection.ltr, child: ShaderMask(shaderCallback: (b) => LinearGradient(colors: [theme.c2, theme.a, theme.c3], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(b), blendMode: BlendMode.srcIn, child: Text(_it(items![i], 0, "GRADIENT · TEXT"), style: TextStyle(color: const Color(0xFFFFFFFF), fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 2, height: 1.08, leadingDistribution: TextLeadingDistribution.even)))), _ => ShaderMask(shaderCallback: (b) => LinearGradient(colors: [theme.c2, theme.a, theme.c3], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(b), blendMode: BlendMode.srcIn, child: Text(_it(items![i], 0, "כותרת מדורגת"), style: TextStyle(color: const Color(0xFFFFFFFF), fontFamily: fonts.serifHe, fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.34, height: 1.08, leadingDistribution: TextLeadingDistribution.even))) })))]), child));
    return body;
  }
}
