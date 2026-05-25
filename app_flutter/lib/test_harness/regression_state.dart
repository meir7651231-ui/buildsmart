import 'package:buildsmart/test_harness/types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 'all' or TestCategory.id
final regressionFilterProvider = StateProvider<String>((_) => 'all');

final regressionStatusProvider =
    StateProvider<RegressionStatus>((_) => RegressionStatus.idle);

final regressionResultsProvider =
    StateProvider<List<TestResult>>((_) => const []);

final filteredResultsProvider = Provider<List<TestResult>>((ref) {
  final filter = ref.watch(regressionFilterProvider);
  final results = ref.watch(regressionResultsProvider);
  if (filter == 'all') return results;
  return results.where((r) => r.category.id == filter).toList();
});

final filteredSummaryProvider =
    Provider<({int total, int passed, int failed})>((ref) {
  final results = ref.watch(filteredResultsProvider);
  final total = results.length;
  final passed = results.where((r) => r.allPass).length;
  return (total: total, passed: passed, failed: total - passed);
});

final summaryByCategoryProvider = Provider<List<CategorySummary>>((ref) {
  final results = ref.watch(regressionResultsProvider);
  return TestCategory.values.map((cat) {
    final items = results.where((r) => r.category == cat).toList();
    return CategorySummary(
      category: cat,
      total: items.length,
      passed: items.where((r) => r.allPass).length,
    );
  }).toList();
});
