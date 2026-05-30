import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Built-in A/B experiment infrastructure (roadmap step 92).
///
/// Stores a persisted `Map<String, String>` of `experimentName → variantName`.
/// Once a variant is assigned for an experiment it sticks across sessions (so
/// the same user keeps seeing the same variant), and can be manually overridden
/// from a debug screen via [override]. Persisted as JSON under a versioned key.
class AbExperimentsNotifier extends StateNotifier<Map<String, String>> {
  AbExperimentsNotifier() : super(const {}) {
    _load();
  }

  static const _key = 'bs.ab-experiments.v1';

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

  /// If [experiment] already has a variant in [state], return it.
  /// Otherwise pick one deterministically from [variants] using
  /// `experiment.hashCode.abs() % variants.length`, persist the
  /// assignment, and return it.
  ///
  /// Throws [ArgumentError] if [variants] is empty.
  String ensure(String experiment, List<String> variants) {
    if (variants.isEmpty) {
      throw ArgumentError.value(
          variants, 'variants', 'must contain at least one variant');
    }
    final existing = state[experiment];
    if (existing != null) return existing;
    final idx = experiment.hashCode.abs() % variants.length;
    final pick = variants[idx];
    state = {...state, experiment: pick};
    _persist();
    return pick;
  }

  /// Returns the assigned variant for [experiment], or `null` if none.
  String? variantOf(String experiment) => state[experiment];

  /// Manually overrides the variant for [experiment] (e.g. from a debug menu).
  void override(String experiment, String variant) {
    if (state[experiment] == variant) return;
    state = {...state, experiment: variant};
    _persist();
  }

  /// Removes any assignment for [experiment].
  void clear(String experiment) {
    if (!state.containsKey(experiment)) return;
    state = {...state}..remove(experiment);
    _persist();
  }
}

final abExperimentsProvider =
    StateNotifierProvider<AbExperimentsNotifier, Map<String, String>>(
  (_) => AbExperimentsNotifier(),
);
