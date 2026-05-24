import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kStorageKey = 'bs.catalog-settings.v1';

enum CatalogViewMode { grid, list }

enum CatalogSort { relevance, priceAsc, rating, newest }

enum CatalogCurrency { ils, usd, eur }

enum CatalogUnit { metric, imperial }

enum CatalogImageSize { small, medium, large }

enum CatalogDecimalFormat { decimal, fraction }

enum CatalogMinRating { any, three, four, five }

enum CatalogTextSize { small, medium, large }

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
    // Section 1 — Search
    required this.quickFilterBar,
    required this.searchRadius,
    // Section 2 — Display
    required this.gridColumns,
    required this.imageSize,
    // Section 3 — Prices
    required this.showUnitPrice,
    required this.priceComparison,
    // Section 4 — Favorites
    required this.syncFavorites,
    required this.listsPerProject,
    required this.priceChangeAlert,
    // Section 5 — Catalog Notifications
    required this.notifLowStock,
    required this.notifNewProducts,
    // Section 6 — Units
    required this.decimalFormat,
    // Section 7 — Suppliers
    required this.maxDistance,
    required this.minRating,
    required this.localSuppliersOnly,
    // Section 8 — AI
    required this.historyBased,
    required this.activeProjectFilter,
    required this.cheapAlternatives,
    // Section 9 — Interface
    required this.compactMode,
    required this.textSize,
    required this.highContrast,
    required this.reducedMotion,
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

  // Section 1 — Search
  final bool quickFilterBar;
  final int searchRadius;

  // Section 2 — Display
  final int gridColumns;
  final CatalogImageSize imageSize;

  // Section 3 — Prices
  final bool showUnitPrice;
  final bool priceComparison;

  // Section 4 — Favorites
  final bool syncFavorites;
  final bool listsPerProject;
  final bool priceChangeAlert;

  // Section 5 — Catalog Notifications
  final bool notifLowStock;
  final bool notifNewProducts;

  // Section 6 — Units
  final CatalogDecimalFormat decimalFormat;

  // Section 7 — Suppliers
  final int maxDistance;
  final CatalogMinRating minRating;
  final bool localSuppliersOnly;

  // Section 8 — AI
  final bool historyBased;
  final bool activeProjectFilter;
  final bool cheapAlternatives;

  // Section 9 — Interface
  final bool compactMode;
  final CatalogTextSize textSize;
  final bool highContrast;
  final bool reducedMotion;

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
    quickFilterBar: true,
    searchRadius: 50,
    gridColumns: 2,
    imageSize: CatalogImageSize.medium,
    showUnitPrice: true,
    priceComparison: true,
    syncFavorites: true,
    listsPerProject: true,
    priceChangeAlert: true,
    notifLowStock: true,
    notifNewProducts: false,
    decimalFormat: CatalogDecimalFormat.decimal,
    maxDistance: 100,
    minRating: CatalogMinRating.any,
    localSuppliersOnly: false,
    historyBased: true,
    activeProjectFilter: false,
    cheapAlternatives: true,
    compactMode: false,
    textSize: CatalogTextSize.medium,
    highContrast: false,
    reducedMotion: false,
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
    bool? quickFilterBar,
    int? searchRadius,
    int? gridColumns,
    CatalogImageSize? imageSize,
    bool? showUnitPrice,
    bool? priceComparison,
    bool? syncFavorites,
    bool? listsPerProject,
    bool? priceChangeAlert,
    bool? notifLowStock,
    bool? notifNewProducts,
    CatalogDecimalFormat? decimalFormat,
    int? maxDistance,
    CatalogMinRating? minRating,
    bool? localSuppliersOnly,
    bool? historyBased,
    bool? activeProjectFilter,
    bool? cheapAlternatives,
    bool? compactMode,
    CatalogTextSize? textSize,
    bool? highContrast,
    bool? reducedMotion,
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
      quickFilterBar: quickFilterBar ?? this.quickFilterBar,
      searchRadius: searchRadius ?? this.searchRadius,
      gridColumns: gridColumns ?? this.gridColumns,
      imageSize: imageSize ?? this.imageSize,
      showUnitPrice: showUnitPrice ?? this.showUnitPrice,
      priceComparison: priceComparison ?? this.priceComparison,
      syncFavorites: syncFavorites ?? this.syncFavorites,
      listsPerProject: listsPerProject ?? this.listsPerProject,
      priceChangeAlert: priceChangeAlert ?? this.priceChangeAlert,
      notifLowStock: notifLowStock ?? this.notifLowStock,
      notifNewProducts: notifNewProducts ?? this.notifNewProducts,
      decimalFormat: decimalFormat ?? this.decimalFormat,
      maxDistance: maxDistance ?? this.maxDistance,
      minRating: minRating ?? this.minRating,
      localSuppliersOnly: localSuppliersOnly ?? this.localSuppliersOnly,
      historyBased: historyBased ?? this.historyBased,
      activeProjectFilter: activeProjectFilter ?? this.activeProjectFilter,
      cheapAlternatives: cheapAlternatives ?? this.cheapAlternatives,
      compactMode: compactMode ?? this.compactMode,
      textSize: textSize ?? this.textSize,
      highContrast: highContrast ?? this.highContrast,
      reducedMotion: reducedMotion ?? this.reducedMotion,
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
        'quickFilterBar': quickFilterBar,
        'searchRadius': searchRadius,
        'gridColumns': gridColumns,
        'imageSize': imageSize.name,
        'showUnitPrice': showUnitPrice,
        'priceComparison': priceComparison,
        'syncFavorites': syncFavorites,
        'listsPerProject': listsPerProject,
        'priceChangeAlert': priceChangeAlert,
        'notifLowStock': notifLowStock,
        'notifNewProducts': notifNewProducts,
        'decimalFormat': decimalFormat.name,
        'maxDistance': maxDistance,
        'minRating': minRating.name,
        'localSuppliersOnly': localSuppliersOnly,
        'historyBased': historyBased,
        'activeProjectFilter': activeProjectFilter,
        'cheapAlternatives': cheapAlternatives,
        'compactMode': compactMode,
        'textSize': textSize.name,
        'highContrast': highContrast,
        'reducedMotion': reducedMotion,
      };

  // Dispatches to defaults via [_enum] / null fallbacks; awkward as a factory.
  // ignore: prefer_constructors_over_static_methods
  static CatalogSettings fromJson(Map<String, dynamic> j) {
    bool b(String k, {bool fallback = true}) =>
        j[k] is bool ? j[k] as bool : fallback;
    int i(String k, int fallback) => (j[k] as num?)?.toInt() ?? fallback;
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
      quickFilterBar: b('quickFilterBar'),
      searchRadius: i('searchRadius', 50),
      gridColumns: i('gridColumns', 2),
      imageSize: _enum(
        j['imageSize'],
        CatalogImageSize.values,
        CatalogImageSize.medium,
      ),
      showUnitPrice: b('showUnitPrice'),
      priceComparison: b('priceComparison'),
      syncFavorites: b('syncFavorites'),
      listsPerProject: b('listsPerProject'),
      priceChangeAlert: b('priceChangeAlert'),
      notifLowStock: b('notifLowStock'),
      notifNewProducts: b('notifNewProducts', fallback: false),
      decimalFormat: _enum(
        j['decimalFormat'],
        CatalogDecimalFormat.values,
        CatalogDecimalFormat.decimal,
      ),
      maxDistance: i('maxDistance', 100),
      minRating: _enum(
        j['minRating'],
        CatalogMinRating.values,
        CatalogMinRating.any,
      ),
      localSuppliersOnly: b('localSuppliersOnly', fallback: false),
      historyBased: b('historyBased'),
      activeProjectFilter: b('activeProjectFilter', fallback: false),
      cheapAlternatives: b('cheapAlternatives'),
      compactMode: b('compactMode', fallback: false),
      textSize: _enum(
        j['textSize'],
        CatalogTextSize.values,
        CatalogTextSize.medium,
      ),
      highContrast: b('highContrast', fallback: false),
      reducedMotion: b('reducedMotion', fallback: false),
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
