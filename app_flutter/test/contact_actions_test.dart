// V1 — the 📞/💬 contact buttons (widgets/contact_actions.dart).
//
// url_launcher cannot launch in a unit test (no platform channel), so the
// [urlLauncherProvider] seam is overridden with a fake that CAPTURES the Uri
// each button builds. We assert:
//   • 📞 (call)  → tel:<raw phone>
//   • 💬 (chat)  → https://wa.me/<international digits> (via waMeDigits)
//   • empty phone → no buttons at all (the guard never launches an empty tel:).

import 'package:buildsmart/state/url_launcher_seam.dart';
import 'package:buildsmart/widgets/contact_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records every Uri handed to the seam; reports success so no error toast.
class _CapturingLauncher {
  final List<Uri> launched = [];
  Future<bool> call(Uri uri) async {
    launched.add(uri);
    return true;
  }
}

Future<_CapturingLauncher> _pump(WidgetTester tester, String phone) async {
  final fake = _CapturingLauncher();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [urlLauncherProvider.overrideWithValue(fake.call)],
      child: MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: Center(child: ContactActions(phone: phone))),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  group('ContactActions', () {
    testWidgets('tapping 📞 launches tel:<phone>', (tester) async {
      final fake = await _pump(tester, '050-123 4567');

      // Two buttons render for a valid phone.
      expect(find.byIcon(Icons.call), findsOneWidget);
      expect(find.byIcon(Icons.chat), findsOneWidget);

      await tester.tap(find.byIcon(Icons.call));
      await tester.pumpAndSettle();

      expect(fake.launched, hasLength(1));
      final uri = fake.launched.single;
      expect(uri.scheme, 'tel');
      // tel: carries the raw phone (the dialer tolerates separators); a space
      // is %20-encoded on the wire, so decode the full Uri to compare the
      // human form the button targeted.
      expect(Uri.decodeFull(uri.toString()), 'tel:050-123 4567');
    });

    testWidgets('tapping 💬 launches https://wa.me/<international digits>',
        (tester) async {
      final fake = await _pump(tester, '0501234567');

      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      expect(fake.launched, hasLength(1));
      expect(
        fake.launched.single.toString(),
        'https://wa.me/972501234567',
      );
    });

    testWidgets('empty phone hides BOTH buttons and launches nothing',
        (tester) async {
      final fake = await _pump(tester, '');

      expect(find.byIcon(Icons.call), findsNothing);
      expect(find.byIcon(Icons.chat), findsNothing);
      // Nothing to tap → nothing launched.
      expect(fake.launched, isEmpty);
    });

    testWidgets('a blank / separators-only phone is also treated as empty',
        (tester) async {
      final fake = await _pump(tester, '  --  ');
      expect(find.byIcon(Icons.call), findsNothing);
      expect(find.byIcon(Icons.chat), findsNothing);
      expect(fake.launched, isEmpty);
    });
  });
}
