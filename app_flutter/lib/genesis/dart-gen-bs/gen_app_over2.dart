// ✨ חולל ע"י מנוע-ההרכבה (render-ds/compose) — אטום+אטום ⇒ מסך-סקירה מורכב מנתוני-הישות. אל תערוך ידנית.
import '../dart-ui-bs/ds/ds_store.dart';
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/stat.dart';
import '../dart-ui-bs/premium/lists/expandable_tile.dart';
import '../dart-ui-bs/ds/ds_bars.dart';
import '../dart-ui-bs/auto/worker_equipment_checklist_sheet_primary_btn.dart';
import 'gen_app_rec3.dart';
import '../dart-data-bs/auto/gen_app_over2_content.dart';

class GenAppOver2Screen extends StatelessWidget {
  const GenAppOver2Screen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: appStore,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(spacing: 10, runSpacing: 10, children: [
              Stat(value: appStore.count('app_ent3').toString(), label: gen_app_over2_c0),
              Stat(value: appStore.sum('app_ent3', gen_app_over2_c1).toStringAsFixed(0), label: gen_app_over2_c2),
            ]),
          ),
          if (appStore.records('app_ent3').isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Builder(builder: (context) {
                final r = appStore.records('app_ent3').first;
                return ExpandableTile(title: r[gen_app_over2_c3] ?? '', body: r[gen_app_over2_c4] ?? '');
              }),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: DsBars(labels: appStore.records('app_ent3').take(12).map((r) => r[gen_app_over2_c6] ?? '').toList(), values: appStore.records('app_ent3').take(12).map((r) => double.tryParse(r[gen_app_over2_c5] ?? '') ?? 0).toList()),
          ),
          Expanded(
            child: ListView(
              children: [
                for (final r in appStore.records('app_ent3'))
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3), child: WorkerEquipmentChecklistSheetPrimaryBtn(label: (r[gen_app_over2_c7] ?? '').isEmpty ? (r['__id'] ?? '') : (r[gen_app_over2_c7] ?? ''), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppRec3Screen(initialId: r['__id'] ?? ''))))),
              ],
            ),
          ),
          ],
        ),
      );
}
