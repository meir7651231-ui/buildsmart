// 🧭 חולל ע"י ניווט-מקשרים (app-shell · G26 · הכרעה-27) — עמוד-השורש: עובדות · ישויות-בנות (מסוננות לרשומה) · דוח. אל תערוך ידנית.

import '../dart-data-bs/auto/gen_app_calendar_root_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-maor/cockpit-days-since.dart';
import '../dart-ui-bs/auto/kv_line.dart';
import '../dart/f_money.dart';
import '../dart/start_of_week_sunday.dart';
import 'gen_app_calendar_ent1.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// 8000 ⇒ 8,000 · 12.5 ⇒ 12.5 — סכום קריא בתיק (רק תצוגה; הרשומה נשארת ספרות)
/// ב׳-מג · תאריך בתיק כמו שאומרים: היום (9.9) · מחר (10.9) · יום שני 21.9 · 3.10.2027 — ISO נשאר בנתונים
String _fmtDate(String s) { final t = s.trim(); final d = DateTime.tryParse(t.length == 10 ? '${t}T12:00:00' : t); if (d == null) return t; final now = DateTime.now(); final iso = t.length >= 10 ? t.substring(0, 10) : t; final tIso = now.toIso8601String().substring(0, 10); final n = -cockpitDaysSince(iso, tIso).toInt(); if (n == 0) return gen_app_calendar_root_c43; if (n == 1) return gen_app_calendar_root_c44; if (n == -1) return gen_app_calendar_root_c45; final dm = int.parse(iso.substring(8, 10)).toString() + '.' + int.parse(iso.substring(5, 7)).toString() + (d.year != now.year ? '.' + iso.substring(0, 4) : ''); return n.abs() <= 6 ? gen_app_calendar_root_c46.replaceAll('{day}', gen_app_calendar_root_c47.split(',')[cockpitDaysSince(startOfWeekSunday(d).toIso8601String().substring(0, 10), iso).toInt()]) + ' ' + dm : dm; }   // ב׳-מג · תאריך במילים בתיק · G34 · דבק על חלקיקים (ימים-מאז · יום-בשבוע · יום.חודש)
/// ב׳-נד · שורות «מה קרה מאז?» — «2026-09-01 · טקסט» ⇒ «יום שלישי 1.9 · טקסט»
String _noteText(String s) => s.split('\n').map((l) { final m = RegExp(r'^(\d{4}-\d{2}-\d{2}) · (.*)$').firstMatch(l); return m == null ? l : _fmtDate(m.group(1)!) + ' · ' + m.group(2)!; }).join('\n');
String _fmtNum(String s) { final t = s.trim(); final v = num.tryParse(t.replaceAll(',', '')); if (v == null) return t; final parts = t.replaceAll(',', '').split('.'); final ip = fMoney(num.tryParse(parts[0]) ?? 0).replaceFirst('₪', ''); return parts.length > 1 ? ip + '.' + parts[1] : ip; }   // G34 · חלקיק fMoney (מפרידי-אלפים)

class GenAppCalendarRootScreen extends StatelessWidget {
  const GenAppCalendarRootScreen({required this.id, super.key});
  final String id;   // ignore: unused_element
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) {
    final r0 = appStore.byId('app_calendar_ent1', id);
    if (r0 == null) return DsScaffold(title: gen_app_calendar_root_c48, subtitle: gen_app_calendar_root_c49, icon: gen_app_calendar_root_c50, children: const []);
    return DsScaffold(title: appStore.displayOf('app_calendar_ent1', id), subtitle: const [gen_app_calendar_root_c41, gen_app_calendar_root_c42][appStore.stageOf('app_calendar_ent1', id).clamp(0, 1)], icon: gen_app_calendar_root_c51, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsFold(title: gen_app_calendar_root_c25, details: [if ((r0[gen_app_calendar_root_c20] ?? '').trim().isNotEmpty) KvLine(label: gen_app_calendar_root_c0, value: (r0[gen_app_calendar_root_c1] ?? '')), if ((r0[gen_app_calendar_root_c21] ?? '').trim().isNotEmpty) KvLine(label: gen_app_calendar_root_c4, value: _fmtDate(r0[gen_app_calendar_root_c5] ?? '')), if ((r0[gen_app_calendar_root_c22] ?? '').trim().isNotEmpty) KvLine(label: gen_app_calendar_root_c8, value: (r0[gen_app_calendar_root_c9] ?? '')), if ((r0[gen_app_calendar_root_c23] ?? '').trim().isNotEmpty) KvLine(label: gen_app_calendar_root_c12, value: (r0[gen_app_calendar_root_c13] ?? '')), if ((r0[gen_app_calendar_root_c24] ?? '').trim().isNotEmpty) KvLine(label: gen_app_calendar_root_c16, value: (r0[gen_app_calendar_root_c17] ?? ''))])),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: (() { final loc = [(r0[gen_app_calendar_root_c26] ?? '')].map((x) => x.trim()).firstWhere((x) => x.length >= 3, orElse: () => ''); if (loc.isEmpty) return const SizedBox.shrink(); return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [DsChipButton(label: gen_app_calendar_root_c27 + ' · ' + (loc.length > 24 ? loc.substring(0, 24) + '…' : loc), onTap: () => launchUrl(Uri.parse('https://maps.google.com/?q=' + Uri.encodeComponent(loc)), mode: LaunchMode.externalApplication))])); })()),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.only(bottom: 10), child: DsQuickAdd(hint: gen_app_calendar_root_c28, onSubmit: (t) { final v = t.trim(); if (v.isEmpty) return; final prev = r0['__note'] ?? ''; final stamp = DateTime.now().toIso8601String().substring(0, 10); appStore.update('app_calendar_ent1', id, {'__note': (prev.isEmpty ? '' : prev + '\n') + stamp + ' · ' + v}); appStore.logAction('auto', gen_app_calendar_root_c29.replaceAll('{who}', appStore.displayOf('app_calendar_ent1', id)), entity: 'app_calendar_ent1', rid: id, field: '__note', prev: prev); }))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: (appStore.stageOf('app_calendar_ent1', id) >= 1 ? const SizedBox.shrink() : Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [DsChipButton(label: gen_app_calendar_root_c30, onTap: () { final prev = r0[AppStore.stageKey] ?? '0'; appStore.update('app_calendar_ent1', id, {AppStore.stageKey: '1'}); appStore.logAction('auto', gen_app_calendar_root_c31.replaceAll('{who}', appStore.displayOf('app_calendar_ent1', id)), entity: 'app_calendar_ent1', rid: id, field: AppStore.stageKey, prev: prev); })])))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [DsChipButton(label: gen_app_calendar_root_c32, onTap: () { final snap = Map<String, String>.from(r0); appStore.removeById('app_calendar_ent1', id); appStore.logAction('del', gen_app_calendar_root_c33.replaceAll('{who}', snap.values.take(2).join(' · ')), entity: 'app_calendar_ent1', rid: id, prev: jsonEncode(snap)); Navigator.of(context).pop(); })]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [DsChipButton(label: gen_app_calendar_root_c34, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppCalendarEnt1Screen(editId: id)))), const SizedBox(width: 8), DsChipButton(label: gen_app_calendar_root_c35, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppCalendarEnt1Screen(initial: {for (final e in r0.entries) if (!e.key.startsWith('__') && !const <String>[gen_app_calendar_root_c36].contains(e.key)) e.key: e.value}))))]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [DsChipButton(label: gen_app_calendar_root_c37, onTap: () { final lines = <String>[appStore.displayOf('app_calendar_ent1', id)]; for (final e in r0.entries) { if (e.key.startsWith('__') || e.value.trim().isEmpty) continue; lines.add(e.key + ': ' + (const <String>[gen_app_calendar_root_c38].contains(e.key) ? _fmtDate(e.value) : e.value.trim())); }   /* ב׳-עו · שיתוף עם תאריכים במילים */ Clipboard.setData(ClipboardData(text: lines.join('\n'))); /* ב׳-פד · גם ללוח — במחשב אין וואטסאפ */ launchUrl(Uri.parse('https://wa.me/?text=' + Uri.encodeComponent(lines.join('\n'))), mode: LaunchMode.externalApplication); })]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ((r0['__note'] ?? '').trim().isNotEmpty ? DsFold(title: gen_app_calendar_root_c39, details: [Text(_noteText(r0['__note'] ?? ''), style: TextStyle(color: DsLook.of(context).ink, fontSize: 15, height: 1.5))]) : const SizedBox.shrink())),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ((r0['__doc'] ?? '').startsWith('data:image') ? DsFold(title: gen_app_calendar_root_c40, details: [ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(base64Decode((r0['__doc'] ?? '').split(',').last), fit: BoxFit.fitWidth))]) : const SizedBox.shrink())),
    ]);
  });
}
