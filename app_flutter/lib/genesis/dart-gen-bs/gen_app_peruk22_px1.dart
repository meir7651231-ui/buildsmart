// 🧩 חולל ע"י מפרק-החלקיקים הפתוח (particles · הכרעה-27): כל חלקיק נמצא בכל הקטלוג ומורכב מחדש. אל תערוך ידנית.
//   טבלה = [טבלה] ⇒ table ⇒ [table] ⇒ DsTable
//   פעולה פתח תיק = [פעולה] פתח תיק ⇒ act ⇒ [action] ⇒ DsPrimaryButton
//   ריק אין תיקים עדיין = [ריק] אין תיקים עדיין ⇒ empty ⇒ [empty] ⇒ EmptyState@premium/feedback
//   מסגרת = [תוכן מסגרת] ⇒ content ⇒ [alert] ⇒ DsNote
//   בלוקים = [תוכן בלוקים] ⇒ content ⇒ [alert] ⇒ DsNote
//   אסור = [תוכן אסור] ⇒ content ⇒ [alert] ⇒ DsNote

import '../dart-data-bs/auto/gen_app_peruk22_px1_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-forge-bs/composite/split_control.dart';
import '../dart-forge-bs/spatial/data_grid.dart';
import '../dart-forge-bs/temporal/event_calendar.dart';
import '../dart-ui-bs/auto/empty_state.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import 'gen_app_peruk22_ent1.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/spatial/spatial.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppPeruk22Px1Screen extends StatelessWidget {
  const GenAppPeruk22Px1Screen({super.key});
  @override
  Widget build(BuildContext context) => DsScaffold(title: gen_app_peruk22_px1_c60, subtitle: gen_app_peruk22_px1_c61, icon: gen_app_peruk22_px1_c62, children: [
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeDataGrid(bare: true, columns: [gen_app_peruk22_px1_c1, gen_app_peruk22_px1_c2, gen_app_peruk22_px1_c3, gen_app_peruk22_px1_c4, gen_app_peruk22_px1_c5, gen_app_peruk22_px1_c6, gen_app_peruk22_px1_c7], items: [for (final r in appStore.records('app_peruk22_ent1')) [(r[gen_app_peruk22_px1_c8] ?? ''), (r[gen_app_peruk22_px1_c9] ?? ''), (r[gen_app_peruk22_px1_c10] ?? ''), (r[gen_app_peruk22_px1_c11] ?? ''), (r[gen_app_peruk22_px1_c12] ?? ''), (r[gen_app_peruk22_px1_c13] ?? ''), (r[gen_app_peruk22_px1_c14] ?? '')]]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk22Ent1Screen())), child: ForgeToneButton(items: [[gen_app_peruk22_px1_c16]]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => appStore.records('app_peruk22_ent1').isEmpty ? EmptyState(label: gen_app_peruk22_px1_c18) : const SizedBox.shrink())),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk22_px1_c22, label: gen_app_peruk22_px1_c23, tone: 0), DsNote(message: gen_app_peruk22_px1_c25, label: gen_app_peruk22_px1_c26, tone: 0), DsNote(message: gen_app_peruk22_px1_c28, label: gen_app_peruk22_px1_c29, tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk22_px1_c32, label: gen_app_peruk22_px1_c33, tone: 0), DsNote(message: gen_app_peruk22_px1_c35, label: gen_app_peruk22_px1_c36, tone: 0), DsNote(message: gen_app_peruk22_px1_c38, label: gen_app_peruk22_px1_c39, tone: 0), DsNote(message: gen_app_peruk22_px1_c41, label: gen_app_peruk22_px1_c42, tone: 0), DsNote(message: gen_app_peruk22_px1_c44, label: gen_app_peruk22_px1_c45, tone: 0), DsNote(message: gen_app_peruk22_px1_c47, label: gen_app_peruk22_px1_c48, tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk22_px1_c51, label: gen_app_peruk22_px1_c52, tone: 0), DsNote(message: gen_app_peruk22_px1_c54, label: gen_app_peruk22_px1_c55, tone: 0), DsNote(message: gen_app_peruk22_px1_c57, label: gen_app_peruk22_px1_c58, tone: 0)])),
  ]);
}
