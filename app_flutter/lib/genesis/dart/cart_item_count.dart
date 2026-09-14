// ⚛️ אטום-Dart (דרגת-חוזה) · cartItemCount
// מוצא: buildsmart/app_flutter/lib/screens/store_screen.dart:473 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// טיפוסים מוטבעים (חוק-1, verbatim מהמקור): SmartCartLine.
// ייעוד-עברי (G63 · מקור: מונחי-מסך-המקור screens__store_screen — כמו purposeFrom באינדקס-התצוגה, אפס-המצאה): פריטים · ממתינים · לסיכום · בבנייה · להמשיך · הוסף · כלים · מושכרים · עד · פעילים · הצעות · חדשות

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

/// Total number of units in the cart: summed fixed-item quantities plus the
/// quantity of every smart-cart line (so 3× of one product counts as 3).
int cartItemCount(Map<String, int> qtys, List<SmartCartLine> smartLines) =>
    qtys.values.where((q) => q > 0).fold<int>(0, (s, q) => s + q) +
    smartLines.fold<int>(0, (s, l) => s + l.productQty);
