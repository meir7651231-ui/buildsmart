// 📄 חולל ע"י חלקיק-הדוח (particles · G24 · הכרעה-27): מבנה-קבוע-לרשומה; כל חלק מורכב מחלקיקים שנמצאו בחיפוש-פתוח. אל תערוך ידנית.
//   כרטיס עסקה ב־ שורות = [תוכן כרטיס עסקה ב־ שורות]
//   אדום צהוב ירוק = ממצא.צבע, [תוכן אדום צהוב ירוק]
//   חישוב בטוחות = [תוכן חישוב בטוחות]
//   בקשות לשינוי = מתווך, [תוכן בקשות לשינוי]
//   החלטה = החלטה
//   מה לא בדקנו = [תוכן מה לא בדקנו]
//   לוח = לוח
//   הסתייגות = [תוכן הסתייגות]
//   [תוכן כרטיס עסקה ב־ שורות]⇒DsNote
//   ממצא.צבע⇒DsSection+DsNote
//   [תוכן אדום צהוב ירוק]⇒DsNote
//   [תוכן חישוב בטוחות]⇒DsNote
//   מתווך⇒DsChip
//   [תוכן בקשות לשינוי]⇒DsNote
//   החלטה⇒DsChip
//   [תוכן מה לא בדקנו]⇒DsNote
//   לוח⇒KvLine
//   [תוכן הסתייגות]⇒DsNote
//   שליחה בוואטסאפ⇒DsPrimaryButton+waLink

import '../dart-data-bs/auto/gen_app_peruk01_rp1_content.dart';
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
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

/// 📤 סריאליזציית-הדוח לטקסט (G25): *חלק* · שורות; נבדקת ב-test/genesis_gen_app_<ns>_report_test.dart
String reportTextGenAppPeruk01Rp1Screen(Map<String, String> r0, String id0) {
  final b = <String>[
    gen_app_peruk01_rp1_c5,
    gen_app_peruk01_rp1_c20,
    gen_app_peruk01_rp1_c24,
    ['*' + gen_app_peruk01_rp1_c48 + ' · ' + appStore.referencing('app_peruk01_ent2', gen_app_peruk01_rp1_c25, id0).where((r) => (r[gen_app_peruk01_rp1_c46] ?? '') == gen_app_peruk01_rp1_c47).toList().length.toString() + '*' + [for (final r in appStore.referencing('app_peruk01_ent2', gen_app_peruk01_rp1_c25, id0).where((r) => (r[gen_app_peruk01_rp1_c46] ?? '') == gen_app_peruk01_rp1_c47).toList()) '\n- ' + (r[gen_app_peruk01_rp1_c49] ?? '')].join(), '*' + gen_app_peruk01_rp1_c52 + ' · ' + appStore.referencing('app_peruk01_ent2', gen_app_peruk01_rp1_c25, id0).where((r) => (r[gen_app_peruk01_rp1_c50] ?? '') == gen_app_peruk01_rp1_c51).toList().length.toString() + '*' + [for (final r in appStore.referencing('app_peruk01_ent2', gen_app_peruk01_rp1_c25, id0).where((r) => (r[gen_app_peruk01_rp1_c50] ?? '') == gen_app_peruk01_rp1_c51).toList()) '\n- ' + (r[gen_app_peruk01_rp1_c53] ?? '')].join(), '*' + gen_app_peruk01_rp1_c56 + ' · ' + appStore.referencing('app_peruk01_ent2', gen_app_peruk01_rp1_c25, id0).where((r) => (r[gen_app_peruk01_rp1_c54] ?? '') == gen_app_peruk01_rp1_c55).toList().length.toString() + '*' + [for (final r in appStore.referencing('app_peruk01_ent2', gen_app_peruk01_rp1_c25, id0).where((r) => (r[gen_app_peruk01_rp1_c54] ?? '') == gen_app_peruk01_rp1_c55).toList()) '\n- ' + (r[gen_app_peruk01_rp1_c57] ?? '')].join()].join('\n'),
    gen_app_peruk01_rp1_c66,
    gen_app_peruk01_rp1_c70,
    gen_app_peruk01_rp1_c82,
    gen_app_peruk01_rp1_c86,
    [for (final r in [r0].where((r) => (r[gen_app_peruk01_rp1_c97] ?? '').toString().trim().isNotEmpty)) gen_app_peruk01_rp1_c95 + ': ' + (r[gen_app_peruk01_rp1_c96] ?? '')].join('\n'),
    gen_app_peruk01_rp1_c106,
    gen_app_peruk01_rp1_c110,
    [for (final r in [r0].where((r) => (r[gen_app_peruk01_rp1_c121] ?? '').toString().trim().isNotEmpty)) gen_app_peruk01_rp1_c119 + ': ' + (r[gen_app_peruk01_rp1_c120] ?? '')].join('\n'),
    gen_app_peruk01_rp1_c125,
    gen_app_peruk01_rp1_c143,
    gen_app_peruk01_rp1_c147,
    [for (final r in [r0]) ...[if ((r[gen_app_peruk01_rp1_c153] ?? '').trim().isNotEmpty) gen_app_peruk01_rp1_c154 + ': ' + (r[gen_app_peruk01_rp1_c155] ?? '')]].join('\n'),
    gen_app_peruk01_rp1_c159,
    gen_app_peruk01_rp1_c165,
  ];
  return b.where((s) => s.trim().isNotEmpty).join('\n');
}

class GenAppPeruk01Rp1Screen extends StatefulWidget {
  const GenAppPeruk01Rp1Screen({this.initialId, super.key});
  final String? initialId;   // G26 · פתיחה מעמוד-השורש: הדוח של הרשומה הזו
  @override
  State<GenAppPeruk01Rp1Screen> createState() => _GenAppPeruk01Rp1ScreenState();
}

class _GenAppPeruk01Rp1ScreenState extends State<GenAppPeruk01Rp1Screen> {
  int? _sel;
  Future<void> _send(BuildContext context, Map<String, String> r0, String id0) async {
    final text = reportTextGenAppPeruk01Rp1Screen(r0, id0);
    final dynamic url = waLink((r0[gen_app_peruk01_rp1_c171] ?? ''), text, waDigits);
    if (url is String && url.isNotEmpty) { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); return; }
    await Share.share(text);
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, __) {
    final rs = appStore.records('app_peruk01_ent1');
    if (rs.isEmpty) return DsScaffold(title: gen_app_peruk01_rp1_c172, subtitle: gen_app_peruk01_rp1_c173, icon: gen_app_peruk01_rp1_c175, children: [EmptyState(label: gen_app_peruk01_rp1_c3)]);
    final i0 = _sel ?? (widget.initialId != null ? rs.indexWhere((r) => r[AppStore.idKey] == widget.initialId) : 0);
    final i = (i0 < 0 ? 0 : i0).clamp(0, rs.length - 1);
    final r0 = rs[i];
    final id0 = r0[AppStore.idKey] ?? '';
    return DsScaffold(title: gen_app_peruk01_rp1_c172, subtitle: gen_app_peruk01_rp1_c173, icon: gen_app_peruk01_rp1_c176, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeMustChip(bare: true, items: [for (final s in [for (final o in appStore.options('app_peruk01_ent1')) o.value]) [s]], selected: {i}, onSelect: (v) => setState(() => _sel = v))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk01_rp1_c21, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk01_rp1_c7, label: gen_app_peruk01_rp1_c8, tone: 0), DsNote(message: gen_app_peruk01_rp1_c10, label: gen_app_peruk01_rp1_c11, tone: 0), DsNote(message: gen_app_peruk01_rp1_c13, label: gen_app_peruk01_rp1_c14, tone: 0), DsNote(message: gen_app_peruk01_rp1_c16, label: gen_app_peruk01_rp1_c17, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk01_rp1_c67, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsSection(title: gen_app_peruk01_rp1_c32 + ' · ' + appStore.referencing('app_peruk01_ent2', gen_app_peruk01_rp1_c25, id0).where((r) => (r[gen_app_peruk01_rp1_c30] ?? '') == gen_app_peruk01_rp1_c31).toList().length.toString(), children: [for (final r in appStore.referencing('app_peruk01_ent2', gen_app_peruk01_rp1_c25, id0).where((r) => (r[gen_app_peruk01_rp1_c30] ?? '') == gen_app_peruk01_rp1_c31).toList()) DsNote(message: (r[gen_app_peruk01_rp1_c27] ?? ''), label: (r[gen_app_peruk01_rp1_c28] ?? ''), tone: 0)], tone: 0), DsSection(title: gen_app_peruk01_rp1_c37 + ' · ' + appStore.referencing('app_peruk01_ent2', gen_app_peruk01_rp1_c25, id0).where((r) => (r[gen_app_peruk01_rp1_c35] ?? '') == gen_app_peruk01_rp1_c36).toList().length.toString(), children: [for (final r in appStore.referencing('app_peruk01_ent2', gen_app_peruk01_rp1_c25, id0).where((r) => (r[gen_app_peruk01_rp1_c35] ?? '') == gen_app_peruk01_rp1_c36).toList()) DsNote(message: (r[gen_app_peruk01_rp1_c27] ?? ''), label: (r[gen_app_peruk01_rp1_c28] ?? ''), tone: 0)], tone: 0), DsSection(title: gen_app_peruk01_rp1_c42 + ' · ' + appStore.referencing('app_peruk01_ent2', gen_app_peruk01_rp1_c25, id0).where((r) => (r[gen_app_peruk01_rp1_c40] ?? '') == gen_app_peruk01_rp1_c41).toList().length.toString(), children: [for (final r in appStore.referencing('app_peruk01_ent2', gen_app_peruk01_rp1_c25, id0).where((r) => (r[gen_app_peruk01_rp1_c40] ?? '') == gen_app_peruk01_rp1_c41).toList()) DsNote(message: (r[gen_app_peruk01_rp1_c27] ?? ''), label: (r[gen_app_peruk01_rp1_c28] ?? ''), tone: 0)], tone: 0)])), Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk01_rp1_c59, label: gen_app_peruk01_rp1_c60, tone: 0), DsNote(message: gen_app_peruk01_rp1_c62, label: gen_app_peruk01_rp1_c63, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk01_rp1_c83, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk01_rp1_c72, label: gen_app_peruk01_rp1_c73, tone: 0), DsNote(message: gen_app_peruk01_rp1_c75, label: gen_app_peruk01_rp1_c76, tone: 0), DsNote(message: gen_app_peruk01_rp1_c78, label: gen_app_peruk01_rp1_c79, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsFold(title: gen_app_peruk01_rp1_c174, details: [Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk01_rp1_c107, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_peruk01_rp1_c93] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_peruk01_rp1_c88 + ': ' + (r[gen_app_peruk01_rp1_c89] ?? '')]], variants: const <int>[0]))])), Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk01_rp1_c99, label: gen_app_peruk01_rp1_c100, tone: 0), DsNote(message: gen_app_peruk01_rp1_c102, label: gen_app_peruk01_rp1_c103, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk01_rp1_c122, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_peruk01_rp1_c117] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_peruk01_rp1_c112 + ': ' + (r[gen_app_peruk01_rp1_c113] ?? '')]], variants: const <int>[0]))]))], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk01_rp1_c144, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk01_rp1_c127, label: gen_app_peruk01_rp1_c128, tone: 0), DsNote(message: gen_app_peruk01_rp1_c130, label: gen_app_peruk01_rp1_c131, tone: 0), DsNote(message: gen_app_peruk01_rp1_c133, label: gen_app_peruk01_rp1_c134, tone: 0), DsNote(message: gen_app_peruk01_rp1_c136, label: gen_app_peruk01_rp1_c137, tone: 0), DsNote(message: gen_app_peruk01_rp1_c139, label: gen_app_peruk01_rp1_c140, tone: 0)])], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk01_rp1_c156, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0]) Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final e in (<List<String>>[[gen_app_peruk01_rp1_c150, (r[gen_app_peruk01_rp1_c151] ?? '')]].where((e) => e[1].trim().isNotEmpty).toList()..sort((a, b) => a[1].compareTo(b[1])))) KvLine(label: e[0], value: e[1])]))]))], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk01_rp1_c166, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk01_rp1_c161, label: gen_app_peruk01_rp1_c162, tone: 0)])], tone: 0))])),
      Padding(padding: const EdgeInsets.only(top: 4, bottom: 12), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _send(context, r0, id0), child: ForgeToneButton(items: [[gen_app_peruk01_rp1_c169]]))),
    ]);
  });
}
