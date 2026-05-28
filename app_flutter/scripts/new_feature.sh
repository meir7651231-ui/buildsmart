#!/usr/bin/env bash
# new_feature.sh — scaffold a new isolated feature under lib/features/[name]/
#
# Usage:
#   ./scripts/new_feature.sh <feature_name>
#
# Example:
#   ./scripts/new_feature.sh order_track
#
# Creates:
#   lib/features/order_track/model.dart
#   lib/features/order_track/helper.dart
#   lib/features/order_track/widget.dart
#   test/features/order_track_test.dart
#
# Then prints the isolation checklist.

set -euo pipefail

# ── Validate argument ──────────────────────────────────────────────────────────
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <feature_name>"
  echo "  Example: $0 order_track"
  exit 1
fi

FEATURE="$1"

# Feature names must be snake_case Dart identifiers.
if ! [[ "$FEATURE" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "❌ Feature name must be snake_case (lowercase letters, digits, underscores)."
  echo "   Got: $FEATURE"
  exit 1
fi

# ── Resolve paths ─────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$SCRIPT_DIR/.."   # app_flutter/

FEATURE_DIR="$ROOT/lib/features/$FEATURE"
TEST_DIR="$ROOT/test/features"

# ── Guard: don't overwrite existing feature ───────────────────────────────────
if [[ -d "$FEATURE_DIR" ]]; then
  echo "⚠️  Feature already exists: $FEATURE_DIR"
  echo "   To rebuild, remove the directory first."
  exit 1
fi

# ── Create directories ─────────────────────────────────────────────────────────
mkdir -p "$FEATURE_DIR"
mkdir -p "$TEST_DIR"

# Convert snake_case to PascalCase for class names
CLASS_NAME=$(echo "$FEATURE" | sed -E 's/(^|_)([a-z])/\U\2/g')

# ── model.dart ────────────────────────────────────────────────────────────────
cat > "$FEATURE_DIR/model.dart" << DART
// ignore_for_file: public_member_api_docs
/// ${FEATURE}/model.dart
///
/// Pure data types and enums for the $CLASS_NAME feature.
/// No Flutter, no Riverpod, no BuildContext — pure Dart only.
///
/// Source: proto [L####] — fill in verbatim line reference before connect.

/// TODO: define enums and data classes for this feature.
///
/// Example:
///   enum ${CLASS_NAME}Stage { ... }
///   class ${CLASS_NAME}Item { ... }
DART

# ── helper.dart ───────────────────────────────────────────────────────────────
cat > "$FEATURE_DIR/helper.dart" << DART
// ignore_for_file: public_member_api_docs
/// ${FEATURE}/helper.dart
///
/// Pure logic functions for the $CLASS_NAME feature.
/// No BuildContext, no ref, no side-effects.
///
/// Source: proto [L####] — fill in verbatim line reference before connect.
///
/// Unit tests: test/features/${FEATURE}_test.dart

/// TODO: implement helper functions.
///
/// Example:
///   String someComputation(int input) { ... }
DART

# ── widget.dart ───────────────────────────────────────────────────────────────
cat > "$FEATURE_DIR/widget.dart" << DART
// ignore_for_file: public_member_api_docs
/// ${FEATURE}/widget.dart
///
/// Dial widget for the $CLASS_NAME feature.
///
/// RULES (enforced by IsolationValidator):
///   ✅ Uses DialColumn / DialRow only
///   ❌ No showDialog / showModalBottomSheet / Navigator.push / new Scaffold
///   ❌ No import from lib/screens/
///
/// Source: proto [L####] — fill in verbatim line reference before connect.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:buildsmart/widgets/dial.dart';

// ignore: unused_import
import 'helper.dart';
// ignore: unused_import
import 'model.dart';

/// ${CLASS_NAME}Dial — dial widget for the $FEATURE feature.
///
/// Rendered via DialColumn + DialRow. No full-screen views.
class ${CLASS_NAME}Dial extends ConsumerWidget {
  const ${CLASS_NAME}Dial({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: replace with actual DialRow leaves from proto [L####].
    return const DialColumn(
      children: [
        // Example leaf — replace with verbatim labels:
        // DialRow(icon: '📋', label: 'TODO: verbatim label [L####]', onTap: null),
      ],
    );
  }
}
DART

# ── test/features/[name]_test.dart ────────────────────────────────────────────
cat > "$TEST_DIR/${FEATURE}_test.dart" << DART
// ignore_for_file: avoid_print
/// test/features/${FEATURE}_test.dart
///
/// Isolation + unit + widget tests for the $CLASS_NAME feature.
///
/// Run in isolation before connecting to shell:
///   flutter test test/features/${FEATURE}_test.dart -v

import 'package:flutter_test/flutter_test.dart';

import '../../lib/features/$FEATURE/helper.dart';
// import '../../lib/features/$FEATURE/model.dart';
// import '../../lib/features/$FEATURE/widget.dart';

import '../helpers/dial_test_helper.dart';
import '../helpers/feature_isolation_test_base.dart';
import '../helpers/isolation_validator.dart';
import '../helpers/wiring_contract_helper.dart';

// ---------------------------------------------------------------------------
// Isolation base — structural checks run first.
// ---------------------------------------------------------------------------

class _${CLASS_NAME}IsolationTest extends FeatureIsolationTestBase {
  @override
  String get featureName => '$FEATURE';

  @override
  List<String> get featureFiles => [
        'lib/features/$FEATURE/model.dart',
        'lib/features/$FEATURE/helper.dart',
        'lib/features/$FEATURE/widget.dart',
      ];

  // Declare verbatim strings once feature content is filled in:
  // @override
  // List<(String, int)> get verbatimStrings => [
  //   ('TODO: verbatim label', 12345), // [L12345]
  // ];
}

void main() {
  // Run structural isolation checks (screens/ imports, test file exists, R2).
  _${CLASS_NAME}IsolationTest().runIsolationChecks();

  // ---------------------------------------------------------------------------
  // Helper unit tests
  // ---------------------------------------------------------------------------
  group('$FEATURE helper', () {
    test('placeholder — replace with real helper tests', () {
      // TODO: import and test helper functions from helper.dart.
      // Example:
      //   expect(someComputation(0), equals('expected'));
      expect(true, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Widget tests
  // ---------------------------------------------------------------------------
  group('$FEATURE widget', () {
    testWidgets('dial renders without crash', (tester) async {
      // TODO: uncomment once widget.dart has real content.
      // await DialTestHelper.pumpDial(tester, const ${CLASS_NAME}Dial());
      // DialTestHelper.expectNoFullScreen(tester);
      // DialTestHelper.expectDialLeaf(tester, 'TODO: verbatim label'); // [L####]
      expect(true, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // WIRING contracts — add as features are wired.
  // ---------------------------------------------------------------------------
  group('$FEATURE wiring', () {
    test('placeholder — add contracts from WIRING.md', () {
      WiringContractHelper.expectBlocked(
        '$FEATURE — not yet connected',
        reason: 'feature scaffold only — wiring pending',
      );
    });
  });
}
DART

# ── Print summary ──────────────────────────────────────────────────────────────
echo ""
echo "✅ Feature scaffold created: $FEATURE"
echo ""
echo "Files created:"
echo "  lib/features/$FEATURE/model.dart"
echo "  lib/features/$FEATURE/helper.dart"
echo "  lib/features/$FEATURE/widget.dart"
echo "  test/features/${FEATURE}_test.dart"
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Isolation checklist (PROTOCOL.md §15)                      ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo "  1. Fill in model.dart — enums + data classes (no Flutter/Riverpod)"
echo "  2. Fill in helper.dart — pure logic (no BuildContext, no ref)"
echo "  3. Write unit tests in test/features/${FEATURE}_test.dart"
echo "  4. Run: flutter test test/features/${FEATURE}_test.dart"
echo "  5. Fill in widget.dart — DialColumn + DialRow leaves only"
echo "  6. Write widget tests (pumpDial + expectDialLeaf)"
echo "  7. Run: flutter test test/features/${FEATURE}_test.dart"
echo "  8. Verify: flutter analyze"
echo "  9. Add WIRING.md row with status 🚧"
echo " 10. Connect to home_shell / FAB trigger"
echo " 11. Run: flutter test  (full suite)"
echo " 12. Update WIRING.md row to ✅ or ⛔"
echo ""
echo "VRB-01 reminder: before writing any Hebrew string:"
echo "  grep -n 'המחרוזת' /home/user/buildsmart/index.html"
echo ""
