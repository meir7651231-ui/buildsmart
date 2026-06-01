import 'package:buildsmart/data/catalog_lens.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/state/catalog_lens_state.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Step 3 of the lens selector — the LIST-LEVEL view-axis control that lives
/// OUTSIDE the product card. A row of chips (📂 קטגוריה / 🎚 וריאנטים / 🌳 עץ-חכם)
/// that re-organises the product list it sits above. Only the lenses that are
/// MEANINGFUL for [products] are shown (see [availableLensesForSet]) — a
/// raw-parts list like copper fittings or PPR shows no 🌳, a single-category
/// set shows nothing at all.
///
/// Reads/writes [catalogLensProvider]. Tapping a chip changes the active lens;
/// the host list then renders `groupByLens(products, activeLens)`. This widget
/// renders NOTHING when fewer than two lenses apply (a 1-option selector is
/// noise), so the default category-only screens are visually unchanged.
class LensSelectorRow extends ConsumerWidget {
  const LensSelectorRow({required this.products, super.key});

  final List<LipskeyCatalogProduct> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final available = availableLensesForSet(products);
    // A selector with one (or zero) option is noise — render nothing so the
    // familiar category-only list is untouched.
    if (available.length < 2) return const SizedBox.shrink();

    final selected = ref.watch(catalogLensProvider);
    final active = resolveActiveLens(selected, available);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          const Text(
            'סדר לפי:',
            style: TextStyle(
              color: Color(0xFF888888),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 6,
              children: [
                for (final lens in available)
                  _LensChip(
                    lens: lens,
                    active: lens == active,
                    onTap: () =>
                        ref.read(catalogLensProvider.notifier).state = lens,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LensChip extends StatelessWidget {
  const _LensChip({
    required this.lens,
    required this.active,
    required this.onTap,
  });

  final CatalogLens lens;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? BsTokens.brand : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? BsTokens.brand : const Color(0xFFC8C8CE),
          ),
        ),
        child: Text(
          lens.chipLabel,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF6E6E73),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
