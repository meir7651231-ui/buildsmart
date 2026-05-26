import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  });
  final String productKey;
  final String productName;
  final String productEmoji;
  final String brandName;
  final int brandPrice;
  final int productQty;
  final List<SmartCartAcc> accessories;

  int get total {
    var t = brandPrice * productQty;
    for (final a in accessories) {
      t += a.price * a.qty;
    }
    return t;
  }
}

class SmartCartNotifier extends StateNotifier<List<SmartCartLine>> {
  SmartCartNotifier() : super(const []);

  void add(SmartCartLine line) {
    state = [...state, line];
  }

  void remove(int index) {
    state = [
      for (var i = 0; i < state.length; i++)
        if (i != index) state[i],
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
}

final smartCartProvider =
    StateNotifierProvider<SmartCartNotifier, List<SmartCartLine>>(
  (_) => SmartCartNotifier(),
);
