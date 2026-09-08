// 🧭 חולל ע"י ניווט-מקשרים (app-shell · G30 · הכרעה-28) — «היום»: דבר-אחד לכל רשומה פתוחה — נוסח · שלח · פתח. ≤2 הקשות, אפס-הקלדה. אל תערוך ידנית.

import '../dart-data-bs/auto/gen_app_sechirut_home_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-forge-bs/selection/must_chip.dart';
import '../dart-forge-bs/selection/seg_picker_selection.dart';
import '../dart-forge-bs/selection/segmented_pill_toggle_selection.dart';
import '../dart-forge-bs/selection/star_rating.dart';
import '../dart-forge-bs/selection/unit_segment_toggle_selection.dart';
import '../dart-maor/wa-digits.dart';
import '../dart-maor/wa-link.dart';
import '../dart-ui-bs/ds/ds.dart';
import 'gen_app_sechirut_ent1.dart';
import 'gen_app_sechirut_root.dart';
import 'gen_app_sechirut_rp1.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppSechirutHomeScreen extends StatelessWidget {
  const GenAppSechirutHomeScreen({super.key});
  Future<void> _send(BuildContext context, Map<String, String> r0, String id0) async {
    final text = reportTextGenAppSechirutRp1Screen(r0, id0);
    final dynamic url = waLink((r0[gen_app_sechirut_home_c37] ?? ''), text, waDigits);
    if (url is String && url.isNotEmpty) { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); return; }
    await Share.share(text);
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) {
    final open = appStore.records('app_sechirut_ent1').where((r) => appStore.stageOf('app_sechirut_ent1', r[AppStore.idKey] ?? '') < 5).toList();
    final lead = open.isEmpty ? gen_app_sechirut_home_c48 : open.length == 1 ? gen_app_sechirut_home_c49 : gen_app_sechirut_home_c50.replaceAll('{n}', open.length.toString());
    return DsScaffold(title: gen_app_sechirut_home_c51, subtitle: lead, icon: gen_app_sechirut_home_c52, children: [
      Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(lead, style: TextStyle(color: DsLook.of(context).ink, fontSize: 28, fontWeight: FontWeight.w600, height: 1.2))),
      for (final r in open) DsSection(title: (r[gen_app_sechirut_home_c0] ?? '') + ' · ' + const [gen_app_sechirut_home_c42, gen_app_sechirut_home_c43, gen_app_sechirut_home_c44, gen_app_sechirut_home_c45, gen_app_sechirut_home_c46, gen_app_sechirut_home_c47][appStore.stageOf('app_sechirut_ent1', r[AppStore.idKey] ?? '').clamp(0, 5)], children: [
        AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r]) Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeMustChip(bare: true, items: [for (final s in [gen_app_sechirut_home_c8, gen_app_sechirut_home_c9, gen_app_sechirut_home_c10]) [s]], selected: {((r[gen_app_sechirut_home_c2] ?? '') == gen_app_sechirut_home_c3 ? 0 : (r[gen_app_sechirut_home_c4] ?? '') == gen_app_sechirut_home_c5 ? 1 : (r[gen_app_sechirut_home_c6] ?? '') == gen_app_sechirut_home_c7 ? 2 : 0)}, onSelect: (i) => appStore.update('app_sechirut_ent1', (r[AppStore.idKey] ?? ''), {gen_app_sechirut_home_c11: [gen_app_sechirut_home_c12, gen_app_sechirut_home_c13, gen_app_sechirut_home_c14][i]}))), DsNote(message: ((r[gen_app_sechirut_home_c29] ?? '') == gen_app_sechirut_home_c30 ? (gen_app_sechirut_home_c31 + appStore.referencing('app_sechirut_ent3', gen_app_sechirut_home_c32, (r[AppStore.idKey] ?? '')).map((c) => c[gen_app_sechirut_home_c33] ?? '').where((x) => x.trim().isNotEmpty).join(', ') + gen_app_sechirut_home_c34) : (((r[gen_app_sechirut_home_c21] ?? '') == gen_app_sechirut_home_c22 ? (gen_app_sechirut_home_c23 + appStore.referencing('app_sechirut_ent3', gen_app_sechirut_home_c24, (r[AppStore.idKey] ?? '')).map((c) => c[gen_app_sechirut_home_c25] ?? '').where((x) => x.trim().isNotEmpty).join(', ') + gen_app_sechirut_home_c26 + (r[gen_app_sechirut_home_c27] ?? '') + gen_app_sechirut_home_c28) : (((r[gen_app_sechirut_home_c18] ?? '') == gen_app_sechirut_home_c19 ? (gen_app_sechirut_home_c20) : (gen_app_sechirut_home_c15 + (r[gen_app_sechirut_home_c16] ?? '') + gen_app_sechirut_home_c17)))))), label: gen_app_sechirut_home_c35, tone: 0)]))])),
        Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [Expanded(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _send(context, r, r[AppStore.idKey] ?? ''), child: ForgeToneButton(items: [[gen_app_sechirut_home_c38]]))), const SizedBox(width: 8), Flexible(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppSechirutRootScreen(id: r[AppStore.idKey] ?? ''))), child: ForgeToneButton(items: [[gen_app_sechirut_home_c40]])))])),
      ]),
    ]);
  });
}
