import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class SmartCartAcc {
  const SmartCartAcc({
    required this.name,
    required this.emoji,
    required this.price,
    required this.qty,
  });
  final String name;
  final String emoji;
  final int price;
  final int qty;

  Map<String, dynamic> toJson() =>
      {'name': name, 'emoji': emoji, 'price': price, 'qty': qty};

  factory SmartCartAcc.fromJson(Map<String, dynamic> j) => SmartCartAcc(
        name: j['name'] as String,
        emoji: j['emoji'] as String,
        price: (j['price'] as num).toInt(),
        qty: (j['qty'] as num).toInt(),
      );
}

@immutable
class SmartCartLine {
  const SmartCartLine({
    required this.productKey,
    required this.productName,
    required this.productEmoji,
    required this.brandName,
    required this.brandPrice,
    required this.productQty,
    required this.accessories,
    this.selection = const {},
  });
  final String productKey;
  final String productName;
  final String productEmoji;
  final String brandName;
  final int brandPrice;
  final int productQty;
  final List<SmartCartAcc> accessories;

  /// The configurator selection this line carries (plan E.1 — "הקונפיג נשמר
  /// בשורה"), keyed by attribute (e.g. `{'angle': '45°'}`). EMPTY for every
  /// ordinary (non-configured) line — so its JSON stays byte-identical: the key
  /// is serialized only when non-empty and decoded tolerantly (old lines → {}).
  final Map<String, String> selection;

  int get total {
    var t = brandPrice * productQty;
    for (final a in accessories) {
      t += a.price * a.qty;
    }
    return t;
  }

  Map<String, dynamic> toJson() => {
        'productKey': productKey,
        'productName': productName,
        'productEmoji': productEmoji,
        'brandName': brandName,
        'brandPrice': brandPrice,
        'productQty': productQty,
        'accessories': accessories.map((a) => a.toJson()).toList(),
        // Emitted ONLY when non-empty ⇒ every legacy (unconfigured) line encodes
        // byte-for-byte as before (no new key in the payload).
        if (selection.isNotEmpty) 'selection': selection,
      };

  factory SmartCartLine.fromJson(Map<String, dynamic> j) => SmartCartLine(
        productKey: j['productKey'] as String,
        productName: j['productName'] as String,
        productEmoji: j['productEmoji'] as String,
        brandName: j['brandName'] as String,
        brandPrice: (j['brandPrice'] as num).toInt(),
        productQty: (j['productQty'] as num).toInt(),
        accessories: (j['accessories'] as List<dynamic>)
            .map((e) => SmartCartAcc.fromJson(e as Map<String, dynamic>))
            .toList(),
        // TOLERANT: an old line with no `selection` key → the empty map.
        selection: (j['selection'] as Map?)?.map(
              (k, v) => MapEntry('$k', '$v'),
            ) ??
            const {},
      );
}

class SmartCartNotifier extends StateNotifier<List<SmartCartLine>> {
  SmartCartNotifier() : super(const []) {
    _load();
  }

  static const _prefsKey = 'bs.smart-cart.v1';

  /// True once any mutation has been applied (or _load completes).
  /// Guards against _load clobbering a mutation that arrived before prefs.
  bool _loaded = false;

  // Persist the cart on every change so it survives app restarts.
  @override
  set state(List<SmartCartLine> value) {
    _loaded = true; // mutation happened — block any pending _load
    super.state = value;
    _persist();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) {
        _loaded = true;
        return;
      }
      final list = (jsonDecode(raw) as List<dynamic>)
          .map((e) => SmartCartLine.fromJson(e as Map<String, dynamic>))
          .toList();
      if (!_loaded) {
        super.state = list; // bypass re-persisting the value we just loaded
        _loaded = true;
      }
    } catch (_) {
      // Corrupt/old payload — ignore and start empty.
      _loaded = true;
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode(state.map((l) => l.toJson()).toList()),
      );
    } catch (_) {}
  }

  void add(SmartCartLine line) {
    state = [...state, line];
  }

  void remove(int index) {
    state = [
      for (var i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
  }

  /// Set the quantity of the line at [index]; removes it when [qty] <= 0.
  void setLineQty(int index, int qty) {
    if (index < 0 || index >= state.length) return;
    if (qty <= 0) {
      remove(index);
      return;
    }
    final l = state[index];
    state = [
      for (var i = 0; i < state.length; i++)
        if (i == index)
          SmartCartLine(
            productKey: l.productKey,
            productName: l.productName,
            productEmoji: l.productEmoji,
            brandName: l.brandName,
            brandPrice: l.brandPrice,
            productQty: qty,
            accessories: l.accessories,
            selection: l.selection, // a qty change must not drop the config
          )
        else
          state[i],
    ];
  }

  /// Total quantity across all lines sharing [productKey].
  int qtyForKey(String productKey) => state
      .where((l) => l.productKey == productKey)
      .fold(0, (sum, l) => sum + l.productQty);

  /// Quick-add stepper: collapse all lines for [line.productKey] into the
  /// single [line]. A line with productQty <= 0 removes the product entirely.
  void setQtyForKey(SmartCartLine line) {
    final others =
        state.where((l) => l.productKey != line.productKey).toList();
    state = line.productQty > 0 ? [...others, line] : others;
  }

  void clear() => state = const [];

  /// Replace every cart line with [lines] (a project's stashed snapshot). Used
  /// by the cart-per-project switch: the incoming project's snapshot becomes the
  /// live cart. Reassigns `state` (new list) so it rebuilds + persists via the
  /// setter — `SmartCartLine` is immutable so sharing the line objects is safe.
  void loadSnapshot(List<SmartCartLine> lines) => state = [...lines];
}

final smartCartProvider =
    StateNotifierProvider<SmartCartNotifier, List<SmartCartLine>>(
  (_) => SmartCartNotifier(),
);
