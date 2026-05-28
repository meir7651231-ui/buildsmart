#!/usr/bin/env python3
"""
mutation_test.py — injects 20 bugs into the infra helpers and verifies the
test suite catches every one of them.

EXIT:  0 = all 20 caught   1 = at least one slipped through

Usage (from repo root):
  python3 scripts/mutation_test.py
"""

import os
import re
import subprocess
import sys

BASE = os.path.join(os.path.dirname(__file__), '..', 'app_flutter')
os.chdir(BASE)

IV  = 'test/helpers/isolation_validator.dart'
WC  = 'test/helpers/wiring_contract_helper.dart'
SMF = 'test/helpers/state_machine_fixture.dart'

FLUTTER = '/home/user/flutter/bin/flutter'

# ── helpers ──────────────────────────────────────────────────────────────────

def read(path):
    with open(path) as f:
        return f.read()

def write(path, content):
    with open(path, 'w') as f:
        f.write(content)

def tests_fail() -> bool:
    """Returns True if flutter test test/helpers/ has at least one failure."""
    result = subprocess.run(
        [FLUTTER, 'test', 'test/helpers/', '--reporter=compact'],
        capture_output=True, text=True
    )
    return result.returncode != 0

# ── mutations ─────────────────────────────────────────────────────────────────
# Each entry: (number, description, file, find_str, replace_str)
# find_str is a literal string to replace (not regex).

MUTATIONS = [
    # ── isolation_validator.dart ─────────────────────────────────────────────

    (1, "import check: contains('import') instead of startsWith('import ')",
     IV,
     "l.trimLeft().startsWith('import ') && l.contains('screens/')",
     "l.contains('import') && l.contains('screens/')"),

    (2, "block comment stripping disabled (inBlock never set true)",
     IV,
     "inBlock = true;",
     "inBlock = false; // BUG"),

    (3, "// comment stripping disabled",
     IV,
     "final slashIdx = l.indexOf('//');\n      if (slashIdx != -1) l = l.substring(0, slashIdx);",
     "// BUG: // stripping removed"),

    (4, "_stripStrings not called — R2 checks run on raw lines",
     IV,
     "final lines = _codeLines(filePath).map(_stripStrings).toList();",
     "final lines = _codeLines(filePath);  // BUG: no strip"),

    (5, "showDialog banned pattern removed",
     IV,
     r"      r'\bshowDialog\s*\(',",
     r"      // BUG: r'\bshowDialog\s*\(',"),

    (6, "showModalBottomSheet banned pattern removed",
     IV,
     r"      r'\bshowModalBottomSheet\s*\(',",
     r"      // BUG: r'\bshowModalBottomSheet\s*\(',"),

    (7, "Navigator.push + pushNamed banned patterns removed",
     IV,
     r"      r'\bNavigator\.push\s*\(',"+"\n"+
     r"      r'\bNavigator\.pushNamed\s*\(',",
     r"      // BUG: navigator checks removed"),

    (8, "Scaffold regex check removed entirely",
     IV,
     "    final scaffoldRe = RegExp(r'\\bScaffold\\s*\\(');\n"
     "    final scaffoldHits = lines.where(scaffoldRe.hasMatch).toList();\n"
     "    expect(\n"
     "      scaffoldHits,\n"
     "      isEmpty,\n"
     "      reason:\n"
     "          'R2 violation — $filePath constructs a Scaffold (forbidden in features/):\\n'\n"
     "          '${scaffoldHits.join('\\n')}',\n"
     "    );",
     "    // BUG: Scaffold check removed"),

    (9, "showDialog uses contains() not word-boundary regex → catches identifiers",
     IV,
     r"      r'\bshowDialog\s*\(',",
     r"      r'showDialog',  // BUG: no word boundary"),

    (10, "assertNoScreenImports check inverted — misses real imports",
     IV,
     "l.trimLeft().startsWith('import ') && l.contains('screens/')",
     "!l.trimLeft().startsWith('import ') && l.contains('screens/')  // BUG"),

    # ── wiring_contract_helper.dart ──────────────────────────────────────────

    (11, "expectNonEmpty: Map check removed — empty Map silently passes",
     WC,
     "if (value is String || value is Iterable || value is Map) {",
     "if (value is String || value is Iterable) {  // BUG: no Map"),

    (12, "expectNonEmpty: Iterable check removed — empty Set silently passes",
     WC,
     "if (value is String || value is Iterable || value is Map) {",
     "if (value is String || value is Map) {  // BUG: no Iterable"),

    (13, "expectNonEmpty: checks isEmpty instead of isNotEmpty — inverted",
     WC,
     "        isNotEmpty,\n"
     "        reason: 'WIRING ✅ \"$behavior\" — collection is empty',",
     "        isEmpty,  // BUG: inverted\n"
     "        reason: 'BUG',"),

    (14, "expectWired: compares actual to itself — always passes",
     WC,
     "      equals(expected),",
     "      equals(actual),  // BUG: always passes"),

    (15, "expectInvariant: isFalse instead of isTrue — always fails",
     WC,
     "      isTrue,\n"
     "      reason: 'INVARIANT \"$description\" violated',",
     "      isFalse,  // BUG\n"
     "      reason: 'BUG',"),

    # ── state_machine_fixture.dart ───────────────────────────────────────────

    (16, "expectBlocked: isNotNull instead of isNull — logic inverted",
     SMF,
     "      isNull,\n"
     "      reason: 'transition($state, $action) should be blocked (null), got $result',",
     "      isNotNull,  // BUG\n"
     "      reason: 'BUG',"),

    (17, "expectTransition: isNotNull instead of equals — wrong values pass",
     SMF,
     "      equals(expected),\n"
     "      reason: 'transition($state, $action) → expected $expected, got $result',",
     "      isNotNull,  // BUG\n"
     "      reason: 'BUG',"),

    (18, "testAllTransitions: null rows call expectTransition(null) not expectBlocked",
     SMF,
     "      if (expected == null) {\n"
     "        expectBlocked(state, action);\n"
     "      } else {",
     "      if (expected == null) {\n"
     "        expectTransition(state, action, expected);  // BUG: passes null\n"
     "      } else {"),

    (19, "expectActionsFrom: allowed/blocked checks swapped",
     SMF,
     "        isNotNull,\n"
     "        reason: 'action $action should be allowed from $state',",
     "        isNull,  // BUG: swapped\n"
     "        reason: 'BUG',"),

    (20, "expectThrows: expects no exception instead of Exception",
     SMF,
     "      throwsA(isA<Exception>()),\n"
     "      reason: 'transition($state, $action) should throw',",
     "      returnsNormally,  // BUG\n"
     "      reason: 'BUG',"),
]

# ── runner ────────────────────────────────────────────────────────────────────

caught  = 0
slipped = 0
results = []

originals = {IV: read(IV), WC: read(WC), SMF: read(SMF)}

for (num, desc, path, find, replace) in MUTATIONS:
    original = originals[path]
    if find not in original:
        results.append((num, desc, '⚠️  SKIP', 'find string not in file'))
        continue

    mutated = original.replace(find, replace, 1)
    write(path, mutated)

    try:
        if tests_fail():
            caught += 1
            results.append((num, desc, '✅ CAUGHT', ''))
        else:
            slipped += 1
            results.append((num, desc, '❌ SLIPPED', 'no test detected this bug'))
    finally:
        write(path, original)   # always revert

# ── report ────────────────────────────────────────────────────────────────────

print()
print('═' * 70)
print(f'  MUTATION TEST RESULTS  —  {caught}/{len(MUTATIONS)} bugs caught')
print('═' * 70)
for num, desc, verdict, note in results:
    tag = note and f'  ({note})' or ''
    print(f'  {verdict}  #{num:02d} {desc}{tag}')
print('─' * 70)
print(f'  Caught: {caught}   Slipped: {slipped}   Total: {len(MUTATIONS)}')
print('═' * 70)
print()

sys.exit(0 if slipped == 0 else 1)
