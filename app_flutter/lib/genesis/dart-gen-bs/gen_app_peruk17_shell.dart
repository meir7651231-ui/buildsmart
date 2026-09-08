// 🧭 חולל ע"י ניווט-מקשרים (app-shell · G26 · הכרעה-27) — השלד: סרגל-תחתון בית · תיק · עוד. השורש נגזר מגרף-הקשרים. אל תערוך ידנית.

import '../dart-data-bs/auto/gen_app_peruk17_shell_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-forge-bs/selection/must_chip.dart';
import '../dart-ui-bs/auto/empty_state.dart';
import 'gen_app_peruk17_ent1.dart';
import 'gen_app_peruk17_home.dart';
import 'gen_app_peruk17_hub.dart';
import 'gen_app_peruk17_root.dart';
import 'gen_app_peruk17_scr2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GenAppPeruk17ShellScreen extends StatefulWidget {
  const GenAppPeruk17ShellScreen({super.key});
  @override
  State<GenAppPeruk17ShellScreen> createState() => _GenAppPeruk17ShellScreenState();
}

class _GenAppPeruk17ShellScreenState extends State<GenAppPeruk17ShellScreen> {
  int _t = 0;
  @override
  Widget build(BuildContext context) => CallbackShortcuts(   // G30 · D3/D4: ≤3 מקשים — T היום · I רשימה · A הוספה · Ctrl/Cmd+K פלטה
    bindings: <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.keyT): () => setState(() => _t = 0),
      const SingleActivator(LogicalKeyboardKey.keyI): () => setState(() => _t = 1),
      const SingleActivator(LogicalKeyboardKey.keyA): () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk17Ent1Screen())),
      const SingleActivator(LogicalKeyboardKey.keyK, control: true): () => DsPalette.show(context, hint: gen_app_peruk17_shell_c15, items: [DsPaletteItem(label: gen_app_peruk17_shell_c13, sub: gen_app_peruk17_shell_c14, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk17Ent1Screen()))), for (final r in appStore.records('app_peruk17_ent1')) DsPaletteItem(label: (r[gen_app_peruk17_shell_c9] ?? ''), sub: (r[gen_app_peruk17_shell_c10] ?? ''), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk17RootScreen(id: r[AppStore.idKey] ?? ''))))]),
      const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () => DsPalette.show(context, hint: gen_app_peruk17_shell_c16, items: [DsPaletteItem(label: gen_app_peruk17_shell_c13, sub: gen_app_peruk17_shell_c14, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk17Ent1Screen()))), for (final r in appStore.records('app_peruk17_ent1')) DsPaletteItem(label: (r[gen_app_peruk17_shell_c9] ?? ''), sub: (r[gen_app_peruk17_shell_c10] ?? ''), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk17RootScreen(id: r[AppStore.idKey] ?? ''))))]),
    },
    child: Focus(autofocus: true, child: Scaffold(
    backgroundColor: DsLook.of(context).bg,
    body: IndexedStack(index: _t.clamp(0, 2), children: [const GenAppPeruk17HomeScreen(), _RootTab(), const GenAppPeruk17HubScreen()]),
    bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(12, 6, 12, 10), child: Center(heightFactor: 1.0, child: ForgeMustChip(bare: true, items: [for (final s in [gen_app_peruk17_shell_c0, gen_app_peruk17_shell_c1, gen_app_peruk17_shell_c2]) [s]], selected: {_t}, onSelect: (i) => setState(() => _t = i))))),   // heightFactor: Center ללא-גובה מתפשט לכל הגובה שה-Scaffold מציע ⇒ הגוף נעלם
  )));
}

class _RootTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) {
    final rs = appStore.records('app_peruk17_ent1');
    return DsScaffold(title: gen_app_peruk17_shell_c17, subtitle: rs.length.toString() + ' ' + gen_app_peruk17_shell_c18, icon: gen_app_peruk17_shell_c19, children: [
      Padding(padding: const EdgeInsets.only(bottom: 10), child: DsChipButton(label: gen_app_peruk17_shell_c4, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GenAppPeruk17Ent1Screen())))),
      Padding(padding: const EdgeInsets.only(bottom: 6), child: DsQuickAdd(hint: gen_app_peruk17_shell_c11, onSubmit: (s) => appStore.add('app_peruk17_ent1', {gen_app_peruk17_shell_c12: s}))),
      if (rs.isEmpty) EmptyState(label: gen_app_peruk17_shell_c7),
      for (final r in rs) DsNavTile(glyph: gen_app_peruk17_shell_c20, title: (r[gen_app_peruk17_shell_c9] ?? ''), sub: (r[gen_app_peruk17_shell_c10] ?? ''), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenAppPeruk17RootScreen(id: r[AppStore.idKey] ?? '')))),
    ]);
  });
}
