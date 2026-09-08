// 📄 חולל ע"י חלקיק-הדוח (particles · G24 · הכרעה-27): מבנה-קבוע-לרשומה; כל חלק מורכב מחלקיקים שנמצאו בחיפוש-פתוח. אל תערוך ידנית.
//   כרטיס = [תוכן כרטיס]
//   עילת הדחייה מול הסעיף = [תוכן עילת הדחייה מול הסעיף]
//   רשימת השלמה = [תוכן רשימת השלמה]
//   מכתב מייל תשובה אחד = [תוכן מכתב מייל תשובה אחד]
//   מדרגה אם שוב לא = [תוכן מדרגה אם שוב לא]
//   האם בכלל שווה = [תוכן האם בכלל שווה]
//   הסתייגות = [תוכן הסתייגות]
//   [תוכן כרטיס]⇒DsNote
//   [תוכן עילת הדחייה מול הסעיף]⇒DsNote
//   [תוכן רשימת השלמה]⇒DsNote
//   [תוכן מכתב מייל תשובה אחד]⇒DsNote
//   [תוכן מדרגה אם שוב לא]⇒DsNote
//   [תוכן האם בכלל שווה]⇒DsNote
//   [תוכן הסתייגות]⇒DsNote
//   שליחה בוואטסאפ⇒DsChipButton+waLink

import '../dart-data-bs/auto/gen_app_peruk07_rp1_content.dart';
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
String reportTextGenAppPeruk07Rp1Screen(Map<String, String> r0, String id0) {
  final b = <String>[
    gen_app_peruk07_rp1_c5,
    gen_app_peruk07_rp1_c14,
    gen_app_peruk07_rp1_c18,
    gen_app_peruk07_rp1_c30,
    gen_app_peruk07_rp1_c34,
    gen_app_peruk07_rp1_c43,
    gen_app_peruk07_rp1_c47,
    gen_app_peruk07_rp1_c59,
    gen_app_peruk07_rp1_c63,
    gen_app_peruk07_rp1_c72,
    gen_app_peruk07_rp1_c76,
    gen_app_peruk07_rp1_c82,
    gen_app_peruk07_rp1_c86,
    gen_app_peruk07_rp1_c92,
  ];
  return b.where((s) => s.trim().isNotEmpty).join('\n');
}

class GenAppPeruk07Rp1Screen extends StatefulWidget {
  const GenAppPeruk07Rp1Screen({this.initialId, super.key});
  final String? initialId;   // G26 · פתיחה מעמוד-השורש: הדוח של הרשומה הזו
  @override
  State<GenAppPeruk07Rp1Screen> createState() => _GenAppPeruk07Rp1ScreenState();
}

class _GenAppPeruk07Rp1ScreenState extends State<GenAppPeruk07Rp1Screen> {
  int? _sel;
  Future<void> _send(BuildContext context, Map<String, String> r0, String id0) async {
    final text = reportTextGenAppPeruk07Rp1Screen(r0, id0);
    final dynamic url = waLink((r0[gen_app_peruk07_rp1_c98] ?? ''), text, waDigits);
    if (url is String && url.isNotEmpty) { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); return; }
    await Share.share(text);
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, __) {
    final rs = appStore.records('app_peruk07_ent1');
    if (rs.isEmpty) return DsScaffold(title: gen_app_peruk07_rp1_c99, subtitle: gen_app_peruk07_rp1_c100, icon: gen_app_peruk07_rp1_c102, children: [EmptyState(label: gen_app_peruk07_rp1_c3)]);
    final i0 = _sel ?? (widget.initialId != null ? rs.indexWhere((r) => r[AppStore.idKey] == widget.initialId) : 0);
    final i = (i0 < 0 ? 0 : i0).clamp(0, rs.length - 1);
    final r0 = rs[i];
    final id0 = r0[AppStore.idKey] ?? '';
    return DsScaffold(title: gen_app_peruk07_rp1_c99, subtitle: gen_app_peruk07_rp1_c100, icon: gen_app_peruk07_rp1_c103, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeMustChip(bare: true, items: [for (final s in [for (final o in appStore.options('app_peruk07_ent1')) o.value]) [s]], selected: {i}, onSelect: (v) => setState(() => _sel = v))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk07_rp1_c15, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk07_rp1_c7, label: gen_app_peruk07_rp1_c8, tone: 0), DsNote(message: gen_app_peruk07_rp1_c10, label: gen_app_peruk07_rp1_c11, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk07_rp1_c31, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk07_rp1_c20, label: gen_app_peruk07_rp1_c21, tone: 0), DsNote(message: gen_app_peruk07_rp1_c23, label: gen_app_peruk07_rp1_c24, tone: 0), DsNote(message: gen_app_peruk07_rp1_c26, label: gen_app_peruk07_rp1_c27, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk07_rp1_c44, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk07_rp1_c36, label: gen_app_peruk07_rp1_c37, tone: 0), DsNote(message: gen_app_peruk07_rp1_c39, label: gen_app_peruk07_rp1_c40, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsFold(title: gen_app_peruk07_rp1_c101, details: [Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk07_rp1_c60, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk07_rp1_c49, label: gen_app_peruk07_rp1_c50, tone: 0), DsNote(message: gen_app_peruk07_rp1_c52, label: gen_app_peruk07_rp1_c53, tone: 0), DsNote(message: gen_app_peruk07_rp1_c55, label: gen_app_peruk07_rp1_c56, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk07_rp1_c73, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk07_rp1_c65, label: gen_app_peruk07_rp1_c66, tone: 0), DsNote(message: gen_app_peruk07_rp1_c68, label: gen_app_peruk07_rp1_c69, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk07_rp1_c83, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk07_rp1_c78, label: gen_app_peruk07_rp1_c79, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk07_rp1_c93, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk07_rp1_c88, label: gen_app_peruk07_rp1_c89, tone: 0)])], tone: 0))])),
      Padding(padding: const EdgeInsets.only(top: 4, bottom: 12), child: DsChipButton(label: gen_app_peruk07_rp1_c96, onTap: () => _send(context, r0, id0))),
    ]);
  });
}
