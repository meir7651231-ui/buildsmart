// ─────────────────────────────────────────────────────────────────────────────
// CATALOG-CONFIG · Phase C — the WHEEL. A generic, data-agnostic spinning picker:
// the design's "גלגל עם פס-בחירה" ported onto Flutter's NATIVE wheel
// ([ListWheelScrollView] + [FixedExtentScrollController]) — which gives the
// translateY / perspective / snap the plan asks for with NO manual transform.
// [WheelPicker] knows NOTHING about elbows/manifolds; it renders whatever
// [values] it is handed, styling by the engine [AttributeKind]:
//   • color            → a circular swatch + the Hebrew colour name.
//   • dimension/number → a centred number text.
//   • choice/material/freeText → a centred option text.
// SSOT: knowledge/CATALOG-CONFIG-PLAN.md (§ פאזה C · C.1/C.2).
//
// GATING (plan G · byte-identical-off): a PURE widget with NO `kCatalogConfig`
// branch of its own — reachable only through the gated config card/screen, so it
// tree-shakes out of a default (OFF) build. Nothing imports it outside
// features/catalog_config/.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/domain/trade_schema.dart' show AttributeKind;
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';

/// The pixel height of a single wheel row — the [ListWheelScrollView] itemExtent.
/// Neighbours sit one extent above/below the centred pick.
const double _kItemExtent = 36;

/// The wheel viewport height (~3.6 rows: one centred + dimmed neighbours).
const double _kWheelHeight = 132;

/// The centred SELECTION BAND — a brand-tinted translucent fill (brand @ ~8%)
/// with a rounded (radiusPill) brand hairline outline (brand @ ~40%). Const ARGB,
/// so NO runtime opacity (very_good: no withOpacity).
const Color _kBandFill = Color(0x14FF7A18);
const Color _kBandLine = Color(0x66FF7A18);

/// Colour-swatch palette for an [AttributeKind.color] wheel (plan 🫀). Const
/// ARGB, keyed by the Hebrew colour name; an unknown name → a neutral swatch.
const Color _kSwatchBlue = Color(0xFF2563EB); // כחול
const Color _kSwatchRed = Color(0xFFDC2626); // אדום
const Color _kSwatchWhite = Color(0xFFECECEC); // לבן
const Color _kSwatchBlack = Color(0xFF222222); // שחור
const Color _kSwatchGray = Color(0xFF9AA0A6); // אפור

/// The diameter of a colour-row swatch dot.
const double _kSwatchSize = 14;

/// A wheel's Hebrew label (muted, small, bold) — sits above the spinner.
const TextStyle _kLabelStyle = TextStyle(
  color: BsTokens.mutedLight,
  fontSize: BsTokens.typeLabel,
  fontWeight: FontWeight.w800,
);

/// A generic spinning wheel picker — ONE column of the config card. It renders
/// the handed [values] on Flutter's native [ListWheelScrollView] with a centred
/// selection band; the centred value is brand-highlighted and [onSelected] fires
/// with its index whenever the wheel settles on a new value. GENERIC: it
/// hardcodes no product shape — it draws exactly what it is handed, styled by
/// the engine [AttributeKind].
class WheelPicker extends StatefulWidget {
  const WheelPicker({
    required this.labelHe,
    required this.values,
    required this.selectedIndex,
    required this.onSelected,
    required this.kind,
    super.key,
  });

  /// The wheel's Hebrew label (e.g. `'זווית'`, `'קוטר'`).
  final String labelHe;

  /// The choosable values, in display order.
  final List<String> values;

  /// The index (into [values]) that should be centred.
  final int selectedIndex;

  /// Fired with the newly-centred index whenever the wheel settles on a value.
  final ValueChanged<int> onSelected;

  /// How each row renders — color → swatch + name · every other kind → a
  /// centred value text (number/dimension/choice/material/freeText).
  final AttributeKind kind;

  @override
  State<WheelPicker> createState() => _WheelPickerState();
}

class _WheelPickerState extends State<WheelPicker> {
  late final FixedExtentScrollController _controller;
  late int _current;

  /// The starting (clamped) item — an empty wheel resolves to 0, a stale index is
  /// clamped into range so the controller can never seed out of bounds.
  int get _clampedIndex => widget.values.isEmpty
      ? 0
      : widget.selectedIndex.clamp(0, widget.values.length - 1);

  @override
  void initState() {
    super.initState();
    _current = _clampedIndex;
    _controller = FixedExtentScrollController(initialItem: _current);
  }

  @override
  void didUpdateWidget(WheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // An OUTSIDE-driven index change (the parent re-seeds the selection) animates
    // the wheel to the new pick — but ONLY when it differs from where the wheel
    // already sits, which guards against a feedback loop with [onSelected].
    final target = _clampedIndex;
    if (target != _current && _controller.hasClients) {
      _current = target;
      _controller.animateToItem(
        target,
        duration: BsTokens.microIn,
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(int index) {
    setState(() => _current = index);
    widget.onSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.labelHe,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: _kLabelStyle,
        ),
        const SizedBox(height: BsTokens.space2),
        SizedBox(height: _kWheelHeight, child: _spinner()),
      ],
    );
  }

  Widget _spinner() {
    // GUARD (plan 🛡️ null-fallback) — a valueless wheel shows a single '—'.
    if (widget.values.isEmpty) {
      return const Center(
        child: Text(
          '—',
          style: TextStyle(
            color: BsTokens.mutedLight,
            fontSize: BsTokens.typeSubhead,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        ListWheelScrollView.useDelegate(
          controller: _controller,
          itemExtent: _kItemExtent,
          physics: const FixedExtentScrollPhysics(),
          perspective: 0.0025,
          diameterRatio: 1.6,
          overAndUnderCenterOpacity: 0.35,
          onSelectedItemChanged: _onChanged,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: widget.values.length,
            builder: (context, index) => _row(index),
          ),
        ),
        const IgnorePointer(child: _SelectionBand()),
      ],
    );
  }

  Widget _row(int index) {
    final centred = index == _current;
    final value = widget.values[index];
    // color → a swatch row; every other engine kind → a centred value text.
    if (widget.kind == AttributeKind.color) {
      return _ColorRow(nameHe: value, centred: centred);
    }
    return Center(
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: centred ? BsTokens.brand : BsTokens.inkLight,
          fontSize: BsTokens.typeSubhead,
          fontWeight: centred ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
    );
  }
}

/// The centred selection band — a rounded, brand-tinted translucent strip with a
/// brand hairline outline, overlaid (via [IgnorePointer]) on the wheel's centre.
/// One [_kItemExtent] tall so it frames exactly the centred row.
class _SelectionBand extends StatelessWidget {
  const _SelectionBand();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kItemExtent,
      margin: const EdgeInsets.symmetric(horizontal: BsTokens.space2),
      decoration: BoxDecoration(
        color: _kBandFill,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        border: Border.all(color: _kBandLine, width: 1.2),
      ),
    );
  }
}

/// One row of a colour wheel — a small circular swatch beside the Hebrew name.
/// The swatch carries a stable `Key('wheelSwatch')` so a widget test can assert
/// swatches render without reaching into private geometry.
class _ColorRow extends StatelessWidget {
  const _ColorRow({required this.nameHe, required this.centred});

  final String nameHe;
  final bool centred;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          key: const Key('wheelSwatch'),
          width: _kSwatchSize,
          height: _kSwatchSize,
          decoration: BoxDecoration(
            color: _swatchColor(nameHe),
            shape: BoxShape.circle,
            border: Border.all(color: BsTokens.inkLight, width: 0.5),
          ),
        ),
        const SizedBox(width: BsTokens.space1_5),
        Flexible(
          child: Text(
            nameHe,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: centred ? BsTokens.brand : BsTokens.inkLight,
              fontSize: BsTokens.typeBody,
              fontWeight: centred ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Map a Hebrew colour name → a const swatch colour (plan 🫀). Unknown → muted.
Color _swatchColor(String nameHe) {
  switch (nameHe) {
    case 'כחול':
      return _kSwatchBlue;
    case 'אדום':
      return _kSwatchRed;
    case 'לבן':
      return _kSwatchWhite;
    case 'שחור':
      return _kSwatchBlack;
    case 'אפור':
      return _kSwatchGray;
    default:
      return BsTokens.mutedLight;
  }
}
