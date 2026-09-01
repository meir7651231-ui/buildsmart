// ✨ חולל ע"י מנוע-הרינדור (render-ds) — דשבורד מנתוני-הישויות החיים (drill-down). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_scr7_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/premium/showcase/premium_stat.dart';
import '../dart-ui-bs/premium/dataviz/neon_bars.dart';
import 'gen_app_ent1.dart';
import 'gen_app_ent2.dart';
import 'gen_app_ent6.dart';
import 'package:flutter/material.dart';

class GenAppScr7Screen extends StatelessWidget {
  const GenAppScr7Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_scr7_c0,
      subtitle: gen_app_scr7_c22,
      icon: gen_app_scr7_c1,
      children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: AnimatedBuilder(animation: appStore, builder: (context, _) => PremiumStat(label: gen_app_scr7_c2, value: appStore.count('app_ent1').toDouble(), glyph: gen_app_scr7_c4, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppEnt1Screen()))))), const SizedBox(width: 12), Expanded(child: AnimatedBuilder(animation: appStore, builder: (context, _) => PremiumStat(label: gen_app_scr7_c5, value: appStore.count('app_ent2').toDouble(), glyph: gen_app_scr7_c7, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppEnt2Screen())))))]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: AnimatedBuilder(animation: appStore, builder: (context, _) => PremiumStat(label: gen_app_scr7_c8, value: appStore.sum('app_ent6', gen_app_scr7_c11), glyph: gen_app_scr7_c10, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppEnt6Screen()))))), const SizedBox(width: 12), Expanded(child: AnimatedBuilder(animation: appStore, builder: (context, _) => PremiumStat(label: gen_app_scr7_c12, value: appStore.avg('app_ent1', gen_app_scr7_c15), glyph: gen_app_scr7_c14, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppEnt1Screen())))))]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: AnimatedBuilder(animation: appStore, builder: (context, _) => PremiumStat(label: gen_app_scr7_c16, value: appStore.records('app_ent1').where((r) => (r[gen_app_scr7_c20] ?? '') == gen_app_scr7_c21).length.toDouble(), glyph: gen_app_scr7_c18, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppEnt1Screen()))))), const SizedBox(width: 12), const Expanded(child: SizedBox())]))),
      AnimatedBuilder(animation: appStore, builder: (context, _) => NeonBars(labels: const [gen_app_scr7_c2, gen_app_scr7_c5, gen_app_scr7_c8, gen_app_scr7_c12, gen_app_scr7_c16], values: [appStore.count('app_ent1').toDouble(), appStore.count('app_ent2').toDouble(), appStore.sum('app_ent6', gen_app_scr7_c11), appStore.avg('app_ent1', gen_app_scr7_c15), appStore.records('app_ent1').where((r) => (r[gen_app_scr7_c20] ?? '') == gen_app_scr7_c21).length.toDouble()])),
      ],
    );
  }
}
