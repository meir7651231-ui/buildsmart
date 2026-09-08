// 🧭 חולל ע"י ניווט-מקשרים (app-shell · G26 · הכרעה-27) — עמוד-השורש: עובדות · ישויות-בנות (מסוננות לרשומה) · דוח. אל תערוך ידנית.

import '../dart-data-bs/auto/gen_app_peruk02_root_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/auto/kv_line.dart';
import 'gen_app_peruk02_ent1.dart';
import 'gen_app_peruk02_ent2.dart';
import 'gen_app_peruk02_rp1.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppPeruk02RootScreen extends StatelessWidget {
  const GenAppPeruk02RootScreen({required this.id, super.key});
  final String id;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) {
    final r0 = appStore.byId('app_peruk02_ent1', id);
    if (r0 == null) return DsScaffold(title: gen_app_peruk02_root_c81, subtitle: gen_app_peruk02_root_c82, icon: gen_app_peruk02_root_c83, children: const []);
    return DsScaffold(title: appStore.displayOf('app_peruk02_ent1', id), subtitle: const [gen_app_peruk02_root_c76, gen_app_peruk02_root_c77, gen_app_peruk02_root_c78, gen_app_peruk02_root_c79, gen_app_peruk02_root_c80][appStore.stageOf('app_peruk02_ent1', id).clamp(0, 4)], icon: gen_app_peruk02_root_c84, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk02_root_c72 + ' · ' + appStore.referencing('app_peruk02_ent2', gen_app_peruk02_root_c65, id).length.toString(), children: [for (final r in appStore.referencing('app_peruk02_ent2', gen_app_peruk02_root_c65, id)) DsNavTile(glyph: gen_app_peruk02_root_c71, title: (r[gen_app_peruk02_root_c66] ?? ''), sub: (r[gen_app_peruk02_root_c67] ?? ''), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk02Ent2Screen(scopeField: gen_app_peruk02_root_c68, scopeId: id)))), GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk02Ent2Screen(scopeField: gen_app_peruk02_root_c68, scopeId: id))), child: ForgeToneButton(items: [[gen_app_peruk02_root_c69]]))], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk02Rp1Screen(initialId: id))), child: ForgeToneButton(items: [[gen_app_peruk02_root_c73]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsFold(title: gen_app_peruk02_root_c75, details: [if ((r0[gen_app_peruk02_root_c52] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk02_root_c0, value: (r0[gen_app_peruk02_root_c1] ?? '')), if ((r0[gen_app_peruk02_root_c53] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk02_root_c4, value: (r0[gen_app_peruk02_root_c5] ?? '')), if ((r0[gen_app_peruk02_root_c54] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk02_root_c8, value: (r0[gen_app_peruk02_root_c9] ?? '')), if ((r0[gen_app_peruk02_root_c55] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk02_root_c12, value: (r0[gen_app_peruk02_root_c13] ?? '')), if ((r0[gen_app_peruk02_root_c56] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk02_root_c16, value: (r0[gen_app_peruk02_root_c17] ?? '')), if ((r0[gen_app_peruk02_root_c57] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk02_root_c20, value: (r0[gen_app_peruk02_root_c21] ?? '')), if ((r0[gen_app_peruk02_root_c58] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk02_root_c24, value: (r0[gen_app_peruk02_root_c25] ?? '')), if ((r0[gen_app_peruk02_root_c59] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk02_root_c28, value: (r0[gen_app_peruk02_root_c29] ?? '')), if ((r0[gen_app_peruk02_root_c60] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk02_root_c32, value: (r0[gen_app_peruk02_root_c33] ?? '')), if ((r0[gen_app_peruk02_root_c61] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk02_root_c36, value: (r0[gen_app_peruk02_root_c37] ?? '')), if ((r0[gen_app_peruk02_root_c62] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk02_root_c40, value: (r0[gen_app_peruk02_root_c41] ?? '')), if ((r0[gen_app_peruk02_root_c63] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk02_root_c44, value: (r0[gen_app_peruk02_root_c45] ?? '')), if ((r0[gen_app_peruk02_root_c64] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk02_root_c48, value: (r0[gen_app_peruk02_root_c49] ?? ''))])),
    ]);
  });
}
