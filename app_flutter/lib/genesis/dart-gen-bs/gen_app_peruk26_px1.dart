// 🧩 חולל ע"י מפרק-החלקיקים הפתוח (particles · הכרעה-27): כל חלקיק נמצא בכל הקטלוג ומורכב מחדש. אל תערוך ידנית.
//   טבלה = [טבלה] ⇒ table ⇒ [table] ⇒ DsTable
//   פעולה פתח תיק = [פעולה] פתח תיק ⇒ act ⇒ [action] ⇒ DsPrimaryButton
//   ריק אין תיקים עדיין = [ריק] אין תיקים עדיין ⇒ empty ⇒ [empty] ⇒ EmptyState@premium/feedback
//   מסגרת = [תוכן מסגרת] ⇒ content ⇒ [alert] ⇒ DsNote
//   בלוקים = [תוכן בלוקים] ⇒ content ⇒ [alert] ⇒ DsNote
//   סיווג = [תוכן סיווג] ⇒ content ⇒ [group, alert] ⇒ DsNote
//   אסור = [תוכן אסור] ⇒ content ⇒ [alert] ⇒ DsNote

import '../dart-data-bs/auto/gen_app_peruk26_px1_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-forge-bs/composite/split_control.dart';
import '../dart-forge-bs/spatial/data_grid.dart';
import '../dart-forge-bs/temporal/event_calendar.dart';
import '../dart-ui-bs/auto/empty_state.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import 'gen_app_peruk26_ent1.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/spatial/spatial.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppPeruk26Px1Screen extends StatelessWidget {
  const GenAppPeruk26Px1Screen({super.key});
  @override
  Widget build(BuildContext context) => DsScaffold(title: gen_app_peruk26_px1_c89, subtitle: gen_app_peruk26_px1_c90, icon: gen_app_peruk26_px1_c91, children: [
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeDataGrid(bare: true, columns: [gen_app_peruk26_px1_c1, gen_app_peruk26_px1_c2, gen_app_peruk26_px1_c3, gen_app_peruk26_px1_c4, gen_app_peruk26_px1_c5, gen_app_peruk26_px1_c6], items: [for (final r in appStore.records('app_peruk26_ent1')) [(r[gen_app_peruk26_px1_c7] ?? ''), (r[gen_app_peruk26_px1_c8] ?? ''), (r[gen_app_peruk26_px1_c9] ?? ''), (r[gen_app_peruk26_px1_c10] ?? ''), (r[gen_app_peruk26_px1_c11] ?? ''), (r[gen_app_peruk26_px1_c12] ?? '')]]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk26Ent1Screen())), child: ForgeToneButton(items: [[gen_app_peruk26_px1_c14]]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => appStore.records('app_peruk26_ent1').isEmpty ? EmptyState(label: gen_app_peruk26_px1_c16) : const SizedBox.shrink())),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk26_px1_c20, label: gen_app_peruk26_px1_c21, tone: 0), DsNote(message: gen_app_peruk26_px1_c23, label: gen_app_peruk26_px1_c24, tone: 0), DsNote(message: gen_app_peruk26_px1_c26, label: gen_app_peruk26_px1_c27, tone: 0), DsNote(message: gen_app_peruk26_px1_c29, label: gen_app_peruk26_px1_c30, tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk26_px1_c33, label: gen_app_peruk26_px1_c34, tone: 0), DsNote(message: gen_app_peruk26_px1_c36, label: gen_app_peruk26_px1_c37, tone: 0), DsNote(message: gen_app_peruk26_px1_c39, label: gen_app_peruk26_px1_c40, tone: 0), DsNote(message: gen_app_peruk26_px1_c42, label: gen_app_peruk26_px1_c43, tone: 0), DsNote(message: gen_app_peruk26_px1_c45, label: gen_app_peruk26_px1_c46, tone: 0), DsNote(message: gen_app_peruk26_px1_c48, label: gen_app_peruk26_px1_c49, tone: 0), DsNote(message: gen_app_peruk26_px1_c51, label: gen_app_peruk26_px1_c52, tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsSection(title: gen_app_peruk26_px1_c67, children: [DsNote(message: gen_app_peruk26_px1_c55, label: gen_app_peruk26_px1_c56, tone: 0)], tone: 0), DsSection(title: gen_app_peruk26_px1_c70, children: [DsNote(message: gen_app_peruk26_px1_c58, label: gen_app_peruk26_px1_c59, tone: 0)], tone: 0), DsSection(title: gen_app_peruk26_px1_c73, children: [DsNote(message: gen_app_peruk26_px1_c61, label: gen_app_peruk26_px1_c62, tone: 0)], tone: 0), DsSection(title: gen_app_peruk26_px1_c76, children: [DsNote(message: gen_app_peruk26_px1_c64, label: gen_app_peruk26_px1_c65, tone: 0)], tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk26_px1_c80, label: gen_app_peruk26_px1_c81, tone: 0), DsNote(message: gen_app_peruk26_px1_c83, label: gen_app_peruk26_px1_c84, tone: 0), DsNote(message: gen_app_peruk26_px1_c86, label: gen_app_peruk26_px1_c87, tone: 0)])),
  ]);
}
