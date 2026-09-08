// 📄 חולל ע"י חלקיק-הדוח (particles · G24 · הכרעה-27): מבנה-קבוע-לרשומה; כל חלק מורכב מחלקיקים שנמצאו בחיפוש-פתוח. אל תערוך ידנית.
//   כרטיס = [תוכן כרטיס]
//   שאלות לבית החולים לקופה = [תוכן שאלות לבית החולים לקופה]
//   טיוטת בקשת פירוט העברת = [תוכן טיוטת בקשת פירוט העברת]
//   מה לא לדחות סתם = [תוכן מה לא לדחות סתם]
//   אם כבר הוצל״פ עצירה = [תוכן אם כבר הוצל״פ עצירה]
//   הסתייגות = [תוכן הסתייגות]
//   [תוכן כרטיס]⇒DsNote
//   [תוכן שאלות לבית החולים לקופה]⇒DsNote
//   [תוכן טיוטת בקשת פירוט העברת]⇒DsNote
//   [תוכן מה לא לדחות סתם]⇒DsNote
//   [תוכן אם כבר הוצל״פ עצירה]⇒DsNote
//   [תוכן הסתייגות]⇒DsNote
//   שליחה בוואטסאפ⇒DsChipButton+waLink

import '../dart-data-bs/auto/gen_app_peruk15_rp1_content.dart';
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

/// 📤 סריאליזציית-הדוח לטקסט (G25): *חלק* · שורות; נבדקת ב-test/genesis_gen_app_<ns>_report_test.dart
String reportTextGenAppPeruk15Rp1Screen(Map<String, String> r0, String id0) {
  final b = <String>[
    gen_app_peruk15_rp1_c5,
    gen_app_peruk15_rp1_c14,
    gen_app_peruk15_rp1_c18,
    gen_app_peruk15_rp1_c24,
    gen_app_peruk15_rp1_c28,
    gen_app_peruk15_rp1_c34,
    gen_app_peruk15_rp1_c38,
    gen_app_peruk15_rp1_c44,
    gen_app_peruk15_rp1_c48,
    gen_app_peruk15_rp1_c54,
    gen_app_peruk15_rp1_c58,
    gen_app_peruk15_rp1_c64,
  ];
  return b.where((s) => s.trim().isNotEmpty).join('\n');
}

class GenAppPeruk15Rp1Screen extends StatefulWidget {
  const GenAppPeruk15Rp1Screen({this.initialId, super.key});
  final String? initialId;   // G26 · פתיחה מעמוד-השורש: הדוח של הרשומה הזו
  @override
  State<GenAppPeruk15Rp1Screen> createState() => _GenAppPeruk15Rp1ScreenState();
}

class _GenAppPeruk15Rp1ScreenState extends State<GenAppPeruk15Rp1Screen> {
  int? _sel;
  Future<void> _send(BuildContext context, Map<String, String> r0, String id0) async {
    final text = reportTextGenAppPeruk15Rp1Screen(r0, id0);
    final dynamic url = waLink((r0[gen_app_peruk15_rp1_c70] ?? ''), text, waDigits);
    if (url is String && url.isNotEmpty) { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); return; }
    await Share.share(text);
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, __) {
    final rs = appStore.records('app_peruk15_ent1');
    if (rs.isEmpty) return DsScaffold(title: gen_app_peruk15_rp1_c71, subtitle: gen_app_peruk15_rp1_c72, icon: gen_app_peruk15_rp1_c74, children: [EmptyState(label: gen_app_peruk15_rp1_c3)]);
    final i0 = _sel ?? (widget.initialId != null ? rs.indexWhere((r) => r[AppStore.idKey] == widget.initialId) : 0);
    final i = (i0 < 0 ? 0 : i0).clamp(0, rs.length - 1);
    final r0 = rs[i];
    final id0 = r0[AppStore.idKey] ?? '';
    return DsScaffold(title: gen_app_peruk15_rp1_c71, subtitle: gen_app_peruk15_rp1_c72, icon: gen_app_peruk15_rp1_c75, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeMustChip(bare: true, items: [for (final s in [for (final o in appStore.options('app_peruk15_ent1')) o.value]) [s]], selected: {i}, onSelect: (v) => setState(() => _sel = v))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk15_rp1_c15, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk15_rp1_c7, label: gen_app_peruk15_rp1_c8, tone: 0), DsNote(message: gen_app_peruk15_rp1_c10, label: gen_app_peruk15_rp1_c11, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk15_rp1_c25, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk15_rp1_c20, label: gen_app_peruk15_rp1_c21, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk15_rp1_c35, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk15_rp1_c30, label: gen_app_peruk15_rp1_c31, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsFold(title: gen_app_peruk15_rp1_c73, details: [Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk15_rp1_c45, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk15_rp1_c40, label: gen_app_peruk15_rp1_c41, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk15_rp1_c55, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk15_rp1_c50, label: gen_app_peruk15_rp1_c51, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk15_rp1_c65, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk15_rp1_c60, label: gen_app_peruk15_rp1_c61, tone: 0)])], tone: 0))])),
      Padding(padding: const EdgeInsets.only(top: 4, bottom: 12), child: DsChipButton(label: gen_app_peruk15_rp1_c68, onTap: () => _send(context, r0, id0))),
    ]);
  });
}
