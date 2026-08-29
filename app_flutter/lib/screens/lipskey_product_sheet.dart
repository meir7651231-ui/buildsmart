import 'package:buildsmart/theme/tokens.dart';
import 'dart:math';
import 'package:buildsmart/data/product_images.dart';

import 'package:buildsmart/data/catalog_source.dart'
    show companyCatalogActive, lipskeyScanPool, resolvedCatalogProducts;
import 'package:buildsmart/data/company_categories.dart'
    show companyComplementsFor;
import 'package:buildsmart/data/company_spec_bridge.dart'
    show kCompanySpecSkus;
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_smart_data.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/screens/spec_copilot_screen.dart'
    show SpecCopilotScreen;
import 'package:buildsmart/data/repositories/claude_functions.dart'
    show claudeGatewayProvider;
import 'package:buildsmart/screens/paired_explain_screen.dart'
    show PairedExplainScreen;
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/data/score_band.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/data/variant_families.dart';
import 'package:buildsmart/features/card_keyboard/card_keyboard_flag.dart'
    show kCardKeyboardFlag, kUnifiedFinderFlag;
import 'package:buildsmart/features/card_keyboard/card_picks.dart'
    show CardPick, cardPicksProvider;
import 'package:buildsmart/features/card_keyboard/hop_graph.dart'
    show EdgeKind, HopGraph;
import 'package:buildsmart/features/card_keyboard/hop_stack.dart';
import 'package:buildsmart/features/card_keyboard/line_plan.dart'
    show planLineFromPicks;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show divePoolBySku;
import 'package:buildsmart/logic/install_kit.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/feature_flags.dart' show featureFlagsProvider;
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/widgets/store_comparison_line.dart'
    show StoreComparisonLine, kStoreComparisonUi;
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens a SmartProduct-style bottom sheet for a Lipskey product.
/// [categoryProducts] = all products in the same Lipskey category (for brand variants).
/// Re-entrancy guard for [showLipskeyProductSheet]: two taps landing in the SAME
/// frame (before the modal route finishes pushing and its barrier covers the
/// trigger) would each fire and stack two identical product sheets. Set true on
/// open, cleared on the NEXT frame (not on dismiss) — that is enough to swallow
/// the same-frame duplicate, and a frame-scoped reset never persists (a
/// dismiss-scoped flag could leak across widget tests or block a legitimate
/// re-open). Central here ⇒ all ~15 call sites are covered by this one guard.
bool _lipskeyProductSheetOpen = false;

void showLipskeyProductSheet(
  BuildContext context,
  LipskeyCatalogProduct product,
  List<LipskeyCatalogProduct> categoryProducts, {
  bool forceLive = false,
  List<LipskeyCatalogProduct> hopSeedForTest = const <LipskeyCatalogProduct>[],
}) {
  if (_lipskeyProductSheetOpen) return;
  _lipskeyProductSheetOpen = true;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => LipskeyProductSheet(
      product: product,
      // Never hand the sheet an empty sibling list: its variant pager indexes
      // the list and throws "Invalid argument(s): 0" on length 0 (blanking the
      // whole card). Fall back to the product itself so it always renders.
      categoryProducts:
          categoryProducts.isEmpty ? [product] : categoryProducts,
      forceLive: forceLive,
      hopSeedForTest: hopSeedForTest,
    ),
  );
  WidgetsBinding.instance
      .addPostFrameCallback((_) => _lipskeyProductSheetOpen = false);
}

/// Fullscreen pinch/zoom viewer for a product image or spec page.
void _openFullscreenAsset(BuildContext context, String asset, String emoji) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.92),
    builder: (_) => Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 5,
            child: Center(
              child: productImage(asset,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Text(emoji,
                      style: const TextStyle(fontSize: 96))),
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 16,
          child: Material(
            color: Colors.black12,
            shape: const CircleBorder(),
            child: Semantics(
              button: true,
              label: 'סגור',
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.pop(context),
                child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(Icons.close, color: Colors.white)),
              ),
            ),
          ),
        ),
        const Positioned(
          bottom: 36,
          left: 0,
          right: 0,
          child: CfgText('lipskey_product_sheet.zoom_hint_fullscreen',
              'צבוט להגדלה · הקש לסגירה',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black38, fontSize: 12)),
        ),
      ],
    ),
  );
}

/// Candidate pool for the compat/finder scans in this sheet. Company overlay
/// (import feature): an imported product must suggest parts from ITS OWN
/// catalog — never BuildSmart's — so scan [resolvedCatalogProducts] when the
/// overlay is live. Without an overlay (demo/buildsmart) this stays the
/// Lipskey subset the rankings were tuned on — results byte-identical.
List<LipskeyCatalogProduct> get _scanPool => lipskeyScanPool;

class LipskeyProductSheet extends ConsumerStatefulWidget {
  const LipskeyProductSheet({
    super.key,
    required this.product,
    required this.categoryProducts,
    this.forceLive = false,
    this.hopSeedForTest = const <LipskeyCatalogProduct>[],
  });

  final LipskeyCatalogProduct product;
  final List<LipskeyCatalogProduct> categoryProducts;

  /// P8.74 — test seam: force the flag-ON hop UI without the feature flag (parallels
  /// CardKeyboardScreen.forceLiveForTest). Production stays flag-gated → OFF.
  final bool forceLive;

  /// P8.75 — test seam: pre-seed the hop back-stack so a test can exercise the back
  /// control deterministically. Production opens with an empty stack.
  @visibleForTesting
  final List<LipskeyCatalogProduct> hopSeedForTest;

  @override
  ConsumerState<LipskeyProductSheet> createState() =>
      _LipskeyProductSheetState();
}

enum _Unit { single, pack, pallet }

class _LipskeyProductSheetState extends ConsumerState<LipskeyProductSheet> {
  late int _selectedIdx;
  // P8.75: the product back-stack (replaces a single override) — a 'back' returns to
  // the PREVIOUS hopped product, not all the way to the opening variant.
  final HopStack<LipskeyCatalogProduct> _hops = HopStack<LipskeyCatalogProduct>();
  String? _openPickerKey; // 'type' | 'subtype' | 'model' | 'color'
  int? _activeStage;
  late Map<int, bool> _accSelected;
  int _qty = 1;
  _Unit _unit = _Unit.single;


  int get _unitMult => switch (_unit) {
        _Unit.single => 1,
        _Unit.pack => _current.qtyPack ?? 1,
        _Unit.pallet => _current.qtyPallet ?? 1,
      };

  /// Normalised DN-size set used for *matching* compatibility. Only sizes in
  /// a real dimension context — DN-prefixed, ratios (50/40), inch fractions —
  /// so packaging quantities ("75 כמות באריזה") and lengths ("200 ס"מ") are
  /// NOT treated as sizes.
  Set<String> _sizeSet(String name) {
    final out = <String>{};
    void addParts(String token) {
      out.add(token);
      for (final part in token.split('/')) {
        if (part.length >= 2 && RegExp(r'^\d+$').hasMatch(part)) out.add(part);
      }
    }

    for (final raw in name.split(RegExp(r'\s+'))) {
      final w = raw.trim();
      final up = w.toUpperCase();
      if (up.startsWith('DN') && RegExp(r'\d').hasMatch(w)) {
        addParts(up.replaceAll(RegExp(r'[^0-9/]'), ''));
      } else if (RegExp(r'^\d').hasMatch(w) && w.contains('/')) {
        addParts(w.replaceAll('"', '')); // 50/40 · 130/50 · 3/4
      } else if (w.contains('"') && RegExp(r'\d').hasMatch(w)) {
        out.add(w.replaceAll('"', '')); // 1.25 · 1¼
      }
      // bare numbers are intentionally ignored (ambiguous with qty/length)
    }
    return out.where((s) => s.length >= 2).toSet();
  }

  /// The distinct *connection ends* of a product — the atomic DN/inch sizes.
  /// A reducer "75/50" has two ends (75, 50); "DN50" has one (50).
  List<String> _connectionSizes(String name) {
    final set = _sizeSet(name);
    // atomic = numeric parts + inch tokens (drop the compound strings like 75/50)
    final atomic = set.where((s) => !s.contains('/')).toList();
    // preserve a stable, human order: larger DN first
    atomic.sort((a, b) {
      final na = int.tryParse(a), nb = int.tryParse(b);
      if (na != null && nb != null) return nb.compareTo(na);
      return a.compareTo(b);
    });
    return atomic;
  }

  /// Material of a product, inferred from name/category (צעד 62).
  static String _material(LipskeyCatalogProduct p) {
    final n = p.nameHe + p.categoryHe;
    if (n.contains('נחושת')) return 'copper';
    if (n.contains('HDPE')) return 'hdpe';
    if (n.contains('PP') || n.contains('רב שכבתי')) return 'pp';
    if (n.contains('NTM') || n.contains('PEX')) return 'pex';
    return 'pvc'; // default drainage
  }

  /// For one connection size — every other-category part that fits it,
  /// מדורג: אותו חומר תחילה (צעדים 62–63).
  List<LipskeyCatalogProduct> _partsForSize(
      LipskeyCatalogProduct p, String size) {
    final mat = _material(p);
    final gender = p.connectionGender; // 'male' wants 'female' and vice-versa
    final method = p.connectionMethod;
    final seen = <String>{p.sku};
    final all = <LipskeyCatalogProduct>[];
    for (final q in _scanPool) {
      if (q.categoryHe == p.categoryHe) continue; // cross-category only
      if (!seen.add(q.sku)) continue;
      if (!_sizeSet(q.nameHe).contains(size)) continue;
      // צעד 60: a gendered end never mates with the same gender — drop it.
      if (gender != null &&
          q.connectionGender != null &&
          q.connectionGender == gender) {
        continue;
      }
      all.add(q);
    }
    // ranking (צעדים 61–63): same connection-method first, then same material,
    // then opposite gender (the true mate), then category name for stability.
    int methodRank(LipskeyCatalogProduct x) =>
        method == null || x.connectionMethod == null
            ? 1
            : (x.connectionMethod == method ? 0 : 2);
    int genderRank(LipskeyCatalogProduct x) => gender != null &&
            x.connectionGender != null &&
            x.connectionGender != gender
        ? 0
        : 1;
    all.sort((a, b) {
      final cmp = methodRank(a).compareTo(methodRank(b));
      if (cmp != 0) return cmp;
      final am = _material(a) == mat ? 0 : 1;
      final bm = _material(b) == mat ? 0 : 1;
      if (am != bm) return am - bm;
      final g = genderRank(a).compareTo(genderRank(b));
      if (g != 0) return g;
      return a.categoryHe.compareTo(b.categoryHe);
    });
    return all.take(12).toList();
  }

  /// Per-side connection groups: [(sizeLabel, fitting parts), ...].
  List<({String size, List<LipskeyCatalogProduct> parts})> _connectionGroups(
      LipskeyCatalogProduct p) {
    // צעד 68: a manual size override wins over name extraction.
    final sizes = kLipskeyConnectionSizeOverride[p.sku] ?? _connectionSizes(p.nameHe);
    final groups = <({String size, List<LipskeyCatalogProduct> parts})>[];
    for (final s in sizes) {
      final parts = _partsForSize(p, s);
      if (parts.isNotEmpty) groups.add((size: s, parts: parts));
    }
    // צעד 68: prepend confirmed manual pairings the size match missed.
    final overrideSkus = kLipskeyCompatPairOverride[p.sku] ?? const [];
    if (overrideSkus.isNotEmpty) {
      final extra = _scanPool
          .where((q) => overrideSkus.contains(q.sku))
          .toList();
      if (extra.isNotEmpty) {
        if (groups.isEmpty) {
          groups.add((size: 'תואם', parts: extra));
        } else {
          final first = groups.first;
          final merged = [
            ...extra,
            ...first.parts.where((q) => !overrideSkus.contains(q.sku)),
          ];
          groups[0] = (size: first.size, parts: merged);
        }
      }
    }
    return groups;
  }

  /// Installation kit (צעד 64): the single best-ranked mate for each
  /// connection side — the minimal parts list to complete every joint of this
  /// product. De-duped by SKU so a part shared across sides appears once.
  List<LipskeyCatalogProduct> _installKit(LipskeyCatalogProduct p) {
    final kit = <LipskeyCatalogProduct>[];
    final seen = <String>{};
    for (final g in _connectionGroups(p)) {
      if (g.parts.isEmpty) continue;
      final top = g.parts.first; // rank #1 (same method/material, opp. gender)
      if (seen.add(top.sku)) kit.add(top);
    }
    return kit;
  }

  void _addKitToCart(List<LipskeyCatalogProduct> kit) {
    final notifier = ref.read(smartCartProvider.notifier);
    for (final part in kit) {
      notifier.add(SmartCartLine(
        productKey: 'lip:${part.sku}',
        productName: part.nameHe,
        productEmoji: part.typeEmoji,
        brandName: part.brand,
        brandPrice: 0,
        productQty: 1,
        accessories: const [],
      ));
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('נוספו ${kit.length} חלקי ערכת-התקנה לסל ✓'),
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
    ));
  }

  /// Inch sizes show as e.g. 1.25" ; plain DN numbers as DN50.
  String _sizeLabel(String s) =>
      RegExp(r'^\d+$').hasMatch(s) ? 'DN$s' : '$s"';

  void _addToCart() {
    final p = _current;
    final accs = <SmartCartAcc>[];
    for (var i = 0; i < _accs.length; i++) {
      if (_accSelected[i] == true) {
        accs.add(SmartCartAcc(
          name: _accs[i].name,
          emoji: _accs[i].emoji,
          price: _accs[i].price ?? 0,
          qty: 1,
        ));
      }
    }
    ref.read(smartCartProvider.notifier).add(SmartCartLine(
          productKey: 'lip:${p.sku}',
          productName: p.nameHe,
          productEmoji: p.typeEmoji,
          brandName: p.brand,
          brandPrice: 0,
          productQty: _qty * _unitMult,
          accessories: accs,
        ));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: CfgText('lipskey_product_sheet.added_to_cart', 'נוסף לסל ✓'),
      duration: Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
    ));
    Navigator.pop(context);
  }

  // צעד 78: per-product (SKU) link with category fallback.
  List<LipskeyCatAcc> get _accs =>
      lipskeyAccFor(_current.sku, _current.categoryHe);
  List<LipskeyCatStage> get _stages =>
      lipskeyStagesFor(_current.sku, _current.categoryHe);
  LipskeyCatalogProduct get _current =>
      _hops.current ?? widget.categoryProducts[_selectedIdx];

  /// P8.74 — the hop UI (back control + related rail) is live when the feature flag
  /// is on, or forced in a test. OFF in production today → byte-identical.
  ///
  /// Swarm-review (high): read ONCE at first access (late final), NOT ref.watch — so a late
  /// async featureFlags load can never swap the engine mid-dive — and honour BOTH unified-
  /// finder flags exactly like CardKeyboardScreen._live. Flag-OFF both are false → identical.
  late final bool _live = widget.forceLive ||
      ref.read(featureFlagsProvider).contains(kCardKeyboardFlag) ||
      ref.read(featureFlagsProvider).contains(kUnifiedFinderFlag);

  /// P8.75 — pop one hop (return to the previous product).
  void _hopBack() => setState(_hops.back);

  /// P8.77 — the flag-gated 'related' rail: the hop-graph neighbours of the current
  /// product as tappable chips (most meaningful first — variant > kit > compat >
  /// category > hub), each tap an in-place hop. Bounded so the rail stays scannable;
  /// never empty for an in-graph product (the hub guarantees >=1 neighbour).
  Widget _hopRail(LipskeyCatalogProduct p) {
    final g = HopGraph.build();
    final neighbours = g
        .rankedNeighborsOf(p.sku)
        .where((s) {
          // De-dup (swarm-review): the compat/kit neighbours are the '🔌 מה מתחבר לזה'
          // rail; keep THIS '🔗 קשור' rail to the OTHER relations (variant/category/hub)
          // so no product appears in both rows.
          final kinds = g.kindsBetween(p.sku, s);
          return !(kinds.contains(EdgeKind.compat) ||
              kinds.contains(EdgeKind.kit));
        })
        .map((s) => divePoolBySku[s])
        .whereType<LipskeyCatalogProduct>()
        .take(10)
        .toList();
    if (neighbours.isEmpty) return const SizedBox.shrink();
    return Padding(
      key: const Key('hopRail'),
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CfgText('lipskey_product_sheet.related_rail_title', '🔗 קשור',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final n in neighbours)
                ActionChip(
                  key: Key('hopRailChip_${n.sku}'),
                  label: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(n.nameHe,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12)),
                  ),
                  onPressed: () => _switchByChip(n),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// P9.89 — the 'what connects to this' rail: the current product's hop-graph
  /// neighbours reached by a compat or kit edge (the same canonical graph as the related
  /// rail, filtered to physical-connection edges) as tappable in-place hops. Flag-gated.
  Widget _hopConnectRail(LipskeyCatalogProduct p) {
    final g = HopGraph.build();
    final connects = g
        .rankedNeighborsOf(p.sku)
        .where((s) {
          final kinds = g.kindsBetween(p.sku, s);
          return kinds.contains(EdgeKind.compat) ||
              kinds.contains(EdgeKind.kit);
        })
        .map((s) => divePoolBySku[s])
        .whereType<LipskeyCatalogProduct>()
        .take(8)
        .toList();
    if (connects.isEmpty) return const SizedBox.shrink();
    return Padding(
      key: const Key('hopConnectRail'),
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CfgText('lipskey_product_sheet.connects_rail_title',
              '🔌 מה מתחבר לזה',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final n in connects)
                ActionChip(
                  key: Key('hopConnectChip_${n.sku}'),
                  label: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(n.nameHe,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12)),
                  ),
                  onPressed: () => _switchByChip(n),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// P10.98 — the line controls: 'add to line' records the current product as a pick;
  /// 'complete line (N)' appears once >=2 are picked and opens the BOM. Flag-gated.
  Widget _lineControls(LipskeyCatalogProduct p) {
    final picks = ref.watch(cardPicksProvider);
    return Padding(
      key: const Key('lineControls'),
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ActionChip(
            key: const Key('addToLineChip'),
            avatar: const Icon(Icons.add, size: 16),
            label: const CfgText('lipskey_product_sheet.add_to_line', 'הוסף לקו'),
            onPressed: () => _addCurrentToLine(p),
          ),
          if (picks.length >= 2)
            ActionChip(
              key: const Key('completeLineChip'),
              avatar: const Icon(Icons.checklist, size: 16),
              label: Text('השלם קו (${picks.length})'),
              onPressed: () => _showLineBom(picks),
            ),
        ],
      ),
    );
  }

  void _addCurrentToLine(LipskeyCatalogProduct p) {
    ref.read(cardPicksProvider.notifier).addPick(
          CardPick(sku: p.sku, label: p.nameHe),
        );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: CfgText('lipskey_product_sheet.added_to_line', 'נוסף לקו ✓'),
      duration: Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showLineBom(List<CardPick> picks) {
    final plan = planLineFromPicks(picks);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (modalCtx) => Directionality(
        key: const Key('lineBomSheet'),
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CfgText('lipskey_product_sheet.line_bom_title',
                    '📋 רשימת חומרים — קו',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (plan.items.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: CfgText(
                                'lipskey_product_sheet.line_bom_empty',
                                'לא נמצאו פריטים לפתרון — בחר מוצרים אחרים לקו',
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF888888))),
                          ),
                        for (final item in plan.items)
                          Text('• ${item.nameHe}  ×${plan.qtyOf(item.sku)}',
                              style: const TextStyle(fontSize: 13)),
                        if (plan.gaps.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                                '⚠️ ${plan.gaps.length} פערים — דורש השלמה',
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF888888))),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('addLineToCartButton'),
                    // Swarm-review: an empty plan must NOT 'add 0 to cart' and silently
                    // wipe the picks — disable the button so a fully-unresolvable line is a
                    // visible no-op, not a fake success toast.
                    onPressed: plan.items.isEmpty
                        ? null
                        : () {
                            _addLineToCart(plan.items);
                            Navigator.of(modalCtx).pop();
                          },
                    child: Text(
                        plan.items.isEmpty ? 'אין פריטים לסל' : 'הוסף הכל לסל'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addLineToCart(List<LipskeyCatalogProduct> items) {
    final notifier = ref.read(smartCartProvider.notifier);
    for (final part in items) {
      notifier.add(SmartCartLine(
        productKey: 'lip:${part.sku}',
        productName: part.nameHe,
        productEmoji: part.typeEmoji,
        brandName: part.brand,
        brandPrice: 0,
        productQty: 1,
        accessories: const [],
      ));
    }
    ref.read(cardPicksProvider.notifier).clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('נוספו ${items.length} פריטי-קו לסל ✓'),
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
    ));
  }

  /// P8.78 — the hop path breadcrumb: every product in the path as a tappable crumb
  /// (home → … → current). Tapping a crumb jumps back to it (popTo); tapping home
  /// clears to the opening variant. Built only when live and the path is non-empty.
  Widget _hopBreadcrumb() {
    final crumbs = _hops.path;
    return Padding(
      key: const Key('hopBreadcrumb'),
      padding: const EdgeInsets.only(bottom: 6),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2,
        runSpacing: 2,
        children: [
          InkWell(
            key: const Key('hopCrumb_home'),
            onTap: () => setState(_hops.clear),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Icon(Icons.home_outlined, size: 14),
            ),
          ),
          for (var i = 0; i < crumbs.length; i++) ...[
            const Icon(Icons.chevron_left, size: 14),
            InkWell(
              key: Key('hopCrumb_$i'),
              onTap: () => setState(() {
                _hops.popTo(i);
              }),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 90),
                child: Text(
                  crumbs[i].nameHe,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: i == crumbs.length - 1
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedIdx =
        widget.categoryProducts.indexOf(widget.product).clamp(0, widget.categoryProducts.length - 1);
    for (final seed in widget.hopSeedForTest) {
      _hops.push(seed);
    }
    _accSelected = {
      for (var i = 0; i < (_accs.length); i++) i: false,
    };
  }

  void _switchByChip(LipskeyCatalogProduct q) {
    setState(() {
      _hops.push(q);
      _openPickerKey = null;
      _accSelected = {for (var j = 0; j < _accs.length; j++) j: false};
      _activeStage = null;
      // Reset the unit selector to the new variant's default: pack/pallet
      // quantities (qtyPack/qtyPallet) are per-product, so a leftover 'ארגז'
      // from the previous variant misrepresents the freshly-selected one.
      _unit = _Unit.single;
    });
  }

  int get _accTotal {
    var t = 0;
    for (var i = 0; i < _accs.length; i++) {
      if (_accSelected[i] == true) t += _accs[i].price ?? 0;
    }
    return t;
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final p = _current;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Close (X) — clear & prominent, top-left
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 0, 2),
                  child: Material(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: const CircleBorder(),
                    child: Semantics(
                      button: true,
                      label: 'סגור',
                      child: Tooltip(
                        message: 'סגור',
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.pop(context),
                          child: const SizedBox(
                            width: 48,
                            height: 48,
                            child: Icon(Icons.close,
                                color: BsTokens.inkLight, size: 22),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
                  children: [
                    // ── Hero image (tap = flip to spec) ─────────────────
                    _HeroImage(product: p, screenH: screenH),

                    const SizedBox(height: 16),

                    // ── Product header ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(p.categoryEmoji,
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(p.categoryHe,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.black38, fontSize: 12)),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                      ClipboardData(text: p.sku));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: CfgText(
                                          'lipskey_product_sheet.sku_copied',
                                          'מק"ט הועתק'),
                                      duration: Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: Text('#${p.sku}',
                                    style: const TextStyle(
                                        color: Color(0xFFFFB300),
                                        fontFamily: 'monospace',
                                        fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text((p.dims?['שם מלא'] as String?) ?? p.nameHe,
                              style: const TextStyle(
                                  color: BsTokens.inkLight,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  height: 1.3)),
                          if (p.nameEn.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(p.nameEn,
                                style: const TextStyle(
                                    color: Color(0xFF888888),
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic)),
                          ],
                          // ── C3.4 · multi-store comparison ──────────────────
                          // OWNER-LOCKED: the ONLY sheet surface that shows a
                          // price. Gated on a const (default false) ⇒ dead code,
                          // tree-shaken ⇒ the sheet is byte-identical with the
                          // flag OFF. Turned on at go-live with useServerCatalog.
                          if (kStoreComparisonUi)
                            StoreComparisonLine(sku: p.sku),
                          // Two HONEST chips instead of one conflated "ציון
                          // נתונים": cardReadinessScore is gated on the verified
                          // CONNECTION spec, so it really measures install/
                          // connection readiness — a non-connecting auxiliary
                          // (clamp/seat/grate) is correctly low. The separate
                          // dataCompletenessScore (spec-free) vindicates a part
                          // whose LISTING is complete even when it never plumbs.
                          const SizedBox(height: 6),
                          Builder(builder: (_) {
                            final s = cardReadinessScore(p);
                            final c = scoreBandColors(s.score);
                            final d = dataCompletenessScore(p);
                            final dc = scoreBandColors(d.score);
                            Widget chip(
                                    ScoreBandColors col, String text) =>
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: col.bg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: col.border),
                                  ),
                                  child: Text(text,
                                      style: TextStyle(
                                          color: col.fg,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700)),
                                );
                            return Wrap(spacing: 6, runSpacing: 6, children: [
                              chip(dc,
                                  '📋 שלמות נתונים ${d.score}% · ${d.label}'),
                              chip(c,
                                  '🔧 מוכנות התקנה ${s.score} · ${s.label}'),
                            ]);
                          }),
                          const SizedBox(height: 8),
                          if (_live && _hops.canGoBack) _hopBreadcrumb(),
                          if (_live && _hops.canGoBack)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: ActionChip(
                                  key: const Key('hopBackChip'),
                                  avatar: const Icon(Icons.undo, size: 16),
                                  label: const CfgText(
                                      'lipskey_product_sheet.hop_back',
                                      'חזרה למוצר הקודם'),
                                  onPressed: _hopBack,
                                ),
                              ),
                            ),
                          if (_live) _hopRail(p),
                          if (_live) _hopConnectRail(p),
                          if (_live) _lineControls(p),
                          _InteractiveChips(
                            product: p,
                            openPickerKey: _openPickerKey,
                            onChipTap: (key) => setState(() {
                              _openPickerKey =
                                  _openPickerKey == key ? null : key;
                            }),
                            onVariantSelect: _switchByChip,
                          ),
                          if (widget.categoryProducts.length > 1)
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: CfgText(
                                  'lipskey_product_sheet.chip_hint',
                                  '💡 צ׳יפ כתום ▾ — הקש להחלפת גודל/צבע/דגם',
                                  style: TextStyle(
                                      color: Color(0xFF888888), fontSize: 11)),
                            ),
                          const SizedBox(height: 12),
                          // ── מאתר · תאימות · ערכת התקנה · דומים ────────
                          _QuickInfoStrips(
                            product: p,
                            onPickProduct: (q) {
                              // jump to the sibling/related product right
                              // inside this same sheet, without closing it
                              _switchByChip(q);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    const _Divider(),
                    const SizedBox(height: 16),

                    // ── (Removed: "🔀 בחר גרסה" — duplicated by the
                    //   🔄 דומים strip's expandable carousel; variant
                    //   switching now happens via the strip panel.)

                    // ── (Removed: standalone "🧰 אביזרים נדרשים" — fully
                    //   absorbed into the 📦 ערכת התקנה strip panel.)

                    // ── Installation stages ─────────────────────────────
                    if (_stages.isNotEmpty) ...[
                      _SectionTitle(
                        emoji: '📋',
                        title: 'שלבי התקנה',
                        subtitle: '${_stages.length} שלבים',
                      ),
                      const SizedBox(height: 10),
                      ..._stages.asMap().entries.map((e) => _StageRow(
                            stage: e.value,
                            index: e.key,
                            isActive: _activeStage == e.key,
                            onTap: () => setState(() =>
                                _activeStage =
                                    _activeStage == e.key ? null : e.key),
                          )),
                      const SizedBox(height: 16),
                      const _Divider(),
                      const SizedBox(height: 16),
                    ],

                    // ── Spec data ───────────────────────────────────────
                    if (p.color != null ||
                        p.qtyPack != null ||
                        p.qtyPallet != null ||
                        p.dims != null) ...[
                      _SectionTitle(emoji: '📐', title: 'פרטי מוצר'),
                      const SizedBox(height: 10),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            if (p.color != null)
                              _SpecRow('🎨', 'צבע', p.color!),
                            if (p.qtyPack != null)
                              _SpecRow('📦', 'כמות באריזה',
                                  '${p.qtyPack}'),
                            if (p.qtyPallet != null)
                              _SpecRow('🏗️', 'כמות במשטח',
                                  '${p.qtyPallet}'),
                            if (p.dims != null)
                              for (final e in p.dims!.entries)
                                if (e.value != null && e.key != 'שם מלא')
                                  _SpecRow(
                                      '📐',
                                      e.key,
                                      formatDimValue(
                                          e.key,
                                          '${e.value}',
                                          ref.watch(catalogSettingsProvider))),
                            // Imported products carry page 0 — no bogus
                            // 'עמוד 0' row (BuildSmart pages are all >= 1).
                            if (p.page > 0)
                              _SpecRow('📄', 'עמוד בקטלוג',
                                  'עמוד ${p.page}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _Divider(),
                      const SizedBox(height: 16),
                    ],

                    // (purchase bar — qty/unit/add-to-cart — pinned as a
                    //  footer below the scroll so the CTA is always reachable)

                    // ── 🔧 חיבורים תואמים — לפי צד/מידה ──────────────────
                    ...(() {
                      final groups = _connectionGroups(p);
                      if (groups.isEmpty) return <Widget>[];
                      final multi = groups.length > 1;
                      final w = <Widget>[
                        const SizedBox(height: 16),
                        const _Divider(),
                        const SizedBox(height: 16),
                        _SectionTitle(
                          emoji: '🔧',
                          title: 'חיבורים תואמים',
                          subtitle: multi
                              ? '${groups.length} צדדים — מה מתחבר לכל מידה'
                              : 'מה מתחבר ל-${_sizeLabel(groups.first.size)}',
                        ),
                        const SizedBox(height: 6),
                      ];
                      // ── ערכת-התקנה: המתאם המומלץ לכל צד, בלחיצה אחת ──────
                      final kit = _installKit(p);
                      if (kit.length >= 2) {
                        w.add(Padding(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0x143DD9B0),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0x553DD9B0)),
                            ),
                            child: Row(
                              children: [
                                const Text('🧩', style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const CfgText(
                                          'lipskey_product_sheet.recommended_kit',
                                          'ערכת התקנה מומלצת',
                                          style: TextStyle(
                                              color: BsTokens.inkLight,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700)),
                                      Text(
                                          '${kit.length} חלקים — מתאם לכל צד חיבור',
                                          style: const TextStyle(
                                              color: Color(0xFF9AA3B2),
                                              fontSize: 11)),
                                    ],
                                  ),
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF3DD9B0),
                                    foregroundColor: const Color(0xFF06251C),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                  ),
                                  onPressed: () => _addKitToCart(kit),
                                  child: const CfgText(
                                      'lipskey_product_sheet.add_kit',
                                      '+ ערכה',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                        ));
                      }
                      for (var gi = 0; gi < groups.length; gi++) {
                        final g = groups[gi];
                        w.add(Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20, 8, 20, 6),
                          child: Row(
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0x22FF7A18),
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                        color: const Color(0x55FF7A18)),
                                  ),
                                  child: Text(
                                    multi
                                        ? '📐 צד ${gi + 1}: ${_sizeLabel(g.size)}'
                                        : '📐 ${_sizeLabel(g.size)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Color(0xFFFF9D4D),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text('${g.parts.length} חלקים',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Color(0xFF9AA3B2),
                                        fontSize: 11)),
                              ),
                            ],
                          ),
                        ));
                        w.add(SizedBox(
                          height: 132,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: g.parts.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (_, i) => _RelatedCard(
                              product: g.parts[i],
                              onTap: () => showLipskeyProductSheet(
                                context,
                                g.parts[i],
                                _scanPool
                                    .where((x) =>
                                        x.categoryHe == g.parts[i].categoryHe)
                                    .toList(),
                              ),
                            ),
                          ),
                        ));
                      }
                      return w;
                    })(),

                    // ── (Removed: "🔗 מוצרים נלווים / דומים" — duplicated
                    //   the 🔄 דומים strip's carousel and the 🤝 compat
                    //   strip's panel. Users now access related products
                    //   through the top strips, in a more focused way.)
                  ],
                ),
              ),
              // Pinned purchase bar — qty/unit/add-to-cart always reachable.
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: const Border(top: BorderSide(color: Color(0x14000000))),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _QtyStepper(
                          qty: _qty,
                          onChanged: (v) => setState(() => _qty = max(1, v)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _UnitToggle(
                            unit: _unit,
                            hasPack: p.qtyPack != null,
                            hasPallet: p.qtyPallet != null,
                            onChanged: (u) => setState(() => _unit = u),
                          ),
                        ),
                      ],
                    ),
                    if (_unit != _Unit.single)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'סה"כ ${_qty * _unitMult} יחידות',
                          style: const TextStyle(
                              color: Color(0xFF9AA3B2), fontSize: 12),
                        ),
                      ),
                    if (_accTotal > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const CfgText(
                                'lipskey_product_sheet.selected_accessories',
                                'אביזרים נבחרים:',
                                style: TextStyle(
                                    color: Colors.black38, fontSize: 13)),
                            Text('+ ₪$_accTotal',
                                style: const TextStyle(
                                    color: Color(0xFF3DD9B0),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: BsTokens.brand,
                          foregroundColor: const Color(0xFF1A1200),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _addToCart,
                        icon: const Icon(Icons.shopping_cart, size: 19),
                        label: const CfgText(
                            'lipskey_product_sheet.add_to_cart_btn',
                            'הוסף לסל',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    // #ai-spec-copilot — "is this OK for my conditions?" (verified
                    // temp verdict in Dart + Claude phrasing). Only when the product
                    // carries a verified spec (the verdict's source of truth).
                    if (kVerifiedSpecs.containsKey(p.sku)) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context)
                              .push(SpecCopilotScreen.route(p)),
                          icon: const Text('🌡️', style: TextStyle(fontSize: 15)),
                          label: const CfgText(
                              'lipskey_product_sheet.spec_copilot_cta',
                              'מתאים לתנאים שלי?',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                    // #ai-paired-explain — "what else does this install need?"
                    // Grounded on the real frequentlyPairedTypesFor(p) engine;
                    // gateway null (demo) → not in the tree → byte-identical.
                    Builder(builder: (context) {
                      final pairedTypes = frequentlyPairedTypesFor(p);
                      if (pairedTypes.isEmpty) return const SizedBox.shrink();
                      return Consumer(builder: (context, ref, _) {
                        if (ref.watch(claudeGatewayProvider) == null) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                  PairedExplainScreen.route(
                                      product: p.nameHe, types: pairedTypes)),
                              icon: const Text('🧩',
                                  style: TextStyle(fontSize: 15)),
                              label: const CfgText(
                                  'lipskey_product_sheet.paired_explain_cta',
                                  'מה עוד צריך להתקנה?',
                                  style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                        );
                      });
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── qty stepper ─────────────────────────────────────────────────────────────
class _QtyStepper extends StatelessWidget {
  const _QtyStepper({required this.qty, required this.onChanged});
  final int qty;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget b(String s, VoidCallback t) => InkWell(
          onTap: t,
          child: SizedBox(
              width: 38,
              height: 44,
              child: Center(
                  child: Text(s,
                      style: const TextStyle(
                          color: BsTokens.inkLight, fontSize: 20)))),
        );
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: BsTokens.brand),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          b('−', () => onChanged(qty - 1)),
          SizedBox(
              width: 34,
              child: Center(
                  child: Text('$qty',
                      style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontSize: 17,
                          fontWeight: FontWeight.w800)))),
          b('+', () => onChanged(qty + 1)),
        ],
      ),
    );
  }
}

// ── unit toggle: בודד / ארגז / משטח ──────────────────────────────────────────
class _UnitToggle extends StatelessWidget {
  const _UnitToggle({
    required this.unit,
    required this.hasPack,
    required this.hasPallet,
    required this.onChanged,
  });
  final _Unit unit;
  final bool hasPack;
  final bool hasPallet;
  final ValueChanged<_Unit> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget opt(String label, _Unit u, bool enabled) {
      final sel = unit == u;
      return Expanded(
        child: InkWell(
          onTap: enabled ? () => onChanged(u) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            color: sel ? BsTokens.brand : Colors.transparent,
            alignment: Alignment.center,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: sel
                        ? const Color(0xFF1A1200)
                        : (enabled
                            ? const Color(0xFF9AA3B2)
                            : const Color(0xFF44495A)),
                    fontWeight: sel ? FontWeight.w800 : FontWeight.w500)),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          opt('בודד', _Unit.single, true),
          opt('ארגז', _Unit.pack, hasPack),
          opt('משטח', _Unit.pallet, hasPallet),
        ],
      ),
    );
  }
}

// ── related product mini-card ────────────────────────────────────────────────
class _RelatedCard extends StatelessWidget {
  const _RelatedCard({required this.product, required this.onTap});
  final LipskeyCatalogProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 112,
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: const Color(0xFFEEEEEE)),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 56,
              child: product.imageAsset != null
                  ? productImage(product.imageAsset!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Center(
                          child: Text(product.typeEmoji,
                              style: const TextStyle(fontSize: 28))))
                  : Center(
                      child: Text(product.typeEmoji,
                          style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(height: 5),
            Flexible(
              child: Text(product.nameHe,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: BsTokens.inkLight, fontSize: 11, height: 1.25)),
            ),
            const SizedBox(height: 3),
            Text('#${product.sku}',
                style: const TextStyle(
                    color: Color(0xFF9AA3B2),
                    fontSize: 9,
                    fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }
}

// ── Hero flip card ────────────────────────────────────────────────────────────
class _HeroImage extends ConsumerStatefulWidget {
  const _HeroImage({
    required this.product,
    required this.screenH,
  });

  final LipskeyCatalogProduct product;
  final double screenH;

  @override
  ConsumerState<_HeroImage> createState() => _HeroImageState();
}

class _HeroImageState extends ConsumerState<_HeroImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  bool _showSpec = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _flip() {
    // A11Y: if reducedMotion is on, jump directly to the target face with no
    // rotation animation — the AnimatedBuilder still rebuilds but angle is 0/π.
    final reduced = ref.read(catalogSettingsProvider).reducedMotion;
    if (reduced) {
      _ctrl.value = _showSpec ? 0.0 : 1.0;
    } else if (_showSpec) {
      _ctrl.reverse();
    } else {
      _ctrl.forward();
    }
    setState(() => _showSpec = !_showSpec);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return SizedBox(
      height: widget.screenH * 0.30,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final angle = _anim.value * pi;
          final showingSpec = angle > pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showingSpec
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: _SpecSide(
                      product: p,
                      onFlip: _flip,
                      onZoom: () => _openFullscreenAsset(
                          context, p.specImageAsset, p.typeEmoji),
                    ),
                  )
                : _ProductSide(
                    product: p,
                    onFlip: _flip,
                    onZoom: () => _openFullscreenAsset(
                        context,
                        p.imageAsset ?? p.specImageAsset,
                        p.typeEmoji),
                  ),
          );
        },
      ),
    );
  }
}

class _ProductSide extends StatefulWidget {
  const _ProductSide({
    required this.product,
    required this.onFlip,
    required this.onZoom,
  });
  final LipskeyCatalogProduct product;
  final VoidCallback onFlip;
  final VoidCallback onZoom;

  @override
  State<_ProductSide> createState() => _ProductSideState();
}

class _ProductSideState extends State<_ProductSide> {
  int _i = 0;

  @override
  void didUpdateWidget(_ProductSide old) {
    super.didUpdateWidget(old);
    if (old.product.sku != widget.product.sku) _i = 0;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final imgs = product.imageAssets;
    final hasImg = imgs.isNotEmpty;
    final i = hasImg ? _i % imgs.length : 0;
    return GestureDetector(
      onTap: widget.onZoom, // tap image → fullscreen zoom
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.5,
                  colors: [
                    const Color(0xFF3D5A80).withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            productImage(
              hasImg ? imgs[i] : product.specImageAsset,
              fit: hasImg ? BoxFit.contain : BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Text(product.typeEmoji,
                    style: const TextStyle(fontSize: 72)),
              ),
            ),
            // multi-image pager (1/N) — only when there's more than one photo.
            if (imgs.length > 1)
              Positioned(
                top: 0,
                left: 0,
                child: Semantics(
                  button: true,
                  label: 'התמונה הבאה',
                  child: Tooltip(
                    message: 'התמונה הבאה',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () =>
                          setState(() => _i = (i + 1) % imgs.length),
                      // ≥48dp tap target around the small pager chip (a11y);
                      // Positioned 10→0 keeps the centred chip in place.
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(minWidth: 48, minHeight: 48),
                        child: Center(
                          widthFactor: 1,
                          heightFactor: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xCC1A1200),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${i + 1}/${imgs.length}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // zoom hint (top-right)
            const Positioned(
              top: 10,
              right: 10,
              child: _ZoomHint(),
            ),
            // PPRCT material badge (bottom-right) — helpful when the catalog
            // doesn't supply a distinct PPRCT product photo (pages 81-85 use
            // the matching PPR family image). Shows on PPR too if the user
            // wants symmetry — gated on material in dims.
            if (product.dims?['חומר']?.toString().contains('PPRCT') == true)
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A623D), // dark green
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const CfgText('lipskey_product_sheet.ppr_ct_badge',
                      'PPR-CT',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5)),
                ),
              ),
            // "פרטים / מפרט" button — flips to the spec page
            Positioned(
              bottom: 0,
              left: 10,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onFlip,
                // ≥48dp tap target (a11y); bottom 10→0 keeps the centred chip
                // in (roughly) the same visual spot.
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: BsTokens.brand,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.description_outlined,
                              color: Color(0xFF1A1200), size: 14),
                          SizedBox(width: 5),
                          CfgText('lipskey_product_sheet.details_spec',
                              'פרטים / מפרט',
                              style: TextStyle(
                                  color: Color(0xFF1A1200),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoomHint extends StatelessWidget {
  const _ZoomHint();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.zoom_in, color: Colors.black54, size: 14),
            SizedBox(width: 4),
            CfgText('lipskey_product_sheet.zoom',
                'הגדלה',
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

class _SpecSide extends StatefulWidget {
  const _SpecSide({
    required this.product,
    required this.onFlip,
    required this.onZoom,
  });
  final LipskeyCatalogProduct product;
  final VoidCallback onFlip;
  final VoidCallback onZoom;

  @override
  State<_SpecSide> createState() => _SpecSideState();
}

class _SpecSideState extends State<_SpecSide> {
  int _i = 0;

  @override
  void didUpdateWidget(_SpecSide old) {
    super.didUpdateWidget(old);
    if (old.product.sku != widget.product.sku) _i = 0;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final specs = product.specImageAssets;
    final i = _i % specs.length;
    return GestureDetector(
      onTap: widget.onZoom, // tap spec → fullscreen zoom
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Stack(
          fit: StackFit.expand,
          children: [
            productImage(
              specs[i],
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Center(
                child: Text(product.typeEmoji,
                    style: const TextStyle(fontSize: 72)),
              ),
            ),
            // multi-spec pager (1/N) — only when there's more than one image.
            if (specs.length > 1)
              Positioned(
                top: 0,
                left: 0,
                child: Semantics(
                  button: true,
                  label: 'המפרט הבא',
                  child: Tooltip(
                    message: 'המפרט הבא',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () =>
                          setState(() => _i = (i + 1) % specs.length),
                      // ≥48dp tap target around the small pager chip (a11y);
                      // Positioned 10→0 keeps the centred chip in place.
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(minWidth: 48, minHeight: 48),
                        child: Center(
                          widthFactor: 1,
                          heightFactor: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xCC1A1200),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${i + 1}/${specs.length}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // zoom hint
            const Positioned(top: 10, right: 10, child: _ZoomHint()),
            // back-to-product button
            Positioned(
              bottom: 0,
              left: 10,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onFlip,
                // ≥48dp tap target (a11y); bottom 10→0 keeps the centred chip
                // in (roughly) the same visual spot.
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: BsTokens.brand,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.image_outlined,
                              color: Color(0xFF1A1200), size: 14),
                          SizedBox(width: 5),
                          CfgText('lipskey_product_sheet.back_to_product',
                              'חזרה למוצר',
                              style: TextStyle(
                                  color: Color(0xFF1A1200),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stage row ─────────────────────────────────────────────────────────────────
class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.stage,
    required this.index,
    required this.isActive,
    required this.onTap,
  });

  final LipskeyCatStage stage;
  final int index;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? (stage.isFinal
                    ? BsTokens.success.withOpacity(0.12)
                    : const Color(0xFF3D5A80).withOpacity(0.2))
                : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? (stage.isFinal
                      ? BsTokens.success.withOpacity(0.6)
                      : const Color(0xFF64FFDA).withOpacity(0.5))
                  : const Color(0xFFEEEEEE),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: stage.isFinal
                      ? BsTokens.success.withOpacity(0.2)
                      : const Color(0xFF3D5A80).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text('${index + 1}',
                    style: TextStyle(
                        color: stage.isFinal
                            ? BsTokens.success
                            : const Color(0xFF64FFDA),
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              Text(stage.emoji,
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stage.label,
                        style: const TextStyle(
                            color: BsTokens.inkLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    if (isActive && stage.desc.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(stage.desc,
                          style: const TextStyle(
                              color: Colors.black38, fontSize: 12)),
                    ],
                  ],
                ),
              ),
              Icon(
                isActive
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: const Color(0xFF888888),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(
      {required this.emoji, required this.title, this.subtitle});
  final String emoji;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Text(emoji,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ),
            if (subtitle != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0xFF888888), fontSize: 11)),
              ),
            ],
          ],
        ),
      );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Divider(
      height: 1, color: Color(0xFFEEEEEE), indent: 20, endIndent: 20);
}

Widget _SpecRow(String emoji, String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(label,
                style: const TextStyle(
                    color: Colors.black38, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          // Wrap long values (e.g. dims מידות / תיאור) instead of overflowing
          // the Row — short values still right-align identically to before.
          Expanded(
            child: Text(value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                    color: BsTokens.inkLight, fontSize: 13)),
          ),
        ],
      ),
    );

/// Four expandable info strips for the product sheet — מאתר · תאימות ·
/// ערכת התקנה · דומים. Each strip stays compact by default and pulls its
/// payload INTO the card when the user taps it (no navigation, no snackbars,
/// no scrolling) — the data is rendered right below the row. Only one strip
/// is open at a time; tapping the open strip closes it.
class _QuickInfoStrips extends ConsumerStatefulWidget {
  const _QuickInfoStrips({
    required this.product,
    required this.onPickProduct,
  });

  final LipskeyCatalogProduct product;

  /// Called when the user picks a product from any of the expanded panels.
  /// The product sheet swaps the displayed product to the picked one without
  /// closing the sheet — same UX as the existing brand-variant chips.
  final void Function(LipskeyCatalogProduct) onPickProduct;

  @override
  ConsumerState<_QuickInfoStrips> createState() => _QuickInfoStripsState();
}

enum _StripKind { finder, compat, complements, kit, variants, compliance, spec, price, info, hygiene }

/// Socket-fusion welding plan per nominal diameter (catalog p.9):
/// (insertion depth mm, heating sec, cooling min). Plate temp 260°C.
const _kPprWeldPlan = <String, (double, int, int)>{
  '20': (14.5, 8, 2),
  '25': (16.0, 11, 2),
  '32': (18.0, 12, 4),
  '40': (20.5, 18, 4),
  '50': (23.5, 27, 4),
  '63': (27.5, 36, 6),
  '75': (30.0, 45, 8),
  '90': (33.0, 60, 8),
  '110': (37.0, 75, 8),
  '125': (40.0, 90, 8),
};

/// Weld-plan lookup key for a PPR pipe: its nominal/outer diameter as a bare
/// string ('20','25',…). Polyroll PPR pipes carry it under 'קוטר חיצוני'
/// (supply + faser) or 'dn נומינלי' (faser p.708). W1 fix: the lookup read only
/// 'dn נומינלי', so the weld plan vanished for every pipe keyed on 'קוטר חיצוני'.
/// Pinned by test/ppr_weld_dn_test.dart.
String? pprWeldDn(Map<String, dynamic>? dims) =>
    (dims?['dn נומינלי'] ?? dims?['קוטר חיצוני'])?.toString();

/// One-line summary of a unified install-kit (smart-tree + auto-derived
/// tools): "3 חובה · 2 אופציה · 4 כלים", omitting any zero segment.
String _formatKitSummary(({int must, int optional, int tools}) k) {
  final parts = <String>[];
  if (k.must > 0) parts.add('${k.must} חובה');
  if (k.optional > 0) parts.add('${k.optional} אופציה');
  if (k.tools > 0) parts.add('${k.tools} כלים');
  return parts.join(' · ');
}

/// Compact spec one-liner for the strip header (the expanded panel shows
/// the full breakdown): "פליז · 90°C · ½""
String _formatSpecValue(
    ({
      String material,
      String? pressureRating,
      double maxTempC,
      String waterSystem,
      String endsSummary,
      double? minBoreMm,
    }) s) {
  final parts = <String>[s.material, '${s.maxTempC.toStringAsFixed(0)}°C'];
  if (s.pressureRating != null) parts.add(s.pressureRating!);
  return parts.join(' · ');
}

class _QuickInfoStripsState extends ConsumerState<_QuickInfoStrips> {
  _StripKind? _open;

  // Per-product memo of the engine-derived strip facts. Each of these is an
  // O(catalog)-scale sweep (compatibleProductsCount ≈ O(855); installKitFor +
  // variantSiblingsCountFor touch the whole catalog), so recomputing them on
  // every build() — including each settings change watched in the price strip —
  // was pure waste. They depend ONLY on the product, so we cache them keyed on
  // sku and recompute only when the parent swaps to a different product. Byte-
  // identical to calling the helpers inline (same pure inputs → same outputs).
  String? _factsSku;
  late ({String emoji, String label})? _finder;
  late int _compat;
  late ({int must, int optional, int tools})? _kit;
  late int _famCount;
  late List<({String label, String reason})> _compliance;
  late ({
    String material,
    String? pressureRating,
    double maxTempC,
    String waterSystem,
    String endsSummary,
    double? minBoreMm,
  })? _spec;
  late List<LipskeyCatalogProduct> _companyComplements;

  /// Recompute the cached per-product facts when [p] differs from the cached
  /// product (or on first build). Same single source as the inline calls.
  void _ensureFacts(LipskeyCatalogProduct p) {
    if (_factsSku == p.sku) return;
    _factsSku = p.sku;
    _finder = finderGroupFor(p);
    _compat = compatibleProductsCount(p);
    _kit = installKitFor(p);
    _famCount = variantSiblingsCountFor(p);
    _compliance = complianceTriggersFor(p);
    _spec = engineeringSpecFor(p);
    // Company template column 'מוצרים משלימים' resolved against the live
    // universe — const [] on demo (no product carries the column), so the
    // demo strips render byte-identical.
    _companyComplements = companyComplementsFor(p, resolvedCatalogProducts);
  }

  @override
  void didUpdateWidget(covariant _QuickInfoStrips oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the parent swaps to a different product, collapse any open panel
    // so the user always sees the four strips of the new product first.
    if (oldWidget.product.sku != widget.product.sku) {
      _open = null;
    }
  }

  void _toggle(_StripKind k) =>
      setState(() => _open = _open == k ? null : k);

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    _ensureFacts(p);
    final finder = _finder;
    final compat = _compat;
    final kit = _kit;
    final famCount = _famCount;

    final rows = <_StripDef>[
      if (finder != null)
        _StripDef(
          kind: _StripKind.finder,
          emoji: finder.emoji,
          // finder.emoji is a plumbing glyph (🚰🚽🕳️…) canvaskit can't draw —
          // render a "finder" Material icon instead (see I1-followup).
          icon: Icons.travel_explore,
          label: 'נמצא ב',
          value: finder.label,
          tint: const Color(0xFF3DD9B0),
        ),
      if (compat > 0)
        _StripDef(
          kind: _StripKind.compat,
          emoji: '🤝',
          label: 'מוצרים תואמים',
          value: '$compat מוצרים',
          tint: const Color(0xFF7FD0FF),
        ),
      // The company's OWN declared complements (template column 'מוצרים
      // משלימים') — only on an active company catalog whose skus resolved;
      // on demo companyCatalogActive is false, so the rows are unchanged.
      if (companyCatalogActive && _companyComplements.isNotEmpty)
        _StripDef(
          kind: _StripKind.complements,
          emoji: '🧩',
          label: 'מוצרים משלימים',
          value: '${_companyComplements.length} מוצרים',
          tint: const Color(0xFFEC4899),
        ),
      if (kit != null)
        _StripDef(
          kind: _StripKind.kit,
          emoji: '📦',
          label: 'ערכת התקנה',
          value: _formatKitSummary(kit),
          tint: const Color(0xFFFF9D4D),
        ),
      if (famCount > 1)
        _StripDef(
          kind: _StripKind.variants,
          emoji: '🔄',
          label: 'דומים',
          value: '$famCount וריאנטים',
          tint: const Color(0xFFC9A7FF),
        ),
      // ── New strips: compliance · engineering spec · price ─────────
      if (_compliance.isNotEmpty)
        _StripDef(
          kind: _StripKind.compliance,
          emoji: '🛡',
          label: 'תקינות',
          value: '${_compliance.length} דרישות',
          tint: BsTokens.danger,
        ),
      if (_spec != null)
        _StripDef(
          kind: _StripKind.spec,
          emoji: '📊',
          label: 'מפרט הנדסי',
          value: _formatSpecValue(_spec!),
          tint: const Color(0xFF8B5CF6),
        ),
      if (priceFor(p) != null)
        _StripDef(
          kind: _StripKind.price,
          emoji: '💰',
          // Estimated price honours the catalog price settings: VAT-inclusive
          // (×1.17) when "כולל מע\"מ" is on + the chosen currency symbol, and a
          // "ליחידה" suffix when "הצגת מחיר ליחידה" is on (the catalog ballpark
          // is a per-unit figure).
          label: 'מחיר משוער',
          value: () {
            final s = ref.watch(catalogSettingsProvider);
            final base = formatCatalogPrice(priceFor(p)!, s, prefix: '~');
            return s.showUnitPrice ? '$base ליחידה' : base;
          }(),
          tint: BsTokens.success,
        ),
      if (p.brand == 'פולירול')
        _StripDef(
          kind: _StripKind.info,
          emoji: 'ℹ️',
          label: 'מידע כללי',
          value: 'צנרת PPR · יתרונות',
          tint: const Color(0xFF3B82F6),
        ),
      if (p.brand == 'פולירול')
        _StripDef(
          kind: _StripKind.hygiene,
          emoji: '🧼',
          label: 'חיטוי וניקוי',
          value: 'בור חלק · ללא אבנית',
          tint: const Color(0xFF06B6D4),
        ),
      if (p.brand == 'חוליות')
        _StripDef(
          kind: _StripKind.info,
          emoji: 'ℹ️',
          label: 'מידע כללי',
          value: 'SmartLock™ · דלוחין PP · 32-63 מ"מ',
          tint: const Color(0xFF14764A),
        ),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            _StripRow(
              def: rows[i],
              open: _open == rows[i].kind,
              onTap: () => _toggle(rows[i].kind),
            ),
            if (_open == rows[i].kind)
              _StripPanel(
                kind: rows[i].kind,
                product: p,
                tint: rows[i].tint,
                onPickProduct: widget.onPickProduct,
              ),
            if (i < rows.length - 1)
              const Divider(
                height: 1,
                thickness: 0.7,
                color: Color(0xFFF1F1F1),
                indent: 12,
                endIndent: 12,
              ),
          ],
        ],
      ),
    );
  }
}

class _StripDef {
  const _StripDef({
    required this.kind,
    required this.emoji,
    required this.label,
    required this.value,
    required this.tint,
    this.icon,
  });
  final _StripKind kind;
  final String emoji;
  final String label;
  final String value;
  final Color tint;
  // When set, the strip renders this Material icon instead of [emoji] — used
  // where the emoji is a glyph canvaskit's bundled font can't draw (e.g. the
  // finder group emoji 🚰🚽🕳️, which showed as an empty box).
  final IconData? icon;
}

class _StripRow extends StatefulWidget {
  const _StripRow({
    required this.def,
    required this.open,
    required this.onTap,
  });
  final _StripDef def;
  final bool open;
  final VoidCallback onTap;

  @override
  State<_StripRow> createState() => _StripRowState();
}

class _StripRowState extends State<_StripRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.def;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: widget.open
            ? d.tint.withValues(alpha: 0.12)
            : (_pressed
                ? d.tint.withValues(alpha: 0.18)
                : Colors.transparent),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: d.tint.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: d.icon != null
                  ? Icon(d.icon, size: 16, color: d.tint)
                  : Text(d.emoji, style: const TextStyle(fontSize: 15)),
            ),
            const SizedBox(width: 10),
            Text(
              '${d.label}:',
              style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                d.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            AnimatedRotation(
              turns: widget.open ? 0.25 : 0,
              duration: const Duration(milliseconds: 150),
              child:
                  Icon(Icons.chevron_left, size: 16, color: d.tint),
            ),
          ],
        ),
      ),
    );
  }
}

/// True when [sku]'s spec was bridged from a company import (kCompanySpecSkus)
/// rather than hand-verified — spec-derived panels then get a 'לפי נתוני היבוא'
/// header so imported data never reads as verified. The set is empty until a
/// company import runs, so the demo renders byte-identical.
bool _isCompanySpec(String sku) => kCompanySpecSkus.contains(sku);

/// The data payload that opens beneath a strip when it's tapped. Each kind
/// pulls its content from the matching helper (related_info.dart / smart-tree
/// / variant-families) and renders it as a compact horizontal carousel of
/// mini cards, or — for ערכת התקנה — a vertical list of accessory rows.
class _StripPanel extends StatelessWidget {
  const _StripPanel({
    required this.kind,
    required this.product,
    required this.tint,
    required this.onPickProduct,
  });

  final _StripKind kind;
  final LipskeyCatalogProduct product;
  final Color tint;
  final void Function(LipskeyCatalogProduct) onPickProduct;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
      color: tint.withValues(alpha: 0.05),
      child: switch (kind) {
        _StripKind.finder => _buildFinder(),
        _StripKind.compat => _buildCompat(),
        _StripKind.complements => _buildComplements(),
        _StripKind.kit => _buildKit(),
        _StripKind.variants => _buildVariants(),
        _StripKind.compliance => _buildCompliance(),
        _StripKind.spec => _buildSpec(),
        _StripKind.price => _buildPrice(context),
        _StripKind.info => _buildInfo(),
        _StripKind.hygiene => _buildHygiene(),
      },
    );
  }

  // ── מאתר: other products in the same layman finder group ──────────────────
  Widget _buildFinder() {
    final f = finderGroupFor(product);
    if (f == null) {
      return const _EmptyHint('אין קבוצה');
    }
    // We re-use the existing _kFinderGroups indirectly: a product belongs to
    // the same finder group when its layman label matches. So pull every
    // product whose finderGroupFor() has the same label.
    final peers = _scanPool
        .where((q) =>
            q.sku != product.sku && finderGroupFor(q)?.label == f.label)
        .take(20)
        .toList();
    if (peers.isEmpty) return const _EmptyHint('אין מוצרים אחרים בקבוצה');
    return _miniCarousel(peers);
  }

  // ── תאימות: only products that BOTH mate with the source AND add at least
  // one new connection option. Filters out trivial duplicates (e.g. another
  // HDPE 32×25 coupling that just shares the same pipe size without giving
  // any new endpoint), so the carousel shows truly completing parts.
  Widget _buildCompat() {
    if (kVerifiedSpecs[product.sku] == null) {
      return const _EmptyHint('אין מפרט תואם');
    }
    final hits = compatibleProductsFor(product).take(20).toList();
    if (hits.isEmpty) {
      return const _EmptyHint('לא נמצאו מוצרים שמשלימים את הקצוות');
    }
    final carousel = _miniCarousel(hits,
        labelFor: (q) => connectionExplainHe(product, q));
    // Import-bridged spec → title the section honestly; a hand-verified spec
    // renders exactly as before (kCompanySpecSkus is empty without an import).
    if (!_isCompanySpec(product.sku)) return carousel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_infoHead('לפי נתוני היבוא'), carousel],
    );
  }

  // ── מוצרים משלימים: the company's OWN declared complements — the template
  // column 'מוצרים משלימים' (|-separated skus) resolved against the live
  // universe. The strip only exists when the list is non-empty, so the hint
  // is a stale-panel guard only.
  Widget _buildComplements() {
    final hits = companyComplementsFor(product, resolvedCatalogProducts);
    if (hits.isEmpty) return const _EmptyHint('אין מוצרים משלימים');
    return _miniCarousel(hits);
  }

  // ── ערכת התקנה: smart-tree accessories + auto-derived install tools ─────
  // Two data sources merged into one view:
  //  1. smart-tree (smartProductForSku): manually-curated product-specific
  //     accessories (gaskets, silicone, brand-specific parts)
  //  2. install_kit (recommendedKitForProduct): tools and sealants derived
  //     automatically from the product's actual connector ends — wrenches
  //     sized to the BSP threads, compression-nut wrench for HDPE ends, etc.
  Widget _buildKit() {
    final sp = smartProductForSku(product.sku);
    final tools = recommendedKitForProduct(product);
    final isPpr = product.brand == 'פולירול';
    final dn = pprWeldDn(product.dims);
    final weld = isPpr ? _kPprWeldPlan[dn] : null;
    if ((sp == null || sp.acc.isEmpty) && tools.isEmpty && !isPpr) {
      return const _EmptyHint('אין רשימת ערכת התקנה');
    }

    final must = sp?.acc.where((a) => a.must).toList() ?? const [];
    final opt = sp?.acc.where((a) => !a.must).toList() ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (must.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
            child: CfgText('lipskey_product_sheet.must_smart_tree',
                'חובה (עץ חכם)',
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: Color(0xFFCC6614),
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
          for (final a in must) _accRow(a, true),
        ],
        if (opt.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 8, 4, 4),
            child: CfgText('lipskey_product_sheet.optional_smart_tree',
                'אופציונלי (עץ חכם)',
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
          for (final a in opt) _accRow(a, false),
        ],
        if (tools.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 8, 4, 4),
            child: CfgText('lipskey_product_sheet.tools_auto',
                'כלים ואיטומים (אוטומטי)',
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: Color(0xFF7FD0FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
          for (final k in tools) _kitRow(k),
        ],
        if (isPpr) ...[
          _infoHead('תוכנית ריתוך-שקע (פלטה 260°C)'),
          if (weld != null)
            _infoBullet(
                '⌀$dn: עומק ${weld.$1} מ"מ · חימום ${weld.$2} שנ׳ · קירור ${weld.$3} דק׳'),
          _infoBullet('ודא פלטה ב-260°C ותותבים מחוזקים'),
          _infoBullet('הכנס צינור ואביזר לתותבים (נקבה+זכר)'),
          _infoBullet('חמם לפי הזמן בטבלה, שלוף וחבר מיד עד הסימון'),
          _infoBullet('החזק מחוברים ללא סיבוב עד התקררות'),
        ],
      ],
    );
  }

  Widget _kitRow(KitItem k) {
    final tagColor = switch (k.kind) {
      KitKind.tool => const Color(0xFF7FD0FF),
      KitKind.sealant => const Color(0xFF3DD9B0),
      KitKind.safety => BsTokens.danger,
    };
    final tagLabel = switch (k.kind) {
      KitKind.tool => 'כלי',
      KitKind.sealant => 'איטום',
      KitKind.safety => 'בטיחות',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: tagColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(tagLabel,
                style: TextStyle(
                    color: tagColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(k.label,
                    style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                Text(k.reason,
                    style: const TextStyle(
                        color: Color(0xFF888888), fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _accRow(SmartAcc a, bool must) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
      child: Row(
        children: [
          Text(a.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(a.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
          if (must)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const CfgText('lipskey_product_sheet.must_badge', 'חובה',
                  style: TextStyle(
                      color: Color(0xFFCC4A14),
                      fontSize: 9,
                      fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  // ── דומים: variant siblings (same canonical family, different attribute) ──
  Widget _buildVariants() {
    final siblings = variantSiblingsOf(product)
        .where((q) => q.sku != product.sku)
        .take(20)
        .toList();
    if (siblings.isEmpty) return const _EmptyHint('אין וריאנטים נוספים');
    return _miniCarousel(siblings);
  }

  // ── תקינות: what compliance items this product triggers ────────────────
  Widget _buildCompliance() {
    final triggers = complianceTriggersFor(product);
    if (triggers.isEmpty) return const _EmptyHint('אין דרישות תקינות מיוחדות');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final t in triggers)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: BsTokens.danger.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const CfgText(
                      'lipskey_product_sheet.must_badge_compliance', 'חובה',
                      style: TextStyle(
                          color: BsTokens.danger,
                          fontSize: 9,
                          fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.label,
                          style: const TextStyle(
                              color: BsTokens.inkLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                      Text(t.reason,
                          style: const TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 10,
                              height: 1.3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── מפרט הנדסי: material · pressure · temp · system · ends · bore ─────
  Widget _buildSpec() {
    final s = engineeringSpecFor(product);
    if (s == null) return const _EmptyHint('אין מפרט הנדסי מאומת');
    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
          child: Row(
            children: [
              Text('$label:',
                  style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(value,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace')),
              ),
            ],
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Import-bridged spec → header says so; hand-verified: unchanged.
        if (_isCompanySpec(product.sku)) _infoHead('לפי נתוני היבוא'),
        row('חומר', s.material),
        if (s.pressureRating != null) row('דירוג לחץ', s.pressureRating!),
        if ((product.dims?['לחץ עבודה (50 שנה)'] as String?)?.isNotEmpty ?? false)
          row('לחץ עבודה', product.dims!['לחץ עבודה (50 שנה)'] as String),
        row('טמפ\' מקס\'', '${s.maxTempC.toStringAsFixed(0)}°C'),
        row('מערכת', s.waterSystem),
        if (s.minBoreMm != null)
          row(
              'קוטר פנימי',
              '${s.minBoreMm! == s.minBoreMm!.roundToDouble() ? s.minBoreMm!.toStringAsFixed(0) : s.minBoreMm!.toStringAsFixed(1)} mm'),
        row('קצוות חיבור', s.endsSummary),
      ],
    );
  }

  Widget _infoBullet(String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Text('• $t',
            textAlign: TextAlign.right,
            style: const TextStyle(
                color: BsTokens.inkLight, fontSize: 11.5, height: 1.35)),
      );

  Widget _infoHead(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 2),
        child: Text(t,
            textAlign: TextAlign.right,
            style: TextStyle(
                color: tint, fontSize: 12, fontWeight: FontWeight.w800)),
      );

  // ── מידע כללי: מבנה רב-שכבתי + חומר גלם + יתרונות (מהקטלוג, עמ' 77) ───────
  Widget _buildInfo() {
    if (product.brand == 'חוליות') return _buildInfoHuliot();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: productImage('assets/polyroll/products/ppr_green_system.jpg',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink()),
        ),
        const SizedBox(height: 2),
        const CfgText('lipskey_product_sheet.ppr_caption',
            'צנרת PPR לאספקת מים חמים וקרים',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF888888), fontSize: 10.5)),
        _infoHead('חומר גלם'),
        _infoBullet('אביזרים: PPR'),
        _infoBullet('אביזרי תבריג: PPR + פליז DZR'),
        _infoHead('יתרונות'),
        _infoBullet('הצנרת היחידה לאספקת מים ההומוגנית בכל חלקיה לאחר ריתוך'),
        _infoBullet('אין קורוזיה ואין הצטברות אבנית בכל חלקי המערכת'),
        _infoBullet('מקדם חיכוך נמוך ביותר — נשארת נקייה לאורך שנים'),
        _infoBullet('אין הקטנת קוטר בצינורות ובאביזרים לאחר החיבור'),
        _infoBullet('עמידות מצוינת וארוכת טווח בלחצים גבוהים'),
        _infoBullet('רמת אקוסטיקה גבוהה'),
        _infoBullet('צנרת קלה ונוחה לעבודה, מגוון אביזרים רחב'),
        _infoBullet('מחברי הברגה מפליז DZR לסביבה קורוזיבית'),
      ],
    );
  }

  // ── מידע כללי — חוליות SmartLock (מהקטלוג, עמ' 5-6 verbatim) ─────────────
  Widget _buildInfoHuliot() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CfgText(
            'lipskey_product_sheet.smartlock_caption',
            'SMART LOCK — מערכת דלוחין, צנרת ואביזרים מפוליפרופילן בקטרים 32-63 מ"מ בצבע שחור',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF888888), fontSize: 10.5)),
        _infoHead('חומר גלם'),
        _infoBullet('צינור רב שכבתי PPML-MD-S16'),
        _infoBullet('שכבה חיצונית: פוליפרופילן שחור — מעכבת קרני UV'),
        _infoBullet(
            'שכבה אמצעית: פוליפרופילן עם תרכובת מינרלית PPMD — בידוד אקוסטי'),
        _infoBullet(
            'שכבה פנימית: פוליפרופילן לבן — מאפשרת ניטור ובקרה חזותיים'),
        _infoBullet('אביזרים: PPMD PP'),
        _infoBullet('שיטת חיבור: נעילת שיניים - ראטצ\'ט'),
        _infoBullet('אטם מערכת: אטם לחץ אלסטומרי TPE'),
        _infoHead('יתרונות'),
        _infoBullet('התקנה מהירה ופשוטה, אטם אינטגרלי באביזר'),
        _infoBullet('אטם עמיד לאורך זמן'),
        _infoBullet('חוזק טבעתי גבוה'),
        _infoBullet('עמידות כימית גבוהה'),
        _infoBullet('קשיחות ויציבות גבוהים'),
        _infoBullet('עמידות בפני פגיעות מכניות'),
        _infoBullet('מודול אלסטיות ואימפקט גבוה'),
        _infoBullet('פנים צינור חלק מאפשר זרימה נקיה'),
        _infoBullet('תוצאות צילום חדות במיוחד'),
        _infoBullet('מיוצר בישראל · בעל תו תקן ישראלי'),
        _infoBullet('קיימות (אורך חיים) ל-100 שנה'),
        _infoBullet('שימוש בצינורות חלקים'),
        _infoBullet(
            'אין צורך בהכנת פאזה לצינור (נדרש לנקות גראדים) · אין צורך בשימוש בחומרי סיכה'),
        _infoBullet('צנרת אקוסטית להפחתת רעש'),
        _infoBullet('צנרת עמידה בעומסי כבידה ללא היווצרות בטן'),
        _infoBullet('עמידות בתנאי מזג אויר קשים'),
        _infoHead('תקינות'),
        _infoBullet('ת"י 958-1 — היתר 737 (צנרת PP לסילוק שפכים חמים)'),
        _infoBullet('ת"י 71253-1 — היתר 114782 (מחסום ריחות מפלסטיק לרצפה)'),
        _infoBullet('ת"י 71253-2 (מאסף מפלסטיק לרצפה ברצפה)'),
        _infoBullet(
            'ת"י 5694 — היתר 114783 (אביזרי ניקוז לאמבט, מחסומים גלויה וסיפונים)'),
        _infoBullet('ת"י 14020 — היתר 70304 (תו ירוק למוצרי PP)'),
        _infoBullet('תקן בינלאומי EN-1451 · DIN 8078 · ISO 180'),
        _infoHead('התקנה כללית (עמ\' 8)'),
        _infoBullet('1. הכנס את הצינור* או האביזר עד למעצור (*ללא גראדים)'),
        _infoBullet('2. הדק את האום עד לנעילת השיניים'),
        _infoHead('התקנת מתאם זווית - ג\'וקר'),
        _infoBullet(
            '1. הכנס את גוף הג\'וקר לאביזר הנדרש, ללא הידוק חיבור הסמארטלוק'),
        _infoBullet('2. השחל את האום והאטם הכדורי על הצינור'),
        _infoBullet(
            '3. קבע את הזווית הרצויה במחבר הג\'וקר והדק את אום הג\'וקר'),
        _infoBullet('4. הדק את אביזר הסמארט לוק'),
        _infoHead('התקנת פקק במחסום/מאסף (עמ\' 9)'),
        _infoBullet(
            'הכנס את הפקק שהמילה UP נמצאת בחלקו העליון וידית האחיזה נמצאת במצב אנכי'),
        _infoBullet('הדק את האום עד נעילת השיניים'),
        _infoHead('התקנה ידנית של האום'),
        _infoBullet(
            '⚠️ האביזרים מגיעים כשהאומים מורכבים עליהם ומוכנים להתקנה. במצב שבו האום מופרד מהאביזר יכול להתקיים רק על ידי פתיחה מכוונת'),
        _infoBullet(
            'כוון את החץ הירוק שעל האום מול השן הגדולה באביזר ← הברג את האום עד לשמיעת הקליק (מעבר מעל השן הגדולה)'),
        _infoHead('חיטוי וניקוי'),
        _infoBullet(
            'תכונות הניקיון נובעות משכבה פנימית פוליפרופילן לבן חלקה ⇒ ללא הצטברות זרימה חופשית'),
        _infoBullet('לא נדרש חיטוי שוטף — שטיפה במים בלבד ברוב המקרים'),
      ],
    );
  }

  // ── חיטוי וניקוי: תכונות הניקיון של הצנרת (מהקטלוג, עמ' 77) ──────────────
  Widget _buildHygiene() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _infoBullet('שתי צורות חיטוי למערכות פולירול: תרמי וכימי'),
        _infoHead('חיטוי תרמי'),
        _infoBullet('70°C למשך 30 דק׳ (טיפול בלגיונלה)'),
        _infoBullet('ניתן בטמפ׳ גבוהה יותר לפי הטבלאות — ללא חריגה מהמרבי'),
        _infoHead('חיטוי כימי'),
        _infoBullet('כלור חופשי 50 מ"ג/ל׳ מעל 12 שעות — פעמיים בשנה'),
        _infoBullet('חלופה: מי חמצן (H2O2) 150 מ"ג/ל׳ למשך 24 שעות'),
        _infoBullet('טמפ׳ עד 30°C בזמן החיטוי הכימי'),
        _infoHead('אזהרות (חוליות)'),
        _infoBullet('אסור לבצע חיטוי תרמי וכימי בו-זמנית'),
        _infoBullet('אסור שימוש בכלור דיאוקסיד במערכות PPR'),
        _infoBullet('חיטוי בכלור עלול לקצר את אורך חיי הצנרת'),
      ],
    );
  }

  // ── מחיר: category-level ballpark with disclaimer ───────────────────────
  Widget _buildPrice(BuildContext context) {
    final base = priceFor(product);
    if (base == null) {
      return const _EmptyHint('אין הערכת מחיר לקטגוריה זו');
    }
    // Honour the price settings: VAT-inclusive amount (×1.17) when on + the
    // chosen currency symbol. (No FX conversion — local display symbol only.)
    // _StripPanel is a StatelessWidget, so read settings via an inline Consumer.
    return Consumer(builder: (context, ref, _) {
      final s = ref.watch(catalogSettingsProvider);
      final price = priceWithVat(base, showVat: s.showVat);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              children: [
                Text('~${currencySymbol(s.currency)}',
                    style: TextStyle(
                        color: bsSuccess(context),
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                Text('$price',
                    style: TextStyle(
                        color: bsSuccess(context),
                        fontSize: 28,
                        fontWeight: FontWeight.w900)),
                if (s.showUnitPrice) ...[
                  const SizedBox(width: 6),
                  CfgText('lipskey_product_sheet.per_unit',
                      'ליחידה',
                      style: TextStyle(
                          color: bsSuccess(context).withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ],
                const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const CfgText('lipskey_product_sheet.estimate_badge',
                    'הערכה',
                    style: TextStyle(
                        color: Color(0xFFCC9114),
                        fontSize: 9,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: CfgText(
                'lipskey_product_sheet.price_note',
                'הערכה לפי קטגוריה — מחיר אמיתי תלוי בספק, מותג ומידה ספציפית.',
                style: TextStyle(
                    color: Color(0xFF888888), fontSize: 10, height: 1.4)),
          ),
        ],
      );
    });
  }

  /// Horizontal product strip. When [labelFor] is supplied and returns a
  /// non-empty string for an item, a small teal "🔗 …" chip is rendered under
  /// the name explaining HOW that product connects (used by the תאימות strip).
  Widget _miniCarousel(List<LipskeyCatalogProduct> items,
      {String Function(LipskeyCatalogProduct)? labelFor}) {
    final hasLabels = labelFor != null;
    return SizedBox(
      height: hasLabels ? 146 : 124,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final q = items[i];
          final label = labelFor?.call(q) ?? '';
          return GestureDetector(
            onTap: () => onPickProduct(q),
            child: Container(
              width: 100,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(color: const Color(0xFFEEEEEE)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 44,
                    child: q.imageAsset != null
                        ? productImage(q.imageAsset!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Center(
                                child: Text(q.typeEmoji,
                                    style: const TextStyle(fontSize: 24))))
                        : Center(
                            child: Text(q.typeEmoji,
                                style: const TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(height: 3),
                  Expanded(
                    child: Text(q.nameHe,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: BsTokens.inkLight,
                            fontSize: 10,
                            height: 1.2)),
                  ),
                  if (label.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F4F1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text('🔗 $label',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              color: Color(0xFF0F766E),
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text('#${q.sku}',
                      style: const TextStyle(
                          color: Color(0xFF9AA3B2),
                          fontSize: 8,
                          fontFamily: 'monospace')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
        child: Text(text,
            textAlign: TextAlign.right,
            style: const TextStyle(
                color: Color(0xFF9AA3B2),
                fontSize: 11,
                fontStyle: FontStyle.italic)),
      );
}

/// Interactive attribute chips (צעד 71+).
/// All four chip kinds use frame-based sibling detection:
/// orange border = has same-frame siblings with a different attribute value.
class _InteractiveChips extends StatelessWidget {
  const _InteractiveChips({
    required this.product,
    required this.openPickerKey,
    required this.onChipTap,
    required this.onVariantSelect,
  });

  final LipskeyCatalogProduct product;
  final String? openPickerKey; // 'type' | 'subtype' | 'model' | 'color'
  final void Function(String key) onChipTap;
  final void Function(LipskeyCatalogProduct) onVariantSelect;

  static const _colorModifiers = {'מוברש', 'מט'};

  // ── צבע: frame-based (אותו סוג, צבע שונה) ───────────────────────────────
  static String _colorFrame(LipskeyCatalogProduct p) => p.nameHe
      .split(RegExp(r'\s+'))
      .where((w) => kindOf(w) != AttrKind.color && !_colorModifiers.contains(w))
      .join(' ');

  static List<LipskeyCatalogProduct> _variantsColor(LipskeyCatalogProduct p) {
    final frame = _colorFrame(p);
    final seen = <String>{};
    final all = <LipskeyCatalogProduct>[];
    // stage-3.1 — follows the ACTIVE catalog source (v2-aware).
    for (final q in resolvedCatalogProducts) {
      if (q.categoryHe != p.categoryHe) continue;
      final v = q.colorVariant;
      if (v == null || v.isEmpty) continue;
      if (_colorFrame(q) != frame) continue;
      if (seen.add(v)) all.add(q);
    }
    all.sort((a, b) {
      if (a.sku == p.sku) return -1;
      if (b.sku == p.sku) return 1;
      return (a.colorVariant ?? '').compareTo(b.colorVariant ?? '');
    });
    return all;
  }

  // ── תת-סוג: frame-based (אותו סוג, תת-סוג שונה) ─────────────────────────
  static List<LipskeyCatalogProduct> _variantsSubtype(
      LipskeyCatalogProduct p) {
    const kind = AttrKind.subtype;
    final frame = p.nameHe
        .split(RegExp(r'\s+'))
        .where((w) => kindOf(w) != kind)
        .join(' ');
    final seen = <String>{};
    final all = <LipskeyCatalogProduct>[];
    for (final q in resolvedCatalogProducts) {
      if (q.categoryHe != p.categoryHe) continue;
      final v = variantValue(q, kind);
      if (v.isEmpty) continue;
      if (q.nameHe
              .split(RegExp(r'\s+'))
              .where((w) => kindOf(w) != kind)
              .join(' ') !=
          frame) continue;
      if (seen.add(v)) all.add(q);
    }
    all.sort((a, b) {
      if (a.sku == p.sku) return -1;
      if (b.sku == p.sku) return 1;
      return variantValue(a, kind).compareTo(variantValue(b, kind));
    });
    return all;
  }

  // ── סוג מורכב: multi-word types first, then type+qualifier ──────────────
  static String _resolveCompoundType(LipskeyCatalogProduct p) {
    final name = p.nameHe;
    final words = name.split(RegExp(r'\s+'));

    // Multi-word types matched as substring (longest first).
    final multiWord = kLipskeyTypes.where((t) => t.contains(' ')).toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final t in multiWord) {
      if (name.contains(t)) return t;
    }

    // Single-word type + optional trailing qualifier.
    for (final typeWord in kLipskeyTypes) {
      if (typeWord.contains(' ')) continue;
      final idx = words.indexOf(typeWord);
      if (idx < 0) continue;
      if (idx + 1 >= words.length) return typeWord;
      final next = words[idx + 1];
      if (kindOf(next) != null) return typeWord;
      if (_colorModifiers.contains(next)) return typeWord;
      if (next.length > 2 &&
          (next.startsWith('ל') || next.startsWith('ב'))) return typeWord;
      return '$typeWord $next';
    }
    return '';
  }

  // ── סוג: category-wide (כל הסוגים בקטגוריה, כמו findTypeSiblings) ────────
  static List<LipskeyCatalogProduct> _variantsType(LipskeyCatalogProduct p) {
    final compound = _resolveCompoundType(p);
    if (compound.isEmpty) return [];
    final byCompound = <String, LipskeyCatalogProduct>{compound: p};
    for (final q in resolvedCatalogProducts) {
      if (q.categoryHe != p.categoryHe) continue;
      final qc = _resolveCompoundType(q);
      if (qc.isEmpty || byCompound.containsKey(qc)) continue;
      byCompound[qc] = q;
    }
    if (byCompound.length <= 1) return [];
    return byCompound.values.toList()
      ..sort((a, b) {
        if (a.sku == p.sku) return -1;
        if (b.sku == p.sku) return 1;
        return _resolveCompoundType(a).compareTo(_resolveCompoundType(b));
      });
  }

  // ── דגם: category-wide (כל הדגמים בקטגוריה, כמו findAttrSiblings(model)) ─
  static List<LipskeyCatalogProduct> _variantsModel(LipskeyCatalogProduct p) {
    final seen = <String>{};
    final all = <LipskeyCatalogProduct>[];
    for (final q in resolvedCatalogProducts) {
      if (q.categoryHe != p.categoryHe) continue;
      final m = q.brandModel;
      if (m == null || m.isEmpty) continue;
      if (seen.add(m)) all.add(q);
    }
    if (all.length <= 1) return [];
    return all
      ..sort((a, b) {
        if (a.sku == p.sku) return -1;
        if (b.sku == p.sku) return 1;
        return (a.brandModel ?? '').compareTo(b.brandModel ?? '');
      });
  }

  // ── מידה: frame-based (אותו מוצר, מידה שונה) — חוצה-מותג ─────────────────
  static double _firstSizeNum(String s) =>
      double.tryParse(RegExp(r'\d+(?:\.\d+)?').firstMatch(s)?.group(0) ?? '') ??
      0;

  static List<LipskeyCatalogProduct> _variantsSize(LipskeyCatalogProduct p) {
    const kind = AttrKind.size;
    final frame = p.nameHe
        .split(RegExp(r'\s+'))
        .where((w) => kindOf(w) != kind)
        .join(' ');
    final seen = <String>{};
    final all = <LipskeyCatalogProduct>[];
    for (final q in resolvedCatalogProducts) {
      if (q.categoryHe != p.categoryHe) continue;
      final v = variantValue(q, kind);
      if (v.isEmpty) continue;
      if (q.nameHe
              .split(RegExp(r'\s+'))
              .where((w) => kindOf(w) != kind)
              .join(' ') !=
          frame) continue;
      if (seen.add(v)) all.add(q);
    }
    all.sort((a, b) {
      if (a.sku == p.sku) return -1;
      if (b.sku == p.sku) return 1;
      return _firstSizeNum(variantValue(a, kind))
          .compareTo(_firstSizeNum(variantValue(b, kind)));
    });
    return all;
  }

  // ── Unified sibling check & picker options ───────────────────────────────
  static bool _hasSiblings(LipskeyCatalogProduct p, String key) {
    switch (key) {
      case 'type':
        return _variantsType(p).isNotEmpty;
      case 'model':
        return _variantsModel(p).isNotEmpty;
      case 'color':
        final myVal = p.colorVariant;
        if (myVal == null || myVal.isEmpty) return false;
        final frame = _colorFrame(p);
        return resolvedCatalogProducts.any((q) {
          final qv = q.colorVariant;
          return q.categoryHe == p.categoryHe &&
              q.sku != p.sku &&
              qv != null &&
              qv.isNotEmpty &&
              qv != myVal &&
              _colorFrame(q) == frame;
        });
      case 'subtype':
        return _variantsSubtype(p).length > 1;
      case 'size':
        return _variantsSize(p).length > 1;
      default:
        return false;
    }
  }

  // Returns (display label, target product) for each picker option.
  static List<(String, LipskeyCatalogProduct)> _pickerOptions(
      LipskeyCatalogProduct p, String key) {
    switch (key) {
      case 'type':
        return _variantsType(p).map((q) {
          final ct = _resolveCompoundType(q);
          final label = ct.contains(' ') ? ct.split(' ').last : ct;
          return (label, q);
        }).toList();
      case 'model':
        return _variantsModel(p)
            .map((q) => (q.brandModel ?? '', q))
            .toList();
      case 'color':
        return _variantsColor(p)
            .map((q) => (q.colorVariant ?? '', q))
            .toList();
      case 'subtype':
        return _variantsSubtype(p)
            .map((q) => (variantValue(q, AttrKind.subtype), q))
            .toList();
      case 'size':
        return _variantsSize(p)
            .map((q) => (variantValue(q, AttrKind.size), q))
            .toList();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final parsed = product.parsedName;
    final compound = _resolveCompoundType(product);
    final sizeVal = variantValue(product, AttrKind.size);

    final entries = <({String label, String value, Color color, String key})>[
      if (parsed.type != null)
        (
          label: 'סוג',
          value: compound.isNotEmpty ? compound : parsed.type!,
          color: const Color(0xFFFF9D4D),
          key: 'type',
        ),
      if (parsed.subtype != null)
        (
          label: 'תת-סוג',
          value: parsed.subtype!,
          color: const Color(0xFF7FD0FF),
          key: 'subtype',
        ),
      if (sizeVal.isNotEmpty)
        (
          label: 'גודל',
          value: '\u202A$sizeVal\u202C', // LTR embed so 20x2.8 isn't flipped
          color: const Color(0xFF4CAF50),
          key: 'size',
        ),
      if (parsed.variant != null)
        (
          label: 'צבע',
          value: parsed.variant!,
          color: const Color(0xFFC9A7FF),
          key: 'color',
        ),
      if (parsed.brand != null)
        (
          label: 'דגם',
          value: parsed.brand!,
          color: const Color(0xFFFF9D4D),
          key: 'model',
        ),
      if ((product.dims?['אורך'] as String?)?.isNotEmpty ?? false)
        (
          label: 'אורך',
          value: product.dims!['אורך'] as String,
          color: const Color(0xFF9E9E9E),
          key: 'length',
        ),
    ];
    if (entries.isEmpty) return const SizedBox.shrink();

    final activeOptions = openPickerKey != null
        ? _pickerOptions(product, openPickerKey!)
        : <(String, LipskeyCatalogProduct)>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [for (final c in entries) _buildChip(c)],
        ),
        if (openPickerKey != null && activeOptions.isNotEmpty) ...[
          const SizedBox(height: 8),
          _ChipPickerRow(
            options: activeOptions,
            currentSku: product.sku,
            onSelect: onVariantSelect,
          ),
        ],
      ],
    );
  }

  Widget _buildChip(({String label, String value, Color color, String key}) c) {
    final tappable = _hasSiblings(product, c.key);
    final isOpen = openPickerKey == c.key;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen
            ? c.color.withValues(alpha: 0.22)
            : c.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: tappable
              ? const Color(0xFFFF9D4D)
              : c.color.withValues(alpha: 0.35),
          width: tappable ? 1.5 : 1.0,
        ),
      ),
      child: Text.rich(
        TextSpan(children: [
          TextSpan(
            text: '${c.label} ',
            style: const TextStyle(color: Color(0xFF888888), fontSize: 10),
          ),
          TextSpan(
            text: c.value,
            style: TextStyle(
              color: c.color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (tappable)
            TextSpan(
              text: isOpen ? ' ×' : ' ›',
              style: const TextStyle(color: Color(0xFFFF9D4D), fontSize: 10),
            ),
        ]),
      ),
    );
    if (!tappable) return chip;
    return GestureDetector(onTap: () => onChipTap(c.key), child: chip);
  }
}

class _ChipPickerRow extends StatelessWidget {
  const _ChipPickerRow({
    required this.options,
    required this.currentSku,
    required this.onSelect,
  });

  final List<(String, LipskeyCatalogProduct)> options;
  final String currentSku;
  final void Function(LipskeyCatalogProduct) onSelect;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: const Color(0xFFFF9D4D).withValues(alpha: 0.4)),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final opt in options)
            _PickerOption(
              value: opt.$1,
              isSelected: opt.$2.sku == currentSku,
              onTap: () => onSelect(opt.$2),
            ),
        ],
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  const _PickerOption({
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF9D4D).withValues(alpha: 0.2)
              : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFFF9D4D) : const Color(0xFF444444),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            color:
                isSelected ? const Color(0xFFFF9D4D) : const Color(0xFFCCCCCC),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
