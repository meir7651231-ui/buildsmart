// card_picks.dart — the multi-product LINE basket (P10.92). As the user converges to a
// product they can PICK it; two or more picks can be planned into one installation line
// (P10.98 wraps the existing buildInstallation). Identity-scoped state lives in Riverpod;
// the model + the dedup/order rules are pure and unit-tested.

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One product the user has picked toward a multi-product line. Identity is the [sku]
/// alone — [label] is display only, so re-picking the same product under a different
/// label is a no-op, not a duplicate.
@immutable
class CardPick {
  const CardPick({required this.sku, required this.label});

  final String sku;
  final String label;

  @override
  bool operator ==(Object other) => other is CardPick && other.sku == sku;

  @override
  int get hashCode => sku.hashCode;
}

/// The ordered, sku-deduplicated list of picks for the current line.
class CardPicksNotifier extends StateNotifier<List<CardPick>> {
  CardPicksNotifier() : super(const <CardPick>[]);

  /// True once there are >=2 picks — enough to plan an installation line.
  bool get canCompleteLine => state.length >= 2;

  /// Append [pick] unless its sku is already picked (dedup; insertion order preserved).
  void addPick(CardPick pick) {
    if (state.any((p) => p.sku == pick.sku)) return;
    state = [...state, pick];
  }

  /// Drop the pick with [sku], if present.
  void removePick(String sku) {
    state = state.where((p) => p.sku != sku).toList();
  }

  /// Clear the line.
  void clear() => state = const <CardPick>[];
}

final cardPicksProvider =
    StateNotifierProvider<CardPicksNotifier, List<CardPick>>(
  (ref) => CardPicksNotifier(),
);
