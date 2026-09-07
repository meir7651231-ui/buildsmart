// ✨ חולל ע"י מנוע-ההרכבה (render-ds/compose) — אטום+אטום ⇒ מסך-סקירה מורכב מנתוני-הישות. אל תערוך ידנית.
import '../dart-ui-bs/ds/ds_store.dart';
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds_toggle_tile.dart';
import '../dart-ui-bs/premium/lists/glass_list_tile.dart';
import '../dart-ui-bs/auto/ai_bar.dart';
import '../dart-ui-bs/ds/ds_board.dart';
import '../dart-data-bs/auto/gen_app_peruk21_over1_content.dart';
import '../dart-forge-bs/spatial/spatial.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppPeruk21Over1Screen extends StatelessWidget {
  const GenAppPeruk21Over1Screen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: appStore,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(spacing: 10, runSpacing: 10, children: [
              DsToggleTile(value: appStore.count('app_peruk21_ent1').toString(), label: gen_app_peruk21_over1_c0),
            ]),
          ),
          if (appStore.records('app_peruk21_ent1').isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Builder(builder: (context) {
                final r = appStore.records('app_peruk21_ent1').first;
                return GlassListTile(title: r[gen_app_peruk21_over1_c1] ?? '', subtitle: r[gen_app_peruk21_over1_c2] ?? '');
              }),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: AiBar(pct: appStore.count('app_peruk21_ent1') == 0 ? 0 : (appStore.records('app_peruk21_ent1').where((r) => appStore.stageOf('app_peruk21_ent1', r['__id'] ?? '') >= 4).length * 100 ~/ appStore.count('app_peruk21_ent1'))),
          ),
          Expanded(child: Builder(builder: (_) { final kS = const [gen_app_peruk21_over1_c3, gen_app_peruk21_over1_c4, gen_app_peruk21_over1_c5, gen_app_peruk21_over1_c6, gen_app_peruk21_over1_c7]; final kR = appStore.records('app_peruk21_ent1'); final kF = (r) => appStore.stageOf('app_peruk21_ent1', r['__id'] ?? ''); final kT = (r) => r[gen_app_peruk21_over1_c8] ?? ''; final kM = (id, to) => appStore.setStage('app_peruk21_ent1', id, to); final kCols = [for (var c = 0; c < kS.length; c++) [for (final r in kR) if (kF(r).clamp(0, kS.length - 1) == c) r]]; return ForgeKanbanBoard(bare: true, items: [for (var c = 0; c < kS.length; c++) [kS[c], '${kCols[c].length}', for (final r in kCols[c]) kT(r).isEmpty ? (r['__id'] ?? '') : kT(r)]], onCell: (i, j) { if (i < kS.length - 1 && j < kCols[i].length) kM(kCols[i][j]['__id'] ?? '', i + 1); }, onCellLong: (i, j) { if (i > 0 && j < kCols[i].length) kM(kCols[i][j]['__id'] ?? '', i - 1); }); })),
          ],
        ),
      );
}
