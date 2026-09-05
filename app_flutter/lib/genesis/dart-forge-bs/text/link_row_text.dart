// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "text" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/text-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// LinkRow — seam:collection · 10 חריצים
class ForgeLinkRowText extends StatelessWidget {
  /// תפר-דאטה (G12a): 10 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 10;
  static const List<String> fieldDemo = <String>["שורה עם ", "קישור מודגש", " וגם ", "קו תחתון", " בתוך פסקה — כל מצב נגזר מ-var(--a).", "Label", "·", "Label", "·", "Meta"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  static Widget _hide(String s, Widget w) => s.isEmpty ? const SizedBox.shrink() : w;   // G13a · חריץ-ריק ⇒ הקופסה נעלמת
  /// G13a · הקשה על כפתור/קישור k (סדר-הופעה, 5 פעולות).
  final void Function(int)? onAction;
  static const int actionSlots = 5;
  const ForgeLinkRowText({super.key, this.fields, this.child, this.onAction});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Container(padding: const EdgeInsets.fromLTRB(18, 18, 18, 18), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: _withChild(IntrinsicWidth(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_f(0, "שורה עם "), style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 14.5, height: 1.9, leadingDistribution: TextLeadingDistribution.even)), GestureDetector(behavior: HitTestBehavior.opaque, onTap: onAction == null ? null : () => onAction!(0), child: _hide(_f(1, "קישור מודגש"), Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.a.withValues(alpha: 0.400), width: 1))), child: Text(_f(1, "קישור מודגש"), style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 14.5, fontWeight: FontWeight.w600, height: 1.9, leadingDistribution: TextLeadingDistribution.even))))), Text(_f(2, " וגם "), style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 14.5, height: 1.9, leadingDistribution: TextLeadingDistribution.even)), GestureDetector(behavior: HitTestBehavior.opaque, onTap: onAction == null ? null : () => onAction!(1), child: Text(_f(3, "קו תחתון"), style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 14.5, height: 1.9, leadingDistribution: TextLeadingDistribution.even))), Text(_f(4, " בתוך פסקה — כל מצב נגזר מ-var(--a)."), style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 14.5, height: 1.9, leadingDistribution: TextLeadingDistribution.even)), const SizedBox(height: 12), Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [Directionality(textDirection: TextDirection.ltr, child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 10, children: [GestureDetector(behavior: HitTestBehavior.opaque, onTap: onAction == null ? null : () => onAction!(2), child: Text(_f(5, "Label"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12, height: 1.9, leadingDistribution: TextLeadingDistribution.even))), Text(_f(6, "·"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12, height: 1.9, leadingDistribution: TextLeadingDistribution.even)), GestureDetector(behavior: HitTestBehavior.opaque, onTap: onAction == null ? null : () => onAction!(3), child: Text(_f(7, "Label"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12, height: 1.9, leadingDistribution: TextLeadingDistribution.even))), Text(_f(8, "·"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12, height: 1.9, leadingDistribution: TextLeadingDistribution.even)), GestureDetector(behavior: HitTestBehavior.opaque, onTap: onAction == null ? null : () => onAction!(4), child: Text(_f(9, "Meta"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12, height: 1.9, leadingDistribution: TextLeadingDistribution.even)))]))])])), child));
    return body;
  }
}
