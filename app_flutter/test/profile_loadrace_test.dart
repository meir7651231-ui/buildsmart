// Cluster-6 guard (9×9 fleet, autonomous run 2026-06-09 · task #24):
// Re-registration load-race — a returning user with an OLD persisted profile
// types fresh name/contact and registers; the late async _load() used to land
// and clobber the fresh input with the stale prefs value. The _userTouched
// guard makes a late _load() non-destructive once the user has written.
import 'package:buildsmart/state/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('#24 late _load() does NOT overwrite freshly-registered input', () async {
    // A previous profile is already persisted (the re-registration scenario).
    SharedPreferences.setMockInitialValues({
      kUserProfileKey:
          '{"name":"ישן","contact":"old@example.com","profession":"אינסטלטור","registered":true}',
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Reading the notifier constructs it (fires the async _load) and we
    // synchronously register fresh input on the same turn — exactly the race.
    container
        .read(userProfileProvider.notifier)
        .register(name: 'חדש', contact: '0501234567');

    // Let the late async _load() future resolve.
    await Future<void>.delayed(const Duration(milliseconds: 60));

    final p = container.read(userProfileProvider);
    expect(p.name, 'חדש',
        reason: 'fresh registration must survive the late prefs load');
    expect(p.contact, '0501234567');
    expect(p.registered, isTrue);
  });
}
