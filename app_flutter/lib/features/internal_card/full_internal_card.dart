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
import 'package:buildsmart/features/fittings/ui/sudoku_grid.dart'
    show SudokuGrid;
import 'package:buildsmart/logic/install_engine.dart' show findShortestPath;
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

/// THE full internal card. Give it a [product]; it renders every section the
/// engine can populate for that product, and a swipe on the name cycles the
/// size-variant family (D5). Reusable (any fitting SKU); the home embed +
/// standalone route both seed it with the SmartLock elbow hero.
class FullInternalCard extends ConsumerStatefulWidget {
  const FullInternalCard({
    required this.product,
    this.initialRailSide = 0,
    super.key,
  });

  /// The default hero — SmartLock ברך 90° 50 (real SKU; mockup's 120050 is not
  /// in the catalog). Resolved via [catalogProductForSku].
  static const String heroSku = '70055960';

  final LipskeyCatalogProduct product;

  /// D4 — pre-open a side rail on first build (previews/tests): -1 left, +1 right.
  final int initialRailSide;

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

  /// D5 — step the variant family by [dir] (clamped to the ends). The whole card
  /// re-resolves against the new SKU (name · image · spec · variants).
  void _stepVariant(int dir) {
    final fam = variantSiblingsOf(_current);
    if (fam.length < 2) {
      return;
    }
    final i = fam.indexWhere((s) => s.sku == _current.sku);
    final next = (i + dir).clamp(0, fam.length - 1);
    if (next != i) {
      setState(() => _current = fam[next]);
    }
  }

  /// D6 — the chosen sale unit (בודד / ארגז / משטח).
  String _unit = 'בודד';

  void _pickUnit(String u) => setState(() => _unit = u);

  /// D15 — the spec is HIDDEN behind the 📋 clipboard; tapping it swaps the big
  /// product image for the spec panel in place (the card is image-first, not a
  /// text dump).
  bool _specOpen = false;

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
        onStepVariant: _stepVariant,
        onPickUnit: _pickUnit,
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
    this.onStepVariant,
    this.onPickUnit,
    this.onToggleSpec,
    this.onPickSpecTab,
    this.onSwipeImage,
  });

  final LipskeyCatalogProduct product;

  /// D6 — the selected sale-unit key (בודד / ארגז / משטח).
  final String unit;

  /// D15 — whether the 📋 spec panel is showing (in place of the big image).
  final bool specOpen;

  /// D15 — the active spec tab index.
  final int specTab;

  /// D5 — the name-swipe steps the variant family by ±1 (null ⇒ inert).
  final void Function(int dir)? onStepVariant;

  /// D6 — pick a sale unit (null ⇒ inert).
  final void Function(String unit)? onPickUnit;

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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: _cCard),
        child: Column(
          key: const Key('fullInternalCard'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _topBar(context, p),
            // Image-first: the big product image is the hero; the 📋 clipboard
            // swaps it for the spec panel in place (D15) — spec is never spilled.
            if (specOpen)
              _specPanel(context, p, settings)
            else if (railSide != 0)
              _sideRail(context, p, railSide)
            else
              _bigImage(context, p),
            _footer(p),
            _buyArea(context, ref, p, settings),
            // D6–D9/D14 — the line strip (circles + קו/בדיקה/השלם) appears ONLY
            // after a product is added; the base card is just image + add.
            _lineStrip(context, ref, p),
          ],
        ),
      ),
    );
  }

  // ── top bar (📋 spec toggle · SKU embossed · → next) ──────────────────────────
  Widget _topBar(BuildContext context, LipskeyCatalogProduct p) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 6),
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
            const Text('→', style: TextStyle(fontSize: 20, color: _cAccent)),
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
        height: 236,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
        decoration: BoxDecoration(
          color: _cImgBg,
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        child: asset == null
            ? Text(_heroEmoji(p), style: const TextStyle(fontSize: 104))
            : Image(
                image: resolveProductImage(asset),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    Text(_heroEmoji(p), style: const TextStyle(fontSize: 104)),
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
        height: 236,
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
            // Header label.
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // D5 — swiping the name steps the variant family (size).
          GestureDetector(
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
            child: Text(
              p.nameHe,
              key: const Key('internalCardName'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: _cInk,
              ),
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
        ],
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
      height: 236,
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
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < fam.length; i++)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == sel ? _cAccent : _cLine,
              ),
            ),
        ],
      ),
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
        base == null ? '' : ' · ${formatCatalogPrice(base * mult, s)}';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (units.length > 1) _unitSelector(units, selected),
        Container(
          margin: const EdgeInsets.fromLTRB(13, 8, 13, 13),
          child: Material(
            key: const Key('internalCardBuy'),
            color: _cAccent,
            borderRadius: BorderRadius.circular(11),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _addToCart(context, ref, p, selected, mult),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    '＋ הוסף לסל$priceStr',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
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
  Widget _unitSelector(Map<String, int> units, String selected) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(13, 4, 13, 0),
      child: Row(
        children: [
          for (final e in units.entries)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onPickUnit == null ? null : () => onPickUnit!(e.key),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: e.key == selected ? _cAccent : _cImgBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: e.key == selected ? _cAccent : _cLine,
                    ),
                  ),
                  child: Text(
                    e.value == 1 ? e.key : '${e.key} · ${e.value}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: e.key == selected ? Colors.white : _cInk,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// D6 — add the current variant to the smart cart in the selected unit
  /// (quantity = the unit's piece-count). Toasts confirmation.
  void _addToCart(
    BuildContext context,
    WidgetRef ref,
    LipskeyCatalogProduct p,
    String unitKey,
    int mult,
  ) {
    ref.read(smartCartProvider.notifier).add(
          SmartCartLine(
            productKey: 'lip:${p.sku}',
            productName: p.nameHe,
            productEmoji: _heroEmoji(p),
            brandName: p.brand,
            brandPrice: priceFor(p) ?? 0,
            productQty: mult,
            accessories: const [],
            selection: {'יחידה': unitKey},
          ),
        );
    showToast(context, 'נוסף לסל');
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
  ) {
    final line = ref.watch(smartCartProvider);
    if (line.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      key: const Key('internalCardLineStrip'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(13, 10, 13, 2),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < line.length; i++)
                _lineCircle(
                  line[i].productEmoji,
                  highlighted: i == line.length - 1,
                ),
            ],
          ),
        ),
        _lineActions(context, ref, p),
      ],
    );
  }

  /// One product in the line — a circle with its emoji; the last-added is
  /// highlighted (D8 · "היחיד = המוצר האחרון").
  Widget _lineCircle(String emoji, {required bool highlighted}) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: highlighted ? _cHotBg : _cImgBg,
        border: Border.all(
          color: highlighted ? _cAccent : _cLine,
          width: highlighted ? 2 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 20)),
    );
  }

  // ── D14 · line actions (קו · בדיקה · השלם) ───────────────────────────────────
  /// Three connection actions over the live install engine. "קו" seeds the line
  /// (the cart-derived line the engine reads); "בדיקה" reports the product's
  /// per-end needs + direct-mate count; "השלם" runs the (ungated) BFS solver
  /// `findShortestPath` from this product to its best partner and shows the
  /// auto-completed path (connectors inserted by the engine). The full
  /// multi-fixture line is the D11/D12 grid endgame — here it is card-scoped.
  Widget _lineActions(
    BuildContext context,
    WidgetRef ref,
    LipskeyCatalogProduct p,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(13, 8, 13, 0),
      child: Row(
        children: [
          Expanded(
            child: _lineBtn(
              '🔗 קו',
              const Key('lineBtnLine'),
              () => _openGrid(context, p),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _lineBtn(
              '🔍 בדיקה',
              const Key('lineBtnCheck'),
              () => _showCheck(context, p),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _lineBtn(
              '🧩 השלם',
              const Key('lineBtnSolve'),
              () => _showSolve(context, p),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lineBtn(String label, Key key, VoidCallback onTap) {
    return Material(
      key: key,
      color: _cImgBg,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _cLine),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: _cInk,
            ),
          ),
        ),
      ),
    );
  }

  /// קו — seed the line (the cart is the line the engine reads).
  /// קו — opens the sudoku line-builder grid (D11/D13) in a sheet: the
  /// engine-driven "only what mates the neighbour" board (P6·6).
  void _openGrid(BuildContext context, LipskeyCatalogProduct p) {
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

  /// בדיקה — per-end needs + direct-mate count + any connection warning.
  void _showCheck(BuildContext context, LipskeyCatalogProduct p) {
    final compat = compatibleProductsFor(p);
    final warn = connectionWarningHe(p);
    final lines = <String>[
      if (compat.isEmpty)
        'אין תואם ישיר בקטלוג'
      else
        'מתחבר ישירות ל־${compat.length} מוצרים',
      if (warn != null) '⚠️ $warn',
      ...connectionNeedsHe(p),
    ];
    _infoSheet(context, '🔍 בדיקת חיבורים', lines);
  }

  /// השלם — run the BFS solver from this product to its best partner and show
  /// the auto-completed path (the engine inserts any needed connectors).
  void _showSolve(BuildContext context, LipskeyCatalogProduct p) {
    final compat = compatibleProductsFor(p);
    if (compat.isEmpty) {
      showToast(context, 'אין מוצר תואם להשלמה');
      return;
    }
    final path = findShortestPath(p, compat.first);
    if (path == null || path.isEmpty) {
      showToast(context, 'לא נמצא מסלול חיבור');
      return;
    }
    _infoSheet(
      context,
      '🧩 השלמת חיבור · ${path.length} פריטים',
      [
        for (var i = 0; i < path.length; i++)
          '${i + 1}. ${_heroEmoji(path[i])} ${path[i].nameHe}',
      ],
    );
  }

  void _infoSheet(BuildContext context, String title, List<String> lines) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _cCard,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _cInk,
                  ),
                ),
                const SizedBox(height: 10),
                if (lines.isEmpty)
                  const Text('אין נתונים', style: TextStyle(color: _cDim))
                else
                  for (final l in lines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        l,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: _cInk,
                          height: 1.3,
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

/// D3 — the tap-image gallery: a full-screen dark pager over the product image(s)
/// then the spec diagram(s), each pinch-zoomable, with a ✕ and page dots. A
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
  int _page = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
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
                itemCount: widget.images.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => InteractiveViewer(
                  maxScale: 4,
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
              if (widget.images.length > 1)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < widget.images.length; i++)
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
