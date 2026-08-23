import 'package:buildsmart/features/word_finder/category_groups.dart';
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('at most 12 distinct groups over the whole pool', () {
    final groups = kDivePool.map(groupOf).toSet();
    expect(groups.length, lessThanOrEqualTo(12), reason: '$groups');
  });

  test('groupOf is total — every product gets a non-empty group', () {
    for (final p in kDivePool) {
      expect(groupOf(p), isNotEmpty);
    }
  });

  test('fall-through to אחר is at most a couple of niche categories', () {
    final unmapped = kDivePool
        .where((p) => groupOf(p) == 'אחר')
        .map((p) => p.categoryHe)
        .toSet();
    // 'אחר' is the plan's explicit catch-all; only a couple of niche source
    // categories (whose raw string resists exact-match) legitimately land here,
    // and ≤12 still holds (11 named + 'אחר').
    expect(unmapped.length, lessThanOrEqualTo(2),
        reason: 'too many unmapped categories: $unmapped');
  });

  test('groupOf returns the curated group for a real product', () {
    final p = kDivePool.firstWhere((x) => x.categoryHe == 'אביזרי נחושת');
    expect(groupOf(p), 'חיבורים ומחברים');
  });

  test('the full group set (named + אחר fallback) is <=12 by construction', () {
    final allGroups = {...kCategoryGroups.values, 'אחר'};
    expect(allGroups.length, lessThanOrEqualTo(12), reason: '$allGroups');
  });
}
