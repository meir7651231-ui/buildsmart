import 'package:buildsmart/data/menu_trees.dart';
import 'package:buildsmart/data/projects.dart';
import 'package:buildsmart/data/sections.dart';
import 'package:buildsmart/test_harness/types.dart';

List<TestResult> testSections() {
  return [
    _runResult(
      id: 'sections:store',
      label: '🏪 kStoreSections — מבנה עץ חנות ספק',
      area: 'עצי BS',
      run: () {
        final checks = <TestCheck>[];
        _checkSectionList(
          checks,
          tag: 'store',
          sections: kStoreSections,
          expectedCount: 4,
        );
        _checkSectionById(checks, kStoreSections, 's-home',   childCount: 3);
        _checkSectionById(checks, kStoreSections, 's-orders', childCount: 3);
        _checkSectionById(checks, kStoreSections, 's-stock',  childCount: 2);
        _checkSectionById(checks, kStoreSections, 's-portal', childCount: 8);
        return checks;
      },
    ),
    _runResult(
      id: 'sections:courier',
      label: '🛵 kCourierSections — מבנה עץ שליח',
      area: 'עצי BS',
      run: () {
        final checks = <TestCheck>[];
        _checkSectionList(
          checks,
          tag: 'courier',
          sections: kCourierSections,
          expectedCount: 4,
        );
        _checkSectionById(checks, kCourierSections, 'vehicle', childCount: 3);
        _checkSectionById(checks, kCourierSections, 'active',  childCount: 3);
        _checkSectionById(checks, kCourierSections, 'portal',  childCount: 6);
        return checks;
      },
    ),
    _runResult(
      id: 'sections:worker',
      label: '🦺 kWorkerSections — מבנה עץ עובד',
      area: 'עצי BS',
      run: () {
        final checks = <TestCheck>[];
        _checkSectionList(
          checks,
          tag: 'worker',
          sections: kWorkerSections,
          expectedCount: 3,
        );
        _checkSectionById(checks, kWorkerSections, 'current',   childCount: 2);
        _checkSectionById(checks, kWorkerSections, 'queue',     childCount: 1);
        _checkSectionById(checks, kWorkerSections, 'submitted', childCount: 2);
        return checks;
      },
    ),
    _runResult(
      id: 'sections:manager',
      label: '👔 kManagerSections — מבנה עץ מנהל',
      area: 'עצי BS',
      run: () {
        final checks = <TestCheck>[];
        _checkSectionList(
          checks,
          tag: 'manager',
          sections: kManagerSections,
          expectedCount: 4,
        );
        _checkSectionById(checks, kManagerSections, 'm-products',  childCount: 5);
        _checkSectionById(checks, kManagerSections, 'm-orders',    childCount: 6);
        _checkSectionById(checks, kManagerSections, 'm-customers', childCount: 2);
        _checkSectionById(checks, kManagerSections, 'm-manage',    childCount: 5);

        // mm-regression must be reachable — this wires the test panel entry point
        final manage = kManagerSections.firstWhere((s) => s.id == 'm-manage');
        final regression = manage.children.any((s) => s.id == 'mm-regression');
        checks.add(TestCheck(
          name: 'mm-regression קיים תחת m-manage',
          pass: regression,
        ));
        return checks;
      },
    ),
    _runResult(
      id: 'sections:persona-map',
      label: 'kPersonaSections — מיפוי דמויות → עצים',
      area: 'עצי BS',
      run: () {
        final checks = <TestCheck>[];
        const expectedKeys = {'store', 'courier', 'worker', 'manager'};
        for (final k in expectedKeys) {
          final found = kPersonaSections.containsKey(k);
          checks.add(TestCheck(
            name: 'kPersonaSections["$k"] קיים',
            pass: found,
          ));
          if (found) {
            checks.add(TestCheck(
              name: 'kPersonaSections["$k"] לא ריק',
              pass: kPersonaSections[k]!.isNotEmpty,
              got: '${kPersonaSections[k]!.length}',
            ));
          }
        }
        // contractor must NOT be in the map (no sub-sections in legacy)
        checks.add(TestCheck(
          name: 'contractor אינו ב-kPersonaSections (אין תת-עצים)',
          pass: !kPersonaSections.containsKey('contractor'),
        ));
        return checks;
      },
    ),
    _runResult(
      id: 'sections:walkBsDrill',
      label: 'walkBsDrill — ניווט בעץ BS',
      area: 'לוגיקה',
      run: () {
        final checks = <TestCheck>[];

        // Root — empty path → full list
        final root = walkBsDrill('manager', const []);
        checks.add(TestCheck(
          name: 'walkBsDrill(manager, []) מחזיר 4 sections בשורש',
          pass: root.current.length == 4,
          expected: '4',
          got: '${root.current.length}',
        ));
        checks.add(TestCheck(
          name: 'walkBsDrill(manager, []) anchors ריק',
          pass: root.anchors.isEmpty,
        ));

        // One step
        final step1 = walkBsDrill('manager', const ['ניהול']);
        checks.add(TestCheck(
          name: 'walkBsDrill(manager, [ניהול]) anchors אחד',
          pass: step1.anchors.length == 1,
          expected: '1',
          got: '${step1.anchors.length}',
        ));
        checks.add(TestCheck(
          name: 'walkBsDrill(manager, [ניהול]) מחזיר 5 ילדים',
          pass: step1.current.length == 5,
          expected: '5',
          got: '${step1.current.length}',
        ));

        // Unknown path → stops at root
        final bad = walkBsDrill('manager', const ['לא קיים']);
        checks.add(TestCheck(
          name: 'walkBsDrill עם נתיב לא קיים מחזיר שורש',
          pass: bad.anchors.isEmpty && bad.current.length == 4,
        ));

        // Courier vehicle drill
        final courier = walkBsDrill('courier', const ['הרכב שלי היום']);
        checks.add(TestCheck(
          name: 'walkBsDrill(courier, [הרכב שלי היום]) → 3 סוגי רכב',
          pass: courier.current.length == 3,
          expected: '3',
          got: '${courier.current.length}',
        ));

        // Unknown persona → empty
        final nobody = walkBsDrill('contractor', const []);
        checks.add(TestCheck(
          name: 'walkBsDrill(contractor, []) → רשימה ריקה (אין עץ)',
          pass: nobody.current.isEmpty,
        ));
        return checks;
      },
    ),
    _runResult(
      id: 'sections:menus',
      label: 'kHomeTree · kCartTree · kFinanceHub',
      area: 'תפריטים',
      run: () {
        final checks = <TestCheck>[];

        checks.add(TestCheck(
          name: 'kHomeTree מכיל 4 items',
          pass: kHomeTree.length == 4,
          expected: '4',
          got: '${kHomeTree.length}',
        ));
        for (final s in kHomeTree) {
          checks.add(TestCheck(
            name: 'home item "${s.id}" עם emoji+title',
            pass: s.emoji.isNotEmpty && s.title.isNotEmpty,
          ));
          checks.add(TestCheck(
            name: 'home item "${s.id}" עם children',
            pass: s.hasChildren,
            got: '${s.children.length}',
          ));
        }

        checks.add(TestCheck(
          name: 'kCartTree מכיל 2 items',
          pass: kCartTree.length == 2,
          expected: '2',
          got: '${kCartTree.length}',
        ));
        final orders = kCartTree.firstWhere(
          (s) => s.id == 'cart-orders',
          orElse: () => const Section(id: '', emoji: '', title: ''),
        );
        checks.add(TestCheck(
          name: 'cart-orders עם 6 ילדים',
          pass: orders.children.length == 6,
          expected: '6',
          got: '${orders.children.length}',
        ));

        checks.add(TestCheck(
          name: 'kFinanceHub מכיל 10 items',
          pass: kFinanceHub.length == 10,
          expected: '10',
          got: '${kFinanceHub.length}',
        ));
        for (final f in kFinanceHub) {
          checks.add(TestCheck(
            name: 'finance item "${f.id}" עם emoji+title',
            pass: f.emoji.isNotEmpty && f.title.isNotEmpty,
          ));
        }

        // projectsTree includes finance hub
        final tree = projectsTree();
        final hasFinHub = tree.any((s) => s.id == 'fin-hub');
        checks.add(TestCheck(
          name: 'projectsTree() מכיל fin-hub',
          pass: hasFinHub,
        ));
        checks.add(TestCheck(
          name: 'projectsTree() = kProjects.length + 1',
          pass: tree.length == kProjects.length + 1,
          expected: '${kProjects.length + 1}',
          got: '${tree.length}',
        ));
        return checks;
      },
    ),
    _runResult(
      id: 'sections:ids-unique',
      label: 'Section ids — אין כפילות בכל עץ',
      area: 'שלמות',
      run: () {
        final checks = <TestCheck>[];
        final allTrees = <String, List<Section>>{
          'store':   kStoreSections,
          'courier': kCourierSections,
          'worker':  kWorkerSections,
          'manager': kManagerSections,
          'home':    kHomeTree,
          'cart':    kCartTree,
          'finance': kFinanceHub,
        };
        for (final entry in allTrees.entries) {
          final ids = <String>[];
          void walk(List<Section> list) {
            for (final s in list) {
              ids.add(s.id);
              if (s.hasChildren) walk(s.children);
            }
          }
          walk(entry.value);
          final idSet = ids.toSet();
          checks.add(TestCheck(
            name: 'עץ ${entry.key}: אין כפילות ids (${idSet.length}/${ids.length})',
            pass: idSet.length == ids.length,
            expected: '${ids.length}',
            got: '${idSet.length}',
          ));
        }
        return checks;
      },
    ),
  ];
}

// ── helpers ──────────────────────────────────────────────────────────────────

void _checkSectionList(
  List<TestCheck> checks, {
  required String tag,
  required List<Section> sections,
  required int expectedCount,
}) {
  checks.add(TestCheck(
    name: '$tag: מספר sections = $expectedCount',
    pass: sections.length == expectedCount,
    expected: '$expectedCount',
    got: '${sections.length}',
  ));
  for (final s in sections) {
    checks.add(TestCheck(
      name: '$tag/${s.id}: id לא ריק',
      pass: s.id.isNotEmpty,
      got: s.id,
    ));
    checks.add(TestCheck(
      name: '$tag/${s.id}: emoji לא ריק',
      pass: s.emoji.isNotEmpty,
      got: s.emoji,
    ));
    checks.add(TestCheck(
      name: '$tag/${s.id}: title לא ריק',
      pass: s.title.isNotEmpty,
      got: s.title,
    ));
  }
}

void _checkSectionById(
  List<TestCheck> checks,
  List<Section> list,
  String id, {
  required int childCount,
}) {
  final found = list.where((s) => s.id == id).toList();
  if (found.isEmpty) {
    checks.add(TestCheck(
      name: 'section "$id" קיים',
      pass: false,
      detail: 'לא נמצא ברשימה',
    ));
    return;
  }
  final s = found.first;
  checks.add(TestCheck(
    name: '"${s.id}" עם $childCount ילדים',
    pass: s.children.length == childCount,
    expected: '$childCount',
    got: '${s.children.length}',
  ));
}

TestResult _runResult({
  required String id,
  required String label,
  required String area,
  required List<TestCheck> Function() run,
}) {
  var checks = <TestCheck>[];
  var crashed = false;
  try {
    checks = run();
  } on Object catch (e) {
    crashed = true;
    checks.add(TestCheck(
      name: 'הבדיקה רצה בלי לקרוס',
      pass: false,
      detail: '$e',
    ));
  }
  if (!crashed) {
    checks.add(const TestCheck(name: 'הבדיקה רצה בלי לקרוס', pass: true));
  }
  return TestResult(
    id: id,
    category: TestCategory.sections,
    label: label,
    area: area,
    checks: checks,
  );
}
