// 📄 חולל ע"י חלקיק-הדוח (particles · G24 · הכרעה-27): מבנה-קבוע-לרשומה; כל חלק מורכב מחלקיקים שנמצאו בחיפוש-פתוח. אל תערוך ידנית.
//   כרטיס = [תוכן כרטיס]
//   רשימת מסמכים להנחה השגה = [תוכן רשימת מסמכים להנחה השגה]
//   טיוטת פנייה קצרה = [תוכן טיוטת פנייה קצרה]
//   מה לשלם בינתיים שלא = [תוכן מה לשלם בינתיים שלא]
//   מתי אין מה לערער = [תוכן מתי אין מה לערער]
//   לוח = לוח
//   הסתייגות = [תוכן הסתייגות]
//   [תוכן כרטיס]⇒DsNote
//   [תוכן רשימת מסמכים להנחה השגה]⇒DsNote
//   [תוכן טיוטת פנייה קצרה]⇒DsNote
//   [תוכן מה לשלם בינתיים שלא]⇒DsNote
//   [תוכן מתי אין מה לערער]⇒DsNote
//   לוח⇒KvLine
//   [תוכן הסתייגות]⇒DsNote
//   שליחה בוואטסאפ⇒DsChipButton+waLink

import '../dart-data-bs/auto/gen_app_peruk19_rp1_content.dart';
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

/// 📤 סריאליזציית-הדוח לטקסט (G25): *חלק* · שורות; נבדקת ב-test/genesis_gen_app_<ns>_report_test.dart
String reportTextGenAppPeruk19Rp1Screen(Map<String, String> r0, String id0) {
  final b = <String>[
    gen_app_peruk19_rp1_c5,
    gen_app_peruk19_rp1_c11,
    gen_app_peruk19_rp1_c15,
    gen_app_peruk19_rp1_c21,
    gen_app_peruk19_rp1_c25,
    gen_app_peruk19_rp1_c31,
    gen_app_peruk19_rp1_c35,
    gen_app_peruk19_rp1_c41,
    gen_app_peruk19_rp1_c45,
    gen_app_peruk19_rp1_c51,
    gen_app_peruk19_rp1_c55,
    [for (final r in [r0]) ...[if ((r[gen_app_peruk19_rp1_c61] ?? '').trim().isNotEmpty) gen_app_peruk19_rp1_c62 + ': ' + (r[gen_app_peruk19_rp1_c63] ?? '')]].join('\n'),
    gen_app_peruk19_rp1_c67,
    gen_app_peruk19_rp1_c73,
  ];
  return b.where((s) => s.trim().isNotEmpty).join('\n');
}

class GenAppPeruk19Rp1Screen extends StatefulWidget {
  const GenAppPeruk19Rp1Screen({this.initialId, super.key});
  final String? initialId;   // G26 · פתיחה מעמוד-השורש: הדוח של הרשומה הזו
  @override
  State<GenAppPeruk19Rp1Screen> createState() => _GenAppPeruk19Rp1ScreenState();
}

class _GenAppPeruk19Rp1ScreenState extends State<GenAppPeruk19Rp1Screen> {
  int? _sel;
  Future<void> _send(BuildContext context, Map<String, String> r0, String id0) async {
    final text = reportTextGenAppPeruk19Rp1Screen(r0, id0);
    final dynamic url = waLink((r0[gen_app_peruk19_rp1_c79] ?? ''), text, waDigits);
    if (url is String && url.isNotEmpty) { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); return; }
    await Share.share(text);
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, __) {
    final rs = appStore.records('app_peruk19_ent1');
    if (rs.isEmpty) return DsScaffold(title: gen_app_peruk19_rp1_c80, subtitle: gen_app_peruk19_rp1_c81, icon: gen_app_peruk19_rp1_c83, children: [EmptyState(label: gen_app_peruk19_rp1_c3)]);
    final i0 = _sel ?? (widget.initialId != null ? rs.indexWhere((r) => r[AppStore.idKey] == widget.initialId) : 0);
    final i = (i0 < 0 ? 0 : i0).clamp(0, rs.length - 1);
    final r0 = rs[i];
    final id0 = r0[AppStore.idKey] ?? '';
    return DsScaffold(title: gen_app_peruk19_rp1_c80, subtitle: gen_app_peruk19_rp1_c81, icon: gen_app_peruk19_rp1_c84, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeMustChip(bare: true, items: [for (final s in [for (final o in appStore.options('app_peruk19_ent1')) o.value]) [s]], selected: {i}, onSelect: (v) => setState(() => _sel = v))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk19_rp1_c12, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk19_rp1_c7, label: gen_app_peruk19_rp1_c8, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk19_rp1_c22, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk19_rp1_c17, label: gen_app_peruk19_rp1_c18, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk19_rp1_c32, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk19_rp1_c27, label: gen_app_peruk19_rp1_c28, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsFold(title: gen_app_peruk19_rp1_c82, details: [Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk19_rp1_c42, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk19_rp1_c37, label: gen_app_peruk19_rp1_c38, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk19_rp1_c52, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk19_rp1_c47, label: gen_app_peruk19_rp1_c48, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk19_rp1_c64, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0]) Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final e in (<List<String>>[[gen_app_peruk19_rp1_c58, (r[gen_app_peruk19_rp1_c59] ?? '')]].where((e) => e[1].trim().isNotEmpty).toList()..sort((a, b) => a[1].compareTo(b[1])))) KvLine(label: e[0], value: e[1])]))]))], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk19_rp1_c74, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk19_rp1_c69, label: gen_app_peruk19_rp1_c70, tone: 0)])], tone: 0))])),
      Padding(padding: const EdgeInsets.only(top: 4, bottom: 12), child: DsChipButton(label: gen_app_peruk19_rp1_c77, onTap: () => _send(context, r0, id0))),
    ]);
  });
}
