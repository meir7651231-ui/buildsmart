// 🧩 חולל ע"י מפרק-החלקיקים הפתוח (particles · הכרעה-27): כל חלקיק נמצא בכל הקטלוג ומורכב מחדש. אל תערוך ידנית.
//   טבלה = [טבלה] ⇒ table ⇒ [table] ⇒ DsTable
//   פעולה פתח תיק = [פעולה] פתח תיק ⇒ act ⇒ [action] ⇒ DsPrimaryButton
//   ריק אין תיקים עדיין = [ריק] אין תיקים עדיין ⇒ empty ⇒ [empty] ⇒ EmptyState@premium/feedback
//   מסגרת = [תוכן מסגרת] ⇒ content ⇒ [alert] ⇒ ToastCard
//   בלוקים = [תוכן בלוקים] ⇒ content ⇒ [alert] ⇒ ToastCard
//   סיווג = [תוכן סיווג] ⇒ content ⇒ [group, alert] ⇒ ToastCard
//   אסור = [תוכן אסור] ⇒ content ⇒ [alert] ⇒ ToastCard

import '../dart-data-bs/auto/gen_app_peruk19_px1_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/auto/empty_state.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import '../dart-ui-bs/premium/feedback/toast_card.dart';
import 'gen_app_peruk19_ent1.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/header/header.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/spatial/spatial.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppPeruk19Px1Screen extends StatelessWidget {
  const GenAppPeruk19Px1Screen({super.key});
  @override
  Widget build(BuildContext context) => DsScaffold(title: gen_app_peruk19_px1_c100, subtitle: gen_app_peruk19_px1_c101, icon: gen_app_peruk19_px1_c102, header: false, children: [ForgeCenteredPageHeader(fields: ['', gen_app_peruk19_px1_c100, gen_app_peruk19_px1_c101]), ...[
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeDataGrid(bare: true, columns: [gen_app_peruk19_px1_c1, gen_app_peruk19_px1_c2, gen_app_peruk19_px1_c3, gen_app_peruk19_px1_c4, gen_app_peruk19_px1_c5, gen_app_peruk19_px1_c6, gen_app_peruk19_px1_c7], items: [for (final r in appStore.records('app_peruk19_ent1')) [(r[gen_app_peruk19_px1_c8] ?? ''), (r[gen_app_peruk19_px1_c9] ?? ''), (r[gen_app_peruk19_px1_c10] ?? ''), (r[gen_app_peruk19_px1_c11] ?? ''), (r[gen_app_peruk19_px1_c12] ?? ''), (r[gen_app_peruk19_px1_c13] ?? ''), (r[gen_app_peruk19_px1_c14] ?? '')]]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk19Ent1Screen())), child: ForgeToneButton(items: [[gen_app_peruk19_px1_c16]]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => appStore.records('app_peruk19_ent1').isEmpty ? EmptyState(label: gen_app_peruk19_px1_c18) : const SizedBox.shrink())),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk19_px1_c22, tone: 0), ToastCard(message: gen_app_peruk19_px1_c25, tone: 0), ToastCard(message: gen_app_peruk19_px1_c28, tone: 0), ToastCard(message: gen_app_peruk19_px1_c31, tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk19_px1_c35, tone: 0), ToastCard(message: gen_app_peruk19_px1_c38, tone: 0), ToastCard(message: gen_app_peruk19_px1_c41, tone: 0), ToastCard(message: gen_app_peruk19_px1_c44, tone: 0), ToastCard(message: gen_app_peruk19_px1_c47, tone: 0), ToastCard(message: gen_app_peruk19_px1_c50, tone: 0), ToastCard(message: gen_app_peruk19_px1_c53, tone: 0), ToastCard(message: gen_app_peruk19_px1_c56, tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ForgeTitledSection(fields: [gen_app_peruk19_px1_c75, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[ToastCard(message: gen_app_peruk19_px1_c60, tone: 0)]])), ForgeTitledSection(fields: [gen_app_peruk19_px1_c78, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[ToastCard(message: gen_app_peruk19_px1_c63, tone: 0)]])), ForgeTitledSection(fields: [gen_app_peruk19_px1_c81, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[ToastCard(message: gen_app_peruk19_px1_c66, tone: 0)]])), ForgeTitledSection(fields: [gen_app_peruk19_px1_c84, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[ToastCard(message: gen_app_peruk19_px1_c69, tone: 0)]])), ForgeTitledSection(fields: [gen_app_peruk19_px1_c87, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[ToastCard(message: gen_app_peruk19_px1_c72, tone: 0)]]))])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk19_px1_c91, tone: 0), ToastCard(message: gen_app_peruk19_px1_c94, tone: 0), ToastCard(message: gen_app_peruk19_px1_c97, tone: 0)])),
  ]]);
}
