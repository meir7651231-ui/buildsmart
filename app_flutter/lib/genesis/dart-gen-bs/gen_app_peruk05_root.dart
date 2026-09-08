// 🧭 חולל ע"י ניווט-מקשרים (app-shell · G26 · הכרעה-27) — עמוד-השורש: עובדות · ישויות-בנות (מסוננות לרשומה) · דוח. אל תערוך ידנית.

import '../dart-data-bs/auto/gen_app_peruk05_root_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/auto/kv_line.dart';
import 'gen_app_peruk05_ent1.dart';
import 'gen_app_peruk05_ent2.dart';
import 'gen_app_peruk05_rp1.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

/// 8000 ⇒ 8,000 · 12.5 ⇒ 12.5 — סכום קריא בתיק (רק תצוגה; הרשומה נשארת ספרות)
String _fmtNum(String s) { final t = s.trim(); final v = num.tryParse(t.replaceAll(',', '')); if (v == null) return t; final parts = t.replaceAll(',', '').split('.'); final ip = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ','); return parts.length > 1 ? ip + '.' + parts[1] : ip; }

class GenAppPeruk05RootScreen extends StatelessWidget {
  const GenAppPeruk05RootScreen({required this.id, super.key});
  final String id;   // ignore: unused_element
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) {
    final r0 = appStore.byId('app_peruk05_ent1', id);
    if (r0 == null) return DsScaffold(title: gen_app_peruk05_root_c56, subtitle: gen_app_peruk05_root_c57, icon: gen_app_peruk05_root_c58, children: const []);
    return DsScaffold(title: appStore.displayOf('app_peruk05_ent1', id), subtitle: const [gen_app_peruk05_root_c51, gen_app_peruk05_root_c52, gen_app_peruk05_root_c53, gen_app_peruk05_root_c54, gen_app_peruk05_root_c55][appStore.stageOf('app_peruk05_ent1', id).clamp(0, 4)], icon: gen_app_peruk05_root_c59, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk05_root_c42 + ' · ' + appStore.referencing('app_peruk05_ent2', gen_app_peruk05_root_c35, id).length.toString(), children: [for (final r in appStore.referencing('app_peruk05_ent2', gen_app_peruk05_root_c35, id)) DsNavTile(glyph: gen_app_peruk05_root_c41, title: (r[gen_app_peruk05_root_c36] ?? ''), sub: (r[gen_app_peruk05_root_c37] ?? ''), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk05Ent2Screen(scopeField: gen_app_peruk05_root_c38, scopeId: id)))), DsChipButton(label: gen_app_peruk05_root_c39, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk05Ent2Screen(scopeField: gen_app_peruk05_root_c38, scopeId: id))))], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsChipButton(label: gen_app_peruk05_root_c43, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk05Rp1Screen(initialId: id))))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsFold(title: gen_app_peruk05_root_c45, details: [if ((r0[gen_app_peruk05_root_c28] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk05_root_c0, value: (r0[gen_app_peruk05_root_c1] ?? '')), if ((r0[gen_app_peruk05_root_c29] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk05_root_c4, value: (r0[gen_app_peruk05_root_c5] ?? '')), if ((r0[gen_app_peruk05_root_c30] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk05_root_c8, value: (r0[gen_app_peruk05_root_c9] ?? '')), if ((r0[gen_app_peruk05_root_c31] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk05_root_c12, value: (r0[gen_app_peruk05_root_c13] ?? '')), if ((r0[gen_app_peruk05_root_c32] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk05_root_c16, value: (r0[gen_app_peruk05_root_c17] ?? '')), if ((r0[gen_app_peruk05_root_c33] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk05_root_c20, value: (r0[gen_app_peruk05_root_c21] ?? '')), if ((r0[gen_app_peruk05_root_c34] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk05_root_c24, value: (r0[gen_app_peruk05_root_c25] ?? ''))])),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: (() { final ph = [(r0[gen_app_peruk05_root_c46] ?? '')].map((x) => x.replaceAll(RegExp(r'[^0-9+]'), '')).firstWhere((x) => x.length >= 9, orElse: () => ''); if (ph.isEmpty) return const SizedBox.shrink(); final intl = ph.startsWith('+') ? ph.substring(1) : (ph.startsWith('0') ? '972' + ph.substring(1) : ph); return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [DsChipButton(label: gen_app_peruk05_root_c47, onTap: () => launchUrl(Uri.parse('tel:' + ph), mode: LaunchMode.externalApplication)), const SizedBox(width: 8), DsChipButton(label: gen_app_peruk05_root_c48, onTap: () => launchUrl(Uri.parse('https://wa.me/' + intl), mode: LaunchMode.externalApplication))])); })()),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ((r0['__note'] ?? '').trim().isNotEmpty ? DsFold(title: gen_app_peruk05_root_c49, details: [Text(r0['__note'] ?? '', style: TextStyle(color: DsLook.of(context).ink, fontSize: 15, height: 1.5))]) : const SizedBox.shrink())),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ((r0['__doc'] ?? '').startsWith('data:image') ? DsFold(title: gen_app_peruk05_root_c50, details: [ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(base64Decode((r0['__doc'] ?? '').split(',').last), fit: BoxFit.fitWidth))]) : const SizedBox.shrink())),
    ]);
  });
}
