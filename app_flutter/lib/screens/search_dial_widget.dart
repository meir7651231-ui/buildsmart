import 'package:buildsmart/data/catalog.dart';
import 'package:buildsmart/screens/barcode_scanner.dart';
import 'package:buildsmart/services/voice.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/widgets/dial.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Search FAB dial — 5 tools (voice · barcode · filters · sort · catalog).
/// Ported from app/src/components/search/tools-dial.tsx + submenu-*.tsx.
/// Phase 2: tools open a sub-dial; non-functional ones toast "בבנייה".
class SearchDialWidget extends ConsumerWidget {
  const SearchDialWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tool = ref.watch(searchToolProvider);
    if (tool == null) return const _ToolsRoot();

    return DialColumn(
      children: [
        // Anchor — tap to pop back to root.
        DialRow(
          label: _label(tool),
          emoji: _emoji(tool),
          icon: Icons.circle,
          active: true,
          onTap: () => ref.read(searchToolProvider.notifier).state = null,
        ),
        ..._submenu(context, tool),
      ],
    );
  }

  List<Widget> _submenu(BuildContext context, SearchTool tool) {
    if (tool == SearchTool.catalog) {
      return [
        for (final c in kCatalogCats)
          DialRow(
            label: c.title,
            emoji: c.emoji,
            icon: Icons.circle,
            onTap: () => showToast(context, '${c.title} — בבנייה'),
          ),
      ];
    }
    if (tool == SearchTool.sort) {
      // @legacy submenu-sort.tsx — 5 sort options.
      const sorts = [
        (label: 'ברירת מחדל', emoji: '🔀'),
        (label: 'שם א→ת',    emoji: '🔡'),
        (label: 'שם ת→א',    emoji: '🔠'),
        (label: 'מחיר ↑',    emoji: '⬆️'),
        (label: 'מחיר ↓',    emoji: '⬇️'),
      ];
      return [
        for (final s in sorts)
          DialRow(
            label: s.label,
            emoji: s.emoji,
            icon: Icons.circle,
            onTap: () => showToast(context, '${s.label} — בבנייה'),
          ),
      ];
    }
    if (tool == SearchTool.filters) {
      // @legacy submenu-filters.tsx — 2 toggle filters.
      const filters = [
        (label: 'עם תמונה',      emoji: '🖼️'),
        (label: 'עם מחיר מוצג', emoji: '💲'),
      ];
      return [
        for (final f in filters)
          DialRow(
            label: f.label,
            emoji: f.emoji,
            icon: Icons.circle,
            onTap: () => showToast(context, '${f.label} — בבנייה'),
          ),
      ];
    }
    if (tool == SearchTool.voice) {
      return [
        DialRow(
          label: 'הקש להפעלה',
          emoji: '🎤',
          icon: Icons.circle,
          onTap: () async {
            final ok = await VoiceService.instance.listen(
              onFinal: (t) {
                if (context.mounted && t.isNotEmpty) {
                  showToast(context, t);
                }
              },
            );
            if (!context.mounted) return;
            if (!ok) showToast(context, 'הדפדפן הזה לא תומך בחיפוש קולי');
          },
        ),
      ];
    }
    if (tool == SearchTool.barcode) {
      return [
        DialRow(
          label: 'פתח מצלמה',
          emoji: '📷',
          icon: Icons.circle,
          onTap: () => openBarcodeScanner(context),
        ),
      ];
    }
    return const [];
  }

  String _label(SearchTool t) => switch (t) {
        SearchTool.voice    => 'קולי',
        SearchTool.barcode  => 'ברקוד',
        SearchTool.filters  => 'פילטרים',
        SearchTool.sort     => 'מיון',
        SearchTool.catalog  => 'קטלוג',
      };

  String _emoji(SearchTool t) => switch (t) {
        SearchTool.voice    => '🎤',
        SearchTool.barcode  => '📷',
        SearchTool.filters  => '⚙️',
        SearchTool.sort     => '↕️',
        SearchTool.catalog  => '▦',
      };
}

class _ToolsRoot extends ConsumerWidget {
  const _ToolsRoot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const tools = [
      (id: SearchTool.voice,   label: 'קולי',     emoji: '🎤'),
      (id: SearchTool.barcode, label: 'ברקוד',    emoji: '📷'),
      (id: SearchTool.filters, label: 'פילטרים', emoji: '⚙️'),
      (id: SearchTool.sort,    label: 'מיון',     emoji: '↕️'),
      (id: SearchTool.catalog, label: 'קטלוג',    emoji: '▦'),
    ];
    return DialColumn(
      children: [
        for (final t in tools)
          DialRow(
            label: t.label,
            emoji: t.emoji,
            icon: Icons.circle,
            onTap: () =>
                ref.read(searchToolProvider.notifier).state = t.id,
          ),
      ],
    );
  }
}
