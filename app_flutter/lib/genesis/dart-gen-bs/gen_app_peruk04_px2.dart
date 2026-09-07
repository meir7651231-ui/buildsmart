// 🧩 חולל ע"י מפרק-החלקיקים הפתוח (particles · הכרעה-27): כל חלקיק נמצא בכל הקטלוג ומורכב מחדש. אל תערוך ידנית.
//   בדיקה = [תוכן בדיקה] ⇒ content ⇒ [group, alert] ⇒ ToastCard
//   צבע = צבע ⇒ partition ⇒ [group, alert] ⇒ DsSection + ToastCard

import '../dart-data-bs/auto/gen_app_peruk04_px2_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/auto/section_header.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/premium/feedback/toast_card.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/header/header.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppPeruk04Px2Screen extends StatelessWidget {
  const GenAppPeruk04Px2Screen({super.key});
  @override
  Widget build(BuildContext context) => DsScaffold(title: gen_app_peruk04_px2_c68, subtitle: gen_app_peruk04_px2_c69, icon: gen_app_peruk04_px2_c70, header: false, children: [ForgeCenteredPageHeader(fields: ['', gen_app_peruk04_px2_c68, gen_app_peruk04_px2_c69]), ...[
    Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [SectionHeader(gen_app_peruk04_px2_c40), ToastCard(message: gen_app_peruk04_px2_c1, tone: 0), ToastCard(message: gen_app_peruk04_px2_c4, tone: 0), ToastCard(message: gen_app_peruk04_px2_c7, tone: 0), ToastCard(message: gen_app_peruk04_px2_c10, tone: 0)]), Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [SectionHeader(gen_app_peruk04_px2_c43), ToastCard(message: gen_app_peruk04_px2_c13, tone: 0), ToastCard(message: gen_app_peruk04_px2_c16, tone: 0), ToastCard(message: gen_app_peruk04_px2_c19, tone: 0), ToastCard(message: gen_app_peruk04_px2_c22, tone: 0), ToastCard(message: gen_app_peruk04_px2_c25, tone: 0), ToastCard(message: gen_app_peruk04_px2_c28, tone: 0)]), Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [SectionHeader(gen_app_peruk04_px2_c46), ToastCard(message: gen_app_peruk04_px2_c31, tone: 0), ToastCard(message: gen_app_peruk04_px2_c34, tone: 0), ToastCard(message: gen_app_peruk04_px2_c37, tone: 0)])])),
    Padding(padding: const EdgeInsets.only(bottom: 10), child: AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ForgeTitledSection(fields: [gen_app_peruk04_px2_c55 + ' · ' + appStore.records('app_peruk04_ent2').where((r) => (r[gen_app_peruk04_px2_c53] ?? '') == gen_app_peruk04_px2_c54).toList().length.toString(), '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[for (final r in appStore.records('app_peruk04_ent2').where((r) => (r[gen_app_peruk04_px2_c53] ?? '') == gen_app_peruk04_px2_c54).toList()) ToastCard(message: (r[gen_app_peruk04_px2_c50] ?? ''), tone: 0)]])), ForgeTitledSection(fields: [gen_app_peruk04_px2_c60 + ' · ' + appStore.records('app_peruk04_ent2').where((r) => (r[gen_app_peruk04_px2_c58] ?? '') == gen_app_peruk04_px2_c59).toList().length.toString(), '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[for (final r in appStore.records('app_peruk04_ent2').where((r) => (r[gen_app_peruk04_px2_c58] ?? '') == gen_app_peruk04_px2_c59).toList()) ToastCard(message: (r[gen_app_peruk04_px2_c50] ?? ''), tone: 0)]])), ForgeTitledSection(fields: [gen_app_peruk04_px2_c65 + ' · ' + appStore.records('app_peruk04_ent2').where((r) => (r[gen_app_peruk04_px2_c63] ?? '') == gen_app_peruk04_px2_c64).toList().length.toString(), '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[for (final r in appStore.records('app_peruk04_ent2').where((r) => (r[gen_app_peruk04_px2_c63] ?? '') == gen_app_peruk04_px2_c64).toList()) ToastCard(message: (r[gen_app_peruk04_px2_c50] ?? ''), tone: 0)]]))]))),
  ]]);
}
