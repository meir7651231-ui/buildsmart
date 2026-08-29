import 'package:buildsmart/features/card_keyboard/card_keyboard_screen.dart';
import 'package:buildsmart/features/card_keyboard/opening_surface.dart'
    show OpeningSurface;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('flag-ON: the opening renders the single OpeningSurface',
      (t) async {
    await t.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: CardKeyboardScreen(forceLiveForTest: true)),
        ),
      ),
    );
    await t.pump();

    expect(find.byType(OpeningSurface), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.mic), kIsWeb ? findsNothing : findsOneWidget,
        reason: 'mic shows iff not web (showMic: !kIsWeb)');
    // the single-mouth contract: ZERO mode chooser
    expect(find.byType(ToggleButtons), findsNothing);
    expect(find.byType(TabBar), findsNothing);
  });

  testWidgets('flag-OFF: renders nothing — no OpeningSurface (byte-identical)',
      (t) async {
    await t.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: CardKeyboardScreen())),
      ),
    );
    await t.pump();
    expect(find.byType(OpeningSurface), findsNothing);
  });
}
