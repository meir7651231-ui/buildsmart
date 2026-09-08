// 📄 חולל ע"י חלקיק-הדוח (particles · G24 · הכרעה-27): מבנה-קבוע-לרשומה; כל חלק מורכב מחלקיקים שנמצאו בחיפוש-פתוח. אל תערוך ידנית.
//   האם עכשיו בכלל זמן = [תוכן האם עכשיו בכלל זמן]
//   מספר אחד לבקש טווח = [תוכן מספר אחד לבקש טווח]
//   משפטים לפגישה = [תוכן משפטים לפגישה]
//   אסור = [תוכן אסור]
//   מה לבקש בכתב אחרי = [תוכן מה לבקש בכתב אחרי]
//   הסתייגות = [תוכן הסתייגות]
//   [תוכן האם עכשיו בכלל זמן]⇒DsNote
//   [תוכן מספר אחד לבקש טווח]⇒DsNote
//   [תוכן משפטים לפגישה]⇒DsNote
//   [תוכן אסור]⇒DsNote
//   [תוכן מה לבקש בכתב אחרי]⇒DsNote
//   [תוכן הסתייגות]⇒DsNote
//   שליחה בוואטסאפ⇒DsChipButton+waLink

import '../dart-data-bs/auto/gen_app_peruk28_rp1_content.dart';
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
String reportTextGenAppPeruk28Rp1Screen(Map<String, String> r0, String id0) {
  final b = <String>[
    gen_app_peruk28_rp1_c5,
    gen_app_peruk28_rp1_c11,
    gen_app_peruk28_rp1_c15,
    gen_app_peruk28_rp1_c21,
    gen_app_peruk28_rp1_c25,
    gen_app_peruk28_rp1_c31,
    gen_app_peruk28_rp1_c35,
    gen_app_peruk28_rp1_c53,
    gen_app_peruk28_rp1_c57,
    gen_app_peruk28_rp1_c63,
    gen_app_peruk28_rp1_c67,
    gen_app_peruk28_rp1_c73,
  ];
  return b.where((s) => s.trim().isNotEmpty).join('\n');
}

class GenAppPeruk28Rp1Screen extends StatefulWidget {
  const GenAppPeruk28Rp1Screen({this.initialId, super.key});
  final String? initialId;   // G26 · פתיחה מעמוד-השורש: הדוח של הרשומה הזו
  @override
  State<GenAppPeruk28Rp1Screen> createState() => _GenAppPeruk28Rp1ScreenState();
}

class _GenAppPeruk28Rp1ScreenState extends State<GenAppPeruk28Rp1Screen> {
  int? _sel;
  Future<void> _send(BuildContext context, Map<String, String> r0, String id0) async {
    final text = reportTextGenAppPeruk28Rp1Screen(r0, id0);
    final dynamic url = waLink((r0[gen_app_peruk28_rp1_c79] ?? ''), text, waDigits);
    if (url is String && url.isNotEmpty) { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); return; }
    await Share.share(text);
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, __) {
    final rs = appStore.records('app_peruk28_ent1');
    if (rs.isEmpty) return DsScaffold(title: gen_app_peruk28_rp1_c80, subtitle: gen_app_peruk28_rp1_c81, icon: gen_app_peruk28_rp1_c83, children: [EmptyState(label: gen_app_peruk28_rp1_c3)]);
    final i0 = _sel ?? (widget.initialId != null ? rs.indexWhere((r) => r[AppStore.idKey] == widget.initialId) : 0);
    final i = (i0 < 0 ? 0 : i0).clamp(0, rs.length - 1);
    final r0 = rs[i];
    final id0 = r0[AppStore.idKey] ?? '';
    return DsScaffold(title: gen_app_peruk28_rp1_c80, subtitle: gen_app_peruk28_rp1_c81, icon: gen_app_peruk28_rp1_c84, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeMustChip(bare: true, items: [for (final s in [for (final o in appStore.options('app_peruk28_ent1')) o.value]) [s]], selected: {i}, onSelect: (v) => setState(() => _sel = v))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk28_rp1_c12, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk28_rp1_c7, label: gen_app_peruk28_rp1_c8, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk28_rp1_c22, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk28_rp1_c17, label: gen_app_peruk28_rp1_c18, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk28_rp1_c32, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk28_rp1_c27, label: gen_app_peruk28_rp1_c28, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsFold(title: gen_app_peruk28_rp1_c82, details: [Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk28_rp1_c54, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk28_rp1_c37, label: gen_app_peruk28_rp1_c38, tone: 0), DsNote(message: gen_app_peruk28_rp1_c40, label: gen_app_peruk28_rp1_c41, tone: 0), DsNote(message: gen_app_peruk28_rp1_c43, label: gen_app_peruk28_rp1_c44, tone: 0), DsNote(message: gen_app_peruk28_rp1_c46, label: gen_app_peruk28_rp1_c47, tone: 0), DsNote(message: gen_app_peruk28_rp1_c49, label: gen_app_peruk28_rp1_c50, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk28_rp1_c64, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk28_rp1_c59, label: gen_app_peruk28_rp1_c60, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk28_rp1_c74, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk28_rp1_c69, label: gen_app_peruk28_rp1_c70, tone: 0)])], tone: 0))])),
      Padding(padding: const EdgeInsets.only(top: 4, bottom: 12), child: DsChipButton(label: gen_app_peruk28_rp1_c77, onTap: () => _send(context, r0, id0))),
    ]);
  });
}
