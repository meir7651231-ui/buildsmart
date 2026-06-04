import 'package:buildsmart/screens/barcode_scanner.dart';
import 'package:buildsmart/screens/catalog_screen.dart'
    show
        catalogProductSortProvider,
        catalogSectionProvider,
        searchImageOnlyProvider,
        searchPanelOpenProvider,
        ProductSort;
import 'package:buildsmart/services/voice.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/widgets/dial.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Search FAB dial — 4 tools (voice · barcode · filters · sort).
/// catalog is now a main bottom-nav tab.
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
        ..._submenu(context, ref, tool),
      ],
    );
  }

  List<Widget> _submenu(BuildContext context, WidgetRef ref, SearchTool tool) {
    if (tool == SearchTool.sort) {
      // @legacy submenu-sort.tsx — 4 sort options (mirrors ProductSort enum).
      const sorts = [
        (label: 'ברירת מחדל', emoji: '🔀', value: ProductSort.byOrder),
        (label: 'שם א→ת',    emoji: '🔡', value: ProductSort.nameAZ),
        (label: 'שם ת→א',    emoji: '🔠', value: ProductSort.nameZA),
        (label: 'מק"ט',      emoji: '↕️', value: ProductSort.sku),
      ];
      return [
        for (final s in sorts)
          DialRow(
            label: s.label,
            emoji: s.emoji,
            icon: Icons.circle,
            active: ref.watch(catalogProductSortProvider) == s.value,
            onTap: () {
              ref.read(catalogProductSortProvider.notifier).state = s.value;
              ref.read(searchToolProvider.notifier).state = null;
            },
          ),
      ];
    }
    if (tool == SearchTool.filters) {
      // @legacy submenu-filters.tsx — 2 toggle filters.
      // 'עם תמונה' wires to searchImageOnlyProvider (mirrors _SearchToolsRow).
      // 'עם מחיר מוצג' has no backing provider yet — remains placeholder.
      return [
        DialRow(
          label: 'עם תמונה',
          emoji: '🖼️',
          icon: Icons.circle,
          active: ref.watch(searchImageOnlyProvider),
          onTap: () {
            ref.read(searchImageOnlyProvider.notifier).state =
                !ref.read(searchImageOnlyProvider);
          },
        ),
        DialRow(
          label: 'עם מחיר מוצג',
          emoji: '💲',
          icon: Icons.circle,
          onTap: () => showToast(context, 'עם מחיר מוצג — בבנייה'),
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
          label: 'הפעל מצלמה',
          emoji: '📷',
          icon: Icons.circle,
          onTap: () => openBarcodeScanner(context),
        ),
      ];
    }
    return const [];
  }

  String _label(SearchTool t) => switch (t) {
        SearchTool.voice   => 'קולי',
        SearchTool.barcode => 'ברקוד',
        SearchTool.filters => 'פילטרים',
        SearchTool.sort    => 'מיון',
      };

  String _emoji(SearchTool t) => switch (t) {
        SearchTool.voice   => '🎤',
        SearchTool.barcode => '📷',
        SearchTool.filters => '⚙️',
        SearchTool.sort    => '↕️',
      };
}

class _ToolsRoot extends ConsumerWidget {
  const _ToolsRoot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const tools = [
      (id: SearchTool.voice,   label: 'קולי',    emoji: '🎤'),
      (id: SearchTool.barcode, label: 'ברקוד',   emoji: '📷'),
      (id: SearchTool.filters, label: 'פילטרים', emoji: '⚙️'),
      (id: SearchTool.sort,    label: 'מיון',    emoji: '↕️'),
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
        // ▦ קטלוג — direct action: close search panel + navigate to קטגוריות.
        // Mirrors _SearchToolsRow onTap (catalog_screen.dart:1696-1699).
        DialRow(
          label: 'קטלוג',
          emoji: '▦',
          icon: Icons.circle,
          onTap: () {
            ref.read(searchPanelOpenProvider.notifier).state = false;
            ref.read(catalogSectionProvider.notifier).state = 'קטגוריות';
            ref.read(openDialProvider.notifier).state = OpenDial.none;
          },
        ),
      ],
    );
  }
}
