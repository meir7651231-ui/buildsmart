// ✨ חולל ע"י מנוע-ההרכבה (render-ds/compose) — אטום+אטום ⇒ מסך-סקירה מורכב מנתוני-הישות. אל תערוך ידנית.
import '../dart-ui-bs/ds/ds_store.dart';
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/today_stat.dart';
import '../dart-ui-bs/premium/lists/glass_list_tile.dart';
import '../dart-ui-bs/premium/dataviz/neon_bars.dart';
import '../dart-ui-bs/auto/ai_card_btn.dart';
import 'gen_app_rec6.dart';
import '../dart-data-bs/auto/gen_app_over3_content.dart';

class GenAppOver3Screen extends StatelessWidget {
  const GenAppOver3Screen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: appStore,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(spacing: 10, runSpacing: 10, children: [
              TodayStat(value: appStore.count('app_ent6').toString(), label: gen_app_over3_c0),
              TodayStat(value: appStore.sum('app_ent6', gen_app_over3_c1).toStringAsFixed(0), label: gen_app_over3_c2),
            ]),
          ),
          if (appStore.records('app_ent6').isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Builder(builder: (context) {
                final r = appStore.records('app_ent6').first;
                return GlassListTile(title: r[gen_app_over3_c3] ?? '', subtitle: r[gen_app_over3_c4] ?? '');
              }),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: NeonBars(labels: appStore.records('app_ent6').take(12).map((r) => r[gen_app_over3_c6] ?? '').toList(), values: appStore.records('app_ent6').take(12).map((r) => double.tryParse(r[gen_app_over3_c5] ?? '') ?? 0).toList()),
          ),
          Expanded(
            child: ListView(
              children: [
                for (final r in appStore.records('app_ent6'))
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3), child: AiCardBtn(label: (r[gen_app_over3_c7] ?? '').isEmpty ? (r['__id'] ?? '') : (r[gen_app_over3_c7] ?? ''), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppRec6Screen(initialId: r['__id'] ?? ''))))),
              ],
            ),
          ),
          ],
        ),
      );
}
