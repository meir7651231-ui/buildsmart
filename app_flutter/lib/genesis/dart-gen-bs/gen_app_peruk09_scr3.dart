// ✨ חולל ע"י מנוע-הרינדור (render-ds) — דשבורד מנתוני-הישויות החיים (drill-down). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_app_peruk09_scr3_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/auto/kv_line.dart';
import 'gen_app_peruk09_ent1.dart';
import 'gen_app_peruk09_ent2.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/dataviz/dataviz.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppPeruk09Scr3Screen extends StatelessWidget {
  const GenAppPeruk09Scr3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: gen_app_peruk09_scr3_c0,
      subtitle: gen_app_peruk09_scr3_c11,
      icon: gen_app_peruk09_scr3_c1,
      children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: AnimatedBuilder(animation: appStore, builder: (context, _) => KvLine(label: gen_app_peruk09_scr3_c2, value: appStore.count('app_peruk09_ent1').toDouble().toStringAsFixed(0)))), const SizedBox(width: 12), Expanded(child: AnimatedBuilder(animation: appStore, builder: (context, _) => KvLine(label: gen_app_peruk09_scr3_c5, value: appStore.records('app_peruk09_ent2').where((r) => (r[gen_app_peruk09_scr3_c9] ?? '') == gen_app_peruk09_scr3_c10).length.toDouble().toStringAsFixed(0))))]))),
      AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeWaveformBars(fields: ['', ''], values: (() { final _vs = [appStore.count('app_peruk09_ent1').toDouble(), appStore.records('app_peruk09_ent2').where((r) => (r[gen_app_peruk09_scr3_c9] ?? '') == gen_app_peruk09_scr3_c10).length.toDouble()]; final _m = _vs.fold<double>(0.0, (a, b) => a > b ? a : b); return [for (final v in _vs) _m == 0 ? 0.0 : v / _m]; })())),
      ],
    );
  }
}
