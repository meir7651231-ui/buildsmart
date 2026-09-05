// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "temporal" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/temporal-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// LiveClock + RelativeTime — seam:fields · 4 חריצים
class ForgeLiveClockRelativeTime extends StatelessWidget {
  /// תפר-דאטה (G12a): 4 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 4;
  static const List<String> fieldDemo = <String>["14:32:07", "Label · Meta", "RELATIVETIME · ", "META"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  const ForgeLiveClockRelativeTime({super.key, this.fields, this.child});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), child: _withChild(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.fromLTRB(0, 12, 0, 12), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Directionality(textDirection: TextDirection.ltr, child: Text(_f(0, "14:32:07"), style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 44, fontWeight: FontWeight.w700, letterSpacing: 0.88, fontFeatures: const [FontFeature.tabularFigures()]))), const SizedBox(height: 4), Directionality(textDirection: TextDirection.ltr, child: Text(_f(1, "Label · Meta"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11)))])), Directionality(textDirection: TextDirection.ltr, child: Container(margin: const EdgeInsets.fromLTRB(0, 10, 0, 0), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Container(width: 6, height: 6, decoration: BoxDecoration(color: theme.a, borderRadius: BorderRadius.circular(999))), Text(_f(2, "RELATIVETIME · "), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10, letterSpacing: 1.20)), Flexible(child: Text(_f(3, "META"), style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis, softWrap: false))])))]), child));
    return body;
  }
}
