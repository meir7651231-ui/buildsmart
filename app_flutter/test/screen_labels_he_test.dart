// SWARM run-1 — the screen→Hebrew map that gives the wizard's element accordion
// its group headers (labelHe is per-element; the SCREEN header needed its own
// map). normalizeScreen collapses the duplicate raw screen ids; screenLabelHe
// returns Hebrew for known screens and a humanized fallback for the long tail.

import 'package:buildsmart/config/screen_labels_he.dart';
import 'package:buildsmart/state/studio/element_registry.dart'
    show kElementRegistry;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizeScreen collapses the documented duplicate pairs', () {
    expect(normalizeScreen('catalog_screen'), normalizeScreen('catalog'));
    expect(normalizeScreen('store_screen'), normalizeScreen('store'));
    expect(normalizeScreen('manager_dashboard_screen'), normalizeScreen('manager'));
    expect(normalizeScreen('smart_home_screen'), normalizeScreen('home'));
  });

  test('normalizeScreen is idempotent', () {
    for (final s in ['catalog_screen', 'store', 'manager', 'anything_else']) {
      expect(normalizeScreen(normalizeScreen(s)), normalizeScreen(s));
    }
  });

  test('screenLabelHe never returns empty — every registry screen gets a header',
      () {
    for (final d in kElementRegistry) {
      final label = screenLabelHe(d.screen);
      expect(label.trim(), isNotEmpty, reason: 'screen ${d.screen} has no header');
    }
  });

  test('screenLabelHe gives real Hebrew for the major screens', () {
    // A known screen returns Hebrew (contains a Hebrew letter), not the raw id.
    final he = RegExp(r'[֐-׿]');
    for (final s in ['manager', 'store', 'cart', 'catalog', 'home']) {
      expect(he.hasMatch(screenLabelHe(s)), isTrue, reason: 'no Hebrew for $s');
      expect(screenLabelHe(s), isNot(equals(s)), reason: 'raw id leaked for $s');
    }
  });

  test('unknown screen falls back to a humanized (non-empty) label', () {
    expect(screenLabelHe('some_unknown_screen').trim(), isNotEmpty);
  });
}
