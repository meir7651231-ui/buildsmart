import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kStorageKey = 'bs.store-settings.v1';

enum StoreSortDefault { priceAsc, rating, distance }
enum StorePayment { card, bit, applePay, supplierCredit }

class StoreSettings {
  const StoreSettings({
    required this.defaultAddress,
    required this.defaultPayment,
    required this.vatInclusive,
    required this.minOrderAmount,
    required this.sortDefault,
    required this.notifDeals,
    required this.notifBackInStock,
    required this.confirmLargeOrder,
    required this.largeOrderThreshold,
  });

  final String defaultAddress;
  final StorePayment defaultPayment;
  final bool vatInclusive;
  final int minOrderAmount;
  final StoreSortDefault sortDefault;
  final bool notifDeals;
  final bool notifBackInStock;
  final bool confirmLargeOrder;
  final int largeOrderThreshold;

  static const StoreSettings defaults = StoreSettings(
    defaultAddress: '',
    defaultPayment: StorePayment.card,
    vatInclusive: true,
    minOrderAmount: 0,
    sortDefault: StoreSortDefault.priceAsc,
    notifDeals: true,
    notifBackInStock: true,
    confirmLargeOrder: true,
    largeOrderThreshold: 5000,
  );

  StoreSettings copyWith({
    String? defaultAddress,
    StorePayment? defaultPayment,
    bool? vatInclusive,
    int? minOrderAmount,
    StoreSortDefault? sortDefault,
    bool? notifDeals,
    bool? notifBackInStock,
    bool? confirmLargeOrder,
    int? largeOrderThreshold,
  }) {
    return StoreSettings(
      defaultAddress: defaultAddress ?? this.defaultAddress,
      defaultPayment: defaultPayment ?? this.defaultPayment,
      vatInclusive: vatInclusive ?? this.vatInclusive,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      sortDefault: sortDefault ?? this.sortDefault,
      notifDeals: notifDeals ?? this.notifDeals,
      notifBackInStock: notifBackInStock ?? this.notifBackInStock,
      confirmLargeOrder: confirmLargeOrder ?? this.confirmLargeOrder,
      largeOrderThreshold: largeOrderThreshold ?? this.largeOrderThreshold,
    );
  }

  Map<String, dynamic> toJson() => {
        'defaultAddress': defaultAddress,
        'defaultPayment': defaultPayment.name,
        'vatInclusive': vatInclusive,
        'minOrderAmount': minOrderAmount,
        'sortDefault': sortDefault.name,
        'notifDeals': notifDeals,
        'notifBackInStock': notifBackInStock,
        'confirmLargeOrder': confirmLargeOrder,
        'largeOrderThreshold': largeOrderThreshold,
      };

  // Dispatches to defaults via [_enum] / null fallbacks; awkward as a factory.
  // ignore: prefer_constructors_over_static_methods
  static StoreSettings fromJson(Map<String, dynamic> j) {
    return StoreSettings(
      defaultAddress: (j['defaultAddress'] as String?) ?? '',
      defaultPayment: _enum(
        j['defaultPayment'],
        StorePayment.values,
        StorePayment.card,
      ),
      vatInclusive: j['vatInclusive'] != false,
      minOrderAmount: (j['minOrderAmount'] as num?)?.toInt() ?? 0,
      sortDefault: _enum(
        j['sortDefault'],
        StoreSortDefault.values,
        StoreSortDefault.priceAsc,
      ),
      notifDeals: j['notifDeals'] != false,
      notifBackInStock: j['notifBackInStock'] != false,
      confirmLargeOrder: j['confirmLargeOrder'] != false,
      largeOrderThreshold:
          (j['largeOrderThreshold'] as num?)?.toInt() ?? 5000,
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

class StoreSettingsNotifier extends StateNotifier<StoreSettings> {
  StoreSettingsNotifier() : super(StoreSettings.defaults) {
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kStorageKey);
      if (raw == null) return;
      final j = jsonDecode(raw) as Map<String, dynamic>;
      state = StoreSettings.fromJson(j);
    } on Object catch (_) {
      // Corrupt or unavailable storage — keep defaults.
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kStorageKey, jsonEncode(state.toJson()));
    } on Object catch (_) {
      // Best-effort.
    }
  }

  void update(StoreSettings Function(StoreSettings) f) {
    state = f(state);
    unawaited(_persist());
  }

  Future<void> reset() async {
    state = StoreSettings.defaults;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kStorageKey);
    } on Object catch (_) {/* ignore */}
  }
}

final storeSettingsProvider =
    StateNotifierProvider<StoreSettingsNotifier, StoreSettings>(
  (_) => StoreSettingsNotifier(),
);
