// #86 — the stock forecast's "הזמן עכשיו" unit price must be the product's own
// unit price, NOT (line total incl. accessories) / qty.
//
// Before the fix: 2 units × ₪100 + one accessory ₪30 ⇒ line `price` = 230 ⇒
// forecast unit price ₪115 (and the reorder total inflated by the same ratio).
import 'package:buildsmart/logic/ai_hub_logic.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:flutter_test/flutter_test.dart';

Order _order(String id, DateTime at, List<OrderLineItem> lines) => Order(
  id: id,
  who: 'קבלן',
  site: 'אתר',
  items: lines.length,
  sum: lines.fold(0, (s, l) => s + l.price),
  stage: 'new',
  createdAt: at,
  lines: lines,
);

void main() {
  final t0 = DateTime(2026, 11);
  final t1 = DateTime(2026, 11, 8);

  group('#86 OrderLineItem.unitPrice', () {
    test(
      'forecast uses captured unitPrice, not total/qty incl. accessories',
      () {
        final preds = computeStockForecast(
          [
            _order('BS-1', t0, const [
              OrderLineItem(
                name: 'ברז',
                emoji: '🚰',
                qty: 2,
                price: 230,
                unitPrice: 100,
              ),
            ]),
          ],
          const [],
          now: t1,
        );
        expect(preds, hasLength(1));
        expect(preds.single.unitPrice, 100);
      },
    );

    test('legacy line without unitPrice falls back to price / qty', () {
      final preds = computeStockForecast(
        [
          _order('BS-1', t0, const [
            OrderLineItem(name: 'ברז', emoji: '🚰', qty: 2, price: 230),
          ]),
        ],
        const [],
        now: t1,
      );
      expect(preds.single.unitPrice, 115);
    });

    test(
      'latest line wins: new captured price overrides an older fallback',
      () {
        final preds = computeStockForecast(
          [
            _order('BS-1', t0, const [
              OrderLineItem(name: 'ברז', emoji: '🚰', qty: 2, price: 230),
            ]),
            _order('BS-2', t1, const [
              OrderLineItem(
                name: 'ברז',
                emoji: '🚰',
                qty: 1,
                price: 140,
                unitPrice: 110,
              ),
            ]),
          ],
          const [],
          now: t1,
        );
        expect(preds.single.unitPrice, 110);
      },
    );

    test('JSON: unitPrice round-trips; legacy JSON stays byte-identical', () {
      const withUnit = OrderLineItem(
        name: 'ברז',
        emoji: '🚰',
        qty: 2,
        price: 230,
        unitPrice: 100,
      );
      final j = withUnit.toJson();
      expect(j['unitPrice'], 100);
      expect(OrderLineItem.fromJson(j).unitPrice, 100);

      const legacy = OrderLineItem(
        name: 'ברז',
        emoji: '🚰',
        qty: 2,
        price: 230,
      );
      expect(legacy.toJson().keys, ['name', 'emoji', 'qty', 'price']);
      expect(
        OrderLineItem.fromJson(const {
          'name': 'ברז',
          'emoji': '🚰',
          'qty': 2,
          'price': 230,
        }).unitPrice,
        0,
      );
    });

    test('Order JSON round-trip preserves line unitPrice', () {
      final o = _order('BS-9', t0, const [
        OrderLineItem(
          name: 'ברז',
          emoji: '🚰',
          qty: 2,
          price: 230,
          unitPrice: 100,
        ),
      ]);
      final back = Order.fromJson(o.toJson());
      expect(back.lines.single.unitPrice, 100);
    });
  });
}
