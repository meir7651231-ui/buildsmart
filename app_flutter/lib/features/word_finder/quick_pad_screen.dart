// QuickPadScreen — the flag-gated DIVERSE-LIST ("ערב-רב") quick re-order pad.
//
// STAGE B of the word-finder swarm: the thin, self-gating UI seam that wires
// the PURE quick-pad ranking engine (`quick_pad_engine.dart`) to the approved
// quantity-key keyboard (`quick_pad_keyboard.dart`). The user's most-used
// products — favorites, then per-item usage-frequency, then recently-viewed —
// surface as fast quick-add keys with a per-item quantity stepper; tapping a
// key adds that product (× its quantity) straight to the smart cart.
//
// PURITY SPLIT (mirrors `WordFinderScreen`): this screen is the ONLY
// Flutter-/Riverpod-aware layer. It reads the three usage providers, hands
// their RAW sku collections to the pure `quickPicks(...)` engine, maps the
// resulting `QuickPick`s into keyboard `QuickPadItem`s, and on a tap builds a
// real `SmartCartLine` and pushes it through `SmartCartNotifier.add` — the
// EXACT cart-add path `lipskey_product_sheet.dart` uses.
//
// SELF-GATING: like `SmartSuggestionStrip` / `WordFinderScreen`, the screen
// renders nothing (a zero-height `SizedBox.shrink`) unless `kWordFinderFlag` is
// enabled. It is safe to land dark; wiring it into a real navigation seam is a
// SEPARATE later step.
//
// FREQUENCY CAVEAT: `smartInputUsageProvider.frequencies` is keyed by the
// PICKED TEXT (a free-form smart-input phrase), NOT necessarily a catalog sku.
// So we keep ONLY frequency keys that are REAL skus present in `kDivePool`
// (sorted most-frequent first); the rest are dropped. If none survive, the
// `frequentSkus` input is `const []` and the engine simply ranks
// favorites → recents.

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart';
import 'package:buildsmart/features/word_finder/quick_pad_engine.dart';
import 'package:buildsmart/features/word_finder/quick_pad_item.dart';
import 'package:buildsmart/features/word_finder/quick_pad_keyboard.dart';
import 'package:buildsmart/features/word_finder/word_finder_flag.dart';
import 'package:buildsmart/state/feature_flags.dart';
import 'package:buildsmart/state/product_favorites.dart';
import 'package:buildsmart/state/recently_viewed.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/state/smart_input_usage.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The flag-gated quick re-order pad. Surfaces the user's most-used products as
/// quick-add quantity keys and adds the tapped product (× its qty) to the cart.
class QuickPadScreen extends ConsumerStatefulWidget {
  const QuickPadScreen({super.key, this.onSwitchMode});

  /// Optional callback for the keyboard's `מצב רגיל` utility key — lets a host
  /// flip back to the regular browsing mode. Null hides the key entirely.
  final void Function()? onSwitchMode;

  @override
  ConsumerState<QuickPadScreen> createState() => _QuickPadScreenState();
}

class _QuickPadScreenState extends ConsumerState<QuickPadScreen> {
  /// The set of real `kDivePool` skus, computed ONCE per isolate — used to keep
  /// only frequency keys that name an addable catalog product (the usage signal
  /// is keyed by free-form text, not necessarily a sku).
  static final Set<String> _poolSkus = {for (final p in kDivePool) p.sku};

  /// Derive the frequent-sku list from `smartInputUsageProvider`: sort its
  /// `frequencies` entries most-frequent first and keep ONLY keys that are real
  /// `kDivePool` skus (drop free-form phrases). Returns `const []` when none
  /// survive, so the engine falls back to favorites → recents cleanly.
  List<String> _frequentSkus(SmartInputUsage usage) {
    final entries = usage.frequencies.entries
        .where((e) => _poolSkus.contains(e.key))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // most-frequent first
    if (entries.isEmpty) return const [];
    return [for (final e in entries) e.key];
  }

  /// Add the tapped product (× [qty]) to the smart cart via the SAME
  /// `SmartCartNotifier.add(SmartCartLine(...))` path the product sheet uses.
  /// `brandPrice` is 0 (the catalog carries no price — the sheet defaults it to
  /// 0 too) and there are no accessories on a quick-add line.
  void _addToCart(LipskeyCatalogProduct p, int qty) {
    ref.read(smartCartProvider.notifier).add(
          SmartCartLine(
            productKey: 'lip:${p.sku}',
            productName: p.nameHe,
            productEmoji: p.typeEmoji,
            brandName: p.brand,
            brandPrice: 0,
            productQty: qty,
            accessories: const [],
          ),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('נוסף לסל ✓  ${quickLabel(p)} ×$qty'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // SELF-GATE first — render nothing unless the flag is on. Mirrors the
    // `smart_suggestion_strip.dart` / `word_finder_screen.dart`
    // `.contains(flag) → SizedBox.shrink` idiom.
    final on = ref.watch(featureFlagsProvider).contains(kWordFinderFlag);
    if (!on) return const SizedBox.shrink();

    // Read the three usage providers and hand their RAW sku collections to the
    // pure engine. Favorites is a Set, recents a newest-first List, frequents a
    // most-frequent-first List derived above.
    final favSkus = ref.watch(productFavoritesProvider);
    final recentSkus = ref.watch(recentlyViewedProvider);
    final usage = ref.watch(smartInputUsageProvider);
    final frequentSkus = _frequentSkus(usage);

    final picks = quickPicks(
      favSkus: favSkus,
      recentSkus: recentSkus,
      frequentSkus: frequentSkus,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.surfaceMid,
        body: SafeArea(
          child: picks.isEmpty
              ? _buildEmptyState()
              : _buildPad(picks),
        ),
      ),
    );
  }

  /// Friendly empty-state when the user has no favorites / recents / frequents
  /// to surface yet — better than an empty keyboard.
  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(BsTokens.space3),
      child: Center(
        child: Text(
          // OWNER-REVIEW: 'התחל' is the clean singular-masc imperative (was the
          // colloquial 'תתחיל') — matches the voice of kFirstQuestion.
          'עדיין אין מועדפים — התחל לבחור מוצרים',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: BsTokens.inkLight,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  /// Map each [QuickPick] into a keyboard [QuickPadItem] (carrying the resolved
  /// product as its payload) and render the quantity-key [QuickPadKeyboard].
  Widget _buildPad(List<QuickPick> picks) {
    final items = [
      for (final pick in picks)
        QuickPadItem(pick.label, payload: pick.product),
    ];
    return SingleChildScrollView(
      child: QuickPadKeyboard(
        items: items,
        onAdd: (item, qty) =>
            _addToCart(item.payload as LipskeyCatalogProduct, qty),
        onSwitchMode: widget.onSwitchMode,
      ),
    );
  }
}
