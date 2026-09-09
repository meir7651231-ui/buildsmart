// 🧭 חולל ע"י ניווט-מקשרים (app-shell · G26 · הכרעה-27) — עמוד-השורש: עובדות · ישויות-בנות (מסוננות לרשומה) · דוח. אל תערוך ידנית.

import '../dart-data-bs/auto/gen_app_peruk10_root_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-maor/cockpit-days-since.dart';
import '../dart-maor/day-month-of-iso.dart';
import '../dart-maor/weekday-of-iso.dart';
import '../dart-ui-bs/auto/kv_line.dart';
import '../dart/f_money.dart';
import 'gen_app_peruk10_ent1.dart';
import 'gen_app_peruk10_rp1.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';

/// 8000 ⇒ 8,000 · 12.5 ⇒ 12.5 — סכום קריא בתיק (רק תצוגה; הרשומה נשארת ספרות)
/// ב׳-מג · תאריך בתיק כמו שאומרים: היום (9.9) · מחר (10.9) · יום שני 21.9 · 3.10.2027 — ISO נשאר בנתונים
String _fmtDate(String s) { final t = s.trim(); final d = DateTime.tryParse(t.length == 10 ? '${t}T12:00:00' : t); if (d == null) return t; final now = DateTime.now(); final iso = t.length >= 10 ? t.substring(0, 10) : t; final tIso = now.toIso8601String().substring(0, 10); final n = -cockpitDaysSince(iso, tIso).toInt(); if (n == 0) return gen_app_peruk10_root_c61; if (n == 1) return gen_app_peruk10_root_c62; if (n == -1) return gen_app_peruk10_root_c63; final dm = dayMonthOfIso(iso, d.year != now.year); return n.abs() <= 6 ? gen_app_peruk10_root_c64.replaceAll('{day}', gen_app_peruk10_root_c65.split(',')[weekdayOfIso(iso)]) + ' ' + dm : dm; }   // ב׳-מג · תאריך במילים בתיק · G34 · דבק על חלקיקים (ימים-מאז · יום-בשבוע · יום.חודש)
/// ב׳-נד · שורות «מה קרה מאז?» — «2026-09-01 · טקסט» ⇒ «יום שלישי 1.9 · טקסט»
String _noteText(String s) => s.split('\n').map((l) { final m = RegExp(r'^(\d{4}-\d{2}-\d{2}) · (.*)$').firstMatch(l); return m == null ? l : _fmtDate(m.group(1)!) + ' · ' + m.group(2)!; }).join('\n');
String _fmtNum(String s) { final t = s.trim(); final v = num.tryParse(t.replaceAll(',', '')); if (v == null) return t; final parts = t.replaceAll(',', '').split('.'); final ip = fMoney(num.tryParse(parts[0]) ?? 0).replaceFirst('₪', ''); return parts.length > 1 ? ip + '.' + parts[1] : ip; }   // G34 · חלקיק fMoney (מפרידי-אלפים)

class GenAppPeruk10RootScreen extends StatelessWidget {
  const GenAppPeruk10RootScreen({required this.id, super.key});
  final String id;   // ignore: unused_element
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) {
    final r0 = appStore.byId('app_peruk10_ent1', id);
    if (r0 == null) return DsScaffold(title: gen_app_peruk10_root_c66, subtitle: gen_app_peruk10_root_c67, icon: gen_app_peruk10_root_c68, children: const []);
    return DsScaffold(title: appStore.displayOf('app_peruk10_ent1', id), subtitle: const [gen_app_peruk10_root_c56, gen_app_peruk10_root_c57, gen_app_peruk10_root_c58, gen_app_peruk10_root_c59, gen_app_peruk10_root_c60][appStore.stageOf('app_peruk10_ent1', id).clamp(0, 4)], icon: gen_app_peruk10_root_c69, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsChipButton(label: gen_app_peruk10_root_c40, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk10Rp1Screen(initialId: id))))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsFold(title: gen_app_peruk10_root_c42, details: [if ((r0[gen_app_peruk10_root_c32] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk10_root_c0, value: (r0[gen_app_peruk10_root_c1] ?? '')), if ((r0[gen_app_peruk10_root_c33] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk10_root_c4, value: (r0[gen_app_peruk10_root_c5] ?? '')), if ((r0[gen_app_peruk10_root_c34] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk10_root_c8, value: (r0[gen_app_peruk10_root_c9] ?? '')), if ((r0[gen_app_peruk10_root_c35] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk10_root_c12, value: (r0[gen_app_peruk10_root_c13] ?? '')), if ((r0[gen_app_peruk10_root_c36] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk10_root_c16, value: (r0[gen_app_peruk10_root_c17] ?? '')), if ((r0[gen_app_peruk10_root_c37] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk10_root_c20, value: (r0[gen_app_peruk10_root_c21] ?? '')), if ((r0[gen_app_peruk10_root_c38] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk10_root_c24, value: _fmtNum(r0[gen_app_peruk10_root_c25] ?? '')), if ((r0[gen_app_peruk10_root_c39] ?? '').trim().isNotEmpty) KvLine(label: gen_app_peruk10_root_c28, value: (r0[gen_app_peruk10_root_c29] ?? ''))])),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: (() { final ph = [(r0[gen_app_peruk10_root_c43] ?? '')].map((x) => x.replaceAll(RegExp(r'[^0-9+]'), '')).firstWhere((x) => x.length >= 9, orElse: () => ''); if (ph.isEmpty) return const SizedBox.shrink(); final intl = ph.startsWith('+') ? ph.substring(1) : (ph.startsWith('0') ? '972' + ph.substring(1) : ph); return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [DsChipButton(label: gen_app_peruk10_root_c44, onTap: () => launchUrl(Uri.parse('tel:' + ph), mode: LaunchMode.externalApplication)), const SizedBox(width: 8), DsChipButton(label: gen_app_peruk10_root_c45, onTap: () => launchUrl(Uri.parse('https://wa.me/' + intl), mode: LaunchMode.externalApplication))])); })()),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.only(bottom: 10), child: DsQuickAdd(hint: gen_app_peruk10_root_c46, onSubmit: (t) { final v = t.trim(); if (v.isEmpty) return; final prev = r0['__note'] ?? ''; final stamp = DateTime.now().toIso8601String().substring(0, 10); appStore.update('app_peruk10_ent1', id, {'__note': (prev.isEmpty ? '' : prev + '\n') + stamp + ' · ' + v}); appStore.logAction('auto', gen_app_peruk10_root_c47.replaceAll('{who}', appStore.displayOf('app_peruk10_ent1', id)), entity: 'app_peruk10_ent1', rid: id, field: '__note', prev: prev); }))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: (appStore.stageOf('app_peruk10_ent1', id) >= 4 ? const SizedBox.shrink() : Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [DsChipButton(label: gen_app_peruk10_root_c48, onTap: () { final prev = r0[AppStore.stageKey] ?? '0'; appStore.update('app_peruk10_ent1', id, {AppStore.stageKey: '4'}); appStore.logAction('auto', gen_app_peruk10_root_c49.replaceAll('{who}', appStore.displayOf('app_peruk10_ent1', id)), entity: 'app_peruk10_ent1', rid: id, field: AppStore.stageKey, prev: prev); })])))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [DsChipButton(label: gen_app_peruk10_root_c50, onTap: () { final snap = Map<String, String>.from(r0); appStore.removeById('app_peruk10_ent1', id); appStore.logAction('del', gen_app_peruk10_root_c51.replaceAll('{who}', snap.values.take(2).join(' · ')), entity: 'app_peruk10_ent1', rid: id, prev: jsonEncode(snap)); Navigator.of(context).pop(); })]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [DsChipButton(label: gen_app_peruk10_root_c52, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk10Ent1Screen(editId: id)))), const SizedBox(width: 8), DsChipButton(label: gen_app_peruk10_root_c53, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk10Ent1Screen(initial: {for (final e in r0.entries) if (!e.key.startsWith('__') && !const <String>[].contains(e.key)) e.key: e.value}))))]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ((r0['__note'] ?? '').trim().isNotEmpty ? DsFold(title: gen_app_peruk10_root_c54, details: [Text(_noteText(r0['__note'] ?? ''), style: TextStyle(color: DsLook.of(context).ink, fontSize: 15, height: 1.5))]) : const SizedBox.shrink())),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ((r0['__doc'] ?? '').startsWith('data:image') ? DsFold(title: gen_app_peruk10_root_c55, details: [ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(base64Decode((r0['__doc'] ?? '').split(',').last), fit: BoxFit.fitWidth))]) : const SizedBox.shrink())),
    ]);
  });
}
