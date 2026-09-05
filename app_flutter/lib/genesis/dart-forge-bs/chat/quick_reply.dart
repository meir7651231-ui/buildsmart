// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "chat" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/chat-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// QuickReply — seam:fields · 4 חריצים
class ForgeQuickReply extends StatelessWidget {
  /// תפר-דאטה (G12a): 4 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 4;
  static const List<String> fieldDemo = <String>["Label", "Label", "Value", "Label"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  static Widget _hide(String s, Widget w) => s.isEmpty ? const SizedBox.shrink() : w;   // G13a · חריץ-ריק ⇒ הקופסה נעלמת
  /// G13b · bare=true ⇒ ליבת-הבקרה בלי מסגרת-הגלריה של Pure (.ctl/.body/.stage); child נכנס לליבה. false ⇒ ביט-זהה לגלריה.
  final bool bare;
  /// G13a · קבוצת-פריטים: items[i] = חריצי-הטקסט של פריט i (1 חריצים · 4 בדמו). null ⇒ פריטי-העיצוב.
  final List<List<String>>? items;
  static const int itemSlots = 1;
  static const int itemDemo = 4;
  String _it(List<String> r, int j, String d) => items == null ? d : (j < r.length ? r[j] : '');
  const ForgeQuickReply({super.key, this.fields, this.child, this.bare = false, this.items});
  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget core = Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [...(items == null ? <Widget>[_hide(_f(0, "Label"), Container(constraints: const BoxConstraints(minHeight: 38), padding: const EdgeInsets.fromLTRB(14, 8, 14, 8), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.100), border: Border.all(color: theme.a800), borderRadius: BorderRadius.circular(999)), child: Text(_f(0, "Label"), style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 12.5)))), _hide(_f(1, "Label"), Container(constraints: const BoxConstraints(minHeight: 38), padding: const EdgeInsets.fromLTRB(14, 8, 14, 8), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.100), border: Border.all(color: theme.a800), borderRadius: BorderRadius.circular(999)), child: Text(_f(1, "Label"), style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 12.5)))), _hide(_f(2, "Value"), Container(constraints: const BoxConstraints(minHeight: 38), padding: const EdgeInsets.fromLTRB(14, 8, 14, 8), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.100), border: Border.all(color: theme.a800), borderRadius: BorderRadius.circular(999)), child: Text(_f(2, "Value"), style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 12.5)))), _hide(_f(3, "Label"), Container(constraints: const BoxConstraints(minHeight: 38), padding: const EdgeInsets.fromLTRB(14, 8, 14, 8), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.100), border: Border.all(color: theme.a800), borderRadius: BorderRadius.circular(999)), child: Text(_f(3, "Label"), style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 12.5))))] : List<Widget>.generate(items!.length, (i) => _hide(_it(items![i], 0, "Label"), Container(constraints: const BoxConstraints(minHeight: 38), padding: const EdgeInsets.fromLTRB(14, 8, 14, 8), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.100), border: Border.all(color: theme.a800), borderRadius: BorderRadius.circular(999)), child: Text(_it(items![i], 0, "Label"), style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 12.5))))))]);
    final Widget body = bare ? _withChild(core, child) : Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), child: _withChild(core, child));
    return body;
  }
}
