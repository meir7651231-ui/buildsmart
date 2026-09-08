// 📄 חולל ע"י חלקיק-הדוח (particles · G24 · הכרעה-27): מבנה-קבוע-לרשומה; כל חלק מורכב מחלקיקים שנמצאו בחיפוש-פתוח. אל תערוך ידנית.
//   מפת בטוחות = [תוכן מפת בטוחות]
//   חשיפת ההורה במשפט אחד = [תוכן חשיפת ההורה במשפט אחד]
//   בקשות לתיקון לפני חתימה = בקשות לתיקון לפני חתימה
//   הודעה למשכיר מתווך = הודעה למשכיר מתווך
//   החלטה = השטר
//   הסתייגות = [תוכן הסתייגות]
//   [תוכן מפת בטוחות]⇒DsNote
//   [תוכן חשיפת ההורה במשפט אחד]⇒DsNote
//   בקשות לתיקון לפני חתימה⇒DsChip
//   הודעה למשכיר מתווך⇒ForgeMustChip+DsNote
//   השטר⇒DsChip
//   [תוכן הסתייגות]⇒DsNote
//   שליחה בוואטסאפ⇒DsChipButton+waLink

import '../dart-data-bs/auto/gen_app_peruk05_rp1_content.dart';
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
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/status/status.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

/// 📤 סריאליזציית-הדוח לטקסט (G25): *חלק* · שורות; נבדקת ב-test/genesis_gen_app_<ns>_report_test.dart
String reportTextGenAppPeruk05Rp1Screen(Map<String, String> r0, String id0) {
  final b = <String>[
    gen_app_peruk05_rp1_c5,
    gen_app_peruk05_rp1_c14,
    gen_app_peruk05_rp1_c18,
    gen_app_peruk05_rp1_c30,
    gen_app_peruk05_rp1_c34,
    [for (final r in [r0].where((r) => (r[gen_app_peruk05_rp1_c45] ?? '').toString().trim().isNotEmpty)) gen_app_peruk05_rp1_c43 + ': ' + (r[gen_app_peruk05_rp1_c44] ?? '')].join('\n'),
    gen_app_peruk05_rp1_c49,
    [for (final r in [r0]) [gen_app_peruk05_rp1_c79, ([(r[gen_app_peruk05_rp1_c81] ?? '')].any((x) => x.trim().isEmpty) ? '' : (gen_app_peruk05_rp1_c80 + (r[gen_app_peruk05_rp1_c81] ?? '') + gen_app_peruk05_rp1_c82)), ([appStore.referencing('app_peruk05_ent2', gen_app_peruk05_rp1_c84, (r[AppStore.idKey] ?? '')).map((c) => (c[gen_app_peruk05_rp1_c85] ?? '')).where((x) => x.trim().isNotEmpty).join(', ')].any((x) => x.trim().isEmpty) ? '' : (gen_app_peruk05_rp1_c83 + appStore.referencing('app_peruk05_ent2', gen_app_peruk05_rp1_c84, (r[AppStore.idKey] ?? '')).map((c) => (c[gen_app_peruk05_rp1_c85] ?? '')).where((x) => x.trim().isNotEmpty).join(', ') + gen_app_peruk05_rp1_c86))].where((x) => x.trim().isNotEmpty).join(' ')].join('\n'),
    gen_app_peruk05_rp1_c90,
    [for (final r in [r0].where((r) => (r[gen_app_peruk05_rp1_c101] ?? '').toString().trim().isNotEmpty)) gen_app_peruk05_rp1_c99 + ': ' + (r[gen_app_peruk05_rp1_c100] ?? '')].join('\n'),
    gen_app_peruk05_rp1_c105,
    gen_app_peruk05_rp1_c111,
  ];
  return b.where((s) => s.trim().isNotEmpty).join('\n');
}

class GenAppPeruk05Rp1Screen extends StatefulWidget {
  const GenAppPeruk05Rp1Screen({this.initialId, super.key});
  final String? initialId;   // G26 · פתיחה מעמוד-השורש: הדוח של הרשומה הזו
  @override
  State<GenAppPeruk05Rp1Screen> createState() => _GenAppPeruk05Rp1ScreenState();
}

class _GenAppPeruk05Rp1ScreenState extends State<GenAppPeruk05Rp1Screen> {
  int? _sel;
  Future<void> _send(BuildContext context, Map<String, String> r0, String id0) async {
    final text = reportTextGenAppPeruk05Rp1Screen(r0, id0);
    final dynamic url = waLink((r0[gen_app_peruk05_rp1_c117] ?? ''), text, waDigits);
    if (url is String && url.isNotEmpty) { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); return; }
    await Share.share(text);
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, __) {
    final rs = appStore.records('app_peruk05_ent1');
    if (rs.isEmpty) return DsScaffold(title: gen_app_peruk05_rp1_c118, subtitle: gen_app_peruk05_rp1_c119, icon: gen_app_peruk05_rp1_c121, children: [EmptyState(label: gen_app_peruk05_rp1_c3)]);
    final i0 = _sel ?? (widget.initialId != null ? rs.indexWhere((r) => r[AppStore.idKey] == widget.initialId) : 0);
    final i = (i0 < 0 ? 0 : i0).clamp(0, rs.length - 1);
    final r0 = rs[i];
    final id0 = r0[AppStore.idKey] ?? '';
    return DsScaffold(title: gen_app_peruk05_rp1_c118, subtitle: gen_app_peruk05_rp1_c119, icon: gen_app_peruk05_rp1_c122, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeMustChip(bare: true, items: [for (final s in [for (final o in appStore.options('app_peruk05_ent1')) o.value]) [s]], selected: {i}, onSelect: (v) => setState(() => _sel = v))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk05_rp1_c15, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk05_rp1_c7, label: gen_app_peruk05_rp1_c8, tone: 0), DsNote(message: gen_app_peruk05_rp1_c10, label: gen_app_peruk05_rp1_c11, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk05_rp1_c31, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk05_rp1_c20, label: gen_app_peruk05_rp1_c21, tone: 0), DsNote(message: gen_app_peruk05_rp1_c23, label: gen_app_peruk05_rp1_c24, tone: 0), DsNote(message: gen_app_peruk05_rp1_c26, label: gen_app_peruk05_rp1_c27, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk05_rp1_c46, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_peruk05_rp1_c41] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_peruk05_rp1_c36 + ': ' + (r[gen_app_peruk05_rp1_c37] ?? '')]], variants: const <int>[0]))]))], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsFold(title: gen_app_peruk05_rp1_c120, details: [Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk05_rp1_c87, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0]) Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeMustChip(bare: true, items: [for (final s in [gen_app_peruk05_rp1_c59, gen_app_peruk05_rp1_c60, gen_app_peruk05_rp1_c61, gen_app_peruk05_rp1_c62]) [s]], selected: {((r[gen_app_peruk05_rp1_c51] ?? '') == gen_app_peruk05_rp1_c52 ? 0 : (r[gen_app_peruk05_rp1_c53] ?? '') == gen_app_peruk05_rp1_c54 ? 1 : (r[gen_app_peruk05_rp1_c55] ?? '') == gen_app_peruk05_rp1_c56 ? 2 : (r[gen_app_peruk05_rp1_c57] ?? '') == gen_app_peruk05_rp1_c58 ? 3 : 0)}, onSelect: (i) => appStore.update('app_peruk05_ent1', (r[AppStore.idKey] ?? ''), {gen_app_peruk05_rp1_c63: [gen_app_peruk05_rp1_c64, gen_app_peruk05_rp1_c65, gen_app_peruk05_rp1_c66, gen_app_peruk05_rp1_c67][i]}))), DsNote(message: [gen_app_peruk05_rp1_c68, ([(r[gen_app_peruk05_rp1_c70] ?? '')].any((x) => x.trim().isEmpty) ? '' : (gen_app_peruk05_rp1_c69 + (r[gen_app_peruk05_rp1_c70] ?? '') + gen_app_peruk05_rp1_c71)), ([appStore.referencing('app_peruk05_ent2', gen_app_peruk05_rp1_c73, (r[AppStore.idKey] ?? '')).map((c) => (c[gen_app_peruk05_rp1_c74] ?? '')).where((x) => x.trim().isNotEmpty).join(', ')].any((x) => x.trim().isEmpty) ? '' : (gen_app_peruk05_rp1_c72 + appStore.referencing('app_peruk05_ent2', gen_app_peruk05_rp1_c73, (r[AppStore.idKey] ?? '')).map((c) => (c[gen_app_peruk05_rp1_c74] ?? '')).where((x) => x.trim().isNotEmpty).join(', ') + gen_app_peruk05_rp1_c75))].where((x) => x.trim().isNotEmpty).join(' '), label: gen_app_peruk05_rp1_c76, tone: 0)]))]))], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk05_rp1_c102, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_peruk05_rp1_c97] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_peruk05_rp1_c92 + ': ' + (r[gen_app_peruk05_rp1_c93] ?? '')]], variants: const <int>[0]))]))], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk05_rp1_c112, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk05_rp1_c107, label: gen_app_peruk05_rp1_c108, tone: 0)])], tone: 0))])),
      Padding(padding: const EdgeInsets.only(top: 4, bottom: 12), child: DsChipButton(label: gen_app_peruk05_rp1_c115, onTap: () => _send(context, r0, id0))),
    ]);
  });
}
