// 🧩 חולל ע"י מפרק-החלקיקים הפתוח (particles · הכרעה-27): כל חלקיק נמצא בכל הקטלוג ומורכב מחדש. אל תערוך ידנית.
//   חורג = סך בטוחות / תקרה לפי 3 חודשים ⇒ / ⇒ [ratio] ⇒ StatRow
//   מעל התקרה = מונה(חורג מול 3 חודשים=חורג) ⇒ count ⇒ [headline] ⇒ KpiTile
//   מה החוק קובע = [תוכן חוק] ⇒ content ⇒ [alert] ⇒ ToastCard

import '../dart-data-bs/auto/gen_app_sechirut_px2_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/premium/dataviz/kpi_tile.dart';
import '../dart-ui-bs/premium/feedback/toast_card.dart';
import '../dart-ui-bs/premium/lists/stat_row.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/card/card.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/status/status.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/header/header.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppSechirutPx2Screen extends StatelessWidget {
  const GenAppSechirutPx2Screen({super.key});
  @override
  Widget build(BuildContext context) => DsScaffold(title: gen_app_sechirut_px2_c36, subtitle: gen_app_sechirut_px2_c37, icon: gen_app_sechirut_px2_c38, header: false, children: [ForgeCenteredPageHeader(fields: ['', gen_app_sechirut_px2_c36, gen_app_sechirut_px2_c37]), ...[
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in appStore.records('app_sechirut_ent2')) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeLinearProgressStatus(fields: [gen_app_sechirut_px2_c0, ((num.tryParse(r[gen_app_sechirut_px2_c2] ?? '') ?? 0) == 0 ? 0.0 : (num.tryParse(r[gen_app_sechirut_px2_c1] ?? '') ?? 0) / (num.tryParse(r[gen_app_sechirut_px2_c2] ?? '') ?? 0)).toStringAsFixed(2)], values: [((num.tryParse(r[gen_app_sechirut_px2_c2] ?? '') ?? 0) == 0 ? 0.0 : (num.tryParse(r[gen_app_sechirut_px2_c1] ?? '') ?? 0) / (num.tryParse(r[gen_app_sechirut_px2_c2] ?? '') ?? 0)).clamp(0.0, 1.0).toDouble()]))]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeStatPlain(fields: [gen_app_sechirut_px2_c5, appStore.records('app_sechirut_ent2').where((r) => (r[gen_app_sechirut_px2_c7] ?? '') == gen_app_sechirut_px2_c8).length.toDouble().toStringAsFixed(0)]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_sechirut_px2_c12, tone: 0), ToastCard(message: gen_app_sechirut_px2_c15, tone: 0), ToastCard(message: gen_app_sechirut_px2_c18, tone: 0), ToastCard(message: gen_app_sechirut_px2_c21, tone: 0), ToastCard(message: gen_app_sechirut_px2_c24, tone: 0), ToastCard(message: gen_app_sechirut_px2_c27, tone: 0), ToastCard(message: gen_app_sechirut_px2_c30, tone: 0), ToastCard(message: gen_app_sechirut_px2_c33, tone: 0)])),
  ]]);
}
