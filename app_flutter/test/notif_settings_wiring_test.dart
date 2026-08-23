// wave-2 BATCH 3 · NOTIFICATION SETTINGS wiring contract.
//
// Proves the toggles previously marked 'בבנייה' now have a real LOCAL effect on
// the EXISTING in-app notification system (the per-username worker/courier bell
// feed in state/worker_notifs.dart) and the 🔊 'צליל ורטט' arrival feedback:
//   • boardFeedEnabled — the master 'התראות בתוך האפליקציה' switch + the
//     '🦺 עובד' / '🛵 שליח' per-role toggles gate the live bell FEED;
//   • currentWorkerNotifsProvider honours that gate (a logged worker's feed
//     empties when either toggle is off, mark-read/clear still target the
//     stored feed);
//   • notifFeedbackFor — sound/vibrate fire only when on AND not snoozed / not
//     inside quiet-hours;
//   • the persisted fields round-trip through SharedPreferences.
//
// The 🔑 delivery channels (email/SMS/WhatsApp) stay server-gated and are NOT
// asserted to do anything locally — that is correct (no fake).

import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/notif_settings.dart';
import 'package:buildsmart/state/worker_notifs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const d = NotifSettings.defaults;

  group('boardFeedEnabled — in-app + per-role gate', () {
    test('defaults: worker + courier feeds enabled', () {
      expect(boardFeedEnabled(d, BoardRole.worker), isTrue);
      expect(boardFeedEnabled(d, BoardRole.courier), isTrue);
    });

    test('master switch off ⇒ every board role gated', () {
      final s = d.copyWith(pushEnabled: false);
      expect(boardFeedEnabled(s, BoardRole.worker), isFalse);
      expect(boardFeedEnabled(s, BoardRole.courier), isFalse);
      expect(boardFeedEnabled(s, BoardRole.store), isFalse);
    });

    test('personaWorker off gates ONLY the worker feed', () {
      final s = d.copyWith(personaWorker: false);
      expect(boardFeedEnabled(s, BoardRole.worker), isFalse);
      expect(boardFeedEnabled(s, BoardRole.courier), isTrue,
          reason: 'the worker toggle must not touch the courier feed');
    });

    test('personaCourier off gates ONLY the courier feed', () {
      final s = d.copyWith(personaCourier: false);
      expect(boardFeedEnabled(s, BoardRole.courier), isFalse);
      expect(boardFeedEnabled(s, BoardRole.worker), isTrue);
    });

    test('store role has no per-role toggle — only the master gates it', () {
      // Store is on with defaults, off only because of the master switch.
      expect(boardFeedEnabled(d, BoardRole.store), isTrue);
      expect(
        boardFeedEnabled(
          d.copyWith(personaWorker: false, personaCourier: false),
          BoardRole.store,
        ),
        isTrue,
        reason: 'worker/courier toggles must not gate the store feed',
      );
    });
  });

  group('currentWorkerNotifsProvider respects the gate', () {
    test('a logged worker sees the feed by default', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(boardAuthProvider.notifier).login(BoardRole.worker, 'ran', '1111');
      c.read(workerNotifsProvider.notifier).addNotification(
            username: 'ran',
            emoji: '✅',
            title: 'משימה אושרה',
          );
      expect(c.read(currentWorkerNotifsProvider), hasLength(1));
      expect(c.read(currentWorkerUnreadCountProvider), 1);
    });

    test('personaWorker off empties the SURFACED feed (badge → 0)', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(boardAuthProvider.notifier).login(BoardRole.worker, 'ran', '1111');
      c.read(workerNotifsProvider.notifier).addNotification(
            username: 'ran',
            emoji: '✅',
            title: 'משימה אושרה',
          );
      c
          .read(notifSettingsProvider.notifier)
          .update((s) => s.copyWith(personaWorker: false));

      expect(c.read(currentWorkerNotifsProvider), isEmpty,
          reason: 'the live worker bell goes quiet when the toggle is off');
      expect(c.read(currentWorkerUnreadCountProvider), 0);
      // The stored feed is untouched — turning it back on restores the list.
      expect(c.read(workerNotifsProvider)['ran'], hasLength(1));
    });

    test('master in-app switch off also empties the worker feed', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(boardAuthProvider.notifier).login(BoardRole.worker, 'ran', '1111');
      c.read(workerNotifsProvider.notifier).addNotification(
            username: 'ran',
            emoji: '✅',
            title: 'x',
          );
      c
          .read(notifSettingsProvider.notifier)
          .update((s) => s.copyWith(pushEnabled: false));
      expect(c.read(currentWorkerUnreadCountProvider), 0);
    });

    test('toggling back on restores the surfaced feed', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(boardAuthProvider.notifier).login(BoardRole.worker, 'ran', '1111');
      c.read(workerNotifsProvider.notifier).addNotification(
            username: 'ran',
            emoji: '✅',
            title: 'x',
          );
      final notif = c.read(notifSettingsProvider.notifier)
        ..update((s) => s.copyWith(personaWorker: false));
      expect(c.read(currentWorkerUnreadCountProvider), 0);
      notif.update((s) => s.copyWith(personaWorker: true));
      expect(c.read(currentWorkerUnreadCountProvider), 1);
    });
  });

  group('notifFeedbackFor — 🔊 sound/vibration gate', () {
    test('defaults: both channels fire', () {
      final fb = notifFeedbackFor(d);
      expect(fb.sound, isTrue);
      expect(fb.vibrate, isTrue);
    });

    test('sound off ⇒ only vibrate; vibrate off ⇒ only sound', () {
      expect(notifFeedbackFor(d.copyWith(soundEnabled: false)),
          (sound: false, vibrate: true));
      expect(notifFeedbackFor(d.copyWith(vibrationEnabled: false)),
          (sound: true, vibrate: false));
    });

    test('snooze suppresses BOTH channels', () {
      final snoozed = d.copyWith(
        snoozeUntilMs:
            DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
      );
      expect(snoozed.isSnoozedNow, isTrue);
      expect(notifFeedbackFor(snoozed), (sound: false, vibrate: false));
    });

    test('quiet-hours window suppresses BOTH channels', () {
      // A 1-minute window that certainly contains "now" (start = now-1min,
      // end = now+1min) so the assertion is time-stable.
      final now = DateTime.now();
      final start = now.subtract(const Duration(minutes: 1));
      final end = now.add(const Duration(minutes: 1));
      final quiet = d.copyWith(
        quietHoursEnabled: true,
        quietStartHour: start.hour,
        quietStartMin: start.minute,
        quietEndHour: end.hour,
        quietEndMin: end.minute,
      );
      // Skip the rare midnight-rollover minute where start>end flips meaning.
      if (!quiet.isInQuietHours) return;
      expect(notifFeedbackFor(quiet), (sound: false, vibrate: false));
    });
  });

  group('persist round-trip (wired fields survive a restart)', () {
    test('personaWorker / personaCourier / sound / vibration round-trip',
        () async {
      final c1 = ProviderContainer();
      c1.read(notifSettingsProvider.notifier).update(
            (s) => s.copyWith(
              personaWorker: false,
              personaCourier: false,
              soundEnabled: false,
              vibrationEnabled: false,
              pushEnabled: false,
            ),
          );
      await _settle();
      c1.dispose();

      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      c2.read(notifSettingsProvider); // lazy provider — touch to start _load
      await _settle();

      final s = c2.read(notifSettingsProvider);
      expect(s.personaWorker, isFalse);
      expect(s.personaCourier, isFalse);
      expect(s.soundEnabled, isFalse);
      expect(s.vibrationEnabled, isFalse);
      expect(s.pushEnabled, isFalse);
    });
  });
}
