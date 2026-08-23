// Smart-nav PROOF-OF-CONCEPT: a self-gating strip of product-category chips for
// the STORE screen. Tapping a category takes the user straight to the catalog
// filtered to that category — proving "tap a suggestion → the app navigates you
// to the result, no menu-hunting."
//
// Self-gates exactly like `SmartSuggestionStrip`: renders NOTHING (a zero-height
// `SizedBox.shrink`) when the `kSmartInputFlag` feature flag is off OR when
// `accessibleNavigation` is active (a11y fallback). OFF → byte-identical store.

import 'package:buildsmart/data/catalog.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:buildsmart/state/feature_flags.dart';
import 'package:buildsmart/widgets/smart_input/models.dart';
import 'package:buildsmart/widgets/smart_input/smart_chip_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A horizontal strip of product-category suggestion chips. Off/a11y → nothing.
/// On pick, [openCatalogCategory] switches to the catalog tab and drills into
/// the tapped category.
class CategorySuggestionStrip extends ConsumerWidget {
  const CategorySuggestionStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(featureFlagsProvider).contains(kSmartInputFlag);
    final a11y = MediaQuery.of(context).accessibleNavigation;
    if (!on || a11y) {
      return const SizedBox.shrink(); // OFF / screen-reader → nothing
    }
    // launch: offer ONLY categories that actually have content — a content-less
    // category would drill into the "הקטגוריה הזו בבנייה" placeholder that the
    // App Store rejects. Mirrors the catalog browse list's own content filter.
    final suggestions = [
      for (final c in kCatalogCats)
        if (categoryHasContent(c.title)) Suggestion(c.title),
    ];
    return SmartChipStrip(
      suggestions: suggestions,
      onPick: (s) => openCatalogCategory(ref, s.text),
    );
  }
}
