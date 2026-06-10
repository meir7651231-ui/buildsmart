// Guard tests for the notifications 'עקוב' (follow) chip fix:
// notifFollowedIdsProvider (screens/notifications_screen.dart) is a real
// PersistedIdSet backed by SharedPreferences key 'bs.notif-followed.v1'.
// These tests reproduce the toggle path the chip's onTap uses (add/remove on
// the notifier) and prove the set PERSISTS — a fresh container (simulated
// restart) re-reads the followed ids from prefs, and remove un-persists.
import 'package:buildsmart/screens/notifications_screen.dart'
    show notifFollowedIdsProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 60));

void main() {
  test('follow toggle — add puts the id in state and in prefs', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await _settle(); // let the initial _load() resolve first

    c.read(notifFollowedIdsProvider.notifier).add('ship-1');
    await _settle();

    expect(c.read(notifFollowedIdsProvider).contains('ship-1'), true,
        reason: 'followed id must appear in state after add');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('bs.notif-followed.v1'), contains('ship-1'),
        reason: 'add must persist the id to SharedPreferences');
  });

  test('follow toggle — persisted ids survive a restart (round-trip)',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c1 = ProviderContainer();
    c1.read(notifFollowedIdsProvider.notifier).add('ship-7');
    await _settle();
    c1.dispose();

    // Fresh container = fresh PersistedIdSet → must reload from prefs.
    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    // Providers are lazy — touch it so the PersistedIdSet (and its _load())
    // actually starts before we settle.
    c2.read(notifFollowedIdsProvider);
    await _settle();

    expect(c2.read(notifFollowedIdsProvider).contains('ship-7'), true,
        reason: 'followed id must survive a simulated app restart');
  });

  test('follow toggle — remove takes the id out of state and prefs', () async {
    SharedPreferences.setMockInitialValues({
      'bs.notif-followed.v1': <String>['ship-1', 'ship-2'],
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    // Providers are lazy — touch it so _load() starts, then settle.
    c.read(notifFollowedIdsProvider);
    await _settle(); // initial _load() picks up the seeded ids

    expect(c.read(notifFollowedIdsProvider).contains('ship-1'), true,
        reason: 'seeded followed ids must load from prefs');

    c.read(notifFollowedIdsProvider.notifier).remove('ship-1');
    await _settle();

    expect(c.read(notifFollowedIdsProvider).contains('ship-1'), false,
        reason: 'removed id must leave state');
    expect(c.read(notifFollowedIdsProvider).contains('ship-2'), true,
        reason: 'other followed ids must be untouched');
    final prefs = await SharedPreferences.getInstance();
    expect(
        prefs.getStringList('bs.notif-followed.v1'), isNot(contains('ship-1')),
        reason: 'remove must un-persist the id');
    expect(prefs.getStringList('bs.notif-followed.v1'), contains('ship-2'));
  });

  test('follow toggle — add then remove ends empty (full toggle cycle)',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await _settle();

    final notifier = c.read(notifFollowedIdsProvider.notifier);
    notifier.add('ship-3');
    await _settle();
    notifier.remove('ship-3');
    await _settle();

    expect(c.read(notifFollowedIdsProvider), isEmpty,
        reason: 'toggle on+off must end with no followed ids');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('bs.notif-followed.v1'), isEmpty,
        reason: 'toggle on+off must end with empty persisted list');
  });
}
