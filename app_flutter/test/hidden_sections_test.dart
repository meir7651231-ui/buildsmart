// The "hide list" choice must SURVIVE a refresh/restart — it's persisted to
// SharedPreferences (not in-memory). This verifies hide/show/toggle persist and
// reload into a fresh notifier.
import 'package:buildsmart/state/hidden_catalog_sections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('hide persists and reloads into a fresh notifier', () async {
    SharedPreferences.setMockInitialValues({});
    final n1 = HiddenCatalogSectionsNotifier();
    await _settle(); // initial _load
    expect(n1.state, isEmpty);

    n1.hide('מועדפים');
    n1.hide('עץ חכם');
    await _settle(); // _persist
    expect(n1.state, {'מועדפים', 'עץ חכם'});

    // A fresh notifier (simulating an app restart) reloads from prefs.
    final n2 = HiddenCatalogSectionsNotifier();
    await _settle();
    expect(n2.state, {'מועדפים', 'עץ חכם'},
        reason: 'hidden lists must survive a refresh/restart');
  });

  test('show restores; toggle flips; idempotent', () async {
    SharedPreferences.setMockInitialValues({});
    final n = HiddenCatalogSectionsNotifier();
    await _settle();

    n.hide('קטגוריות');
    n.hide('קטגוריות'); // idempotent — no duplicate
    expect(n.state, {'קטגוריות'});

    n.show('קטגוריות');
    expect(n.state, isEmpty);

    n.toggle('דומים');
    expect(n.isHidden('דומים'), isTrue);
    n.toggle('דומים');
    expect(n.isHidden('דומים'), isFalse);
    await _settle();

    // persisted empty → fresh notifier loads empty
    final n2 = HiddenCatalogSectionsNotifier();
    await _settle();
    expect(n2.state, isEmpty);
  });
}
