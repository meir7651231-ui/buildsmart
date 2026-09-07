// 📄 חולל ע"י חלקיק-הדוח (particles · G24 · הכרעה-27): מבנה-קבוע-לרשומה; כל חלק מורכב מחלקיקים שנמצאו בחיפוש-פתוח. אל תערוך ידנית.
//   כרטיס = [תוכן כרטיס]
//   רשימת השלמה = [תוכן רשימת השלמה]
//   נוסח פנייה ללשכה פנייה = [תוכן נוסח פנייה ללשכה פנייה]
//   האם בכלל שייך דחוף = [תוכן האם בכלל שייך דחוף]
//   מה לא = [תוכן מה לא]
//   הסתייגות = [תוכן הסתייגות]
//   [תוכן כרטיס]⇒ToastCard
//   [תוכן רשימת השלמה]⇒ToastCard
//   [תוכן נוסח פנייה ללשכה פנייה]⇒ToastCard
//   [תוכן האם בכלל שייך דחוף]⇒ToastCard
//   [תוכן מה לא]⇒ToastCard
//   [תוכן הסתייגות]⇒ToastCard
//   שליחה בוואטסאפ⇒DsPrimaryButton+waLink

import '../dart-data-bs/auto/gen_app_peruk20_rp1_content.dart';
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
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

/// 📤 סריאליזציית-הדוח לטקסט (G25): *חלק* · שורות; נבדקת ב-test/genesis_gen_app_<ns>_report_test.dart
String reportTextGenAppPeruk20Rp1Screen(Map<String, String> r0, String id0) {
  final b = <String>[
    gen_app_peruk20_rp1_c5,
    gen_app_peruk20_rp1_c11,
    gen_app_peruk20_rp1_c15,
    gen_app_peruk20_rp1_c21,
    gen_app_peruk20_rp1_c25,
    gen_app_peruk20_rp1_c31,
    gen_app_peruk20_rp1_c35,
    gen_app_peruk20_rp1_c41,
    gen_app_peruk20_rp1_c45,
    gen_app_peruk20_rp1_c51,
    gen_app_peruk20_rp1_c55,
    gen_app_peruk20_rp1_c61,
  ];
  return b.where((s) => s.trim().isNotEmpty).join('\n');
}

class GenAppPeruk20Rp1Screen extends StatefulWidget {
  const GenAppPeruk20Rp1Screen({this.initialId, super.key});
  final String? initialId;   // G26 · פתיחה מעמוד-השורש: הדוח של הרשומה הזו
  @override
  State<GenAppPeruk20Rp1Screen> createState() => _GenAppPeruk20Rp1ScreenState();
}

class _GenAppPeruk20Rp1ScreenState extends State<GenAppPeruk20Rp1Screen> {
  int? _sel;
  Future<void> _send(BuildContext context, Map<String, String> r0, String id0) async {
    final text = reportTextGenAppPeruk20Rp1Screen(r0, id0);
    final dynamic url = waLink((r0[gen_app_peruk20_rp1_c67] ?? ''), text, waDigits);
    if (url is String && url.isNotEmpty) { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); return; }
    await Share.share(text);
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, __) {
    final rs = appStore.records('app_peruk20_ent1');
    if (rs.isEmpty) return DsScaffold(title: gen_app_peruk20_rp1_c68, subtitle: gen_app_peruk20_rp1_c69, icon: gen_app_peruk20_rp1_c70, header: false, children: [ForgeCenteredPageHeader(fields: ['', gen_app_peruk20_rp1_c68, gen_app_peruk20_rp1_c69]), ...[EmptyState(label: gen_app_peruk20_rp1_c3)]]);
    final i0 = _sel ?? (widget.initialId != null ? rs.indexWhere((r) => r[AppStore.idKey] == widget.initialId) : 0);
    final i = (i0 < 0 ? 0 : i0).clamp(0, rs.length - 1);
    final r0 = rs[i];
    final id0 = r0[AppStore.idKey] ?? '';
    return DsScaffold(title: gen_app_peruk20_rp1_c68, subtitle: gen_app_peruk20_rp1_c69, icon: gen_app_peruk20_rp1_c71, header: false, children: [ForgeCenteredPageHeader(fields: ['', gen_app_peruk20_rp1_c68, gen_app_peruk20_rp1_c69]), ...[
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeSegPickerSelection(bare: true, items: [for (final s in [for (final o in appStore.options('app_peruk20_ent1')) o.value]) [s]], selected: {i}, onSelect: (v) => setState(() => _sel = v))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_peruk20_rp1_c12, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk20_rp1_c7, tone: 0)])]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_peruk20_rp1_c22, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk20_rp1_c17, tone: 0)])]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_peruk20_rp1_c32, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk20_rp1_c27, tone: 0)])]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_peruk20_rp1_c42, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk20_rp1_c37, tone: 0)])]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_peruk20_rp1_c52, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk20_rp1_c47, tone: 0)])]]))),
      Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeTitledSection(fields: [gen_app_peruk20_rp1_c62, '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ToastCard(message: gen_app_peruk20_rp1_c57, tone: 0)])]]))),
      Padding(padding: const EdgeInsets.only(top: 4, bottom: 12), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _send(context, r0, id0), child: ForgeToneButton(items: [[gen_app_peruk20_rp1_c65]]))),
    ]]);
  });
}
