#!/usr/bin/env python3
"""
mutation_hard_test.py — 20 HARDER mutations. Subtler bugs, narrower logic gaps.
Some are designed to slip through — finding them means we need more tests.

EXIT:  0 = all caught   1 = at least one slipped

Usage (from repo root):
  python3 scripts/mutation_hard_test.py
"""

import os
import subprocess
import sys

BASE = os.path.join(os.path.dirname(__file__), '..', 'app_flutter')
os.chdir(BASE)

IV  = 'test/helpers/isolation_validator.dart'
WC  = 'test/helpers/wiring_contract_helper.dart'
SMF = 'test/helpers/state_machine_fixture.dart'
DTH = 'test/helpers/dial_test_helper.dart'

FLUTTER = '/home/user/flutter/bin/flutter'

def read(path):
    with open(path) as f: return f.read()

def write(path, content):
    with open(path, 'w') as f: f.write(content)

def tests_fail() -> bool:
    r = subprocess.run(
        [FLUTTER, 'test', 'test/helpers/', '--reporter=compact'],
        capture_output=True, text=True,
    )
    return r.returncode != 0

# ── 20 harder mutations ───────────────────────────────────────────────────────

MUTATIONS = [
    # ── isolation_validator.dart ─────────────────────────────────────────────

    (1, '[IV] block-comment: while→if — second /* */ on same line escapes',
     IV,
     'while (l.contains(\'/*\'))',
     'if (l.contains(\'/*\'))   // BUG: only first block per line stripped'),

    (2, '[IV] showDialog: no \\b — "noshowDialog(" would pass (test gap)',
     IV,
     r"      r'\bshowDialog\s*\(',",
     r"      r'showDialog\s*\(',   // BUG: no word boundary"),

    (3, '[IV] Scaffold: no \\s* — "Scaffold  (" with space escapes',
     IV,
     r"    final scaffoldRe = RegExp(r'\bScaffold\s*\(');",
     r"    final scaffoldRe = RegExp(r'\bScaffold\(');  // BUG: no \s*"),

    (4, '[IV] // strip: continue instead of trim — skips entire line with inline //',
     IV,
     "l = l.substring(0, slashIdx);",
     "continue;  // BUG: skips entire line instead of trimming comment"),

    (5, '[IV] block-exit: end+3 overshoots — eats first code char after */',
     IV,
     'l = l.substring(end + 2);\n        inBlock = false;',
     'l = l.substring(end + 3);  // BUG: off-by-one\n        inBlock = false;'),

    (6, "[IV] _stripStrings: simple regex, no escape handling — \\\\' inside string survives",
     IV,
     r"""      .replaceAll(RegExp(r"'[^'\\]*(?:\\.[^'\\]*)*'"), "''")""",
     r"""      .replaceAll(RegExp(r"'[^']*'"), "''")   // BUG: no escape handling"""),

    (7, '[IV] Navigator.push: \\s+ requires whitespace — "Navigator.push(" escapes',
     IV,
     r"      r'\bNavigator\.push\s*\(',",
     r"      r'\bNavigator\.push\s+\(',  // BUG: requires ≥1 space before ("),

    (8, '[IV] screens check: "screens" without slash — false negative for full path',
     IV,
     "l.trimLeft().startsWith('import ') && l.contains('screens/')",
     "l.trimLeft().startsWith('import ') && l.contains('screens')  // BUG: no slash"),

    (9, '[IV] block inline: start+1 keeps one char of /* prefix',
     IV,
     '        l = l.substring(0, start) + l.substring(end + 2);',
     '        l = l.substring(0, start + 1) + l.substring(end + 2);  // BUG: keeps /'),

    (10, '[IV] block-exit: skip entire line instead of keeping code after */',
     IV,
     '        l = l.substring(end + 2);\n        inBlock = false;',
     '        inBlock = false;\n        continue;  // BUG: discards code after */'),

    # ── dial_test_helper.dart ────────────────────────────────────────────────

    (11, '[DTH] expectDialLeaf: findsAtLeastNWidgets(2) — single widget fails',
     DTH,
     'findsAtLeastNWidgets(1),',
     'findsAtLeastNWidgets(2),  // BUG: requires duplicate'),

    (12, '[DTH] dialTestShell: TextDirection.ltr — RTL test fails',
     DTH,
     'textDirection: TextDirection.rtl,',
     'textDirection: TextDirection.ltr,  // BUG: wrong direction'),

    (13, '[DTH] expectNoFullScreen: lessThanOrEqualTo(3) — 2 nested Scaffolds pass',
     DTH,
     'lessThanOrEqualTo(1),',
     'lessThanOrEqualTo(3),  // BUG: allows 2 violations'),

    (14, '[DTH] expectNoDialLeaf: findsOneWidget instead of findsNothing',
     DTH,
     'findsNothing,',
     'findsOneWidget,  // BUG: expects one, not zero'),

    (15, '[DTH] pumpDial: pump() instead of pumpAndSettle() — animations mid-flight',
     DTH,
     'await tester.pumpAndSettle();',
     'await tester.pump();  // BUG: does not settle'),

    # ── state_machine_fixture.dart ───────────────────────────────────────────

    (16, '[SMF] expectTransition: equals(expected.toString()) — type mismatch always fails',
     SMF,
     '      equals(expected),\n'
     '      reason: \'transition($state, $action) → expected $expected, got $result\',',
     '      equals(expected.toString()),  // BUG: compares toString\n'
     '      reason: \'BUG\','),

    (17, '[SMF] testAllTransitions: sublist(1) — first matrix row silently skipped',
     SMF,
     'for (final (state, action, expected) in matrix) {',
     'for (final (state, action, expected) in matrix.sublist(matrix.isEmpty ? 0 : 1)) {  // BUG: skips row 0'),

    (18, '[SMF] expectActionsFrom: blocked loop uses isNotNull — blocked=null fails',
     SMF,
     '        isNull,\n'
     '        reason: \'action $action should be blocked from $state\',',
     '        isNotNull,  // BUG: inverted\n'
     '        reason: \'BUG\','),

    (19, '[SMF] expectBlocked: expect(result == null, isTrue) — same logic, but…',
     SMF,
     '    expect(\n'
     '      result,\n'
     '      isNull,\n'
     '      reason: \'transition($state, $action) should be blocked (null), got $result\',',
     '    expect(\n'
     '      result == null,  // BUG: bool comparison hides the actual value\n'
     '      isTrue,\n'
     '      reason: \'BUG\','),

    (20, '[WC] expectNonEmpty: value.toString() defeats isEmpty — empty list passes',
     WC,
     '      expect(\n'
     '        value,\n'
     '        isNotEmpty,\n'
     '        reason: \'WIRING ✅ "$behavior" — collection is empty\',',
     '      expect(\n'
     '        value.toString(),  // BUG: toString() is never empty\n'
     '        isNotEmpty,\n'
     '        reason: \'BUG\','),
]

# ── runner ────────────────────────────────────────────────────────────────────

originals = {IV: read(IV), WC: read(WC), SMF: read(SMF), DTH: read(DTH)}
caught = slipped = skipped = 0
results = []

for (num, desc, path, find, replace) in MUTATIONS:
    original = originals[path]
    if find not in original:
        skipped += 1
        results.append((num, desc, '⚠️  SKIP', 'find string not in file'))
        continue

    write(path, original.replace(find, replace, 1))
    try:
        if tests_fail():
            caught += 1
            results.append((num, desc, '✅ CAUGHT', ''))
        else:
            slipped += 1
            results.append((num, desc, '❌ SLIPPED', '← test gap'))
    finally:
        write(path, original)

# ── report ────────────────────────────────────────────────────────────────────

total = len(MUTATIONS)
print()
print('═' * 72)
print(f'  HARD MUTATION RESULTS  —  {caught}/{total} caught  '
      f'({slipped} slipped, {skipped} skipped)')
print('═' * 72)
for num, desc, verdict, note in results:
    tag = f'  {note}' if note else ''
    print(f'  {verdict}  #{num:02d} {desc}{tag}')
print('─' * 72)
print(f'  Caught: {caught}   Slipped: {slipped}   Skipped: {skipped}   Total: {total}')
print('═' * 72)
print()

sys.exit(0 if slipped == 0 else 1)
