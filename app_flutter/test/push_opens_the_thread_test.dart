// A tapped notification has to land on the conversation it announced.
//
// The seam for this shipped empty. `PushController._onOpened` carries the
// comment "actual deep-navigation ... is a documented FOLLOW-UP", and no call
// site ever passed an `onOpened` — so the payload arrived with its `threadId`
// and the app opened on whatever screen it had been on. A notification that
// names a person, quotes their message, and then drops you on the catalog is a
// broken promise.
//
// THE TRAP THAT MAKES THIS SUBTLE. `ChatsScreen` opens a conversation from
// `ref.listen`, which fires on a CHANGE and not for a value that was already
// there. Every push route sets the id before that screen exists:
//
//   cold launch   the app was not running when the id became known
//   web, no tab   the browser opens a fresh page carrying ?thread=
//   warm resume   the id is set, then we navigate — the screen mounts after
//
// So a listen-only handoff drops the id in all three, and the failure looks like
// "the notification works, it just doesn't do anything". Hence: park the value,
// read it on arrival, clear it as it is read.

import 'package:buildsmart/state/push_routing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('threadIdFrom — reading the FCM payload', () {
    test('takes the threadId the chat push sends', () {
      // The key matches functions/src/push.ts → onChatMessageCreated.
      expect(threadIdFrom({'type': 'chat', 'threadId': 't-42'}), 't-42');
    });

    test('an ORDER push routes nowhere — it is not a conversation', () {
      expect(threadIdFrom({'type': 'order', 'orderId': 'BS-1'}), isNull,
          reason: 'routing an order to a chat is worse than not routing it');
    });

    test('empty, blank and non-string ids are all "no thread"', () {
      expect(threadIdFrom({'threadId': ''}), isNull);
      expect(threadIdFrom({'threadId': '   '}), isNull);
      expect(threadIdFrom({'threadId': 42}), isNull);
      expect(threadIdFrom(const {}), isNull);
    });

    test('surrounding whitespace is trimmed, not rejected', () {
      expect(threadIdFrom({'threadId': ' t-7 '}), 't-7');
    });
  });

  group('threadIdFromLaunchUrl — the browser opened with no tab', () {
    test('reads ?thread= from the launch url', () {
      expect(
        threadIdFromLaunchUrl('https://buildsmart-il.com/?thread=t-9'),
        't-9',
      );
    });

    test('an ordinary visit carries no thread', () {
      expect(threadIdFromLaunchUrl('https://buildsmart-il.com/'), isNull);
      expect(threadIdFromLaunchUrl(''), isNull);
      expect(threadIdFromLaunchUrl(null), isNull);
    });

    test('a percent-encoded id survives the round trip', () {
      final encoded = Uri.encodeQueryComponent('t/9 a');
      expect(threadIdFromLaunchUrl('https://x.com/?thread=$encoded'), 't/9 a');
    });

    test('a malformed url degrades to null instead of throwing', () {
      expect(threadIdFromLaunchUrl(':::not a url:::'), isNull);
    });
  });

  group('the pending thread survives until something consumes it', () {
    test('THE TRAP: a value set BEFORE anyone listens is still readable', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      // This is the cold-launch order: the id lands first, the screen later.
      c.read(pendingPushThreadProvider.notifier).state = 't-1';

      var heardByListener = false;
      c.listen<String?>(pendingPushThreadProvider, (_, __) {
        heardByListener = true;
      });

      expect(heardByListener, isFalse,
          reason: 'exactly why listening alone loses the notification');
      expect(c.read(pendingPushThreadProvider), 't-1',
          reason: 'but reading on arrival still finds it');
    });

    test('consuming clears it, so the same thread can arrive again', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(pendingPushThreadProvider.notifier).state = 't-2';

      expect(c.read(pendingPushThreadProvider), 't-2');
      c.read(pendingPushThreadProvider.notifier).state = null;
      expect(c.read(pendingPushThreadProvider), isNull,
          reason: 'left in place, a second push for t-2 would never re-fire');
    });

    test('nothing pending is the ordinary case and reads as null', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(pendingPushThreadProvider), isNull);
    });

    test('a later notification replaces an unconsumed one', () {
      // Two messages before the screen opens: the newest is the one tapped.
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(pendingPushThreadProvider.notifier).state = 't-3';
      c.read(pendingPushThreadProvider.notifier).state = 't-4';
      expect(c.read(pendingPushThreadProvider), 't-4');
    });
  });

  group('afterThisFrame — opening a route is never done mid-build', () {
    testWidgets('the callback runs after the frame, not during it',
        (tester) async {
      // Pushing a route while the tree is still building is the release-only
      // crash this codebase has already paid for once, and every push entry
      // point arrives during a build or a lifecycle callback.
      var ran = false;
      await tester.pumpWidget(
        Builder(
          builder: (_) {
            afterThisFrame(() => ran = true);
            expect(ran, isFalse, reason: 'must not run inside build');
            return const SizedBox.shrink();
          },
        ),
      );
      await tester.pump();
      expect(ran, isTrue);
    });
  });
}
