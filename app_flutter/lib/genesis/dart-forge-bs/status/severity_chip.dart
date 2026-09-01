// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "status" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/status-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// SeverityChip — seam:series
class ForgeSeverityChip extends StatelessWidget {
  const ForgeSeverityChip({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(4, 6, 4, 2), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 10, children: [Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 10, children: [Container(width: 64, child: Text("Low", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w700))), Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 3, children: [const SizedBox.shrink(), const SizedBox.shrink(), const SizedBox.shrink(), const SizedBox.shrink()]), Text("Meta", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 10))]), Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 10, children: [Container(width: 64, child: Text("Medium", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w700))), Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 3, children: [const SizedBox.shrink(), const SizedBox.shrink(), const SizedBox.shrink(), const SizedBox.shrink()]), Text("Meta", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 10))]), Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 10, children: [Container(width: 64, child: Text("High", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w700))), Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 3, children: [const SizedBox.shrink(), const SizedBox.shrink(), const SizedBox.shrink(), const SizedBox.shrink()]), Text("Meta", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 10))]), Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 10, children: [Container(width: 64, child: Text("Critical", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w700))), Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 3, children: [const SizedBox.shrink(), const SizedBox.shrink(), const SizedBox.shrink(), const SizedBox.shrink()]), Text("Meta", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 10))])]));
  }
}
