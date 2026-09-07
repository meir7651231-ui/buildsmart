// 📄 חולל ע"י חלקיק-הדוח (particles · G24 · הכרעה-27): מבנה-קבוע-לרשומה; כל חלק מורכב מחלקיקים שנמצאו בחיפוש-פתוח. אל תערוך ידנית.
//   כרטיס עסקה = לקוח, שכירות, חודשים, שכירות לשנה, בטוחה.סך בטוחות, בטוחה.חורג מול 3 חודשים
//   אדום צהוב ירוק = ממצא.צבע
//   חישוב בטוחות = בטוחה.תקרה לפי 3 חודשים, בטוחה.תקרה לפי שליש, בטוחה.חורג, בטוחה.מעל התקרה
//   בקשות לשינוי = ממצא.מה לבקש
//   החלטה = החלטה
//   מה לא בדקנו = [תוכן לא נבדק]
//   הסתייגות = [תוכן הסתייגות]
//   לקוח⇒DsChip
//   שכירות⇒DsChip
//   חודשים⇒DsChip
//   שכירות לשנה⇒DsChip
//   בטוחה.סך בטוחות⇒DsChip
//   בטוחה.חורג מול 3 חודשים⇒DsChip
//   ממצא.צבע⇒DsSection+ToastCard
//   בטוחה.תקרה לפי 3 חודשים⇒DsChip
//   בטוחה.תקרה לפי שליש⇒DsChip
//   בטוחה.חורג⇒StatRow
//   בטוחה.מעל התקרה⇒KpiTile
//   ממצא.מה לבקש⇒DsChip
//   החלטה⇒DsChip
//   [תוכן לא נבדק]⇒ToastCard
//   [תוכן הסתייגות]⇒ToastCard

import '../dart-data-bs/auto/gen_app_sechirut_rp1_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/auto/empty_state.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/premium/actions/segmented_switch.dart';
import '../dart-ui-bs/premium/dataviz/kpi_tile.dart';
import '../dart-ui-bs/premium/feedback/toast_card.dart';
import '../dart-ui-bs/premium/lists/stat_row.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/card/card.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/header/header.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/selection/selection.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/status/status.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppSechirutRp1Screen extends StatefulWidget {
  const GenAppSechirutRp1Screen({super.key});
  @override
  State<GenAppSechirutRp1Screen> createState() => _GenAppSechirutRp1ScreenState();
}

class _GenAppSechirutRp1ScreenState extends State<GenAppSechirutRp1Screen> {
  int _i = 0;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, __) {
    final rs = appStore.records('app_sechirut_ent1');
    if (rs.isEmpty) return DsScaffold(title: gen_app_sechirut_rp1_c141, subtitle: gen_app_sechirut_rp1_c142, icon: gen_app_sechirut_rp1_c143, header: false, children: [ForgeCenteredPageHeader(fields: ['', gen_app_sechirut_rp1_c141, gen_app_sechirut_rp1_c142]), ...[EmptyState(label: gen_app_sechirut_rp1_c3)]]);
    final r0 = rs[_i.clamp(0, rs.length - 1)];
    final id0 = r0[AppStore.idKey] ?? '';
    return DsScaffold(title: gen_app_sechirut_rp1_c141, subtitle: gen_app_sechirut_rp1_c142, icon: gen_app_sechirut_rp1_c144, header: false, children: [ForgeCenteredPageHeader(fields: ['', gen_app_sechirut_rp1_c141, gen_app_sechirut_rp1_c142]), ...[
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeSegPickerSelection(bare: true, items: [for (final s in [for (final o in appStore.options('app_sechirut_ent1')) o.value]) [s]], selected: {_i}, onSelect: (i) => setState(() => _i = i))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_sechirut_rp1_c49, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_sechirut_rp1_c11] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c6 + ': ' + (r[gen_app_sechirut_rp1_c7] ?? '')]], variants: const <int>[0]))])), AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_sechirut_rp1_c18] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c13 + ': ' + (r[gen_app_sechirut_rp1_c14] ?? '')]], variants: const <int>[0]))])), AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_sechirut_rp1_c25] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c20 + ': ' + (r[gen_app_sechirut_rp1_c21] ?? '')]], variants: const <int>[0]))])), AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_sechirut_rp1_c32] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c27 + ': ' + (r[gen_app_sechirut_rp1_c28] ?? '')]], variants: const <int>[0]))])), AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c33, id0).where((r) => (r[gen_app_sechirut_rp1_c40] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c35 + ': ' + (r[gen_app_sechirut_rp1_c36] ?? '')]], variants: const <int>[0]))])), AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c41, id0).where((r) => (r[gen_app_sechirut_rp1_c48] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c43 + ': ' + (r[gen_app_sechirut_rp1_c44] ?? '')]], variants: const <int>[0]))]))]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_sechirut_rp1_c72, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsSection(title: gen_app_sechirut_rp1_c59 + ' · ' + appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c52, id0).where((r) => (r[gen_app_sechirut_rp1_c57] ?? '') == gen_app_sechirut_rp1_c58).toList().length.toString(), children: [for (final r in appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c52, id0).where((r) => (r[gen_app_sechirut_rp1_c57] ?? '') == gen_app_sechirut_rp1_c58).toList()) ToastCard(message: (r[gen_app_sechirut_rp1_c54] ?? ''), tone: 0)], tone: 0), DsSection(title: gen_app_sechirut_rp1_c64 + ' · ' + appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c52, id0).where((r) => (r[gen_app_sechirut_rp1_c62] ?? '') == gen_app_sechirut_rp1_c63).toList().length.toString(), children: [for (final r in appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c52, id0).where((r) => (r[gen_app_sechirut_rp1_c62] ?? '') == gen_app_sechirut_rp1_c63).toList()) ToastCard(message: (r[gen_app_sechirut_rp1_c54] ?? ''), tone: 0)], tone: 0), DsSection(title: gen_app_sechirut_rp1_c69 + ' · ' + appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c52, id0).where((r) => (r[gen_app_sechirut_rp1_c67] ?? '') == gen_app_sechirut_rp1_c68).toList().length.toString(), children: [for (final r in appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c52, id0).where((r) => (r[gen_app_sechirut_rp1_c67] ?? '') == gen_app_sechirut_rp1_c68).toList()) ToastCard(message: (r[gen_app_sechirut_rp1_c54] ?? ''), tone: 0)], tone: 0)]))]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_sechirut_rp1_c104, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c75, id0).where((r) => (r[gen_app_sechirut_rp1_c82] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c77 + ': ' + (r[gen_app_sechirut_rp1_c78] ?? '')]], variants: const <int>[0]))])), AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c83, id0).where((r) => (r[gen_app_sechirut_rp1_c90] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c85 + ': ' + (r[gen_app_sechirut_rp1_c86] ?? '')]], variants: const <int>[0]))])), AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c91, id0)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeLinearProgressStatus(fields: [gen_app_sechirut_rp1_c92, ((num.tryParse(r[gen_app_sechirut_rp1_c94] ?? '') ?? 0) == 0 ? 0.0 : (num.tryParse(r[gen_app_sechirut_rp1_c93] ?? '') ?? 0) / (num.tryParse(r[gen_app_sechirut_rp1_c94] ?? '') ?? 0)).toStringAsFixed(2)], values: [((num.tryParse(r[gen_app_sechirut_rp1_c94] ?? '') ?? 0) == 0 ? 0.0 : (num.tryParse(r[gen_app_sechirut_rp1_c93] ?? '') ?? 0) / (num.tryParse(r[gen_app_sechirut_rp1_c94] ?? '') ?? 0)).clamp(0.0, 1.0).toDouble()]))])), AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeStatPlain(fields: [gen_app_sechirut_rp1_c98, appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c97, id0).where((r) => (r[gen_app_sechirut_rp1_c100] ?? '') == gen_app_sechirut_rp1_c101).length.toDouble().toStringAsFixed(0)]))]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_sechirut_rp1_c114, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c107, id0).where((r) => (r[gen_app_sechirut_rp1_c113] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[(r[gen_app_sechirut_rp1_c109] ?? '')]], variants: const <int>[0]))]))]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_sechirut_rp1_c124, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_sechirut_rp1_c123] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c118 + ': ' + (r[gen_app_sechirut_rp1_c119] ?? '')]], variants: const <int>[0]))]))]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_sechirut_rp1_c131, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_sechirut_rp1_c128, tone: 0)])]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_sechirut_rp1_c138, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_sechirut_rp1_c135, tone: 0)])]]))),
    ]]);
  });
}
