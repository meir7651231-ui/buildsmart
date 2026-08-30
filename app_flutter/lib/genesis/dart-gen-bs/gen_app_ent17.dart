// ✨ חולל ע"י מנוע-הרינדור (render-ds) — מסך-חי מחווט (טופס→חנות→טבלה + לוגיקה). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent17_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-maor/advance-status.dart';
import '../dart-maor/fmt-date.dart';
import '../dart-maor/month-he-of.dart';
import 'package:flutter/material.dart';

class GenAppEnt17Screen extends StatefulWidget {
  const GenAppEnt17Screen({super.key});

  @override
  State<GenAppEnt17Screen> createState() => _GenAppEnt17ScreenState();
}

class _GenAppEnt17ScreenState extends State<GenAppEnt17Screen> {
  final Map<int, String> _v = {};

  void _save() {
    if (_v.values.where((x) => x.trim().isNotEmpty).isEmpty) return;
    appStore.add(gen_app_ent17_c7, <String, String>{gen_app_ent17_c8: _v[0] ?? '', gen_app_ent17_c9: _v[1] ?? '', gen_app_ent17_c10: _v[2] ?? '', gen_app_ent17_c12: _v[3] ?? '', gen_app_ent17_c13: _v[4] ?? '', gen_app_ent17_c15: _v[5] ?? '', gen_app_ent17_c16: _v[6] ?? '', gen_app_ent17_c17: _v[7] ?? ''});
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
      title: gen_app_ent17_c0,
      subtitle: gen_app_ent17_c1,
      icon: gen_app_ent17_c2,
      bottomBar: DsPrimaryButton(label: gen_app_ent17_c3, onTap: _save),
      children: [
        DsWorkflow(steps: const [gen_app_ent17_c19, gen_app_ent17_c20, gen_app_ent17_c21], current: 2),
        DsSection(title: gen_app_ent17_c4, children: [
          DsField(label: gen_app_ent17_c8, hint: '', value: _v[0] ?? '', onChanged: (v) => setState(() => _v[0] = v)),
          DsField(label: gen_app_ent17_c9, hint: '', value: _v[1] ?? '', onChanged: (v) => setState(() => _v[1] = v)),
          DsField(label: gen_app_ent17_c10, hint: '', value: _v[2] ?? '', onChanged: (v) => setState(() => _v[2] = v)),
          if ((_v[2] ?? '').trim().isNotEmpty) _live(gen_app_ent17_c11, monthHeOf((_v[2] ?? ''))),
          DsField(label: gen_app_ent17_c12, hint: '', value: _v[3] ?? '', onChanged: (v) => setState(() => _v[3] = v)),
          DsField(label: gen_app_ent17_c13, hint: '', value: _v[4] ?? '', onChanged: (v) => setState(() => _v[4] = v)),
          if ((_v[4] ?? '').trim().isNotEmpty) _live(gen_app_ent17_c14, fmtDate((_v[4] ?? ''))),
          DsField(label: gen_app_ent17_c15, hint: '', value: _v[5] ?? '', onChanged: (v) => setState(() => _v[5] = v)),
          DsField(label: gen_app_ent17_c16, hint: '', value: _v[6] ?? '', onChanged: (v) => setState(() => _v[6] = v)),
          DsField(label: gen_app_ent17_c17, hint: '', value: _v[7] ?? '', onChanged: (v) => setState(() => _v[7] = v)),
          if ((_v[7] ?? '').trim().isNotEmpty) _live(gen_app_ent17_c18, advanceStatus((_v[7] ?? ''))),
        ]),
        DsSection(title: gen_app_ent17_c5, children: [
          AnimatedBuilder(
            animation: appStore,
            builder: (context, _) {
              final rs = appStore.records(gen_app_ent17_c7);
              if (rs.isEmpty) return const DsEmpty(label: gen_app_ent17_c6);
              return Column(children: [
                for (final r in rs)
                  DsRecordCard(labels: const [gen_app_ent17_c8, gen_app_ent17_c9, gen_app_ent17_c10, gen_app_ent17_c12, gen_app_ent17_c13, gen_app_ent17_c15, gen_app_ent17_c16, gen_app_ent17_c17], values: [r[gen_app_ent17_c8] ?? '', r[gen_app_ent17_c9] ?? '', r[gen_app_ent17_c10] ?? '', r[gen_app_ent17_c12] ?? '', r[gen_app_ent17_c13] ?? '', r[gen_app_ent17_c15] ?? '', r[gen_app_ent17_c16] ?? '', r[gen_app_ent17_c17] ?? '']),
              ]);
            },
          ),
        ]),
      ],
    );
  }
}
