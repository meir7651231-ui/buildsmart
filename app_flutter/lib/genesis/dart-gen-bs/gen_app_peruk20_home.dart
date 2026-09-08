// 🧭 חולל ע"י ניווט-מקשרים (app-shell · G30 · הכרעה-28) — «היום»: דבר-אחד לכל רשומה פתוחה — נוסח · שלח · פתח. ≤2 הקשות, אפס-הקלדה. אל תערוך ידנית.

import '../dart-data-bs/auto/gen_app_peruk20_home_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-maor/wa-digits.dart';
import '../dart-maor/wa-link.dart';
import '../dart-ui-bs/ds/ds.dart';
import 'gen_app_peruk20_ent1.dart';
import 'gen_app_peruk20_root.dart';
import 'gen_app_peruk20_rp1.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppPeruk20HomeScreen extends StatelessWidget {
  const GenAppPeruk20HomeScreen({super.key});
  Future<void> _send(BuildContext context, Map<String, String> r0, String id0) async {
    final text = reportTextGenAppPeruk20Rp1Screen(r0, id0);
    final dynamic url = waLink((r0[gen_app_peruk20_home_c1] ?? ''), text, waDigits);
    if (url is String && url.isNotEmpty) { await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication); return; }
    await Share.share(text);
  }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) {
    final open = appStore.records('app_peruk20_ent1').where((r) => appStore.stageOf('app_peruk20_ent1', r[AppStore.idKey] ?? '') < 4).toList();
    final lead = open.isEmpty ? gen_app_peruk20_home_c11 : open.length == 1 ? gen_app_peruk20_home_c12 : gen_app_peruk20_home_c13.replaceAll('{n}', open.length.toString());
    return DsScaffold(title: gen_app_peruk20_home_c14, subtitle: lead, icon: gen_app_peruk20_home_c15, children: [
      Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(lead, style: TextStyle(color: DsLook.of(context).ink, fontSize: 28, fontWeight: FontWeight.w600, height: 1.2))),
      for (final r in open) DsSection(title: (r[gen_app_peruk20_home_c0] ?? '') + ' · ' + const [gen_app_peruk20_home_c6, gen_app_peruk20_home_c7, gen_app_peruk20_home_c8, gen_app_peruk20_home_c9, gen_app_peruk20_home_c10][appStore.stageOf('app_peruk20_ent1', r[AppStore.idKey] ?? '').clamp(0, 4)], children: [
        
        Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [Expanded(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _send(context, r, r[AppStore.idKey] ?? ''), child: ForgeToneButton(items: [[gen_app_peruk20_home_c2]]))), const SizedBox(width: 8), Flexible(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk20RootScreen(id: r[AppStore.idKey] ?? ''))), child: ForgeToneButton(items: [[gen_app_peruk20_home_c4]])))])),
      ]),
    ]);
  });
}
