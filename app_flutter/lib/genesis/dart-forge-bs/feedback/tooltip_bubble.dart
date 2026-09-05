// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "feedback" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/feedback-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// TooltipBubble — seam:fields · 3 חריצים
class ForgeTooltipBubble extends StatelessWidget {
  /// תפר-דאטה (G12a): 3 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 3;
  static const List<String> fieldDemo = <String>["Label", "TooltipBubble", "FIELDS"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  static Widget _hide(String s, Widget w) => s.isEmpty ? const SizedBox.shrink() : w;   // G13a · חריץ-ריק ⇒ הקופסה נעלמת
  const ForgeTooltipBubble({super.key, this.fields, this.child});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(decoration: BoxDecoration(color: skin.ink, borderRadius: BorderRadius.circular(9), boxShadow: [BoxShadow(color: const Color(0x80000000), offset: const Offset(0, 8), blurRadius: 22, spreadRadius: 0)]), child: _withChild(Stack(clipBehavior: Clip.none, children: [Padding(padding: const EdgeInsets.fromLTRB(11, 8, 11, 8), child: Text(_f(0, "Label"), style: TextStyle(color: skin.canvas, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: fonts.he))), Positioned(bottom: -5, right: 18, width: 10, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: skin.ink)))]), child)), const SizedBox(height: 2), SizedBox(width: double.infinity, child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Flexible(child: Text(_f(1, "TooltipBubble"), style: TextStyle(color: skin.ink, fontSize: 16, fontFamily: fonts.he), overflow: TextOverflow.ellipsis, softWrap: false)), _hide(_f(2, "FIELDS"), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(5, 1, 5, 1), decoration: BoxDecoration(border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text(_f(2, "FIELDS"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 7.5, fontWeight: FontWeight.w600, letterSpacing: 1)))))]))]);
    return body;
  }
}
