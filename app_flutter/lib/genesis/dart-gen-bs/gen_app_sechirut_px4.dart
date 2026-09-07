// 🧩 חולל ע"י מפרק-החלקיקים הפתוח (particles · הכרעה-27): כל חלקיק נמצא בכל הקטלוג ומורכב מחדש. אל תערוך ידנית.
//   הכנסה = סכום(סכום) ⇒ sum ⇒ [headline] ⇒ KpiTile
//   לא שולם = מונה(שולם=לא) ⇒ count ⇒ [headline] ⇒ KpiTile

import '../dart-data-bs/auto/gen_app_sechirut_px4_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/premium/dataviz/kpi_tile.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/card/card.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/header/header.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppSechirutPx4Screen extends StatelessWidget {
  const GenAppSechirutPx4Screen({super.key});
  @override
  Widget build(BuildContext context) => DsScaffold(title: gen_app_sechirut_px4_c9, subtitle: gen_app_sechirut_px4_c10, icon: gen_app_sechirut_px4_c11, header: false, children: [ForgeCenteredPageHeader(fields: ['', gen_app_sechirut_px4_c9, gen_app_sechirut_px4_c10]), ...[
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeStatPlain(fields: [gen_app_sechirut_px4_c0, appStore.sum('app_sechirut_ent4', gen_app_sechirut_px4_c1).toStringAsFixed(0)]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeStatPlain(fields: [gen_app_sechirut_px4_c4, appStore.records('app_sechirut_ent4').where((r) => (r[gen_app_sechirut_px4_c5] ?? '') == gen_app_sechirut_px4_c6).length.toDouble().toStringAsFixed(0)]))),
  ]]);
}
