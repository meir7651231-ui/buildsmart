// 🧭 חולל ע"י ניווט-מקשרים (app-shell · G26 · הכרעה-27) — עמוד-השורש: עובדות · ישויות-בנות (מסוננות לרשומה) · דוח. אל תערוך ידנית.

import '../dart-data-bs/auto/gen_app_peruk06_root_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/auto/kv_line.dart';
import 'gen_app_peruk06_ent1.dart';
import 'gen_app_peruk06_ent2.dart';
import 'gen_app_peruk06_rp1.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

class GenAppPeruk06RootScreen extends StatelessWidget {
  const GenAppPeruk06RootScreen({required this.id, super.key});
  final String id;   // ignore: unused_element
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) {
    final r0 = appStore.byId('app_peruk06_ent1', id);
    if (r0 == null) return DsScaffold(title: gen_app_peruk06_root_c63, subtitle: gen_app_peruk06_root_c64, icon: gen_app_peruk06_root_c65, children: const []);
    return DsScaffold(title: appStore.displayOf('app_peruk06_ent1', id), subtitle: const [gen_app_peruk06_root_c58, gen_app_peruk06_root_c59, gen_app_peruk06_root_c60, gen_app_peruk06_root_c61, gen_app_peruk06_root_c62][appStore.stageOf('app_peruk06_ent1', id).clamp(0, 4)], icon: gen_app_peruk06_root_c66, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk06_root_c52 + ' · ' + appStore.referencing('app_peruk06_ent2', gen_app_peruk06_root_c45, id).length.toString(), children: [for (final r in appStore.referencing('app_peruk06_ent2', gen_app_peruk06_root_c45, id)) DsNavTile(glyph: gen_app_peruk06_root_c51, title: (r[gen_app_peruk06_root_c46] ?? ''), sub: (r[gen_app_peruk06_root_c47] ?? ''), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk06Ent2Screen(scopeField: gen_app_peruk06_root_c48, scopeId: id)))), DsPrimaryButton(label: gen_app_peruk06_root_c49, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk06Ent2Screen(scopeField: gen_app_peruk06_root_c48, scopeId: id))))], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsPrimaryButton(label: gen_app_peruk06_root_c53, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk06Rp1Screen(initialId: id))))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsFold(title: gen_app_peruk06_root_c55, details: [if ((r0[gen_app_peruk06_root_c36] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk06_root_c0, value: (r0[gen_app_peruk06_root_c1] ?? '')), if ((r0[gen_app_peruk06_root_c37] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk06_root_c4, value: (r0[gen_app_peruk06_root_c5] ?? '')), if ((r0[gen_app_peruk06_root_c38] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk06_root_c8, value: (r0[gen_app_peruk06_root_c9] ?? '')), if ((r0[gen_app_peruk06_root_c39] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk06_root_c12, value: (r0[gen_app_peruk06_root_c13] ?? '')), if ((r0[gen_app_peruk06_root_c40] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk06_root_c16, value: (r0[gen_app_peruk06_root_c17] ?? '')), if ((r0[gen_app_peruk06_root_c41] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk06_root_c20, value: (r0[gen_app_peruk06_root_c21] ?? '')), if ((r0[gen_app_peruk06_root_c42] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk06_root_c24, value: (r0[gen_app_peruk06_root_c25] ?? '')), if ((r0[gen_app_peruk06_root_c43] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk06_root_c28, value: (r0[gen_app_peruk06_root_c29] ?? '')), if ((r0[gen_app_peruk06_root_c44] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk06_root_c32, value: (r0[gen_app_peruk06_root_c33] ?? ''))])),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ((r0['__note'] ?? '').trim().isNotEmpty ? DsFold(title: gen_app_peruk06_root_c56, details: [Text(r0['__note'] ?? '', style: TextStyle(color: DsLook.of(context).ink, fontSize: 15, height: 1.5))]) : const SizedBox.shrink())),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ((r0['__doc'] ?? '').startsWith('data:image') ? DsFold(title: gen_app_peruk06_root_c57, details: [ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(base64Decode((r0['__doc'] ?? '').split(',').last), fit: BoxFit.fitWidth))]) : const SizedBox.shrink())),
    ]);
  });
}
