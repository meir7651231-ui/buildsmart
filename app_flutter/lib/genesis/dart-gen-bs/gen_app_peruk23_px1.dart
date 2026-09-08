// 🧩 חולל ע"י מפרק-החלקיקים הפתוח (particles · הכרעה-27): כל חלקיק נמצא בכל הקטלוג ומורכב מחדש. אל תערוך ידנית.
//   טבלה = [טבלה] ⇒ table ⇒ [table] ⇒ DsTable
//   פעולה פתח תיק = [פעולה] פתח תיק ⇒ act ⇒ [action] ⇒ DsPrimaryButton
//   ריק אין תיקים עדיין = [ריק] אין תיקים עדיין ⇒ empty ⇒ [empty] ⇒ EmptyState@premium/feedback
//   מסגרת = [תוכן מסגרת] ⇒ content ⇒ [alert] ⇒ DsNote
//   בלוקים = [תוכן בלוקים] ⇒ content ⇒ [alert] ⇒ DsNote
//   אסור = [תוכן אסור] ⇒ content ⇒ [alert] ⇒ DsNote

import '../dart-data-bs/auto/gen_app_peruk23_px1_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-forge-bs/composite/split_control.dart';
import '../dart-forge-bs/spatial/data_grid.dart';
import '../dart-forge-bs/temporal/event_calendar.dart';
import '../dart-ui-bs/auto/empty_state.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import 'gen_app_peruk23_ent1.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/spatial/spatial.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppPeruk23Px1Screen extends StatelessWidget {
  const GenAppPeruk23Px1Screen({super.key});
  @override
  Widget build(BuildContext context) => DsScaffold(title: gen_app_peruk23_px1_c52, subtitle: gen_app_peruk23_px1_c53, icon: gen_app_peruk23_px1_c54, children: [
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeDataGrid(bare: true, columns: [gen_app_peruk23_px1_c1, gen_app_peruk23_px1_c2, gen_app_peruk23_px1_c3], items: [for (final r in appStore.records('app_peruk23_ent1')) [(r[gen_app_peruk23_px1_c4] ?? ''), (r[gen_app_peruk23_px1_c5] ?? ''), (r[gen_app_peruk23_px1_c6] ?? '')]]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk23Ent1Screen())), child: ForgeToneButton(items: [[gen_app_peruk23_px1_c8]]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => appStore.records('app_peruk23_ent1').isEmpty ? EmptyState(label: gen_app_peruk23_px1_c10) : const SizedBox.shrink())),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk23_px1_c14, label: gen_app_peruk23_px1_c15, tone: 0), DsNote(message: gen_app_peruk23_px1_c17, label: gen_app_peruk23_px1_c18, tone: 0), DsNote(message: gen_app_peruk23_px1_c20, label: gen_app_peruk23_px1_c21, tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk23_px1_c24, label: gen_app_peruk23_px1_c25, tone: 0), DsNote(message: gen_app_peruk23_px1_c27, label: gen_app_peruk23_px1_c28, tone: 0), DsNote(message: gen_app_peruk23_px1_c30, label: gen_app_peruk23_px1_c31, tone: 0), DsNote(message: gen_app_peruk23_px1_c33, label: gen_app_peruk23_px1_c34, tone: 0), DsNote(message: gen_app_peruk23_px1_c36, label: gen_app_peruk23_px1_c37, tone: 0), DsNote(message: gen_app_peruk23_px1_c39, label: gen_app_peruk23_px1_c40, tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk23_px1_c43, label: gen_app_peruk23_px1_c44, tone: 0), DsNote(message: gen_app_peruk23_px1_c46, label: gen_app_peruk23_px1_c47, tone: 0), DsNote(message: gen_app_peruk23_px1_c49, label: gen_app_peruk23_px1_c50, tone: 0)])),
  ]);
}
