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
    viewMode: CatalogViewMode.list,
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
        CatalogViewMode.list,
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

// ─── price / dimension display helpers (pure — applied by the consuming UI) ──
//
// These are the single source of truth for how the price & dimension settings
// in the קטלוג › מחירים ומטבע / יחידות מידה sections actually affect rendered
// text. The settings screen binds the controls; the catalog/product-card/sheet
// call these so the toggle is honest (it really changes what the user sees).

/// Israel statutory VAT rate (17%). [priceWithVat] multiplies by `1 + this`.
const double kVatRate = 0.17;

/// Apply VAT to a base (pre-VAT) price when [showVat] is on. Pure rounding to
/// the nearest shekel so the displayed integer matches what the card renders.
/// Returns the base unchanged when [showVat] is false.
int priceWithVat(int base, {required bool showVat}) =>
    showVat ? (base * (1 + kVatRate)).round() : base;

/// Display symbol for the chosen catalog currency. This is the *local display*
/// symbol only — NO FX conversion is applied to the amount (live rates need an
/// external service; faking a conversion would mislead). The selection is
/// persisted and the symbol is shown next to the (unconverted) amount.
String currencySymbol(CatalogCurrency c) => switch (c) {
      CatalogCurrency.ils => '₪',
      CatalogCurrency.usd => r'$',
      CatalogCurrency.eur => '€',
    };

/// Format a base (pre-VAT, ILS) price for display: applies [CatalogSettings.showVat]
/// and prefixes the chosen [CatalogSettings.currency] symbol. [prefix] is kept
/// (e.g. '~' for an estimated price) and sits before the symbol.
/// Example: base 100, showVat true, ils → '₪117'.
String formatCatalogPrice(
  int base,
  CatalogSettings s, {
  String prefix = '',
}) {
  final amount = priceWithVat(base, showVat: s.showVat);
  return '$prefix${currencySymbol(s.currency)}$amount';
}

/// mm → inch (1″ = 25.4 mm). Returns null when [raw] has no parseable number.
double? _mmToInch(String raw) {
  final m = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(raw);
  if (m == null) return null;
  return double.parse(m.group(0)!) / 25.4;
}

/// Render a decimal inch value per [CatalogDecimalFormat]:
///  • decimal  → '1.57"'   (2 dp, trailing zeros trimmed)
///  • fraction → '1 9/16"' (nearest 1/16, mixed number)
String _formatInch(double inch, CatalogDecimalFormat fmt) {
  if (fmt == CatalogDecimalFormat.decimal) {
    var t = inch.toStringAsFixed(2);
    if (t.contains('.')) {
      t = t.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return '$t"';
  }
  // Nearest 1/16″ as a mixed fraction.
  final sixteenths = (inch * 16).round();
  final whole = sixteenths ~/ 16;
  var num = sixteenths % 16;
  var den = 16;
  while (num != 0 && num % 2 == 0) {
    num ~/= 2;
    den ~/= 2;
  }
  if (num == 0) return '$whole"';
  if (whole == 0) return '$num/$den"';
  return '$whole $num/$den"';
}

/// Whether a dims-table key carries a millimetre measurement we can convert to
/// imperial (matches `mm`, `מ"מ`, diameter/length keys). Keys without a numeric
/// mm value (materials, pressure ratings, free text) are left untouched.
bool _isMmDimKey(String key) {
  final k = key.toLowerCase();
  return k == 'mm' ||
      key.contains('מ"מ') ||
      key.contains('מ”מ') ||
      k.contains('mm');
}

/// Format ONE dims-table value for display, honouring the metric/imperial unit
/// system and the decimal/fraction format. Metric is passed through verbatim
/// (the catalog data is already metric). Imperial converts a mm value to inches
/// in the chosen format; non-mm values (and anything unparseable) pass through.
/// [unitHint] is the dims key (e.g. 'mm', 'אורך') used to decide convertibility.
String formatDimValue(
  String unitHint,
  String value,
  CatalogSettings s,
) {
  if (s.unit == CatalogUnit.metric) return value;
  if (!_isMmDimKey(unitHint)) return value;
  final inch = _mmToInch(value);
  if (inch == null) return value;
  return _formatInch(inch, s.decimalFormat);
}
