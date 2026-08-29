// U1.5.2 — the "ממתין לאישור" banner: visible only when the signed-in user is
// pending, otherwise renders nothing. Driven by pendingApprovalProvider.

import 'package:buildsmart/state/rbac.dart' show pendingApprovalProvider;
import 'package:buildsmart/widgets/pending_approval_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap({required bool pending}) => ProviderScope(
      overrides: [pendingApprovalProvider.overrideWithValue(pending)],
      child: const MaterialApp(
        home: Scaffold(body: PendingApprovalBanner()),
      ),
    );

void main() {
  testWidgets('shows the pending notice when the user is pending', (tester) async {
    await tester.pumpWidget(_wrap(pending: true));
    expect(find.textContaining('ממתין לאישור'), findsOneWidget);
  });

  testWidgets('renders nothing (shrink) when the user is NOT pending',
      (tester) async {
    await tester.pumpWidget(_wrap(pending: false));
    expect(find.textContaining('ממתין לאישור'), findsNothing);
    expect(find.byType(SizedBox), findsOneWidget); // the SizedBox.shrink
  });
}
