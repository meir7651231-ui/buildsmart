// ─────────────────────────────────────────────────────────────────────────────
// THE FULL INTERNAL PRODUCT CARD ("כרטיס-מוצר פנימי · הכי מורחב · המנוע חשוף").
// Renders up to 13 data sections for a fitting product, EACH wired to an existing
// engine function and shown ONLY when that engine returns data (R8 · no invention —
// SmartLock has no VerifiedSpec ⇒ compat/price are empty/null ⇒ those sections hide).
// Layout + palette are a 1:1 port of knowledge/internal-card mockup card-max-internal.
//
// Wiring (SSOT: knowledge/internal-card/WIRING-SSOT.md):
//   header      → typeEmoji · nameHe · sku · dims(DN/t) · brand
//   🎛️ הגדרה     → wheel axes label (קוטר · זווית · אורך · כמות)
//   🧩 וריאנטים   → variantSiblingsCountFor / variantSiblingsOf
//   🔗 מתחבר ל־   → compatibleProductsFor            (empty ⇒ hidden)
//   🔩 הוראות-חיבור→ engineeringSpecFor.endsSummary
//   🛠️ שלבי התקנה → installTipsFor
//   🧰 ערכת אביזרים→ installKitFor + recommendedKitForProduct
//   🧱 מפרט חומרים → engineeringSpecFor.material (+ endsSummary)
//   📐 מפרט הנדסי  → engineeringSpecFor (dn/di/PN/system)
//   🌡️ טמפרטורה    → engineeringSpecFor.maxTempC
//   📋 תקינות      → complianceTriggersFor
//   ⚠️ אזהרות      → systemSafetyNoteHe / connectionWarningHe
//   🧩 משלימים     → frequentlyPairedTypesFor
//   💰 הערכת מחיר  → priceFor + formatCatalogPrice    (null ⇒ hidden)
//   ＋ הוסף לסל    → priceFor (else plain label)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/product_images.dart' show resolveProductImage;
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/features/fittings/engine/models.dart' show RunElement;
// `Family` collides with Riverpod's provider `Family`, so the engine enums come
// in under a prefix (used only by the gallery-3D route builder).
import 'package:buildsmart/features/fittings/engine/models.dart' as fm
    show Dir, Family;
import 'package:buildsmart/features/fittings/render/product_line_3d.dart'
    show ProductLine3D;
import 'package:buildsmart/features/fittings/ui/sudoku_grid.dart'
    show SudokuGrid, runElementFor;
import 'package:buildsmart/logic/install_kit.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/smart_cart.dart'
    show SmartCartLine, smartCartProvider;
import 'package:buildsmart/widgets/toast.dart' show showToast;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── palette (exact card-max-internal hexes) ──────────────────────────────────
const Color _cCard = Color(0xFFFFFFFF);
const Color _cInk = Color(0xFF232A33);
const Color _cDim = Color(0xFF7A828D);
const Color _cLine = Color(0xFFE9ECF1);
const Color _cAccent = Color(0xFFEE6A2A);
const Color _cAccentD = Color(0xFFCF551B);
const Color _cImgBg = Color(0xFFF4F6F9);
const Color _cWarn = Color(0xFFC0392B);
const Color _cSecBorder = Color(0xFFE3E7EC);
const Color _cBody = Color(0xFF48505A);
const Color _cHotBg = Color(0xFFFFF2EA);
const Color _cHotBorder = Color(0xFFFFD6BD);
const Color _cGreen = Color(0xFF1F9D57); // D9 "אשר · סה״כ" confirm button
const Color _cHintBg = Color(0xFFE7F6EC); // green coaching-hint pill bg (e_2/e_3)
const Color _cHintInk = Color(0xFF1E874B); // green coaching-hint text

/// THE full internal card. Give it a [product]; it renders every section the
/// engine can populate for that product, and a swipe on the name cycles the
/// size-variant family (D5). Reusable (any fitting SKU); the home embed +
/// standalone route both seed it with the SmartLock elbow hero.
class FullInternalCard extends ConsumerStatefulWidget {
  const FullInternalCard({
    required this.product,
    this.initialRailSide = 0,
    this.initialSpecOpen = false,
    this.fillHeight = false,
    this.onBack,
    super.key,
  });

  /// The default hero — SmartLock ברך 90° 50 (real SKU; mockup's 120050 is not
  /// in the catalog). Resolved via [catalogProductForSku].
  static const String heroSku = '70055960';

  final LipskeyCatalogProduct product;

  /// D4 — pre-open a side rail on first build (previews/tests): -1 left, +1 right.
  final int initialRailSide;

  /// D15 — pre-open the 📋 spec panel on first build (previews/tests).
  final bool initialSpecOpen;

  /// Full-screen mode — the card fills the whole screen (the hero image expands
  /// to take the slack, the buy area pins near the bottom) instead of shrink-
  /// wrapping. Off ⇒ the compact embedded card (home).
  final bool fillHeight;

  /// The top-bar → arrow goes back one screen. Null ⇒ the arrow is inert (the
  /// embedded home card has no route to pop).
  final VoidCallback? onBack;

  @override
  ConsumerState<FullInternalCard> createState() => _FullInternalCardState();
}

class _FullInternalCardState extends ConsumerState<FullInternalCard> {
  late LipskeyCatalogProduct _current = widget.product;

  @override
  void didUpdateWidget(FullInternalCard old) {
    super.didUpdateWidget(old);
    if (old.product.sku != widget.product.sku) {
      _current = widget.product;
    }
  }

  /// D5 — step the variant family by [dir], WRAPPING around the ends so every
  /// swipe changes the size (clamping left one swipe direction inert at the
  /// ends, which read as "broken"). The card re-resolves against the new SKU.
  void _stepVariant(int dir) {
    final fam = variantSiblingsOf(_current);
    if (fam.length < 2) {
      return;
    }
    final i = fam.indexWhere((s) => s.sku == _current.sku);
    final next = (i + dir + fam.length) % fam.length;
    if (next != i) {
      setState(() => _current = fam[next]);
    }
  }

  /// D5 — jump straight to variant [index] (tapping a size dot).
  void _pickVariant(int index) {
    final fam = variantSiblingsOf(_current);
    if (index < 0 || index >= fam.length || fam[index].sku == _current.sku) {
      return;
    }
    setState(() => _current = fam[index]);
  }

  /// D6 — the chosen sale unit (בודד / ארגז / משטח). Swipe-selected on the buy
  /// button (◀▶) — there is no visible unit-chip row.
  String _unit = 'בודד';

  /// D6 — how many of the selected unit to add (up/down swipe on the buy button).
  int _qty = 1;

  /// D6 — cycle the sale unit by a horizontal swipe on the buy button.
  void _stepUnit(int dir) {
    final keys = _current.saleUnits.keys.toList();
    if (keys.length < 2) return;
    final cur = keys.indexOf(_unit);
    final i = cur < 0 ? 0 : cur;
    setState(() => _unit = keys[(i + dir + keys.length) % keys.length]);
  }

  /// D6 — bump the quantity by a vertical swipe (up = +1, down = −1; min 1).
  void _stepQty(int delta) =>
      setState(() => _qty = (_qty + delta).clamp(1, 999));

  /// D8 — which line circle is highlighted (null ⇒ the last-added). Tapping a
  /// circle highlights it; tapping the already-highlighted one removes it
  /// (screen #2: "לחיצה על עיגול = מדגיש · לחיצה על המודגש = מסיר").
  int? _highlightLine;

  void _tapLineCircle(int index) {
    final line = ref.read(smartCartProvider);
    if (index < 0 || index >= line.length) return;
    final highlighted = _highlightLine ?? line.length - 1;
    if (index == highlighted) {
      ref.read(smartCartProvider.notifier).remove(index);
      setState(() => _highlightLine = null);
    } else {
      setState(() => _highlightLine = index);
    }
  }

  /// D15 — the spec is HIDDEN behind the 📋 clipboard; tapping it swaps the big
  /// product image for the spec panel in place (the card is image-first, not a
  /// text dump).
  late bool _specOpen = widget.initialSpecOpen;

  void _toggleSpec() => setState(() => _specOpen = !_specOpen);

  /// D15 — which spec tab is active (מפרט / תקן / אזהרה / חומר / טמפ׳).
  int _specTab = 0;

  void _pickSpecTab(int i) => setState(() => _specTab = i);

  /// D4 — which side's connect-rail is showing: 0 = image, -1 = left end,
  /// +1 = right end. Swiping the image toggles the matching side.
  late int _railSide = widget.initialRailSide;

  void _swipeImage(int dir) =>
      setState(() => _railSide = _railSide == dir ? 0 : dir);

  @override
  Widget build(BuildContext context) => _CardView(
        product: _current,
        unit: _unit,
        specOpen: _specOpen,
        specTab: _specTab,
        railSide: _railSide,
        fillHeight: widget.fillHeight,
        onBack: widget.onBack,
        onStepVariant: _stepVariant,
        onPickVariant: _pickVariant,
        qty: _qty,
        onCycleUnit: _stepUnit,
        onStepQty: _stepQty,
        highlightLine: _highlightLine,
        onTapLine: _tapLineCircle,
        onToggleSpec: _toggleSpec,
        onPickSpecTab: _pickSpecTab,
        onSwipeImage: _swipeImage,
      );
}

/// The stateless render of one product's card (all section builders). The
/// stateful [FullInternalCard] above swaps [product] on a name-swipe.
class _CardView extends ConsumerWidget {
  const _CardView({
    required this.product,
    required this.unit,
    required this.specOpen,
    required this.specTab,
    required this.railSide,
    this.fillHeight = false,
    this.onBack,
    this.onStepVariant,
    this.onPickVariant,
    this.qty = 1,
    this.onCycleUnit,
    this.onStepQty,
    this.highlightLine,
    this.onTapLine,
    this.onToggleSpec,
    this.onPickSpecTab,
    this.onSwipeImage,
  });

  /// Full-screen mode — the hero area expands to fill the screen.
  final bool fillHeight;

  /// Back one screen (top-bar → arrow). Null ⇒ inert.
  final VoidCallback? onBack;

  final LipskeyCatalogProduct product;

  /// D6 — the selected sale-unit key (בודד / ארגז / משטח).
  final String unit;

  /// D15 — whether the 📋 spec panel is showing (in place of the big image).
  final bool specOpen;

  /// D15 — the active spec tab index.
  final int specTab;

  /// D5 — the name-swipe steps the variant family by ±1 (null ⇒ inert).
  final void Function(int dir)? onStepVariant;

  /// D5 — jump to a specific variant by tapping its size dot (null ⇒ inert).
  final void Function(int index)? onPickVariant;

  /// D6 — quantity of the selected unit to add.
  final int qty;

  /// D6 — cycle the sale unit (horizontal swipe on the buy button; null ⇒ inert).
  final void Function(int dir)? onCycleUnit;

  /// D6 — bump the quantity (vertical swipe on the buy button; null ⇒ inert).
  final void Function(int delta)? onStepQty;

  /// D8 — highlighted line-circle index (null ⇒ the last-added).
  final int? highlightLine;

  /// D8 — tap a line circle: highlight it, or remove it if already highlighted.
  final void Function(int index)? onTapLine;

  /// D15 — toggle the spec panel (null ⇒ inert).
  final VoidCallback? onToggleSpec;

  /// D15 — pick a spec tab (null ⇒ inert).
  final void Function(int index)? onPickSpecTab;

  /// D4 — which side's connect-rail is showing (0 image · -1 left · +1 right).
  final int railSide;

  /// D4 — swipe the image by dir (-1 left · +1 right); null ⇒ inert.
  final void Function(int dir)? onSwipeImage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(catalogSettingsProvider);
    final p = product;

    // Image-first: the big product image is the hero; the 📋 clipboard swaps it
    // for the spec panel in place (D15) — spec is never spilled.
    final hero = specOpen
        ? _specPanel(context, p, settings)
        : (railSide != 0 ? _sideRail(context, p, railSide) : _bigImage(context, p));
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: _cCard),
        child: Column(
          key: const Key('fullInternalCard'),
          mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Green coaching-hint pill — full-screen card only (e_0/e_2/e_3).
            if (fillHeight) _hintBanner(),
            _topBar(context, p),
            // Full-screen: the hero (image / spec panel / rail) fills the slack;
            // each scrolls internally when it needs to. Embedded: shrink-wraps.
            if (fillHeight) Expanded(child: hero) else hero,
            _footer(p),
            _buyArea(context, ref, p, settings),
            // D6–D9/D14 — the line strip (circles + קו/בדיקה/השלם) appears ONLY
            // after a product is added; the base card is just image + add.
            _lineStrip(context, ref, p, settings),
          ],
        ),
      ),
    );
  }

  // ── green coaching-hint pill (e_0 · e_2 · e_3) ────────────────────────────────
  /// The soft-green hint bar at the very top of the FULL-SCREEN card — verbatim
  /// wording from the reference screens, swapped by state (hero · spec · rail).
  /// Arrows are Material icons (the reference's ← / → glyphs tofu in Heebo) and
  /// point the way the real card's own affordances do. Full-screen only, so the
  /// embedded home card stays uncluttered.
  Widget _hintBanner() {
    final List<InlineSpan> spans;
    if (specOpen) {
      // e_3: "נגיעה ב📋 (לא קופץ) — …"
      spans = const [
        TextSpan(
          text: 'נגיעה ב📋 (לא קופץ) — המפרט/תקן/אזהרה מחליף את התמונה '
              'במקום · טאבים למעבר',
        ),
      ];
    } else if (railSide != 0) {
      // e_0: "משיכה ימינה → מה מתחבר לצד ימין" / "…שמאלה → …לצד שמאל"
      final toRight = railSide > 0;
      spans = [
        TextSpan(text: 'משיכה ${toRight ? 'ימינה' : 'שמאלה'} '),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Icon(
            toRight ? Icons.arrow_forward : Icons.arrow_back,
            size: 13,
            color: _cHintInk,
          ),
        ),
        TextSpan(text: ' מה מתחבר לצד ${toRight ? 'ימין' : 'שמאל'}'),
      ];
    } else {
      // e_2: "מפרט · → חזור · מק״ט מוטבע על התמונה · נגיעה=גלריה"
      spans = const [
        TextSpan(text: 'מפרט · '),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Icon(Icons.arrow_forward, size: 13, color: _cHintInk),
        ),
        TextSpan(text: ' חזור · מק״ט מוטבע על התמונה · נגיעה=גלריה'),
      ];
    }
    return Container(
      key: const Key('internalCardHintBanner'),
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _cHintBg,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(
            color: _cHintInk,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
          children: spans,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ── top bar (📋 spec toggle · SKU embossed · → next) ──────────────────────────
  Widget _topBar(BuildContext context, LipskeyCatalogProduct p) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        // Full-screen: extra top inset so the SKU clears the always-on
        // "🟢 מחובר לשרת" connection pill that overlays the top of every screen.
        padding: EdgeInsets.fromLTRB(12, fillHeight ? 34 : 11, 12, 6),
        child: Row(
          children: [
            GestureDetector(
              key: const Key('internalCardSpecToggle'),
              behavior: HitTestBehavior.opaque,
              onTap: onToggleSpec,
              child: Opacity(
                opacity: specOpen ? 1 : 0.6,
                child: const Text('📋', style: TextStyle(fontSize: 20)),
              ),
            ),
            const Spacer(),
            Text(
              p.sku,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: _cDim,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            // → goes back one screen (full-screen route); inert & dimmed when
            // embedded (no route to pop).
            GestureDetector(
              key: const Key('internalCardBack'),
              behavior: HitTestBehavior.opaque,
              onTap: onBack,
              child: Icon(
                Icons.arrow_forward,
                size: 22,
                color: onBack == null ? _cLine : _cAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// D17 — the design's per-type glyph for the hero visual (the fitting shapes
  /// in the spec screenshots), overriding the app-wide type glyph INSIDE the
  /// gated card only. Falls back to the shared glyph for uncovered types.
  static String _heroEmoji(LipskeyCatalogProduct p) {
    final n = p.nameHe;
    bool has(String s) => n.contains(s);
    if (has('ברך') || has('זווית')) return '🦵';
    if (has('מסעף') || has('הסתעפות')) return '🔱';
    if (has('צינור') || has('צנרת')) return '🟫';
    if (has('מצרה')) return '🔻';
    if (has('ניפל')) return '🔗';
    if (has('פקק')) return '⬛';
    if (has('מצמד') || has('מחבר') || has('מופה')) return '🧷';
    if (has('אום')) return '🔩';
    return p.typeEmoji;
  }

  // ── the hero image (dominant · tap → gallery · D17 never grey) ────────────────
  Widget _bigImage(BuildContext context, LipskeyCatalogProduct p) {
    final asset = p.imageAsset;
    return GestureDetector(
      key: const Key('internalCardImage'),
      behavior: HitTestBehavior.opaque,
      onTap: () => _openGallery(context, p),
      // D4 — swipe the image to reveal the per-side "what connects" rail.
      onHorizontalDragEnd: onSwipeImage == null
          ? null
          : (d) {
              final v = d.primaryVelocity ?? 0;
              if (v != 0) onSwipeImage!(v < 0 ? -1 : 1);
            },
      child: Container(
        // Full-screen: null height ⇒ fills the Expanded slack. Embedded: 360.
        height: fillHeight ? null : 360,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
        decoration: BoxDecoration(
          color: _cImgBg,
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        child: asset == null
            ? Text(_heroEmoji(p), style: const TextStyle(fontSize: 148))
            : Image(
                image: resolveProductImage(asset),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    Text(_heroEmoji(p), style: const TextStyle(fontSize: 148)),
              ),
      ),
    );
  }

  // ── D4 · the per-side "what connects" rail (revealed by swiping the image) ────
  Widget _sideRail(BuildContext context, LipskeyCatalogProduct p, int side) {
    // side −1 → the first end, +1 → the last end (each physical end differs).
    final ends = verifiedEndsCountFor(p);
    final endIndex = side < 0 ? 0 : (ends <= 1 ? 0 : ends - 1);
    final mates = compatibleProductsForEnd(p, endIndex).take(6).toList();
    final label = side < 0 ? 'מה מתחבר לצד שמאל' : 'מה מתחבר לצד ימין';
    final railLeft = side < 0;
    final asset = p.imageAsset;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSwipeImage == null ? null : () => onSwipeImage!(side),
      onHorizontalDragEnd: onSwipeImage == null
          ? null
          : (d) {
              final v = d.primaryVelocity ?? 0;
              if (v != 0) onSwipeImage!(v < 0 ? -1 : 1);
            },
      child: Container(
        key: const Key('internalCardRail'),
        height: fillHeight ? null : 236,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
        decoration: BoxDecoration(
          color: _cImgBg,
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // The product image stays visible in the centre.
            Center(
              child: asset == null
                  ? Text(_heroEmoji(p), style: const TextStyle(fontSize: 88))
                  : Image(
                      image: resolveProductImage(asset),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          Text(_heroEmoji(p), style: const TextStyle(fontSize: 88)),
                    ),
            ),
            // The connection-point dot on the active side of the image.
            Positioned.fill(
              child: Align(
                alignment: railLeft
                    ? const Alignment(-0.35, 0)
                    : const Alignment(0.35, 0),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.28),
                  ),
                ),
              ),
            ),
            // Header label — shown ONLY on the embedded card. On the full-screen
            // card the green hint banner already says "מה מתחבר לצד …", so this
            // inner header would be redundant (e_0 shows only the top banner).
            if (!fillHeight)
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Text(
                  '🔗 $label · החלק ↔',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: _cAccent,
                  ),
                ),
              ),
            // The vertical rail of round icon-chips along the active edge.
            Positioned(
              top: 30,
              bottom: 8,
              left: railLeft ? 6 : null,
              right: railLeft ? null : 6,
              child: mates.isEmpty
                  ? const Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Text('אין תואם ישיר',
                            style: TextStyle(fontSize: 10, color: _cDim)),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [for (final m in mates) _railChip(m)],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// One round mate-chip on the side rail: emoji circle + a tiny label.
  Widget _railChip(LipskeyCatalogProduct m) {
    final sz = m.connectionSizes.isNotEmpty ? m.connectionSizes.first : '';
    final word = m.nameHe.split(' ').first;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _cCard,
              border: Border.all(color: _cAccent, width: 1.5),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x22000000), blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            alignment: Alignment.center,
            child: Text(_heroEmoji(m), style: const TextStyle(fontSize: 17)),
          ),
          const SizedBox(height: 1),
          SizedBox(
            width: 54,
            child: Text(
              sz.isEmpty ? word : '$word $sz',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 8, color: _cBody),
            ),
          ),
        ],
      ),
    );
  }

  // ── name · subtitle · variant dots ───────────────────────────────────────────
  Widget _footer(LipskeyCatalogProduct p) {
    final dims = p.dims ?? const <String, dynamic>{};
    final dn = (dims['DN'] ?? '').toString();
    final sub = <String>[
      if (dn.isNotEmpty) '$dn מ״מ',
      if (p.brand.isNotEmpty) p.brand,
    ].join(' · ');
    final hasVariants = variantSiblingsOf(p).length >= 2;
    // D5 — a horizontal drag ANYWHERE on the name block steps the size (bigger
    // target than the name text alone); tapping a dot jumps to that size.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: onStepVariant == null
          ? null
          : (d) {
              final v = d.primaryVelocity ?? 0;
              if (v < 0) {
                onStepVariant!(1);
              } else if (v > 0) {
                onStepVariant!(-1);
              }
            },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              p.nameHe,
              key: const Key('internalCardName'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: _cInk,
              ),
            ),
            if (sub.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                sub,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.5, color: _cDim),
              ),
            ],
            const SizedBox(height: 6),
            _variantDots(p),
            if (hasVariants) ...[
              const SizedBox(height: 3),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swap_horiz, size: 13, color: _cDim),
                  SizedBox(width: 3),
                  Text(
                    'החלק או הקש נקודה להחלפת מידה',
                    style: TextStyle(fontSize: 10.5, color: _cDim),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── D15 · spec panel — 5 inline tabs that swap the image IN PLACE (screenshot 7)
  static const List<(String, String)> _specTabs = [
    ('📐', 'מפרט'),
    ('📋', 'תקן'),
    ('⚠️', 'אזהרה'),
    ('🧱', 'חומר'),
    ('🌡️', 'טמפ׳'),
  ];

  Widget _specPanel(
    BuildContext context,
    LipskeyCatalogProduct p,
    CatalogSettings s,
  ) {
    final active = specTab.clamp(0, _specTabs.length - 1);
    final content = <Widget>[
      if (active == 0) ...[
        ..._engSpecSection(p),
        ..._configSection(),
        ..._variantsSection(p),
        ..._connectsSection(p),
      ],
      if (active == 1) ..._complianceSection(p),
      if (active == 2) ...[
        ..._warningsSection(p),
        ..._connectionInstructionsSection(p),
        ..._installStepsSection(p),
      ],
      if (active == 3) ...[
        ..._materialsSection(p),
        ..._kitSection(p),
        ..._complementsSection(p),
      ],
      if (active == 4) ...[
        ..._temperatureSection(p),
        ..._priceSection(p, s),
      ],
    ];
    return Container(
      key: const Key('internalCardSpecPanel'),
      // Full-screen: fill the slack (content scrolls inside). Embedded: 236.
      height: fillHeight ? null : 236,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      decoration: BoxDecoration(
        color: _cImgBg,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ColoredBox(
            color: _cCard,
            child: Row(
              children: [
                for (var i = 0; i < _specTabs.length; i++)
                  Expanded(
                    child: _specTabBtn(
                      _specTabs[i].$1,
                      _specTabs[i].$2,
                      i == active,
                      () => onPickSpecTab?.call(i),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: content.isEmpty
                ? const Center(
                    child: Text('אין נתונים', style: TextStyle(color: _cDim)),
                  )
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: content,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _specTabBtn(String icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? _cAccent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: active ? _cAccent : _cBody,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// D5 — pagination dots under the name showing the variant position; a swipe
  /// on the name moves between them. Hidden for a single-variant product.
  Widget _variantDots(LipskeyCatalogProduct p) {
    final fam = variantSiblingsOf(p);
    if (fam.length < 2) {
      return const SizedBox(height: 2);
    }
    final sel = fam.indexWhere((s) => s.sku == p.sku);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < fam.length; i++)
          GestureDetector(
            key: Key('variantDot_$i'),
            behavior: HitTestBehavior.opaque,
            onTap: onPickVariant == null ? null : () => onPickVariant!(i),
            child: Padding(
              // Generous hit area — the dot itself is tiny.
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: i == sel ? 18 : 7,
                height: 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: i == sel ? _cAccent : _cLine,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// D3 — tap the image → a full-screen gallery of the product image(s) + the
  /// spec diagram(s), with pinch-zoom + page dots. Inert with no image.
  void _openGallery(BuildContext context, LipskeyCatalogProduct p) {
    final images = <String>[...p.imageAssets, ...p.specImageAssets];
    if (images.isEmpty) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _InternalCardGallery(product: p, images: images),
      ),
    );
  }

  // ── section shell (6px top border · title row · body) ────────────────────────
  Widget _section({
    required String icon,
    required String title,
    required Widget child,
    String? count,
    bool warn = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _cCard,
        border: Border(top: BorderSide(color: _cSecBorder, width: 6)),
      ),
      padding: const EdgeInsets.fromLTRB(13, 9, 13, 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: warn ? _cWarn : _cAccentD,
                  ),
                ),
              ),
              if (count != null) _countBadge(count),
            ],
          ),
          const SizedBox(height: 4),
          DefaultTextStyle.merge(
            style: const TextStyle(
              fontSize: 11,
              color: _cBody,
              height: 1.55,
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _countBadge(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
        decoration: BoxDecoration(
          color: _cAccent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      );

  Widget _miniChip(String text, {bool hot = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: hot ? _cHotBg : _cImgBg,
          border: Border.all(color: hot ? _cHotBorder : _cLine),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 9.5,
            color: hot ? _cAccentD : const Color(0xFF5A636E),
            fontWeight: hot ? FontWeight.w800 : FontWeight.w400,
          ),
        ),
      );

  // ── 1 · הגדרה (wheels label) ─────────────────────────────────────────────────
  List<Widget> _configSection() => [
        _section(
          icon: '🎛️',
          title: 'הגדרה',
          count: 'גלגלים',
          child: const Text('קוטר · זווית · אורך · כמות'),
        ),
      ];

  // ── 2 · variants ─────────────────────────────────────────────────────────────
  List<Widget> _variantsSection(LipskeyCatalogProduct p) {
    final count = variantSiblingsCountFor(p);
    if (count <= 1) return const [];
    final sibs = variantSiblingsOf(p);
    final labels = <String>[];
    for (final s in sibs.take(6)) {
      final sig = (s.dims?['סימון'] ?? s.dims?['DN'] ?? '').toString();
      labels.add(sig.isNotEmpty ? sig : s.nameHe);
    }
    return [
      _section(
        icon: '🧩',
        title: 'וריאנטים',
        count: '$count',
        child: Text('${labels.join(' · ')}${sibs.length > 6 ? '...' : ''}'),
      ),
    ];
  }

  // ── 3 · what connects (per-product; empty for SmartLock) ─────────────────────
  List<Widget> _connectsSection(LipskeyCatalogProduct p) {
    final mates = compatibleProductsFor(p);
    if (mates.isEmpty) return const [];
    final dn = p.connectionSizes.isNotEmpty ? p.connectionSizes.first : '';
    return [
      _section(
        icon: '🔗',
        title: 'מתחבר ל־',
        count: '${mates.length}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dn.isNotEmpty) Text('מה שמתחבר למידה $dn:'),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (var i = 0; i < mates.take(8).length; i++)
                  _miniChip(mates[i].nameHe, hot: i == 0),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  // ── 4 · connection instructions (ends summary) ───────────────────────────────
  List<Widget> _connectionInstructionsSection(LipskeyCatalogProduct p) {
    final spec = engineeringSpecFor(p);
    final ends = spec?.endsSummary ?? '';
    if (ends.isEmpty) return const [];
    return [
      _section(
        icon: '🔩',
        title: 'הוראות-חיבור',
        child: Text(ends),
      ),
    ];
  }

  // ── 5 · install steps (tips) ─────────────────────────────────────────────────
  List<Widget> _installStepsSection(LipskeyCatalogProduct p) {
    final tips = installTipsFor(p);
    if (tips.isEmpty) return const [];
    return [
      _section(
        icon: '🛠️',
        title: 'שלבי התקנה',
        count: '${tips.length}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < tips.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text('${i + 1}. ${tips[i]}'),
              ),
          ],
        ),
      ),
    ];
  }

  // ── 6 · install kit ──────────────────────────────────────────────────────────
  List<Widget> _kitSection(LipskeyCatalogProduct p) {
    final kit = installKitFor(p);
    if (kit == null) return const [];
    final items = recommendedKitForProduct(p);
    final parts = <String>[
      if (kit.must > 0) '${kit.must} חובה',
      if (kit.optional > 0) '${kit.optional} אופציה',
      if (kit.tools > 0) '${kit.tools} כלים',
    ];
    if (parts.isEmpty) return const [];
    return [
      _section(
        icon: '🧰',
        title: 'ערכת אביזרים',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(parts.join(' · ')),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [for (final it in items.take(6)) _miniChip(it.label)],
              ),
            ],
          ],
        ),
      ),
    ];
  }

  // ── 7 · materials ────────────────────────────────────────────────────────────
  List<Widget> _materialsSection(LipskeyCatalogProduct p) {
    final spec = engineeringSpecFor(p);
    if (spec == null || spec.material.isEmpty) return const [];
    return [
      _section(
        icon: '🧱',
        title: 'מפרט חומרים',
        child: Text(spec.material),
      ),
    ];
  }

  // ── 8 · engineering spec ─────────────────────────────────────────────────────
  List<Widget> _engSpecSection(LipskeyCatalogProduct p) {
    final spec = engineeringSpecFor(p);
    if (spec == null) return const [];
    final di = (p.dims?['t'] ?? '').toString();
    final parts = <String>[
      if (spec.minBoreMm != null) 'dn ${spec.minBoreMm!.round()}',
      if (di.isNotEmpty) 'di $di',
      if (spec.pressureRating != null) spec.pressureRating!,
      if (spec.waterSystem.isNotEmpty) spec.waterSystem,
    ];
    if (parts.isEmpty) return const [];
    return [
      _section(
        icon: '📐',
        title: 'מפרט הנדסי',
        child: Text(parts.join(' · ')),
      ),
    ];
  }

  // ── 9 · temperature ──────────────────────────────────────────────────────────
  List<Widget> _temperatureSection(LipskeyCatalogProduct p) {
    final spec = engineeringSpecFor(p);
    if (spec == null || spec.maxTempC <= 0) return const [];
    return [
      _section(
        icon: '🌡️',
        title: 'טמפרטורה',
        child: Text('עד ${spec.maxTempC.round()}°C'),
      ),
    ];
  }

  // ── 10 · compliance / standards ──────────────────────────────────────────────
  List<Widget> _complianceSection(LipskeyCatalogProduct p) {
    final items = complianceTriggersFor(p);
    if (items.isEmpty) return const [];
    return [
      _section(
        icon: '📋',
        title: 'דרישות תקינות',
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [for (final it in items.take(8)) _miniChip(it.label)],
        ),
      ),
    ];
  }

  // ── 11 · warnings ────────────────────────────────────────────────────────────
  List<Widget> _warningsSection(LipskeyCatalogProduct p) {
    final notes = <String>[];
    final safety = systemSafetyNoteHe(p);
    if (safety != null && safety.isNotEmpty) notes.add(safety);
    final connWarn = connectionWarningHe(p);
    if (connWarn != null && connWarn.isNotEmpty) notes.add(connWarn);
    if (notes.isEmpty) return const [];
    return [
      _section(
        icon: '⚠️',
        title: 'אזהרות',
        warn: true,
        child: Text(notes.join(' · ')),
      ),
    ];
  }

  // ── 12 · complementary products ──────────────────────────────────────────────
  List<Widget> _complementsSection(LipskeyCatalogProduct p) {
    final paired = frequentlyPairedTypesFor(p);
    if (paired.isEmpty) return const [];
    return [
      _section(
        icon: '🧩',
        title: 'אביזרים משלימים',
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [for (final t in paired.take(6)) _miniChip(t)],
        ),
      ),
    ];
  }

  // ── 13 · price estimate ──────────────────────────────────────────────────────
  List<Widget> _priceSection(LipskeyCatalogProduct p, CatalogSettings s) {
    final base = priceFor(p);
    if (base == null) return const [];
    return [
      _section(
        icon: '💰',
        title: 'הערכת מחיר',
        child: Text('הערכה לפי קטגוריה · ${formatCatalogPrice(base, s)}'),
      ),
    ];
  }

  // ── buy area (D6 · unit selector + wired add-to-cart) ─────────────────────────
  Widget _buyArea(
    BuildContext context,
    WidgetRef ref,
    LipskeyCatalogProduct p,
    CatalogSettings s,
  ) {
    final units = p.saleUnits;
    final selected = units.containsKey(unit) ? unit : units.keys.first;
    final mult = units[selected] ?? 1;
    final base = priceFor(p);
    final priceStr =
        base == null ? '' : ' · ${formatCatalogPrice(base * mult * qty, s)}';
    // Screen #2 — once THIS product is in the line the button turns GREEN
    // "✓ אשר · סה״כ <line-total>"; before, it's the orange "+ הוסף לסל".
    final line = ref.watch(smartCartProvider);
    final inLine = line.any((l) => l.productKey == 'lip:${p.sku}');
    final lineTotal = line.fold<int>(0, (sum, l) => sum + l.total);
    final line2 = inLine
        ? 'סה״כ ${formatCatalogPrice(lineTotal, s)}'
        : '$qty × $selected$priceStr';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The swipe hint (◀▶ unit · ▲▼ qty) — only while still adding; once the
        // product is in the line the button becomes "אשר".
        if (!inLine)
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 5, 13, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (units.length > 1) ...[
                  const Icon(Icons.swap_horiz, size: 12, color: _cDim),
                  const SizedBox(width: 2),
                  const Text('יחידה',
                      style: TextStyle(fontSize: 10, color: _cDim)),
                  const SizedBox(width: 10),
                ],
                const Icon(Icons.swap_vert, size: 12, color: _cDim),
                const SizedBox(width: 2),
                const Text('כמות', style: TextStyle(fontSize: 10, color: _cDim)),
              ],
            ),
          ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          // Horizontal drag cycles the unit; vertical drag bumps the quantity.
          onHorizontalDragEnd: (onCycleUnit == null || units.length < 2)
              ? null
              : (d) {
                  final v = d.primaryVelocity ?? 0;
                  if (v != 0) onCycleUnit!(v < 0 ? 1 : -1);
                },
          onVerticalDragEnd: onStepQty == null
              ? null
              : (d) {
                  final v = d.primaryVelocity ?? 0;
                  if (v != 0) onStepQty!(v < 0 ? 1 : -1); // swipe up = +1
                },
          child: Container(
            margin: const EdgeInsets.fromLTRB(13, 6, 13, 13),
            child: Material(
              key: const Key('internalCardBuy'),
              color: inLine ? _cGreen : _cAccent,
              borderRadius: BorderRadius.circular(11),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _addToCart(context, ref, p, selected, mult, qty),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(inLine ? Icons.check : Icons.add,
                              size: 18, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            inLine ? 'אשר' : 'הוסף לסל',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        line2,
                        style: TextStyle(
                          color: inLine
                              ? const Color(0xFFDDF3E2)
                              : const Color(0xFFFFE3D2),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// D6 — the sale-unit chips (בודד · ארגז · משטח), shown only when the product
  /// carries more than one (R8 — no invented pack/pallet counts).
  /// D6 — add the current variant to the smart cart: [qty] of [unitKey], each
  /// unit worth [mult] pieces ⇒ mult × qty pieces total. Toasts confirmation.
  void _addToCart(
    BuildContext context,
    WidgetRef ref,
    LipskeyCatalogProduct p,
    String unitKey,
    int mult,
    int qty,
  ) {
    ref.read(smartCartProvider.notifier).add(
          SmartCartLine(
            productKey: 'lip:${p.sku}',
            productName: p.nameHe,
            productEmoji: _heroEmoji(p),
            brandName: p.brand,
            brandPrice: priceFor(p) ?? 0,
            productQty: mult * qty,
            accessories: const [],
            selection: {'יחידה': unitKey},
          ),
        );
    showToast(context, qty > 1 ? 'נוספו $qty × $unitKey לסל' : 'נוסף לסל');
  }

  /// "+" in the line strip → the line-builder grid (D11/D13) SEEDED from this
  /// product: the palette + "only what mates the neighbour" suggestions +
  /// קו/בדיקה/השלם ("+ פתוח · בחר מוצרים לקו", screen #7 · reconnects the grid
  /// entry the card lost when its קו/בדיקה/השלם row was removed).
  void _openLineGrid(BuildContext context, LipskeyCatalogProduct p) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          14,
          16,
          14,
          16 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: SingleChildScrollView(child: SudokuGrid(seedProduct: p)),
      ),
    );
  }

  // ── D6–D9 · line strip — circles + the smart buttons, only after a product ────
  /// The "pulse" area under the buy button: each added product is a circle (the
  /// last one highlighted), and the קו/בדיקה/השלם buttons appear ONLY once the
  /// line has at least one item. Empty line ⇒ nothing (the base card is just
  /// image + add).
  Widget _lineStrip(
    BuildContext context,
    WidgetRef ref,
    LipskeyCatalogProduct p,
    CatalogSettings s,
  ) {
    final line = ref.watch(smartCartProvider);
    if (line.isEmpty) {
      return const SizedBox.shrink();
    }
    final hot = (highlightLine ?? line.length - 1).clamp(0, line.length - 1);
    return Column(
      key: const Key('internalCardLineStrip'),
      mainAxisSize: MainAxisSize.min,
      children: [
        // No header — the total lives on the green "אשר" button (screen #2).
        // A bare bold "+" (left, per "+ בשמאל") + the product circles.
        Padding(
          padding: const EdgeInsets.fromLTRB(13, 6, 13, 2),
          child: Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // RTL: last-added circle is rightmost, "+" ends up leftmost.
              for (var i = line.length - 1; i >= 0; i--)
                GestureDetector(
                  key: Key('lineCircle_$i'),
                  behavior: HitTestBehavior.opaque,
                  onTap: onTapLine == null ? null : () => onTapLine!(i),
                  child: _lineCircle(
                    line[i].productEmoji,
                    line[i].productQty,
                    highlighted: i == hot,
                  ),
                ),
              // "+" — open the line-builder (grid) seeded from this product:
              // "בחר מוצרים לקו (מרובה)" + קו/בדיקה/השלם (screen #7 "+ פתוח").
              GestureDetector(
                key: const Key('lineAddMore'),
                behavior: HitTestBehavior.opaque,
                onTap: () => _openLineGrid(context, p),
                child: const SizedBox(
                  width: 38,
                  height: 40,
                  child: Center(
                    child: Icon(Icons.add, color: _cAccent, size: 32),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Text(
          'האחרון מודגש · הקש עיגול=בחירה · הקש מודגש=הסרה · +=הוספה',
          style: TextStyle(fontSize: 9.5, color: _cDim),
        ),
      ],
    );
  }

  /// One product in the line — a circle with its emoji + a ×qty badge; the
  /// last-added is highlighted (D8 · "היחיד = המוצר האחרון").
  Widget _lineCircle(String emoji, int qty, {required bool highlighted}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: highlighted ? _cHotBg : _cImgBg,
            border: Border.all(
              color: highlighted ? _cAccent : _cLine,
              width: highlighted ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            emoji.trim().isEmpty ? '📦' : emoji,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        if (qty > 1)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: _cAccent,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                '×$qty',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The gallery's תלת-ממד page: THIS product, welded into a complete connected
/// run. The product leads (its routing revealed so an elbow/tee shows its
/// turn/branch instead of hiding inline) and its real compatible mates close the
/// line — the assembler adds the transition-pipes + end-stubs. A terminator
/// (plug) trails the mates so it caps a real run rather than an empty stub.
/// Empty ⇒ untyped product ⇒ the caller shows the emoji.
List<RunElement> _galleryThreeDRoute(LipskeyCatalogProduct p) {
  final seed = runElementFor(p);
  if (seed == null) return const [];
  final star = _revealRouting(seed);
  final mates = [
    for (final m in compatibleProductsFor(p).take(2))
      if (runElementFor(m) case final RunElement e) e,
  ];
  // A plug terminates the assembler ⇒ put it last so the mates render first.
  return star.family == fm.Family.plug ? [...mates, star] : [star, ...mates];
}

/// Re-stamp a bending fitting so its geometry reads in the static gallery view:
/// an elbow/tee/saddle laid out inline (`Dir.right`) hides its turn behind the
/// pipe. Point it UP and the 90°/branch becomes unmistakable. Straight families
/// (coupler · reducer · valve · adapter · plug · collar) are unchanged.
RunElement _revealRouting(RunElement e) => switch (e.family) {
      fm.Family.elbow90 ||
      fm.Family.elbow45 ||
      fm.Family.miteredElbow ||
      fm.Family.tee ||
      fm.Family.saddle =>
        RunElement(e.family, e.od, dir: fm.Dir.up, od2: e.od2),
      _ => e,
    };

/// D3 — the tap-image gallery: a full-screen dark pager over the product
/// image(s), the spec diagram(s), and a seeded 3D page — each pinch/slider-
/// zoomable, with a ✕, page dots, a zoom slider, and מפרט/תלת-ממד side jumps. A
/// missing asset degrades to the big product emoji (never a broken box).
class _InternalCardGallery extends StatefulWidget {
  const _InternalCardGallery({required this.product, required this.images});

  final LipskeyCatalogProduct product;
  final List<String> images;

  @override
  State<_InternalCardGallery> createState() => _InternalCardGalleryState();
}

class _InternalCardGalleryState extends State<_InternalCardGallery> {
  final PageController _ctrl = PageController();
  final TransformationController _zoom = TransformationController();
  int _page = 0;
  double _scale = 1;

  @override
  void dispose() {
    _ctrl.dispose();
    _zoom.dispose();
    super.dispose();
  }

  void _jumpTo(int page) => _ctrl.animateToPage(
        page,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );

  /// A side-jump chip (מפרט / תלת-ממד) on the gallery edge.
  Widget _galleryThumb(String emoji, String label, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 54,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xF0151F2A),
        body: SafeArea(
          child: Stack(
            children: [
              PageView.builder(
                key: const Key('internalCardGallery'),
                controller: _ctrl,
                itemCount: widget.images.length + 1,
                onPageChanged: (i) => setState(() {
                  _page = i;
                  _scale = 1;
                  _zoom.value = Matrix4.identity();
                }),
                itemBuilder: (context, i) {
                  // The extra last page is the seeded 3D view (תלת-ממד).
                  if (i >= widget.images.length) {
                    final route = _galleryThreeDRoute(widget.product);
                    return Center(
                      child: route.isEmpty
                          ? Text(widget.product.typeEmoji,
                              style: const TextStyle(fontSize: 96))
                          : Container(
                              margin: const EdgeInsets.all(24),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: ProductLine3D(route: route),
                            ),
                    );
                  }
                  return InteractiveViewer(
                    transformationController: i == _page ? _zoom : null,
                    minScale: 1,
                    maxScale: 4,
                    onInteractionEnd: (_) => setState(() =>
                        _scale = _zoom.value.getMaxScaleOnAxis().clamp(1, 4)),
                    child: Center(
                      child: Image(
                        image: resolveProductImage(widget.images[i]),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Text(
                          widget.product.typeEmoji,
                          style: const TextStyle(fontSize: 96),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Side jumps (screen #7): מפרט (spec diagram, right) · תלת-ממד
              // (the 3D page, left).
              if (widget.product.specImageAssets.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _galleryThumb('📐', 'מפרט',
                        () => _jumpTo(widget.product.imageAssets.length)),
                  ),
                ),
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _galleryThumb(
                      '🧊', 'תלת-ממד', () => _jumpTo(widget.images.length)),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black26,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              // Zoom slider (screen #7 · gallery mode): − … slider … 🔍.
              Positioned(
                bottom: 18,
                left: 22,
                right: 22,
                child: Row(
                  children: [
                    const Icon(Icons.remove, color: Colors.white70, size: 20),
                    Expanded(
                      child: Slider(
                        key: const Key('galleryZoom'),
                        value: _scale,
                        min: 1,
                        max: 4,
                        activeColor: _cAccent,
                        onChanged: (v) => setState(() {
                          _scale = v;
                          _zoom.value = Matrix4.diagonal3Values(v, v, v);
                        }),
                      ),
                    ),
                    const Icon(Icons.zoom_in, color: Colors.white70, size: 22),
                  ],
                ),
              ),
              Positioned(
                bottom: 58,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < widget.images.length + 1; i++)
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _page ? _cAccent : Colors.white38,
                        ),
                      ),
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
