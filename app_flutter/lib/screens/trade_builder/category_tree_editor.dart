// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · Pillar #2 — Domain/Vertical Builder · Step 45 — the CATEGORY-
// TREE editor (wizard step 2 surface).
//
// The owner authors the trade's [TradeCategory] list: a ReorderableListView of
// the trade's categories (sorted by sortIndex — a drag rewrites sortIndex
// 0..n-1 idempotently), tap-to-rename (a prefilled dialog + 'שמור'), a
// Semantics-'מחק' delete per tile, and the bottom add-row (שם קטגוריה +
// הוסף קטגוריה) writing through `upsertCategory` under a DETERMINISTIC slug
// id '<tradeId>.cat.<slug>' (the s44 idiom — NO DateTime/random; a collision
// appends '-2', '-3', … so a same-named sibling never silently overwrites).
// The 🏷️ AppBar action pushes the trade's AttributeSchemaEditorScreen.
//
// Reached only via the trade tile on TradeBuilderHomeScreen (itself behind
// kTradeBuilderFlag, default OFF) ⇒ zero regression. LIGHT manager idiom +
// explicit RTL + Semantics on every tappable + the screen-local textScaler
// clamp (max 1.35) — the s44 family (trade_builder_home.dart) verbatim.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;

import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/screens/trade_builder/attribute_schema_editor.dart';
import 'package:buildsmart/screens/trade_builder/product_authoring_screen.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/config_theme.dart' show cfgRadius;
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The emoji a new category is stamped with (the add-row keeps the minimal
/// s45 surface — no emoji field yet; TradeCategory.emoji is required).
const String _kDefaultCategoryEmoji = '📁';

/// The s44 deterministic slug: trimmed, lowercased, whitespace runs → '-'.
/// NO DateTime/random — the same text always yields the same slug.
String _slug(String text) =>
    text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');

/// Rebuild a category with a new title / sortIndex, preserving EVERY other
/// authored field (parentId, attributeSchemaIds, smartFixtureId — the domain
/// type has no copyWith).
TradeCategory _copy(TradeCategory c, {String? titleHe, int? sortIndex}) =>
    TradeCategory(
      id: c.id,
      tradeId: c.tradeId,
      titleHe: titleHe ?? c.titleHe,
      emoji: c.emoji,
      parentId: c.parentId,
      sortIndex: sortIndex ?? c.sortIndex,
      attributeSchemaIds: c.attributeSchemaIds,
      smartFixtureId: c.smartFixtureId,
    );

/// 🗂️ עץ קטגוריות — the trade's category-tree editor (Pillar-2 · step 45).
class CategoryTreeEditorScreen extends ConsumerStatefulWidget {
  const CategoryTreeEditorScreen({required this.tradeId, super.key});

  final String tradeId;

  static Route<void> route(String tradeId) => MaterialPageRoute<void>(
        builder: (_) => CategoryTreeEditorScreen(tradeId: tradeId),
      );

  @override
  ConsumerState<CategoryTreeEditorScreen> createState() =>
      _CategoryTreeEditorState();
}

class _CategoryTreeEditorState extends ConsumerState<CategoryTreeEditorScreen> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// The trade's categories STABLE-sorted by sortIndex (ties keep the stored
  /// order, so a legacy doc with equal indexes never shuffles between builds).
  List<TradeCategory> _sorted(TradesDoc doc) {
    final own = [
      for (final c in doc.categories)
        if (c.tradeId == widget.tradeId) c,
    ];
    final indexed = own.asMap().entries.toList()
      ..sort((a, b) {
        final bySort = a.value.sortIndex.compareTo(b.value.sortIndex);
        return bySort != 0 ? bySort : a.key.compareTo(b.key);
      });
    return [for (final e in indexed) e.value];
  }

  /// '<tradeId>.cat.<slug>' — deterministic; an id collision appends '-2',
  /// then '-3', … (the s45 contract), so a same-named sibling gets its own id
  /// instead of upsert-overwriting the existing category.
  String _newCategoryId(List<TradeCategory> all, String name) {
    final base = '${widget.tradeId}.cat.${_slug(name)}';
    var id = base;
    var n = 2;
    while (all.any((c) => c.id == id)) {
      id = '$base-${n++}';
    }
    return id;
  }

  /// Add from the bottom row: guard the empty name (no-op), sortIndex = next
  /// after the trade's current max (append at the end).
  void _add() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final doc = ref.read(tradesStoreProvider);
    final next =
        _sorted(doc).fold<int>(-1, (m, c) => math.max(m, c.sortIndex)) + 1;
    ref.read(tradesStoreProvider.notifier).upsertCategory(
          TradeCategory(
            id: _newCategoryId(doc.categories, name),
            tradeId: widget.tradeId,
            titleHe: name,
            emoji: _kDefaultCategoryEmoji,
            sortIndex: next,
          ),
        );
    setState(_name.clear);
  }

  /// Drag handler — move within the trade's sorted list, then rewrite
  /// sortIndex 0..n-1, upserting ONLY the changed rows (the upsert itself is
  /// idempotent too, so a no-move drag writes nothing).
  void _onReorder(int oldIndex, int newIndex) {
    final sorted = _sorted(ref.read(tradesStoreProvider));
    if (oldIndex < 0 || oldIndex >= sorted.length) return;
    var to = newIndex > oldIndex ? newIndex - 1 : newIndex;
    to = to.clamp(0, sorted.length - 1);
    final moved = sorted.removeAt(oldIndex);
    sorted.insert(to, moved);
    final notifier = ref.read(tradesStoreProvider.notifier);
    for (var i = 0; i < sorted.length; i++) {
      if (sorted[i].sortIndex != i) {
        notifier.upsertCategory(_copy(sorted[i], sortIndex: i));
      }
    }
  }

  /// Tap-to-rename: the prefilled dialog; 'שמור' upserts the same id with the
  /// new title (empty/unchanged → no-op), every other field preserved.
  Future<void> _rename(TradeCategory c) async {
    final saved = await showDialog<String>(
      context: context,
      builder: (_) => _RenameCategoryDialog(initial: c.titleHe),
    );
    if (!mounted) return;
    final name = saved?.trim() ?? '';
    if (name.isEmpty || name == c.titleHe) return;
    ref
        .read(tradesStoreProvider.notifier)
        .upsertCategory(_copy(c, titleHe: name));
  }

  // NOTE deliberately NO hintText anywhere on this screen: a hint renders as
  // a real (transparent) Text widget, and the step-45 tests count VISIBLE
  // Text widgets containing an authored title — a 'למשל: …' hint echoing a
  // plausible title would poison those counts.
  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: BsTokens.cardLight,
        labelStyle:
            const TextStyle(color: BsTokens.mutedLight, fontSize: 13.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEDEDED)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEDEDED)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BsTokens.brand, width: 1.4),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final cats = _sorted(ref.watch(tradesStoreProvider));
    final mq = MediaQuery.of(context);
    // The SAME a11y clamp as the s44 builder screens: cap the text scale at
    // 1.35× (never scales UP — min only caps).
    return MediaQuery(
      data: mq.copyWith(
        textScaler: TextScaler.linear(math.min(mq.textScaler.scale(1), 1.35)),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: BsTokens.bgLight,
          appBar: AppBar(
            backgroundColor: BsTokens.cardLight,
            elevation: 0,
            iconTheme: const IconThemeData(color: BsTokens.inkLight),
            title: const Text(
              '🗂️ עץ קטגוריות',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            actions: [
              // s45: the sibling authoring surface — the trade's
              // attribute-schema editor.
              Semantics(
                button: true,
                label: 'מאפיינים',
                child: IconButton(
                  onPressed: () => Navigator.of(context).push(
                    AttributeSchemaEditorScreen.route(widget.tradeId),
                  ),
                  icon: const Text('🏷️', style: TextStyle(fontSize: 18)),
                ),
              ),
              // s46: the sibling authoring surface — the trade's
              // product-authoring screen (wizard step 4).
              Semantics(
                button: true,
                label: 'מוצרים',
                child: IconButton(
                  onPressed: () => Navigator.of(context).push(
                    ProductAuthoringScreen.route(widget.tradeId),
                  ),
                  icon: const Text('📦', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: cats.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.fromLTRB(
                          BsTokens.space4,
                          BsTokens.space4,
                          BsTokens.space4,
                          BsTokens.space2,
                        ),
                        children: const [_EmptyCategories()],
                      )
                    : ReorderableListView(
                        padding: const EdgeInsets.fromLTRB(
                          BsTokens.space4,
                          BsTokens.space4,
                          BsTokens.space4,
                          BsTokens.space2,
                        ),
                        onReorder: _onReorder,
                        children: [
                          for (final c in cats)
                            Padding(
                              key: ValueKey('cat-${c.id}'),
                              padding: const EdgeInsets.only(
                                bottom: BsTokens.space3,
                              ),
                              child: _CategoryTile(
                                category: c,
                                onTap: () => _rename(c),
                                onDelete: () => ref
                                    .read(tradesStoreProvider.notifier)
                                    .removeCategory(c.id),
                              ),
                            ),
                        ],
                      ),
              ),
              // The pinned bottom add-row — inside the body so
              // resizeToAvoidBottomInset keeps it above the keyboard.
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    BsTokens.space4,
                    BsTokens.space2,
                    BsTokens.space4,
                    BsTokens.space4,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _name,
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _add(),
                          style: const TextStyle(
                            color: BsTokens.inkLight,
                            fontSize: 14,
                          ),
                          decoration: _dec('שם קטגוריה'),
                        ),
                      ),
                      const SizedBox(width: BsTokens.space2),
                      _PillButton(
                        label: 'הוסף קטגוריה',
                        enabled: _name.text.trim().isNotEmpty,
                        onTap: _add,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The calm empty-state — the s44 _EmptyTrades idiom with the s45 literal.
class _EmptyCategories extends StatelessWidget {
  const _EmptyCategories();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: BsTokens.space4,
        vertical: BsTokens.space5,
      ),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: const Column(
        children: [
          Text('🗂️', style: TextStyle(fontSize: 34)),
          SizedBox(height: BsTokens.space2),
          Text(
            'אין עדיין קטגוריות',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: BsTokens.mutedLight,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// One category tile — the family's WHITE card, whole-surface tappable
/// (rename) with a Semantics-'מחק' trailing delete. Long-press drags (the
/// ReorderableListView default handles).
class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onTap,
    required this.onDelete,
  });

  final TradeCategory category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${category.emoji} ${category.titleHe}',
      child: Material(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        child: InkWell(
          borderRadius: BorderRadius.circular(cfgRadius(context)),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(BsTokens.space4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(cfgRadius(context)),
              border: Border.all(color: const Color(0xFFEDEDED)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: BsTokens.brand.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: BsTokens.space3),
                Expanded(
                  child: Text(
                    category.titleHe,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: BsTokens.space2),
                Semantics(
                  label: 'מחק',
                  button: true,
                  child: IconButton(
                    onPressed: onDelete,
                    // A real tooltip: a semantics label for screen-readers AND
                    // a long-press hint — independent of semantics-tree timing.
                    tooltip: 'מחק',
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: BsTokens.mutedLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The rename dialog — owns its prefilled controller (safe dispose), brings
/// its own RTL (dialogs mount on the app overlay, ABOVE the screen's
/// Directionality). 'שמור' pops the typed text; 'ביטול' pops null.
class _RenameCategoryDialog extends StatefulWidget {
  const _RenameCategoryDialog({required this.initial});

  final String initial;

  @override
  State<_RenameCategoryDialog> createState() => _RenameCategoryDialogState();
}

class _RenameCategoryDialogState extends State<_RenameCategoryDialog> {
  late final TextEditingController _ctl =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: BsTokens.cardLight,
        title: const Text(
          'שינוי שם',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        content: TextField(
          controller: _ctl,
          autofocus: true,
          onSubmitted: (v) => Navigator.pop(context, v),
          style: const TextStyle(color: BsTokens.inkLight, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: BsTokens.cardLight,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEDEDED)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: BsTokens.brand, width: 1.4),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'ביטול',
              style: TextStyle(color: BsTokens.mutedLight),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _ctl.text),
            style: TextButton.styleFrom(foregroundColor: BsTokens.brand),
            child: const Text(
              'שמור',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

/// The family's brand-pill action (the s44 _SaveDraftButton idiom): always
/// tappable (guards no-op), [enabled] drives the disabled-grey visual + the
/// Semantics enabled flag. Shrink-wraps in a Row, stretches in a ListView.
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: enabled ? BsTokens.brand : const Color(0xFFE2E2E2),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: enabled ? bsOnAccent(context) : BsTokens.mutedLight,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
