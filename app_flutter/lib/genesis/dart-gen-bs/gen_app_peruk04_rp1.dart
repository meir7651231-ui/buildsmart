// 📄 חולל ע"י חלקיק-הדוח (particles · G24 · הכרעה-27): מבנה-קבוע-לרשומה; כל חלק מורכב מחלקיקים שנמצאו בחיפוש-פתוח. אל תערוך ידנית.
//   כרטיס = [תוכן כרטיס]
//   דיף סעיפים = [תוכן דיף סעיפים]
//   מספר מיקוח אחד = [תוכן מספר מיקוח אחד]
//   הודעת תשובה אחת = הודעת תשובה אחת, [תוכן הודעת תשובה אחת]
//   לוח = [תוכן לוח]
//   הסתייגות = [תוכן הסתייגות]
//   [תוכן כרטיס]⇒ToastCard
//   [תוכן דיף סעיפים]⇒ToastCard
//   [תוכן מספר מיקוח אחד]⇒ToastCard
//   הודעת תשובה אחת⇒DsChip
//   [תוכן הודעת תשובה אחת]⇒ToastCard
//   [תוכן לוח]⇒ToastCard
//   [תוכן הסתייגות]⇒ToastCard
//   שליחה בוואטסאפ⇒DsPrimaryButton+waLink

import '../dart-data-bs/auto/gen_app_peruk04_rp1_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-maor/wa-digits.dart';
import '../dart-maor/wa-link.dart';
import '../dart-ui-bs/auto/empty_state.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/premium/actions/segmented_switch.dart';
import '../dart-ui-bs/premium/feedback/toast_card.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/header/header.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/selection/selection.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/status/status.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

/// 📤 סריאליזציית-הדוח לטקסט (G25): *חלק* · שורות; נבדקת ב-test/genesis_gen_app_<ns>_report_test.dart
String reportTextGenAppPeruk04Rp1Screen(Map<String, String> r0, String id0) {
  final b = <String>[
    gen_app_peruk04_rp1_c5,
    gen_app_peruk04_rp1_c14,
    gen_app_peruk04_rp1_c18,
    gen_app_peruk04_rp1_c30,
    gen_app_peruk04_rp1_c34,
    gen_app_peruk04_rp1_c46,
    gen_app_peruk04_rp1_c50,
    [for (final r in [r0].where((r) => (r[gen_app_peruk04_rp1_c61] ?? '').toString().trim().isNotEmpty)) gen_app_peruk04_rp1_c59 + ': ' + (r[gen_app_peruk04_rp1_c60] ?? '')].join('\n'),
    gen_app_peruk04_rp1_c67,
    gen_app_peruk04_rp1_c71,
    gen_app_peruk04_rp1_c77,
    gen_app_peruk04_rp1_c81,
    gen_app_peruk04_rp1_c87,
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
    final dynamic url = waLink((r0[gen_app_peruk04_rp1_c93] ?? ''), text, waDigits);
    if (url is String && url.isNotEmpty) { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); return; }
    await Share.share(text);
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, __) {
    final rs = appStore.records('app_peruk04_ent1');
    if (rs.isEmpty) return DsScaffold(title: gen_app_peruk04_rp1_c94, subtitle: gen_app_peruk04_rp1_c95, icon: gen_app_peruk04_rp1_c96, header: false, children: [ForgeCenteredPageHeader(fields: ['', gen_app_peruk04_rp1_c94, gen_app_peruk04_rp1_c95]), ...[EmptyState(label: gen_app_peruk04_rp1_c3)]]);
    final i0 = _sel ?? (widget.initialId != null ? rs.indexWhere((r) => r[AppStore.idKey] == widget.initialId) : 0);
    final i = (i0 < 0 ? 0 : i0).clamp(0, rs.length - 1);
    final r0 = rs[i];
    final id0 = r0[AppStore.idKey] ?? '';
    return DsScaffold(title: gen_app_peruk04_rp1_c94, subtitle: gen_app_peruk04_rp1_c95, icon: gen_app_peruk04_rp1_c97, header: false, children: [ForgeCenteredPageHeader(fields: ['', gen_app_peruk04_rp1_c94, gen_app_peruk04_rp1_c95]), ...[
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeSegPickerSelection(bare: true, items: [for (final s in [for (final o in appStore.options('app_peruk04_ent1')) o.value]) [s]], selected: {i}, onSelect: (v) => setState(() => _sel = v))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_peruk04_rp1_c15, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk04_rp1_c7, tone: 0), ToastCard(message: gen_app_peruk04_rp1_c10, tone: 0)])]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_peruk04_rp1_c31, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk04_rp1_c20, tone: 0), ToastCard(message: gen_app_peruk04_rp1_c23, tone: 0), ToastCard(message: gen_app_peruk04_rp1_c26, tone: 0)])]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_peruk04_rp1_c47, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk04_rp1_c36, tone: 0), ToastCard(message: gen_app_peruk04_rp1_c39, tone: 0), ToastCard(message: gen_app_peruk04_rp1_c42, tone: 0)])]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_peruk04_rp1_c68, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_peruk04_rp1_c57] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_peruk04_rp1_c52 + ': ' + (r[gen_app_peruk04_rp1_c53] ?? '')]], variants: const <int>[0]))])), Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk04_rp1_c63, tone: 0)])]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_peruk04_rp1_c78, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk04_rp1_c73, tone: 0)])]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_peruk04_rp1_c88, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk04_rp1_c83, tone: 0)])]]))),
      Padding(padding: const EdgeInsets.only(top: 4, bottom: 12), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _send(context, r0, id0), child: ForgeToneButton(items: [[gen_app_peruk04_rp1_c91]]))),
    ]]);
  });
}
