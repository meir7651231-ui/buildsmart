// 🧭 חולל ע"י ניווט-מקשרים (app-shell · G26 · הכרעה-27) — עמוד-השורש: עובדות · ישויות-בנות (מסוננות לרשומה) · דוח. אל תערוך ידנית.

import '../dart-data-bs/auto/gen_app_peruk21_root_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/auto/kv_line.dart';
import 'gen_app_peruk21_ent1.dart';
import 'gen_app_peruk21_rp1.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

/// 8000 ⇒ 8,000 · 12.5 ⇒ 12.5 — סכום קריא בתיק (רק תצוגה; הרשומה נשארת ספרות)
/// ב׳-מג · תאריך בתיק כמו שאומרים: היום (9.9) · מחר (10.9) · יום שני 21.9 · 3.10.2027 — ISO נשאר בנתונים
String _fmtDate(String s) { final t = s.trim(); final d = DateTime.tryParse(t.length == 10 ? '${t}T12:00:00' : t); if (d == null) return t; final now = DateTime.now(); final n = DateTime(d.year, d.month, d.day).difference(DateTime(now.year, now.month, now.day)).inDays; final dm = '${d.day}.${d.month}'; if (n == 0) return gen_app_peruk21_root_c50 + ' (' + dm + ')'; if (n == 1) return gen_app_peruk21_root_c51 + ' (' + dm + ')'; if (n == -1) return gen_app_peruk21_root_c52 + ' (' + dm + ')'; if (n.abs() <= 6) return gen_app_peruk21_root_c53.replaceAll('{day}', gen_app_peruk21_root_c54.split(',')[d.weekday % 7]) + ' ' + dm; return dm + '.${d.year}'; }
String _fmtNum(String s) { final t = s.trim(); final v = num.tryParse(t.replaceAll(',', '')); if (v == null) return t; final parts = t.replaceAll(',', '').split('.'); final ip = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ','); return parts.length > 1 ? ip + '.' + parts[1] : ip; }

class GenAppPeruk21RootScreen extends StatelessWidget {
  const GenAppPeruk21RootScreen({required this.id, super.key});
  final String id;   // ignore: unused_element
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) {
    final r0 = appStore.byId('app_peruk21_ent1', id);
    if (r0 == null) return DsScaffold(title: gen_app_peruk21_root_c55, subtitle: gen_app_peruk21_root_c56, icon: gen_app_peruk21_root_c57, children: const []);
    return DsScaffold(title: appStore.displayOf('app_peruk21_ent1', id), subtitle: const [gen_app_peruk21_root_c45, gen_app_peruk21_root_c46, gen_app_peruk21_root_c47, gen_app_peruk21_root_c48, gen_app_peruk21_root_c49][appStore.stageOf('app_peruk21_ent1', id).clamp(0, 4)], icon: gen_app_peruk21_root_c58, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsChipButton(label: gen_app_peruk21_root_c30, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk21Rp1Screen(initialId: id))))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsFold(title: gen_app_peruk21_root_c32, details: [if ((r0[gen_app_peruk21_root_c24] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk21_root_c0, value: (r0[gen_app_peruk21_root_c1] ?? '')), if ((r0[gen_app_peruk21_root_c25] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk21_root_c4, value: (r0[gen_app_peruk21_root_c5] ?? '')), if ((r0[gen_app_peruk21_root_c26] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk21_root_c8, value: (r0[gen_app_peruk21_root_c9] ?? '')), if ((r0[gen_app_peruk21_root_c27] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk21_root_c12, value: (r0[gen_app_peruk21_root_c13] ?? '')), if ((r0[gen_app_peruk21_root_c28] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk21_root_c16, value: _fmtDate(r0[gen_app_peruk21_root_c17] ?? '')), if ((r0[gen_app_peruk21_root_c29] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk21_root_c20, value: (r0[gen_app_peruk21_root_c21] ?? ''))])),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: (() { final ph = [(r0[gen_app_peruk21_root_c33] ?? '')].map((x) => x.replaceAll(RegExp(r'[^0-9+]'), '')).firstWhere((x) => x.length >= 9, orElse: () => ''); if (ph.isEmpty) return const SizedBox.shrink(); final intl = ph.startsWith('+') ? ph.substring(1) : (ph.startsWith('0') ? '972' + ph.substring(1) : ph); return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [DsChipButton(label: gen_app_peruk21_root_c34, onTap: () => launchUrl(Uri.parse('tel:' + ph), mode: LaunchMode.externalApplication)), const SizedBox(width: 8), DsChipButton(label: gen_app_peruk21_root_c35, onTap: () => launchUrl(Uri.parse('https://wa.me/' + intl), mode: LaunchMode.externalApplication))])); })()),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.only(bottom: 10), child: DsQuickAdd(hint: gen_app_peruk21_root_c36, onSubmit: (t) { final v = t.trim(); if (v.isEmpty) return; final prev = r0['__note'] ?? ''; final stamp = DateTime.now().toIso8601String().substring(0, 10); appStore.update('app_peruk21_ent1', id, {'__note': (prev.isEmpty ? '' : prev + '\n') + stamp + ' · ' + v}); appStore.logAction('auto', gen_app_peruk21_root_c37.replaceAll('{who}', appStore.displayOf('app_peruk21_ent1', id)), entity: 'app_peruk21_ent1', rid: id, field: '__note', prev: prev); }))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: (appStore.stageOf('app_peruk21_ent1', id) >= 4 ? const SizedBox.shrink() : Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [DsChipButton(label: gen_app_peruk21_root_c38, onTap: () { final prev = r0[AppStore.stageKey] ?? '0'; appStore.update('app_peruk21_ent1', id, {AppStore.stageKey: '4'}); appStore.logAction('auto', gen_app_peruk21_root_c39.replaceAll('{who}', appStore.displayOf('app_peruk21_ent1', id)), entity: 'app_peruk21_ent1', rid: id, field: AppStore.stageKey, prev: prev); })])))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [DsChipButton(label: gen_app_peruk21_root_c40, onTap: () { final snap = Map<String, String>.from(r0); appStore.removeById('app_peruk21_ent1', id); appStore.logAction('del', gen_app_peruk21_root_c41.replaceAll('{who}', snap.values.take(2).join(' · ')), entity: 'app_peruk21_ent1', rid: id, prev: jsonEncode(snap)); Navigator.of(context).pop(); })]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [DsChipButton(label: gen_app_peruk21_root_c42, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk21Ent1Screen(editId: id))))]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ((r0['__note'] ?? '').trim().isNotEmpty ? DsFold(title: gen_app_peruk21_root_c43, details: [Text(r0['__note'] ?? '', style: TextStyle(color: DsLook.of(context).ink, fontSize: 15, height: 1.5))]) : const SizedBox.shrink())),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ((r0['__doc'] ?? '').startsWith('data:image') ? DsFold(title: gen_app_peruk21_root_c44, details: [ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(base64Decode((r0['__doc'] ?? '').split(',').last), fit: BoxFit.fitWidth))]) : const SizedBox.shrink())),
    ]);
  });
}
