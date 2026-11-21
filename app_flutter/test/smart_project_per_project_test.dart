// Regression: the §7 smart-project done-set is scoped PER PROJECT.
// Before: one global Set — a day marked done in PRJ-1 showed as done in PRJ-2.
import 'package:buildsmart/data/projects.dart';
import 'package:buildsmart/state/projects_engine.dart';
import 'package:buildsmart/state/smart_project_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('prefs key: seed-active project keeps the legacy key, others scoped',
      () {
    expect(SmartProjectNotifier.prefsKeyFor(kActiveProjectId),
        'bs.smart-project.v1');
    expect(SmartProjectNotifier.prefsKeyFor('PRJ-2'),
        'bs.smart-project.v1.PRJ-2');
  });

  test('legacy marks (saved before scoping) still load for the seed project',
      () async {
    SharedPreferences.setMockInitialValues({
      'bs.smart-project.v1': ['1-1', '2-1'],
    });
    final n = SmartProjectNotifier(projectId: kActiveProjectId);
    await _settle();
    await _settle();
    expect(n.state, {'1-1', '2-1'});
    final other = SmartProjectNotifier(projectId: 'PRJ-2');
    await _settle();
    await _settle();
    expect(other.state, isEmpty);
  });

  test('marking a day in one project does not mark it in another', () async {
    if (kProjects.length < 2) return; // clean profile: no seed projects
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.listen(smartProjectProvider, (_, __) {});
    final first = c.read(activeProjectProvider).id;
    final second = kProjects.firstWhere((p) => p.id != first).id;

    c.read(smartProjectProvider.notifier).toggle('1-1');
    expect(c.read(smartProjectProvider), {'1-1'});
    expect(c.read(smartProjectProgressProvider).done, 1);
    await _settle();

    c.read(projectsProvider.notifier).switchProject(second);
    await _settle();
    await _settle();
    expect(c.read(smartProjectProvider), isEmpty,
        reason: 'PRJ-1 marks must not leak into $second');
    expect(c.read(smartProjectProgressProvider).done, 0);

    c.read(smartProjectProvider.notifier).toggle('3-2');
    await _settle();

    c.read(projectsProvider.notifier).switchProject(first);
    await _settle();
    await _settle();
    expect(c.read(smartProjectProvider), {'1-1'},
        reason: 'switching back restores the first project marks');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList(SmartProjectNotifier.prefsKeyFor(second)),
        ['3-2']);
  });
}
