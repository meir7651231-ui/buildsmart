import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-product סוג / מידה filter selection — restored on card reopen so the
/// user's filter context doesn't reset every time. Closes Roadmap step 7
/// (was 🟦 — filter dimension was the missing piece alongside brand+acc).
///
/// Shape: `{ productKey: { type?, size? } }`. A null value or empty inner map
/// means no filter for that product (the default). Persisted as JSON under
/// `bs.card-filter-state.v1`.
class CardFilterSelection {
  final String? type;
  final String? size;
  const CardFilterSelection({this.type, this.size});

  bool get isEmpty => type == null && size == null;

  Map<String, dynamic> toJson() => {
        if (type != null) 't': type,
        if (size != null) 's': size,
      };

  static CardFilterSelection fromJson(Map<String, dynamic> j) =>
      CardFilterSelection(
          type: j['t'] as String?, size: j['s'] as String?);
}

class CardFilterStateNotifier
    extends StateNotifier<Map<String, CardFilterSelection>> {
  CardFilterStateNotifier() : super(const {}) {
    _load();
  }

  static const _key = 'bs.card-filter-state.v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    final m = jsonDecode(raw) as Map<String, dynamic>;
    state = m.map((k, v) => MapEntry(
          k,
          CardFilterSelection.fromJson(v as Map<String, dynamic>),
        ));
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final m = state.map((k, v) => MapEntry(k, v.toJson()));
    await prefs.setString(_key, jsonEncode(m));
  }

  CardFilterSelection? get(String productKey) => state[productKey];

  void setType(String productKey, String? type) {
    final cur = state[productKey];
    _put(productKey, CardFilterSelection(type: type, size: cur?.size));
  }

  void setSize(String productKey, String? size) {
    final cur = state[productKey];
    _put(productKey, CardFilterSelection(type: cur?.type, size: size));
  }

  void clear(String productKey) {
    if (!state.containsKey(productKey)) return;
    final next = {...state}..remove(productKey);
    state = next;
    _persist();
  }

  void _put(String productKey, CardFilterSelection next) {
    if (next.isEmpty) {
      clear(productKey);
      return;
    }
    state = {...state, productKey: next};
    _persist();
  }
}

final cardFilterStateProvider = StateNotifierProvider<CardFilterStateNotifier,
    Map<String, CardFilterSelection>>(
  (_) => CardFilterStateNotifier(),
);
