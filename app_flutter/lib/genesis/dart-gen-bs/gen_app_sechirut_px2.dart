// 🧩 חולל ע"י מפרק-החלקיקים הפתוח (particles · הכרעה-27): כל חלקיק נמצא בכל הקטלוג ומורכב מחדש. אל תערוך ידנית.
//   חורג = סך בטוחות / תקרה לפי 3 חודשים ⇒ / ⇒ [ratio] ⇒ ForgeGlowSlider
//   מעל התקרה = מונה(חורג מול 3 חודשים=חורג) ⇒ count ⇒ [headline] ⇒ KvLine
//   מה החוק קובע = [תוכן חוק] ⇒ content ⇒ [alert] ⇒ DsNote

import '../dart-data-bs/auto/gen_app_sechirut_px2_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-forge-bs/input/glow_slider.dart';
import '../dart-ui-bs/auto/kv_line.dart';
import '../dart-ui-bs/ds/ds.dart';
import 'package:flutter/material.dart';

class GenAppSechirutPx2Screen extends StatelessWidget {
  const GenAppSechirutPx2Screen({super.key});
  @override
  Widget build(BuildContext context) => DsScaffold(title: gen_app_sechirut_px2_c36, subtitle: gen_app_sechirut_px2_c37, icon: gen_app_sechirut_px2_c38, children: [
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in appStore.records('app_sechirut_ent2')) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeGlowSlider())]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => KvLine(label: gen_app_sechirut_px2_c5, value: appStore.records('app_sechirut_ent2').where((r) => (r[gen_app_sechirut_px2_c7] ?? '') == gen_app_sechirut_px2_c8).length.toDouble().toStringAsFixed(0)))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_sechirut_px2_c12, label: gen_app_sechirut_px2_c13, tone: 0), DsNote(message: gen_app_sechirut_px2_c15, label: gen_app_sechirut_px2_c16, tone: 0), DsNote(message: gen_app_sechirut_px2_c18, label: gen_app_sechirut_px2_c19, tone: 0), DsNote(message: gen_app_sechirut_px2_c21, label: gen_app_sechirut_px2_c22, tone: 0), DsNote(message: gen_app_sechirut_px2_c24, label: gen_app_sechirut_px2_c25, tone: 0), DsNote(message: gen_app_sechirut_px2_c27, label: gen_app_sechirut_px2_c28, tone: 0), DsNote(message: gen_app_sechirut_px2_c30, label: gen_app_sechirut_px2_c31, tone: 0), DsNote(message: gen_app_sechirut_px2_c33, label: gen_app_sechirut_px2_c34, tone: 0)])),
  ]);
}
