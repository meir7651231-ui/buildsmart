// 📄 חולל ע"י חלקיק-הדוח (particles · G24 · הכרעה-27): מבנה-קבוע-לרשומה; כל חלק מורכב מחלקיקים שנמצאו בחיפוש-פתוח. אל תערוך ידנית.
//   כרטיס = [תוכן כרטיס]
//   ציר = [תוכן ציר]
//   טבלת כסף = [תוכן טבלת כסף]
//   הודעה = [תוכן הודעה]
//   הודעה = [תוכן הודעה]
//   מה לא לעשות השבוע = [תוכן מה לא לעשות השבוע]
//   הסתייגות = [תוכן הסתייגות]
//   [תוכן כרטיס]⇒DsNote
//   [תוכן ציר]⇒DsNote
//   [תוכן טבלת כסף]⇒DsNote
//   [תוכן הודעה]⇒DsNote
//   [תוכן הודעה]⇒DsNote
//   [תוכן מה לא לעשות השבוע]⇒DsNote
//   [תוכן הסתייגות]⇒DsNote
//   שליחה בוואטסאפ⇒DsPrimaryButton+waLink

import '../dart-data-bs/auto/gen_app_peruk06_rp1_content.dart';
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
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

/// 📤 סריאליזציית-הדוח לטקסט (G25): *חלק* · שורות; נבדקת ב-test/genesis_gen_app_<ns>_report_test.dart
String reportTextGenAppPeruk06Rp1Screen(Map<String, String> r0, String id0) {
  final b = <String>[
    gen_app_peruk06_rp1_c5,
    gen_app_peruk06_rp1_c17,
    gen_app_peruk06_rp1_c21,
    gen_app_peruk06_rp1_c27,
    gen_app_peruk06_rp1_c31,
    gen_app_peruk06_rp1_c37,
    gen_app_peruk06_rp1_c41,
    gen_app_peruk06_rp1_c56,
    gen_app_peruk06_rp1_c60,
    gen_app_peruk06_rp1_c75,
    gen_app_peruk06_rp1_c79,
    gen_app_peruk06_rp1_c91,
    gen_app_peruk06_rp1_c95,
    gen_app_peruk06_rp1_c101,
  ];
  return b.where((s) => s.trim().isNotEmpty).join('\n');
}

class GenAppPeruk06Rp1Screen extends StatefulWidget {
  const GenAppPeruk06Rp1Screen({this.initialId, super.key});
  final String? initialId;   // G26 · פתיחה מעמוד-השורש: הדוח של הרשומה הזו
  @override
  State<GenAppPeruk06Rp1Screen> createState() => _GenAppPeruk06Rp1ScreenState();
}

class _GenAppPeruk06Rp1ScreenState extends State<GenAppPeruk06Rp1Screen> {
  int? _sel;
  Future<void> _send(BuildContext context, Map<String, String> r0, String id0) async {
    final text = reportTextGenAppPeruk06Rp1Screen(r0, id0);
    final dynamic url = waLink((r0[gen_app_peruk06_rp1_c107] ?? ''), text, waDigits);
    if (url is String && url.isNotEmpty) { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); return; }
    await Share.share(text);
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, __) {
    final rs = appStore.records('app_peruk06_ent1');
    if (rs.isEmpty) return DsScaffold(title: gen_app_peruk06_rp1_c108, subtitle: gen_app_peruk06_rp1_c109, icon: gen_app_peruk06_rp1_c111, children: [EmptyState(label: gen_app_peruk06_rp1_c3)]);
    final i0 = _sel ?? (widget.initialId != null ? rs.indexWhere((r) => r[AppStore.idKey] == widget.initialId) : 0);
    final i = (i0 < 0 ? 0 : i0).clamp(0, rs.length - 1);
    final r0 = rs[i];
    final id0 = r0[AppStore.idKey] ?? '';
    return DsScaffold(title: gen_app_peruk06_rp1_c108, subtitle: gen_app_peruk06_rp1_c109, icon: gen_app_peruk06_rp1_c112, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeMustChip(bare: true, items: [for (final s in [for (final o in appStore.options('app_peruk06_ent1')) o.value]) [s]], selected: {i}, onSelect: (v) => setState(() => _sel = v))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk06_rp1_c18, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk06_rp1_c7, label: gen_app_peruk06_rp1_c8, tone: 0), DsNote(message: gen_app_peruk06_rp1_c10, label: gen_app_peruk06_rp1_c11, tone: 0), DsNote(message: gen_app_peruk06_rp1_c13, label: gen_app_peruk06_rp1_c14, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk06_rp1_c28, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk06_rp1_c23, label: gen_app_peruk06_rp1_c24, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk06_rp1_c38, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk06_rp1_c33, label: gen_app_peruk06_rp1_c34, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsFold(title: gen_app_peruk06_rp1_c110, details: [Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk06_rp1_c57, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk06_rp1_c43, label: gen_app_peruk06_rp1_c44, tone: 0), DsNote(message: gen_app_peruk06_rp1_c46, label: gen_app_peruk06_rp1_c47, tone: 0), DsNote(message: gen_app_peruk06_rp1_c49, label: gen_app_peruk06_rp1_c50, tone: 0), DsNote(message: gen_app_peruk06_rp1_c52, label: gen_app_peruk06_rp1_c53, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk06_rp1_c76, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk06_rp1_c62, label: gen_app_peruk06_rp1_c63, tone: 0), DsNote(message: gen_app_peruk06_rp1_c65, label: gen_app_peruk06_rp1_c66, tone: 0), DsNote(message: gen_app_peruk06_rp1_c68, label: gen_app_peruk06_rp1_c69, tone: 0), DsNote(message: gen_app_peruk06_rp1_c71, label: gen_app_peruk06_rp1_c72, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk06_rp1_c92, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk06_rp1_c81, label: gen_app_peruk06_rp1_c82, tone: 0), DsNote(message: gen_app_peruk06_rp1_c84, label: gen_app_peruk06_rp1_c85, tone: 0), DsNote(message: gen_app_peruk06_rp1_c87, label: gen_app_peruk06_rp1_c88, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk06_rp1_c102, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk06_rp1_c97, label: gen_app_peruk06_rp1_c98, tone: 0)])], tone: 0))])),
      Padding(padding: const EdgeInsets.only(top: 4, bottom: 12), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _send(context, r0, id0), child: ForgeToneButton(items: [[gen_app_peruk06_rp1_c105]]))),
    ]);
  });
}
