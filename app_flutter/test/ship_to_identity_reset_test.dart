// Nightly 2026-11-20 — the "לאן לשלוח?" address and the courier note are
// identity-scoped: when the signed-in account changes (sign-out → another
// user signs in on the same device, no reload) both reset to empty, so user
// A's address / note never ride on user B's order.
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late StateController<String?> uid;
  late ProviderContainer c;

  setUp(() {
    final fakeUid = StateProvider<String?>((_) => 'user-A');
    c = ProviderContainer(
      overrides: [currentUidProvider.overrideWith((ref) => ref.watch(fakeUid))],
    );
    uid = c.read(fakeUid.notifier);
  });
  tearDown(() => c.dispose());

  test('ship-to address resets when the account changes', () {
    c.read(shipToProvider.notifier).state = 'רחוב הרצל 1, תל אביב';
    expect(c.read(shipToProvider), 'רחוב הרצל 1, תל אביב');

    uid.state = null; // sign-out
    expect(c.read(shipToProvider), '');

    c.read(shipToProvider.notifier).state = 'כתובת זמנית';
    uid.state = 'user-B'; // another account signs in
    expect(c.read(shipToProvider), '');
  });

  test('courier note resets when the account changes', () {
    c.read(cartNotesProvider.notifier).state = 'להשאיר אצל השומר';
    uid.state = 'user-B';
    expect(c.read(cartNotesProvider), '');
  });

  test('same account (no uid change) keeps the values', () {
    c.read(shipToProvider.notifier).state = 'אתר הבנייה';
    c.read(cartNotesProvider.notifier).state = 'קומה 3';
    uid.state = 'user-A'; // same uid — StateProvider does not notify
    expect(c.read(shipToProvider), 'אתר הבנייה');
    expect(c.read(cartNotesProvider), 'קומה 3');
  });
}
