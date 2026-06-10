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

import 'package:buildsmart/data/repositories/chat_firebase.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
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
  void send(String threadId, BsRole fromRole, String text);

  /// Reset both collections to the verbatim `kChatThreads` seed (tests / a
  /// future "demo reset"). Mirrors `ChatEngineNotifier.resetToSeed`.
  void resetToSeed();
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
  if (Firebase.apps.isEmpty) return null;
  final repo = FirebaseChatRepository()..attach();
  ref.onDispose(repo.dispose);
  return repo;
});
