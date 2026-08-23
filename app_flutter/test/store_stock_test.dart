// Guards the relocated StoreOosNotifier (moved to lib/state/store_stock.dart in
// Wave 6 so the autoStock portal tile can read it without a circular import).
import 'package:buildsmart/state/store_stock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('storeOosProvider: markOos adds the product, markAvailable removes it', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(storeOosProvider), isEmpty);

    c.read(storeOosProvider.notifier).markOos('ברז כדורי');
    expect(c.read(storeOosProvider), contains('ברז כדורי'));
    expect(c.read(storeOosProvider).length, 1);

    // Set semantics — marking the same product OOS twice stays at one entry.
    c.read(storeOosProvider.notifier).markOos('ברז כדורי');
    expect(c.read(storeOosProvider).length, 1);

    c.read(storeOosProvider.notifier).markAvailable('ברז כדורי');
    expect(c.read(storeOosProvider), isNot(contains('ברז כדורי')));
    expect(c.read(storeOosProvider), isEmpty);
  });
}
