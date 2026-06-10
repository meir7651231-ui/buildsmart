// Guards the welcome→auth wiring (#server-gate-auth): with the backend flag OFF
// (the default — tests never initialise Firebase) the welcome flow stays on the
// demo path and the users-profile writer is null, so nothing reaches Firestore.
// The flag-ON path (route to showLoginSheet → enter on auth) is exercised by the
// real-backend preview channel on a device — it needs a live Firebase gateway
// the sandbox can't provide.
import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/onboarding_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('backend flag is OFF in tests → no live backend', () {
    expect(useFirebaseBackend, isFalse);
  });

  testWidgets('usersProfileWriterProvider is null without Firebase', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(usersProfileWriterProvider), isNull);
  });

  testWidgets('welcome renders the demo path with the flag OFF', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: WelcomeScreen()),
      ),
    );
    await tester.pump();

    // The demo entry link is present (flag OFF = the existing onboarding).
    expect(find.text('המשך ללא רישום (דוגמה)'), findsOneWidget);
    // Sanity: not yet entered the app.
    final c = ProviderScope.containerOf(
      tester.element(find.byType(WelcomeScreen)),
    );
    expect(c.read(welcomeSeenProvider), isTrue); // default true in tests
  });
}
