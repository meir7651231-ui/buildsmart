// 🧭 חולל ע"י ניווט-מקשרים (app-shell · G26 · הכרעה-27) — עמוד-השורש: עובדות · ישויות-בנות (מסוננות לרשומה) · דוח. אל תערוך ידנית.

import '../dart-data-bs/auto/gen_app_peruk23_root_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/auto/kv_line.dart';
import 'gen_app_peruk23_ent1.dart';
import 'gen_app_peruk23_rp1.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

/// 8000 ⇒ 8,000 · 12.5 ⇒ 12.5 — סכום קריא בתיק (רק תצוגה; הרשומה נשארת ספרות)
String _fmtNum(String s) { final t = s.trim(); final v = num.tryParse(t.replaceAll(',', '')); if (v == null) return t; final parts = t.replaceAll(',', '').split('.'); final ip = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ','); return parts.length > 1 ? ip + '.' + parts[1] : ip; }

class GenAppPeruk23RootScreen extends StatelessWidget {
  const GenAppPeruk23RootScreen({required this.id, super.key});
  final String id;   // ignore: unused_element
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) {
    final r0 = appStore.byId('app_peruk23_ent1', id);
    if (r0 == null) return DsScaffold(title: gen_app_peruk23_root_c29, subtitle: gen_app_peruk23_root_c30, icon: gen_app_peruk23_root_c31, children: const []);
    return DsScaffold(title: appStore.displayOf('app_peruk23_ent1', id), subtitle: const [gen_app_peruk23_root_c24, gen_app_peruk23_root_c25, gen_app_peruk23_root_c26, gen_app_peruk23_root_c27, gen_app_peruk23_root_c28][appStore.stageOf('app_peruk23_ent1', id).clamp(0, 4)], icon: gen_app_peruk23_root_c32, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsPrimaryButton(label: gen_app_peruk23_root_c15, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk23Rp1Screen(initialId: id))))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsFold(title: gen_app_peruk23_root_c17, details: [if ((r0[gen_app_peruk23_root_c12] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk23_root_c0, value: (r0[gen_app_peruk23_root_c1] ?? '')), if ((r0[gen_app_peruk23_root_c13] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk23_root_c4, value: (r0[gen_app_peruk23_root_c5] ?? '')), if ((r0[gen_app_peruk23_root_c14] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk23_root_c8, value: (r0[gen_app_peruk23_root_c9] ?? ''))])),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: (() { final ph = [(r0[gen_app_peruk23_root_c18] ?? '')].map((x) => x.replaceAll(RegExp(r'[^0-9+]'), '')).firstWhere((x) => x.length >= 9, orElse: () => ''); if (ph.isEmpty) return const SizedBox.shrink(); final intl = ph.startsWith('+') ? ph.substring(1) : (ph.startsWith('0') ? '972' + ph.substring(1) : ph); return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [DsChipButton(label: gen_app_peruk23_root_c19, onTap: () => launchUrl(Uri.parse('tel:' + ph), mode: LaunchMode.externalApplication)), const SizedBox(width: 8), DsChipButton(label: gen_app_peruk23_root_c20, onTap: () => launchUrl(Uri.parse('https://wa.me/' + intl), mode: LaunchMode.externalApplication))])); })()),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [DsChipButton(label: gen_app_peruk23_root_c21, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk23Ent1Screen(editId: id))))]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ((r0['__note'] ?? '').trim().isNotEmpty ? DsFold(title: gen_app_peruk23_root_c22, details: [Text(r0['__note'] ?? '', style: TextStyle(color: DsLook.of(context).ink, fontSize: 15, height: 1.5))]) : const SizedBox.shrink())),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ((r0['__doc'] ?? '').startsWith('data:image') ? DsFold(title: gen_app_peruk23_root_c23, details: [ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(base64Decode((r0['__doc'] ?? '').split(',').last), fit: BoxFit.fitWidth))]) : const SizedBox.shrink())),
    ]);
  });
}
