// Studio Pillar 3 · step 91 — the anon-but-stable actorKey + the sign-in stitch.
//
// PROVED HERE (§5), Firebase-free with a mock SharedPreferences + a recording
// stitch writer (the intel_sink_test.dart:30 `_RecordingWriter` idiom):
//   1. PER-INSTALL STABILITY — a signed-out actorKey is a per-install uuid that is
//      minted ONCE, is identical across two reads, and SURVIVES a restart (a fresh
//      container over the same prefs re-reads the SAME key, never re-minting);
//   2. uid SHADOW — when signed-in, actorKey resolves to the uid while the anon key
//      still exists underneath (the continuity source the stitch bridges from);
//   3. anon→uid CONTINUITY — a sign-in emits EXACTLY ONE `identify` event carrying
//      the anon key (as actorKey) + the new uid (top-level, NOT a prop), and the
//      gated stitch write carries the SAME pair, so the pre-login journey stays
//      joinable;
//   4. OFF-BACKEND NOT WRITTEN — with the gate shut (the default test build) the
//      stitch writer is the inert Noop, so NO Firestore write is attempted, and no
//      uid ever lands in a visible prop (R1-4);
//   5. ERASURE (§9) — erase() drops the local key + removes it from prefs, severing
//      client-side continuity.
import 'package:buildsmart/state/auth_state.dart' show currentUidProvider;
import 'package:buildsmart/state/intel/actor_key.dart';
import 'package:buildsmart/state/intel/intel_events.dart';
import 'package:buildsmart/state/intel/intel_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A recording stitch writer — proves the (gated) stitch WRITE shape without
/// Firebase, mirroring intel_sink_test.dart's `_RecordingWriter`. Records each
/// (uid, anonKey) pair; NEVER throws.
class _RecordingStitchWriter implements ActorStitchWriter {
  final List<({String anonKey, String uid})> writes =
      <({String anonKey, String uid})>[];

  @override
  Future<void> writeStitch({
    required String uid,
    required String anonKey,
  }) async {
    writes.add((uid: uid, anonKey: anonKey));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(const <String, Object>{}));

  group('actorKey — per-install stability (§5)', () {
    test(
      'a signed-out actorKey is minted ONCE, is stable across two reads, and '
      'SURVIVES a restart (fresh container, same prefs → the SAME key)',
      () async {
        // First "install".
        final c1 = ProviderContainer();
        addTearDown(c1.dispose);
        await c1.read(anonActorKeyProvider.notifier).ready; // load + mint settle

        final k1 = c1.read(actorKeyProvider);
        final k1again = c1.read(actorKeyProvider);
        expect(k1, isNotNull);
        expect(k1, isNotEmpty);
        expect(k1again, k1); // two reads → the SAME key (no re-mint)

        // The mint persisted it to disk.
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(kActorKeyPrefsKey), k1);

        // "Restart": a fresh container over the SAME (mock) prefs.
        final c2 = ProviderContainer();
        addTearDown(c2.dispose);
        await c2.read(anonActorKeyProvider.notifier).ready;
        expect(c2.read(actorKeyProvider), k1); // stable across restart
      },
    );

    test(
      'a signed-in uid SHADOWS the anon key (actorKey == uid), while the anon key '
      'still exists underneath as the stitch continuity source',
      () async {
        final c = ProviderContainer(
          overrides: <Override>[
            currentUidProvider.overrideWithValue('uid-42'),
          ],
        );
        addTearDown(c.dispose);
        await c.read(anonActorKeyProvider.notifier).ready;

        expect(c.read(actorKeyProvider), 'uid-42'); // uid wins
        expect(c.read(anonActorKeyProvider), isNotNull); // anon key preserved
      },
    );
  });

  group('sign-in stitch — anon→uid continuity (§5)', () {
    test(
      'a sign-in emits ONE identify carrying the anon key + the new uid, and the '
      'gated stitch write carries the SAME pair (the journey stays joinable)',
      () async {
        final uid = StateProvider<String?>((_) => null);
        final writer = _RecordingStitchWriter();
        final c = ProviderContainer(
          overrides: <Override>[
            currentUidProvider.overrideWith((ref) => ref.watch(uid)),
            actorStitchWriterProvider.overrideWithValue(writer),
          ],
        );
        addTearDown(c.dispose);

        // Activate the (otherwise dormant) stitch listener + settle the anon key.
        c.read(actorStitchProvider);
        await c.read(anonActorKeyProvider.notifier).ready;
        final anon = c.read(anonActorKeyProvider);
        expect(anon, isNotNull);
        // Before sign-in, the actorKey IS the anon key.
        expect(c.read(actorKeyProvider), anon);

        // Sign in.
        c.read(uid.notifier).state = 'uid-1';
        await pumpEventQueue();

        // Exactly ONE identify, carrying BOTH ids for the stitch.
        final ids = c
            .read(intelLogProvider)
            .where((e) => e.name == IntelEvents.identify)
            .toList();
        expect(ids, hasLength(1));
        expect(ids.single.actorKey, anon); // the anon key IS recorded (join key)
        expect(ids.single.uid, 'uid-1'); // the new pseudonymous id
        expect(ids.single.props, isEmpty); // no uid in a visible prop (R1-4)

        // The persistent mapping write carried the SAME pair.
        expect(writer.writes, hasLength(1));
        expect(writer.writes.single.uid, 'uid-1');
        expect(writer.writes.single.anonKey, anon);

        // After sign-in, the actorKey resolves to the uid (continuity handed off).
        expect(c.read(actorKeyProvider), 'uid-1');
      },
    );
  });

  group('off-backend — the stitch is NEVER written (§3 / DoD)', () {
    test(
      'DEFAULT (off-backend, unconsented) → the stitch writer is the Noop; a '
      'sign-in still emits identify but attempts NO Firestore write, and no uid '
      'lands in a visible prop',
      () async {
        final uid = StateProvider<String?>((_) => null);
        final c = ProviderContainer(
          overrides: <Override>[
            currentUidProvider.overrideWith((ref) => ref.watch(uid)),
          ],
        );
        addTearDown(c.dispose);

        // useFirebaseBackend && kIntelLive are const-false in the test build, so
        // the gate stays shut → the inert writer (nothing can touch Firestore).
        expect(c.read(actorStitchWriterProvider), isA<NoopActorStitchWriter>());

        c.read(actorStitchProvider);
        await c.read(anonActorKeyProvider.notifier).ready;
        final anon = c.read(anonActorKeyProvider);

        c.read(uid.notifier).state = 'uid-9';
        await pumpEventQueue();

        // The local identify STILL fires (the on-device buffer is always-on)…
        final ids = c
            .read(intelLogProvider)
            .where((e) => e.name == IntelEvents.identify)
            .toList();
        expect(ids, hasLength(1));
        expect(ids.single.actorKey, anon);
        // …but NO uid is echoed into a visible prop (invariant R1-4).
        expect(ids.single.props, isEmpty);
        expect(ids.single.props.containsValue('uid-9'), isFalse);
      },
    );
  });

  group('erasure (§9) — "forget me" severs client-side continuity', () {
    test('erase() drops the local key AND removes it from prefs', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final notifier = c.read(anonActorKeyProvider.notifier);
      await notifier.ready;
      expect(c.read(anonActorKeyProvider), isNotNull); // minted

      await notifier.erase();

      expect(c.read(anonActorKeyProvider), isNull); // continuity severed
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(kActorKeyPrefsKey), isNull); // gone from disk
    });
  });
}
