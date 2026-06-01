import 'package:buildsmart/data/catalog_lens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The currently-selected catalog lens (the list-level view-axis chosen via the
/// selector chips OUTSIDE the product card). Transient by design — like the
/// grid/list view toggle, it resets per session rather than persisting, since
/// the right lens depends on what the user is browsing right now.
///
/// Defaults to [CatalogLens.category] (the familiar flat list). When the active
/// product set doesn't support the selected lens (see [availableLensesForSet]),
/// the UI falls back to category — so this provider never strands the list on
/// an empty lens.
final catalogLensProvider =
    StateProvider<CatalogLens>((_) => CatalogLens.category);

/// Resolve the lens to actually USE for [available] lenses: the selected one if
/// it's still available for the current set, else the first available
/// (category is always available, so this never returns something unusable).
CatalogLens resolveActiveLens(
  CatalogLens selected,
  List<CatalogLens> available,
) {
  if (available.contains(selected)) return selected;
  return available.isEmpty ? CatalogLens.category : available.first;
}
