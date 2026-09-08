// 📄 חולל ע"י חלקיק-הדוח (particles · G24 · הכרעה-27): מבנה-קבוע-לרשומה; כל חלק מורכב מחלקיקים שנמצאו בחיפוש-פתוח. אל תערוך ידנית.
//   סיווג = [תוכן סיווג]
//   שעון = [תוכן שעון]
//   הודעה למשכיר וואטסאפ תיאור = הודעה למשכיר וואטסאפ תיאור
//   הודעה אם אין תשובה = הודעה אם אין תשובה
//   אסור = [תוכן אסור]
//   אופציות אחרי השעון רק = אופציות אחרי השעון רק, [תוכן אופציות אחרי השעון רק]
//   מה לצלם היום כדי = [תוכן מה לצלם היום כדי]
//   לוח = לוח
//   הסתייגות = [תוכן הסתייגות]
//   [תוכן סיווג]⇒DsNote
//   [תוכן שעון]⇒DsNote
//   הודעה למשכיר וואטסאפ תיאור⇒ForgeMustChip+DsNote
//   הודעה אם אין תשובה⇒ForgeMustChip+DsNote
//   [תוכן אסור]⇒DsNote
//   אופציות אחרי השעון רק⇒DsChip
//   [תוכן אופציות אחרי השעון רק]⇒DsNote
//   [תוכן מה לצלם היום כדי]⇒DsNote
//   לוח⇒KvLine
//   [תוכן הסתייגות]⇒DsNote
//   שליחה בוואטסאפ⇒DsChipButton+waLink

import '../dart-data-bs/auto/gen_app_peruk03_rp1_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-forge-bs/selection/must_chip.dart';
import '../dart-forge-bs/selection/seg_picker_selection.dart';
import '../dart-forge-bs/selection/segmented_pill_toggle_selection.dart';
import '../dart-forge-bs/selection/star_rating.dart';
import '../dart-forge-bs/selection/unit_segment_toggle_selection.dart';
import '../dart-maor/wa-digits.dart';
import '../dart-maor/wa-link.dart';
import '../dart-ui-bs/auto/empty_state.dart';
import '../dart-ui-bs/auto/kv_line.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/status/status.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

/// 📤 סריאליזציית-הדוח לטקסט (G25): *חלק* · שורות; נבדקת ב-test/genesis_gen_app_<ns>_report_test.dart
String reportTextGenAppPeruk03Rp1Screen(Map<String, String> r0, String id0) {
  final b = <String>[
    gen_app_peruk03_rp1_c5,
    gen_app_peruk03_rp1_c56,
    gen_app_peruk03_rp1_c60,
    gen_app_peruk03_rp1_c66,
    gen_app_peruk03_rp1_c70,
    [for (final r in [r0]) [gen_app_peruk03_rp1_c91, ([(r[gen_app_peruk03_rp1_c93] ?? '')].any((x) => x.trim().isEmpty) ? '' : (gen_app_peruk03_rp1_c92 + (r[gen_app_peruk03_rp1_c93] ?? '') + gen_app_peruk03_rp1_c94)), ([gen_app_peruk03_rp1_c96].any((x) => x.trim().isEmpty) ? '' : (gen_app_peruk03_rp1_c95 + gen_app_peruk03_rp1_c96 + gen_app_peruk03_rp1_c97))].where((x) => x.trim().isNotEmpty).join(' ')].join('\n'),
    gen_app_peruk03_rp1_c101,
    [for (final r in [r0]) [gen_app_peruk03_rp1_c122, ([(r[gen_app_peruk03_rp1_c124] ?? '')].any((x) => x.trim().isEmpty) ? '' : (gen_app_peruk03_rp1_c123 + (r[gen_app_peruk03_rp1_c124] ?? '') + gen_app_peruk03_rp1_c125)), ([gen_app_peruk03_rp1_c127].any((x) => x.trim().isEmpty) ? '' : (gen_app_peruk03_rp1_c126 + gen_app_peruk03_rp1_c127 + gen_app_peruk03_rp1_c128))].where((x) => x.trim().isNotEmpty).join(' ')].join('\n'),
    gen_app_peruk03_rp1_c132,
    gen_app_peruk03_rp1_c159,
    gen_app_peruk03_rp1_c163,
    [for (final r in [r0].where((r) => (r[gen_app_peruk03_rp1_c174] ?? '').toString().trim().isNotEmpty)) gen_app_peruk03_rp1_c172 + ': ' + (r[gen_app_peruk03_rp1_c173] ?? '')].join('\n'),
    gen_app_peruk03_rp1_c180,
    gen_app_peruk03_rp1_c184,
    gen_app_peruk03_rp1_c193,
    gen_app_peruk03_rp1_c197,
    [for (final r in [r0]) ...[if ((r[gen_app_peruk03_rp1_c205] ?? '').trim().isNotEmpty) gen_app_peruk03_rp1_c206 + ': ' + (r[gen_app_peruk03_rp1_c207] ?? ''), if ((r[gen_app_peruk03_rp1_c208] ?? '').trim().isNotEmpty) gen_app_peruk03_rp1_c209 + ': ' + (r[gen_app_peruk03_rp1_c210] ?? '')]].join('\n'),
    gen_app_peruk03_rp1_c214,
    gen_app_peruk03_rp1_c220,
  ];
  return b.where((s) => s.trim().isNotEmpty).join('\n');
}

class GenAppPeruk03Rp1Screen extends StatefulWidget {
  const GenAppPeruk03Rp1Screen({this.initialId, super.key});
  final String? initialId;   // G26 · פתיחה מעמוד-השורש: הדוח של הרשומה הזו
  @override
  State<GenAppPeruk03Rp1Screen> createState() => _GenAppPeruk03Rp1ScreenState();
}

class _GenAppPeruk03Rp1ScreenState extends State<GenAppPeruk03Rp1Screen> {
  int? _sel;
  Future<void> _send(BuildContext context, Map<String, String> r0, String id0) async {
    final text = reportTextGenAppPeruk03Rp1Screen(r0, id0);
    final dynamic url = waLink((r0[gen_app_peruk03_rp1_c226] ?? ''), text, waDigits);
    if (url is String && url.isNotEmpty) { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); return; }
    await Share.share(text);
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, __) {
    final rs = appStore.records('app_peruk03_ent1');
    if (rs.isEmpty) return DsScaffold(title: gen_app_peruk03_rp1_c227, subtitle: gen_app_peruk03_rp1_c228, icon: gen_app_peruk03_rp1_c230, children: [EmptyState(label: gen_app_peruk03_rp1_c3)]);
    final i0 = _sel ?? (widget.initialId != null ? rs.indexWhere((r) => r[AppStore.idKey] == widget.initialId) : 0);
    final i = (i0 < 0 ? 0 : i0).clamp(0, rs.length - 1);
    final r0 = rs[i];
    final id0 = r0[AppStore.idKey] ?? '';
    return DsScaffold(title: gen_app_peruk03_rp1_c227, subtitle: gen_app_peruk03_rp1_c228, icon: gen_app_peruk03_rp1_c231, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeMustChip(bare: true, items: [for (final s in [for (final o in appStore.options('app_peruk03_ent1')) o.value]) [s]], selected: {i}, onSelect: (v) => setState(() => _sel = v))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk03_rp1_c57, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsSection(title: gen_app_peruk03_rp1_c40, children: [DsNote(message: gen_app_peruk03_rp1_c7, label: gen_app_peruk03_rp1_c8, tone: 0), DsNote(message: gen_app_peruk03_rp1_c10, label: gen_app_peruk03_rp1_c11, tone: 0), DsNote(message: gen_app_peruk03_rp1_c13, label: gen_app_peruk03_rp1_c14, tone: 0), DsNote(message: gen_app_peruk03_rp1_c16, label: gen_app_peruk03_rp1_c17, tone: 0)], tone: 0), DsSection(title: gen_app_peruk03_rp1_c43, children: [DsNote(message: gen_app_peruk03_rp1_c19, label: gen_app_peruk03_rp1_c20, tone: 0)], tone: 0), DsSection(title: gen_app_peruk03_rp1_c46, children: [DsNote(message: gen_app_peruk03_rp1_c22, label: gen_app_peruk03_rp1_c23, tone: 0)], tone: 0), DsSection(title: gen_app_peruk03_rp1_c49, children: [DsNote(message: gen_app_peruk03_rp1_c25, label: gen_app_peruk03_rp1_c26, tone: 0), DsNote(message: gen_app_peruk03_rp1_c28, label: gen_app_peruk03_rp1_c29, tone: 0), DsNote(message: gen_app_peruk03_rp1_c31, label: gen_app_peruk03_rp1_c32, tone: 0), DsNote(message: gen_app_peruk03_rp1_c34, label: gen_app_peruk03_rp1_c35, tone: 0)], tone: 0), DsSection(title: gen_app_peruk03_rp1_c52, children: [DsNote(message: gen_app_peruk03_rp1_c37, label: gen_app_peruk03_rp1_c38, tone: 0)], tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk03_rp1_c67, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk03_rp1_c62, label: gen_app_peruk03_rp1_c63, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk03_rp1_c98, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0]) Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeMustChip(bare: true, items: [for (final s in [gen_app_peruk03_rp1_c76, gen_app_peruk03_rp1_c77]) [s]], selected: {((r[gen_app_peruk03_rp1_c72] ?? '') == gen_app_peruk03_rp1_c73 ? 0 : (r[gen_app_peruk03_rp1_c74] ?? '') == gen_app_peruk03_rp1_c75 ? 1 : 0)}, onSelect: (i) => appStore.update('app_peruk03_ent1', (r[AppStore.idKey] ?? ''), {gen_app_peruk03_rp1_c78: [gen_app_peruk03_rp1_c79, gen_app_peruk03_rp1_c80][i]}))), DsNote(message: [gen_app_peruk03_rp1_c81, ([(r[gen_app_peruk03_rp1_c83] ?? '')].any((x) => x.trim().isEmpty) ? '' : (gen_app_peruk03_rp1_c82 + (r[gen_app_peruk03_rp1_c83] ?? '') + gen_app_peruk03_rp1_c84)), ([gen_app_peruk03_rp1_c86].any((x) => x.trim().isEmpty) ? '' : (gen_app_peruk03_rp1_c85 + gen_app_peruk03_rp1_c86 + gen_app_peruk03_rp1_c87))].where((x) => x.trim().isNotEmpty).join(' '), label: gen_app_peruk03_rp1_c88, tone: 0)]))]))], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsFold(title: gen_app_peruk03_rp1_c229, details: [Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk03_rp1_c129, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0]) Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeMustChip(bare: true, items: [for (final s in [gen_app_peruk03_rp1_c107, gen_app_peruk03_rp1_c108]) [s]], selected: {((r[gen_app_peruk03_rp1_c103] ?? '') == gen_app_peruk03_rp1_c104 ? 0 : (r[gen_app_peruk03_rp1_c105] ?? '') == gen_app_peruk03_rp1_c106 ? 1 : 0)}, onSelect: (i) => appStore.update('app_peruk03_ent1', (r[AppStore.idKey] ?? ''), {gen_app_peruk03_rp1_c109: [gen_app_peruk03_rp1_c110, gen_app_peruk03_rp1_c111][i]}))), DsNote(message: [gen_app_peruk03_rp1_c112, ([(r[gen_app_peruk03_rp1_c114] ?? '')].any((x) => x.trim().isEmpty) ? '' : (gen_app_peruk03_rp1_c113 + (r[gen_app_peruk03_rp1_c114] ?? '') + gen_app_peruk03_rp1_c115)), ([gen_app_peruk03_rp1_c117].any((x) => x.trim().isEmpty) ? '' : (gen_app_peruk03_rp1_c116 + gen_app_peruk03_rp1_c117 + gen_app_peruk03_rp1_c118))].where((x) => x.trim().isNotEmpty).join(' '), label: gen_app_peruk03_rp1_c119, tone: 0)]))]))], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk03_rp1_c160, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk03_rp1_c134, label: gen_app_peruk03_rp1_c135, tone: 0), DsNote(message: gen_app_peruk03_rp1_c137, label: gen_app_peruk03_rp1_c138, tone: 0), DsNote(message: gen_app_peruk03_rp1_c140, label: gen_app_peruk03_rp1_c141, tone: 0), DsNote(message: gen_app_peruk03_rp1_c143, label: gen_app_peruk03_rp1_c144, tone: 0), DsNote(message: gen_app_peruk03_rp1_c146, label: gen_app_peruk03_rp1_c147, tone: 0), DsNote(message: gen_app_peruk03_rp1_c149, label: gen_app_peruk03_rp1_c150, tone: 0), DsNote(message: gen_app_peruk03_rp1_c152, label: gen_app_peruk03_rp1_c153, tone: 0), DsNote(message: gen_app_peruk03_rp1_c155, label: gen_app_peruk03_rp1_c156, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk03_rp1_c181, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_peruk03_rp1_c170] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_peruk03_rp1_c165 + ': ' + (r[gen_app_peruk03_rp1_c166] ?? '')]], variants: const <int>[0]))])), Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk03_rp1_c176, label: gen_app_peruk03_rp1_c177, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk03_rp1_c194, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk03_rp1_c186, label: gen_app_peruk03_rp1_c187, tone: 0), DsNote(message: gen_app_peruk03_rp1_c189, label: gen_app_peruk03_rp1_c190, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk03_rp1_c211, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0]) Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final e in (<List<String>>[[gen_app_peruk03_rp1_c200, (r[gen_app_peruk03_rp1_c201] ?? '')], [gen_app_peruk03_rp1_c202, (r[gen_app_peruk03_rp1_c203] ?? '')]].where((e) => e[1].trim().isNotEmpty).toList()..sort((a, b) => a[1].compareTo(b[1])))) KvLine(label: e[0], value: e[1])]))]))], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk03_rp1_c221, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk03_rp1_c216, label: gen_app_peruk03_rp1_c217, tone: 0)])], tone: 0))])),
      Padding(padding: const EdgeInsets.only(top: 4, bottom: 12), child: DsChipButton(label: gen_app_peruk03_rp1_c224, onTap: () => _send(context, r0, id0))),
    ]);
  });
}
