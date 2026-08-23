// The contractor-home atoms: faithful, portable extractions of the finder's
// build-blocks. Each atom is pure — everything comes through props/callbacks,
// no ambient screen state. Pixels must match `finder_screen.dart` exactly
// (parity test). See atom-engine/ENGINE-SPEC.md §4.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/_size_norm.dart';
import 'package:buildsmart/screens/finder_screen.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';

// Same palette the finder uses (private there; redeclared so the atoms are
// self-contained and the fallback file stays untouched).
const _ink = BsTokens.inkLight;
const _mute = Color(0xFF888888);
const _surface = Color(0xFFF5F5F5);

/// Atom 1 — the landing type list. Receives the already system-filtered,
/// counted groups (the controller mirrors the finder's `_categoryCountsFor` /
/// `_groupCount`), so the atom stays pure.
class AtomTypeGrid extends StatelessWidget {
  const AtomTypeGrid({
    required this.groups,
    required this.onSelect,
    super.key,
  });

  final List<(FinderGroup, int)> groups;
  final ValueChanged<FinderGroup> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const Key('catalog-list'),
      itemCount: groups.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        indent: 82,
        color: _surface,
      ),
      itemBuilder: (_, i) {
        final g = groups[i].$1;
        final count = groups[i].$2;
        return InkWell(
          onTap: () => onSelect(g),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: _surface,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: finderGroupGlyph(g.label, size: 46),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.label,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(g.desc,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _mute,
                                fontSize: 13,
                              )),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: BsTokens.brand,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_left, color: _mute),
            ]),
          ),
        );
      },
    );
  }
}

/// Atom 2 — selected-type header: breadcrumb + back-one-level.
class AtomBreadcrumb extends StatelessWidget {
  const AtomBreadcrumb({
    required this.group,
    required this.sub,
    required this.size,
    required this.onBack,
    super.key,
  });

  final FinderGroup group;
  final String? sub;
  final String? size;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final crumbs = <String>[
      group.label,
      if (sub != null) sub!,
      if (size != null) size!,
    ];
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onBack,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            const Icon(Icons.chevron_right, color: _mute),
            const SizedBox(width: 6),
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: _surface,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: finderGroupGlyph(group.label, size: 30),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(crumbs.join('  ‹  '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ]),
        ),
      ),
    );
  }
}

/// A labeled chip row. One widget bound five ways (subtype / narrow / angle /
/// letter / wall). [selected] null ⇒ the "הכל" chip is active. [labelFor] maps
/// a value to its visible chip label (identity by default; the wall bar shows
/// `$c מ"מ` while keying selection on `c`).
class AtomChipBar extends StatelessWidget {
  const AtomChipBar({
    required this.hint,
    required this.options,
    required this.selected,
    required this.onSelectAll,
    required this.onSelect,
    this.labelFor,
    super.key,
  });

  final String hint;
  final List<String> options;
  final String? selected;
  final VoidCallback onSelectAll;
  final ValueChanged<String> onSelect;
  final String Function(String)? labelFor;

  @override
  Widget build(BuildContext context) {
    String label(String v) => labelFor?.call(v) ?? v;
    return atomChipRow(hint, [
      atomChip('הכל', selected == null, onSelectAll),
      for (final c in options)
        atomChip(label(c), selected == c, () => onSelect(c)),
    ]);
  }
}

/// Atom — reassurance line: how many products matched.
class AtomResultCount extends StatelessWidget {
  const AtomResultCount({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text('נמצאו $count מוצרים',
            style: const TextStyle(color: _mute, fontSize: 12)),
      ),
    );
  }
}

/// Atom — one-time orange-chip legend hint. [onDismiss] hides it.
class AtomChipTip extends StatelessWidget {
  const AtomChipTip({required this.onDismiss, super.key});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        const Text('💡', style: TextStyle(fontSize: 13)),
        const SizedBox(width: 6),
        const Expanded(
          child: CfgText('finder_screen.chip_tip',
              'צ׳יפ כתום על מוצר — הקש כדי להחליף גודל או צבע',
              style: TextStyle(color: _ink, fontSize: 12)),
        ),
        Semantics(
          button: true,
          label: 'סגור',
          child: Tooltip(
            message: 'סגור',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDismiss,
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Icon(Icons.close, size: 16, color: _mute),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

/// Terminal results surface — the product list, or the empty message.
class AtomProductList extends StatelessWidget {
  const AtomProductList({required this.products, super.key});

  final List<LipskeyCatalogProduct> products;

  @override
  Widget build(BuildContext context) {
    return products.isEmpty
        ? const Center(
            child: CfgText('finder_screen.no_results', 'לא נמצאו מוצרים',
                style: TextStyle(color: _mute)))
        : LipskeyProductsList(products: products);
  }
}

/// A labeled chip row: fixed leading hint + horizontally-scrolling chips.
Widget atomChipRow(String hint, List<Widget> chips) {
  return Container(
    height: 48,
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: _surface)),
    ),
    child: Row(children: [
      Padding(
        padding: const EdgeInsetsDirectional.only(start: 14, end: 2),
        child: Text(hint,
            style: const TextStyle(
              color: _mute,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            )),
      ),
      Expanded(child: AtomChipScroll(children: chips)),
    ]),
  );
}

/// A single pill chip. (Positional args mirror the finder's `_chip` for a
/// faithful, side-by-side-comparable extraction.)
// ignore: avoid_positional_boolean_parameters
Widget atomChip(String label, bool active, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsetsDirectional.only(end: 8),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? BsTokens.brand : _surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            textDirection: chipLabelDirection(label),
            style: TextStyle(
              color: active ? Colors.white : _ink,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            )),
      ),
    ),
  );
}

/// Horizontal chip strip with a scroll-discoverability edge-fade hint (verbatim
/// copy of the finder's `_ChipScroll`).
class AtomChipScroll extends StatefulWidget {
  const AtomChipScroll({required this.children, super.key});
  final List<Widget> children;
  @override
  State<AtomChipScroll> createState() => _AtomChipScrollState();
}

class _AtomChipScrollState extends State<AtomChipScroll> {
  final _ctrl = ScrollController();
  bool _more = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_recompute);
    WidgetsBinding.instance.addPostFrameCallback((_) => _recompute());
  }

  void _recompute() {
    if (!_ctrl.hasClients) return;
    final more = _ctrl.offset < _ctrl.position.maxScrollExtent - 0.5;
    if (more != _more) setState(() => _more = more);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<ScrollMetricsNotification>(
          onNotification: (_) {
            _recompute();
            return false;
          },
          child: ListView(
            controller: _ctrl,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 7),
            children: widget.children,
          ),
        ),
        if (_more)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                key: const Key('chip-scroll-more'),
                width: 30,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [Color(0x00FFFFFF), Colors.white],
                  ),
                ),
                alignment: Alignment.centerLeft,
                child: const Icon(Icons.chevron_left,
                    size: 18, color: _mute, textDirection: TextDirection.ltr),
              ),
            ),
          ),
      ],
    );
  }
}
