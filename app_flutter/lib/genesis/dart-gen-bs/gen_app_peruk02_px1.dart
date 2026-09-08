// 🧩 חולל ע"י מפרק-החלקיקים הפתוח (particles · הכרעה-27): כל חלקיק נמצא בכל הקטלוג ומורכב מחדש. אל תערוך ידנית.
//   טבלה = [טבלה] ⇒ table ⇒ [table] ⇒ DsTable
//   פעולה פתח תיק = [פעולה] פתח תיק ⇒ act ⇒ [action] ⇒ DsPrimaryButton
//   ריק אין תיקים עדיין = [ריק] אין תיקים עדיין ⇒ empty ⇒ [empty] ⇒ EmptyState@premium/feedback
//   מסגרת = [תוכן מסגרת] ⇒ content ⇒ [alert] ⇒ DsNote
//   בלוקים = [תוכן בלוקים] ⇒ content ⇒ [alert] ⇒ DsNote
//   אסור = [תוכן אסור] ⇒ content ⇒ [alert] ⇒ DsNote
//   לוח = [לוח] ⇒ dates ⇒ [magnitude] ⇒ KvLine

import '../dart-data-bs/auto/gen_app_peruk02_px1_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-forge-bs/composite/split_control.dart';
import '../dart-forge-bs/spatial/data_grid.dart';
import '../dart-forge-bs/temporal/event_calendar.dart';
import '../dart-ui-bs/auto/empty_state.dart';
import '../dart-ui-bs/auto/kv_line.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import 'gen_app_peruk02_ent1.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/spatial/spatial.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppPeruk02Px1Screen extends StatelessWidget {
  const GenAppPeruk02Px1Screen({super.key});
  @override
  Widget build(BuildContext context) => DsScaffold(title: gen_app_peruk02_px1_c109, subtitle: gen_app_peruk02_px1_c110, icon: gen_app_peruk02_px1_c111, children: [
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeDataGrid(bare: true, columns: [gen_app_peruk02_px1_c1, gen_app_peruk02_px1_c2, gen_app_peruk02_px1_c3, gen_app_peruk02_px1_c4, gen_app_peruk02_px1_c5, gen_app_peruk02_px1_c6, gen_app_peruk02_px1_c7, gen_app_peruk02_px1_c8, gen_app_peruk02_px1_c9, gen_app_peruk02_px1_c10, gen_app_peruk02_px1_c11, gen_app_peruk02_px1_c12, gen_app_peruk02_px1_c13], items: [for (final r in appStore.records('app_peruk02_ent1')) [(r[gen_app_peruk02_px1_c14] ?? ''), (r[gen_app_peruk02_px1_c15] ?? ''), (r[gen_app_peruk02_px1_c16] ?? ''), (r[gen_app_peruk02_px1_c17] ?? ''), (r[gen_app_peruk02_px1_c18] ?? ''), (r[gen_app_peruk02_px1_c19] ?? ''), (r[gen_app_peruk02_px1_c20] ?? ''), (r[gen_app_peruk02_px1_c21] ?? ''), (r[gen_app_peruk02_px1_c22] ?? ''), (r[gen_app_peruk02_px1_c23] ?? ''), (r[gen_app_peruk02_px1_c24] ?? ''), (r[gen_app_peruk02_px1_c25] ?? ''), (r[gen_app_peruk02_px1_c26] ?? '')]]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk02Ent1Screen())), child: ForgeToneButton(items: [[gen_app_peruk02_px1_c28]]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => appStore.records('app_peruk02_ent1').isEmpty ? EmptyState(label: gen_app_peruk02_px1_c30) : const SizedBox.shrink())),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk02_px1_c34, label: gen_app_peruk02_px1_c35, tone: 0), DsNote(message: gen_app_peruk02_px1_c37, label: gen_app_peruk02_px1_c38, tone: 0), DsNote(message: gen_app_peruk02_px1_c40, label: gen_app_peruk02_px1_c41, tone: 0), DsNote(message: gen_app_peruk02_px1_c43, label: gen_app_peruk02_px1_c44, tone: 0), DsNote(message: gen_app_peruk02_px1_c46, label: gen_app_peruk02_px1_c47, tone: 0), DsNote(message: gen_app_peruk02_px1_c49, label: gen_app_peruk02_px1_c50, tone: 0), DsNote(message: gen_app_peruk02_px1_c52, label: gen_app_peruk02_px1_c53, tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk02_px1_c56, label: gen_app_peruk02_px1_c57, tone: 0), DsNote(message: gen_app_peruk02_px1_c59, label: gen_app_peruk02_px1_c60, tone: 0), DsNote(message: gen_app_peruk02_px1_c62, label: gen_app_peruk02_px1_c63, tone: 0), DsNote(message: gen_app_peruk02_px1_c65, label: gen_app_peruk02_px1_c66, tone: 0), DsNote(message: gen_app_peruk02_px1_c68, label: gen_app_peruk02_px1_c69, tone: 0), DsNote(message: gen_app_peruk02_px1_c71, label: gen_app_peruk02_px1_c72, tone: 0), DsNote(message: gen_app_peruk02_px1_c74, label: gen_app_peruk02_px1_c75, tone: 0), DsNote(message: gen_app_peruk02_px1_c77, label: gen_app_peruk02_px1_c78, tone: 0), DsNote(message: gen_app_peruk02_px1_c80, label: gen_app_peruk02_px1_c81, tone: 0), DsNote(message: gen_app_peruk02_px1_c83, label: gen_app_peruk02_px1_c84, tone: 0), DsNote(message: gen_app_peruk02_px1_c86, label: gen_app_peruk02_px1_c87, tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk02_px1_c90, label: gen_app_peruk02_px1_c91, tone: 0), DsNote(message: gen_app_peruk02_px1_c93, label: gen_app_peruk02_px1_c94, tone: 0), DsNote(message: gen_app_peruk02_px1_c96, label: gen_app_peruk02_px1_c97, tone: 0), DsNote(message: gen_app_peruk02_px1_c99, label: gen_app_peruk02_px1_c100, tone: 0), DsNote(message: gen_app_peruk02_px1_c102, label: gen_app_peruk02_px1_c103, tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in appStore.records('app_peruk02_ent1')) Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final e in (<List<String>>[[gen_app_peruk02_px1_c107, (r[gen_app_peruk02_px1_c108] ?? '')]].where((e) => e[1].trim().isNotEmpty).toList()..sort((a, b) => a[1].compareTo(b[1])))) KvLine(label: e[0], value: e[1])]))]))),
  ]);
}
