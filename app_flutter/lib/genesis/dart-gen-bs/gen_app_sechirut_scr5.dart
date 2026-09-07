// ✨ חולל ע"י מנוע-הרינדור (render-ds) — דשבורד מנתוני-הישויות החיים (drill-down). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_sechirut_scr5_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/premium/showcase/premium_stat.dart';
import '../dart-ui-bs/premium/dataviz/neon_bars.dart';
import 'gen_app_sechirut_ent1.dart';
import 'gen_app_sechirut_ent2.dart';
import 'gen_app_sechirut_ent3.dart';
import 'gen_app_sechirut_ent4.dart';
import 'package:flutter/material.dart';

class GenAppSechirutScr5Screen extends StatelessWidget {
  const GenAppSechirutScr5Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_sechirut_scr5_c0,
      subtitle: gen_app_sechirut_scr5_c33,
      icon: gen_app_sechirut_scr5_c1,
      children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: AnimatedBuilder(animation: appStore, builder: (context, _) => PremiumStat(label: gen_app_sechirut_scr5_c2, value: appStore.count('app_sechirut_ent1').toDouble(), glyph: gen_app_sechirut_scr5_c4, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutEnt1Screen()))))), const SizedBox(width: 12), Expanded(child: AnimatedBuilder(animation: appStore, builder: (context, _) => PremiumStat(label: gen_app_sechirut_scr5_c5, value: appStore.records('app_sechirut_ent3').where((r) => (r[gen_app_sechirut_scr5_c9] ?? '') == gen_app_sechirut_scr5_c10).length.toDouble(), glyph: gen_app_sechirut_scr5_c7, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutEnt3Screen())))))]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: AnimatedBuilder(animation: appStore, builder: (context, _) => PremiumStat(label: gen_app_sechirut_scr5_c11, value: appStore.records('app_sechirut_ent3').where((r) => (r[gen_app_sechirut_scr5_c15] ?? '') == gen_app_sechirut_scr5_c16).length.toDouble(), glyph: gen_app_sechirut_scr5_c13, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutEnt3Screen()))))), const SizedBox(width: 12), Expanded(child: AnimatedBuilder(animation: appStore, builder: (context, _) => PremiumStat(label: gen_app_sechirut_scr5_c17, value: appStore.records('app_sechirut_ent2').where((r) => (r[gen_app_sechirut_scr5_c21] ?? '') == gen_app_sechirut_scr5_c22).length.toDouble(), glyph: gen_app_sechirut_scr5_c19, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutEnt2Screen())))))]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: AnimatedBuilder(animation: appStore, builder: (context, _) => PremiumStat(label: gen_app_sechirut_scr5_c23, value: appStore.records('app_sechirut_ent4').where((r) => (r[gen_app_sechirut_scr5_c27] ?? '') == gen_app_sechirut_scr5_c28).length.toDouble(), glyph: gen_app_sechirut_scr5_c25, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutEnt4Screen()))))), const SizedBox(width: 12), Expanded(child: AnimatedBuilder(animation: appStore, builder: (context, _) => PremiumStat(label: gen_app_sechirut_scr5_c29, value: appStore.sum('app_sechirut_ent4', gen_app_sechirut_scr5_c32), glyph: gen_app_sechirut_scr5_c31, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppSechirutEnt4Screen())))))]))),
      AnimatedBuilder(animation: appStore, builder: (context, _) => NeonBars(labels: const [gen_app_sechirut_scr5_c2, gen_app_sechirut_scr5_c5, gen_app_sechirut_scr5_c11, gen_app_sechirut_scr5_c17, gen_app_sechirut_scr5_c23, gen_app_sechirut_scr5_c29], values: [appStore.count('app_sechirut_ent1').toDouble(), appStore.records('app_sechirut_ent3').where((r) => (r[gen_app_sechirut_scr5_c9] ?? '') == gen_app_sechirut_scr5_c10).length.toDouble(), appStore.records('app_sechirut_ent3').where((r) => (r[gen_app_sechirut_scr5_c15] ?? '') == gen_app_sechirut_scr5_c16).length.toDouble(), appStore.records('app_sechirut_ent2').where((r) => (r[gen_app_sechirut_scr5_c21] ?? '') == gen_app_sechirut_scr5_c22).length.toDouble(), appStore.records('app_sechirut_ent4').where((r) => (r[gen_app_sechirut_scr5_c27] ?? '') == gen_app_sechirut_scr5_c28).length.toDouble(), appStore.sum('app_sechirut_ent4', gen_app_sechirut_scr5_c32)])),
      ],
    );
  }
}
