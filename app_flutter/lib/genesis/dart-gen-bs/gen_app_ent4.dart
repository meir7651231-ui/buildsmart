// ✨ חולל ע"י מנוע-הרינדור (render-ds) — מסך-חי מחווט (טופס→חנות→טבלה + לוגיקה). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent4_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-maor/advance-status.dart';
import '../dart-maor/fmt-date.dart';
import '../dart-maor/gen-join-code.dart';
import '../dart-maor/month-he-of.dart';
import '../dart-maor/room-info-label.dart';
import 'package:flutter/material.dart';

class GenAppEnt4Screen extends StatefulWidget {
  const GenAppEnt4Screen({super.key});

  @override
  State<GenAppEnt4Screen> createState() => _GenAppEnt4ScreenState();
}

class _GenAppEnt4ScreenState extends State<GenAppEnt4Screen> {
  final Map<int, String> _v = {};

  void _save() {
    if (_v.values.where((x) => x.trim().isNotEmpty).isEmpty) return;
    appStore.add(gen_app_ent4_c7, <String, String>{gen_app_ent4_c8: _v[0] ?? '', gen_app_ent4_c10: _v[1] ?? '', gen_app_ent4_c12: _v[2] ?? '', gen_app_ent4_c13: _v[3] ?? '', gen_app_ent4_c14: _v[4] ?? '', gen_app_ent4_c16: _v[5] ?? '', gen_app_ent4_c17: _v[6] ?? '', gen_app_ent4_c18: _v[7] ?? '', gen_app_ent4_c19: _v[8] ?? '', gen_app_ent4_c21: _v[9] ?? ''});
    setState(() => _v.clear());
  }

  Widget _live(String label, String out) => Padding(
        padding: const EdgeInsets.only(top: 2, bottom: 6),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(color: DsTokens.accentSoft, borderRadius: BorderRadius.circular(DsTokens.rSm)),
          child: Row(children: [
            const Icon(Icons.bolt, size: 15, color: DsTokens.accentDark),
            const SizedBox(width: 7),
            Expanded(child: Text('$label · $out', style: const TextStyle(color: DsTokens.accentDark, fontSize: 13, fontWeight: FontWeight.w700))),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_ent4_c0,
      subtitle: gen_app_ent4_c1,
      icon: gen_app_ent4_c2,
      bottomBar: DsPrimaryButton(label: gen_app_ent4_c3, onTap: _save),
      children: [
        DsSection(title: gen_app_ent4_c4, children: [
          DsField(label: gen_app_ent4_c8, hint: '', value: _v[0] ?? '', onChanged: (v) => setState(() => _v[0] = v)),
          if ((_v[0] ?? '').trim().isNotEmpty) _live(gen_app_ent4_c9, genJoinCode((_v[0] ?? ''))),
          DsField(label: gen_app_ent4_c10, hint: '', value: _v[1] ?? '', onChanged: (v) => setState(() => _v[1] = v)),
          if ((_v[1] ?? '').trim().isNotEmpty) _live(gen_app_ent4_c11, monthHeOf((_v[1] ?? ''))),
          DsField(label: gen_app_ent4_c12, hint: '', value: _v[2] ?? '', onChanged: (v) => setState(() => _v[2] = v)),
          DsField(label: gen_app_ent4_c13, hint: '', value: _v[3] ?? '', onChanged: (v) => setState(() => _v[3] = v)),
          DsField(label: gen_app_ent4_c14, hint: '', value: _v[4] ?? '', onChanged: (v) => setState(() => _v[4] = v)),
          if ((_v[4] ?? '').trim().isNotEmpty) _live(gen_app_ent4_c15, fmtDate((_v[4] ?? ''))),
          DsField(label: gen_app_ent4_c16, hint: '', value: _v[5] ?? '', onChanged: (v) => setState(() => _v[5] = v)),
          DsField(label: gen_app_ent4_c17, hint: '', value: _v[6] ?? '', onChanged: (v) => setState(() => _v[6] = v)),
          DsField(label: gen_app_ent4_c18, hint: '', value: _v[7] ?? '', onChanged: (v) => setState(() => _v[7] = v)),
          DsField(label: gen_app_ent4_c19, hint: '', value: _v[8] ?? '', onChanged: (v) => setState(() => _v[8] = v)),
          if ((_v[8] ?? '').trim().isNotEmpty) _live(gen_app_ent4_c20, roomInfoLabel((_v[8] ?? ''))),
          DsField(label: gen_app_ent4_c21, hint: '', value: _v[9] ?? '', onChanged: (v) => setState(() => _v[9] = v)),
          if ((_v[9] ?? '').trim().isNotEmpty) _live(gen_app_ent4_c22, advanceStatus((_v[9] ?? ''))),
        ]),
        DsSection(title: gen_app_ent4_c5, children: [
          AnimatedBuilder(
            animation: appStore,
            builder: (context, _) {
              final rs = appStore.records(gen_app_ent4_c7);
              if (rs.isEmpty) return const DsEmpty(label: gen_app_ent4_c6);
              return Column(children: [
                for (final r in rs)
                  DsRecordCard(labels: const [gen_app_ent4_c8, gen_app_ent4_c10, gen_app_ent4_c12, gen_app_ent4_c13, gen_app_ent4_c14, gen_app_ent4_c16, gen_app_ent4_c17, gen_app_ent4_c18, gen_app_ent4_c19, gen_app_ent4_c21], values: [r[gen_app_ent4_c8] ?? '', r[gen_app_ent4_c10] ?? '', r[gen_app_ent4_c12] ?? '', r[gen_app_ent4_c13] ?? '', r[gen_app_ent4_c14] ?? '', r[gen_app_ent4_c16] ?? '', r[gen_app_ent4_c17] ?? '', r[gen_app_ent4_c18] ?? '', r[gen_app_ent4_c19] ?? '', r[gen_app_ent4_c21] ?? '']),
              ]);
            },
          ),
        ]),
      ],
    );
  }
}
