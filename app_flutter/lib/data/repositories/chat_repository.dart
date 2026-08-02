// ─────────────────────────────────────────────────────────────────────────────
// ChatRepository — the read/write surface for the shared cross-persona chat
// store (S4.1–S4.3).
//
// SERVER-READY SEAM (modeled on `orders_repository.dart`, T6.1/S3). Chat never
// had a repository file because the engine itself (`state/sys_chat.dart`,
// `ChatEngineNotifier`) IS the local store — seeded from `kChatThreads`,
// persisted as a SharedPreferences overlay. So unlike orders there is no
// `chat_local.dart` impl to wrap: on the local path the engine keeps being the
// single source of truth, and this seam only exists so the Firestore-backed
// implementation (`chat_firebase.dart`) can drop IN BEHIND the engine — the
// engine binds to it (`ChatEngineNotifier.bindRemote`) and every screen keeps
// reading `chatEngineProvider` unchanged (zero UI diffs).
//
// WHY `implements Listenable` (the one structural difference from the S3
// seams): the engine subscribes to the repository (`addListener`) and re-reads
// the sync [threads] on every cache change — that is the S4 real-time loop
// (Firestore `snapshots()` → cache → notify → engine state). Carrying
// Listenable ON the seam lets `sys_chat.dart` bind through the interface alone,
// without importing the Firebase implementation.
//
// Method surface mirrors what the engine exposes today:
//   • read   — [threads]: the full live thread list (heads + their messages),
//              seed-ordered; the engine filters per-persona via `threadsFor`.
//   • write  — [send] (S4.3: message write + thread lastMsg/ts update) ·
//              [resetToSeed] (tests / demo reset).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/chat_firebase.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show FirestoreCollectionSource, RemoteCollectionSource;
import 'package:buildsmart/state/auth_state.dart' show currentUidProvider;
import 'package:buildsmart/state/sys_chat.dart';
import 'package:flutter/foundation.dart' show Listenable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Server-ready contract over the shared chat store. The current local backing
/// is `ChatEngineNotifier` itself (`state/sys_chat.dart`); the Firestore impl
/// ([FirebaseChatRepository]) drops in behind this contract and the engine
/// mirrors it (swap-implementation-only — providers + UI unchanged).
abstract class ChatRepository implements Listenable {
  /// The full live thread list — every thread head with its ts-ordered
  /// messages, in the verbatim seed order. SYNCHRONOUS (served from the cache);
  /// 🔒 per-persona isolation stays the engine's job (`threadsFor`).
  List<ChatThread> threads();

  /// S4.3 — append a message from [fromRole] to [threadId] AND update the
  /// thread head's `lastMsg`/`ts`. Verbatim `ChatEngineNotifier.send` semantics:
  /// trims, no-op on empty text / unknown thread, bot thread auto-replies.
  /// A8 — [fromUid] (the sender's `auth.uid`, '' when signed-out) is stamped on
  /// the message doc when non-empty; additive + display-neutral.
  void send(String threadId, BsRole fromRole, String text,
      {String fromUid = ''});

  /// #8/3a (per-user chat) — CREATE-OR-GET the per-user DM thread for
  /// [participantUids]. The thread id is the DETERMINISTIC `dm-<sorted, de-duped
  /// uids joined by __>` ([dmThreadId], sys_chat.dart), so the same set of people
  /// always maps to ONE thread on every device (natural dedup, no lookup).
  /// Creates the `chatThreads/{id}` head — real `participantUids`, name, avatar,
  /// ts — if absent, and NEVER overwrites an existing thread (create-or-get);
  /// an optimistic local cache upsert mirrors it back like [send]. At least TWO
  /// distinct uids are required to create; the (always-computed) id is returned
  /// regardless.
  String createOrGetThread(List<String> participantUids,
      {String name = '', String avatar = '💬'});

  /// Reset both collections to the verbatim `kChatThreads` seed (tests / a
  /// future "demo reset"). Mirrors `ChatEngineNotifier.resetToSeed`.
  void resetToSeed();

  /// A14 (launch uid-migration) — STAMP a thread head's `participantUids` (the
  /// auth-truth the Firestore rules scope on). Called by the engine's
  /// [ChatEngineNotifier.ensureParticipantUids] when `kUidScopedQueries` is ON
  /// and the union of the thread's roles' real uids has been resolved (A7).
  /// Optimistic cache upsert + background head write (toDoc already persists
  /// participantUids when non-empty); a no-op on an unknown thread. Gated +
  /// additive — never called with the flag OFF, so today's path is unchanged.
  void setParticipantUids(String threadId, List<String> uids);

  /// #chat-delivery-status — RE-FIRE a `failed` message's background write (the
  /// "נסה שוב" action). Re-marks the message [msgId] in [threadId] `pending` and
  /// re-attempts the Firestore write with the same outcome callback. A no-op on
  /// the local/demo path (it has no Firebase → writes never fail → nothing rests
  /// at `failed`); the Firestore impl ([FirebaseChatRepository]) does the work.
  void retry(String threadId, String msgId);
}

/// The chat repository provider — the S4 seam the engine binds through. When
/// Firebase is initialised (the real app, `main()` calls `Firebase.initializeApp`)
/// the Firestore-backed [FirebaseChatRepository] is returned — it `attach()`es
/// its two `snapshots()` listeners (chatThreads + chatMessages) and is disposed
/// with the provider. When Firebase is NOT initialised (the entire Firebase-free
/// test suite) this resolves to NULL and the engine stays the purely-local store
/// it is today — byte-identical behavior, Firestore never touched. (Null instead
/// of a `LocalChatRepository`: the local impl IS the engine, so wrapping it here
/// would only add a dead delegation layer.)
final chatRepositoryProvider = Provider<ChatRepository?>((ref) {
  if (!useFirebaseBackend) return null;
  // A14 — UID-SCOPED `chatThreads` listen (behind `kUidScopedQueries`, default
  // OFF), mirroring `ordersRepositoryProvider`. The whole-collection chatThreads
  // listen is DENIED doc-by-doc by the participant-scoped rule (RULES ARE NOT
  // FILTERS), which silently blanks live threads. With the flag ON *and* a uid
  // known, scope the listen to threads the signed-in user belongs to —
  // `where('participantUids', arrayContains: uid)`, the exact field the rules
  // (chatThreads read/write) and the now-flipped composite index use. Flag OFF /
  // no-uid / Firebase-free ⇒ scope == null ⇒ the source stays UNSCOPED, the
  // whole-collection listen BYTE-IDENTICAL to today (the zero-regression
  // invariant).
  final uid = ref.watch(currentUidProvider);
  final scoped = kUidScopedQueries && uid != null && uid.isNotEmpty;
  final threadsSource = scoped
      ? FirestoreCollectionSource(
          'chatThreads',
          scope: (c) => c.where('participantUids', arrayContains: uid),
        )
      : null;
  // #chat-live-messages — the `chatMessages` READ rule is PER-DOC
  // (`auth.uid in threadParticipants(resource.data.threadId)`, a get() on the
  // parent thread), so — "rules are not filters" — the ONLY query Firestore can
  // prove is one that PINS `threadId`. A whole-collection chatMessages listen is
  // therefore DENIED as a whole and silently blanks live messages (the send/
  // receive break). When scoped, hand the repo a threadId → scoped-source
  // FACTORY: it opens one `where('threadId', isEqualTo: id)` listen per
  // participating thread and merges them (see [_PerThreadChatMessagesSource]), so
  // messages flow in on BOTH sides. Flag OFF / no-uid / Firebase-free ⇒ null ⇒
  // the base whole-collection listen, BYTE-IDENTICAL to before this fix.
  final RemoteCollectionSource Function(String threadId)? messagesSourceFor =
      scoped
          ? (threadId) => FirestoreCollectionSource(
                'chatMessages',
                scope: (c) => c.where('threadId', isEqualTo: threadId),
                bound: (q) => q.orderBy('ts', descending: true).limit(500),
              )
          : null;
  final repo = FirebaseChatRepository(
    threadsSource: threadsSource,
    messagesSourceFor: messagesSourceFor,
  )..attach();
  ref.onDispose(repo.dispose);
  return repo;
});
