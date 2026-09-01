// ✨ חולל ע"י מנוע-ההרכבה (render-ds/detail) — בורר-רשומה ⇒ שדות + KPI-יחסים. אל תערוך ידנית.
import '../dart-ui-bs/ds/ds_store.dart';
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/callout.dart';
import '../dart-data-bs/auto/gen_app_rec4_content.dart';

class GenAppRec4Screen extends StatefulWidget {
  const GenAppRec4Screen({this.initialId, super.key});

  final String? initialId;   // רשומה-פתיחה מניווט (הקלקה על שורה); null ⇒ הראשונה.

  @override
  State<GenAppRec4Screen> createState() => _GenAppRec4ScreenState();
}

class _GenAppRec4ScreenState extends State<GenAppRec4Screen> {
  int? _sel;   // null ⇒ טרם-נבחר-ידנית (משתמשים ב-initialId).

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: appStore,
        builder: (context, _) {
          final recs = appStore.scoped('app_ent4', gen_app_rec4_c11);
          if (recs.isEmpty) return Center(child: Text(gen_app_rec4_c12));
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
                      DropdownMenuItem(value: j, child: Text((recs[j][gen_app_rec4_c0] ?? '').isEmpty ? '#' + (j + 1).toString() : (recs[j][gen_app_rec4_c0] ?? ''))),
                  ],
                  onChanged: (v) { if (v != null) setState(() => _sel = v); },
                ),
              ),
              const SizedBox(height: 8),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Callout(value: r[gen_app_rec4_c1] ?? '', label: gen_app_rec4_c2)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Callout(value: r[gen_app_rec4_c3] ?? '', label: gen_app_rec4_c4)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Callout(value: r[gen_app_rec4_c5] ?? '', label: gen_app_rec4_c6)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Callout(value: r[gen_app_rec4_c7] ?? '', label: gen_app_rec4_c8)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Callout(value: r[gen_app_rec4_c9] ?? '', label: gen_app_rec4_c10)),
            ],
          );
        },
      );
}
