// 🧩 חולל ע"י מפרק-החלקיקים הפתוח (particles · הכרעה-27): כל חלקיק נמצא בכל הקטלוג ומורכב מחדש. אל תערוך ידנית.
//   טבלה = [טבלה] ⇒ table ⇒ [table] ⇒ DsTable
//   פעולה פתח תיק = [פעולה] פתח תיק ⇒ act ⇒ [action] ⇒ DsChipButton
//   ריק אין תיקים עדיין = [ריק] אין תיקים עדיין ⇒ empty ⇒ [empty] ⇒ EmptyState@premium/feedback
//   מסגרת = [תוכן מסגרת] ⇒ content ⇒ [alert] ⇒ DsNote
//   בלוקים = [תוכן בלוקים] ⇒ content ⇒ [alert] ⇒ DsNote
//   אסור = [תוכן אסור] ⇒ content ⇒ [alert] ⇒ DsNote

import '../dart-data-bs/auto/gen_app_peruk09_px1_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-forge-bs/composite/split_control.dart';
import '../dart-forge-bs/spatial/data_grid.dart';
import '../dart-forge-bs/temporal/event_calendar.dart';
import '../dart-ui-bs/auto/empty_state.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import 'gen_app_peruk09_ent1.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/spatial/spatial.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppPeruk09Px1Screen extends StatelessWidget {
  const GenAppPeruk09Px1Screen({super.key});
  @override
  Widget build(BuildContext context) => DsScaffold(title: gen_app_peruk09_px1_c75, subtitle: gen_app_peruk09_px1_c76, icon: gen_app_peruk09_px1_c77, children: [
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeDataGrid(bare: true, columns: [gen_app_peruk09_px1_c1, gen_app_peruk09_px1_c2, gen_app_peruk09_px1_c3, gen_app_peruk09_px1_c4, gen_app_peruk09_px1_c5, gen_app_peruk09_px1_c6, gen_app_peruk09_px1_c7], items: [for (final r in appStore.records('app_peruk09_ent1')) [(r[gen_app_peruk09_px1_c8] ?? ''), (r[gen_app_peruk09_px1_c9] ?? ''), (r[gen_app_peruk09_px1_c10] ?? ''), (r[gen_app_peruk09_px1_c11] ?? ''), (r[gen_app_peruk09_px1_c12] ?? ''), (r[gen_app_peruk09_px1_c13] ?? ''), (r[gen_app_peruk09_px1_c14] ?? '')]]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: DsChipButton(label: gen_app_peruk09_px1_c16, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk09Ent1Screen())))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => appStore.records('app_peruk09_ent1').isEmpty ? EmptyState(label: gen_app_peruk09_px1_c18) : const SizedBox.shrink())),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk09_px1_c22, label: gen_app_peruk09_px1_c23, tone: 0), DsNote(message: gen_app_peruk09_px1_c25, label: gen_app_peruk09_px1_c26, tone: 0), DsNote(message: gen_app_peruk09_px1_c28, label: gen_app_peruk09_px1_c29, tone: 0), DsNote(message: gen_app_peruk09_px1_c31, label: gen_app_peruk09_px1_c32, tone: 0), DsNote(message: gen_app_peruk09_px1_c34, label: gen_app_peruk09_px1_c35, tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk09_px1_c38, label: gen_app_peruk09_px1_c39, tone: 0), DsNote(message: gen_app_peruk09_px1_c41, label: gen_app_peruk09_px1_c42, tone: 0), DsNote(message: gen_app_peruk09_px1_c44, label: gen_app_peruk09_px1_c45, tone: 0), DsNote(message: gen_app_peruk09_px1_c47, label: gen_app_peruk09_px1_c48, tone: 0), DsNote(message: gen_app_peruk09_px1_c50, label: gen_app_peruk09_px1_c51, tone: 0), DsNote(message: gen_app_peruk09_px1_c53, label: gen_app_peruk09_px1_c54, tone: 0), DsNote(message: gen_app_peruk09_px1_c56, label: gen_app_peruk09_px1_c57, tone: 0), DsNote(message: gen_app_peruk09_px1_c59, label: gen_app_peruk09_px1_c60, tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk09_px1_c63, label: gen_app_peruk09_px1_c64, tone: 0), DsNote(message: gen_app_peruk09_px1_c66, label: gen_app_peruk09_px1_c67, tone: 0), DsNote(message: gen_app_peruk09_px1_c69, label: gen_app_peruk09_px1_c70, tone: 0), DsNote(message: gen_app_peruk09_px1_c72, label: gen_app_peruk09_px1_c73, tone: 0)])),
  ]);
}
