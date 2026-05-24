import 'package:flutter/foundation.dart';

enum TestCategory { buttons, tabs, products, behavior, dsync, dupes }

extension TestCategoryX on TestCategory {
  String get id => name;
  String get he => switch (this) {
        TestCategory.buttons   => 'כפתורים',
        TestCategory.tabs      => 'טאבים',
        TestCategory.products  => 'מוצרים',
        TestCategory.behavior  => 'התנהגות',
        TestCategory.dsync     => 'סנכרון',
        TestCategory.dupes     => 'זהויות',
      };
}

enum RegressionStatus { idle, running, done }

@immutable
class TestCheck {
  const TestCheck({
    required this.name,
    required this.pass,
    this.expected,
    this.got,
    this.detail,
  });
  final String name;
  final bool pass;
  final String? expected;
  final String? got;
  final String? detail;
}

@immutable
class TestResult {
  const TestResult({
    required this.id,
    required this.category,
    required this.label,
    required this.checks,
    this.area,
  });
  final String id;
  final TestCategory category;
  final String label;
  final String? area;
  final List<TestCheck> checks;

  bool get allPass => checks.every((c) => c.pass);
  int get failedCount => checks.where((c) => !c.pass).length;
}

@immutable
class CategorySummary {
  const CategorySummary({
    required this.category,
    required this.total,
    required this.passed,
  });
  final TestCategory category;
  final int total;
  final int passed;
}
