// 🧩 חולל ע"י מפרק-החלקיקים הפתוח (particles · הכרעה-27): כל חלקיק נמצא בכל הקטלוג ומורכב מחדש. אל תערוך ידנית.
//   טבלה = [טבלה] ⇒ table ⇒ [table] ⇒ DsTable
//   פעולה פתח תיק = [פעולה] פתח תיק ⇒ act ⇒ [action] ⇒ DsChipButton
//   ריק אין תיקים עדיין = [ריק] אין תיקים עדיין ⇒ empty ⇒ [empty] ⇒ EmptyState@premium/feedback
//   מסגרת = [תוכן מסגרת] ⇒ content ⇒ [alert] ⇒ DsNote
//   בלוקים = [תוכן בלוקים] ⇒ content ⇒ [alert] ⇒ DsNote
//   סיווג = [תוכן סיווג] ⇒ content ⇒ [group, alert] ⇒ DsNote
//   אסור = [תוכן אסור] ⇒ content ⇒ [alert] ⇒ DsNote

import '../dart-data-bs/auto/gen_app_peruk27_px1_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-forge-bs/composite/split_control.dart';
import '../dart-forge-bs/spatial/data_grid.dart';
import '../dart-forge-bs/temporal/event_calendar.dart';
import '../dart-ui-bs/auto/empty_state.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import 'gen_app_peruk27_ent1.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/spatial/spatial.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppPeruk27Px1Screen extends StatelessWidget {
  const GenAppPeruk27Px1Screen({super.key});
  @override
  Widget build(BuildContext context) => DsScaffold(title: gen_app_peruk27_px1_c97, subtitle: gen_app_peruk27_px1_c98, icon: gen_app_peruk27_px1_c99, children: [
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeDataGrid(bare: true, columns: [gen_app_peruk27_px1_c1, gen_app_peruk27_px1_c2, gen_app_peruk27_px1_c3, gen_app_peruk27_px1_c4], items: [for (final r in appStore.records('app_peruk27_ent1')) [(r[gen_app_peruk27_px1_c5] ?? ''), (r[gen_app_peruk27_px1_c6] ?? ''), (r[gen_app_peruk27_px1_c7] ?? ''), (r[gen_app_peruk27_px1_c8] ?? '')]]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: DsChipButton(label: gen_app_peruk27_px1_c10, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk27Ent1Screen())))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => appStore.records('app_peruk27_ent1').isEmpty ? EmptyState(label: gen_app_peruk27_px1_c12) : const SizedBox.shrink())),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk27_px1_c16, label: gen_app_peruk27_px1_c17, tone: 0), DsNote(message: gen_app_peruk27_px1_c19, label: gen_app_peruk27_px1_c20, tone: 0), DsNote(message: gen_app_peruk27_px1_c22, label: gen_app_peruk27_px1_c23, tone: 0), DsNote(message: gen_app_peruk27_px1_c25, label: gen_app_peruk27_px1_c26, tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk27_px1_c29, label: gen_app_peruk27_px1_c30, tone: 0), DsNote(message: gen_app_peruk27_px1_c32, label: gen_app_peruk27_px1_c33, tone: 0), DsNote(message: gen_app_peruk27_px1_c35, label: gen_app_peruk27_px1_c36, tone: 0), DsNote(message: gen_app_peruk27_px1_c38, label: gen_app_peruk27_px1_c39, tone: 0), DsNote(message: gen_app_peruk27_px1_c41, label: gen_app_peruk27_px1_c42, tone: 0), DsNote(message: gen_app_peruk27_px1_c44, label: gen_app_peruk27_px1_c45, tone: 0), DsNote(message: gen_app_peruk27_px1_c47, label: gen_app_peruk27_px1_c48, tone: 0), DsNote(message: gen_app_peruk27_px1_c50, label: gen_app_peruk27_px1_c51, tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsSection(title: gen_app_peruk27_px1_c69, children: [DsNote(message: gen_app_peruk27_px1_c54, label: gen_app_peruk27_px1_c55, tone: 0)], tone: 0), DsSection(title: gen_app_peruk27_px1_c72, children: [DsNote(message: gen_app_peruk27_px1_c57, label: gen_app_peruk27_px1_c58, tone: 0)], tone: 0), DsSection(title: gen_app_peruk27_px1_c75, children: [DsNote(message: gen_app_peruk27_px1_c60, label: gen_app_peruk27_px1_c61, tone: 0)], tone: 0), DsSection(title: gen_app_peruk27_px1_c78, children: [DsNote(message: gen_app_peruk27_px1_c63, label: gen_app_peruk27_px1_c64, tone: 0)], tone: 0), DsSection(title: gen_app_peruk27_px1_c81, children: [DsNote(message: gen_app_peruk27_px1_c66, label: gen_app_peruk27_px1_c67, tone: 0)], tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk27_px1_c85, label: gen_app_peruk27_px1_c86, tone: 0), DsNote(message: gen_app_peruk27_px1_c88, label: gen_app_peruk27_px1_c89, tone: 0), DsNote(message: gen_app_peruk27_px1_c91, label: gen_app_peruk27_px1_c92, tone: 0), DsNote(message: gen_app_peruk27_px1_c94, label: gen_app_peruk27_px1_c95, tone: 0)])),
  ]);
}
