// 🧩 חולל ע"י מפרק-החלקיקים הפתוח (particles · הכרעה-27): כל חלקיק נמצא בכל הקטלוג ומורכב מחדש. אל תערוך ידנית.
//   אדומים = מונה(צבע=אדום) ⇒ count ⇒ [headline] ⇒ KpiTile
//   צבע = צבע ⇒ partition ⇒ [group] ⇒ SectionHeader
//   מה לבקש = מה לבקש ⇒ raw ⇒ [fact] ⇒ DsChip
//   ריק אין ממצאים עדיין = [ריק] אין ממצאים עדיין ⇒ empty ⇒ [empty] ⇒ EmptyState@premium/feedback

import '../dart-data-bs/auto/gen_app_sechirut_px3_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/auto/empty_state.dart';
import '../dart-ui-bs/auto/section_header.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/premium/dataviz/kpi_tile.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/card/card.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/header/header.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/status/status.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppSechirutPx3Screen extends StatelessWidget {
  const GenAppSechirutPx3Screen({super.key});
  @override
  Widget build(BuildContext context) => DsScaffold(title: gen_app_sechirut_px3_c37, subtitle: gen_app_sechirut_px3_c38, icon: gen_app_sechirut_px3_c39, header: false, children: [ForgeCenteredPageHeader(fields: ['', gen_app_sechirut_px3_c37, gen_app_sechirut_px3_c38]), ...[
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeStatPlain(fields: [gen_app_sechirut_px3_c0, appStore.records('app_sechirut_ent3').where((r) => (r[gen_app_sechirut_px3_c1] ?? '') == gen_app_sechirut_px3_c2).length.toDouble().toStringAsFixed(0)]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [SectionHeader(gen_app_sechirut_px3_c11 + ' · ' + appStore.records('app_sechirut_ent3').where((r) => (r[gen_app_sechirut_px3_c9] ?? '') == gen_app_sechirut_px3_c10).toList().length.toString()), ...[for (final r in appStore.records('app_sechirut_ent3').where((r) => (r[gen_app_sechirut_px3_c9] ?? '') == gen_app_sechirut_px3_c10).toList()) Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Text((r[gen_app_sechirut_px3_c14] ?? '')))], SectionHeader(gen_app_sechirut_px3_c17 + ' · ' + appStore.records('app_sechirut_ent3').where((r) => (r[gen_app_sechirut_px3_c15] ?? '') == gen_app_sechirut_px3_c16).toList().length.toString()), ...[for (final r in appStore.records('app_sechirut_ent3').where((r) => (r[gen_app_sechirut_px3_c15] ?? '') == gen_app_sechirut_px3_c16).toList()) Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Text((r[gen_app_sechirut_px3_c20] ?? '')))], SectionHeader(gen_app_sechirut_px3_c23 + ' · ' + appStore.records('app_sechirut_ent3').where((r) => (r[gen_app_sechirut_px3_c21] ?? '') == gen_app_sechirut_px3_c22).toList().length.toString()), ...[for (final r in appStore.records('app_sechirut_ent3').where((r) => (r[gen_app_sechirut_px3_c21] ?? '') == gen_app_sechirut_px3_c22).toList()) Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Text((r[gen_app_sechirut_px3_c26] ?? '')))]]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in appStore.records('app_sechirut_ent3').where((r) => (r[gen_app_sechirut_px3_c33] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[(r[gen_app_sechirut_px3_c28] ?? '')]], variants: const <int>[0]))]))),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => appStore.records('app_sechirut_ent3').isEmpty ? EmptyState(label: gen_app_sechirut_px3_c34) : const SizedBox.shrink())),
  ]]);
}
