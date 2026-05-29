import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers the last brand the user picked on each SmartProduct card
/// (`productKey → brandName`), so reopening the card restores their choice
/// instead of always defaulting to the recommended brand. Persisted as JSON.
/// Roadmap step 7 (unified persisted selection — brand dimension).
class CardSelectionNotifier extends StateNotifier<Map<String, String>> {
  CardSelectionNotifier() : super(const {}) {
    _load();
  }

  static const _key = 'bs.card-brand-selection.v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      state = m.map((k, v) => MapEntry(k, v as String));
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state));
  }

  String? brandFor(String productKey) => state[productKey];

  void setBrand(String productKey, String brandName) {
    if (state[productKey] == brandName) return;
    state = {...state, productKey: brandName};
    _persist();
  }
}

final cardSelectionProvider =
    StateNotifierProvider<CardSelectionNotifier, Map<String, String>>(
  (_) => CardSelectionNotifier(),
);
