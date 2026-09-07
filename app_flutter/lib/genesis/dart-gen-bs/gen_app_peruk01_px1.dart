// 🧩 חולל ע"י מפרק-החלקיקים הפתוח (particles · הכרעה-27): כל חלקיק נמצא בכל הקטלוג ומורכב מחדש. אל תערוך ידנית.
//   טבלה = [טבלה] ⇒ table ⇒ [table] ⇒ DsTable
//   פעולה פתח תיק = [פעולה] פתח תיק ⇒ act ⇒ [action] ⇒ DsPrimaryButton
//   ריק אין תיקים עדיין = [ריק] אין תיקים עדיין ⇒ empty ⇒ [empty] ⇒ EmptyState@premium/feedback
//   מסגרת = [תוכן מסגרת] ⇒ content ⇒ [alert] ⇒ ToastCard
//   אסור = [תוכן אסור] ⇒ content ⇒ [alert] ⇒ ToastCard
//   לא נכנס = [תוכן לא נכנס] ⇒ content ⇒ [alert] ⇒ ToastCard

import '../dart-data-bs/auto/gen_app_peruk01_px1_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/auto/empty_state.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import '../dart-ui-bs/premium/feedback/toast_card.dart';
import 'gen_app_peruk01_ent1.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/header/header.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/spatial/spatial.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppPeruk01Px1Screen extends StatelessWidget {
  const GenAppPeruk01Px1Screen({super.key});
  @override
  Widget build(BuildContext context) => DsScaffold(title: gen_app_peruk01_px1_c122, subtitle: gen_app_peruk01_px1_c123, icon: gen_app_peruk01_px1_c124, header: false, children: [ForgeCenteredPageHeader(fields: ['', gen_app_peruk01_px1_c122, gen_app_peruk01_px1_c123]), ...[
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeDataGrid(bare: true, columns: [gen_app_peruk01_px1_c1, gen_app_peruk01_px1_c2, gen_app_peruk01_px1_c3, gen_app_peruk01_px1_c4, gen_app_peruk01_px1_c5, gen_app_peruk01_px1_c6, gen_app_peruk01_px1_c7, gen_app_peruk01_px1_c8, gen_app_peruk01_px1_c9, gen_app_peruk01_px1_c10, gen_app_peruk01_px1_c11, gen_app_peruk01_px1_c12, gen_app_peruk01_px1_c13, gen_app_peruk01_px1_c14, gen_app_peruk01_px1_c15, gen_app_peruk01_px1_c16, gen_app_peruk01_px1_c17], items: [for (final r in appStore.records('app_peruk01_ent1')) [(r[gen_app_peruk01_px1_c18] ?? ''), (r[gen_app_peruk01_px1_c19] ?? ''), (r[gen_app_peruk01_px1_c20] ?? ''), (r[gen_app_peruk01_px1_c21] ?? ''), (r[gen_app_peruk01_px1_c22] ?? ''), (r[gen_app_peruk01_px1_c23] ?? ''), (r[gen_app_peruk01_px1_c24] ?? ''), (r[gen_app_peruk01_px1_c25] ?? ''), (r[gen_app_peruk01_px1_c26] ?? ''), (r[gen_app_peruk01_px1_c27] ?? ''), (r[gen_app_peruk01_px1_c28] ?? ''), (r[gen_app_peruk01_px1_c29] ?? ''), (r[gen_app_peruk01_px1_c30] ?? ''), (r[gen_app_peruk01_px1_c31] ?? ''), (r[gen_app_peruk01_px1_c32] ?? ''), (r[gen_app_peruk01_px1_c33] ?? ''), (r[gen_app_peruk01_px1_c34] ?? '')]]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk01Ent1Screen())), child: ForgeToneButton(items: [[gen_app_peruk01_px1_c36]]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => appStore.records('app_peruk01_ent1').isEmpty ? EmptyState(label: gen_app_peruk01_px1_c38) : const SizedBox.shrink())),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk01_px1_c42, tone: 0), ToastCard(message: gen_app_peruk01_px1_c45, tone: 0), ToastCard(message: gen_app_peruk01_px1_c48, tone: 0), ToastCard(message: gen_app_peruk01_px1_c51, tone: 0), ToastCard(message: gen_app_peruk01_px1_c54, tone: 0), ToastCard(message: gen_app_peruk01_px1_c57, tone: 0), ToastCard(message: gen_app_peruk01_px1_c60, tone: 0), ToastCard(message: gen_app_peruk01_px1_c63, tone: 0), ToastCard(message: gen_app_peruk01_px1_c66, tone: 0), ToastCard(message: gen_app_peruk01_px1_c69, tone: 0), ToastCard(message: gen_app_peruk01_px1_c72, tone: 0), ToastCard(message: gen_app_peruk01_px1_c75, tone: 0), ToastCard(message: gen_app_peruk01_px1_c78, tone: 0), ToastCard(message: gen_app_peruk01_px1_c81, tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk01_px1_c85, tone: 0), ToastCard(message: gen_app_peruk01_px1_c88, tone: 0), ToastCard(message: gen_app_peruk01_px1_c91, tone: 0), ToastCard(message: gen_app_peruk01_px1_c94, tone: 0), ToastCard(message: gen_app_peruk01_px1_c97, tone: 0)])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk01_px1_c101, tone: 0), ToastCard(message: gen_app_peruk01_px1_c104, tone: 0), ToastCard(message: gen_app_peruk01_px1_c107, tone: 0), ToastCard(message: gen_app_peruk01_px1_c110, tone: 0), ToastCard(message: gen_app_peruk01_px1_c113, tone: 0), ToastCard(message: gen_app_peruk01_px1_c116, tone: 0), ToastCard(message: gen_app_peruk01_px1_c119, tone: 0)])),
  ]]);
}
