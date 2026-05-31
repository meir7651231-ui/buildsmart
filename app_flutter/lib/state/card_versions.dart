import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A saved named snapshot of a card selection (product + brand), used to
/// compare alternatives later. Distinct from [SavedConfigsNotifier] (which is
/// a single-toggle favourite) and from [CardSelectionNotifier] (which only
/// remembers the *last* brand). Roadmap step 76.
class ConfigVersion {
  const ConfigVersion({
    required this.id,
    required this.label,
    required this.productKey,
    required this.brandName,
    required this.savedAt,
  });

  final String id;
  final String label;
  final String productKey;
  final String brandName;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'productKey': productKey,
        'brandName': brandName,
        'savedAt': savedAt.toIso8601String(),
      };

  factory ConfigVersion.fromJson(Map<String, dynamic> j) => ConfigVersion(
        id: j['id'] as String,
        label: j['label'] as String,
        productKey: j['productKey'] as String,
        brandName: j['brandName'] as String,
        savedAt:
            DateTime.tryParse(j['savedAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class CardVersionsNotifier extends StateNotifier<List<ConfigVersion>> {
  CardVersionsNotifier() : super(const []) {
    _load();
  }

  static const _key = 'bs.card-versions.v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      state = (jsonDecode(raw) as List)
          .map((e) => ConfigVersion.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(state.map((e) => e.toJson()).toList()));
  }

  /// Save a new named version. If a version with the same (productKey, label)
  /// already exists, it's replaced (so re-saving under the same label updates
  /// the brand instead of duplicating). Returns the saved version.
  ConfigVersion save({
    required String label,
    required String productKey,
    required String brandName,
  }) {
    final now = DateTime.now();
    final id = '$productKey|$label|${now.microsecondsSinceEpoch}';
    final v = ConfigVersion(
        id: id,
        label: label,
        productKey: productKey,
        brandName: brandName,
        savedAt: now);
    final filtered = state
        .where((x) => !(x.productKey == productKey && x.label == label))
        .toList();
    state = [...filtered, v];
    _persist();
    return v;
  }

  void remove(String id) {
    state = state.where((x) => x.id != id).toList();
    _persist();
  }

  List<ConfigVersion> forProduct(String productKey) =>
      state.where((x) => x.productKey == productKey).toList();
}

final cardVersionsProvider =
    StateNotifierProvider<CardVersionsNotifier, List<ConfigVersion>>(
  (_) => CardVersionsNotifier(),
);
