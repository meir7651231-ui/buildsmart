// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "motion" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/motion-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// GenerativeCanvas — seam:fields · 1 חריצים
class ForgeGenerativeCanvas extends StatelessWidget {
  /// תפר-דאטה (G12a): 1 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 1;
  static const List<String> fieldDemo = <String>["ORGANISM"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  const ForgeGenerativeCanvas({super.key, this.fields, this.child});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Container(height: 150, decoration: BoxDecoration(color: skin.sunken), child: _withChild(SizedBox(width: double.infinity, child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: SizedBox(width: double.infinity, child: const SizedBox.shrink())), Positioned(top: 10, right: 10, child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Container(width: 7, height: 7, decoration: BoxDecoration(color: skin.ok, borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: skin.ok, offset: const Offset(0, 0), blurRadius: 9, spreadRadius: 0)])), Text(_f(0, "ORGANISM"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 8.5, letterSpacing: 1.36))]))])), child));
    return body;
  }
}
