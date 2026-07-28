// screen-mgmt s7 — the floating keyboard's HOME tool grid honours the wizard's
// per-screen keyboard layout ('kbd:home'). This proves the filter contract that
// FloatingCardKeyboard._applyHomeKbdLayout applies over the REAL kbHomeNodes
// labels: the default is byte-identical (all tiles in order), hiding a tile from
// the wizard drops it, and reorder follows the wizard order. (The full-render
// byte-identity of the default is covered by floating_card_keyboard_test.)

import 'package:buildsmart/config/screen_registry.dart' show keyboardLayoutKey;
import 'package:buildsmart/screens/keyboard_tool_tree.dart' show kbHomeNodes;
import 'package:buildsmart/state/screen_sections.dart'
    show screenSectionsProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('s7 — the home keyboard grid filters/reorders kbHomeNodes by the '
      "'kbd:home' layout (default byte-identical · hide drops · reorder)", () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(screenSectionsProvider.notifier);
    final labels = [for (final node in kbHomeNodes()) node.label];
    expect(labels, contains('מהירים')); // sanity: the real top-level tile labels

    // default: all tiles, same order ⇒ byte-identical.
    expect(n.visibleIds(keyboardLayoutKey('home'), labels), labels);

    // hide a tile from the wizard ⇒ it drops from the keyboard grid.
    n.hide(keyboardLayoutKey('home'), 'מהירים');
    final visible = n.visibleIds(keyboardLayoutKey('home'), labels);
    expect(visible, isNot(contains('מהירים')));
    expect(visible.length, labels.length - 1);

    // reorder ⇒ the grid follows the wizard order.
    n.moveDown(keyboardLayoutKey('home'), labels, labels.first);
    expect(n.orderedIds(keyboardLayoutKey('home'), labels).first,
        isNot(labels.first));
  });
}
