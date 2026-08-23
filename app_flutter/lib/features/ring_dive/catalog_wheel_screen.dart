// CATALOG WHEEL — the owner's "pick which wheel to start from" finder.
//
// Ring flow (a constraint engine, not a fixed tree — every door open):
//   1) AXIS wheel  — "ממה נתחיל?" — every axis that still splits the pool
//      (סוג · קוטר · אורך · מעבר · חומר · חדר · …). Spin, pick one.
//   2) VALUE wheel — that axis's options (½" · DN40 · …). Spin, pick one → a
//      constraint is added and we return to the AXIS wheel for the next pick.
//   Repeat in ANY order; a "📋 הצג" option and the auto-collapse show the final
//   products. Behind [kAxisDive] ⇒ tree-shaken (byte-identical) when off.

import 'dart:async' show Timer;

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/product_images.dart' show resolveProductImage;
import 'package:buildsmart/data/smart_tree.dart'
    show SmartProduct, kSmartProducts;
import 'package:buildsmart/features/ring_dive/catalog_axes.dart';
import 'package:buildsmart/features/ring_dive/catalog_slang.dart'
    show catValueLabel;
import 'package:buildsmart/features/ring_dive/ring_dive_wheel.dart'
    show RingDiveWheel;
import 'package:buildsmart/features/word_finder/recipe_kit.dart'
    show assembleKit;
import 'package:buildsmart/screens/lipskey_product_sheet.dart'
    show showLipskeyProductSheet;
import 'package:flutter/material.dart';

class CatalogWheelScreen extends StatefulWidget {
  const CatalogWheelScreen({super.key});

  @override
  State<CatalogWheelScreen> createState() => _CatalogWheelScreenState();
}

class _CatalogWheelScreenState extends State<CatalogWheelScreen> {
  /// Chosen constraints: axisId → value.
  final Map<String, String> _cons = <String, String>{};

  /// Constraint order, so back removes the most-recent pick.
  final List<String> _order = <String>[];

  /// The axis we are currently picking a VALUE for; null = the axis selector.
  String? _axis;

  /// The user asked to see the remaining products (the "📋 הצג" option).
  bool _showList = false;

  /// Which page of a long wheel is showing. Every wheel caps at [_cap] slots; when
  /// there are more options, the last slot is "עוד…" and tapping it advances one
  /// page (cycling back to the start), so a wheel is NEVER more than [_cap] items —
  /// the owner's hard rule. "עוד" pages, it does NOT dump the whole list at once.
  int _page = 0;

  /// Max options on a ring before the rest fold behind "עוד…".
  static const int _cap = 12;

  /// ENGINE 3 — jobs. When [_jobMode], the wheel walks the work-recipes instead of
  /// the axes: job-category → job → its assembled kit. A whole job in a few taps.
  bool _jobMode = false;
  String? _jobCat;
  SmartProduct? _job;

  /// The wheel's currently-focused index, fired by [RingDiveWheel.onFocusChanged]
  /// as you SPIN (not only on tap). The live gallery under the wheel rebuilds off
  /// this to preview the focused value's products in real time — and ONLY the
  /// gallery rebuilds on a spin, never the wheel itself.
  final ValueNotifier<int> _focus = ValueNotifier<int>(0);

  /// Max thumbnails in the live gallery before a trailing "+N" tile (which opens
  /// the full list) — so the grid never tries to lay out thousands of images.
  static const int _galCap = 24;

  /// The exact product set the "+N עוד" tile counted, so tapping it opens THAT set
  /// even on the value wheel (where a bare _showList was swallowed by the _axis
  /// early-return). Null → the current [_cons] match.
  List<CatProduct>? _listSet;

  /// Debounces the live gallery preview so a fast spin only previews the value the
  /// wheel SETTLES on, not every crossed detent (which churned CDN fetches + janked
  /// the spin). The wheel's own dial highlight stays instant regardless.
  Timer? _previewDebounce;

  /// Drives the COLLAPSING HEADER: the live gallery's scroll controller feeds a
  /// 0→1 "collapse" amount — 0 = wheel at full size, 1 = wheel shrunk away and a
  /// small 🎡 emoji pill pinned at the top. So scrolling INTO the product photos
  /// hands the screen over to the images; scrolling back up brings the wheel back.
  final ScrollController _galScroll = ScrollController();
  final ValueNotifier<double> _collapse = ValueNotifier<double>(0);

  /// Gallery scroll distance (px) that fully collapses the wheel.
  static const double _collapseSpan = 120;

  /// Level signature — when the wheel moves to a new ring (dive / back / page) we
  /// reset scroll + collapse so every new level opens with the wheel back up.
  String _lastSig = '';

  @override
  void initState() {
    super.initState();
    _galScroll.addListener(_onGalScroll);
  }

  void _onGalScroll() {
    if (!_galScroll.hasClients) return;
    final t = (_galScroll.offset / _collapseSpan).clamp(0.0, 1.0);
    if ((t - _collapse.value).abs() > 0.001) _collapse.value = t;
  }

  /// Re-expand the wheel + jump the gallery to the top. Called from [_body] DURING
  /// build when the ring level changes, so the whole reset is deferred to a post-
  /// frame callback — mutating [_collapse] mid-build would fire its
  /// ValueListenableBuilder's setState during build (a framework error).
  void _resetCollapse() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_galScroll.hasClients) _galScroll.jumpTo(0);
      _collapse.value = 0;
    });
  }

  @override
  void dispose() {
    _previewDebounce?.cancel();
    _galScroll.dispose();
    _collapse.dispose();
    _focus.dispose();
    super.dispose();
  }

  CatAxis _ax(String id) => kCatAxes.firstWhere((a) => a.id == id);

  /// True when [_up] has something to undo — the AppBar back button reads this so
  /// it renders EXACTLY when _up() can act (job mode, paging, list, value wheel,
  /// constraints). Was gated on only _order/_axis/_showList, which hid the arrow
  /// through the whole 'לפי עבודה' flow + a paged wheel → a navigation dead-end.
  bool get _canBack =>
      _job != null ||
      _jobCat != null ||
      _jobMode ||
      _page > 0 ||
      _showList ||
      _axis != null ||
      _order.isNotEmpty;

  /// Step up one ring; false at the root (nothing to undo).
  bool _up() {
    if (_job != null) {
      setState(() {
        _job = null;
        _page = 0;
        _focus.value = 0;
      });
      return true;
    }
    if (_jobCat != null) {
      setState(() {
        _jobCat = null;
        _page = 0;
        _focus.value = 0;
      });
      return true;
    }
    if (_jobMode) {
      setState(() {
        _jobMode = false;
        _page = 0;
        _focus.value = 0;
      });
      return true;
    }
    if (_page > 0) {
      setState(() {
        _page = 0;
        _focus.value = 0;
      });
      return true;
    }
    if (_showList) {
      setState(() {
        _showList = false;
        _listSet = null;
      });
      return true;
    }
    if (_axis != null) {
      setState(() {
        _axis = null;
        _focus.value = 0;
      });
      return true;
    }
    if (_order.isNotEmpty) {
      setState(() {
        _cons.remove(_order.removeLast());
        _focus.value = 0;
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final crumbs = <String>[
      'הכול',
      for (final id in _order) '${_ax(id).label}: ${catValueLabel(id, _cons[id]!)}',
      if (_axis != null) _ax(_axis!).label,
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: !_canBack
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  tooltip: 'חזרה',
                  onPressed: () => _up(),
                ),
          title: Builder(
            builder: (context) {
              // In RTL a faded single Text clips the LEFT edge = the NEWEST crumb
              // (the current location). Pin the leaf so it always shows; only the
              // parent trail fades when the title overflows.
              final leaf = crumbs.last;
              final trail = crumbs.length > 1
                  ? '${crumbs.sublist(0, crumbs.length - 1).join(' › ')} › '
                  : '';
              return Row(
                children: <Widget>[
                  if (trail.isNotEmpty)
                    Flexible(
                      child: Text(
                        trail,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  Text(leaf,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              );
            },
          ),
        ),
        body: SafeArea(child: _body()),
      ),
    );
  }

  Widget _wheel(List<String> labels, List<String> subs, String hint,
          ValueChanged<int> onSelect) =>
      Center(
        child: RingDiveWheel(
          labels: labels,
          sublabels: subs,
          hubHint: hint,
          onSelect: onSelect,
        ),
      );

  /// A wheel over [items], NEVER more than [_cap] slots. When there are more, the
  /// last slot is "עוד…" and tapping it pages forward (cycling back to the start),
  /// so the wheel stays ≤ [_cap] — instead of dumping the whole list onto one wheel.
  Widget _capped<T>(List<T> items, String Function(T) label, String hint,
      void Function(T) pick) {
    if (items.length <= _cap) {
      return _wheel(<String>[for (final it in items) label(it)],
          const <String>[], hint, (i) => pick(items[i]));
    }
    const per = _cap - 1; // 11 real options + 1 reserved "עוד…" slot
    final pages = (items.length + per - 1) ~/ per;
    final start = (_page % pages) * per;
    final end = start + per < items.length ? start + per : items.length;
    final slice = items.sublist(start, end);
    final labels = <String>[for (final it in slice) label(it), 'עוד…'];
    return _wheel(labels, const <String>[], hint, (i) {
      if (i == slice.length) {
        setState(() => _page++);
        return;
      }
      pick(slice[i]);
    });
  }

  /// The visible slice of [items] for the current [_page] (cycling) when the list
  /// tops [_cap]; the whole list otherwise. Mirrors [_capped]'s paging so the
  /// value wheel + its trailing "עוד…" stay within [_cap] slots.
  List<T> _pageOf<T>(List<T> items) {
    if (items.length <= _cap) return items;
    const per = _cap - 1;
    final pages = (items.length + per - 1) ~/ per;
    final start = (_page % pages) * per;
    final end = start + per < items.length ? start + per : items.length;
    return items.sublist(start, end);
  }

  /// A wheel with a LIVE product gallery beneath it. Spinning fires
  /// [RingDiveWheel.onFocusChanged] → [_focus]; only the gallery (a
  /// [ValueListenableBuilder]) rebuilds, showing [previewFor] of the focused
  /// index — the wheel keeps its own rotation untouched.
  Widget _wheelWithGallery({
    required List<String> labels,
    required List<String> subs,
    required String hint,
    required ValueChanged<int> onSelect,
    required List<CatProduct> Function(int) previewFor,
    required String Function(int) headline,
    bool livePreview = true,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Keep the dial at its natural 340px when the viewport has room; on a short
        // / landscape / split viewport shrink it (reserving room for the gallery) so
        // the Column never overflows + zeroes the gallery below it. FittedBox routes
        // hit-testing through its transform, so the wheel's (170,170) centre holds.
        final double dial = constraints.maxHeight.isFinite
            ? (constraints.maxHeight - 124).clamp(140.0, 340.0)
            : 340.0;
        // Built ONCE (not inside the collapse builder) so its State — and thus the
        // wheel's live rotation — survives every collapse tick.
        final wheel = RingDiveWheel(
          labels: labels,
          sublabels: subs,
          hubHint: hint,
          onSelect: onSelect,
          // VALUE wheel: DEBOUNCE the preview so a fast spin only previews the
          // value it SETTLES on (not every detent → CDN churn + jank). AXIS wheel
          // (livePreview:false): the gallery ignores focus → no tick.
          onFocusChanged: livePreview
              ? (i) {
                  _previewDebounce?.cancel();
                  _previewDebounce = Timer(
                    const Duration(milliseconds: 140),
                    () {
                      if (mounted) _focus.value = i;
                    },
                  );
                }
              : null,
        );
        return Column(
          children: <Widget>[
            // COLLAPSING HEADER — as the gallery scrolls (_collapse 0→1) the wheel
            // shrinks (its FittedBox) and fades out while a small 🎡 pill fades in,
            // pinned to the top. Tapping the pill scrolls back up → the wheel re-opens.
            ValueListenableBuilder<double>(
              valueListenable: _collapse,
              builder: (context, t, _) {
                final e = Curves.easeOut.transform(t);
                final h = dial - (dial - 46.0) * e;
                return SizedBox(
                  width: dial,
                  height: h,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      IgnorePointer(
                        // Once mostly collapsed the tiny wheel must not steal the
                        // pill's tap.
                        ignoring: t > 0.6,
                        child: Opacity(
                          opacity: (1 - e * 1.3).clamp(0.0, 1.0),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(width: 340, height: 340, child: wheel),
                          ),
                        ),
                      ),
                      if (t > 0.45)
                        Opacity(
                          opacity: ((t - 0.45) / 0.55).clamp(0.0, 1.0),
                          child: IgnorePointer(
                            ignoring: t < 0.6,
                            child: _collapsedPill(hint),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Expanded(
              child: livePreview
                  ? ValueListenableBuilder<int>(
                      valueListenable: _focus,
                      builder: (_, f, __) => _gallery(previewFor(f), headline(f)),
                    )
                  : _gallery(previewFor(0), headline(0)),
            ),
          ],
        );
      },
    );
  }

  /// The wheel's COLLAPSED form: a compact 🎡 pill pinned at the top that names
  /// what the wheel is choosing ([hint], e.g. "איזה קוטר?"). Tapping it scrolls the
  /// gallery back to the top, which re-opens the full wheel.
  Widget _collapsedPill(String hint) => Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _galScroll.animateTo(
                0,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOut,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x33FF7A18)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text('🎡', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        hint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7A3B00),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_up,
                        size: 16, color: Color(0xFFB06A2E)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  /// The live thumbnail grid under the wheel (3-wide). Capped at [_galCap]; a
  /// trailing "+N" tile opens the full list instead of silently dropping the rest.
  Widget _gallery(List<CatProduct> set, String headline) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 2, 12, 6),
          child: Text(
            // Count FIRST so it never ellipsizes away behind a long slang label.
            '🖼️ ${set.length} · $headline',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: set.isEmpty
              ? const Center(
                  child: Text('אין מוצרים תואמים',
                      style: TextStyle(fontSize: 12)))
              : GridView.builder(
                  // Feeds the collapsing header — scrolling the photos shrinks the
                  // wheel into its 🎡 pill (see _collapse / _onGalScroll).
                  controller: _galScroll,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  gridDelegate:
                      // Responsive: ~132px-wide cells (≈3 columns on a phone, more
                      // on a wide desktop browser) instead of a hardcoded 3 that
                      // balloon to ~400px each on buildsmart-il.com.
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 132,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.80,
                  ),
                  itemCount: set.length > _galCap ? _galCap : set.length,
                  itemBuilder: (_, i) {
                    if (set.length > _galCap && i == _galCap - 1) {
                      return _moreTile(set.length - (_galCap - 1), set);
                    }
                    return _galTile(set[i].product);
                  },
                ),
        ),
      ],
    );
  }

  /// The "+N עוד" tile — opens the full list of EXACTLY [set] (the products it
  /// counted). Carrying [set] via [_listSet] is what makes it work on the VALUE
  /// wheel too: a bare _showList there was swallowed by _body's `_axis != null`
  /// early-return, so the tile was a dead tap.
  Widget _moreTile(int n, List<CatProduct> set) => InkWell(
        onTap: () => setState(() {
          _listSet = List<CatProduct>.of(set);
          _showList = true;
          _focus.value = 0;
        }),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text('+$n\nעוד',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF556070))),
          ),
        ),
      );

  /// One product thumbnail — the real CDN photo via the app's single resolver
  /// ([resolveProductImage]; NEVER a raw asset, which would vanish in a release
  /// build), sized down for the grid, with the type-emoji as the fallback for the
  /// ~4% of products that have no photo. Tapping opens the full product sheet.
  Widget _galTile(LipskeyCatalogProduct p) {
    final asset = p.imageAsset;
    return InkWell(
      // Pass the SAME-CATEGORY products (not just [p]) so the sheet's "💡 tap to
      // switch size/color" variant hint appears when the product actually has
      // switchable variants (it gates on categoryProducts.length > 1).
      onTap: () => showLipskeyProductSheet(
        context,
        p,
        <LipskeyCatalogProduct>[
          for (final cp in catPool)
            if (cp.product.categoryHe == p.categoryHe) cp.product,
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: const Color(0x17000000)),
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            Expanded(
              child: SizedBox.expand(
                child: ColoredBox(
                  color: const Color(0xFFF6F9FB),
                  child: asset == null
                      ? Center(
                          child: Text(p.typeEmoji,
                              style: const TextStyle(fontSize: 30)))
                      : Image(
                          image: ResizeImage(resolveProductImage(asset),
                              width: 220),
                          fit: BoxFit.contain,
                          excludeFromSemantics: true,
                          gaplessPlayback: true,
                          errorBuilder: (_, __, ___) => Center(
                              child: Text(p.typeEmoji,
                                  style: const TextStyle(fontSize: 30))),
                          frameBuilder: (_, child, frame, sync) =>
                              (sync || frame != null)
                                  ? child
                                  : const ColoredBox(color: Color(0x08000000)),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
              child: Text(
                p.nameHe,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                    fontSize: 10.5, height: 1.15, color: Color(0xFF2A2A2A)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    // Reset the collapsing header whenever the ring LEVEL changes (dive / back /
    // page / job step) so a fresh level never inherits the prior level's scroll
    // offset and opens already-collapsed.
    final sig =
        '$_jobMode|$_jobCat|${_job != null}|$_axis|${_order.length}|$_showList|$_page';
    if (sig != _lastSig) {
      _lastSig = sig;
      _resetCollapse();
    }

    // ── ENGINE 3 — the JOB path (recipe kits) ──────────────────────────────────
    if (_jobMode) return _jobBody();

    final matched = catMatching(_cons);

    // "+N עוד" / "📋 הצג" → the full list. Checked BEFORE the value-wheel branch so
    // the gallery's overflow tile opens the EXACT set it counted, on BOTH wheels
    // (previously the `_axis != null` early-return below swallowed it on the value
    // wheel, making "+N" a dead tap that also leaked _showList into the next pick).
    if (_showList) return _finalList(_listSet ?? matched);

    // ── VALUE wheel — the axis's options, with a LIVE product gallery under it
    //    that previews the FOCUSED value's products as you SPIN (before you tap).
    if (_axis != null) {
      final axisId = _axis!;
      final vals = catOptsFor(axisId, _cons, matched, matched);
      final more = vals.length > _cap;
      final shown = _pageOf(vals);
      final labels = <String>[
        for (final v in shown) catValueLabel(axisId, v),
        if (more) 'עוד…',
      ];
      // Partition the matched set by the SHOWN values ONCE, so the live preview
      // is an O(1) map lookup per spin instead of an O(matched) rescan every time
      // the focus changes (or the gallery rebuilds).
      final byValue = <String, List<CatProduct>>{};
      for (final cp in matched) {
        for (final v in shown) {
          if (cp.has(axisId, v)) (byValue[v] ??= <CatProduct>[]).add(cp);
        }
      }
      return _wheelWithGallery(
        labels: labels,
        subs: const <String>[],
        hint: 'איזה ${_ax(axisId).label}?',
        onSelect: (i) {
          if (more && i == shown.length) {
            setState(() {
              _page++;
              _focus.value = 0;
            });
            return;
          }
          setState(() {
            _cons[axisId] = shown[i]; // raw value; the label shown was the slang
            _order.add(axisId);
            _axis = null;
            _page = 0;
            _focus.value = 0;
          });
        },
        previewFor: (f) {
          if (f >= 0 && f < shown.length) {
            final v = shown[f];
            return <CatProduct>[
              for (final cp in matched)
                if (cp.has(axisId, v)) cp,
            ];
          }
          return matched;
        },
        headline: (f) => (f >= 0 && f < shown.length)
            ? 'תצוגה מקדימה · ${_ax(axisId).label}: ${catValueLabel(axisId, shown[f])}'
            : 'מוצרים תואמים',
      );
    }

    final axes = catFindAxes(_cons);
    if (axes.isEmpty || matched.length <= 1) {
      return _finalList(matched); // _showList handled at the top of _body
    }

    // ── AXIS wheel — "הצג" + a "לפי עבודה" entry (opening only) + the top axes
    //    (easy-path order), the rest behind "עוד…", all within [_cap] slots. ─────
    final labels = <String>[];
    final subs = <String>[];
    final actions = <VoidCallback>[];
    void add(String label, String sub, VoidCallback act) {
      labels.add(label);
      subs.add(sub);
      actions.add(act);
    }

    add('📋 הצג ${matched.length}', 'כל המוצרים',
        () => setState(() => _showList = true));
    if (_cons.isEmpty) {
      add('🔧 לפי עבודה', '${kSmartProducts.length} מתכונים',
          () => setState(() {
                _jobMode = true;
                _page = 0;
                _focus.value = 0;
              }));
    }
    // Page the axes so the wheel — הצג/לפי-עבודה + the axes + a "עוד…" slot —
    // never tops [_cap]. "עוד…" advances one page and cycles; no dump-all wheel.
    final reserved = labels.length; // הצג [+ לפי עבודה] are on EVERY page
    final slots = _cap - reserved;
    final moreA = axes.length > slots;
    List<String> shownAxes;
    if (moreA) {
      final per = slots - 1; // reserve one slot for "עוד…"
      final pages = (axes.length + per - 1) ~/ per;
      final start = (_page % pages) * per;
      final end = start + per < axes.length ? start + per : axes.length;
      shownAxes = axes.sublist(start, end);
    } else {
      shownAxes = axes;
    }
    for (final id in shownAxes) {
      add(
        '${_ax(id).emoji} ${_ax(id).label}',
        '${catOptsFor(id, _cons, matched, matched).length} אפשרויות',
        () => setState(() {
          _axis = id;
          _page = 0;
          _focus.value = 0;
        }),
      );
    }
    if (moreA) {
      add('עוד…', 'צירים נוספים', () => setState(() {
            _page++;
            _focus.value = 0;
          }));
    }
    // The axis wheel too carries the live gallery — spinning across axes keeps the
    // current matched set below (an axis is not itself a filter, so it previews
    // everything that still matches).
    return _wheelWithGallery(
      labels: labels,
      subs: subs,
      hint: _order.isEmpty ? 'ממה נתחיל?' : 'לפי מה עוד?',
      onSelect: (i) => actions[i](),
      previewFor: (_) => matched,
      headline: (_) => 'מוצרים תואמים',
      // The axis-wheel gallery is focus-INDEPENDENT (always the current matched
      // set), so don't drive it off _focus — avoids a wasted 24-tile rebuild on
      // every spin detent that produces identical output.
      livePreview: false,
    );
  }

  /// ENGINE 3 — the job flow: category → job → its assembled kit.
  Widget _jobBody() {
    if (_job != null) return _kitList(_job!);
    if (_jobCat != null) {
      final jobs = <SmartProduct>[
        for (final s in kSmartProducts)
          if (s.cat == _jobCat) s,
      ];
      return _capped(jobs, (j) => '${j.emoji} ${j.name}', 'איזו עבודה?',
          (j) => setState(() {
                _job = j;
                _page = 0;
              }));
    }
    final cats = <String>[];
    for (final s in kSmartProducts) {
      if (!cats.contains(s.cat)) cats.add(s.cat);
    }
    return _capped(cats, (c) => c, 'איזו עבודה תעשה?',
        (c) => setState(() {
              _jobCat = c;
              _page = 0;
            }));
  }

  /// The chosen job's kit — one line per accessory, resolved to a catalog product.
  Widget _kitList(SmartProduct job) {
    final lines = assembleKit(job);
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Column(
            children: <Widget>[
              Text('${job.emoji} ${job.name}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              Text('הערכה המלאה · ${lines.length} חלקים',
                  style: const TextStyle(fontSize: 12.5)),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: lines.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final l = lines[i];
              final p = l.product;
              return ListTile(
                leading: Text(p?.typeEmoji ?? '•',
                    style: const TextStyle(fontSize: 20)),
                title: Text(l.acc.name, textDirection: TextDirection.rtl),
                subtitle: Text(p?.nameHe ?? 'לבחירה ידנית',
                    style: const TextStyle(fontSize: 11)),
                trailing: p == null ? null : const Icon(Icons.chevron_left),
                onTap:
                    p == null ? null : () => showLipskeyProductSheet(context, p, <LipskeyCatalogProduct>[p]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _finalList(List<CatProduct> matched) {
    final products = <LipskeyCatalogProduct>[for (final p in matched) p.product];
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Text(
            products.length == 1
                ? 'המוצר שמצאנו:'
                : 'בחר את המדויק · ${products.length} מוצרים',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: products.isEmpty
              ? const Center(child: Text('לא נמצאו מוצרים'))
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate:
                      // Responsive: ~132px-wide cells (≈3 columns on a phone, more
                      // on a wide desktop browser) instead of a hardcoded 3 that
                      // balloon to ~400px each on buildsmart-il.com.
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 132,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.80,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, i) => _galTile(products[i]),
                ),
        ),
      ],
    );
  }
}
