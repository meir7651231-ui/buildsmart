// 🧭 חולל ע"י ניווט-מקשרים (app-shell · G26 · הכרעה-27) — עמוד-השורש: עובדות · ישויות-בנות (מסוננות לרשומה) · דוח. אל תערוך ידנית.

import '../dart-data-bs/auto/gen_app_calendar_root_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/auto/kv_line.dart';
import 'gen_app_calendar_ent1.dart';
import 'dart:convert';

import 'package:flutter/material.dart';

/// 8000 ⇒ 8,000 · 12.5 ⇒ 12.5 — סכום קריא בתיק (רק תצוגה; הרשומה נשארת ספרות)
String _fmtNum(String s) { final t = s.trim(); final v = num.tryParse(t.replaceAll(',', '')); if (v == null) return t; final parts = t.replaceAll(',', '').split('.'); final ip = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ','); return parts.length > 1 ? ip + '.' + parts[1] : ip; }

class GenAppCalendarRootScreen extends StatelessWidget {
  const GenAppCalendarRootScreen({required this.id, super.key});
  final String id;   // ignore: unused_element
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) {
    final r0 = appStore.byId('app_calendar_ent1', id);
    if (r0 == null) return DsScaffold(title: gen_app_calendar_root_c30, subtitle: gen_app_calendar_root_c31, icon: gen_app_calendar_root_c32, children: const []);
    return DsScaffold(title: appStore.displayOf('app_calendar_ent1', id), subtitle: const [gen_app_calendar_root_c28, gen_app_calendar_root_c29][appStore.stageOf('app_calendar_ent1', id).clamp(0, 1)], icon: gen_app_calendar_root_c33, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsFold(title: gen_app_calendar_root_c25, details: [if ((r0[gen_app_calendar_root_c20] ?? '').trim().isNotEmpty) KvLine(label: gen_app_calendar_root_c0, value: (r0[gen_app_calendar_root_c1] ?? '')), if ((r0[gen_app_calendar_root_c21] ?? '').trim().isNotEmpty) KvLine(label: gen_app_calendar_root_c4, value: (r0[gen_app_calendar_root_c5] ?? '')), if ((r0[gen_app_calendar_root_c22] ?? '').trim().isNotEmpty) KvLine(label: gen_app_calendar_root_c8, value: (r0[gen_app_calendar_root_c9] ?? '')), if ((r0[gen_app_calendar_root_c23] ?? '').trim().isNotEmpty) KvLine(label: gen_app_calendar_root_c12, value: (r0[gen_app_calendar_root_c13] ?? '')), if ((r0[gen_app_calendar_root_c24] ?? '').trim().isNotEmpty) KvLine(label: gen_app_calendar_root_c16, value: (r0[gen_app_calendar_root_c17] ?? ''))])),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ((r0['__note'] ?? '').trim().isNotEmpty ? DsFold(title: gen_app_calendar_root_c26, details: [Text(r0['__note'] ?? '', style: TextStyle(color: DsLook.of(context).ink, fontSize: 15, height: 1.5))]) : const SizedBox.shrink())),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ((r0['__doc'] ?? '').startsWith('data:image') ? DsFold(title: gen_app_calendar_root_c27, details: [ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(base64Decode((r0['__doc'] ?? '').split(',').last), fit: BoxFit.fitWidth))]) : const SizedBox.shrink())),
    ]);
  });
}
