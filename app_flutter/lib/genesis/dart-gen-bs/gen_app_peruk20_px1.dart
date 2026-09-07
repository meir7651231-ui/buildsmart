// 🧩 חולל ע"י מפרק-החלקיקים הפתוח (particles · הכרעה-27): כל חלקיק נמצא בכל הקטלוג ומורכב מחדש. אל תערוך ידנית.
//   טבלה = [טבלה] ⇒ table ⇒ [table] ⇒ DsTable
//   פעולה פתח תיק = [פעולה] פתח תיק ⇒ act ⇒ [action] ⇒ DsPrimaryButton
//   ריק אין תיקים עדיין = [ריק] אין תיקים עדיין ⇒ empty ⇒ [empty] ⇒ EmptyState@premium/feedback
//   מסגרת = [תוכן מסגרת] ⇒ content ⇒ [alert] ⇒ ToastCard
//   בלוקים = [תוכן בלוקים] ⇒ content ⇒ [alert] ⇒ ToastCard
//   סיווג = [תוכן סיווג] ⇒ content ⇒ [group, alert] ⇒ ToastCard
//   אסור = [תוכן אסור] ⇒ content ⇒ [alert] ⇒ ToastCard

import '../dart-data-bs/auto/gen_app_peruk20_px1_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/auto/empty_state.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import '../dart-ui-bs/premium/feedback/toast_card.dart';
import 'gen_app_peruk20_ent1.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/header/header.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/spatial/spatial.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppPeruk20Px1Screen extends StatelessWidget {
  const GenAppPeruk20Px1Screen({super.key});
  @override
  Widget build(BuildContext context) => DsScaffold(title: gen_app_peruk20_px1_c89, subtitle: gen_app_peruk20_px1_c90, icon: gen_app_peruk20_px1_c91, header: false, children: [ForgeCenteredPageHeader(fields: ['', gen_app_peruk20_px1_c89, gen_app_peruk20_px1_c90]), ...[
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeDataGrid(bare: true, columns: [gen_app_peruk20_px1_c1, gen_app_peruk20_px1_c2, gen_app_peruk20_px1_c3, gen_app_peruk20_px1_c4, gen_app_peruk20_px1_c5, gen_app_peruk20_px1_c6], items: [for (final r in appStore.records('app_peruk20_ent1')) [(r[gen_app_peruk20_px1_c7] ?? ''), (r[gen_app_peruk20_px1_c8] ?? ''), (r[gen_app_peruk20_px1_c9] ?? ''), (r[gen_app_peruk20_px1_c10] ?? ''), (r[gen_app_peruk20_px1_c11] ?? ''), (r[gen_app_peruk20_px1_c12] ?? '')]]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk20Ent1Screen())), child: ForgeToneButton(items: [[gen_app_peruk20_px1_c14]]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => appStore.records('app_peruk20_ent1').isEmpty ? EmptyState(label: gen_app_peruk20_px1_c16) : const SizedBox.shrink())),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk20_px1_c20, tone: 0), ToastCard(message: gen_app_peruk20_px1_c23, tone: 0), ToastCard(message: gen_app_peruk20_px1_c26, tone: 0), ToastCard(message: gen_app_peruk20_px1_c29, tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk20_px1_c33, tone: 0), ToastCard(message: gen_app_peruk20_px1_c36, tone: 0), ToastCard(message: gen_app_peruk20_px1_c39, tone: 0), ToastCard(message: gen_app_peruk20_px1_c42, tone: 0), ToastCard(message: gen_app_peruk20_px1_c45, tone: 0), ToastCard(message: gen_app_peruk20_px1_c48, tone: 0), ToastCard(message: gen_app_peruk20_px1_c51, tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ForgeTitledSection(fields: [gen_app_peruk20_px1_c67, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[ToastCard(message: gen_app_peruk20_px1_c55, tone: 0)]])), ForgeTitledSection(fields: [gen_app_peruk20_px1_c70, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[ToastCard(message: gen_app_peruk20_px1_c58, tone: 0)]])), ForgeTitledSection(fields: [gen_app_peruk20_px1_c73, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[ToastCard(message: gen_app_peruk20_px1_c61, tone: 0)]])), ForgeTitledSection(fields: [gen_app_peruk20_px1_c76, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[ToastCard(message: gen_app_peruk20_px1_c64, tone: 0)]]))])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk20_px1_c80, tone: 0), ToastCard(message: gen_app_peruk20_px1_c83, tone: 0), ToastCard(message: gen_app_peruk20_px1_c86, tone: 0)])),
  ]]);
}
