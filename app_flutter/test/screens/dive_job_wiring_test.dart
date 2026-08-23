// INTEGRATION: the keystroke-ZERO job boost (swarm #2) is wired through the live
// diveResultsProvider. With an EMPTY cart — nothing to mate against — opening a job
// (keyboardJobSkusProvider) must lift the job's OWN kit into the top-4 for a broad
// word, proving the FIRST pick is steered by the job. ON path:
//
//   flutter test --dart-define=GLOBAL_SEARCH=true test/screens/dive_job_wiring_test.dart
//
// Flag-off the whole branch tree-shakes ⇒ the test self-skips.

import 'package:buildsmart/data/task_skus_local.dart' show productsForTask;
import 'package:buildsmart/features/global_search/global_search.dart'
    show kGlobalSearch;
import 'package:buildsmart/screens/catalog_screen.dart'
    show diveResultsProvider, keyboardDiveQueryProvider;
import 'package:buildsmart/state/keyboard_job_context.dart'
    show keyboardJobSkusProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('an OPEN job lifts its own kit into top-4 on an empty cart', () {
    if (!kGlobalSearch) return; // flag-off: nothing wired

    // Task 1 (hot-water line) → its two PEX couplers; both names contain "מקשר",
    // a broad head-word shared by dozens of couplers, so from the letters alone
    // the intended two are buried.
    final jobProducts = productsForTask(1);
    expect(jobProducts.length, greaterThanOrEqualTo(2));
    final jobSkus = jobProducts.map((p) => p.sku).toList();
    const q = 'מקשר';

    int firstJobRank(void Function(ProviderContainer) seed) {
      final c = ProviderContainer();
      c.read(keyboardDiveQueryProvider.notifier).state = q;
      seed(c);
      final r = c.read(diveResultsProvider);
      c.dispose();
      return r.indexWhere((p) => jobSkus.contains(p.sku));
    }

    // Empty cart, no job in focus — the couplers rank by letters only.
    final rank0 = firstJobRank((_) {});
    // Empty cart, but the job is open.
    final rank1 = firstJobRank(
        (c) => c.read(keyboardJobSkusProvider.notifier).state = jobSkus);

    expect(rank1, greaterThanOrEqualTo(0),
        reason: 'a job product must stay in the results');
    expect(rank1, lessThan(4),
        reason: 'the open job must put its kit in the top-4 — first pick is smart');
    expect(rank1, lessThanOrEqualTo(rank0),
        reason: 'opening the job must never demote its own kit');
  });
}
