// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// PremiumToggle — seam:fields · מצבים חיים · 1 חריצים
enum ForgePremiumToggleState { state, state1, state2, state3 }

class ForgePremiumToggle extends StatelessWidget {
  final ForgePremiumToggleState state;
  /// תפר-דאטה (G12a): 1 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 1;
  static const List<String> fieldDemo = <String>["on"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  /// G13a · הקשה על כפתור/קישור k (סדר-הופעה, 1 פעולות).
  final void Function(int)? onAction;
  static const int actionSlots = 1;
  const ForgePremiumToggle({super.key, this.state = ForgePremiumToggleState.state, this.fields, this.child, this.onAction});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = switch (state) {
      ForgePremiumToggleState.state => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [GestureDetector(behavior: HitTestBehavior.opaque, onTap: onAction == null ? null : () => onAction!(0), child: Container(width: 46, height: 27, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.centerLeft, end: Alignment.centerRight), border: Border.all(color: const Color(0x2EFFFFFF)), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 3), blurRadius: 10, spreadRadius: 0)]), child: _withChild(Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: const SizedBox.shrink()), Positioned(top: 2, right: 2, width: 21, child: Container(width: 21, height: 21, decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: const Color(0x59000000), offset: const Offset(0, 2), blurRadius: 4, spreadRadius: 0)])))]), child))), Text(_f(0, "on"), style: TextStyle(color: skin.ink, fontSize: 16, fontFamily: fonts.he))]),
      ForgePremiumToggleState.state1 => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [GestureDetector(behavior: HitTestBehavior.opaque, onTap: onAction == null ? null : () => onAction!(0), child: Container(width: 46, height: 27, alignment: Alignment.center, decoration: BoxDecoration(color: skin.raised, border: Border.all(color: const Color(0x2EFFFFFF)), borderRadius: BorderRadius.circular(999)), child: _withChild(Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: const SizedBox.shrink()), Positioned(top: 2, right: 2, width: 21, child: Container(width: 21, height: 21, decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: const Color(0x59000000), offset: const Offset(0, 2), blurRadius: 4, spreadRadius: 0)])))]), child))), Text(_f(0, "off"), style: TextStyle(color: skin.ink, fontSize: 16, fontFamily: fonts.he))]),
      ForgePremiumToggleState.state2 => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [GestureDetector(behavior: HitTestBehavior.opaque, onTap: onAction == null ? null : () => onAction!(0), child: Container(width: 46, height: 27, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.centerLeft, end: Alignment.centerRight), border: Border.all(color: const Color(0x2EFFFFFF)), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 3), blurRadius: 10, spreadRadius: 0)]), child: _withChild(Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: const SizedBox.shrink()), Positioned(top: 2, right: 2, width: 21, child: Container(width: 21, height: 21, decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: const Color(0x59000000), offset: const Offset(0, 2), blurRadius: 4, spreadRadius: 0)])))]), child))), Text(_f(0, "focus"), style: TextStyle(color: skin.ink, fontSize: 16, fontFamily: fonts.he))]),
      ForgePremiumToggleState.state3 => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [GestureDetector(behavior: HitTestBehavior.opaque, onTap: onAction == null ? null : () => onAction!(0), child: Opacity(opacity: 0.5, child: Container(width: 46, height: 27, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.centerLeft, end: Alignment.centerRight), border: Border.all(color: const Color(0x2EFFFFFF)), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 3), blurRadius: 10, spreadRadius: 0)]), child: _withChild(Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: const SizedBox.shrink()), Positioned(top: 2, right: 2, width: 21, child: Container(width: 21, height: 21, decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: const Color(0x59000000), offset: const Offset(0, 2), blurRadius: 4, spreadRadius: 0)])))]), child)))), Text(_f(0, "disabled"), style: TextStyle(color: skin.ink, fontSize: 16, fontFamily: fonts.he))]),
    };
    return body;
  }
}
