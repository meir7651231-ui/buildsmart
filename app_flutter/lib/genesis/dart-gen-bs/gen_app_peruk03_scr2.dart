// ✨ חולל ע"י מנוע-הרינדור (render-ds) — דשבורד מנתוני-הישויות החיים (drill-down). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_peruk03_scr2_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/auto/kv_line.dart';
import 'gen_app_peruk03_ent1.dart';
import 'package:flutter/material.dart';

class GenAppPeruk03Scr2Screen extends StatelessWidget {
  const GenAppPeruk03Scr2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_peruk03_scr2_c0,
      subtitle: gen_app_peruk03_scr2_c5,
      icon: gen_app_peruk03_scr2_c1,
      children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: AnimatedBuilder(animation: appStore, builder: (context, _) => KvLine(label: gen_app_peruk03_scr2_c2, value: appStore.count('app_peruk03_ent1').toDouble().toStringAsFixed(0)))), const SizedBox(width: 12), const Expanded(child: SizedBox())]))),
      ],
    );
  }
}
