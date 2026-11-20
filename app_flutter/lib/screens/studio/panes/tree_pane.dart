// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 18 — Pane A: the element tree.
//
// A registry-driven screen → area → element tree, VIRTUALISED as a flattened
// `ListView.builder` (NOT nested ExpansionTiles), so it scales to many thousands of
// ids. A search box filters by labelHe/id; the persona dropdown sets the edit
// scope; tapping a leaf selects it for the inspector (s19). Read-only.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/studio/element_registry.dart'
    show ElementDescriptor, elementRegistryProvider;
import 'package:buildsmart/state/studio/studio_nav.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart' show BsTokens;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TreePane extends ConsumerStatefulWidget {
  const TreePane({super.key});

  @override
  ConsumerState<TreePane> createState() => _TreePaneState();
}

class _TreePaneState extends ConsumerState<TreePane> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(elementRegistryProvider);
    final scope = ref.watch(studioScopePersonaProvider);
    final selected = ref.watch(studioSelectedIdProvider);
    final rows = _flatten(all, _search.text.trim());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(BsTokens.space3),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    isDense: true,
                    prefixIcon: Icon(Icons.search),
                    hintText: 'חיפוש רכיב…',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: scope,
                items: [
                  for (final k in kStudioPersonas)
                    DropdownMenuItem(value: k, child: Text(kStudioPersonaHe[k]!)),
                ],
                onChanged: (v) => ref
                    .read(studioScopePersonaProvider.notifier)
                    .state = v ?? 'contractor',
              ),
            ],
          ),
        ),
        Expanded(
          child: rows.isEmpty
              ? Center(
                  child: Text(
                    'אין רכיבים',
                    style: TextStyle(color: bsMuted(context)),
                  ),
                )
              : ListView.builder(
                  itemCount: rows.length,
                  itemBuilder: (_, i) => _rowWidget(context, ref, rows[i], selected),
                ),
        ),
      ],
    );
  }
}

Widget _rowWidget(
    BuildContext context, WidgetRef ref, _Row row, String? selected) {
  switch (row) {
    case _ScreenRow(:final screen):
      return Container(
        // Light: the original surfaceMid band (byte-identical). Dark: the M3
        // container tone, so the band + its theme ink stay legible.
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : BsTokens.surfaceMid,
        padding: const EdgeInsets.symmetric(
          horizontal: BsTokens.space3,
          vertical: 6,
        ),
        child: Text(
          '🗂️ $screen',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: bsInk(context),
          ),
        ),
      );
    case _AreaRow(:final area):
      return Padding(
        padding: const EdgeInsetsDirectional.only(
          start: BsTokens.space4,
          top: 6,
          bottom: 2,
        ),
        child: Text(
          area,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: bsMuted(context),
            fontSize: BsTokens.typeCaption,
          ),
        ),
      );
    case _ElemRow(:final d):
      return ListTile(
        dense: true,
        selected: d.id == selected,
        selectedTileColor: BsTokens.brand.withValues(alpha: 0.08),
        title: Text(d.labelHe),
        subtitle: Text(
          d.id,
          style: TextStyle(
            fontSize: BsTokens.typeCaption,
            color: bsMuted(context),
          ),
        ),
        trailing: d.wired
            ? null
            : const Text(
                'טרם חובר',
                style: TextStyle(
                  fontSize: BsTokens.typeCaption,
                  color: BsTokens.warnText,
                ),
              ),
        onTap: () =>
            ref.read(studioSelectedIdProvider.notifier).state = d.id,
      );
  }
}

sealed class _Row {}

class _ScreenRow extends _Row {
  _ScreenRow(this.screen);
  final String screen;
}

class _AreaRow extends _Row {
  _AreaRow(this.area);
  final String area;
}

class _ElemRow extends _Row {
  _ElemRow(this.d);
  final ElementDescriptor d;
}

/// Flatten the registry to screen-header → area-header → element rows, filtered by
/// [q] (labelHe / id substring). A flat list ⇒ a single virtualised ListView.
List<_Row> _flatten(List<ElementDescriptor> all, String q) {
  final filtered = q.isEmpty
      ? all
      : all.where((d) => d.labelHe.contains(q) || d.id.contains(q)).toList();
  final rows = <_Row>[];
  final byScreen = <String, List<ElementDescriptor>>{};
  for (final d in filtered) {
    (byScreen[d.screen] ??= []).add(d);
  }
  byScreen.forEach((screen, elems) {
    rows.add(_ScreenRow(screen));
    final byArea = <String, List<ElementDescriptor>>{};
    for (final d in elems) {
      (byArea[d.area] ??= []).add(d);
    }
    byArea.forEach((area, areaElems) {
      rows.add(_AreaRow(area));
      for (final d in areaElems) {
        rows.add(_ElemRow(d));
      }
    });
  });
  return rows;
}
