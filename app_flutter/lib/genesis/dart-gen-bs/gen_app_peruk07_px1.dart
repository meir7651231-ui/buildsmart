// 🧩 חולל ע"י מפרק-החלקיקים הפתוח (particles · הכרעה-27): כל חלקיק נמצא בכל הקטלוג ומורכב מחדש. אל תערוך ידנית.
//   טבלה = [טבלה] ⇒ table ⇒ [table] ⇒ DsTable
//   פעולה פתח תיק = [פעולה] פתח תיק ⇒ act ⇒ [action] ⇒ DsChipButton
//   ריק אין תיקים עדיין = [ריק] אין תיקים עדיין ⇒ empty ⇒ [empty] ⇒ EmptyState@premium/feedback
//   מסגרת = [תוכן מסגרת] ⇒ content ⇒ [alert] ⇒ DsNote
//   בלוקים = [תוכן בלוקים] ⇒ content ⇒ [alert] ⇒ DsNote
//   סיווג = [תוכן סיווג] ⇒ content ⇒ [group, alert] ⇒ DsNote
//   אסור = [תוכן אסור] ⇒ content ⇒ [alert] ⇒ DsNote

import '../dart-data-bs/auto/gen_app_peruk07_px1_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-forge-bs/composite/split_control.dart';
import '../dart-forge-bs/spatial/data_grid.dart';
import '../dart-forge-bs/temporal/event_calendar.dart';
import '../dart-ui-bs/auto/empty_state.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import 'gen_app_peruk07_ent1.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/spatial/spatial.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppPeruk07Px1Screen extends StatelessWidget {
  const GenAppPeruk07Px1Screen({super.key});
  @override
  Widget build(BuildContext context) => DsScaffold(title: gen_app_peruk07_px1_c138, subtitle: gen_app_peruk07_px1_c139, icon: gen_app_peruk07_px1_c140, children: [
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeDataGrid(bare: true, columns: [gen_app_peruk07_px1_c1, gen_app_peruk07_px1_c2, gen_app_peruk07_px1_c3, gen_app_peruk07_px1_c4, gen_app_peruk07_px1_c5, gen_app_peruk07_px1_c6, gen_app_peruk07_px1_c7, gen_app_peruk07_px1_c8], items: [for (final r in appStore.records('app_peruk07_ent1')) [(r[gen_app_peruk07_px1_c9] ?? ''), (r[gen_app_peruk07_px1_c10] ?? ''), (r[gen_app_peruk07_px1_c11] ?? ''), (r[gen_app_peruk07_px1_c12] ?? ''), (r[gen_app_peruk07_px1_c13] ?? ''), (r[gen_app_peruk07_px1_c14] ?? ''), (r[gen_app_peruk07_px1_c15] ?? ''), (r[gen_app_peruk07_px1_c16] ?? '')]]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: DsChipButton(label: gen_app_peruk07_px1_c18, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk07Ent1Screen())))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => appStore.records('app_peruk07_ent1').isEmpty ? EmptyState(label: gen_app_peruk07_px1_c20) : const SizedBox.shrink())),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk07_px1_c24, label: gen_app_peruk07_px1_c25, tone: 0), DsNote(message: gen_app_peruk07_px1_c27, label: gen_app_peruk07_px1_c28, tone: 0), DsNote(message: gen_app_peruk07_px1_c30, label: gen_app_peruk07_px1_c31, tone: 0), DsNote(message: gen_app_peruk07_px1_c33, label: gen_app_peruk07_px1_c34, tone: 0), DsNote(message: gen_app_peruk07_px1_c36, label: gen_app_peruk07_px1_c37, tone: 0), DsNote(message: gen_app_peruk07_px1_c39, label: gen_app_peruk07_px1_c40, tone: 0), DsNote(message: gen_app_peruk07_px1_c42, label: gen_app_peruk07_px1_c43, tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk07_px1_c46, label: gen_app_peruk07_px1_c47, tone: 0), DsNote(message: gen_app_peruk07_px1_c49, label: gen_app_peruk07_px1_c50, tone: 0), DsNote(message: gen_app_peruk07_px1_c52, label: gen_app_peruk07_px1_c53, tone: 0), DsNote(message: gen_app_peruk07_px1_c55, label: gen_app_peruk07_px1_c56, tone: 0), DsNote(message: gen_app_peruk07_px1_c58, label: gen_app_peruk07_px1_c59, tone: 0), DsNote(message: gen_app_peruk07_px1_c61, label: gen_app_peruk07_px1_c62, tone: 0), DsNote(message: gen_app_peruk07_px1_c64, label: gen_app_peruk07_px1_c65, tone: 0), DsNote(message: gen_app_peruk07_px1_c67, label: gen_app_peruk07_px1_c68, tone: 0), DsNote(message: gen_app_peruk07_px1_c70, label: gen_app_peruk07_px1_c71, tone: 0), DsNote(message: gen_app_peruk07_px1_c73, label: gen_app_peruk07_px1_c74, tone: 0), DsNote(message: gen_app_peruk07_px1_c76, label: gen_app_peruk07_px1_c77, tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsSection(title: gen_app_peruk07_px1_c110, children: [DsNote(message: gen_app_peruk07_px1_c80, label: gen_app_peruk07_px1_c81, tone: 0), DsNote(message: gen_app_peruk07_px1_c83, label: gen_app_peruk07_px1_c84, tone: 0)], tone: 0), DsSection(title: gen_app_peruk07_px1_c113, children: [DsNote(message: gen_app_peruk07_px1_c86, label: gen_app_peruk07_px1_c87, tone: 0), DsNote(message: gen_app_peruk07_px1_c89, label: gen_app_peruk07_px1_c90, tone: 0), DsNote(message: gen_app_peruk07_px1_c92, label: gen_app_peruk07_px1_c93, tone: 0)], tone: 0), DsSection(title: gen_app_peruk07_px1_c116, children: [DsNote(message: gen_app_peruk07_px1_c95, label: gen_app_peruk07_px1_c96, tone: 0), DsNote(message: gen_app_peruk07_px1_c98, label: gen_app_peruk07_px1_c99, tone: 0)], tone: 0), DsSection(title: gen_app_peruk07_px1_c119, children: [DsNote(message: gen_app_peruk07_px1_c101, label: gen_app_peruk07_px1_c102, tone: 0), DsNote(message: gen_app_peruk07_px1_c104, label: gen_app_peruk07_px1_c105, tone: 0)], tone: 0), DsSection(title: gen_app_peruk07_px1_c122, children: [DsNote(message: gen_app_peruk07_px1_c107, label: gen_app_peruk07_px1_c108, tone: 0)], tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk07_px1_c126, label: gen_app_peruk07_px1_c127, tone: 0), DsNote(message: gen_app_peruk07_px1_c129, label: gen_app_peruk07_px1_c130, tone: 0), DsNote(message: gen_app_peruk07_px1_c132, label: gen_app_peruk07_px1_c133, tone: 0), DsNote(message: gen_app_peruk07_px1_c135, label: gen_app_peruk07_px1_c136, tone: 0)])),
  ]);
}
