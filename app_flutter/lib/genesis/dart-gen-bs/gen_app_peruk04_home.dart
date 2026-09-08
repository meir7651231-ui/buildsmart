// 🧭 חולל ע"י ניווט-מקשרים (app-shell · G30 · הכרעה-28) — «היום»: דבר-אחד לכל רשומה פתוחה — נוסח · שלח · פתח. ≤2 הקשות, אפס-הקלדה. אל תערוך ידנית.

import '../dart-data-bs/auto/gen_app_peruk04_home_content.dart';
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
import 'gen_app_peruk04_ent1.dart';
import 'gen_app_peruk04_root.dart';
import 'gen_app_peruk04_rp1.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppPeruk04HomeScreen extends StatelessWidget {
  const GenAppPeruk04HomeScreen({super.key});
  Future<void> _send(BuildContext context, Map<String, String> r0, String id0) async {
    final text = reportTextGenAppPeruk04Rp1Screen(r0, id0);
    final dynamic url = waLink((r0[gen_app_peruk04_home_c23] ?? ''), text, waDigits);
    if (url is String && url.isNotEmpty) { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); return; }
    await Share.share(text);
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) {
    final open = appStore.records('app_peruk04_ent1').where((r) => appStore.stageOf('app_peruk04_ent1', r[AppStore.idKey] ?? '') < 4).toList();
    final lead = open.isEmpty ? gen_app_peruk04_home_c33 : open.length == 1 ? gen_app_peruk04_home_c34 : gen_app_peruk04_home_c35.replaceAll('{n}', open.length.toString());
    return DsScaffold(title: gen_app_peruk04_home_c36, subtitle: lead, icon: gen_app_peruk04_home_c37, children: [
      Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(lead, style: TextStyle(color: DsLook.of(context).ink, fontSize: 28, fontWeight: FontWeight.w600, height: 1.2))),
      for (final r in open) DsSection(title: (r[gen_app_peruk04_home_c0] ?? '') + ' · ' + const [gen_app_peruk04_home_c28, gen_app_peruk04_home_c29, gen_app_peruk04_home_c30, gen_app_peruk04_home_c31, gen_app_peruk04_home_c32][appStore.stageOf('app_peruk04_ent1', r[AppStore.idKey] ?? '').clamp(0, 4)], children: [
        AnimatedBuilder(animation: appStore, builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final r in [r]) Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Padding(padding: const EdgeInsets.only(bottom: 8), child: ForgeMustChip(bare: true, items: [for (final s in [gen_app_peruk04_home_c8, gen_app_peruk04_home_c9, gen_app_peruk04_home_c10]) [s]], selected: {((r[gen_app_peruk04_home_c2] ?? '') == gen_app_peruk04_home_c3 ? 0 : (r[gen_app_peruk04_home_c4] ?? '') == gen_app_peruk04_home_c5 ? 1 : (r[gen_app_peruk04_home_c6] ?? '') == gen_app_peruk04_home_c7 ? 2 : 0)}, onSelect: (i) => appStore.update('app_peruk04_ent1', (r[AppStore.idKey] ?? ''), {gen_app_peruk04_home_c11: [gen_app_peruk04_home_c12, gen_app_peruk04_home_c13, gen_app_peruk04_home_c14][i]}))), DsNote(message: gen_app_peruk04_home_c15 + (r[gen_app_peruk04_home_c16] ?? '') + gen_app_peruk04_home_c17 + appStore.referencing('app_peruk04_ent2', gen_app_peruk04_home_c18, (r[AppStore.idKey] ?? '')).map((c) => c[gen_app_peruk04_home_c19] ?? '').where((x) => x.trim().isNotEmpty).join(', ') + gen_app_peruk04_home_c20, label: gen_app_peruk04_home_c21, tone: 0)]))])),
        Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [Expanded(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _send(context, r, r[AppStore.idKey] ?? ''), child: ForgeToneButton(items: [[gen_app_peruk04_home_c24]]))), const SizedBox(width: 8), Flexible(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk04RootScreen(id: r[AppStore.idKey] ?? ''))), child: ForgeToneButton(items: [[gen_app_peruk04_home_c26]])))])),
      ]),
    ]);
  });
}
