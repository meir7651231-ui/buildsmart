// 🧭 חולל ע"י ניווט-מקשרים (app-shell · G26 · הכרעה-27) — עמוד-השורש: עובדות · ישויות-בנות (מסוננות לרשומה) · דוח. אל תערוך ידנית.

import '../dart-data-bs/auto/gen_app_tasks_root_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/auto/kv_line.dart';
import 'gen_app_tasks_ent1.dart';
import 'package:flutter/material.dart';

class GenAppTasksRootScreen extends StatelessWidget {
  const GenAppTasksRootScreen({required this.id, super.key});
  final String id;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) {
    final r0 = appStore.byId('app_tasks_ent1', id);
    if (r0 == null) return DsScaffold(title: gen_app_tasks_root_c18, subtitle: gen_app_tasks_root_c19, icon: gen_app_tasks_root_c20, children: const []);
    return DsScaffold(title: appStore.displayOf('app_tasks_ent1', id), subtitle: const [gen_app_tasks_root_c16, gen_app_tasks_root_c17][appStore.stageOf('app_tasks_ent1', id).clamp(0, 1)], icon: gen_app_tasks_root_c21, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsFold(title: gen_app_tasks_root_c15, details: [if ((r0[gen_app_tasks_root_c12] ?? '').trim().isNotEmpty) KvLine(label: gen_app_tasks_root_c0, value: (r0[gen_app_tasks_root_c1] ?? '')), if ((r0[gen_app_tasks_root_c13] ?? '').trim().isNotEmpty) KvLine(label: gen_app_tasks_root_c4, value: (r0[gen_app_tasks_root_c5] ?? '')), if ((r0[gen_app_tasks_root_c14] ?? '').trim().isNotEmpty) KvLine(label: gen_app_tasks_root_c8, value: (r0[gen_app_tasks_root_c9] ?? ''))])),
    ]);
  });
}
