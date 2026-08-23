// Render-lock for the Co-Pilot screen (#manager-copilot). With no live gateway
// (the default test build — claudeGatewayProvider == null) it must render the
// HONEST "requires connection" off-state, never crash.
import 'package:buildsmart/screens/manager_copilot_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the honest off-state when no backend gateway', (t) async {
    await t.pumpWidget(const ProviderScope(
      child: MaterialApp(home: ManagerCopilotScreen()),
    ));
    await t.pump();
    // Title chrome present…
    expect(find.text('🤖 קו-פיילוט'), findsOneWidget);
    expect(find.text('שאל את העסק שלך'), findsOneWidget);
    // …and the graceful off-state (no gateway in a Firebase-free test build).
    expect(find.text('💡 הקו-פיילוט החכם דורש חיבור לשרת.'), findsOneWidget);
  });
}
