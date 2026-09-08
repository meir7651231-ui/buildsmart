// 📄 חולל ע"י חלקיק-הדוח (particles · G24 · הכרעה-27): מבנה-קבוע-לרשומה; כל חלק מורכב מחלקיקים שנמצאו בחיפוש-פתוח. אל תערוך ידנית.
//   כרטיס = [תוכן כרטיס]
//   דיף סעיפים = דיף סעיפים
//   מספר מיקוח אחד = [תוכן מספר מיקוח אחד]
//   הודעת תשובה אחת = הודעת תשובה אחת
//   לוח = לוח
//   הסתייגות = [תוכן הסתייגות]
//   [תוכן כרטיס]⇒DsNote
//   דיף סעיפים⇒DsDiffRow+KvLine
//   [תוכן מספר מיקוח אחד]⇒DsNote
//   הודעת תשובה אחת⇒ForgeMustChip+DsNote
//   לוח⇒KvLine
//   [תוכן הסתייגות]⇒DsNote
//   שליחה בוואטסאפ⇒DsChipButton+waLink

import '../dart-data-bs/auto/gen_app_peruk04_rp1_content.dart';
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
String reportTextGenAppPeruk04Rp1Screen(Map<String, String> r0, String id0) {
  final b = <String>[
    gen_app_peruk04_rp1_c5,
    gen_app_peruk04_rp1_c17,
    gen_app_peruk04_rp1_c21,
    [for (final r in [r0]) ...[if (((num.tryParse(r[gen_app_peruk04_rp1_c40] ?? '') ?? 0) - (num.tryParse(r[gen_app_peruk04_rp1_c39] ?? '') ?? 0)) != 0) gen_app_peruk04_rp1_c43 + ': ' + (num.tryParse(r[gen_app_peruk04_rp1_c40] ?? '') ?? 0).toStringAsFixed(0) + ' ' + gen_app_peruk04_rp1_c44 + (num.tryParse(r[gen_app_peruk04_rp1_c39] ?? '') ?? 0).toStringAsFixed(0) + ')' + ' (' + (((num.tryParse(r[gen_app_peruk04_rp1_c40] ?? '') ?? 0) - (num.tryParse(r[gen_app_peruk04_rp1_c39] ?? '') ?? 0)) >= 0 ? '+' : '') + ((num.tryParse(r[gen_app_peruk04_rp1_c40] ?? '') ?? 0) - (num.tryParse(r[gen_app_peruk04_rp1_c39] ?? '') ?? 0)).toStringAsFixed(0) + ' · ' + ((num.tryParse(r[gen_app_peruk04_rp1_c39] ?? '') ?? 0) == 0 ? 0.0 : ((num.tryParse(r[gen_app_peruk04_rp1_c40] ?? '') ?? 0) - (num.tryParse(r[gen_app_peruk04_rp1_c39] ?? '') ?? 0)) / (num.tryParse(r[gen_app_peruk04_rp1_c39] ?? '') ?? 0) * 100).toStringAsFixed(0) + '%)' + ' · ' + gen_app_peruk04_rp1_c45 + ' ' + (((num.tryParse(r[gen_app_peruk04_rp1_c40] ?? '') ?? 0) - (num.tryParse(r[gen_app_peruk04_rp1_c39] ?? '') ?? 0)) * 12).toStringAsFixed(0), if (((num.tryParse(r[gen_app_peruk04_rp1_c42] ?? '') ?? 0) - (num.tryParse(r[gen_app_peruk04_rp1_c41] ?? '') ?? 0)) != 0) gen_app_peruk04_rp1_c46 + ': ' + (num.tryParse(r[gen_app_peruk04_rp1_c42] ?? '') ?? 0).toStringAsFixed(0) + ' ' + gen_app_peruk04_rp1_c47 + (num.tryParse(r[gen_app_peruk04_rp1_c41] ?? '') ?? 0).toStringAsFixed(0) + ')' + ' (' + (((num.tryParse(r[gen_app_peruk04_rp1_c42] ?? '') ?? 0) - (num.tryParse(r[gen_app_peruk04_rp1_c41] ?? '') ?? 0)) >= 0 ? '+' : '') + ((num.tryParse(r[gen_app_peruk04_rp1_c42] ?? '') ?? 0) - (num.tryParse(r[gen_app_peruk04_rp1_c41] ?? '') ?? 0)).toStringAsFixed(0) + ' · ' + ((num.tryParse(r[gen_app_peruk04_rp1_c41] ?? '') ?? 0) == 0 ? 0.0 : ((num.tryParse(r[gen_app_peruk04_rp1_c42] ?? '') ?? 0) - (num.tryParse(r[gen_app_peruk04_rp1_c41] ?? '') ?? 0)) / (num.tryParse(r[gen_app_peruk04_rp1_c41] ?? '') ?? 0) * 100).toStringAsFixed(0) + '%)', gen_app_peruk04_rp1_c48 + ': ' + ((((num.tryParse(r[gen_app_peruk04_rp1_c40] ?? '') ?? 0) - (num.tryParse(r[gen_app_peruk04_rp1_c39] ?? '') ?? 0)) * 12)).toStringAsFixed(0)]].join('\n'),
    gen_app_peruk04_rp1_c52,
    gen_app_peruk04_rp1_c61,
    gen_app_peruk04_rp1_c65,
    [for (final r in [r0]) [gen_app_peruk04_rp1_c91, ([(r[gen_app_peruk04_rp1_c93] ?? '')].any((x) => x.trim().isEmpty) ? '' : (gen_app_peruk04_rp1_c92 + (r[gen_app_peruk04_rp1_c93] ?? '') + gen_app_peruk04_rp1_c94)), ([appStore.referencing('app_peruk04_ent2', gen_app_peruk04_rp1_c96, (r[AppStore.idKey] ?? '')).map((c) => (c[gen_app_peruk04_rp1_c97] ?? '')).where((x) => x.trim().isNotEmpty).join(', ')].any((x) => x.trim().isEmpty) ? '' : (gen_app_peruk04_rp1_c95 + appStore.referencing('app_peruk04_ent2', gen_app_peruk04_rp1_c96, (r[AppStore.idKey] ?? '')).map((c) => (c[gen_app_peruk04_rp1_c97] ?? '')).where((x) => x.trim().isNotEmpty).join(', ') + gen_app_peruk04_rp1_c98))].where((x) => x.trim().isNotEmpty).join(' ')].join('\n'),
    gen_app_peruk04_rp1_c102,
    [for (final r in [r0]) ...[if ((r[gen_app_peruk04_rp1_c110] ?? '').trim().isNotEmpty) gen_app_peruk04_rp1_c111 + ': ' + (r[gen_app_peruk04_rp1_c112] ?? ''), if ((r[gen_app_peruk04_rp1_c113] ?? '').trim().isNotEmpty) gen_app_peruk04_rp1_c114 + ': ' + (r[gen_app_peruk04_rp1_c115] ?? '')]].join('\n'),
    gen_app_peruk04_rp1_c119,
    gen_app_peruk04_rp1_c125,
  ];
  return b.where((s) => s.trim().isNotEmpty).join('\n');
}

class GenAppPeruk04Rp1Screen extends StatefulWidget {
  const GenAppPeruk04Rp1Screen({this.initialId, super.key});
  final String? initialId;   // G26 · פתיחה מעמוד-השורש: הדוח של הרשומה הזו
  @override
  State<GenAppPeruk04Rp1Screen> createState() => _GenAppPeruk04Rp1ScreenState();
}

class _GenAppPeruk04Rp1ScreenState extends State<GenAppPeruk04Rp1Screen> {
  int? _sel;
  Future<void> _send(BuildContext context, Map<String, String> r0, String id0) async {
    final text = reportTextGenAppPeruk04Rp1Screen(r0, id0);
    final dynamic url = waLink((r0[gen_app_peruk04_rp1_c131] ?? ''), text, waDigits);
    if (url is String && url.isNotEmpty) { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); return; }
    await Share.share(text);
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, __) {
    final rs = appStore.records('app_peruk04_ent1');
    if (rs.isEmpty) return DsScaffold(title: gen_app_peruk04_rp1_c132, subtitle: gen_app_peruk04_rp1_c133, icon: gen_app_peruk04_rp1_c135, children: [EmptyState(label: gen_app_peruk04_rp1_c3)]);
    final i0 = _sel ?? (widget.initialId != null ? rs.indexWhere((r) => r[AppStore.idKey] == widget.initialId) : 0);
    final i = (i0 < 0 ? 0 : i0).clamp(0, rs.length - 1);
    final r0 = rs[i];
    final id0 = r0[AppStore.idKey] ?? '';
    return DsScaffold(title: gen_app_peruk04_rp1_c132, subtitle: gen_app_peruk04_rp1_c133, icon: gen_app_peruk04_rp1_c136, children: [
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeMustChip(bare: true, items: [for (final s in [for (final o in appStore.options('app_peruk04_ent1')) o.value]) [s]], selected: {i}, onSelect: (v) => setState(() => _sel = v))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk04_rp1_c18, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk04_rp1_c7, label: gen_app_peruk04_rp1_c8, tone: 0), DsNote(message: gen_app_peruk04_rp1_c10, label: gen_app_peruk04_rp1_c11, tone: 0), DsNote(message: gen_app_peruk04_rp1_c13, label: gen_app_peruk04_rp1_c14, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk04_rp1_c49, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0]) ...[if (((num.tryParse(r[gen_app_peruk04_rp1_c24] ?? '') ?? 0) - (num.tryParse(r[gen_app_peruk04_rp1_c23] ?? '') ?? 0)) != 0) DsDiffRow(label: gen_app_peruk04_rp1_c30, value: (num.tryParse(r[gen_app_peruk04_rp1_c24] ?? '') ?? 0).toStringAsFixed(0) + ' ' + gen_app_peruk04_rp1_c31 + (num.tryParse(r[gen_app_peruk04_rp1_c23] ?? '') ?? 0).toStringAsFixed(0) + ')', delta: (((num.tryParse(r[gen_app_peruk04_rp1_c24] ?? '') ?? 0) - (num.tryParse(r[gen_app_peruk04_rp1_c23] ?? '') ?? 0)) >= 0 ? '+' : '') + ((num.tryParse(r[gen_app_peruk04_rp1_c24] ?? '') ?? 0) - (num.tryParse(r[gen_app_peruk04_rp1_c23] ?? '') ?? 0)).toStringAsFixed(0) + ' · ' + (((num.tryParse(r[gen_app_peruk04_rp1_c23] ?? '') ?? 0) == 0 ? 0.0 : ((num.tryParse(r[gen_app_peruk04_rp1_c24] ?? '') ?? 0) - (num.tryParse(r[gen_app_peruk04_rp1_c23] ?? '') ?? 0)) / (num.tryParse(r[gen_app_peruk04_rp1_c23] ?? '') ?? 0) * 100) >= 0 ? '+' : '') + ((num.tryParse(r[gen_app_peruk04_rp1_c23] ?? '') ?? 0) == 0 ? 0.0 : ((num.tryParse(r[gen_app_peruk04_rp1_c24] ?? '') ?? 0) - (num.tryParse(r[gen_app_peruk04_rp1_c23] ?? '') ?? 0)) / (num.tryParse(r[gen_app_peruk04_rp1_c23] ?? '') ?? 0) * 100).toStringAsFixed(0) + '%', sub: gen_app_peruk04_rp1_c32 + ': ' + (((num.tryParse(r[gen_app_peruk04_rp1_c24] ?? '') ?? 0) - (num.tryParse(r[gen_app_peruk04_rp1_c23] ?? '') ?? 0)) * 12).toStringAsFixed(0), tone: 0), if (((num.tryParse(r[gen_app_peruk04_rp1_c26] ?? '') ?? 0) - (num.tryParse(r[gen_app_peruk04_rp1_c25] ?? '') ?? 0)) != 0) DsDiffRow(label: gen_app_peruk04_rp1_c33, value: (num.tryParse(r[gen_app_peruk04_rp1_c26] ?? '') ?? 0).toStringAsFixed(0) + ' ' + gen_app_peruk04_rp1_c34 + (num.tryParse(r[gen_app_peruk04_rp1_c25] ?? '') ?? 0).toStringAsFixed(0) + ')', delta: (((num.tryParse(r[gen_app_peruk04_rp1_c26] ?? '') ?? 0) - (num.tryParse(r[gen_app_peruk04_rp1_c25] ?? '') ?? 0)) >= 0 ? '+' : '') + ((num.tryParse(r[gen_app_peruk04_rp1_c26] ?? '') ?? 0) - (num.tryParse(r[gen_app_peruk04_rp1_c25] ?? '') ?? 0)).toStringAsFixed(0) + ' · ' + (((num.tryParse(r[gen_app_peruk04_rp1_c25] ?? '') ?? 0) == 0 ? 0.0 : ((num.tryParse(r[gen_app_peruk04_rp1_c26] ?? '') ?? 0) - (num.tryParse(r[gen_app_peruk04_rp1_c25] ?? '') ?? 0)) / (num.tryParse(r[gen_app_peruk04_rp1_c25] ?? '') ?? 0) * 100) >= 0 ? '+' : '') + ((num.tryParse(r[gen_app_peruk04_rp1_c25] ?? '') ?? 0) == 0 ? 0.0 : ((num.tryParse(r[gen_app_peruk04_rp1_c26] ?? '') ?? 0) - (num.tryParse(r[gen_app_peruk04_rp1_c25] ?? '') ?? 0)) / (num.tryParse(r[gen_app_peruk04_rp1_c25] ?? '') ?? 0) * 100).toStringAsFixed(0) + '%', sub: gen_app_peruk04_rp1_c35, tone: 0), KvLine(label: gen_app_peruk04_rp1_c36, value: ((((num.tryParse(r[gen_app_peruk04_rp1_c24] ?? '') ?? 0) - (num.tryParse(r[gen_app_peruk04_rp1_c23] ?? '') ?? 0)) * 12)).toStringAsFixed(0))]]))], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk04_rp1_c62, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk04_rp1_c54, label: gen_app_peruk04_rp1_c55, tone: 0), DsNote(message: gen_app_peruk04_rp1_c57, label: gen_app_peruk04_rp1_c58, tone: 0)])], tone: 0)),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: DsFold(title: gen_app_peruk04_rp1_c134, details: [Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk04_rp1_c99, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0]) Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeMustChip(bare: true, items: [for (final s in [gen_app_peruk04_rp1_c73, gen_app_peruk04_rp1_c74, gen_app_peruk04_rp1_c75]) [s]], selected: {((r[gen_app_peruk04_rp1_c67] ?? '') == gen_app_peruk04_rp1_c68 ? 0 : (r[gen_app_peruk04_rp1_c69] ?? '') == gen_app_peruk04_rp1_c70 ? 1 : (r[gen_app_peruk04_rp1_c71] ?? '') == gen_app_peruk04_rp1_c72 ? 2 : 0)}, onSelect: (i) => appStore.update('app_peruk04_ent1', (r[AppStore.idKey] ?? ''), {gen_app_peruk04_rp1_c76: [gen_app_peruk04_rp1_c77, gen_app_peruk04_rp1_c78, gen_app_peruk04_rp1_c79][i]}))), DsNote(message: [gen_app_peruk04_rp1_c80, ([(r[gen_app_peruk04_rp1_c82] ?? '')].any((x) => x.trim().isEmpty) ? '' : (gen_app_peruk04_rp1_c81 + (r[gen_app_peruk04_rp1_c82] ?? '') + gen_app_peruk04_rp1_c83)), ([appStore.referencing('app_peruk04_ent2', gen_app_peruk04_rp1_c85, (r[AppStore.idKey] ?? '')).map((c) => (c[gen_app_peruk04_rp1_c86] ?? '')).where((x) => x.trim().isNotEmpty).join(', ')].any((x) => x.trim().isEmpty) ? '' : (gen_app_peruk04_rp1_c84 + appStore.referencing('app_peruk04_ent2', gen_app_peruk04_rp1_c85, (r[AppStore.idKey] ?? '')).map((c) => (c[gen_app_peruk04_rp1_c86] ?? '')).where((x) => x.trim().isNotEmpty).join(', ') + gen_app_peruk04_rp1_c87))].where((x) => x.trim().isNotEmpty).join(' '), label: gen_app_peruk04_rp1_c88, tone: 0)]))]))], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk04_rp1_c116, children: [AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0]) Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final e in (<List<String>>[[gen_app_peruk04_rp1_c105, (r[gen_app_peruk04_rp1_c106] ?? '')], [gen_app_peruk04_rp1_c107, (r[gen_app_peruk04_rp1_c108] ?? '')]].where((e) => e[1].trim().isNotEmpty).toList()..sort((a, b) => a[1].compareTo(b[1])))) KvLine(label: e[0], value: e[1])]))]))], tone: 0)), Padding(padding: const EdgeInsets.only(bottom: 12), child: DsSection(title: gen_app_peruk04_rp1_c126, children: [Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsNote(message: gen_app_peruk04_rp1_c121, label: gen_app_peruk04_rp1_c122, tone: 0)])], tone: 0))])),
      Padding(padding: const EdgeInsets.only(top: 4, bottom: 12), child: DsChipButton(label: gen_app_peruk04_rp1_c129, onTap: () => _send(context, r0, id0))),
    ]);
  });
}
