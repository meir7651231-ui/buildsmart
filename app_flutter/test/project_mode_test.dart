// Roadmap step 52 — persisted project mode.
import 'package:buildsmart/state/project_mode.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('defaults to ProjectMode.any; isFiltering false', () {
    SharedPreferences.setMockInitialValues({});
    final n = ProjectModeNotifier();
    expect(n.state, ProjectMode.any);
    expect(n.isFiltering, isFalse);
  });

  test('set persists across a fresh notifier', () async {
    SharedPreferences.setMockInitialValues({});
    final n1 = ProjectModeNotifier();
    n1.set(ProjectMode.hot);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final n2 = ProjectModeNotifier();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(n2.state, ProjectMode.hot);
    expect(n2.isFiltering, isTrue);
  });

  test('setting the same mode is a no-op (no churn)', () {
    SharedPreferences.setMockInitialValues({});
    final n = ProjectModeNotifier();
    n.set(ProjectMode.any);
    final before = n.state;
    n.set(ProjectMode.any);
    expect(identical(before, n.state), isTrue);
  });
}
