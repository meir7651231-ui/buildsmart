// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "text" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/text-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// PullQuote — seam:fields
class ForgePullQuote extends StatelessWidget {
  const ForgePullQuote({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(24, 22, 24, 22), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Container(padding: const EdgeInsets.fromLTRB(24, 8, 24, 8), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("”", style: TextStyle(color: theme.aHi, fontFamily: fonts.he)), Text("הטיפוגרפיה היא הקול של הממשק לפני שאמרנו מילה — הסולם, המשקל והמרווח מכריעים מה נקרא ראשון.", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("“", style: TextStyle(color: theme.aHi, fontFamily: fonts.he))]), Text("Meta · Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he))])));
  }
}
