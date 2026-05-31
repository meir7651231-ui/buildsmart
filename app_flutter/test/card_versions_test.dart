// Roadmap step 76 — config versioning (named snapshots per product).
import 'package:buildsmart/state/card_versions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('save persists across a fresh notifier; forProduct filters', () async {
    SharedPreferences.setMockInitialValues({});
    final n1 = CardVersionsNotifier();
    n1.save(label: 'זול', productKey: 'faucet', brandName: 'A');
    n1.save(label: 'יוקרתי', productKey: 'faucet', brandName: 'B');
    n1.save(label: 'דיפולט', productKey: 'drain', brandName: 'X');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(n1.forProduct('faucet').length, 2);
    expect(n1.forProduct('drain').length, 1);

    final n2 = CardVersionsNotifier();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(n2.forProduct('faucet').map((v) => v.label).toSet(),
        {'זול', 'יוקרתי'});
  });

  test('re-saving the same (product, label) replaces the brand (no dup)', () {
    SharedPreferences.setMockInitialValues({});
    final n = CardVersionsNotifier();
    n.save(label: 'בחירה', productKey: 'faucet', brandName: 'A');
    n.save(label: 'בחירה', productKey: 'faucet', brandName: 'B'); // re-save
    final list = n.forProduct('faucet');
    expect(list.length, 1, reason: 'same label → replace');
    expect(list.first.brandName, 'B');
  });

  test('remove(id) clears just that version', () {
    SharedPreferences.setMockInitialValues({});
    final n = CardVersionsNotifier();
    final a = n.save(label: 'a', productKey: 'p', brandName: 'A');
    n.save(label: 'b', productKey: 'p', brandName: 'B');
    n.remove(a.id);
    expect(n.forProduct('p').length, 1);
    expect(n.forProduct('p').first.label, 'b');
  });

  test('different products keep separate label namespaces', () {
    SharedPreferences.setMockInitialValues({});
    final n = CardVersionsNotifier();
    n.save(label: 'בחירה', productKey: 'faucet', brandName: 'A');
    n.save(label: 'בחירה', productKey: 'drain', brandName: 'X');
    expect(n.forProduct('faucet').length, 1);
    expect(n.forProduct('drain').length, 1);
  });
}
