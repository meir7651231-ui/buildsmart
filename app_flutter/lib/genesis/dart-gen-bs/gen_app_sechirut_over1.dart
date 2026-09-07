// ✨ חולל ע"י מנוע-ההרכבה (render-ds/compose) — אטום+אטום ⇒ מסך-סקירה מורכב מנתוני-הישות. אל תערוך ידנית.
import '../dart-ui-bs/ds/ds_store.dart';
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/worker_app_stat.dart';
import '../dart-ui-bs/premium/lists/expandable_tile.dart';
import '../dart-ui-bs/auto/bar.dart';
import '../dart-ui-bs/ds/ds_board.dart';
import '../dart-data-bs/auto/gen_app_sechirut_over1_content.dart';

class GenAppSechirutOver1Screen extends StatelessWidget {
  const GenAppSechirutOver1Screen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: appStore,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(spacing: 10, runSpacing: 10, children: [
              WorkerAppStat(value: appStore.count('app_sechirut_ent1').toString(), label: gen_app_sechirut_over1_c1),
            ]),
          ),
          if (appStore.scoped('app_sechirut_ent1', gen_app_sechirut_over1_c0).isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Builder(builder: (context) {
                final r = appStore.scoped('app_sechirut_ent1', gen_app_sechirut_over1_c0).first;
                return ExpandableTile(title: r[gen_app_sechirut_over1_c2] ?? '', body: r[gen_app_sechirut_over1_c3] ?? '');
              }),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Bar(pct: appStore.count('app_sechirut_ent1') == 0 ? 0 : (appStore.scoped('app_sechirut_ent1', gen_app_sechirut_over1_c0).where((r) => appStore.stageOf('app_sechirut_ent1', r['__id'] ?? '') >= 5).length * 100 ~/ appStore.count('app_sechirut_ent1'))),
          ),
          Expanded(child: DsBoard(stages: const [gen_app_sechirut_over1_c4, gen_app_sechirut_over1_c5, gen_app_sechirut_over1_c6, gen_app_sechirut_over1_c7, gen_app_sechirut_over1_c8, gen_app_sechirut_over1_c9], records: appStore.scoped('app_sechirut_ent1', gen_app_sechirut_over1_c0), stageOf: (r) => appStore.stageOf('app_sechirut_ent1', r['__id'] ?? ''), titleOf: (r) => r[gen_app_sechirut_over1_c10] ?? '', onMove: (id, to) => appStore.setStage('app_sechirut_ent1', id, to))),
          ],
        ),
      );
}
