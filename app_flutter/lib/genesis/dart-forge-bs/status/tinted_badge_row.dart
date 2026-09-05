// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "status" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/status-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// TintedBadgeRow — seam:fields · 3 חריצים
class ForgeTintedBadgeRow extends StatelessWidget {
  /// תפר-דאטה (G12a): 3 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 3;
  static const List<String> fieldDemo = <String>["LABEL 3", "LABEL 12", "LABEL 99+"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  static Widget _hide(String s, Widget w) => s.isEmpty ? const SizedBox.shrink() : w;   // G13a · חריץ-ריק ⇒ הקופסה נעלמת
  const ForgeTintedBadgeRow({super.key, this.fields, this.child});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Container(padding: const EdgeInsets.fromLTRB(2, 8, 2, 8), child: _withChild(Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [_hide(_f(0, "LABEL 3"), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(8, 3, 8, 3), decoration: BoxDecoration(color: theme.aHi.withValues(alpha: 0.130), border: Border.all(color: theme.aHi.withValues(alpha: 0.280)), borderRadius: BorderRadius.circular(6)), child: Text(_f(0, "LABEL 3"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.5))))), _hide(_f(1, "LABEL 12"), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(8, 3, 8, 3), decoration: BoxDecoration(color: skin.mut.withValues(alpha: 0.130), border: Border.all(color: skin.mut.withValues(alpha: 0.280)), borderRadius: BorderRadius.circular(6)), child: Text(_f(1, "LABEL 12"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.5))))), _hide(_f(2, "LABEL 99+"), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(8, 3, 8, 3), decoration: BoxDecoration(color: skin.err.withValues(alpha: 0.130), border: Border.all(color: skin.err.withValues(alpha: 0.280)), borderRadius: BorderRadius.circular(6)), child: Text(_f(2, "LABEL 99+"), style: TextStyle(color: skin.err, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.5)))))]), child));
    return body;
  }
}
