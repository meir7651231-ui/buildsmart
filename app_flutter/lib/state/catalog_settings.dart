import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kStorageKey = 'bs.catalog-settings.v1';

enum CatalogViewMode { grid, list }

enum CatalogSort { relevance, priceAsc, rating, newest }

enum CatalogCurrency { ils, usd, eur }

enum CatalogUnit { metric, imperial }

class CatalogSettings {
  const CatalogSettings({
    required this.searchHistoryEnabled,
    required this.viewMode,
    required this.sortDefault,
    required this.showVat,
    required this.currency,
    required this.notifPriceDrop,
    required this.notifBackInStock,
    required this.unit,
    required this.aiRecommendations,
  });

  final bool searchHistoryEnabled;
  final CatalogViewMode viewMode;
  final CatalogSort sortDefault;
  final bool showVat;
  final CatalogCurrency currency;
  final bool notifPriceDrop;
  final bool notifBackInStock;
  final CatalogUnit unit;
  final bool aiRecommendations;

  static const CatalogSettings defaults = CatalogSettings(
    searchHistoryEnabled: true,
    viewMode: CatalogViewMode.grid,
    sortDefault: CatalogSort.relevance,
    showVat: true,
    currency: CatalogCurrency.ils,
    notifPriceDrop: true,
    notifBackInStock: true,
    unit: CatalogUnit.metric,
    aiRecommendations: true,
  );

  CatalogSettings copyWith({
    bool? searchHistoryEnabled,
    CatalogViewMode? viewMode,
    CatalogSort? sortDefault,
    bool? showVat,
    CatalogCurrency? currency,
    bool? notifPriceDrop,
    bool? notifBackInStock,
    CatalogUnit? unit,
    bool? aiRecommendations,
  }) {
    return CatalogSettings(
      searchHistoryEnabled: searchHistoryEnabled ?? this.searchHistoryEnabled,
      viewMode: viewMode ?? this.viewMode,
      sortDefault: sortDefault ?? this.sortDefault,
      showVat: showVat ?? this.showVat,
      currency: currency ?? this.currency,
      notifPriceDrop: notifPriceDrop ?? this.notifPriceDrop,
      notifBackInStock: notifBackInStock ?? this.notifBackInStock,
      unit: unit ?? this.unit,
      aiRecommendations: aiRecommendations ?? this.aiRecommendations,
    );
  }

  Map<String, dynamic> toJson() => {
        'searchHistoryEnabled': searchHistoryEnabled,
        'viewMode': viewMode.name,
        'sortDefault': sortDefault.name,
        'showVat': showVat,
        'currency': currency.name,
        'notifPriceDrop': notifPriceDrop,
        'notifBackInStock': notifBackInStock,
        'unit': unit.name,
        'aiRecommendations': aiRecommendations,
      };

  // Dispatches to defaults via [_enum] / null fallbacks; awkward as a factory.
  // ignore: prefer_constructors_over_static_methods
  static CatalogSettings fromJson(Map<String, dynamic> j) {
    bool b(String k, {bool fallback = true}) =>
        j[k] is bool ? j[k] as bool : fallback;
    return CatalogSettings(
      searchHistoryEnabled: b('searchHistoryEnabled'),
      viewMode: _enum(
        j['viewMode'],
        CatalogViewMode.values,
        CatalogViewMode.grid,
      ),
      sortDefault: _enum(
        j['sortDefault'],
        CatalogSort.values,
        CatalogSort.relevance,
      ),
      showVat: b('showVat'),
      currency: _enum(
        j['currency'],
        CatalogCurrency.values,
        CatalogCurrency.ils,
      ),
      notifPriceDrop: b('notifPriceDrop'),
      notifBackInStock: b('notifBackInStock'),
      unit: _enum(
        j['unit'],
        CatalogUnit.values,
        CatalogUnit.metric,
      ),
      aiRecommendations: b('aiRecommendations'),
    );
  }
}

T _enum<T extends Enum>(Object? raw, List<T> values, T fallback) {
  if (raw is String) {
    for (final v in values) {
      if (v.name == raw) return v;
    }
  }
  return fallback;
}

class CatalogSettingsNotifier extends StateNotifier<CatalogSettings> {
  CatalogSettingsNotifier() : super(CatalogSettings.defaults) {
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kStorageKey);
      if (raw == null) return;
      final j = jsonDecode(raw) as Map<String, dynamic>;
      state = CatalogSettings.fromJson(j);
    } on Object catch (_) {/* keep defaults */}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kStorageKey, jsonEncode(state.toJson()));
    } on Object catch (_) {/* best-effort */}
  }

  void update(CatalogSettings Function(CatalogSettings) f) {
    state = f(state);
    unawaited(_persist());
  }

  Future<void> reset() async {
    state = CatalogSettings.defaults;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kStorageKey);
    } on Object catch (_) {/* ignore */}
  }
}

final catalogSettingsProvider =
    StateNotifierProvider<CatalogSettingsNotifier, CatalogSettings>(
  (_) => CatalogSettingsNotifier(),
);
