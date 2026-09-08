// 📄 חולל ע"י חלקיק-הדוח (particles · G24 · הכרעה-27): מבנה-קבוע-לרשומה; כל חלק מורכב מחלקיקים שנמצאו בחיפוש-פתוח. אל תערוך ידנית.
//   המספר שלך = המספר שלך
//   אדום צהוב ירוק = ממצא.צבע
//   התשובה = התשובה
//   לוח = לוח
//   כרטיס עסקה = לקוח, שכירות, חודשים, שכירות לשנה, בטוחה.סך בטוחות, בטוחה.חורג מול 3 חודשים
//   חישוב בטוחות = בטוחה.תקרה לפי 3 חודשים, בטוחה.תקרה לפי שליש, בטוחה.חורג, בטוחה.מעל התקרה
//   בקשות לשינוי = ממצא.מה לבקש
//   מה לא בדקנו = [תוכן לא נבדק]
//   הסתייגות = [תוכן הסתייגות]
//   המספר שלך⇒KvLine
//   ממצא.צבע⇒DsSection+DsNote
//   התשובה⇒ForgeMustChip+DsNote
//   לוח⇒KvLine
//   לקוח⇒DsChip
//   שכירות⇒DsChip
//   חודשים⇒DsChip
//   שכירות לשנה⇒DsChip
//   בטוחה.סך בטוחות⇒DsChip
//   בטוחה.חורג מול 3 חודשים⇒DsChip
//   בטוחה.תקרה לפי 3 חודשים⇒DsChip
//   בטוחה.תקרה לפי שליש⇒DsChip
//   בטוחה.חורג⇒ForgeGlowSlider
//   בטוחה.מעל התקרה⇒KvLine
//   ממצא.מה לבקש⇒DsChip
//   [תוכן לא נבדק]⇒DsNote
//   [תוכן הסתייגות]⇒DsNote
//   שליחה בוואטסאפ⇒DsPrimaryButton+waLink

import '../dart-data-bs/auto/gen_app_sechirut_rp1_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-forge-bs/input/glow_slider.dart';
import '../dart-forge-bs/selection/must_chip.dart';
import '../dart-forge-bs/selection/seg_picker_selection.dart';
import '../dart-forge-bs/selection/segmented_pill_toggle_selection.dart';
import '../dart-forge-bs/selection/star_rating.dart';
import '../dart-forge-bs/selection/unit_segment_toggle_selection.dart';
import '../dart-maor/wa-digits.dart';
import '../dart-maor/wa-link.dart';
import '../dart-ui-bs/auto/empty_state.dart';
import '../dart-ui-bs/auto/kv_line.dart';
import '../dart-ui-bs/ds/ds.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/status/status.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

/// 📤 סריאליזציית-הדוח לטקסט (G25): *חלק* · שורות; נבדקת ב-test/genesis_gen_app_<ns>_report_test.dart
String reportTextGenAppSechirutRp1Screen(Map<String, String> r0, String id0) {
  final b = <String>[
    gen_app_sechirut_rp1_c5,
    [for (final r in [r0]) gen_app_sechirut_rp1_c11 + ': ' + (num.tryParse(r[gen_app_sechirut_rp1_c12] ?? '') ?? 0).toStringAsFixed(0) + ' — ' + gen_app_sechirut_rp1_c13].join('\n'),
    gen_app_sechirut_rp1_c17,
    ['*' + gen_app_sechirut_rp1_c41 + ' · ' + appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c18, id0).where((r) => (r[gen_app_sechirut_rp1_c39] ?? '') == gen_app_sechirut_rp1_c40).toList().length.toString() + '*' + [for (final r in appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c18, id0).where((r) => (r[gen_app_sechirut_rp1_c39] ?? '') == gen_app_sechirut_rp1_c40).toList()) '\n- ' + (r[gen_app_sechirut_rp1_c42] ?? '')].join(), '*' + gen_app_sechirut_rp1_c45 + ' · ' + appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c18, id0).where((r) => (r[gen_app_sechirut_rp1_c43] ?? '') == gen_app_sechirut_rp1_c44).toList().length.toString() + '*' + [for (final r in appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c18, id0).where((r) => (r[gen_app_sechirut_rp1_c43] ?? '') == gen_app_sechirut_rp1_c44).toList()) '\n- ' + (r[gen_app_sechirut_rp1_c46] ?? '')].join(), '*' + gen_app_sechirut_rp1_c49 + ' · ' + appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c18, id0).where((r) => (r[gen_app_sechirut_rp1_c47] ?? '') == gen_app_sechirut_rp1_c48).toList().length.toString() + '*' + [for (final r in appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c18, id0).where((r) => (r[gen_app_sechirut_rp1_c47] ?? '') == gen_app_sechirut_rp1_c48).toList()) '\n- ' + (r[gen_app_sechirut_rp1_c50] ?? '')].join()].join('\n'),
    gen_app_sechirut_rp1_c54,
    [for (final r in [r0]) ((r[gen_app_sechirut_rp1_c106] ?? '') == gen_app_sechirut_rp1_c107 ? (gen_app_sechirut_rp1_c108 + appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c109, (r[AppStore.idKey] ?? '')).map((c) => c[gen_app_sechirut_rp1_c110] ?? '').where((x) => x.trim().isNotEmpty).join(', ') + gen_app_sechirut_rp1_c111) : (((r[gen_app_sechirut_rp1_c98] ?? '') == gen_app_sechirut_rp1_c99 ? (gen_app_sechirut_rp1_c100 + appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c101, (r[AppStore.idKey] ?? '')).map((c) => c[gen_app_sechirut_rp1_c102] ?? '').where((x) => x.trim().isNotEmpty).join(', ') + gen_app_sechirut_rp1_c103 + (r[gen_app_sechirut_rp1_c104] ?? '') + gen_app_sechirut_rp1_c105) : (((r[gen_app_sechirut_rp1_c95] ?? '') == gen_app_sechirut_rp1_c96 ? (gen_app_sechirut_rp1_c97) : (gen_app_sechirut_rp1_c92 + (r[gen_app_sechirut_rp1_c93] ?? '') + gen_app_sechirut_rp1_c94))))))].join('\n'),
    gen_app_sechirut_rp1_c115,
    [for (final r in [r0]) ...[if ((r[gen_app_sechirut_rp1_c121] ?? '').trim().isNotEmpty) gen_app_sechirut_rp1_c122 + ': ' + (r[gen_app_sechirut_rp1_c123] ?? '')]].join('\n'),
    gen_app_sechirut_rp1_c127,
    [for (final r in [r0].where((r) => (r[gen_app_sechirut_rp1_c138] ?? '').toString().trim().isNotEmpty)) gen_app_sechirut_rp1_c136 + ': ' + (r[gen_app_sechirut_rp1_c137] ?? '')].join('\n'),
    [for (final r in [r0].where((r) => (r[gen_app_sechirut_rp1_c149] ?? '').toString().trim().isNotEmpty)) gen_app_sechirut_rp1_c147 + ': ' + (r[gen_app_sechirut_rp1_c148] ?? '')].join('\n'),
    [for (final r in [r0].where((r) => (r[gen_app_sechirut_rp1_c160] ?? '').toString().trim().isNotEmpty)) gen_app_sechirut_rp1_c158 + ': ' + (r[gen_app_sechirut_rp1_c159] ?? '')].join('\n'),
    [for (final r in [r0].where((r) => (r[gen_app_sechirut_rp1_c171] ?? '').toString().trim().isNotEmpty)) gen_app_sechirut_rp1_c169 + ': ' + (r[gen_app_sechirut_rp1_c170] ?? '')].join('\n'),
    [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c172, id0).where((r) => (r[gen_app_sechirut_rp1_c183] ?? '').toString().trim().isNotEmpty)) gen_app_sechirut_rp1_c181 + ': ' + (r[gen_app_sechirut_rp1_c182] ?? '')].join('\n'),
    [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c184, id0).where((r) => (r[gen_app_sechirut_rp1_c195] ?? '').toString().trim().isNotEmpty)) gen_app_sechirut_rp1_c193 + ': ' + (r[gen_app_sechirut_rp1_c194] ?? '')].join('\n'),
    gen_app_sechirut_rp1_c199,
    [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c200, id0).where((r) => (r[gen_app_sechirut_rp1_c211] ?? '').toString().trim().isNotEmpty)) gen_app_sechirut_rp1_c209 + ': ' + (r[gen_app_sechirut_rp1_c210] ?? '')].join('\n'),
    [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c212, id0).where((r) => (r[gen_app_sechirut_rp1_c223] ?? '').toString().trim().isNotEmpty)) gen_app_sechirut_rp1_c221 + ': ' + (r[gen_app_sechirut_rp1_c222] ?? '')].join('\n'),
    [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c224, id0)) gen_app_sechirut_rp1_c230 + ': ' + ((num.tryParse(r[gen_app_sechirut_rp1_c232] ?? '') ?? 0) == 0 ? 0.0 : (num.tryParse(r[gen_app_sechirut_rp1_c231] ?? '') ?? 0) / (num.tryParse(r[gen_app_sechirut_rp1_c232] ?? '') ?? 0)).toStringAsFixed(2)].join('\n'),
    gen_app_sechirut_rp1_c240 + ': ' + appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c233, id0).where((r) => (r[gen_app_sechirut_rp1_c242] ?? '') == gen_app_sechirut_rp1_c243).length.toDouble().toStringAsFixed(0),
    gen_app_sechirut_rp1_c247,
    [for (final r in appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c248, id0).where((r) => (r[gen_app_sechirut_rp1_c257] ?? '').toString().trim().isNotEmpty)) (r[gen_app_sechirut_rp1_c256] ?? '')].join('\n'),
    gen_app_sechirut_rp1_c261,
    gen_app_sechirut_rp1_c267,
    gen_app_sechirut_rp1_c271,
    gen_app_sechirut_rp1_c277,
  ];
  return b.where((s) => s.trim().isNotEmpty).join('\n');
}

class GenAppSechirutRp1Screen extends StatefulWidget {
  const GenAppSechirutRp1Screen({this.initialId, super.key});
  final String? initialId;   // G26 · פתיחה מעמוד-השורש: הדוח של הרשומה הזו
  @override
  State<GenAppSechirutRp1Screen> createState() => _GenAppSechirutRp1ScreenState();
}

class _GenAppSechirutRp1ScreenState extends State<GenAppSechirutRp1Screen> {
  int? _sel;
  Future<void> _send(BuildContext context, Map<String, String> r0, String id0) async {
    final text = reportTextGenAppSechirutRp1Screen(r0, id0);
    final dynamic url = waLink((r0[gen_app_sechirut_rp1_c283] ?? ''), text, waDigits);
    if (url is String && url.isNotEmpty) { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); return; }
    await Share.share(text);
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, __) {
    final rs = appStore.records('app_sechirut_ent1');
    if (rs.isEmpty) return DsScaffold(title: gen_app_sechirut_rp1_c284, subtitle: gen_app_sechirut_rp1_c285, icon: gen_app_sechirut_rp1_c287, children: [EmptyState(label: gen_app_sechirut_rp1_c3)]);
    final i0 = _sel ?? (widget.initialId != null ? rs.indexWhere((r) => r[AppStore.idKey] == widget.initialId) : 0);
    final i = (i0 < 0 ? 0 : i0).clamp(0, rs.length - 1);
    final r0 = rs[i];
    final id0 = r0[AppStore.idKey] ?? '';
    return DsScaffold(title: gen_app_sechirut_rp1_c284, subtitle: gen_app_sechirut_rp1_c285, icon: gen_app_sechirut_rp1_c288, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeMustChip(bare: true, items: [for (final s in [for (final o in appStore.options('app_sechirut_ent1')) o.value]) [s]], selected: {i}, onSelect: (v) => setState(() => _sel = v))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_sechirut_rp1_c14, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0]) Padding(padding: const EdgeInsets.only(bottom: 8), child: KvLine(label: gen_app_sechirut_rp1_c6, value: (num.tryParse(r[gen_app_sechirut_rp1_c7] ?? '') ?? 0).toStringAsFixed(0)))]))], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_sechirut_rp1_c51, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsSection(title: gen_app_sechirut_rp1_c25 + ' · ' + appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c18, id0).where((r) => (r[gen_app_sechirut_rp1_c23] ?? '') == gen_app_sechirut_rp1_c24).toList().length.toString(), children: [for (final r in appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c18, id0).where((r) => (r[gen_app_sechirut_rp1_c23] ?? '') == gen_app_sechirut_rp1_c24).toList()) DsNote(message: (r[gen_app_sechirut_rp1_c20] ?? ''), label: (r[gen_app_sechirut_rp1_c21] ?? ''), tone: 0)], tone: 0), DsSection(title: gen_app_sechirut_rp1_c30 + ' · ' + appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c18, id0).where((r) => (r[gen_app_sechirut_rp1_c28] ?? '') == gen_app_sechirut_rp1_c29).toList().length.toString(), children: [for (final r in appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c18, id0).where((r) => (r[gen_app_sechirut_rp1_c28] ?? '') == gen_app_sechirut_rp1_c29).toList()) DsNote(message: (r[gen_app_sechirut_rp1_c20] ?? ''), label: (r[gen_app_sechirut_rp1_c21] ?? ''), tone: 0)], tone: 0), DsSection(title: gen_app_sechirut_rp1_c35 + ' · ' + appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c18, id0).where((r) => (r[gen_app_sechirut_rp1_c33] ?? '') == gen_app_sechirut_rp1_c34).toList().length.toString(), children: [for (final r in appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c18, id0).where((r) => (r[gen_app_sechirut_rp1_c33] ?? '') == gen_app_sechirut_rp1_c34).toList()) DsNote(message: (r[gen_app_sechirut_rp1_c20] ?? ''), label: (r[gen_app_sechirut_rp1_c21] ?? ''), tone: 0)], tone: 0)]))], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_sechirut_rp1_c112, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0]) Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeMustChip(bare: true, items: [for (final s in [gen_app_sechirut_rp1_c62, gen_app_sechirut_rp1_c63, gen_app_sechirut_rp1_c64]) [s]], selected: {((r[gen_app_sechirut_rp1_c56] ?? '') == gen_app_sechirut_rp1_c57 ? 0 : (r[gen_app_sechirut_rp1_c58] ?? '') == gen_app_sechirut_rp1_c59 ? 1 : (r[gen_app_sechirut_rp1_c60] ?? '') == gen_app_sechirut_rp1_c61 ? 2 : 0)}, onSelect: (i) => appStore.update('app_sechirut_ent1', (r[AppStore.idKey] ?? ''), {gen_app_sechirut_rp1_c65: [gen_app_sechirut_rp1_c66, gen_app_sechirut_rp1_c67, gen_app_sechirut_rp1_c68][i]}))), DsNote(message: ((r[gen_app_sechirut_rp1_c83] ?? '') == gen_app_sechirut_rp1_c84 ? (gen_app_sechirut_rp1_c85 + appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c86, (r[AppStore.idKey] ?? '')).map((c) => c[gen_app_sechirut_rp1_c87] ?? '').where((x) => x.trim().isNotEmpty).join(', ') + gen_app_sechirut_rp1_c88) : (((r[gen_app_sechirut_rp1_c75] ?? '') == gen_app_sechirut_rp1_c76 ? (gen_app_sechirut_rp1_c77 + appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c78, (r[AppStore.idKey] ?? '')).map((c) => c[gen_app_sechirut_rp1_c79] ?? '').where((x) => x.trim().isNotEmpty).join(', ') + gen_app_sechirut_rp1_c80 + (r[gen_app_sechirut_rp1_c81] ?? '') + gen_app_sechirut_rp1_c82) : (((r[gen_app_sechirut_rp1_c72] ?? '') == gen_app_sechirut_rp1_c73 ? (gen_app_sechirut_rp1_c74) : (gen_app_sechirut_rp1_c69 + (r[gen_app_sechirut_rp1_c70] ?? '') + gen_app_sechirut_rp1_c71)))))), label: gen_app_sechirut_rp1_c89, tone: 0)]))]))], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsFold(title: gen_app_sechirut_rp1_c286, details: [Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_sechirut_rp1_c124, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0]) Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final e in (<List<String>>[[gen_app_sechirut_rp1_c118, (r[gen_app_sechirut_rp1_c119] ?? '')]].where((e) => e[1].trim().isNotEmpty).toList()..sort((a, b) => a[1].compareTo(b[1])))) KvLine(label: e[0], value: e[1])]))]))], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_sechirut_rp1_c196, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_sechirut_rp1_c134] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c129 + ': ' + (r[gen_app_sechirut_rp1_c130] ?? '')]], variants: const <int>[0]))])), AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_sechirut_rp1_c145] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c140 + ': ' + (r[gen_app_sechirut_rp1_c141] ?? '')]], variants: const <int>[0]))])), AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_sechirut_rp1_c156] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c151 + ': ' + (r[gen_app_sechirut_rp1_c152] ?? '')]], variants: const <int>[0]))])), AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_sechirut_rp1_c167] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c162 + ': ' + (r[gen_app_sechirut_rp1_c163] ?? '')]], variants: const <int>[0]))])), AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c172, id0).where((r) => (r[gen_app_sechirut_rp1_c179] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c174 + ': ' + (r[gen_app_sechirut_rp1_c175] ?? '')]], variants: const <int>[0]))])), AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c184, id0).where((r) => (r[gen_app_sechirut_rp1_c191] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c186 + ': ' + (r[gen_app_sechirut_rp1_c187] ?? '')]], variants: const <int>[0]))]))], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_sechirut_rp1_c244, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c200, id0).where((r) => (r[gen_app_sechirut_rp1_c207] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c202 + ': ' + (r[gen_app_sechirut_rp1_c203] ?? '')]], variants: const <int>[0]))])), AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c212, id0).where((r) => (r[gen_app_sechirut_rp1_c219] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_sechirut_rp1_c214 + ': ' + (r[gen_app_sechirut_rp1_c215] ?? '')]], variants: const <int>[0]))])), AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c224, id0)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeGlowSlider())])), AnimatedBuilder(animation: appStore, builder: (context, _) => KvLine(label: gen_app_sechirut_rp1_c234, value: appStore.referencing('app_sechirut_ent2', gen_app_sechirut_rp1_c233, id0).where((r) => (r[gen_app_sechirut_rp1_c236] ?? '') == gen_app_sechirut_rp1_c237).length.toDouble().toStringAsFixed(0)))], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_sechirut_rp1_c258, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in appStore.referencing('app_sechirut_ent3', gen_app_sechirut_rp1_c248, id0).where((r) => (r[gen_app_sechirut_rp1_c254] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[(r[gen_app_sechirut_rp1_c250] ?? '')]], variants: const <int>[0]))]))], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_sechirut_rp1_c268, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_sechirut_rp1_c263, label: gen_app_sechirut_rp1_c264, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_sechirut_rp1_c278, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_sechirut_rp1_c273, label: gen_app_sechirut_rp1_c274, tone: 0)])], tone: 0))])),
      Padding(padding: const EdgeInsets.only(top: 4, bottom: 12), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _send(context, r0, id0), child: ForgeToneButton(items: [[gen_app_sechirut_rp1_c281]]))),
    ]);
  });
}
