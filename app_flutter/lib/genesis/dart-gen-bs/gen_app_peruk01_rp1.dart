// 📄 חולל ע"י חלקיק-הדוח (particles · G24 · הכרעה-27): מבנה-קבוע-לרשומה; כל חלק מורכב מחלקיקים שנמצאו בחיפוש-פתוח. אל תערוך ידנית.
//   כרטיס עסקה ב־ שורות = [תוכן כרטיס עסקה ב־ שורות]
//   אדום צהוב ירוק = ממצא.צבע, [תוכן אדום צהוב ירוק]
//   חישוב בטוחות = [תוכן חישוב בטוחות]
//   בקשות לשינוי = מתווך, [תוכן בקשות לשינוי]
//   החלטה = החלטה
//   מה לא בדקנו = [תוכן מה לא בדקנו]
//   הסתייגות = [תוכן הסתייגות]
//   [תוכן כרטיס עסקה ב־ שורות]⇒ToastCard
//   ממצא.צבע⇒DsSection+ToastCard
//   [תוכן אדום צהוב ירוק]⇒ToastCard
//   [תוכן חישוב בטוחות]⇒ToastCard
//   מתווך⇒DsChip
//   [תוכן בקשות לשינוי]⇒ToastCard
//   החלטה⇒DsChip
//   [תוכן מה לא בדקנו]⇒ToastCard
//   [תוכן הסתייגות]⇒ToastCard
//   שליחה בוואטסאפ⇒DsPrimaryButton+waLink

import '../dart-data-bs/auto/gen_app_peruk01_rp1_content.dart';
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
    gen_app_peruk01_rp1_c153,
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
    final dynamic url = waLink((r0[gen_app_peruk01_rp1_c159] ?? ''), text, waDigits);
    if (url is String && url.isNotEmpty) { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); return; }
    await Share.share(text);
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, __) {
    final rs = appStore.records('app_peruk01_ent1');
    if (rs.isEmpty) return DsScaffold(title: gen_app_peruk01_rp1_c160, subtitle: gen_app_peruk01_rp1_c161, icon: gen_app_peruk01_rp1_c162, header: false, children: [ForgeCenteredPageHeader(fields: ['', gen_app_peruk01_rp1_c160, gen_app_peruk01_rp1_c161]), ...[EmptyState(label: gen_app_peruk01_rp1_c3)]]);
    final i0 = _sel ?? (widget.initialId != null ? rs.indexWhere((r) => r[AppStore.idKey] == widget.initialId) : 0);
    final i = (i0 < 0 ? 0 : i0).clamp(0, rs.length - 1);
    final r0 = rs[i];
    final id0 = r0[AppStore.idKey] ?? '';
    return DsScaffold(title: gen_app_peruk01_rp1_c160, subtitle: gen_app_peruk01_rp1_c161, icon: gen_app_peruk01_rp1_c163, header: false, children: [ForgeCenteredPageHeader(fields: ['', gen_app_peruk01_rp1_c160, gen_app_peruk01_rp1_c161]), ...[
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeSegPickerSelection(bare: true, items: [for (final s in [for (final o in appStore.options('app_peruk01_ent1')) o.value]) [s]], selected: {i}, onSelect: (v) => setState(() => _sel = v))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_peruk01_rp1_c21, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk01_rp1_c7, tone: 0), ToastCard(message: gen_app_peruk01_rp1_c10, tone: 0), ToastCard(message: gen_app_peruk01_rp1_c13, tone: 0), ToastCard(message: gen_app_peruk01_rp1_c16, tone: 0)])]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_peruk01_rp1_c67, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [DsSection(title: gen_app_peruk01_rp1_c32 + ' · ' + appStore.referencing('app_peruk01_ent2', gen_app_peruk01_rp1_c25, id0).where((r) => (r[gen_app_peruk01_rp1_c30] ?? '') == gen_app_peruk01_rp1_c31).toList().length.toString(), children: [for (final r in appStore.referencing('app_peruk01_ent2', gen_app_peruk01_rp1_c25, id0).where((r) => (r[gen_app_peruk01_rp1_c30] ?? '') == gen_app_peruk01_rp1_c31).toList()) ToastCard(message: (r[gen_app_peruk01_rp1_c27] ?? ''), tone: 0)], tone: 0), DsSection(title: gen_app_peruk01_rp1_c37 + ' · ' + appStore.referencing('app_peruk01_ent2', gen_app_peruk01_rp1_c25, id0).where((r) => (r[gen_app_peruk01_rp1_c35] ?? '') == gen_app_peruk01_rp1_c36).toList().length.toString(), children: [for (final r in appStore.referencing('app_peruk01_ent2', gen_app_peruk01_rp1_c25, id0).where((r) => (r[gen_app_peruk01_rp1_c35] ?? '') == gen_app_peruk01_rp1_c36).toList()) ToastCard(message: (r[gen_app_peruk01_rp1_c27] ?? ''), tone: 0)], tone: 0), DsSection(title: gen_app_peruk01_rp1_c42 + ' · ' + appStore.referencing('app_peruk01_ent2', gen_app_peruk01_rp1_c25, id0).where((r) => (r[gen_app_peruk01_rp1_c40] ?? '') == gen_app_peruk01_rp1_c41).toList().length.toString(), children: [for (final r in appStore.referencing('app_peruk01_ent2', gen_app_peruk01_rp1_c25, id0).where((r) => (r[gen_app_peruk01_rp1_c40] ?? '') == gen_app_peruk01_rp1_c41).toList()) ToastCard(message: (r[gen_app_peruk01_rp1_c27] ?? ''), tone: 0)], tone: 0)])), Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk01_rp1_c59, tone: 0), ToastCard(message: gen_app_peruk01_rp1_c62, tone: 0)])]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_peruk01_rp1_c83, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk01_rp1_c72, tone: 0), ToastCard(message: gen_app_peruk01_rp1_c75, tone: 0), ToastCard(message: gen_app_peruk01_rp1_c78, tone: 0)])]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_peruk01_rp1_c107, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_peruk01_rp1_c93] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_peruk01_rp1_c88 + ': ' + (r[gen_app_peruk01_rp1_c89] ?? '')]], variants: const <int>[0]))])), Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk01_rp1_c99, tone: 0), ToastCard(message: gen_app_peruk01_rp1_c102, tone: 0)])]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_peruk01_rp1_c122, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r0].where((r) => (r[gen_app_peruk01_rp1_c117] ?? '').toString().trim().isNotEmpty)) Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeStatusChip(items: [[gen_app_peruk01_rp1_c112 + ': ' + (r[gen_app_peruk01_rp1_c113] ?? '')]], variants: const <int>[0]))]))]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_peruk01_rp1_c144, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk01_rp1_c127, tone: 0), ToastCard(message: gen_app_peruk01_rp1_c130, tone: 0), ToastCard(message: gen_app_peruk01_rp1_c133, tone: 0), ToastCard(message: gen_app_peruk01_rp1_c136, tone: 0), ToastCard(message: gen_app_peruk01_rp1_c139, tone: 0)])]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_peruk01_rp1_c154, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk01_rp1_c149, tone: 0)])]]))),
      Padding(padding: const EdgeInsets.only(top: 4, bottom: 12), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _send(context, r0, id0), child: ForgeToneButton(items: [[gen_app_peruk01_rp1_c157]]))),
    ]]);
  });
}
