// ✨ חולל ע"י מנוע-הרינדור (render-ds) — מסך-חי מחווט (טופס→חנות→טבלה + לוגיקה). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_ent2_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-maor/format-israeli-phone.dart';
import '../dart-maor/gematria.dart';
import '../dart-maor/month-he-of.dart';
import '../dart-maor/norm-email.dart';
import 'package:flutter/material.dart';

class GenAppEnt2Screen extends StatefulWidget {
  const GenAppEnt2Screen({super.key});

  @override
  State<GenAppEnt2Screen> createState() => _GenAppEnt2ScreenState();
}

class _GenAppEnt2ScreenState extends State<GenAppEnt2Screen> {
  final Map<int, String> _v = {};

  void _save() {
    if (_v.values.where((x) => x.trim().isNotEmpty).isEmpty) return;
    appStore.add(gen_app_ent2_c7, <String, String>{gen_app_ent2_c8: _v[0] ?? '', gen_app_ent2_c10: _v[1] ?? '', gen_app_ent2_c11: _v[2] ?? '', gen_app_ent2_c13: _v[3] ?? '', gen_app_ent2_c14: _v[4] ?? '', gen_app_ent2_c16: _v[5] ?? '', gen_app_ent2_c18: _v[6] ?? '', gen_app_ent2_c19: _v[7] ?? ''});
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
      title: gen_app_ent2_c0,
      subtitle: gen_app_ent2_c1,
      icon: gen_app_ent2_c2,
      bottomBar: DsPrimaryButton(label: gen_app_ent2_c3, onTap: _save),
      children: [
        DsSection(title: gen_app_ent2_c4, children: [
          DsField(label: gen_app_ent2_c8, hint: '', value: _v[0] ?? '', onChanged: (v) => setState(() => _v[0] = v)),
          if ((_v[0] ?? '').trim().isNotEmpty) _live(gen_app_ent2_c9, monthHeOf((_v[0] ?? ''))),
          DsField(label: gen_app_ent2_c10, hint: '', value: _v[1] ?? '', onChanged: (v) => setState(() => _v[1] = v)),
          DsField(label: gen_app_ent2_c11, hint: '', value: _v[2] ?? '', onChanged: (v) => setState(() => _v[2] = v)),
          if ((_v[2] ?? '').trim().isNotEmpty) _live(gen_app_ent2_c12, gem((num.tryParse(_v[2] ?? '') ?? 0))),
          DsField(label: gen_app_ent2_c13, hint: '', value: _v[3] ?? '', onChanged: (v) => setState(() => _v[3] = v)),
          DsField(label: gen_app_ent2_c14, hint: '', value: _v[4] ?? '', onChanged: (v) => setState(() => _v[4] = v)),
          if ((_v[4] ?? '').trim().isNotEmpty) _live(gen_app_ent2_c15, formatIsraeliPhone((_v[4] ?? ''))),
          DsField(label: gen_app_ent2_c16, hint: '', value: _v[5] ?? '', onChanged: (v) => setState(() => _v[5] = v)),
          if ((_v[5] ?? '').trim().isNotEmpty) _live(gen_app_ent2_c17, normEmail((_v[5] ?? ''))),
          DsField(label: gen_app_ent2_c18, hint: '', value: _v[6] ?? '', onChanged: (v) => setState(() => _v[6] = v)),
          DsField(label: gen_app_ent2_c19, hint: '', value: _v[7] ?? '', onChanged: (v) => setState(() => _v[7] = v)),
        ]),
        DsSection(title: gen_app_ent2_c5, children: [
          AnimatedBuilder(
            animation: appStore,
            builder: (context, _) {
              final rs = appStore.records(gen_app_ent2_c7);
              if (rs.isEmpty) return const DsEmpty(label: gen_app_ent2_c6);
              return Column(children: [
                for (final r in rs)
                  DsRecordCard(labels: const [gen_app_ent2_c8, gen_app_ent2_c10, gen_app_ent2_c11, gen_app_ent2_c13, gen_app_ent2_c14, gen_app_ent2_c16, gen_app_ent2_c18, gen_app_ent2_c19], values: [r[gen_app_ent2_c8] ?? '', r[gen_app_ent2_c10] ?? '', r[gen_app_ent2_c11] ?? '', r[gen_app_ent2_c13] ?? '', r[gen_app_ent2_c14] ?? '', r[gen_app_ent2_c16] ?? '', r[gen_app_ent2_c18] ?? '', r[gen_app_ent2_c19] ?? '']),
              ]);
            },
          ),
        ]),
      ],
    );
  }
}
