// 📄 חולל ע"י חלקיק-הדוח (particles · G24 · הכרעה-27): מבנה-קבוע-לרשומה; כל חלק מורכב מחלקיקים שנמצאו בחיפוש-פתוח. אל תערוך ידנית.
//   כרטיס = מחיר
//   רשימת שאלות למוכר מקסימום = [תוכן רשימת שאלות למוכר מקסימום]
//   מה לבדוק בנסיעה = [תוכן מה לבדוק בנסיעה]
//   מה חייב לפני העברה = [תוכן מה חייב לפני העברה]
//   נוסח = [תוכן נוסח]
//   החלטה = [תוכן החלטה]
//   הסתייגות = [תוכן הסתייגות]
//   מחיר⇒DsChip
//   [תוכן רשימת שאלות למוכר מקסימום]⇒DsNote
//   [תוכן מה לבדוק בנסיעה]⇒DsNote
//   [תוכן מה חייב לפני העברה]⇒DsNote
//   [תוכן נוסח]⇒DsNote
//   [תוכן החלטה]⇒DsNote
//   [תוכן הסתייגות]⇒DsNote
//   שליחה בוואטסאפ⇒DsChipButton+waLink

import '../dart-data-bs/auto/gen_app_peruk12_rp1_content.dart';
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
String reportTextGenAppPeruk12Rp1Screen(Map<String, String> r0, String id0) {
  final b = <String>[
    gen_app_peruk12_rp1_c5,
    [for (final r in [r0].where((r) => (r[gen_app_peruk12_rp1_c16] ?? '').toString().trim().isNotEmpty)) gen_app_peruk12_rp1_c14 + ': ' + (r[gen_app_peruk12_rp1_c15] ?? '')].join('\n'),
    gen_app_peruk12_rp1_c20,
    gen_app_peruk12_rp1_c26,
    gen_app_peruk12_rp1_c30,
    gen_app_peruk12_rp1_c36,
    gen_app_peruk12_rp1_c40,
    gen_app_peruk12_rp1_c46,
    gen_app_peruk12_rp1_c50,
    gen_app_peruk12_rp1_c59,
    gen_app_peruk12_rp1_c63,
    gen_app_peruk12_rp1_c72,
    gen_app_peruk12_rp1_c76,
    gen_app_peruk12_rp1_c82,
  ];
  return b.where((s) => s.trim().isNotEmpty).join('\n');
}

class GenAppPeruk12Rp1Screen extends StatefulWidget {
  const GenAppPeruk12Rp1Screen({this.initialId, super.key});
  final String? initialId;   // G26 · פתיחה מעמוד-השורש: הדוח של הרשומה הזו
  @override
  State<GenAppPeruk12Rp1Screen> createState() => _GenAppPeruk12Rp1ScreenState();
}

class _GenAppPeruk12Rp1ScreenState extends State<GenAppPeruk12Rp1Screen> {
  int? _sel;
  Future<void> _send(BuildContext context, Map<String, String> r0, String id0) async {
    final text = reportTextGenAppPeruk12Rp1Screen(r0, id0);
    final dynamic url = waLink((r0[gen_app_peruk12_rp1_c88] ?? ''), text, waDigits);
    if (url is String && url.isNotEmpty) { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); return; }
    await Share.share(text);
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, __) {
    final rs = appStore.records('app_peruk12_ent1');
    if (rs.isEmpty) return DsScaffold(title: gen_app_peruk12_rp1_c89, subtitle: gen_app_peruk12_rp1_c90, icon: gen_app_peruk12_rp1_c92, children: [EmptyState(label: gen_app_peruk12_rp1_c3)]);
    final i0 = _sel ?? (widget.initialId != null ? rs.indexWhere((r) => r[AppStore.idKey] == widget.initialId) : 0);
    final i = (i0 < 0 ? 0 : i0).clamp(0, rs.length - 1);
    final r0 = rs[i];
    final id0 = r0[AppStore.idKey] ?? '';
    return DsScaffold(title: gen_app_peruk12_rp1_c89, subtitle: gen_app_peruk12_rp1_c90, icon: gen_app_peruk12_rp1_c93, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeMustChip(bare: true, items: [for (final s in [for (final o in appStore.options('app_peruk12_ent1')) o.value]) [s]], selected: {i}, onSelect: (v) => setState(() => _sel = v))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk12_rp1_c17, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_peruk12_rp1_c12] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_peruk12_rp1_c7 + ': ' + (r[gen_app_peruk12_rp1_c8] ?? '')]], variants: const <int>[0]))]))], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk12_rp1_c27, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk12_rp1_c22, label: gen_app_peruk12_rp1_c23, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk12_rp1_c37, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk12_rp1_c32, label: gen_app_peruk12_rp1_c33, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsFold(title: gen_app_peruk12_rp1_c91, details: [Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk12_rp1_c47, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk12_rp1_c42, label: gen_app_peruk12_rp1_c43, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk12_rp1_c60, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk12_rp1_c52, label: gen_app_peruk12_rp1_c53, tone: 0), DsNote(message: gen_app_peruk12_rp1_c55, label: gen_app_peruk12_rp1_c56, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk12_rp1_c73, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk12_rp1_c65, label: gen_app_peruk12_rp1_c66, tone: 0), DsNote(message: gen_app_peruk12_rp1_c68, label: gen_app_peruk12_rp1_c69, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk12_rp1_c83, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk12_rp1_c78, label: gen_app_peruk12_rp1_c79, tone: 0)])], tone: 0))])),
      Padding(padding: const EdgeInsets.only(top: 4, bottom: 12), child: DsChipButton(label: gen_app_peruk12_rp1_c86, onTap: () => _send(context, r0, id0))),
    ]);
  });
}
