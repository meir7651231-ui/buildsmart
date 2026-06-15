// SHARED CROSS-PERSONA CHAT ENGINE — the single live message store that makes
// "אותו מסך-שיחות אצל כולם" real: a message the 🏪 store sends lands in the same
// thread the 👷 contractor reads, and vice-versa (cross-persona wiring, SPEC
// `SPEC-cross-persona-chat.md` CH-1). This is the Flutter/Riverpod lift of the
// chat data from `chats_screen.dart`'s STATIC `const _kThreads` (+ bot
// auto-reply) into ONE live list every role reads & writes — EXACTLY the shape
// `worker_tasks_engine.dart` (audit H2) used for tasks and `orders_engine.dart`
// used for orders: a `_loaded`-guard + a `persist`-flag + a compact
// SharedPreferences overlay.
//
// 🔒 ISOLATION (SPEC §2.5): the store is shared, but ACCESS is not. A thread
// lists its [ChatThread.participants]; [threadsFor] returns only the threads a
// given role takes part in — so the store never sees a contractor↔manager
// thread. The widget (`ChatsScreen`) decides navigation/wrapping per-persona;
// this engine only decides which messages are *visible* to whom.
//
// PERSIST SHAPE: only `messages` grow at runtime (threads themselves are
// seeded), so — mirroring the worker-tasks `{id: status}` overlay — we persist a
// compact `{threadId: [{id, fromRole, text, ts}, ...]}` overlay of each thread's
// messages and re-apply it onto the verbatim [kChatThreads] seed on load. A seed
// edit (new thread) simply has no overlay; a corrupt payload keeps the seed.

// 🔌 SERVER (S4.1–S4.3): when Firebase is initialised the engine BINDS to the
// Firestore-backed [ChatRepository] (`chat_firebase.dart`, two composed caches:
// chatThreads + chatMessages) and becomes a live MIRROR of it — reads stay
// sync, the public API is unchanged, and every screen keeps watching this same
// provider. Without Firebase (the entire test suite) the engine IS the store,
// byte-identical to before. See [ChatEngineNotifier.bindRemote].

import 'dart:async';
import 'dart:convert';

import 'package:buildsmart/data/chat_seeds.dart';
import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/data/repositories/chat_repository.dart';
import 'package:buildsmart/data/repositories/users_lookup.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── model ──────────────────────────────────────────────────────────────────

/// The personas that can take part in a chat. `bot` is the special auto-reply
/// counterpart kept from the legacy `chats_screen` (SPEC §6 — "bot נשאר").
enum BsRole { contractor, store, courier, worker, manager, bot }

/// A single message in a thread. `fromRole` drives "mine vs theirs" in the UI
/// (the reading persona's own messages render right, others left — SPEC §1
/// "כיווניות").
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.fromRole,
    required this.text,
    required this.ts,
    this.fromUid = '',
  });

  final String id;
  final String threadId;
  final BsRole fromRole;
  final String text;
  final DateTime ts;

  /// A8 (launch uid-migration) — the sender's `auth.uid` when the message was
  /// sent while signed-in, else ''. Additive and display-neutral: [fromRole]
  /// still drives the mine/theirs rendering; a later phase (post-S1) scopes
  /// `chatMessages`/thread `participants` on this uid (the server activates that
  /// via the firestore rules — see chat_firebase.dart's deferred-join note).
  /// Written only when non-empty so the seed + every legacy/pre-A8 doc
  /// round-trips byte-identical (zero regression).
  final String fromUid;

  Map<String, dynamic> toJson() => {
        'id': id,
        'threadId': threadId,
        'fromRole': fromRole.name,
        'text': text,
        'ts': ts.toIso8601String(),
        if (fromUid.isNotEmpty) 'fromUid': fromUid,
      };

  static ChatMessage? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final threadId = raw['threadId'];
    final text = raw['text'];
    final ts = DateTime.tryParse('${raw['ts']}');
    final role = BsRole.values
        .where((r) => r.name == raw['fromRole'])
        .cast<BsRole?>()
        .firstWhere((_) => true, orElse: () => null);
    if (id is! String || threadId is! String || text is! String ||
        ts == null || role == null) {
      return null;
    }
    return ChatMessage(
      id: id,
      threadId: threadId,
      fromRole: role,
      text: text,
      ts: ts,
      // A8 — tolerant read: present on a post-A8 doc, '' on every legacy/seed
      // doc (the zero-regression default). A non-String value coerces to ''.
      fromUid: raw['fromUid'] is String ? raw['fromUid'] as String : '',
    );
  }
}

/// A conversation between [participants] (2 personas, or [BsRole.bot] for the
/// chatbot thread). [threadsFor] keys off [participants] for isolation.
class ChatThread {
  const ChatThread({
    required this.id,
    required this.participants,
    required this.name,
    required this.avatar,
    required this.messages,
    this.isBot = false,
    this.audience = 'contractor',
    this.participantUids = const [],
  });

  final String id;
  final List<BsRole> participants;
  final String name;
  final String avatar;
  final List<ChatMessage> messages;

  /// The chatbot thread keeps its legacy auto-reply (SPEC §6).
  final bool isBot;

  /// Which board's chat list the thread belongs to (contract §3):
  /// 'contractor' (the default — ALL legacy threads keep their behavior) ·
  /// 'worker' · 'courier'. The shared bot thread is surfaced to every board
  /// audience by the UI filter (`chats_screen.dart`), not by this field.
  final String audience;

  /// A9 (launch uid-migration) — the Firebase uids of the thread's members, the
  /// auth-truth the Firestore rules (`chatThreads`/`chatMessages`) scope on
  /// (`request.auth.uid in participantUids`). EMPTY on every seed / role-based /
  /// pre-migration thread (the zero-regression default): [participants] keeps
  /// carrying the role identity for display + [threadsFor] isolation. Populating
  /// it (per-user thread creation) is the owner/activation step — until then it
  /// is inert and [chatThreadVisibleToUid] treats an empty list as "visible".
  final List<String> participantUids;

  ChatThread copyWith({
    List<ChatMessage>? messages,
    List<String>? participantUids,
  }) =>
      ChatThread(
        id: id,
        participants: participants,
        name: name,
        avatar: avatar,
        messages: messages ?? this.messages,
        isBot: isBot,
        audience: audience,
        participantUids: participantUids ?? this.participantUids,
      );
}

/// A9 — pure uid-visibility predicate for a chat thread (forward-ready, gated by
/// `kUidScopedQueries` at the call site). A thread with NO [participantUids] is
/// legacy/un-migrated → VISIBLE to everyone (zero regression — today's role
/// threads stay shared); once populated, only its members (uid ∈ list) see it.
/// Pure → unit-tested directly, mirrors the rules' `uid in participantUids`.
bool chatThreadVisibleToUid(List<String> participantUids, String uid) =>
    participantUids.isEmpty || participantUids.contains(uid);

// ─── engine ───────────────────────────────────────────────────────────────────

/// SharedPreferences key for the persisted cross-persona chat messages.
const String kSysChatKey = 'bs.sys-chat.v1';

/// F-56 · cap on the PERSISTED messages per thread. prefs is a bounded budget
/// (~5MB localStorage on web), not an unbounded archive — attendance reports
/// (#86.2) and daily reports (#82) accumulate on every send, so [_persist]
/// keeps only the newest [kSysChatPersistCap] messages of each thread on disk
/// (the in-memory list is untouched within the session). SERVER-SWAP: the
/// server's chat store replaces this cap with real history + pagination when
/// the backend lands.
const int kSysChatPersistCap = 200;

/// Bot auto-replies — lifted verbatim from the legacy `_ChatPage` so the bot
/// thread keeps the exact same behavior (SPEC §6).
const List<String> kBotAutoReplies = [
  'קיבלתי, תודה 👍',
  'בסדר גמור.',
  'אעדכן אותך בהקדם.',
  'מעולה.',
];

// ─── board-audience seed threads (contract §3) ────────────────────────────────

/// A deterministic seed instant for the board-audience threads — fixed (not
/// `DateTime.now()`), mirroring `chat_seeds.dart`'s `_seedDay`, so ids/order
/// are stable for tests and across rebuilds.
final DateTime _boardSeedDay = DateTime(2026, 6, 7, 8);

ChatMessage _boardSeed(
  String threadId,
  BsRole from,
  String text, {
  required int minute,
}) =>
    ChatMessage(
      id: 'seed-$threadId-$minute',
      threadId: threadId,
      fromRole: from,
      text: text,
      ts: _boardSeedDay.add(Duration(minutes: minute)),
    );

/// 🦺 WORKER-audience demo threads (board W, task #70): the worker board's
/// reduced chat list — 'קבלן' + 'מנהל' (the shared bot thread is added by the
/// UI for every board audience). Demo content references the REAL seeded tasks
/// (`kPersonaTasks` ids 1/3 and a `kTaskSteps` step) — nothing invented.
/// SERVER-SWAP: replaced by live server threads when the chat backend lands.
final List<ChatThread> kWorkerChatThreads = [
  ChatThread(
    id: 'th-worker-contractor',
    participants: const [BsRole.worker, BsRole.contractor],
    audience: 'worker',
    name: 'קבלן',
    avatar: '👷',
    messages: [
      _boardSeed('th-worker-contractor', BsRole.contractor,
          'בוקר טוב, היום ממשיכים בהתקנת קו מים חם — חדר רחצה.',
          minute: -30),
      _boardSeed('th-worker-contractor', BsRole.contractor,
          'לא לשכוח בדיקת אטימה בלחץ מים לפני סגירת הקירות.',
          minute: -25),
    ],
  ),
  // #110 — the manager↔worker thread is APP SUPPORT/help, NOT the worker's boss
  // (the boss = the contractor, 'th-worker-contractor'). Display name + avatar
  // are retagged to "תמיכה" / 🎧 so the worker never reads it as a managing
  // superior; the thread id, participants, audience and visibility are
  // UNCHANGED (the seed-lock + isolation tests key off the id, not the name).
  ChatThread(
    id: 'th-worker-manager',
    participants: const [BsRole.worker, BsRole.manager],
    audience: 'worker',
    name: 'תמיכה',
    avatar: '🎧',
    messages: [
      _boardSeed('th-worker-manager', BsRole.manager,
          'תזכורת: משימה שהסתיימה נשלחת לאישור עם תמונת ביצוע 📸',
          minute: -90),
      _boardSeed('th-worker-manager', BsRole.manager,
          'איטום רצפת מקלחת ממתין לאישור — אעבור על זה היום.',
          minute: -45),
    ],
  ),
];

/// The full engine seed: the legacy cross-persona threads (`chat_seeds.dart`,
/// all audience-'contractor' by default) + the board-audience lists. The
/// courier board (K) appends its own list here the same way.
List<ChatThread> _seedThreads() => [...kChatThreads, ...kWorkerChatThreads];

class ChatEngineNotifier extends StateNotifier<List<ChatThread>> {
  ChatEngineNotifier({
    this.persist = true,
    this.lookup,
    this.currentUid,
    bool? uidScoped,
  })  : uidScoped = uidScoped ?? kUidScopedQueries,
        super(_seedThreads()) {
    if (persist) _load();
  }

  /// When false (tests), skip SharedPreferences entirely so the in-memory
  /// seed/flow can be asserted in isolation (the worker-tasks pattern).
  final bool persist;

  /// A14 (launch uid-migration) — the UID-SCOPED gate, DEFAULTING to the
  /// compile-time `kUidScopedQueries` (the provider passes nothing, so
  /// production is gated EXACTLY by that flag — OFF today). A test injects
  /// `uidScoped: true` to drive the population end-to-end in the standard
  /// (define-less) suite, the way every other compile-time switch in this app
  /// is made unit-testable without a recompile. OFF ⇒ [ensureParticipantUids]
  /// is a no-op ⇒ participantUids stays empty ⇒ zero regression.
  final bool uidScoped;

  /// A14 (launch uid-migration) — the COUNTERPARTY → uid directory (A7), or
  /// null on the local/Firebase-free path (the whole test suite, unless a test
  /// injects a fake). When `kUidScopedQueries` is ON and this is non-null,
  /// [ensureParticipantUids] resolves a thread's [ChatThread.participantUids]
  /// as the UNION of the real uids of all its participant ROLES — so the
  /// Firestore rules' `uid in participantUids` becomes a REAL per-user scope.
  /// Injectable so a test drives population with a fake returning known uids.
  final UsersLookup? lookup;

  /// A14 — the signed-in `auth.uid` getter (`currentUidProvider`'s value), or a
  /// getter that returns null on the signed-out / Firebase-free path. The
  /// SENDER's uid is always folded into the resolved [ChatThread.participantUids]
  /// so the sender can read the thread they just stamped (the rules scope on it).
  /// A getter (not a snapshot) so it always reads the live current identity.
  final String? Function()? currentUid;

  /// A14 — thread ids whose participantUids resolve is in flight, so a second
  /// [ensureParticipantUids] (e.g. a rapid second send) does not kick a
  /// duplicate async resolve before the first stamps.
  final Set<String> _uidResolveInFlight = {};

  /// True once a mutation applied or _load completed — guards _load from
  /// clobbering a mutation that landed before prefs resolved (worker-tasks H2).
  bool _loaded = false;

  /// F-35 · thread ids mutated since construction. Lets a LATE [_load] merge
  /// the disk overlay AROUND a pre-load mutation instead of dropping it: the
  /// in-memory thread wins only where a mutation actually landed; every other
  /// thread still hydrates from disk — so an early send() no longer erases the
  /// persisted messages of all the other threads on the next write.
  final Set<String> _dirtyThreadIds = {};

  /// F-35 · completes when [_load] settled (overlay read+merged, or failed
  /// honestly). [_persist] gates on it so a write can never precede the
  /// initial disk read.
  final Completer<void> _loadSettled = Completer<void>();

  /// S4.1/S4.2 — the bound Firestore-backed store, or null on the local path
  /// (no Firebase → the engine itself stays the store, behavior unchanged).
  ChatRepository? _remote;

  /// Bind the engine to the live Firestore-backed chat repository (called by
  /// [chatEngineProvider] only when Firebase is initialised). The real-time
  /// loop both ways:
  ///   • DOWN — every cache change (snapshot or optimistic) `notifyListeners`s
  ///     → [_refreshFromRemote] rebuilds the engine state from the SYNC
  ///     [ChatRepository.threads] (a new message appears live, S4.2);
  ///   • UP — [send]/[resetToSeed] delegate to the repo's verbatim ports, whose
  ///     optimistic upserts notify back synchronously, so the engine (and the
  ///     UI) see the change in the same frame.
  /// The immediate refresh aligns engine ⇄ caches from t0; because it runs
  /// through the `state` setter it also flips [_loaded], so the prefs overlay
  /// never clobbers server state — under Firebase, Firestore's own offline
  /// persistence is the continuity source and prefs stays a write-behind copy.
  void bindRemote(ChatRepository remote) {
    if (_remote != null) return; // bind once (provider-lifetime)
    _remote = remote;
    remote.addListener(_refreshFromRemote);
    _refreshFromRemote();
  }

  void _refreshFromRemote() {
    final r = _remote;
    if (r == null) return;
    state = r.threads(); // public setter → _loaded + persist (write-behind)
  }

  @override
  void dispose() {
    _remote?.removeListener(_refreshFromRemote);
    super.dispose();
  }

  /// Re-apply the persisted per-thread message overlay onto the verbatim
  /// [kChatThreads] seed. A thread with no stored entry keeps its seed messages;
  /// a stored thread that no longer exists in the seed is ignored. Mirrors the
  /// worker-tasks overlay-on-seed load.
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // F-36: the container may be disposed before prefs resolve (test
      // teardown / ProviderScope rebuild) — placing state then throws.
      if (!mounted) return;
      final raw = prefs.getString(kSysChatKey);
      if (raw == null || raw.isEmpty) {
        _loaded = true;
        return;
      }
      // State was wholesale-replaced before the load settled by something
      // that is NOT a tracked local mutation (send/resetToSeed register their
      // thread ids in [_dirtyThreadIds]) — i.e. the Firestore mirror
      // ([bindRemote] → [_refreshFromRemote]). Keep it untouched, exactly
      // like the legacy `if (!_loaded)` guard: under Firebase the prefs
      // overlay never clobbers server state.
      if (_loaded && _dirtyThreadIds.isEmpty) return;
      final m = jsonDecode(raw) as Map<String, dynamic>;
      if (!mounted) return; // F-36: re-check before placing state
      // F-35 merge: apply the disk overlay onto the CURRENT state, skipping
      // the threads a pre-load mutation already touched (the in-memory thread
      // wins there). On the normal path nothing raced, [_dirtyThreadIds] is
      // empty and state IS the seed — byte-equivalent to the legacy
      // overlay-on-seed apply.
      super.state = [
        for (final t in state)
          if (m[t.id] is List && !_dirtyThreadIds.contains(t.id))
            t.copyWith(
              messages: [
                for (final e in m[t.id] as List)
                  if (ChatMessage.tryFromJson(e) case final msg?) msg,
              ],
            )
          else
            t,
      ];
      _loaded = true;
    } on Object catch (_) {
      _loaded = true; // corrupt/old payload — keep the seed
    } finally {
      // F-35: unblock [_persist] in EVERY exit path (success/corrupt/unmounted).
      if (!_loadSettled.isCompleted) _loadSettled.complete();
    }
  }

  Future<void> _persist() async {
    if (!persist) return;
    // F-35: never write before [_load] settled — a mutation racing ahead of
    // the load would otherwise serialize seed message-lists over every other
    // thread's persisted messages. By the time this write runs, [_load] has
    // already merged the disk overlay around any pre-load mutation.
    await _loadSettled.future;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        kSysChatKey,
        jsonEncode({
          // F-56: persist only the newest [kSysChatPersistCap] messages per
          // thread — prefs is a bounded budget, not the message archive.
          for (final t in state)
            t.id: [
              for (final msg in t.messages.length > kSysChatPersistCap
                  ? t.messages
                      .sublist(t.messages.length - kSysChatPersistCap)
                  : t.messages)
                msg.toJson(),
            ],
        }),
      );
    } on Object catch (_) {}
  }

  /// Persist on every change (the worker-tasks/orders pattern).
  @override
  set state(List<ChatThread> value) {
    _loaded = true;
    super.state = value;
    _persist();
  }

  String _nowTime() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

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

  /// Append a message from [fromRole] to [threadId] — visible to BOTH
  /// participants immediately because they read the same shared thread (the
  /// cross-persona core). No-op on an empty text or an unknown thread.
  ///
  /// A8 (launch uid-migration) — [fromUid] stamps the sender's `auth.uid` on
  /// the user line when signed-in (the UI passes `currentUidProvider`); '' on
  /// the local/signed-out path keeps today's behavior byte-for-byte. The bot
  /// auto-reply carries no uid (it is the system, not a user).
  ///
  /// For the BOT thread, a deterministic auto-reply is appended right after the
  /// user's line (mirroring the legacy `_ChatPage` bot behavior). Real (non-bot)
  /// threads do NOT auto-reply — the other persona answers live.
  void send(String threadId, BsRole fromRole, String text,
      {String fromUid = ''}) {
    // A14 — populate participantUids for REAL on first touch (gated, async,
    // non-blocking): when `kUidScopedQueries` is ON and the thread's uids are
    // still empty, resolve the union of its roles' real uids and stamp them.
    // OFF (default) ⇒ no-op ⇒ participantUids stays empty ⇒ today's shared
    // threads, zero regression. Kicked BEFORE the optimistic write so a fresh
    // backend never persists a head without its uids; it never blocks the send.
    ensureParticipantUids(threadId);
    // S4.3 — bound to Firestore: delegate to the repo's verbatim port (message
    // write + thread lastMsg/ts upsert + the bot auto-reply). Its optimistic
    // cache notifies back SYNCHRONOUSLY → [_refreshFromRemote] has already
    // mirrored the new state by the time this returns — same-frame UX as the
    // local path, plus the background Firestore writes.
    final r = _remote;
    if (r != null) {
      r.send(threadId, fromRole, text, fromUid: fromUid);
      return;
    }
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final idx = state.indexWhere((t) => t.id == threadId);
    if (idx < 0) return;
    final thread = state[idx];
    final now = DateTime.now();
    final appended = <ChatMessage>[
      ...thread.messages,
      _mk(threadId, fromRole, trimmed, now, fromUid: fromUid),
    ];
    // Bot thread: keep the auto-reply (next reply in rotation, by current count).
    if (thread.isBot && fromRole != BsRole.bot) {
      final replyIdx = thread.messages
          .where((m) => m.fromRole == BsRole.bot)
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
    // F-35: register the mutation so a late [_load] merges around it.
    _dirtyThreadIds.add(threadId);
    state = [
      for (var i = 0; i < state.length; i++)
        if (i == idx) thread.copyWith(messages: appended) else state[i],
    ];
  }

  /// A14 (launch uid-migration) — POPULATE a thread's [ChatThread.participantUids]
  /// for real (the chat last-mile). When [uidScoped] is ON, a [lookup]
  /// exists, and the thread's uids are still EMPTY, this resolves the UNION over
  /// the thread's participant ROLES of [UsersLookup.uidsByRole] (skipping
  /// [BsRole.bot] — the system has no `users` doc), folds in the SENDER's
  /// [currentUid] (so the sender can read the thread they stamped), and UPSERTS
  /// the resolved set onto the thread head. So a `[contractor, store]` thread
  /// ends up carrying EVERY contractor uid + EVERY store uid (multiple users per
  /// role are all included) — exactly what the rules' `uid in participantUids`
  /// needs to isolate the conversation to the involved roles' real users.
  ///
  /// ZERO REGRESSION: the flag OFF (the default + the whole local test suite
  /// unless a test injects a [lookup]) makes this a NO-OP — participantUids stays
  /// empty, threads stay shared, behaviour is byte-identical to today.
  ///
  /// ASYNC, NON-BLOCKING: `uidsByRole` is async but [send] is sync-optimistic, so
  /// this resolves OFF the send path and stamps the head when it settles (an
  /// in-flight guard prevents a duplicate resolve from a rapid second send). The
  /// remote path stamps through the bound repository ([ChatRepository.
  /// setParticipantUids]); the local path stamps the engine state directly.
  /// Returns the resolve future so callers/tests can await settling.
  Future<void> ensureParticipantUids(String threadId) async {
    if (!uidScoped) return; // gated — OFF is today, exactly
    if (_uidResolveInFlight.contains(threadId)) return; // resolve already kicked

    // A14 — SELF-STAMP FIRST (mirrors orders' `contractorUid == auth.uid`
    // always-present guarantee). The sender's own uid is the ONE entry we can
    // always supply; resolve it BEFORE anything that can fail (the directory
    // lookup, a denied users-query) so a participantUids the rules can satisfy
    // is stamped even when peer resolution comes back empty/throws. No identity
    // (signed-out / uid races to null) ⇒ nothing to stamp ⇒ bail.
    final me = currentUid?.call();
    if (me == null || me.isEmpty) return;

    // Find the thread (local state mirrors the remote when bound) and skip when
    // it is unknown or already populated (resolve once, then it is the cache).
    final idx = state.indexWhere((t) => t.id == threadId);
    if (idx < 0) return;
    if (state[idx].participantUids.isNotEmpty) return;
    final roles = state[idx].participants;

    _uidResolveInFlight.add(threadId);
    try {
      // The union ALWAYS contains the sender (so they can read the thread they
      // stamped); a LinkedHashSet keeps it de-duplicated and deterministically
      // ordered (self first, then roles in seed order, uids in doc order).
      final union = <String>{me};
      // ⋃ over the thread's participant roles of their real uids (bot skipped —
      // it has no users doc). BEST-EFFORT: a null directory (Firebase-free) or a
      // failing/denied users-query must NOT prevent the self-stamp above, so the
      // peer resolution is wrapped — on any failure we fall through with just
      // {me} (the rule-satisfying minimum) instead of bailing empty.
      final lk = lookup;
      if (lk != null) {
        try {
          for (final role in roles) {
            if (role == BsRole.bot) continue;
            union.addAll(await lk.uidsByRole(role.name));
          }
        } on Object catch (_) {
          // Peer resolution failed (denied/offline) — keep {me}; a later send
          // retries the full union. The self-stamp still unlocks the thread.
        }
      }

      if (!mounted) return; // disposed mid-resolve (test teardown / rebuild)
      // `union` is now always ⊇ {me} (non-empty), so the thread is always
      // stamped with at least the sender — the write the rules can satisfy.
      final uids = List<String>.unmodifiable(union);
      // Bound to Firestore: stamp through the repo so the head doc persists the
      // uids (its toDoc already writes participantUids when non-empty) and the
      // mirror flows the new state back into the engine. Local: stamp directly.
      final r = _remote;
      if (r != null) {
        r.setParticipantUids(threadId, uids);
        return;
      }
      final i = state.indexWhere((t) => t.id == threadId);
      if (i < 0) return;
      state = [
        for (var k = 0; k < state.length; k++)
          if (k == i) state[k].copyWith(participantUids: uids) else state[k],
      ];
    } finally {
      _uidResolveInFlight.remove(threadId);
    }
  }

  /// 🔒 ISOLATION primitive — the threads [role] participates in (SPEC §2.5).
  /// The store never sees a contractor↔manager thread. Order is preserved from
  /// the seed (newest-activity ordering is the UI's job, not the engine's).
  List<ChatThread> threadsFor(BsRole role) =>
      state.where((t) => t.participants.contains(role)).toList();

  /// markRead — no unread-count store yet (the legacy `unread` lived on the
  /// static seed only). Kept as a typed no-op so callers/CH-4 can wire it
  /// without reaching back into the engine shape. Optional per SPEC CH-1.
  void markRead(String threadId, BsRole role) {/* no-op: no unread store yet */}

  /// Reset to the verbatim seed (tests / a future "demo reset"). Bound to
  /// Firestore this resets BOTH remote-backed caches (and re-writes the seed);
  /// their notify mirrors the seed back into the engine state. The local seed
  /// is the FULL one (legacy cross-persona + board-audience threads, #70/#75).
  void resetToSeed() {
    final r = _remote;
    if (r != null) {
      r.resetToSeed();
      return;
    }
    // F-35: a reset is a mutation of EVERY thread — a late [_load] must not
    // re-apply the old disk overlay on top of the fresh seed.
    _dirtyThreadIds.addAll(_seedThreads().map((t) => t.id));
    state = _seedThreads();
  }
}

/// The shared cross-persona chat provider — the single live list every persona's
/// `ChatsScreen` reads (filtered through [ChatEngineNotifier.threadsFor]).
///
/// S4 switch (mirrors `ordersRepositoryProvider`): when Firebase is initialised
/// the seam resolves to the Firestore-backed repo and the engine binds to it —
/// live threads/messages flow in through the caches, `send` flows out. When it
/// is NOT (the entire Firebase-free test suite) the seam resolves to null and
/// the engine stays the purely-local store — byte-identical behavior.
final chatEngineProvider =
    StateNotifierProvider<ChatEngineNotifier, List<ChatThread>>(
  (ref) {
    final engine = ChatEngineNotifier(
      // A14 — the directory (A7) + the live signed-in uid (A2). The engine's
      // `uidScoped` defaults to the compile-time `kUidScopedQueries`, so with
      // the flag OFF (today) `ensureParticipantUids` is a no-op and these are
      // never read ⇒ zero regression. `usersLookupProvider` is itself null
      // without the live backend, so this is doubly inert off the launch path.
      lookup: ref.read(usersLookupProvider),
      currentUid: () => ref.read(currentUidProvider),
    );
    final remote = ref.read(chatRepositoryProvider);
    if (remote != null) engine.bindRemote(remote);
    return engine;
  },
);
