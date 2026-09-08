// 🧩 חולל ע"י מפרק-החלקיקים הפתוח (particles · הכרעה-27): כל חלקיק נמצא בכל הקטלוג ומורכב מחדש. אל תערוך ידנית.
//   שכירות לשנה = שכירות לשנה ⇒ raw ⇒ [fact] ⇒ DsChip
//   טבלה = [טבלה] ⇒ table ⇒ [table] ⇒ DsTable
//   פעולה פתח תיק = [פעולה] פתח תיק ⇒ act ⇒ [action] ⇒ DsPrimaryButton
//   החלטה = החלטה ⇒ partition ⇒ [group, alert] ⇒ DsSection + DsNote
//   אסור בפלט = [תוכן אסור] ⇒ content ⇒ [alert] ⇒ DsNote

import '../dart-data-bs/auto/gen_app_sechirut_px1_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-forge-bs/composite/split_control.dart';
import '../dart-forge-bs/spatial/data_grid.dart';
import '../dart-forge-bs/temporal/event_calendar.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import 'gen_app_sechirut_ent1.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/spatial/spatial.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/status/status.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppSechirutPx1Screen extends StatelessWidget {
  const GenAppSechirutPx1Screen({super.key});
  @override
  Widget build(BuildContext context) => DsScaffold(title: gen_app_sechirut_px1_c69, subtitle: gen_app_sechirut_px1_c70, icon: gen_app_sechirut_px1_c71, children: [
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in appStore.records('app_sechirut_ent1').where((r) => (r[gen_app_sechirut_px1_c5] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[(r[gen_app_sechirut_px1_c1] ?? '')]], variants: const <int>[0]))]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeDataGrid(bare: true, columns: [gen_app_sechirut_px1_c7, gen_app_sechirut_px1_c8, gen_app_sechirut_px1_c9, gen_app_sechirut_px1_c10, gen_app_sechirut_px1_c11, gen_app_sechirut_px1_c12, gen_app_sechirut_px1_c13, gen_app_sechirut_px1_c14, gen_app_sechirut_px1_c15, gen_app_sechirut_px1_c16, gen_app_sechirut_px1_c17, gen_app_sechirut_px1_c18], items: [for (final r in appStore.records('app_sechirut_ent1')) [(r[gen_app_sechirut_px1_c19] ?? ''), (r[gen_app_sechirut_px1_c20] ?? ''), (r[gen_app_sechirut_px1_c21] ?? ''), (r[gen_app_sechirut_px1_c22] ?? ''), (r[gen_app_sechirut_px1_c23] ?? ''), (r[gen_app_sechirut_px1_c24] ?? ''), (r[gen_app_sechirut_px1_c25] ?? ''), (r[gen_app_sechirut_px1_c26] ?? ''), (r[gen_app_sechirut_px1_c27] ?? ''), (r[gen_app_sechirut_px1_c28] ?? ''), (r[gen_app_sechirut_px1_c29] ?? ''), (r[gen_app_sechirut_px1_c30] ?? '')]]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutEnt1Screen())), child: ForgeToneButton(items: [[gen_app_sechirut_px1_c32]]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsSection(title: gen_app_sechirut_px1_c40 + ' · ' + appStore.records('app_sechirut_ent1').where((r) => (r[gen_app_sechirut_px1_c38] ?? '') == gen_app_sechirut_px1_c39).toList().length.toString(), children: [for (final r in appStore.records('app_sechirut_ent1').where((r) => (r[gen_app_sechirut_px1_c38] ?? '') == gen_app_sechirut_px1_c39).toList()) DsNote(message: (r[gen_app_sechirut_px1_c35] ?? ''), label: (r[gen_app_sechirut_px1_c36] ?? ''), tone: 0)], tone: 0), DsSection(title: gen_app_sechirut_px1_c45 + ' · ' + appStore.records('app_sechirut_ent1').where((r) => (r[gen_app_sechirut_px1_c43] ?? '') == gen_app_sechirut_px1_c44).toList().length.toString(), children: [for (final r in appStore.records('app_sechirut_ent1').where((r) => (r[gen_app_sechirut_px1_c43] ?? '') == gen_app_sechirut_px1_c44).toList()) DsNote(message: (r[gen_app_sechirut_px1_c35] ?? ''), label: (r[gen_app_sechirut_px1_c36] ?? ''), tone: 0)], tone: 0), DsSection(title: gen_app_sechirut_px1_c50 + ' · ' + appStore.records('app_sechirut_ent1').where((r) => (r[gen_app_sechirut_px1_c48] ?? '') == gen_app_sechirut_px1_c49).toList().length.toString(), children: [for (final r in appStore.records('app_sechirut_ent1').where((r) => (r[gen_app_sechirut_px1_c48] ?? '') == gen_app_sechirut_px1_c49).toList()) DsNote(message: (r[gen_app_sechirut_px1_c35] ?? ''), label: (r[gen_app_sechirut_px1_c36] ?? ''), tone: 0)], tone: 0)]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_sechirut_px1_c54, label: gen_app_sechirut_px1_c55, tone: 0), DsNote(message: gen_app_sechirut_px1_c57, label: gen_app_sechirut_px1_c58, tone: 0), DsNote(message: gen_app_sechirut_px1_c60, label: gen_app_sechirut_px1_c61, tone: 0), DsNote(message: gen_app_sechirut_px1_c63, label: gen_app_sechirut_px1_c64, tone: 0), DsNote(message: gen_app_sechirut_px1_c66, label: gen_app_sechirut_px1_c67, tone: 0)])),
  ]);
}
