import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted per-product accessory state — whether each accessory is checked
/// and its quantity. Restores on card reopen so the user's earlier edits
/// survive a refresh. Roadmap step 7 (acc/qty persistence layer).
///
/// Keyed by **accessory NAME** (not index) so a catalog re-order doesn't
/// corrupt past saves.
@immutable
class AccState {
  const AccState({required this.selected, required this.qty});
  final bool selected;
  final int qty;

  AccState copyWith({bool? selected, int? qty}) =>
      AccState(selected: selected ?? this.selected, qty: qty ?? this.qty);

  Map<String, dynamic> toJson() => {'s': selected, 'q': qty};
  factory AccState.fromJson(Map<String, dynamic> j) =>
      AccState(selected: j['s'] as bool, qty: (j['q'] as num).toInt());
}

class CardAccStateNotifier
    extends StateNotifier<Map<String, Map<String, AccState>>> {
  CardAccStateNotifier() : super(const {}) {
    _load();
  }

  static const _key = 'bs.card-acc-state.v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final outer = jsonDecode(raw) as Map<String, dynamic>;
      state = outer.map((pk, inner) => MapEntry(
            pk,
            (inner as Map<String, dynamic>).map((accName, j) => MapEntry(
                accName, AccState.fromJson(j as Map<String, dynamic>))),
          ));
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final serialised = state.map((pk, inner) =>
        MapEntry(pk, inner.map((k, v) => MapEntry(k, v.toJson()))));
    await prefs.setString(_key, jsonEncode(serialised));
  }

  AccState? get(String productKey, String accName) =>
      state[productKey]?[accName];

  void _update(String productKey, String accName,
      AccState Function(AccState? prev) f) {
    final outer = Map<String, Map<String, AccState>>.from(state);
    final inner = Map<String, AccState>.from(outer[productKey] ?? const {});
    inner[accName] = f(inner[accName]);
    outer[productKey] = inner;
    state = outer;
    _persist();
  }

  void setSelected(String productKey, String accName, bool selected) {
    _update(
        productKey,
        accName,
        (prev) =>
            (prev ?? const AccState(selected: false, qty: 1))
                .copyWith(selected: selected));
  }

  void setQty(String productKey, String accName, int qty) {
    if (qty < 1) qty = 1;
    _update(
        productKey,
        accName,
        (prev) =>
            (prev ?? const AccState(selected: false, qty: 1))
                .copyWith(qty: qty));
  }
}

final cardAccStateProvider =
    StateNotifierProvider<CardAccStateNotifier, Map<String, Map<String, AccState>>>(
  (_) => CardAccStateNotifier(),
);
