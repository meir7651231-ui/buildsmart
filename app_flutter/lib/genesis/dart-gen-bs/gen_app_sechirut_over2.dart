// ✨ חולל ע"י מנוע-ההרכבה (render-ds/compose) — אטום+אטום ⇒ מסך-סקירה מורכב מנתוני-הישות. אל תערוך ידנית.
import '../dart-ui-bs/ds/ds_store.dart';
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds_toggle_tile.dart';
import '../dart-ui-bs/premium/lists/glass_list_tile.dart';
import '../dart-ui-bs/premium/dataviz/neon_bars.dart';
import '../dart-ui-bs/auto/worker_task_detail_sheet_primary_btn.dart';
import 'gen_app_sechirut_rec4.dart';
import '../dart-data-bs/auto/gen_app_sechirut_over2_content.dart';
import '../dart-forge-bs/dataviz/dataviz.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppSechirutOver2Screen extends StatelessWidget {
  const GenAppSechirutOver2Screen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: appStore,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(spacing: 10, runSpacing: 10, children: [
              DsToggleTile(value: appStore.count('app_sechirut_ent4').toString(), label: gen_app_sechirut_over2_c0),
              DsToggleTile(value: appStore.sum('app_sechirut_ent4', gen_app_sechirut_over2_c1).toStringAsFixed(0), label: gen_app_sechirut_over2_c2),
            ]),
          ),
          if (appStore.records('app_sechirut_ent4').isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Builder(builder: (context) {
                final r = appStore.records('app_sechirut_ent4').first;
                return GlassListTile(title: r[gen_app_sechirut_over2_c3] ?? '', subtitle: r[gen_app_sechirut_over2_c4] ?? '');
              }),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ForgeWaveformBars(fields: ['', ''], values: (() { final _vs = appStore.records('app_sechirut_ent4').take(12).map((r) => double.tryParse(r[gen_app_sechirut_over2_c5] ?? '') ?? 0).toList(); final _m = _vs.fold<double>(0.0, (a, b) => a > b ? a : b); return [for (final v in _vs) _m == 0 ? 0.0 : v / _m]; })()),
          ),
          Expanded(
            child: ListView(
              children: [
                for (final r in appStore.records('app_sechirut_ent4'))
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3), child: WorkerTaskDetailSheetPrimaryBtn(label: (r[gen_app_sechirut_over2_c7] ?? '').isEmpty ? (r['__id'] ?? '') : (r[gen_app_sechirut_over2_c7] ?? ''), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppSechirutRec4Screen(initialId: r['__id'] ?? ''))))),
              ],
            ),
          ),
          ],
        ),
      );
}
