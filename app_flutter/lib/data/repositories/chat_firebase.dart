// ─────────────────────────────────────────────────────────────────────────────
// FirebaseChatRepository — the S4.1–S4.3 Firestore-backed implementation of
// [ChatRepository], built on the offline-first cache base ([FirestoreCachedRepo]).
// It drops in BEHIND the shared cross-persona chat engine
// (`state/sys_chat.dart`): the engine binds to it (`bindRemote`) and mirrors its
// caches, so every screen keeps reading `chatEngineProvider` unchanged — zero
// UI diffs, the engine's public API untouched.
//
// WHY THIS REPO IS *COMPOSED* (two backing repos, not one — the `site_firebase`
// S3.S precedent): the schema splits chat across TWO collections,
//   • `chatThreads/{id}`  {participants:[uid], names, lastMsg, ts}   (S4.1)
//   • `chatMessages/{id}` {threadId, fromUid, fromRole, text, ts}    (S4.2)
// so messages can stream per-thread without re-reading every thread doc. Each
// gets its own `FirestoreCachedRepo`; [threads] re-assembles the engine's
// `ChatThread` shape (head + its ts-ordered messages) from the two caches, and
// this composer re-fires `notifyListeners` whenever EITHER cache changes — the
// single subscription point the engine listens on.
//
// HOW THE BRIDGE IS HELD (identical to the orders pilot):
//   • reads ([threads]) are SYNCHRONOUS, served from the two in-memory caches
//     each base maintains from its Firestore `snapshots()` listener;
//   • [send] (S4.3) updates the caches OPTIMISTICALLY (instant for the UI) and
//     fires the matching Firestore writes in the background — the message doc
//     PLUS the thread head's `lastMsg`/`ts` denormalisation. A write failure is
//     logged, never thrown.
//
// SEND SEMANTICS ARE A VERBATIM PORT of `ChatEngineNotifier.send`
// (`state/sys_chat.dart`) so chat behaves byte-for-byte like the local path:
//   • trim; no-op on empty text / unknown thread;
//   • message id `m-<microsecondsSinceEpoch>-<role>`;
//   • the BOT thread auto-replies (next `kBotAutoReplies` in rotation, by the
//     thread's current bot-message count, stamped +1ms) — real threads do NOT
//     auto-reply, the other persona answers live (that is S4's whole point).
//
// ⚠️ UID JOIN DEFERRED TO S1 (documented per the SSOT): until the auth fleet
// lands real `auth.uid`s there are no user ids to write, so the existing
// `BsRole`-based identity is mapped VERBATIM —
//   • `chatThreads.participants` carries the role NAMES (`'contractor'`,
//     `'store'`, …) instead of uids;
//   • `chatMessages.fromRole` is written, `fromUid` is OMITTED.
// After S1, this file is the single point that swaps to uid participants
// (`fromDoc`/`toDoc` below + the S5.2/S5.3 rules `participants` checks);
// `fromDoc` already tolerates unknown participant entries (a future uid next to
// a role name is ignored, not fatal) so mixed docs keep decoding.
//
// SEED CONTRACT (offline-first, fresh-backend-safe), per composed repo:
//   • both caches are BORN from the verbatim [kChatThreads] seed (heads +
//     flattened messages) so chat is non-empty before snapshot 1;
//   • a FIRST snapshot that arrives EMPTY (fresh Firestore) → `pushCacheToRemote`
//     seeds that collection from the local seed (first-empty pushes seeds up);
//   • `resetToSeed` → `replaceAll(seed)` on both.
//
// Comment density/voice mirrors `orders_firebase.dart` — the S2.3 template.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/chat_seeds.dart';
import 'package:buildsmart/data/repositories/chat_repository.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:flutter/foundation.dart';

// ─── seed projections (the verbatim kChatThreads, split per collection) ──────

/// The seed thread HEADS — [kChatThreads] minus their messages, with the
/// denormalised `lastMsg`/`ts` taken from each thread's last seed message.
List<_ChatThreadHead> _threadHeadSeed() => [
      for (final t in kChatThreads)
        _ChatThreadHead(
          id: t.id,
          participants: t.participants,
          participantUids: t.participantUids,
          name: t.name,
          avatar: t.avatar,
          isBot: t.isBot,
          lastMsg: t.messages.isEmpty ? '' : t.messages.last.text,
          lastTs: t.messages.isEmpty ? null : t.messages.last.ts,
        ),
    ];

/// The seed MESSAGES — every [kChatThreads] message, flattened (each already
/// carries its `threadId`; `sortBy` restores the ts order after any snapshot).
List<ChatMessage> _chatMessageSeed() =>
    [for (final t in kChatThreads) ...t.messages];

/// Seed-order index for thread heads: Firestore returns documents in doc-id
/// (alphabetical) order, but the UI expects the verbatim seed order — exactly
/// why the orders pilot re-sorts. Unknown ids (post-S1 server-created threads)
/// sort after the seeds, by id, for a stable order across snapshots.
final Map<String, int> _seedThreadOrder = {
  for (var i = 0; i < kChatThreads.length; i++) kChatThreads[i].id: i,
};

// ─── thread heads · collection `chatThreads` ─────────────────────────────────

/// One `chatThreads/{id}` document — a [ChatThread] minus its messages (those
/// live in `chatMessages`), plus the schema's denormalised `lastMsg`/`ts` (what
/// the live conversation LIST renders without loading messages — S4.1).
@immutable
class _ChatThreadHead {
  const _ChatThreadHead({
    required this.id,
    required this.participants,
    required this.name,
    required this.avatar,
    required this.isBot,
    required this.lastMsg,
    required this.lastTs,
    this.participantUids = const [],
  });

  final String id;
  final List<BsRole> participants;

  /// A9 — uid members (auth-truth the rules scope on); `[]` on every seed /
  /// legacy / role-based thread (zero regression). See [ChatThread.participantUids].
  final List<String> participantUids;
  final String name;
  final String avatar;
  final bool isBot;
  final String lastMsg;
  final DateTime? lastTs;

  _ChatThreadHead copyWith({String? lastMsg, DateTime? lastTs}) =>
      _ChatThreadHead(
        id: id,
        participants: participants,
        participantUids: participantUids,
        name: name,
        avatar: avatar,
        isBot: isBot,
        lastMsg: lastMsg ?? this.lastMsg,
        lastTs: lastTs ?? this.lastTs,
      );
}

/// The Firestore-backed thread-head cache (collection `chatThreads`).
class _ChatThreadsRepo extends FirestoreCachedRepo<_ChatThreadHead> {
  _ChatThreadsRepo({RemoteCollectionSource? source})
      : super(source ?? FirestoreCollectionSource('chatThreads'));

  /// The cache is born with the verbatim seed heads so the conversation list is
  /// non-empty before the first snapshot — identical genesis to the engine.
  @override
  List<_ChatThreadHead> get seed => _threadHeadSeed();

  /// doc-id = the thread id (e.g. `th-contractor-store`).
  @override
  String idOf(_ChatThreadHead value) => value.id;

  /// `_ChatThreadHead` → Firestore doc, per the schema
  /// `{participants:[uid], names, lastMsg, ts}`. ⚠️ Pre-S1: `participants`
  /// carries the ROLE NAMES verbatim (no real uids exist yet — see the header);
  /// `names` carries the display name the list renders. `avatar`/`isBot` are
  /// client extras carried so a fresh backend reseeds the full thread (the
  /// pilot's loss-free round-trip rule). The id is the doc-id, not a field.
  @override
  Map<String, dynamic> toDoc(_ChatThreadHead t) => {
        'participants': [for (final r in t.participants) r.name],
        // A9 — the uid members, written ONLY when populated so a seed/role-based
        // thread's doc stays byte-identical to today (forward-ready; the rules
        // scope on this field). Display/isolation keep using `participants`.
        if (t.participantUids.isNotEmpty) 'participantUids': t.participantUids,
        'names': t.name,
        'avatar': t.avatar,
        'isBot': t.isBot,
        'lastMsg': t.lastMsg,
        if (t.lastTs != null) 'ts': t.lastTs!.toIso8601String(),
      };

  /// Firestore doc → `_ChatThreadHead`. Inverse of [toDoc]: the doc-id becomes
  /// `id`; `participants` role-name strings resolve to [BsRole] — an entry that
  /// resolves to NO role (e.g. a real uid once S1 starts writing them) is
  /// skipped rather than fatal, so mixed pre/post-S1 docs keep decoding; a doc
  /// where NOTHING resolves THROWS (structurally bad for the pre-S1 world) and
  /// the base skips it per-doc. `lastMsg`/`ts` are display denormalisations —
  /// tolerated when missing (messages stream from their own collection anyway).
  @override
  _ChatThreadHead fromDoc(RemoteDoc doc) {
    final j = doc.data;
    final raw = j['participants'];
    if (raw is! List) throw const FormatException('chatThreads: no participants');
    final participants = <BsRole>[
      for (final e in raw)
        ...BsRole.values.where((r) => r.name == e), // unknown entry → skipped
    ];
    if (participants.isEmpty) {
      throw const FormatException('chatThreads: no resolvable participants');
    }
    // A9 — uid members: a string list post-migration, absent on every legacy/
    // seed doc → [] (zero regression). Tolerant of non-string entries.
    final uidsRaw = j['participantUids'];
    final participantUids = <String>[
      if (uidsRaw is List)
        for (final e in uidsRaw)
          if (e is String) e,
    ];
    return _ChatThreadHead(
      id: doc.id,
      participants: participants,
      participantUids: participantUids,
      name: (j['names'] as String?) ?? (j['name'] as String?) ?? doc.id,
      avatar: (j['avatar'] as String?) ?? '💬',
      isBot: j['isBot'] == true,
      lastMsg: (j['lastMsg'] as String?) ?? '',
      lastTs: j['ts'] == null ? null : DateTime.tryParse('${j['ts']}'),
    );
  }

  /// Restore the verbatim seed order (Firestore returns doc-id/alphabetical
  /// order; the engine's contract is "order preserved from the seed" — the UI
  /// owns any newest-activity re-ordering). Non-seed threads sort after, by id.
  @override
  List<_ChatThreadHead> sortBy(List<_ChatThreadHead> items) {
    return List<_ChatThreadHead>.of(items)
      ..sort((a, b) {
        final ai = _seedThreadOrder[a.id];
        final bi = _seedThreadOrder[b.id];
        if (ai != null && bi != null) return ai.compareTo(bi);
        if (ai != null) return -1; // seed threads before server-created ones
        if (bi != null) return 1;
        return a.id.compareTo(b.id);
      });
  }

  /// Fresh backend (first snapshot empty) → seed the remote from the local
  /// seed the cache was born with (the five legacy threads appear server-side).
  @override
  void onFirstSnapshotEmpty() => pushCacheToRemote();
}

// ─── messages · collection `chatMessages` ────────────────────────────────────

/// The Firestore-backed message cache (collection `chatMessages`). The model is
/// the engine's own [ChatMessage] — untouched, so the drop-in is preserved
/// exactly as the pilot keeps `Order` untouched.
class _ChatMessagesRepo extends FirestoreCachedRepo<ChatMessage> {
  _ChatMessagesRepo({RemoteCollectionSource? source})
      : super(source ?? FirestoreCollectionSource('chatMessages'));

  /// Born with every seed message (flattened across threads) so each seeded
  /// conversation is non-empty before the first snapshot.
  @override
  List<ChatMessage> get seed => _chatMessageSeed();

  /// doc-id = the message id (`m-<micros>-<role>` / `seed-<thread>-<minute>`).
  @override
  String idOf(ChatMessage value) => value.id;

  /// `ChatMessage` → Firestore doc, per the schema
  /// `{threadId, fromUid, fromRole, text, ts}`. A8 (launch uid-migration) —
  /// `fromUid` is now WRITTEN when the sender was signed-in (stamped at the send
  /// path from `currentUidProvider`); it is OMITTED when empty (signed-out / the
  /// seed / every legacy doc) so those round-trip byte-identical (zero
  /// regression — the A3 `contractorUid` guard). `fromRole` is ALWAYS written
  /// and still drives the mine/theirs UI; the eventual uid-scoping of
  /// messages/thread `participants` activates later via the firestore rules
  /// (forward-ready). The id is the doc-id, not a field.
  @override
  Map<String, dynamic> toDoc(ChatMessage m) => {
        'threadId': m.threadId,
        'fromRole': m.fromRole.name,
        'text': m.text,
        'ts': m.ts.toIso8601String(),
        if (m.fromUid.isNotEmpty) 'fromUid': m.fromUid,
      };

  /// Firestore doc → `ChatMessage`, through the engine's own tolerant decoder
  /// (`ChatMessage.tryFromJson`) with the doc-id as `id` — one mapping, two
  /// worlds. A structurally-bad doc (missing field / unknown role) decodes to
  /// null → THROW, and the base skips it per-doc (never blanks the chat).
  /// A8 — `fromUid` is read tolerantly by the decoder (present on a post-A8 doc,
  /// '' on every legacy/seed doc — the zero-regression default).
  @override
  ChatMessage fromDoc(RemoteDoc doc) {
    final m = ChatMessage.tryFromJson({...doc.data, 'id': doc.id});
    if (m == null) throw const FormatException('chatMessages: bad doc');
    return m;
  }

  /// `orderBy(ts)` (S4.2) re-established client-side: Firestore returns doc-id
  /// order, the conversation renders chronologically. Tie-broken by id (the bot
  /// auto-reply is stamped +1ms after the user line, so the pair stays ordered).
  @override
  List<ChatMessage> sortBy(List<ChatMessage> items) {
    return List<ChatMessage>.of(items)
      ..sort((a, b) {
        final c = a.ts.compareTo(b.ts);
        if (c != 0) return c;
        return a.id.compareTo(b.id);
      });
  }

  /// Fresh backend → push the seed messages up (first-empty seeds the remote).
  @override
  void onFirstSnapshotEmpty() => pushCacheToRemote();
}

// ─── the composed repository ─────────────────────────────────────────────────

/// The Firestore-backed chat store: TWO composed caches (`chatThreads` +
/// `chatMessages`) behind the one [ChatRepository] surface the engine binds to.
class FirebaseChatRepository extends ChangeNotifier implements ChatRepository {
  /// Constructs the repo over the `chatThreads` + `chatMessages` collections.
  /// The real Firestore instance is resolved LAZILY by
  /// [FirestoreCollectionSource] (never here), so construction does not require
  /// Firebase to be initialised. Pass the sources in tests to drive both caches
  /// with fakes.
  FirebaseChatRepository({
    RemoteCollectionSource? threadsSource,
    RemoteCollectionSource? messagesSource,
  })  : _threads = _ChatThreadsRepo(source: threadsSource),
        _messages = _ChatMessagesRepo(source: messagesSource) {
    // EITHER cache changing (a thread head, a message — optimistic or snapshot)
    // re-fires this composer: the single subscription the engine listens on.
    _threads.addListener(_forward);
    _messages.addListener(_forward);
  }

  final _ChatThreadsRepo _threads;
  final _ChatMessagesRepo _messages;

  void _forward() => notifyListeners();

  /// Subscribe both live document streams (S4.1 threads + S4.2 messages).
  /// Errors are guarded by the base; [dispose] cancels both.
  void attach() {
    _threads.attach();
    _messages.attach();
  }

  // ── reads (SYNCHRONOUS — assembled from the two caches) ─────────────────────

  /// Re-assemble the engine's `ChatThread` shape: each head (seed-ordered) with
  /// its messages grouped out of the ts-ordered message cache — so the grouped
  /// lists are already chronological. A head with no messages yet renders empty
  /// (never dropped).
  @override
  List<ChatThread> threads() {
    final byThread = <String, List<ChatMessage>>{};
    for (final m in _messages.cached()) {
      (byThread[m.threadId] ??= <ChatMessage>[]).add(m);
    }
    return [
      for (final h in _threads.cached())
        ChatThread(
          id: h.id,
          participants: h.participants,
          participantUids: h.participantUids,
          name: h.name,
          avatar: h.avatar,
          isBot: h.isBot,
          messages: byThread[h.id] ?? const [],
        ),
    ];
  }

  // ── writes (optimistic caches + background Firestore) ───────────────────────

  /// Message factory — the engine's verbatim id scheme. A8: [fromUid] stamps
  /// the sender's `auth.uid` on the user line (omitted from the doc when ''),
  /// matching the engine's `_mk`.
  ChatMessage _mk(String threadId, BsRole fromRole, String text, DateTime ts,
          {String fromUid = ''}) =>
      ChatMessage(
        id: 'm-${ts.microsecondsSinceEpoch}-${fromRole.name}',
        threadId: threadId,
        fromRole: fromRole,
        text: text,
        ts: ts,
        fromUid: fromUid,
      );

  /// S4.3 — verbatim port of `ChatEngineNotifier.send` via upsert: the message
  /// lands in the `chatMessages` cache optimistically (visible synchronously to
  /// BOTH participants — they read the same shared store) and the thread head's
  /// `lastMsg`/`ts` denormalisation is upserted alongside; both Firestore
  /// writes fire in the background (guarded — a failure is logged, never
  /// thrown). The BOT thread appends its deterministic auto-reply (rotation by
  /// the thread's current bot-message count, +1ms); real threads do NOT
  /// auto-reply — the other persona answers live.
  @override
  void send(String threadId, BsRole fromRole, String text,
      {String fromUid = ''}) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final heads = _threads.cached();
    final idx = heads.indexWhere((h) => h.id == threadId);
    if (idx < 0) return;
    final head = heads[idx];
    final now = DateTime.now();
    // A8: the user line carries the sender uid; the bot auto-reply (appended
    // below) does NOT — it is the system, not a signed-in user.
    final appended = <ChatMessage>[
      _mk(threadId, fromRole, trimmed, now, fromUid: fromUid),
    ];
    if (head.isBot && fromRole != BsRole.bot) {
      final replyIdx = _messages
          .cached()
          .where((m) => m.threadId == threadId && m.fromRole == BsRole.bot)
          .length;
      appended.add(
        _mk(
          threadId,
          BsRole.bot,
          kBotAutoReplies[replyIdx % kBotAutoReplies.length],
          now.add(const Duration(milliseconds: 1)),
        ),
      );
    }
    for (final m in appended) {
      _messages.upsert(m, prepend: false); // sortBy keeps it chronological
    }
    _threads.upsert(
      head.copyWith(lastMsg: appended.last.text, lastTs: appended.last.ts),
    );
  }

  /// Reset both collections to the verbatim seed — whole-cache optimistic
  /// replace that also re-writes the seed to the remote (the orders
  /// `resetToSeed` semantics, applied per composed repo).
  @override
  void resetToSeed() {
    _threads.replaceAll(_threadHeadSeed());
    _messages.replaceAll(_chatMessageSeed());
  }

  // ── lifecycle ────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _threads
      ..removeListener(_forward)
      ..dispose();
    _messages
      ..removeListener(_forward)
      ..dispose();
    super.dispose();
  }
}
