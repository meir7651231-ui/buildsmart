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

import 'dart:convert';

import 'package:buildsmart/data/chat_seeds.dart';
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
  });

  final String id;
  final String threadId;
  final BsRole fromRole;
  final String text;
  final DateTime ts;

  Map<String, dynamic> toJson() => {
        'id': id,
        'threadId': threadId,
        'fromRole': fromRole.name,
        'text': text,
        'ts': ts.toIso8601String(),
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
  });

  final String id;
  final List<BsRole> participants;
  final String name;
  final String avatar;
  final List<ChatMessage> messages;

  /// The chatbot thread keeps its legacy auto-reply (SPEC §6).
  final bool isBot;

  ChatThread copyWith({List<ChatMessage>? messages}) => ChatThread(
        id: id,
        participants: participants,
        name: name,
        avatar: avatar,
        messages: messages ?? this.messages,
        isBot: isBot,
      );
}

// ─── engine ───────────────────────────────────────────────────────────────────

/// SharedPreferences key for the persisted cross-persona chat messages.
const String kSysChatKey = 'bs.sys-chat.v1';

/// Bot auto-replies — lifted verbatim from the legacy `_ChatPage` so the bot
/// thread keeps the exact same behavior (SPEC §6).
const List<String> kBotAutoReplies = [
  'קיבלתי, תודה 👍',
  'בסדר גמור.',
  'אעדכן אותך בהקדם.',
  'מעולה.',
];

class ChatEngineNotifier extends StateNotifier<List<ChatThread>> {
  ChatEngineNotifier({this.persist = true}) : super(kChatThreads) {
    if (persist) _load();
  }

  /// When false (tests), skip SharedPreferences entirely so the in-memory
  /// seed/flow can be asserted in isolation (the worker-tasks pattern).
  final bool persist;

  /// True once a mutation applied or _load completed — guards _load from
  /// clobbering a mutation that landed before prefs resolved (worker-tasks H2).
  bool _loaded = false;

  /// Re-apply the persisted per-thread message overlay onto the verbatim
  /// [kChatThreads] seed. A thread with no stored entry keeps its seed messages;
  /// a stored thread that no longer exists in the seed is ignored. Mirrors the
  /// worker-tasks overlay-on-seed load.
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kSysChatKey);
      if (raw == null || raw.isEmpty) {
        _loaded = true;
        return;
      }
      final m = jsonDecode(raw) as Map<String, dynamic>;
      if (!_loaded) {
        super.state = [
          for (final t in kChatThreads)
            if (m[t.id] is List)
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
      }
    } on Object catch (_) {
      _loaded = true; // corrupt/old payload — keep the seed
    }
  }

  Future<void> _persist() async {
    if (!persist) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        kSysChatKey,
        jsonEncode({
          for (final t in state) t.id: [for (final msg in t.messages) msg.toJson()],
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

  ChatMessage _mk(String threadId, BsRole fromRole, String text, DateTime ts) =>
      ChatMessage(
        id: 'm-${ts.microsecondsSinceEpoch}-${fromRole.name}',
        threadId: threadId,
        fromRole: fromRole,
        text: text,
        ts: ts,
      );

  /// Append a message from [fromRole] to [threadId] — visible to BOTH
  /// participants immediately because they read the same shared thread (the
  /// cross-persona core). No-op on an empty text or an unknown thread.
  ///
  /// For the BOT thread, a deterministic auto-reply is appended right after the
  /// user's line (mirroring the legacy `_ChatPage` bot behavior). Real (non-bot)
  /// threads do NOT auto-reply — the other persona answers live.
  void send(String threadId, BsRole fromRole, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final idx = state.indexWhere((t) => t.id == threadId);
    if (idx < 0) return;
    final thread = state[idx];
    final now = DateTime.now();
    final appended = <ChatMessage>[
      ...thread.messages,
      _mk(threadId, fromRole, trimmed, now),
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
    state = [
      for (var i = 0; i < state.length; i++)
        if (i == idx) thread.copyWith(messages: appended) else state[i],
    ];
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

  /// Reset to the verbatim seed (tests / a future "demo reset").
  void resetToSeed() => state = kChatThreads;
}

/// The shared cross-persona chat provider — the single live list every persona's
/// `ChatsScreen` reads (filtered through [ChatEngineNotifier.threadsFor]).
final chatEngineProvider =
    StateNotifierProvider<ChatEngineNotifier, List<ChatThread>>(
  (ref) => ChatEngineNotifier(),
);
