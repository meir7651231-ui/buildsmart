// 📄 חולל ע"י חלקיק-הדוח (particles · G24 · הכרעה-27): מבנה-קבוע-לרשומה; כל חלק מורכב מחלקיקים שנמצאו בחיפוש-פתוח. אל תערוך ידנית.
//   כרטיס = [תוכן כרטיס]
//   דברים להוציא מהמגרה = [תוכן דברים להוציא מהמגרה]
//   שאלות לרו״ח או תפתח = [תוכן שאלות לרו״ח או תפתח]
//   טיוטה קצרה רק אם = [תוכן טיוטה קצרה רק אם]
//   מה לא לשלם עיוור = [תוכן מה לא לשלם עיוור]
//   הסתייגות = [תוכן הסתייגות]
//   [תוכן כרטיס]⇒DsNote
//   [תוכן דברים להוציא מהמגרה]⇒DsNote
//   [תוכן שאלות לרו״ח או תפתח]⇒DsNote
//   [תוכן טיוטה קצרה רק אם]⇒DsNote
//   [תוכן מה לא לשלם עיוור]⇒DsNote
//   [תוכן הסתייגות]⇒DsNote
//   שליחה בוואטסאפ⇒DsPrimaryButton+waLink

import '../dart-data-bs/auto/gen_app_peruk18_rp1_content.dart';
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
String reportTextGenAppPeruk18Rp1Screen(Map<String, String> r0, String id0) {
  final b = <String>[
    gen_app_peruk18_rp1_c5,
    gen_app_peruk18_rp1_c11,
    gen_app_peruk18_rp1_c15,
    gen_app_peruk18_rp1_c21,
    gen_app_peruk18_rp1_c25,
    gen_app_peruk18_rp1_c31,
    gen_app_peruk18_rp1_c35,
    gen_app_peruk18_rp1_c41,
    gen_app_peruk18_rp1_c45,
    gen_app_peruk18_rp1_c51,
    gen_app_peruk18_rp1_c55,
    gen_app_peruk18_rp1_c61,
  ];
  return b.where((s) => s.trim().isNotEmpty).join('\n');
}

class GenAppPeruk18Rp1Screen extends StatefulWidget {
  const GenAppPeruk18Rp1Screen({this.initialId, super.key});
  final String? initialId;   // G26 · פתיחה מעמוד-השורש: הדוח של הרשומה הזו
  @override
  State<GenAppPeruk18Rp1Screen> createState() => _GenAppPeruk18Rp1ScreenState();
}

class _GenAppPeruk18Rp1ScreenState extends State<GenAppPeruk18Rp1Screen> {
  int? _sel;
  Future<void> _send(BuildContext context, Map<String, String> r0, String id0) async {
    final text = reportTextGenAppPeruk18Rp1Screen(r0, id0);
    final dynamic url = waLink((r0[gen_app_peruk18_rp1_c67] ?? ''), text, waDigits);
    if (url is String && url.isNotEmpty) { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); return; }
    await Share.share(text);
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, __) {
    final rs = appStore.records('app_peruk18_ent1');
    if (rs.isEmpty) return DsScaffold(title: gen_app_peruk18_rp1_c68, subtitle: gen_app_peruk18_rp1_c69, icon: gen_app_peruk18_rp1_c71, children: [EmptyState(label: gen_app_peruk18_rp1_c3)]);
    final i0 = _sel ?? (widget.initialId != null ? rs.indexWhere((r) => r[AppStore.idKey] == widget.initialId) : 0);
    final i = (i0 < 0 ? 0 : i0).clamp(0, rs.length - 1);
    final r0 = rs[i];
    final id0 = r0[AppStore.idKey] ?? '';
    return DsScaffold(title: gen_app_peruk18_rp1_c68, subtitle: gen_app_peruk18_rp1_c69, icon: gen_app_peruk18_rp1_c72, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeMustChip(bare: true, items: [for (final s in [for (final o in appStore.options('app_peruk18_ent1')) o.value]) [s]], selected: {i}, onSelect: (v) => setState(() => _sel = v))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk18_rp1_c12, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk18_rp1_c7, label: gen_app_peruk18_rp1_c8, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk18_rp1_c22, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk18_rp1_c17, label: gen_app_peruk18_rp1_c18, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk18_rp1_c32, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk18_rp1_c27, label: gen_app_peruk18_rp1_c28, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsFold(title: gen_app_peruk18_rp1_c70, details: [Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk18_rp1_c42, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk18_rp1_c37, label: gen_app_peruk18_rp1_c38, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk18_rp1_c52, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk18_rp1_c47, label: gen_app_peruk18_rp1_c48, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk18_rp1_c62, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk18_rp1_c57, label: gen_app_peruk18_rp1_c58, tone: 0)])], tone: 0))])),
      Padding(padding: const EdgeInsets.only(top: 4, bottom: 12), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _send(context, r0, id0), child: ForgeToneButton(items: [[gen_app_peruk18_rp1_c65]]))),
    ]);
  });
}
