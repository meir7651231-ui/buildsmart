// ✨ חולל ע"י מנוע-ההרכבה (render-ds/detail) — בורר-רשומה ⇒ שדות + KPI-יחסים. אל תערוך ידנית.
import '../dart-ui-bs/ds/ds_store.dart';
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/callout.dart';
import '../dart-data-bs/auto/gen_app_peruk04_rec1_content.dart';

class GenAppPeruk04Rec1Screen extends StatefulWidget {
  const GenAppPeruk04Rec1Screen({this.initialId, super.key});

  final String? initialId;   // רשומה-פתיחה מניווט (הקלקה על שורה); null ⇒ הראשונה.

  @override
  State<GenAppPeruk04Rec1Screen> createState() => _GenAppPeruk04Rec1ScreenState();
}

class _GenAppPeruk04Rec1ScreenState extends State<GenAppPeruk04Rec1Screen> {
  int? _sel;   // null ⇒ טרם-נבחר-ידנית (משתמשים ב-initialId).

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: appStore,
        builder: (context, _) {
          final recs = appStore.records('app_peruk04_ent1');
          if (recs.isEmpty) return Center(child: Text(gen_app_peruk04_rec1_c26));
          final i0 = _sel ?? (widget.initialId != null ? recs.indexWhere((r) => r['__id'] == widget.initialId) : 0);
          final i = (i0 < 0 ? 0 : i0).clamp(0, recs.length - 1);
          final r = recs[i];
          final id = r['__id'] ?? '';
          return ListView(
            padding: const EdgeInsets.only(bottom: 24, top: 8),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButton<int>(
                  value: i,
                  isExpanded: true,
                  items: [
                    for (var j = 0; j < recs.length; j++)
                      DropdownMenuItem(value: j, child: Text((recs[j][gen_app_peruk04_rec1_c0] ?? '').isEmpty ? '#' + (j + 1).toString() : (recs[j][gen_app_peruk04_rec1_c0] ?? ''))),
                  ],
                  onChanged: (v) { if (v != null) setState(() => _sel = v); },
                ),
              ),
              const SizedBox(height: 8),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Callout(value: r[gen_app_peruk04_rec1_c1] ?? '', label: gen_app_peruk04_rec1_c2)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Callout(value: r[gen_app_peruk04_rec1_c3] ?? '', label: gen_app_peruk04_rec1_c4)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Callout(value: r[gen_app_peruk04_rec1_c5] ?? '', label: gen_app_peruk04_rec1_c6)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Callout(value: r[gen_app_peruk04_rec1_c7] ?? '', label: gen_app_peruk04_rec1_c8)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Callout(value: r[gen_app_peruk04_rec1_c9] ?? '', label: gen_app_peruk04_rec1_c10)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Callout(value: r[gen_app_peruk04_rec1_c11] ?? '', label: gen_app_peruk04_rec1_c12)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Callout(value: r[gen_app_peruk04_rec1_c13] ?? '', label: gen_app_peruk04_rec1_c14)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Callout(value: r[gen_app_peruk04_rec1_c15] ?? '', label: gen_app_peruk04_rec1_c16)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Callout(value: r[gen_app_peruk04_rec1_c17] ?? '', label: gen_app_peruk04_rec1_c18)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Callout(value: r[gen_app_peruk04_rec1_c19] ?? '', label: gen_app_peruk04_rec1_c20)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Callout(value: r[gen_app_peruk04_rec1_c21] ?? '', label: gen_app_peruk04_rec1_c22)),
              const SizedBox(height: 8),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(gen_app_peruk04_rec1_c25, style: const TextStyle(fontWeight: FontWeight.w800))),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(spacing: 10, runSpacing: 10, children: [
                Callout(value: appStore.countRef('app_peruk04_ent2', gen_app_peruk04_rec1_c23, id).toString(), label: gen_app_peruk04_rec1_c24),
                ]),
              ),
            ],
          );
        },
      );
}
