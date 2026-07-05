// FindKeyboardPanel — the keyboard AS the product-finder (owner pivot 30/6).
//
// The merged engine's chips render AS KEYS (the grid), each tapped key RISES to
// the prediction row (the answered path), and the next options become the keys —
// the keyboard itself narrows to a product, with NO separate "what fits?" screen
// and NOTHING bolted onto the product card. Driven by the pure [FindSession];
// reaching a product opens the existing product sheet (the proven terminus).
//
// This is a self-contained panel (it owns one [FindSession]); the floating
// keyboard hosts it as its find-mode body. Kept additive so the other keyboard
// modes stay byte-identical.

import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;
import 'package:buildsmart/features/card_keyboard/card_engine.dart'
    show
        CardAskWords,
        CardResolve,
        CardShowProducts,
        CardVerdict,
        MergedKeys,
        SignalChip;
import 'package:buildsmart/features/card_keyboard/find_session.dart'
    show FindSession;
import 'package:buildsmart/screens/lipskey_product_sheet.dart'
    show showLipskeyProductSheet;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The find-mode keyboard body. Self-contained: owns the dive [FindSession] and
/// rebuilds the grid + the prediction row from its verdict after every tap.
class FindKeyboardPanel extends ConsumerStatefulWidget {
  const FindKeyboardPanel({super.key, this.onExit, this.onOpenProduct});

  /// Leave find-mode (the 'אבג' key) — the host clears its find flag so the
  /// normal keyboard returns. Null on a standalone mount.
  final VoidCallback? onExit;

  /// Opens the product sheet through a CALLER-supplied context. The floating host
  /// passes a callback that opens the sheet via its ROOT-navigator context, so
  /// the sheet works under KB_GLOBAL where this panel sits ABOVE the app Navigator
  /// (else showModalBottomSheet → Navigator.of() throws 'No Navigator found' — the
  /// finder product-tap crash the Android/KB_GLOBAL audit found). Null → the
  /// panel's own context (a standalone/manual mount that IS under a Navigator).
  final void Function(
    LipskeyCatalogProduct product,
    List<LipskeyCatalogProduct> siblings,
  )? onOpenProduct;

  @override
  ConsumerState<FindKeyboardPanel> createState() => _FindKeyboardPanelState();
}

class _FindKeyboardPanelState extends ConsumerState<FindKeyboardPanel> {
  final FindSession _find = FindSession();

  void _onWord(String w) => setState(() => _find.pushWord(w));
  void _onChip(SignalChip c) => setState(() => _find.pushChip(c));
  void _back() => setState(_find.pop);
  void _reset() => setState(_find.reset);

  void _openProduct(
    LipskeyCatalogProduct product,
    List<LipskeyCatalogProduct> siblings,
  ) {
    final open = widget.onOpenProduct;
    if (open != null) {
      // The host opens the sheet via its ROOT-navigator context (KB_GLOBAL-safe).
      open(product, siblings);
    } else {
      showLipskeyProductSheet(context, product, siblings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = _find.verdict;
    final cs = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _selectionRow(cs),
            const SizedBox(height: 8),
            _topRow(cs, v),
            const SizedBox(height: 8),
            // Cap the key grid at ~34% of the screen height and SCROLL it, so a
            // large verdict (up to ~38 product keys) never overflows off the top
            // of a short / landscape phone with unreachable keys (Android audit).
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.34,
              ),
              child: SingleChildScrollView(child: _grid(cs, v)),
            ),
          ],
        ),
      ),
    );
  }

  /// The prediction row — the answered path that RISES here on each tap.
  Widget _selectionRow(ColorScheme cs) {
    final sel = _find.selection;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: sel.isEmpty
          ? Text(
              'הקש מקש — והוא יעלה לכאן',
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            )
          : Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final s in sel)
                  Chip(
                    label: Text(s),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: cs.surface,
                    side: BorderSide(color: cs.primary),
                    labelStyle: TextStyle(color: cs.primary, fontSize: 13),
                  ),
              ],
            ),
    );
  }

  /// Back + restart + a one-line hint for the current turn.
  Widget _topRow(ColorScheme cs, CardVerdict v) {
    final hint = switch (v) {
      CardAskWords(:final questionHe) => questionHe,
      MergedKeys() => 'בחר כדי לצמצם',
      CardShowProducts() => 'בחר מוצר',
      CardResolve() => 'מצאתי — הקש לפתיחה',
    };
    return Row(
      children: [
        TextButton(
          onPressed: () => widget.onExit?.call(),
          child: const Text('אבג'),
        ),
        if (_find.selection.isNotEmpty)
          TextButton.icon(
            onPressed: _back,
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('חזרה'),
          ),
        if (_find.selection.isNotEmpty)
          TextButton(onPressed: _reset, child: const Text('התחל שוב')),
        const Spacer(),
        Flexible(
          child: Text(
            hint,
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  /// The KEY GRID — the engine's current options, rendered as keys.
  Widget _grid(ColorScheme cs, CardVerdict v) {
    final keys = <Widget>[];
    switch (v) {
      case CardAskWords(:final words):
        for (final w in words) {
          keys.add(_key(cs, w.word, () => _onWord(w.word)));
        }
      case MergedKeys(:final chips):
        for (final c in chips) {
          keys.add(_key(cs, c.displayLabel, () => _onChip(c),
              accent: c.isDestination));
        }
      case CardShowProducts(:final products):
        for (final p in products) {
          keys.add(_key(cs, p.nameHe, () => _openProduct(p, products),
              product: true));
        }
      case CardResolve(:final product, :final siblings):
        keys.add(_key(cs, product.nameHe, () => _openProduct(product, siblings),
            product: true));
    }
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(spacing: 8, runSpacing: 8, children: keys),
    );
  }

  /// One key — a content tile (chip/word/product) styled like a keyboard key.
  Widget _key(
    ColorScheme cs,
    String label,
    VoidCallback onTap, {
    bool accent = false,
    bool product = false,
  }) {
    final border = product || accent ? cs.primary : cs.outlineVariant;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          // 48dp min touch target (Android audit) + a max width so a long Hebrew
          // product name ellipsizes instead of overflowing the Wrap line.
          constraints: BoxConstraints(
            minHeight: 48,
            maxWidth: MediaQuery.of(context).size.width * 0.82,
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border, width: product ? 2 : 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (product) ...[
                Icon(Icons.inventory_2_outlined, size: 16, color: cs.primary),
                const SizedBox(width: 6),
              ],
              Flexible(
                // OWNER (readability): scale an over-long finder-dive chip label
                // DOWN to fit rather than truncating it to "…", so every product /
                // word chip in the finder stays fully readable.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 14,
                      color: product ? cs.primary : cs.onSurface,
                      fontWeight: product ? FontWeight.w500 : FontWeight.w400,
                    ),
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
