// 🧭 חולל ע"י ניווט-מקשרים (app-shell · G26 · הכרעה-27) — עמוד-השורש: עובדות · ישויות-בנות (מסוננות לרשומה) · דוח. אל תערוך ידנית.

import '../dart-data-bs/auto/gen_app_peruk27_root_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/auto/kv_line.dart';
import 'gen_app_peruk27_ent1.dart';
import 'gen_app_peruk27_rp1.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppPeruk27RootScreen extends StatelessWidget {
  const GenAppPeruk27RootScreen({required this.id, super.key});
  final String id;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) {
    final r0 = appStore.byId('app_peruk27_ent1', id);
    if (r0 == null) return DsScaffold(title: gen_app_peruk27_root_c28, subtitle: gen_app_peruk27_root_c29, icon: gen_app_peruk27_root_c30, children: const []);
    return DsScaffold(title: appStore.displayOf('app_peruk27_ent1', id), subtitle: const [gen_app_peruk27_root_c23, gen_app_peruk27_root_c24, gen_app_peruk27_root_c25, gen_app_peruk27_root_c26, gen_app_peruk27_root_c27][appStore.stageOf('app_peruk27_ent1', id).clamp(0, 4)], icon: gen_app_peruk27_root_c31, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk27Rp1Screen(initialId: id))), child: ForgeToneButton(items: [[gen_app_peruk27_root_c20]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsFold(title: gen_app_peruk27_root_c22, details: [if ((r0[gen_app_peruk27_root_c16] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk27_root_c0, value: (r0[gen_app_peruk27_root_c1] ?? '')), if ((r0[gen_app_peruk27_root_c17] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk27_root_c4, value: (r0[gen_app_peruk27_root_c5] ?? '')), if ((r0[gen_app_peruk27_root_c18] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk27_root_c8, value: (r0[gen_app_peruk27_root_c9] ?? '')), if ((r0[gen_app_peruk27_root_c19] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk27_root_c12, value: (r0[gen_app_peruk27_root_c13] ?? ''))])),
    ]);
  });
}
