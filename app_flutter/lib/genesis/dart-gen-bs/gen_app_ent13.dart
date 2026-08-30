// ✨ חולל ע"י מנוע-הרינדור (render-ds) — מסך-חי מחווט (טופס→חנות→טבלה + לוגיקה). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent13_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_store.dart';

import 'package:flutter/material.dart';

class GenAppEnt13Screen extends StatefulWidget {
  const GenAppEnt13Screen({super.key});

  @override
  State<GenAppEnt13Screen> createState() => _GenAppEnt13ScreenState();
}

class _GenAppEnt13ScreenState extends State<GenAppEnt13Screen> {
  final Map<int, String> _v = {};

  void _save() {
    if (_v.values.where((x) => x.trim().isNotEmpty).isEmpty) return;
    appStore.add(gen_app_ent13_c7, <String, String>{gen_app_ent13_c8: _v[0] ?? '', gen_app_ent13_c9: _v[1] ?? '', gen_app_ent13_c10: _v[2] ?? '', gen_app_ent13_c11: _v[3] ?? '', gen_app_ent13_c12: _v[4] ?? '', gen_app_ent13_c13: _v[5] ?? '', gen_app_ent13_c14: _v[6] ?? ''});
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
      title: gen_app_ent13_c0,
      subtitle: gen_app_ent13_c1,
      icon: gen_app_ent13_c2,
      bottomBar: DsPrimaryButton(label: gen_app_ent13_c3, onTap: _save),
      children: [
        DsWorkflow(steps: const [gen_app_ent13_c15, gen_app_ent13_c16, gen_app_ent13_c17, gen_app_ent13_c18], current: 2),
        DsSection(title: gen_app_ent13_c4, children: [
          DsField(label: gen_app_ent13_c8, hint: '', value: _v[0] ?? '', onChanged: (v) => setState(() => _v[0] = v)),
          DsField(label: gen_app_ent13_c9, hint: '', value: _v[1] ?? '', onChanged: (v) => setState(() => _v[1] = v)),
          DsField(label: gen_app_ent13_c10, hint: '', value: _v[2] ?? '', onChanged: (v) => setState(() => _v[2] = v)),
          DsField(label: gen_app_ent13_c11, hint: '', value: _v[3] ?? '', onChanged: (v) => setState(() => _v[3] = v)),
          DsField(label: gen_app_ent13_c12, hint: '', value: _v[4] ?? '', onChanged: (v) => setState(() => _v[4] = v)),
          DsField(label: gen_app_ent13_c13, hint: '', value: _v[5] ?? '', onChanged: (v) => setState(() => _v[5] = v)),
          DsField(label: gen_app_ent13_c14, hint: '', value: _v[6] ?? '', onChanged: (v) => setState(() => _v[6] = v)),
        ]),
        DsSection(title: gen_app_ent13_c5, children: [
          AnimatedBuilder(
            animation: appStore,
            builder: (context, _) {
              final rs = appStore.records(gen_app_ent13_c7);
              if (rs.isEmpty) return const DsEmpty(label: gen_app_ent13_c6);
              return Column(children: [
                for (final r in rs)
                  DsRecordCard(labels: const [gen_app_ent13_c8, gen_app_ent13_c9, gen_app_ent13_c10, gen_app_ent13_c11, gen_app_ent13_c12, gen_app_ent13_c13, gen_app_ent13_c14], values: [r[gen_app_ent13_c8] ?? '', r[gen_app_ent13_c9] ?? '', r[gen_app_ent13_c10] ?? '', r[gen_app_ent13_c11] ?? '', r[gen_app_ent13_c12] ?? '', r[gen_app_ent13_c13] ?? '', r[gen_app_ent13_c14] ?? '']),
              ]);
            },
          ),
        ]),
      ],
    );
  }
}
