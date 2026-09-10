// ✨ חולל ע"י מנוע-הרינדור (render-ds) — דשבורד מנתוני-הישויות החיים (drill-down). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_tasks_scr1_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/premium/showcase/premium_stat.dart';
import 'gen_app_tasks_ent2.dart';
import 'package:flutter/material.dart';

class GenAppTasksScr1Screen extends StatelessWidget {
  const GenAppTasksScr1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_tasks_scr1_c0,
      subtitle: gen_app_tasks_scr1_c5,
      icon: gen_app_tasks_scr1_c1,
      children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: AnimatedBuilder(animation: appStore, builder: (context, _) => PremiumStat(label: gen_app_tasks_scr1_c2, value: appStore.count('app_tasks_ent2').toDouble(), glyph: gen_app_tasks_scr1_c4, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppTasksEnt2Screen()))))), const SizedBox(width: 12), const Expanded(child: SizedBox())]))),
      ],
    );
  }
}
