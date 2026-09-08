// 🧩 חולל ע"י מפרק-החלקיקים הפתוח (particles · הכרעה-27): כל חלקיק נמצא בכל הקטלוג ומורכב מחדש. אל תערוך ידנית.
//   בדיקה = [תוכן בדיקה] ⇒ content ⇒ [group, alert] ⇒ DsNote
//   צבע = צבע ⇒ partition ⇒ [group, alert] ⇒ DsSection + DsNote

import '../dart-data-bs/auto/gen_app_peruk09_px2_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/auto/section_header.dart';
import 'package:flutter/material.dart';

class GenAppPeruk09Px2Screen extends StatelessWidget {
  const GenAppPeruk09Px2Screen({super.key});
  @override
  Widget build(BuildContext context) => DsScaffold(title: gen_app_peruk09_px2_c53, subtitle: gen_app_peruk09_px2_c54, icon: gen_app_peruk09_px2_c55, children: [
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [SectionHeader(gen_app_peruk09_px2_c25), DsNote(message: gen_app_peruk09_px2_c1, label: gen_app_peruk09_px2_c2, tone: 0)]), Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [SectionHeader(gen_app_peruk09_px2_c28), DsNote(message: gen_app_peruk09_px2_c4, label: gen_app_peruk09_px2_c5, tone: 0), DsNote(message: gen_app_peruk09_px2_c7, label: gen_app_peruk09_px2_c8, tone: 0), DsNote(message: gen_app_peruk09_px2_c10, label: gen_app_peruk09_px2_c11, tone: 0)]), Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [SectionHeader(gen_app_peruk09_px2_c31), DsNote(message: gen_app_peruk09_px2_c13, label: gen_app_peruk09_px2_c14, tone: 0), DsNote(message: gen_app_peruk09_px2_c16, label: gen_app_peruk09_px2_c17, tone: 0), DsNote(message: gen_app_peruk09_px2_c19, label: gen_app_peruk09_px2_c20, tone: 0), DsNote(message: gen_app_peruk09_px2_c22, label: gen_app_peruk09_px2_c23, tone: 0)])])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsSection(title: gen_app_peruk09_px2_c40 + ' · ' + appStore.records('app_peruk09_ent2').where((r) => (r[gen_app_peruk09_px2_c38] ?? '') == gen_app_peruk09_px2_c39).toList().length.toString(), children: [for (final r in appStore.records('app_peruk09_ent2').where((r) => (r[gen_app_peruk09_px2_c38] ?? '') == gen_app_peruk09_px2_c39).toList()) DsNote(message: (r[gen_app_peruk09_px2_c35] ?? ''), label: (r[gen_app_peruk09_px2_c36] ?? ''), tone: 0)], tone: 0), DsSection(title: gen_app_peruk09_px2_c45 + ' · ' + appStore.records('app_peruk09_ent2').where((r) => (r[gen_app_peruk09_px2_c43] ?? '') == gen_app_peruk09_px2_c44).toList().length.toString(), children: [for (final r in appStore.records('app_peruk09_ent2').where((r) => (r[gen_app_peruk09_px2_c43] ?? '') == gen_app_peruk09_px2_c44).toList()) DsNote(message: (r[gen_app_peruk09_px2_c35] ?? ''), label: (r[gen_app_peruk09_px2_c36] ?? ''), tone: 0)], tone: 0), DsSection(title: gen_app_peruk09_px2_c50 + ' · ' + appStore.records('app_peruk09_ent2').where((r) => (r[gen_app_peruk09_px2_c48] ?? '') == gen_app_peruk09_px2_c49).toList().length.toString(), children: [for (final r in appStore.records('app_peruk09_ent2').where((r) => (r[gen_app_peruk09_px2_c48] ?? '') == gen_app_peruk09_px2_c49).toList()) DsNote(message: (r[gen_app_peruk09_px2_c35] ?? ''), label: (r[gen_app_peruk09_px2_c36] ?? ''), tone: 0)], tone: 0)]))),
  ]);
}
