// ✨ חולל ע"י מנוע-הרינדור (render-ds) — דשבורד מנתוני-הישויות החיים (drill-down). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_sechirut_scr5_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/premium/showcase/premium_stat.dart';
import '../dart-ui-bs/premium/dataviz/neon_bars.dart';
import '../dart-ui-bs/premium/dataviz/kpi_tile.dart';
import 'gen_app_sechirut_ent1.dart';
import 'gen_app_sechirut_ent2.dart';
import 'gen_app_sechirut_ent3.dart';
import 'gen_app_sechirut_ent4.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/card/card.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/header/header.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/dataviz/dataviz.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppSechirutScr5Screen extends StatelessWidget {
  const GenAppSechirutScr5Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(title: gen_app_sechirut_scr5_c0, subtitle: gen_app_sechirut_scr5_c33, icon: gen_app_sechirut_scr5_c1, header: false, children: [ForgeCenteredPageHeader(fields: ['', gen_app_sechirut_scr5_c0, gen_app_sechirut_scr5_c33]), ...[
      Padding(padding: const EdgeInsets.only(bottom: 12), child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeStatPlain(fields: [gen_app_sechirut_scr5_c2, appStore.count('app_sechirut_ent1').toDouble().toStringAsFixed(0)]))), const SizedBox(width: 12), Expanded(child: AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeStatPlain(fields: [gen_app_sechirut_scr5_c5, appStore.records('app_sechirut_ent3').where((r) => (r[gen_app_sechirut_scr5_c9] ?? '') == gen_app_sechirut_scr5_c10).length.toDouble().toStringAsFixed(0)])))]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeStatPlain(fields: [gen_app_sechirut_scr5_c11, appStore.records('app_sechirut_ent3').where((r) => (r[gen_app_sechirut_scr5_c15] ?? '') == gen_app_sechirut_scr5_c16).length.toDouble().toStringAsFixed(0)]))), const SizedBox(width: 12), Expanded(child: AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeStatPlain(fields: [gen_app_sechirut_scr5_c17, appStore.records('app_sechirut_ent2').where((r) => (r[gen_app_sechirut_scr5_c21] ?? '') == gen_app_sechirut_scr5_c22).length.toDouble().toStringAsFixed(0)])))]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeStatPlain(fields: [gen_app_sechirut_scr5_c23, appStore.records('app_sechirut_ent4').where((r) => (r[gen_app_sechirut_scr5_c27] ?? '') == gen_app_sechirut_scr5_c28).length.toDouble().toStringAsFixed(0)]))), const SizedBox(width: 12), Expanded(child: AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeStatPlain(fields: [gen_app_sechirut_scr5_c29, appStore.sum('app_sechirut_ent4', gen_app_sechirut_scr5_c32).toStringAsFixed(0)])))]))),
      AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeWaveformBars(fields: ['', ''], values: (() { final _vs = [appStore.count('app_sechirut_ent1').toDouble(), appStore.records('app_sechirut_ent3').where((r) => (r[gen_app_sechirut_scr5_c9] ?? '') == gen_app_sechirut_scr5_c10).length.toDouble(), appStore.records('app_sechirut_ent3').where((r) => (r[gen_app_sechirut_scr5_c15] ?? '') == gen_app_sechirut_scr5_c16).length.toDouble(), appStore.records('app_sechirut_ent2').where((r) => (r[gen_app_sechirut_scr5_c21] ?? '') == gen_app_sechirut_scr5_c22).length.toDouble(), appStore.records('app_sechirut_ent4').where((r) => (r[gen_app_sechirut_scr5_c27] ?? '') == gen_app_sechirut_scr5_c28).length.toDouble(), appStore.sum('app_sechirut_ent4', gen_app_sechirut_scr5_c32)]; final _m = _vs.fold<double>(0.0, (a, b) => a > b ? a : b); return [for (final v in _vs) _m == 0 ? 0.0 : v / _m]; })())),
      ]]);
  }
}
