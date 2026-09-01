// ✨ חולל ע"י מנוע-ההרכבה (render-ds/compose) — אטום+אטום ⇒ מסך-סקירה מורכב מנתוני-הישות. אל תערוך ידנית.
import '../dart-ui-bs/ds/ds_store.dart';
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/rewards_hub_fin_row.dart';
import '../dart-ui-bs/premium/lists/expandable_tile.dart';
import '../dart-ui-bs/ds/ds_bars.dart';
import '../dart-ui-bs/premium/actions/soft_button.dart';
import 'gen_app_rec1.dart';
import '../dart-data-bs/auto/gen_app_over1_content.dart';

class GenAppOver1Screen extends StatelessWidget {
  const GenAppOver1Screen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: appStore,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(spacing: 10, runSpacing: 10, children: [
              RewardsHubFinRow(value: appStore.count('app_ent1').toString(), label: gen_app_over1_c0),
              RewardsHubFinRow(value: appStore.sum('app_ent1', gen_app_over1_c1).toStringAsFixed(0), label: gen_app_over1_c2),
            ]),
          ),
          if (appStore.records('app_ent1').isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Builder(builder: (context) {
                final r = appStore.records('app_ent1').first;
                return ExpandableTile(title: r[gen_app_over1_c3] ?? '', body: r[gen_app_over1_c4] ?? '');
              }),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: DsBars(labels: appStore.records('app_ent1').take(12).map((r) => r[gen_app_over1_c6] ?? '').toList(), values: appStore.records('app_ent1').take(12).map((r) => double.tryParse(r[gen_app_over1_c5] ?? '') ?? 0).toList()),
          ),
          Expanded(
            child: ListView(
              children: [
                for (final r in appStore.records('app_ent1'))
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3), child: SoftButton(label: (r[gen_app_over1_c7] ?? '').isEmpty ? (r['__id'] ?? '') : (r[gen_app_over1_c7] ?? ''), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppRec1Screen(initialId: r['__id'] ?? ''))))),
              ],
            ),
          ),
          ],
        ),
      );
}
