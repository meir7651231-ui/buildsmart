// QuickPadKeyboard — a quantity-key keyboard in the approved BsKeyboard
// aesthetic, for "punching item + quantity" fast.
//
// Each [QuickPadItem] renders as a small block: a plain (icon-free) product
// label key plus a compact quantity stepper — a '−' key, the current qty
// number, and a '+' key. Tapping the product label calls [onAdd] with the
// item and its current quantity. Every key is a KbKey(kind: KeyKind.letter),
// which BsKey draws as plain text with NO Material icon (see BsKey._iconFor →
// null for KeyKind.letter); the stepper uses the text glyphs '+' and '−'
// rather than icons.
//
// Quantity is held per-item in local State: default 1, never below 1.
//
// Like [WordKeyboard]/[BsKeyboard], the whole keyboard is pinned to
// [TextDirection.ltr] + Material(surfaceMid) so the key ORDER stays stable
// inside the otherwise-RTL app, while Hebrew labels still render RTL within
// each key. Rows use the Expanded/flex idiom with [BsTokens.space1] gaps.

import 'package:buildsmart/features/word_finder/quick_pad_item.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_key.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/key_models.dart';
import 'package:flutter/material.dart';

/// Upper bound for a per-item quantity on the [QuickPadKeyboard]. The '+'
/// stepper caps here so a stuck/long-press can't run the count away; the
/// matching lower floor is 1 (see [_QuickPadKeyboardState._decrement]).
const int kMaxQty = 99; // OWNER-REVIEW value

/// A keyboard of product "quantity keys", styled like `BsKeyboard`.
///
/// [items] are chunked into rows of [_itemsPerRow]; each item is a column of
/// (label key, qty stepper). Tapping the label key fires
/// `onAdd(item, currentQty)`. The optional trailing utility key — `מצב רגיל`
/// — fires [onSwitchMode]. No Material icons anywhere: the stepper uses the
/// text glyphs '+' / '−' and all keys are [KeyKind.letter].
class QuickPadKeyboard extends StatefulWidget {
  const QuickPadKeyboard({
    required this.items,
    required this.onAdd,
    super.key,
    this.onSwitchMode,
  });

  /// The product items to render, in order.
  final List<QuickPadItem> items;

  /// Invoked with the tapped [QuickPadItem] and its current quantity.
  final void Function(QuickPadItem item, int qty) onAdd;

  /// Optional utility key to switch back to the regular browsing mode.
  final void Function()? onSwitchMode;

  /// Items per row before wrapping to the next row. Each item is a label key
  /// plus a stepper, so the pad stays compact at two per row.
  static const int _itemsPerRow = 2;

  /// Text glyphs for the stepper — NOT Material icons.
  static const String _minusGlyph = '−'; // U+2212 MINUS SIGN
  static const String _plusGlyph = '+';

  @override
  State<QuickPadKeyboard> createState() => _QuickPadKeyboardState();
}

class _QuickPadKeyboardState extends State<QuickPadKeyboard> {
  /// Per-item quantity, keyed by the item's STABLE identity (its payload — the
  /// catalog product instance — falling back to its label), NOT the list index.
  /// A same-length REORDER of items (a favorites swap, or a re-viewed recent
  /// moving to the front) would otherwise leave the old index→count binding in
  /// place and add the WRONG quantity (naming the wrong product) to the cart.
  /// Keying by identity makes any reorder harmless. Absent key ⇒ quantity 1;
  /// floored at 1, capped at kMaxQty. (Fix: canonical audit, money-numeric lens.)
  final Map<Object, int> _qty = <Object, int>{};

  /// The stable identity key for an item: its payload (the product) when set,
  /// else its label — so [_qty] follows the product, never the slot.
  Object _key(QuickPadItem item) => item.payload ?? item.label;

  /// The current quantity for [item] (defaults to 1 when never stepped).
  int _qtyOf(QuickPadItem item) => _qty[_key(item)] ?? 1;

  void _increment(QuickPadItem item) {
    setState(() {
      final next = _qtyOf(item) + 1;
      _qty[_key(item)] = next > kMaxQty ? kMaxQty : next; // cap at kMaxQty
    });
  }

  void _decrement(QuickPadItem item) {
    setState(() {
      final next = _qtyOf(item) - 1;
      _qty[_key(item)] = next < 1 ? 1 : next; // floor at 1
    });
  }

  /// Builds one product cell: the label key (routes to onAdd) above a compact
  /// stepper row ('−' | qty | '+'). All keys are icon-free KeyKind.letter.
  ///
  /// A11Y: the stepper keys render bare glyphs ('−' / '+' / a number), which a
  /// screen reader would otherwise announce as "minus sign" / "plus" / a lone
  /// digit with no idea what is being changed. Each is wrapped in a [Semantics]
  /// node that NAMES the action and the product (e.g. "הוסף אחד · <product>")
  /// and the qty readout exposes the count as a [Semantics.value]. The glyph's
  /// own inner Semantics is suppressed (`excludeSemantics: true`) so the symbol
  /// is not double-announced. // OWNER-REVIEW: the spoken stepper copy.
  Widget _buildItemCell(int index) {
    final item = widget.items[index];
    final qty = _qtyOf(item);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The product label — tapping it adds `qty` of this item.
        BsKey(
          // KeyKind.letter → BsKey renders the label as plain text, no icon.
          model: KbKey(item.label),
          onTap: () => widget.onAdd(item, _qtyOf(item)),
        ),
        const SizedBox(height: BsTokens.space1),
        // Compact stepper: '−'  qty  '+' — text glyphs, no Material icons.
        Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                excludeSemantics: true, // suppress the bare '−' glyph label
                // OWNER-REVIEW: "decrease quantity of <product>".
                label: 'הפחת כמות · ${item.label}',
                // a11y: the tap action must live on the LABELLED node —
                // excludeSemantics drops BsKey's InkWell action, so without this
                // an AT double-tap is a no-op (announced-but-inoperable).
                onTap: () => _decrement(item),
                child: BsKey(
                  model: const KbKey(QuickPadKeyboard._minusGlyph),
                  onTap: () => _decrement(item),
                ),
              ),
            ),
            const SizedBox(width: BsTokens.space1),
            Expanded(
              child: Semantics(
                // OWNER-REVIEW: "quantity" + the value spoken as the count.
                label: 'כמות',
                value: '$qty',
                excludeSemantics: true, // the bare number reads via `value`
                child: BsKey(
                  model: KbKey('$qty'),
                  // Tapping the qty readout is a no-op affordance; it carries the
                  // count visually. Routed to onAdd so a tap there still adds.
                  onTap: () => widget.onAdd(item, _qtyOf(item)),
                ),
              ),
            ),
            const SizedBox(width: BsTokens.space1),
            Expanded(
              child: Semantics(
                button: true,
                excludeSemantics: true, // suppress the bare '+' glyph label
                // OWNER-REVIEW: "increase quantity of <product>".
                label: 'הוסף כמות · ${item.label}',
                // a11y: tap action on the LABELLED node (excludeSemantics drops
                // the child InkWell action) so AT can actually activate the +.
                onTap: () => _increment(item),
                child: BsKey(
                  model: const KbKey(QuickPadKeyboard._plusGlyph),
                  onTap: () => _increment(item),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds one row of product cells with uniform [Expanded] flex and
  /// [BsTokens.space1] gaps — the BsKeyboard row idiom.
  Widget _buildItemRow(int start, int end) {
    final children = <Widget>[];
    for (var i = start; i < end; i++) {
      if (i > start) children.add(const SizedBox(width: BsTokens.space1));
      children.add(Expanded(child: _buildItemCell(i)));
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  /// Builds the trailing utility row: a single icon-free `מצב רגיל` key routed
  /// to [QuickPadKeyboard.onSwitchMode]. Omitted entirely when no callback.
  Widget _buildUtilityRow() {
    return Row(
      children: [
        Expanded(
          child: BsKey(
            model: const KbKey('מצב רגיל'),
            onTap: () => widget.onSwitchMode?.call(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final rowWidgets = <Widget>[];
    for (var i = 0; i < widget.items.length; i += QuickPadKeyboard._itemsPerRow) {
      final end = (i + QuickPadKeyboard._itemsPerRow < widget.items.length)
          ? i + QuickPadKeyboard._itemsPerRow
          : widget.items.length;
      rowWidgets
        ..add(_buildItemRow(i, end))
        ..add(const SizedBox(height: BsTokens.space1));
    }
    if (widget.onSwitchMode != null) {
      rowWidgets.add(_buildUtilityRow());
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: BsTokens.surfaceMid,
        child: Padding(
          padding: const EdgeInsets.all(BsTokens.space1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: rowWidgets,
          ),
        ),
      ),
    );
  }
}
