// Regression: KbScreen must CLEAR its tools from the screen-tools stack when its
// route is popped. Exercises the REAL widget through a REAL Navigator — the gap
// that let a `ref`-in-dispose throw leave stale tools on the stack. Runs only
// under --dart-define=KB_GLOBAL=true (the const flag gates KbScreen
// registration); skipped otherwise so the default suite stays green.
import 'dart:async';

import 'package:buildsmart/screens/keyboard_tool_tree.dart';
import 'package:buildsmart/state/keyboard_overlay.dart' show kKbGlobal;
import 'package:buildsmart/state/keyboard_screen_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('KbScreen clears its tools when its route is popped (no stale)',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final stockTools = kbStockNodes();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: Text('home'))),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      currentScreenTools(container.read(keyboardScreenToolsProvider)),
      isNull,
    );

    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    unawaited(
      nav.push(
        MaterialPageRoute<void>(
          builder: (_) =>
              KbScreen(tools: stockTools, child: const Text('stock')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      currentScreenTools(container.read(keyboardScreenToolsProvider)),
      same(stockTools),
      reason: 'front-most route mirrors its own tools',
    );

    nav.pop();
    await tester.pumpAndSettle();
    expect(
      tester.takeException(),
      isNull,
      reason: 'dispose must not throw (ref-in-dispose regression)',
    );
    expect(
      container.read(keyboardScreenToolsProvider),
      isEmpty,
      reason: 'popping the route must clear ITS entry (no stale tools)',
    );
  }, skip: !kKbGlobal);
}
