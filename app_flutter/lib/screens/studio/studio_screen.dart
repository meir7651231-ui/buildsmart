// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 16 — the Studio control-center shell.
//
// Four panes via IndexedStack: 🗂️ עץ (tree, s18) · 🛠️ מפקח (inspector, s19) ·
// 🎨 עיצוב (theme, s24) · 🕘 גרסאות (history, s21). RTL + a light scaffold + white
// AppBar (cloned from manager_dashboard chrome). Reached only from the manager row
// (s20); `route()` is kStudioFlag-guarded so even a deep-link can't enter when the
// Studio is inactive ⇒ zero behavior change until then. Panes are placeholders here.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/screens/studio/panes/history_pane.dart';
import 'package:buildsmart/screens/studio/panes/inspector_pane.dart';
import 'package:buildsmart/screens/studio/panes/theme_pane.dart';
import 'package:buildsmart/screens/studio/panes/tree_pane.dart';
import 'package:buildsmart/screens/studio/studio_top_bar.dart';
import 'package:buildsmart/state/studio/edit_mode.dart' show studioCanEditProvider;
import 'package:buildsmart/theme/tokens.dart' show BsTokens;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Studio control center (shell only in s16).
class StudioScreen extends ConsumerStatefulWidget {
  const StudioScreen({super.key});

  /// Owner-gated route — returns null unless the viewer MAY edit (Studio active ∧
  /// real owner ∧ manager context, via [studioCanEditProvider]), so a stray
  /// deep-link / call can never open the Studio for a non-owner (#84 defence — the
  /// route guard no longer relies only on the flag being active).
  static Route<void>? route(WidgetRef ref) => ref.read(studioCanEditProvider)
      ? MaterialPageRoute<void>(builder: (_) => const StudioScreen())
      : null;

  @override
  ConsumerState<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends ConsumerState<StudioScreen> {
  int _pane = 0;

  static const _segments = <(String, String, String)>[
    ('🗂️', 'עץ', 'עץ הרכיבים'),
    ('🛠️', 'מפקח', 'מפקח העריכה'),
    ('🎨', 'עיצוב', 'ערכת נושא'),
    ('🕘', 'גרסאות', 'היסטוריית גרסאות'),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            '🎨 סטודיו',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: BsTokens.inkLight),
              tooltip: 'סגור',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
        body: Column(
          children: [
            const StudioTopBar(),
            Padding(
              padding: const EdgeInsets.all(BsTokens.space3),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < _segments.length; i++)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: ChoiceChip(
                          selected: _pane == i,
                          label: Text('${_segments[i].$1} ${_segments[i].$2}'),
                          onSelected: (_) => setState(() => _pane = i),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _pane,
                children: const [
                  TreePane(),
                  InspectorPane(),
                  ThemePane(),
                  HistoryPane(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
