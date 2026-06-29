// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · Pillar #2 — Domain/Vertical Builder · Step 34 — the authored-trade
// store (finishes chunk A: schema + flags + store).
//
// A `StateNotifier<TradesDoc>` over SharedPreferences (key `bs.trades.v1`, JSON),
// copying the `catalog_settings.dart` idiom (async `_load`/`_persist`, idempotent
// mutators). It holds ONLY the owner-authored deltas; plumbing is supplied by a baked
// seed (step 38), so authored storage starts EMPTY ⇒ no published trade ⇒ the live
// app is byte-identical. The Pillar-5 server swap replaces the persistence behind the
// same notifier. NOT consumed by any live screen yet ⇒ zero regression.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';

import 'package:buildsmart/domain/connection_schema.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kTradesKey = 'bs.trades.v1';

/// Current persisted-doc version. Bump + add a migrate branch when the shape changes.
const int kTradesDocVersion = 1;

List<T> _list<T>(Object? v, T Function(Map<String, dynamic>) from) => v is List
    ? v
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => from(e.cast<String, dynamic>()))
        .toList()
    : const [];

int _schemaVer(Object? v, int fallback) {
  if (v is num) return v.toInt();
  if (v is String) {
    final p = int.tryParse(v);
    if (p != null) return p;
  }
  return fallback;
}

/// The owner's authored deltas across the whole trade model. Immutable; round-trips
/// through JSON (the server seam). `TradesDoc.empty` is the byte-identical start.
@immutable
class TradesDoc {
  const TradesDoc({
    this.trades = const [],
    this.categories = const [],
    this.attributes = const [],
    this.products = const [],
    this.accessories = const [],
    this.fixtures = const [],
    this.connectorTypes = const [],
    this.systems = const [],
    this.productSpecs = const [],
    this.compatRules = const [],
    this.completionRules = const [],
    this.schemaVersion = kTradesDocVersion,
  });

  factory TradesDoc.fromJson(Map<String, dynamic> j) => TradesDoc(
        trades: _list(j['trades'], Trade.fromJson),
        categories: _list(j['categories'], TradeCategory.fromJson),
        attributes: _list(j['attributes'], AttributeDef.fromJson),
        products: _list(j['products'], TradeProduct.fromJson),
        accessories: _list(j['accessories'], AccessoryRule.fromJson),
        fixtures: _list(j['fixtures'], SmartFixture.fromJson),
        connectorTypes: _list(j['connectorTypes'], ConnectorType.fromJson),
        systems: _list(j['systems'], SystemDef.fromJson),
        productSpecs: _list(j['productSpecs'], ProductConnectorSpec.fromJson),
        compatRules: _list(j['compatRules'], CompatibilityRule.fromJson),
        completionRules: _list(j['completionRules'], CompletionRule.fromJson),
        schemaVersion: _schemaVer(j['schemaVersion'], kTradesDocVersion),
      );

  static const TradesDoc empty = TradesDoc();

  final List<Trade> trades;
  final List<TradeCategory> categories;
  final List<AttributeDef> attributes;
  final List<TradeProduct> products;
  final List<AccessoryRule> accessories;
  final List<SmartFixture> fixtures;
  final List<ConnectorType> connectorTypes;
  final List<SystemDef> systems;
  final List<ProductConnectorSpec> productSpecs;
  final List<CompatibilityRule> compatRules;
  final List<CompletionRule> completionRules;
  final int schemaVersion;

  bool get isEmpty =>
      trades.isEmpty &&
      categories.isEmpty &&
      attributes.isEmpty &&
      products.isEmpty &&
      accessories.isEmpty &&
      fixtures.isEmpty &&
      connectorTypes.isEmpty &&
      systems.isEmpty &&
      productSpecs.isEmpty &&
      compatRules.isEmpty &&
      completionRules.isEmpty;

  TradesDoc copyWith({
    List<Trade>? trades,
    List<TradeCategory>? categories,
    List<AttributeDef>? attributes,
    List<TradeProduct>? products,
    List<AccessoryRule>? accessories,
    List<SmartFixture>? fixtures,
    List<ConnectorType>? connectorTypes,
    List<SystemDef>? systems,
    List<ProductConnectorSpec>? productSpecs,
    List<CompatibilityRule>? compatRules,
    List<CompletionRule>? completionRules,
    int? schemaVersion,
  }) =>
      TradesDoc(
        trades: trades ?? this.trades,
        categories: categories ?? this.categories,
        attributes: attributes ?? this.attributes,
        products: products ?? this.products,
        accessories: accessories ?? this.accessories,
        fixtures: fixtures ?? this.fixtures,
        connectorTypes: connectorTypes ?? this.connectorTypes,
        systems: systems ?? this.systems,
        productSpecs: productSpecs ?? this.productSpecs,
        compatRules: compatRules ?? this.compatRules,
        completionRules: completionRules ?? this.completionRules,
        schemaVersion: schemaVersion ?? this.schemaVersion,
      );

  Map<String, dynamic> toJson() => {
        'trades': trades.map((e) => e.toJson()).toList(),
        'categories': categories.map((e) => e.toJson()).toList(),
        'attributes': attributes.map((e) => e.toJson()).toList(),
        'products': products.map((e) => e.toJson()).toList(),
        'accessories': accessories.map((e) => e.toJson()).toList(),
        'fixtures': fixtures.map((e) => e.toJson()).toList(),
        'connectorTypes': connectorTypes.map((e) => e.toJson()).toList(),
        'systems': systems.map((e) => e.toJson()).toList(),
        'productSpecs': productSpecs.map((e) => e.toJson()).toList(),
        'compatRules': compatRules.map((e) => e.toJson()).toList(),
        'completionRules': completionRules.map((e) => e.toJson()).toList(),
        'schemaVersion': schemaVersion,
      };

  @override
  bool operator ==(Object other) =>
      other is TradesDoc &&
      listEquals(other.trades, trades) &&
      listEquals(other.categories, categories) &&
      listEquals(other.attributes, attributes) &&
      listEquals(other.products, products) &&
      listEquals(other.accessories, accessories) &&
      listEquals(other.fixtures, fixtures) &&
      listEquals(other.connectorTypes, connectorTypes) &&
      listEquals(other.systems, systems) &&
      listEquals(other.productSpecs, productSpecs) &&
      listEquals(other.compatRules, compatRules) &&
      listEquals(other.completionRules, completionRules) &&
      other.schemaVersion == schemaVersion;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(trades),
        Object.hashAll(categories),
        Object.hashAll(attributes),
        Object.hashAll(products),
        Object.hashAll(accessories),
        Object.hashAll(fixtures),
        Object.hashAll(connectorTypes),
        Object.hashAll(systems),
        Object.hashAll(productSpecs),
        Object.hashAll(compatRules),
        Object.hashAll(completionRules),
        schemaVersion,
      );
}

class TradesStoreNotifier extends StateNotifier<TradesDoc> {
  TradesStoreNotifier() : super(TradesDoc.empty) {
    _load();
  }

  /// Upgrade a persisted doc to the current schema. REAL path (not a symbolic no-op):
  /// an UNVERSIONED legacy doc is treated as v0 and stamped to v1 (future field
  /// transforms slot in below each `if (from < N)`). Pure — returns a new map.
  @visibleForTesting
  static Map<String, dynamic> migrate(Map<String, dynamic> json) {
    var j = json;
    final from = _schemaVer(j['schemaVersion'], 0);
    if (from < 1) {
      // v0 (unversioned legacy) → v1: stamp the version. (No field moved yet.)
      j = {...j, 'schemaVersion': 1};
    }
    // if (from < 2) { … the v1→v2 transform … }
    return j;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kTradesKey);
      if (raw == null) return; // keep the empty default
      final j = jsonDecode(raw) as Map<String, dynamic>;
      state = TradesDoc.fromJson(migrate(j));
    } on Object catch (_) {/* corrupt prefs → keep the empty default */}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kTradesKey, jsonEncode(state.toJson()));
    } on Object catch (_) {/* best-effort */}
  }

  /// Add or replace a trade by id. Idempotent — an unchanged upsert is a no-op (no
  /// persist / notify).
  void upsertTrade(Trade t) {
    final i = state.trades.indexWhere((x) => x.id == t.id);
    if (i >= 0 && state.trades[i] == t) return;
    final next = [...state.trades];
    if (i >= 0) {
      next[i] = t;
    } else {
      next.add(t);
    }
    state = state.copyWith(trades: next);
    _persist();
  }

  void removeTrade(String id) {
    if (!state.trades.any((x) => x.id == id)) return; // no-op
    state = state.copyWith(
      trades: state.trades.where((x) => x.id != id).toList(),
    );
    _persist();
  }

  /// Replace the entire authored doc (used by import / restore). No-op if unchanged.
  void replaceAll(TradesDoc doc) {
    if (doc == state) return;
    state = doc;
    _persist();
  }

  void clear() {
    if (state.isEmpty) return;
    state = TradesDoc.empty;
    _persist();
  }
}

final tradesStoreProvider =
    StateNotifierProvider<TradesStoreNotifier, TradesDoc>(
  (ref) => TradesStoreNotifier(),
);
