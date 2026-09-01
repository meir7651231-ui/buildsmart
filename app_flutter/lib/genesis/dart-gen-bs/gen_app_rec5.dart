// ✨ חולל ע"י מנוע-ההרכבה (render-ds/detail) — בורר-רשומה ⇒ שדות + KPI-יחסים. אל תערוך ידנית.
import '../dart-ui-bs/ds/ds_store.dart';
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/callout.dart';
import '../dart-data-bs/auto/gen_app_rec5_content.dart';

class GenAppRec5Screen extends StatefulWidget {
  const GenAppRec5Screen({this.initialId, super.key});

  final String? initialId;   // רשומה-פתיחה מניווט (הקלקה על שורה); null ⇒ הראשונה.

  @override
  State<GenAppRec5Screen> createState() => _GenAppRec5ScreenState();
}

class _GenAppRec5ScreenState extends State<GenAppRec5Screen> {
  int? _sel;   // null ⇒ טרם-נבחר-ידנית (משתמשים ב-initialId).

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: appStore,
        builder: (context, _) {
          final recs = appStore.records('app_ent5');
          if (recs.isEmpty) return Center(child: Text(gen_app_rec5_c9));
          final i0 = _sel ?? (widget.initialId != null ? recs.indexWhere((r) => r['__id'] == widget.initialId) : 0);
          final i = (i0 < 0 ? 0 : i0).clamp(0, recs.length - 1);
          final r = recs[i];
          
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
                      DropdownMenuItem(value: j, child: Text((recs[j][gen_app_rec5_c0] ?? '').isEmpty ? '#' + (j + 1).toString() : (recs[j][gen_app_rec5_c0] ?? ''))),
                  ],
                  onChanged: (v) { if (v != null) setState(() => _sel = v); },
                ),
              ),
              const SizedBox(height: 8),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Callout(value: r[gen_app_rec5_c1] ?? '', label: gen_app_rec5_c2)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Callout(value: r[gen_app_rec5_c3] ?? '', label: gen_app_rec5_c4)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Callout(value: r[gen_app_rec5_c5] ?? '', label: gen_app_rec5_c6)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Callout(value: r[gen_app_rec5_c7] ?? '', label: gen_app_rec5_c8)),
            ],
          );
        },
      );
}
