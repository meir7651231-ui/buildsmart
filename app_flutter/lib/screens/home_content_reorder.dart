import 'package:buildsmart/screens/smart_home_screen.dart'
    show smartHomeSectionFor;
import 'package:buildsmart/state/home_content_order.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🏠 תוכן-בית — the REORDERABLE home-content surface (settings → "סידור מסך
/// הבית"). It previews the SAME wired smart-home sections the home actually
/// renders (via [smartHomeSectionFor]) and lets the contractor reorder them
/// (drag, or up/down), persisted via [homeContentOrderProvider]. Opened as a
/// screen via [route] from settings.
class HomeContentReorder extends ConsumerWidget {
  const HomeContentReorder({super.key, this.showAppBar = false});

  /// When opened as a standalone screen we want a Scaffold + AppBar; when
  /// embedded inside the existing home tab we render just the body.
  final bool showAppBar;

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const HomeContentReorder(showAppBar: true),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const body = _Body();
    if (!showAppBar) return body;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: BsTokens.space4,
          title: CfgText(
            'home_content_reorder.t01',
            '🏠 תוכן הבית',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: CfgText('home_content_reorder.t02', '‹ חזרה',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 14)),
            ),
          ],
        ),
        body: body,
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body();

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(homeContentOrderProvider);
    final notifier = ref.read(homeContentOrderProvider.notifier);

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(
          BsTokens.space4, BsTokens.space4, BsTokens.space4, BsTokens.space2),
      child: Row(
        children: [
          Expanded(
            child: CfgText(
              'home_content_reorder.t03',
              'מסך הבית שלי',
              style: TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          if (_editing)
            TextButton(
              onPressed: () {
                notifier.reset();
                showToast(context, 'הסדר אופס לברירת מחדל');
              },
              child: CfgText('home_content_reorder.t04', 'איפוס',
                  style: TextStyle(color: BsTokens.mutedLight)),
            ),
          TextButton.icon(
            onPressed: () => setState(() => _editing = !_editing),
            icon: Icon(_editing ? Icons.check : Icons.swap_vert,
                size: 18, color: BsTokens.brandDark),
            label: Text(_editing ? 'סיום' : 'שנה סדר',
                style: const TextStyle(color: BsTokens.brandDark)),
          ),
        ],
      ),
    );

    final sections = <Widget>[
      for (var i = 0; i < order.length; i++)
        _SectionSlot(
          key: ValueKey(order[i]),
          index: i,
          total: order.length,
          section: order[i],
          editing: _editing,
          onUp: () => notifier.moveUp(order[i]),
          onDown: () => notifier.moveDown(order[i]),
        ),
    ];

    return ListView(
      padding: const EdgeInsets.only(bottom: BsTokens.space6),
      children: [
        header,
        if (_editing)
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorder: notifier.reorder,
            children: sections,
          )
        else
          ...sections,
      ],
    );
  }
}

/// One reorderable home section: a drag-handle header (in edit mode) + the
/// real section content.
class _SectionSlot extends ConsumerWidget {
  const _SectionSlot({
    required this.index,
    required this.total,
    required this.section,
    required this.editing,
    required this.onUp,
    required this.onDown,
    super.key,
  });

  final int index;
  final int total;
  final HomeSection section;
  final bool editing;
  final VoidCallback onUp;
  final VoidCallback onDown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = kHomeSectionMeta[section]!;
    // Preview the REAL smart-home sections (shared with SmartHomeBody) so the
    // reorder screen matches what the home actually shows.
    final content = smartHomeSectionFor(section);

    if (!editing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: BsTokens.space2),
        child: content,
      );
    }

    // Edit mode — compact handle row (drag + up/down) over a dimmed preview.
    return Container(
      margin: const EdgeInsets.fromLTRB(
          BsTokens.space4, BsTokens.space1, BsTokens.space4, BsTokens.space1),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Semantics(
                button: true,
                label: 'גרור לסידור מחדש',
                child: Tooltip(
                  message: 'גרור לסידור מחדש',
                  child: ReorderableDragStartListener(
                    index: index,
                    child: const Padding(
                      padding: EdgeInsets.all(BsTokens.space3),
                      child: Icon(Icons.drag_indicator,
                          color: BsTokens.mutedLight),
                    ),
                  ),
                ),
              ),
              Text(meta.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(meta.title,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    )),
              ),
              IconButton(
                onPressed: index == 0 ? null : onUp,
                icon: const Icon(Icons.keyboard_arrow_up),
                color: BsTokens.brandDark,
                tooltip: 'הזז למעלה',
              ),
              IconButton(
                onPressed: index == total - 1 ? null : onDown,
                icon: const Icon(Icons.keyboard_arrow_down),
                color: BsTokens.brandDark,
                tooltip: 'הזז למטה',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

