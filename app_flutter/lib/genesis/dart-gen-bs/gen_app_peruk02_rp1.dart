// 📄 חולל ע"י חלקיק-הדוח (particles · G24 · הכרעה-27): מבנה-קבוע-לרשומה; כל חלק מורכב מחלקיקים שנמצאו בחיפוש-פתוח. אל תערוך ידנית.
//   כרטיס = [תוכן כרטיס]
//   טבלת שורות = [תוכן טבלת שורות]
//   סכום יעד לדרישה = [תוכן סכום יעד לדרישה]
//   הודעת וואטסאפ אחת = [תוכן הודעת וואטסאפ אחת]
//   אם מתעלמים מדרגה הבאה = [תוכן אם מתעלמים מדרגה הבאה]
//   מה חסר = יציאה, [תוכן מה חסר]
//   לוח = לוח
//   הסתייגות = [תוכן הסתייגות]
//   [תוכן כרטיס]⇒DsNote
//   [תוכן טבלת שורות]⇒DsNote
//   [תוכן סכום יעד לדרישה]⇒DsNote
//   [תוכן הודעת וואטסאפ אחת]⇒DsNote
//   [תוכן אם מתעלמים מדרגה הבאה]⇒DsNote
//   יציאה⇒DsChip
//   [תוכן מה חסר]⇒DsNote
//   לוח⇒KvLine
//   [תוכן הסתייגות]⇒DsNote
//   שליחה בוואטסאפ⇒DsChipButton+waLink

import '../dart-data-bs/auto/gen_app_peruk02_rp1_content.dart';
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
String reportTextGenAppPeruk02Rp1Screen(Map<String, String> r0, String id0) {
  final b = <String>[
    gen_app_peruk02_rp1_c5,
    gen_app_peruk02_rp1_c17,
    gen_app_peruk02_rp1_c21,
    gen_app_peruk02_rp1_c27,
    gen_app_peruk02_rp1_c31,
    gen_app_peruk02_rp1_c40,
    gen_app_peruk02_rp1_c44,
    gen_app_peruk02_rp1_c53,
    gen_app_peruk02_rp1_c57,
    gen_app_peruk02_rp1_c69,
    gen_app_peruk02_rp1_c73,
    [for (final r in [r0].where((r) => (r[gen_app_peruk02_rp1_c84] ?? '').toString().trim().isNotEmpty)) gen_app_peruk02_rp1_c82 + ': ' + (r[gen_app_peruk02_rp1_c83] ?? '')].join('\n'),
    gen_app_peruk02_rp1_c93,
    gen_app_peruk02_rp1_c97,
    [for (final r in [r0]) ...[if ((r[gen_app_peruk02_rp1_c103] ?? '').trim().isNotEmpty) gen_app_peruk02_rp1_c104 + ': ' + (r[gen_app_peruk02_rp1_c105] ?? '')]].join('\n'),
    gen_app_peruk02_rp1_c109,
    gen_app_peruk02_rp1_c115,
  ];
  return b.where((s) => s.trim().isNotEmpty).join('\n');
}

class GenAppPeruk02Rp1Screen extends StatefulWidget {
  const GenAppPeruk02Rp1Screen({this.initialId, super.key});
  final String? initialId;   // G26 · פתיחה מעמוד-השורש: הדוח של הרשומה הזו
  @override
  State<GenAppPeruk02Rp1Screen> createState() => _GenAppPeruk02Rp1ScreenState();
}

class _GenAppPeruk02Rp1ScreenState extends State<GenAppPeruk02Rp1Screen> {
  int? _sel;
  Future<void> _send(BuildContext context, Map<String, String> r0, String id0) async {
    final text = reportTextGenAppPeruk02Rp1Screen(r0, id0);
    final dynamic url = waLink((r0[gen_app_peruk02_rp1_c121] ?? ''), text, waDigits);
    if (url is String && url.isNotEmpty) { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); return; }
    await Share.share(text);
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, __) {
    final rs = appStore.records('app_peruk02_ent1');
    if (rs.isEmpty) return DsScaffold(title: gen_app_peruk02_rp1_c122, subtitle: gen_app_peruk02_rp1_c123, icon: gen_app_peruk02_rp1_c125, children: [EmptyState(label: gen_app_peruk02_rp1_c3)]);
    final i0 = _sel ?? (widget.initialId != null ? rs.indexWhere((r) => r[AppStore.idKey] == widget.initialId) : 0);
    final i = (i0 < 0 ? 0 : i0).clamp(0, rs.length - 1);
    final r0 = rs[i];
    final id0 = r0[AppStore.idKey] ?? '';
    return DsScaffold(title: gen_app_peruk02_rp1_c122, subtitle: gen_app_peruk02_rp1_c123, icon: gen_app_peruk02_rp1_c126, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeMustChip(bare: true, items: [for (final s in [for (final o in appStore.options('app_peruk02_ent1')) o.value]) [s]], selected: {i}, onSelect: (v) => setState(() => _sel = v))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk02_rp1_c18, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk02_rp1_c7, label: gen_app_peruk02_rp1_c8, tone: 0), DsNote(message: gen_app_peruk02_rp1_c10, label: gen_app_peruk02_rp1_c11, tone: 0), DsNote(message: gen_app_peruk02_rp1_c13, label: gen_app_peruk02_rp1_c14, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk02_rp1_c28, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk02_rp1_c23, label: gen_app_peruk02_rp1_c24, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk02_rp1_c41, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk02_rp1_c33, label: gen_app_peruk02_rp1_c34, tone: 0), DsNote(message: gen_app_peruk02_rp1_c36, label: gen_app_peruk02_rp1_c37, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsFold(title: gen_app_peruk02_rp1_c124, details: [Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk02_rp1_c54, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk02_rp1_c46, label: gen_app_peruk02_rp1_c47, tone: 0), DsNote(message: gen_app_peruk02_rp1_c49, label: gen_app_peruk02_rp1_c50, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk02_rp1_c70, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk02_rp1_c59, label: gen_app_peruk02_rp1_c60, tone: 0), DsNote(message: gen_app_peruk02_rp1_c62, label: gen_app_peruk02_rp1_c63, tone: 0), DsNote(message: gen_app_peruk02_rp1_c65, label: gen_app_peruk02_rp1_c66, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk02_rp1_c94, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_peruk02_rp1_c80] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_peruk02_rp1_c75 + ': ' + (r[gen_app_peruk02_rp1_c76] ?? '')]], variants: const <int>[0]))])), Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk02_rp1_c86, label: gen_app_peruk02_rp1_c87, tone: 0), DsNote(message: gen_app_peruk02_rp1_c89, label: gen_app_peruk02_rp1_c90, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk02_rp1_c106, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0]) Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final e in (<List<String>>[[gen_app_peruk02_rp1_c100, (r[gen_app_peruk02_rp1_c101] ?? '')]].where((e) => e[1].trim().isNotEmpty).toList()..sort((a, b) => a[1].compareTo(b[1])))) KvLine(label: e[0], value: e[1])]))]))], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk02_rp1_c116, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk02_rp1_c111, label: gen_app_peruk02_rp1_c112, tone: 0)])], tone: 0))])),
      Padding(padding: const EdgeInsets.only(top: 4, bottom: 12), child: DsChipButton(label: gen_app_peruk02_rp1_c119, onTap: () => _send(context, r0, id0))),
    ]);
  });
}
