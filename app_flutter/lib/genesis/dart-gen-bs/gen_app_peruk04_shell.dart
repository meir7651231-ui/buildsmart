// 🧭 חולל ע"י ניווט-מקשרים (app-shell · G26 · הכרעה-27) — השלד: סרגל-תחתון בית · תיק · עוד. השורש נגזר מגרף-הקשרים. אל תערוך ידנית.

import '../dart-data-bs/auto/gen_app_peruk04_shell_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-forge-bs/selection/must_chip.dart';
import '../dart-ui-bs/auto/empty_state.dart';
import '../dart-ui-bs/ds/ds.dart';
import 'gen_app_peruk04_ent1.dart';
import 'gen_app_peruk04_hub.dart';
import 'gen_app_peruk04_root.dart';
import 'gen_app_peruk04_scr3.dart';
import 'package:flutter/material.dart';
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

class GenAppPeruk04ShellScreen extends StatefulWidget {
  const GenAppPeruk04ShellScreen({super.key});
  @override
  State<GenAppPeruk04ShellScreen> createState() => _GenAppPeruk04ShellScreenState();
}

class _GenAppPeruk04ShellScreenState extends State<GenAppPeruk04ShellScreen> {
  int _t = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: DsLook.of(context).bg,
    body: IndexedStack(index: _t.clamp(0, 2), children: [const GenAppPeruk04Scr3Screen(), _RootTab(), const GenAppPeruk04HubScreen()]),
    bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(12, 6, 12, 10), child: Center(heightFactor: 1.0, child: ForgeMustChip(bare: true, items: [for (final s in [gen_app_peruk04_shell_c0, gen_app_peruk04_shell_c1, gen_app_peruk04_shell_c2]) [s]], selected: {_t}, onSelect: (i) => setState(() => _t = i))))),   // heightFactor: Center ללא-גובה מתפשט לכל הגובה שה-Scaffold מציע ⇒ הגוף נעלם
  );
}

class _RootTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) {
    final rs = appStore.records('app_peruk04_ent1');
    return DsScaffold(title: gen_app_peruk04_shell_c11, subtitle: rs.length.toString() + ' ' + gen_app_peruk04_shell_c12, icon: gen_app_peruk04_shell_c13, children: [
      Padding(padding: const EdgeInsets.only(bottom: 10), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk04Ent1Screen())), child: ForgeToneButton(items: [[gen_app_peruk04_shell_c4]]))),
      if (rs.isEmpty) EmptyState(label: gen_app_peruk04_shell_c7),
      for (final r in rs) DsNavTile(glyph: gen_app_peruk04_shell_c14, title: (r[gen_app_peruk04_shell_c9] ?? ''), sub: (r[gen_app_peruk04_shell_c10] ?? ''), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk04RootScreen(id: r[AppStore.idKey] ?? '')))),
    ]);
  });
}
