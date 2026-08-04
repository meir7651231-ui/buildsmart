import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Generate a flutter_test file from a screen's atom-decomposition graph
/// (`app_flutter/knowledge/screens/<screen>/screen.json`). The RULE: every
/// testable edge + flow-step maps to one test —
///   writes → state-set · action → nav/sheet · registry-ID → wired ·
///   cfgVisible → hide · rule(shrink) → gated · formula → input/output ·
///   verb → effect.
///
/// Trivial `reads` are skipped (priority: verbs, formulas, registry-wiring,
/// gates, writes, actions). Output lands in the OPT-IN `app_flutter/test/
/// generated/` dir so a failing generated test never blocks the main suite.

/// One generated screen test file + its test count.
class GenResult {
  GenResult(this.screen, this.source, this.contents, this.testCount, this.edgeStepCount);
  final String screen;
  final String source; // the screen .dart basename
  final String contents;
  final int testCount;
  final int edgeStepCount; // count(edges + flow-steps) for the count==count check
}

/// Read a screen graph dir and emit a test file. Returns null when the screen
/// has no composer atom (nothing to pump) or no testable mappings.
GenResult? generateForScreen(String screenDir, {String? importPackage}) {
  final screenJson = File(p.join(screenDir, 'screen.json'));
  if (!screenJson.existsSync()) return null;
  final d = jsonDecode(screenJson.readAsStringSync()) as Map<String, dynamic>;
  final screen = d['screen'] as String;
  final source = d['source'] as String; // e.g. smart_home_screen.dart
  final atoms = (d['atoms'] as List).cast<Map<String, dynamic>>();
  if (atoms.isEmpty) return null;

  final composer = atoms.first;
  final composerName = composer['name'] as String;
  // Only a PUBLIC composer can be imported + pumped; a private one (rare) can't.
  if (composerName.startsWith('_')) return null;
  // Skip composers that need REQUIRED constructor args — `const X()` won't
  // compile (a detail/sheet screen that takes data). Regenerable once a pump
  // harness supplies fixtures; for now they'd break compilation.
  final contract = composer['contract'] as Map<String, dynamic>?;
  if (contract != null && contract['constructible'] == false) return null;

  final lib = importPackage ?? 'buildsmart';
  final importPath = 'package:$lib/screens/${p.basenameWithoutExtension(source)}.dart';
  // Self-contained = the screen builds its OWN Scaffold, so we pump it bare. A
  // body-only screen (0 Scaffold) is meant to sit inside a shell's Scaffold; pump
  // it bare and its InkWells have no Material ancestor → they throw. So we detect
  // the real Scaffold presence from source and wrap the body-only ones
  // (selfContained: false → the harness gives them a Scaffold). When the source
  // can't be located (e.g. the decompose golden dir has no lib/), fall back to the
  // "…Screen" name heuristic — which keeps the golden output byte-stable.
  final selfContained =
      _hasOwnScaffold(screenDir, source) ?? composerName.endsWith('Screen');
  // Role screens gate their body on the board session — seed it by screen name.
  final roleArg = _screenRole(screen);
  final roleSuffix = roleArg.isEmpty ? '' : ", role: '$roleArg'";

  final b = StringBuffer();
  var testCount = 0;
  var edgeStep = 0;
  var needsMoney = false;
  final seen = <String>{};

  // formula → input/output. For the recurring `v == null ? 'LABEL' : 'PFX${
  // groupThousands(v)}'` money-formula, reconstruct it as a pure test asserting
  // both branches (null → LABEL · 1234 → PFX1,234). Other formulas are skipped
  // (their free variables can't be reconstructed generically).
  void formulaTest(String atom, String detail, String effect) {
    final branches = _formulaBranches(effect); // ['מחיר לפי ספק', '₪${groupThousands(rec.price!)}']
    if (branches.length != 2) return;
    final lit = branches.firstWhere((x) => !x.contains(r'${'), orElse: () => '');
    final money = branches.firstWhere((x) => x.contains('groupThousands('), orElse: () => '');
    if (lit.isEmpty || money.isEmpty) return;
    final pfx = money.replaceAll(RegExp(r'\$\{groupThousands\([^}]*\)\}'), '');
    final key = 'formula|$lit|$pfx';
    if (!seen.add(key)) return;
    needsMoney = true;
    testCount++;
    final varName = detail.split('=').first.trim();
    b.writeln("""
    test('formula · $atom · $varName (null→"${_esc(lit)}" · 1234→"${_esc(pfx)}1,234")', () {
      String f(int? v) => v == null ? '${_esc(lit)}' : '${_esc(pfx)}\${groupThousands(v)}';
      expect(f(null), '${_esc(lit)}');
      expect(f(1234), '${_esc(pfx)}1,234');
    });""");
  }

  void wiredTest(Map<String, dynamic> node, String atom) {
    final text = (node['text'] as String?) ?? '';
    final id = node['registryId'] as String?;
    if (text.isEmpty) return;
    final key = 'wired|$text';
    if (!seen.add(key)) return;
    testCount++;
    b.writeln("""
    testWidgets('wired · $atom · "${_esc(text)}"${id != null ? ' [$id]' : ''}', (t) async {
      await pumpScreen(t, const $composerName(), selfContained: $selfContained$roleSuffix);
      expect(await findAcrossTabs(t, find.text('${_esc(text)}')), isTrue,
          reason: 'the ${id ?? 'text'} element renders on $screen (any tab)');
    });""");
  }

  void hideTest(Map<String, dynamic> node, String atom) {
    final id = node['registryId'] as String?;
    final text = (node['text'] as String?) ?? '';
    if (id == null || text.isEmpty) return;
    final key = 'hide|$id|$text';
    if (!seen.add(key)) return;
    testCount++;
    b.writeln("""
    testWidgets('hide · $atom · $id → gone when hidden', (t) async {
      await pumpScreen(t, const $composerName(), selfContained: $selfContained$roleSuffix,
          hidden: const {'$id'});
      expect(find.text('${_esc(text)}'), findsNothing,
          reason: 'hiding $id removes it for end-users');
    });""");
  }

  void toastTest(String atom, String label, String toast) {
    final key = 'toast|$label|$toast';
    if (!seen.add(key)) return;
    testCount++;
    b.writeln("""
    testWidgets('verb · $atom · tap "${_esc(label)}" → toast "${_esc(toast)}"', (t) async {
      await pumpScreen(t, const $composerName(), selfContained: $selfContained$roleSuffix);
      expect(await findAcrossTabs(t, find.text('${_esc(label)}')), isTrue,
          reason: 'the "${_esc(label)}" trigger is present (any tab)');
      await t.tap(find.text('${_esc(label)}').first);
      await t.pump(const Duration(milliseconds: 600));
      drainOverflow(t);
      expect(find.textContaining('${_esc(toast)}'), findsWidgets,
          reason: 'tapping "${_esc(label)}" fires the toast (verb effect)');
    });""");
  }

  for (final atom in atoms) {
    final name = atom['name'] as String;
    // Preview variants are NOT in the live tree; const-gated atoms don't render
    // with their gate off — neither can pass a "renders" test, so skip them.
    final variant = atom['variant'] as String?;
    final gate = atom['gate'] as String?;
    final renderable = variant != 'preview' && gate == null;
    final nodes = ((atom['object'] as Map)['nodes'] as List).cast<Map<String, dynamic>>();
    final edges = ((atom['connections'] as Map)['edges'] as List).cast<Map<String, dynamic>>();
    final flows = ((atom['behaviour'] as Map)['flows'] as List).cast<Map<String, dynamic>>();
    edgeStep += edges.length + flows.length;
    if (!renderable) continue;

    // registry-wiring + hide — ONLY registry-backed nodes ("registry-ID→wired").
    // Plain text (unregistered = gaps) is not a wiring target.
    for (final node in nodes) {
      if (node['registryId'] == null) continue;
      final kind = node['kind'] as String;
      if (kind == 'cfgText') wiredTest(node, name);
      if (kind == 'cfgVisible' || kind == 'cfgText') hideTest(node, name);
    }

    // verb effect — a labelled element (cfgText) with a toast flow → tap it and
    // assert the toast (validates the onPressed verb without importing state).
    final label = nodes.firstWhere(
      (n) => n['kind'] == 'cfgText' && (n['text'] as String).isNotEmpty,
      orElse: () => const <String, dynamic>{},
    )['text'] as String?;
    if (label != null && label.isNotEmpty) {
      for (final f in flows) {
        if (f['effect'] == 'toast') {
          final toast = _toastLiteral(f['detail'] as String? ?? '');
          if (toast.isNotEmpty) toastTest(name, label, toast);
        }
      }
    }

    // formula → input/output (reconstructed money-formula).
    for (final f in flows) {
      if (f['mechanism'] == 'formula') {
        formulaTest(name, f['detail'] as String? ?? '', f['effect'] as String? ?? '');
      }
    }
  }

  if (testCount == 0) return null;

  final header = StringBuffer()
    ..writeln('// GENERATED by tools/atom/testgen — DO NOT EDIT.')
    ..writeln('// Source graph: knowledge/screens/$screen/ · screen: $source')
    ..writeln('// Opt-in suite (app_flutter/test/generated/) — NOT run by the main')
    ..writeln('// swarm CI. A failure here is a triage signal (real bug OR generator')
    ..writeln('// gap), never a blocker. Regenerate: dart run atom_testgen … .')
    ..writeln("import '$importPath' show $composerName;")
    ..writeln("import '_harness.dart';")
    ..writeln("import 'package:flutter_test/flutter_test.dart';")
    ..write(needsMoney
        ? "import 'package:$lib/logic/money_format.dart' show groupThousands;\n"
        : '')
    ..writeln()
    ..writeln('void main() {')
    ..writeln('  // OPT-IN: the main swarm suite runs all of test/, so self-skip unless')
    ..writeln('  // the separate atom-tools CI job opts in (--dart-define=atomgen=true).')
    ..writeln('  // A failing generated test therefore never blocks the main CI.')
    ..writeln("  if (!const bool.fromEnvironment('atomgen')) return;")
    ..writeln("  group('$screen · generated ($testCount tests)', () {");

  final footer = '  });\n}\n';
  return GenResult(screen, source, '$header${b.toString()}\n$footer', testCount, edgeStep);
}

String _esc(String s) => s
    .replaceAll(r'\', r'\\')
    .replaceAll("'", r"\'")
    .replaceAll(r'$', r'\$')
    .replaceAll('\n', r'\n')
    .replaceAll('\r', r'\r')
    .replaceAll('\t', r'\t');


/// Whether the screen defines its OWN `Scaffold`. A body-only screen (0 Scaffold)
/// is meant to be a Scaffold body; pumped bare, its `InkWell`/`ListTile` surfaces
/// have no Material ancestor and throw. Detecting this lets the generator wrap
/// only those screens (selfContained: false). Returns null when the screen source
/// can't be located from [screenDir] (e.g. the decompose golden dir has no lib/
/// with this screen) — callers fall back to the name heuristic, so goldens that
/// run without the app tree stay byte-stable.
bool? _hasOwnScaffold(String screenDir, String source) {
  var dir = Directory(screenDir);
  for (var i = 0; i < 6; i++) {
    final lib = Directory(p.join(dir.path, 'lib'));
    if (lib.existsSync()) {
      final f = _libIndex(lib)[source];
      if (f == null) return null; // wrong tree (e.g. a tool's own lib) → fallback
      return RegExp(r'\bScaffold\s*\(').hasMatch(f.readAsStringSync());
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  return null;
}

final _libIndexCache = <String, Map<String, File>>{};

/// basename → File index of every `.dart` under [lib], cached per root so the
/// batch (62 screens) walks each lib tree once, not per screen.
Map<String, File> _libIndex(Directory lib) =>
    _libIndexCache.putIfAbsent(lib.path, () {
      final m = <String, File>{};
      for (final e in lib.listSync(recursive: true, followLinks: false)) {
        if (e is File && e.path.endsWith('.dart')) m[p.basename(e.path)] = e;
      }
      return m;
    });

/// Infer a board role from the screen key (manager_* → manager, …) so the
/// harness can seed the session that gates role screens. Empty = no session.
String _screenRole(String screen) {
  if (screen.contains('manager')) return 'manager';
  if (screen.contains('store') || screen.contains('supplier')) return 'store';
  if (screen.contains('worker')) return 'worker';
  if (screen.contains('courier')) return 'courier';
  return '';
}

/// Split a formula effect `text: 'A' | 'B'` into its two branch strings.
List<String> _formulaBranches(String effect) {
  var s = effect;
  if (s.startsWith('text:')) s = s.substring('text:'.length).trim();
  return s.split(' | ').map((x) {
    var t = x.trim();
    if (t.length >= 2 && t.startsWith("'") && t.endsWith("'")) {
      t = t.substring(1, t.length - 1);
    }
    return t;
  }).toList();
}

/// Extract the STATIC part of a `showToast(context, '${x} נוסף לסל')` literal —
/// strip the `${…}` interpolations and the quotes, keep the constant text.
String _toastLiteral(String detail) {
  final m = RegExp(r"showToast\([^,]*,\s*'(.*?)'").firstMatch(detail);
  if (m == null) return '';
  return m.group(1)!.replaceAll(RegExp(r'\$\{[^}]*\}'), '').trim();
}

/// The shared test harness — pumps a composer with fonts + RTL + a hidden-node
/// override, in the proven full-suite-safe pattern (favorite_tile_opens_sheet).
const String kHarness = r'''
// GENERATED by tools/atom/testgen — DO NOT EDIT.
// Shared pump harness for the generated screen tests.
import 'package:buildsmart/state/board_auth.dart'
    show BoardAuthNotifier, BoardRole, BoardSession, boardAuthProvider;
import 'package:buildsmart/state/studio/config_node.dart' show CfgNode;
import 'package:buildsmart/state/studio/config_store.dart' show resolvedNodeProvider;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool _fontsLoaded = false;
Future<void> _loadFonts() async {
  if (_fontsLoaded) return;
  final f = FontLoader('Heebo')
    ..addFont(rootBundle.load('assets/fonts/Heebo-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Heebo-Bold.ttf'));
  await f.load();
  _fontsLoaded = true;
}

/// Pump [composer] in a tall RTL surface with fonts + mock prefs. When [hidden]
/// is non-empty, override resolvedNodeProvider for those ids to hidden so the
/// CfgVisible/CfgText wrappers shrink for end-users.
/// A board session pinned to a role — role screens (`manager_*`, `store_*`, …)
/// gate their whole body on `boardAuthProvider.role`, so without this the body
/// is just the login gate and nothing renders.
class _SeededBoard extends BoardAuthNotifier {
  _SeededBoard(super.ref, BoardSession session) {
    state = session;
  }
}

BoardRole? _roleOf(String role) => switch (role) {
      'manager' => BoardRole.manager,
      'store' => BoardRole.store,
      'worker' => BoardRole.worker,
      'courier' => BoardRole.courier,
      _ => null,
    };

Future<void> pumpScreen(
  WidgetTester t,
  Widget composer, {
  bool selfContained = false,
  Set<String> hidden = const {},
  String role = '',
}) async {
  await _loadFonts();
  SharedPreferences.setMockInitialValues({});
  // A big surface so lazy lists build + fewer Rows overflow. Overflow that
  // remains is DRAINED below — these tests assert CONTENT, not layout.
  t.view.physicalSize = const Size(1600, 8000);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);

  final br = _roleOf(role);
  final overrides = <Override>[
    if (br != null)
      boardAuthProvider.overrideWith((ref) => _SeededBoard(
            ref,
            BoardSession(
              role: br,
              username: 'demo',
              displayName: 'דמו',
              demo: true,
            ),
          )),
    for (final id in hidden)
      resolvedNodeProvider(id).overrideWith(
        (ref) => const CfgNode(hidden: true),
      ),
  ];
  // Always give the composer a Scaffold ancestor (⇒ a Material for its ink
  // surfaces). A composer that builds its OWN Scaffold just nests harmlessly; a
  // bare-body composer — one whose default construction returns a body meant to
  // sit inside a shell's Scaffold at runtime (a home-shell / board tab like
  // ChatsScreen, or a `showAppBar:false` body like HomeContentReorder) — gets
  // the Material it assumes. This is the isolation `No Material` case: the app
  // ALWAYS mounts these under a Scaffold, so pumping them bare was the false
  // signal, not an app bug. A real `ListTile`-in-`DecoratedBox` finding needs a
  // Material PRESENT and so still surfaces through this wrap (not masked).
  // `selfContained` is kept for call-site compatibility; it no longer gates the
  // wrap.
  final body = Directionality(
      textDirection: TextDirection.rtl, child: Scaffold(body: composer));
  await t.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Heebo', useMaterial3: true),
        home: body,
      ),
    ),
  );
  await t.pump(const Duration(milliseconds: 300));
  drainOverflow(t);
}

/// Tab-walk — a registry element often lives on a NON-default tab, so it is not
/// rendered until that tab is selected. Check [target] on the current view; if
/// absent, tap each Material `Tab` in turn (pumping between) and re-check.
/// Returns true as soon as it is found on any tab. One generic mechanism for
/// every tabbed screen (the big bucket after role-seed).
Future<bool> findAcrossTabs(WidgetTester t, Finder target) async {
  if (target.evaluate().isNotEmpty) return true;
  final count = find.byType(Tab).evaluate().length;
  for (var i = 0; i < count; i++) {
    final tab = find.byType(Tab).at(i);
    if (tab.evaluate().isEmpty) break;
    await t.tap(tab, warnIfMissed: false);
    await t.pump(const Duration(milliseconds: 350));
    drainOverflow(t);
    if (target.evaluate().isNotEmpty) return true;
  }
  return target.evaluate().isNotEmpty;
}

/// Swallow RenderFlex overflow exceptions (a layout concern, orthogonal to what
/// the generated tests assert). A genuine (non-overflow) exception is re-thrown
/// immediately so it still fails the test — a real triage signal, never
/// swallowed.
void drainOverflow(WidgetTester t) {
  Object? ex;
  while ((ex = t.takeException()) != null) {
    final err = ex!;
    if (!err.toString().toLowerCase().contains('overflow')) {
      // ignore: only_throw_errors
      throw err;
    }
  }
}
''';

/// Batch-generate for every screen dir under [screensKnowledgeDir], writing to
/// [outDir]. Returns per-screen results.
List<GenResult> generateBatch(String screensKnowledgeDir, String outDir,
    {String? importPackage}) {
  final dirs = Directory(screensKnowledgeDir)
      .listSync()
      .whereType<Directory>()
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  Directory(outDir).createSync(recursive: true);
  File(p.join(outDir, '_harness.dart')).writeAsStringSync(kHarness);
  final results = <GenResult>[];
  for (final dir in dirs) {
    final r = generateForScreen(dir.path, importPackage: importPackage);
    if (r == null) continue;
    File(p.join(outDir, '${r.screen}_generated_test.dart'))
        .writeAsStringSync(r.contents);
    results.add(r);
  }
  return results;
}
