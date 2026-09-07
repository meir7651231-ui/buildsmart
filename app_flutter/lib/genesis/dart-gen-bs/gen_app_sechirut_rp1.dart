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
//   שליחה בוואטסאפ⇒DsPrimaryButton+waLink

import '../dart-data-bs/auto/gen_app_sechirut_rp1_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-maor/wa-digits.dart';
import '../dart-maor/wa-link.dart';
import '../dart-ui-bs/auto/empty_state.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/premium/actions/segmented_switch.dart';
import '../dart-ui-bs/premium/dataviz/kpi_tile.dart';
import '../dart-ui-bs/premium/feedback/toast_card.dart';
import '../dart-ui-bs/premium/lists/stat_row.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/card/card.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/header/header.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/selection/selection.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/status/status.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

/// 📤 סריאליזציית-הדוח לטקסט (G25): *חלק* · שורות; נבדקת ב-test/genesis_gen_app_<ns>_report_test.dart
String reportTextGenAppSechirutRp1Screen(Map<String, String> r0, String id0) {
  final b = <String>[
    gen_app_sechirut_rp1_c5,
    [for (final r in [r0].where((r) => (r[gen_app_sechirut_rp1_c16] ?? '').toString().trim().isNotEmpty)) gen_app_sechirut_rp1_c14 + ': ' + (r[gen_app_sechirut_rp1_c15] ?? '')].join('\n'),
    [for (final r in [r0].where((r) => (r[gen_app_sechirut_rp1_c27] ?? '').toString().trim().isNotEmpty)) gen_app_sechirut_rp1_c25 + ': ' + (r[gen_app_sechirut_rp1_c26] ?? '')].join('\n'),
    [for (final r in [r0].where((r) => (r[gen_app_sechirut_rp1_c38] ?? '').toString().trim().isNotEmpty)) gen_app_sechirut_rp1_c36 + ': ' + (r[gen_app_sechirut_rp1_c37] ?? '')].join('\n'),
    [for (final r in [r0].where((r) => (r[gen_app_sechirut_rp1_c49] ?? '').toString().trim().isNotEmpty)) gen_app_sechirut_rp1_c47 + ': ' + (r[gen_app_sechirut_rp1_c48] ?? '')].join('\n'),
    [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c50, id0).where((r) => (r[gen_app_sechirut_rp1_c61] ?? '').toString().trim().isNotEmpty)) gen_app_sechirut_rp1_c59 + ': ' + (r[gen_app_sechirut_rp1_c60] ?? '')].join('\n'),
    [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c62, id0).where((r) => (r[gen_app_sechirut_rp1_c73] ?? '').toString().trim().isNotEmpty)) gen_app_sechirut_rp1_c71 + ': ' + (r[gen_app_sechirut_rp1_c72] ?? '')].join('\n'),
    gen_app_sechirut_rp1_c77,
    ['*' + gen_app_sechirut_rp1_c101 + ' · ' + appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c78, id0).where((r) => (r[gen_app_sechirut_rp1_c99] ?? '') == gen_app_sechirut_rp1_c100).toList().length.toString() + '*' + [for (final r in appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c78, id0).where((r) => (r[gen_app_sechirut_rp1_c99] ?? '') == gen_app_sechirut_rp1_c100).toList()) '\n- ' + (r[gen_app_sechirut_rp1_c102] ?? '')].join(), '*' + gen_app_sechirut_rp1_c105 + ' · ' + appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c78, id0).where((r) => (r[gen_app_sechirut_rp1_c103] ?? '') == gen_app_sechirut_rp1_c104).toList().length.toString() + '*' + [for (final r in appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c78, id0).where((r) => (r[gen_app_sechirut_rp1_c103] ?? '') == gen_app_sechirut_rp1_c104).toList()) '\n- ' + (r[gen_app_sechirut_rp1_c106] ?? '')].join(), '*' + gen_app_sechirut_rp1_c109 + ' · ' + appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c78, id0).where((r) => (r[gen_app_sechirut_rp1_c107] ?? '') == gen_app_sechirut_rp1_c108).toList().length.toString() + '*' + [for (final r in appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c78, id0).where((r) => (r[gen_app_sechirut_rp1_c107] ?? '') == gen_app_sechirut_rp1_c108).toList()) '\n- ' + (r[gen_app_sechirut_rp1_c110] ?? '')].join()].join('\n'),
    gen_app_sechirut_rp1_c114,
    [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c115, id0).where((r) => (r[gen_app_sechirut_rp1_c126] ?? '').toString().trim().isNotEmpty)) gen_app_sechirut_rp1_c124 + ': ' + (r[gen_app_sechirut_rp1_c125] ?? '')].join('\n'),
    [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c127, id0).where((r) => (r[gen_app_sechirut_rp1_c138] ?? '').toString().trim().isNotEmpty)) gen_app_sechirut_rp1_c136 + ': ' + (r[gen_app_sechirut_rp1_c137] ?? '')].join('\n'),
    [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c139, id0)) gen_app_sechirut_rp1_c145 + ': ' + ((num.tryParse(r[gen_app_sechirut_rp1_c147] ?? '') ?? 0) == 0 ? 0.0 : (num.tryParse(r[gen_app_sechirut_rp1_c146] ?? '') ?? 0) / (num.tryParse(r[gen_app_sechirut_rp1_c147] ?? '') ?? 0)).toStringAsFixed(2)].join('\n'),
    gen_app_sechirut_rp1_c155 + ': ' + appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c148, id0).where((r) => (r[gen_app_sechirut_rp1_c157] ?? '') == gen_app_sechirut_rp1_c158).length.toDouble().toStringAsFixed(0),
    gen_app_sechirut_rp1_c162,
    [for (final r in appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c163, id0).where((r) => (r[gen_app_sechirut_rp1_c172] ?? '').toString().trim().isNotEmpty)) (r[gen_app_sechirut_rp1_c171] ?? '')].join('\n'),
    gen_app_sechirut_rp1_c176,
    [for (final r in [r0].where((r) => (r[gen_app_sechirut_rp1_c187] ?? '').toString().trim().isNotEmpty)) gen_app_sechirut_rp1_c185 + ': ' + (r[gen_app_sechirut_rp1_c186] ?? '')].join('\n'),
    gen_app_sechirut_rp1_c191,
    gen_app_sechirut_rp1_c197,
    gen_app_sechirut_rp1_c201,
    gen_app_sechirut_rp1_c207,
  ];
  return b.where((s) => s.trim().isNotEmpty).join('\n');
}

class GenAppSechirutRp1Screen extends StatefulWidget {
  const GenAppSechirutRp1Screen({super.key});
  @override
  State<GenAppSechirutRp1Screen> createState() => _GenAppSechirutRp1ScreenState();
}

class _GenAppSechirutRp1ScreenState extends State<GenAppSechirutRp1Screen> {
  int _i = 0;
  Future<void> _send(BuildContext context, Map<String, String> r0, String id0) async {
    final text = reportTextGenAppSechirutRp1Screen(r0, id0);
    final dynamic url = waLink((r0[gen_app_sechirut_rp1_c213] ?? ''), text, waDigits);
    if (url is String && url.isNotEmpty) { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); return; }
    await Share.share(text);
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, __) {
    final rs = appStore.records('app_sechirut_ent1');
    if (rs.isEmpty) return DsScaffold(title: gen_app_sechirut_rp1_c214, subtitle: gen_app_sechirut_rp1_c215, icon: gen_app_sechirut_rp1_c216, header: false, children: [ForgeCenteredPageHeader(fields: ['', gen_app_sechirut_rp1_c214, gen_app_sechirut_rp1_c215]), ...[EmptyState(label: gen_app_sechirut_rp1_c3)]]);
    final r0 = rs[_i.clamp(0, rs.length - 1)];
    final id0 = r0[AppStore.idKey] ?? '';
    return DsScaffold(title: gen_app_sechirut_rp1_c214, subtitle: gen_app_sechirut_rp1_c215, icon: gen_app_sechirut_rp1_c217, header: false, children: [ForgeCenteredPageHeader(fields: ['', gen_app_sechirut_rp1_c214, gen_app_sechirut_rp1_c215]), ...[
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeSegPickerSelection(bare: true, items: [for (final s in [for (final o in appStore.options('app_sechirut_ent1')) o.value]) [s]], selected: {_i}, onSelect: (i) => setState(() => _i = i))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_sechirut_rp1_c74, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_sechirut_rp1_c12] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c7 + ': ' + (r[gen_app_sechirut_rp1_c8] ?? '')]], variants: const <int>[0]))])), AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_sechirut_rp1_c23] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c18 + ': ' + (r[gen_app_sechirut_rp1_c19] ?? '')]], variants: const <int>[0]))])), AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_sechirut_rp1_c34] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c29 + ': ' + (r[gen_app_sechirut_rp1_c30] ?? '')]], variants: const <int>[0]))])), AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_sechirut_rp1_c45] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c40 + ': ' + (r[gen_app_sechirut_rp1_c41] ?? '')]], variants: const <int>[0]))])), AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c50, id0).where((r) => (r[gen_app_sechirut_rp1_c57] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c52 + ': ' + (r[gen_app_sechirut_rp1_c53] ?? '')]], variants: const <int>[0]))])), AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c62, id0).where((r) => (r[gen_app_sechirut_rp1_c69] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c64 + ': ' + (r[gen_app_sechirut_rp1_c65] ?? '')]], variants: const <int>[0]))]))]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_sechirut_rp1_c111, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsSection(title: gen_app_sechirut_rp1_c85 + ' · ' + appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c78, id0).where((r) => (r[gen_app_sechirut_rp1_c83] ?? '') == gen_app_sechirut_rp1_c84).toList().length.toString(), children: [for (final r in appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c78, id0).where((r) => (r[gen_app_sechirut_rp1_c83] ?? '') == gen_app_sechirut_rp1_c84).toList()) ToastCard(message: (r[gen_app_sechirut_rp1_c80] ?? ''), tone: 0)], tone: 0), DsSection(title: gen_app_sechirut_rp1_c90 + ' · ' + appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c78, id0).where((r) => (r[gen_app_sechirut_rp1_c88] ?? '') == gen_app_sechirut_rp1_c89).toList().length.toString(), children: [for (final r in appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c78, id0).where((r) => (r[gen_app_sechirut_rp1_c88] ?? '') == gen_app_sechirut_rp1_c89).toList()) ToastCard(message: (r[gen_app_sechirut_rp1_c80] ?? ''), tone: 0)], tone: 0), DsSection(title: gen_app_sechirut_rp1_c95 + ' · ' + appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c78, id0).where((r) => (r[gen_app_sechirut_rp1_c93] ?? '') == gen_app_sechirut_rp1_c94).toList().length.toString(), children: [for (final r in appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c78, id0).where((r) => (r[gen_app_sechirut_rp1_c93] ?? '') == gen_app_sechirut_rp1_c94).toList()) ToastCard(message: (r[gen_app_sechirut_rp1_c80] ?? ''), tone: 0)], tone: 0)]))]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_sechirut_rp1_c159, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c115, id0).where((r) => (r[gen_app_sechirut_rp1_c122] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c117 + ': ' + (r[gen_app_sechirut_rp1_c118] ?? '')]], variants: const <int>[0]))])), AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c127, id0).where((r) => (r[gen_app_sechirut_rp1_c134] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c129 + ': ' + (r[gen_app_sechirut_rp1_c130] ?? '')]], variants: const <int>[0]))])), AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c139, id0)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeLinearProgressStatus(fields: [gen_app_sechirut_rp1_c140, ((num.tryParse(r[gen_app_sechirut_rp1_c142] ?? '') ?? 0) == 0 ? 0.0 : (num.tryParse(r[gen_app_sechirut_rp1_c141] ?? '') ?? 0) / (num.tryParse(r[gen_app_sechirut_rp1_c142] ?? '') ?? 0)).toStringAsFixed(2)], values: [((num.tryParse(r[gen_app_sechirut_rp1_c142] ?? '') ?? 0) == 0 ? 0.0 : (num.tryParse(r[gen_app_sechirut_rp1_c141] ?? '') ?? 0) / (num.tryParse(r[gen_app_sechirut_rp1_c142] ?? '') ?? 0)).clamp(0.0, 1.0).toDouble()]))])), AnimatedBuilder(animation: appStore, builder: (context, _) => ForgeStatPlain(fields: [gen_app_sechirut_rp1_c149, appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c148, id0).where((r) => (r[gen_app_sechirut_rp1_c151] ?? '') == gen_app_sechirut_rp1_c152).length.toDouble().toStringAsFixed(0)]))]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_sechirut_rp1_c173, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c163, id0).where((r) => (r[gen_app_sechirut_rp1_c169] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[(r[gen_app_sechirut_rp1_c165] ?? '')]], variants: const <int>[0]))]))]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_sechirut_rp1_c188, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_sechirut_rp1_c183] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c178 + ': ' + (r[gen_app_sechirut_rp1_c179] ?? '')]], variants: const <int>[0]))]))]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_sechirut_rp1_c198, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_sechirut_rp1_c193, tone: 0)])]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_sechirut_rp1_c208, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_sechirut_rp1_c203, tone: 0)])]]))),
      Padding(padding: const EdgeInsets.only(top: 4, bottom: 12), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _send(context, r0, id0), child: ForgeToneButton(items: [[gen_app_sechirut_rp1_c211]]))),
    ]]);
  });
}
