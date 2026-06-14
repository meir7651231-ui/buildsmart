import 'dart:async';
import 'dart:convert';

import 'package:buildsmart/screens/camera_sheet.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/chat_settings.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/contact_actions.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── enums ────────────────────────────────────────────────────────────────────

enum _Direction { outgoing, incoming, missed }

enum _ThreadCategory { agent, supplier, bot }

enum _ChatFilter { all, agents, suppliers, bot }

// ─── board-audience filter chips (contract §3, board W) ───────────────────────
//
// Non-contractor audiences ('worker' / 'courier') swap the legacy
// נציגים/ספקים chips for a role-specific set. Selection is a plain index into
// the audience's chip list; the contractor keeps the legacy [_ChatFilter] path
// completely untouched.

/// Selected audience-chip index (0 = הכל). Shared state like
/// [_chatFilterProvider]; an out-of-range stale index falls back to 0.
final _audienceChipIndexProvider = StateProvider<int>((_) => 0);

/// One audience chip: a label + which raw [ChatThread]s it matches.
class _AudienceChip {
  const _AudienceChip(this.label, this.matches);

  final String label;
  final bool Function(ChatThread t) matches;
}

/// True for a couriers-only thread (the 'שליחים' group chip): every non-bot
/// participant is a courier (the courier board seeds such threads).
bool _isCouriersOnly(ChatThread t) =>
    !t.isBot &&
    t.participants.isNotEmpty &&
    t.participants.every((r) => r == BsRole.courier);

/// The chip set per audience (contract §3): worker → הכל/קבלן/מנהל/בוט ·
/// courier → הכל/חנות/לקוח/שליחים/בוט. Null = contractor (the legacy chips).
List<_AudienceChip>? _audienceChipsFor(String audience) => switch (audience) {
      'worker' => [
          _AudienceChip('הכל', (_) => true),
          _AudienceChip('👷 קבלן',
              (t) => !t.isBot && t.participants.contains(BsRole.contractor)),
          _AudienceChip('🎧 תמיכה',
              (t) => !t.isBot && t.participants.contains(BsRole.manager)),
          _AudienceChip('🤖 בוט', (t) => t.isBot),
        ],
      'courier' => [
          _AudienceChip('הכל', (_) => true),
          _AudienceChip('🏪 חנות',
              (t) => !t.isBot && t.participants.contains(BsRole.store)),
          _AudienceChip('👷 לקוח',
              (t) => !t.isBot && t.participants.contains(BsRole.contractor)),
          _AudienceChip('🛵 שליחים', _isCouriersOnly),
          _AudienceChip('🤖 בוט', (t) => t.isBot),
        ],
      _ => null,
    };

/// Which threads a [persona] viewing the [audience] list may see (contract §3
/// + the §2.5 isolation): the 'contractor' (default) view is the participant
/// filter over the legacy audience-'contractor' threads PLUS the
/// audience-'worker' threads the viewer takes part in — so a worker→contractor
/// message ('th-worker-contractor') reaches the contractor's שיחות tab, and a
/// worker→manager message ('th-worker-manager') reaches the manager's
/// standalone ChatsScreen (both open this default list). Without the 'worker'
/// clause those threads were WRITE-ONLY: the worker sent into them but the
/// other side never saw them. A board audience (worker/courier) still sees
/// ONLY its own threads plus the shared bot thread — with ONE symmetric
/// bridge (F-25): the store↔courier pair. The courier's attendance report
/// (#86.2) goes to 'th-store-courier-pickups' (audience 'store') and the
/// courier's daily report goes to 'th-courier-lipskey' (audience 'courier');
/// without the bridge each side's send was write-only for the other. The
/// participants check keeps every other audience-crossing thread invisible
/// (verified against the seed: these are the only store+courier threads).
bool _visibleToAudience(ChatThread t, BsRole persona, String audience) {
  if (audience == 'contractor') {
    return t.participants.contains(persona) &&
        (t.audience == 'contractor' || t.audience == 'worker');
  }
  if (t.isBot) return true; // the bot thread is shared across board audiences
  return (t.audience == audience ||
          (audience == 'courier' && t.audience == 'store') ||
          (audience == 'store' && t.audience == 'courier')) &&
      t.participants.contains(persona);
}

// ─── thread view-model (engine → existing UI adapter) ──────────────────────────
//
// The rich row/page UI below was built around the `_Thread` record and a
// per-message `isMe` flag. To REUSE that UI verbatim while swapping the data
// layer to the shared [chatEngineProvider] (SPEC CH-3), we adapt a [ChatThread]
// into the same `_Thread` shape *for the reading persona*: its last message
// becomes the subtitle/time, and `isMe`/direction are derived from
// `fromRole == persona`. Nothing in the presentational widgets changes.

/// The persona-relative view of a [ChatThread] used to drive the legacy
/// `_ThreadRow`/`_ChatPage`. Carries the engine [threadId] + [persona] so the
/// page can render real messages and `send` as the right role.
typedef _ThreadView = ({_Thread thread, String threadId, BsRole persona});

_Direction _directionFor(ChatThread t, BsRole persona) {
  if (t.messages.isEmpty) return _Direction.outgoing;
  return t.messages.last.fromRole == persona
      ? _Direction.outgoing
      : _Direction.incoming;
}

_ThreadCategory _categoryFor(ChatThread t) {
  if (t.isBot) return _ThreadCategory.bot;
  // A supplier (🏪) counterpart → "ספקים"; everyone else (👷/🛵/👔) → "נציגים".
  return t.participants.contains(BsRole.store)
      ? _ThreadCategory.supplier
      : _ThreadCategory.agent;
}

String _hhmm(DateTime ts) =>
    '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';

/// Real per-chat unread: incoming messages (not from the reading persona)
/// whose timestamp is newer than the thread's persisted lastReadAt
/// (0 = never opened → all incoming messages count).
int _unreadCount(ChatThread t, BsRole persona, int lastReadMs) => t.messages
    .where(
      (m) =>
          m.fromRole != persona &&
          m.ts.millisecondsSinceEpoch > lastReadMs,
    )
    .length;

/// Per-viewer thread title. The worker-board threads are named from the
/// WORKER's point of view ('קבלן' / 'מנהל' — `kWorkerChatThreads`,
/// sys_chat.dart); when the OTHER side (contractor/manager) views such a
/// thread through its default list, show the worker counterpart instead —
/// 'עובד — רן' (רן is kWorkers[0], the seeded demo worker; persona_data.dart)
/// — so the contractor's row isn't labeled with his own role.
String _displayNameFor(ChatThread t, BsRole persona) =>
    t.audience == 'worker' && !t.isBot && persona != BsRole.worker
        ? 'עובד — רן'
        : t.name;

/// Build the legacy `_Thread` record + the engine handle for [persona].
_ThreadView _viewOf(ChatThread t, BsRole persona, Map<String, int> lastRead) {
  final last = t.messages.isNotEmpty ? t.messages.last : null;
  return (
    threadId: t.id,
    persona: persona,
    thread: (
      id: t.id,
      avatar: t.avatar,
      name: _displayNameFor(t, persona),
      subtitle: last?.text ?? '',
      time: last != null ? _hhmm(last.ts) : '',
      direction: _directionFor(t, persona),
      isBot: t.isBot,
      unread: _unreadCount(t, persona, lastRead[t.id] ?? 0),
      isOnline: t.isBot,
      category: _categoryFor(t),
    ),
  );
}

// ─── providers ────────────────────────────────────────────────────────────────

/// "זמן מקוון אחרון" privacy: online presence is shown unless set to nobody.
bool showOnlinePresence(ChatLastSeen p) => p != ChatLastSeen.nobody;

final _chatSearchQueryProvider = StateProvider<String>((_) => '');
final _chatFilterProvider =
    StateProvider<_ChatFilter>((_) => _ChatFilter.all);

// ─── per-username chat-UX state (F-37) ────────────────────────────────────────
//
// Archive/mute/lastRead/history-cleared are USER state, not device state:
// switching accounts (ran→omer, demo→dudi) must not inherit the previous
// user's archive/mutes/unread. Each value therefore lives in a per-username
// bucket nested inside the SAME versioned key (no new v2 keys — the legacy
// flat payload migrates into the 'contractor' bucket on first read), and
// every write is a read-modify-write of ONLY the current bucket, so logout
// never touches another username's data.

/// F-37 · the bucket owner for the per-username chat-UX prefs: the logged-in
/// board session's username, or 'contractor' when there is no board session —
/// the contractor board has no board login, and its bucket is also the
/// migration target for the legacy flat payloads. Watched, so an account
/// switch rebuilds the notifiers onto the new user's bucket.
String _chatBucketUser(Ref ref) =>
    ref.watch(boardAuthProvider.select((s) => s?.username ?? 'contractor'));

/// F-37 · read a `{username: [threadIds]}` buckets map stored as a JSON
/// string under [key]. Handles BOTH payload generations honestly: the current
/// JSON-string form, and the legacy flat StringList (the pre-per-username
/// set), which migrates as the 'contractor' bucket. `getString` on a key
/// holding a StringList throws a type error — caught, then `getStringList`
/// is tried (the ADJUSTed F-37 migration; same key, no v2).
Map<String, List<String>> _readIdBuckets(SharedPreferences prefs, String key) {
  String? raw;
  try {
    raw = prefs.getString(key);
  } on Object catch (_) {
    raw = null; // legacy StringList payload — fall through to getStringList
  }
  if (raw != null) {
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final e in m.entries)
          if (e.value is List)
            e.key: [
              for (final v in e.value as List)
                if (v is String) v,
            ],
      };
    } on Object catch (_) {
      return {}; // corrupt payload — start empty, honestly
    }
  }
  try {
    final legacy = prefs.getStringList(key);
    if (legacy != null) return {'contractor': legacy};
  } on Object catch (_) {/* corrupt — start empty */}
  return {};
}

const String _kArchiveKey = 'bs.chat-archived.v1';

class _ChatArchivedNotifier extends StateNotifier<Set<String>> {
  _ChatArchivedNotifier(this.username) : super(const {}) {
    unawaited(_load());
  }

  /// The bucket owner (F-37) — see [_chatBucketUser].
  final String username;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final mine = _readIdBuckets(prefs, _kArchiveKey)[username];
      if (mine != null) state = mine.toSet();
    } on Object catch (_) {/* keep empty */}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Read-modify-write: only THIS username's bucket changes — every other
      // account's archive survives untouched.
      final buckets = _readIdBuckets(prefs, _kArchiveKey);
      buckets[username] = state.toList();
      await prefs.setString(_kArchiveKey, jsonEncode(buckets));
    } on Object catch (_) {/* best-effort */}
  }

  void archive(String id) {
    state = {...state, id};
    unawaited(_persist());
  }

  void restore(String id) {
    state = {...state}..remove(id);
    unawaited(_persist());
  }
}

final chatArchivedIdsProvider =
    StateNotifierProvider<_ChatArchivedNotifier, Set<String>>(
  (ref) => _ChatArchivedNotifier(_chatBucketUser(ref)),
);

const String _kMuteKey = 'bs.chat-muted.v1';

class _ChatMutedNotifier extends StateNotifier<Set<String>> {
  _ChatMutedNotifier(this.username) : super(const {}) {
    unawaited(_load());
  }

  /// The bucket owner (F-37) — see [_chatBucketUser].
  final String username;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final mine = _readIdBuckets(prefs, _kMuteKey)[username];
      if (mine != null) state = mine.toSet();
    } on Object catch (_) {/* keep empty */}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Read-modify-write: only THIS username's bucket changes.
      final buckets = _readIdBuckets(prefs, _kMuteKey);
      buckets[username] = state.toList();
      await prefs.setString(_kMuteKey, jsonEncode(buckets));
    } on Object catch (_) {/* best-effort */}
  }

  void setAll(Set<String> ids) {
    state = ids;
    unawaited(_persist());
  }
}

final chatMutedIdsProvider =
    StateNotifierProvider<_ChatMutedNotifier, Set<String>>(
  (ref) => _ChatMutedNotifier(_chatBucketUser(ref)),
);

const String _kLastReadKey = 'bs.chat-lastread.v1';

/// F-37 · read the `{username: {threadId: lastReadMs}}` buckets under
/// [_kLastReadKey]. The legacy payload was the flat `{threadId: ms}` map —
/// distinguishable because its values are numbers, not maps — and migrates
/// as the 'contractor' bucket (same key, no v2).
Map<String, Map<String, int>> _readLastReadBuckets(SharedPreferences prefs) {
  final raw = prefs.getString(_kLastReadKey);
  if (raw == null) return {};
  try {
    final m = jsonDecode(raw) as Map<String, dynamic>;
    if (m.values.every((v) => v is Map)) {
      // Nested (current) form.
      return {
        for (final e in m.entries)
          e.key: {
            for (final t in (e.value as Map).entries)
              if (t.value is num) '${t.key}': (t.value as num).toInt(),
          },
      };
    }
    // Legacy flat {threadId: ms} → the contractor bucket.
    return {
      'contractor': {
        for (final e in m.entries)
          if (e.value is num) e.key: (e.value as num).toInt(),
      },
    };
  } on Object catch (_) {
    return {}; // corrupt payload — start empty, honestly
  }
}

/// Per-thread "last read" timestamps (ms since epoch), persisted so the real
/// unread badge survives restarts. A chat page marks its thread read on open;
/// a message counts as unread when it wasn't sent by the reading persona and
/// its ts is newer than the thread's lastReadAt (0 = never opened).
/// Per-username (F-37): the shared bot thread no longer leaks lastRead
/// between personas.
class _ChatLastReadNotifier extends StateNotifier<Map<String, int>> {
  _ChatLastReadNotifier(this.username) : super(const {}) {
    unawaited(_load());
  }

  /// The bucket owner (F-37) — see [_chatBucketUser].
  final String username;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final mine = _readLastReadBuckets(prefs)[username];
      if (mine != null) state = mine;
    } on Object catch (_) {/* keep empty */}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Read-modify-write: only THIS username's bucket changes.
      final buckets = _readLastReadBuckets(prefs);
      buckets[username] = state;
      await prefs.setString(_kLastReadKey, jsonEncode(buckets));
    } on Object catch (_) {/* best-effort */}
  }

  /// Marks [threadId] read as of [at] (defaults to now).
  void markRead(String threadId, {DateTime? at}) {
    state = {
      ...state,
      threadId: (at ?? DateTime.now()).millisecondsSinceEpoch,
    };
    unawaited(_persist());
  }
}

final chatLastReadProvider =
    StateNotifierProvider<_ChatLastReadNotifier, Map<String, int>>(
  (ref) => _ChatLastReadNotifier(_chatBucketUser(ref)),
);

const String _kHistoryClearedKey = 'bs.chat-history-cleared.v1';

/// F-37 · read the `{username: cleared}` buckets under [_kHistoryClearedKey].
/// The legacy payload was a plain bool — `getString` throws on it (caught),
/// then `getBool` reads it and it migrates as the 'contractor' bucket
/// (same key, no v2).
Map<String, bool> _readClearedBuckets(SharedPreferences prefs) {
  String? raw;
  try {
    raw = prefs.getString(_kHistoryClearedKey);
  } on Object catch (_) {
    raw = null; // legacy bool payload — fall through to getBool
  }
  if (raw != null) {
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final e in m.entries)
          if (e.value is bool) e.key: e.value as bool,
      };
    } on Object catch (_) {
      return {}; // corrupt payload — start empty, honestly
    }
  }
  try {
    final legacy = prefs.getBool(_kHistoryClearedKey);
    if (legacy != null) return {'contractor': legacy};
  } on Object catch (_) {/* corrupt — start empty */}
  return {};
}

/// Honest "מחיקת היסטוריה": chat history is ephemeral per-session widget state
/// (there is no persisted message store). This flag — once set — makes new chat
/// pages open empty instead of seeding the thread greeting/last message, and it
/// survives restarts. It is the lightest truthful wiring short of a full store.
/// Per-username (F-37): clearing the history on one account does not blank
/// another account's chats.
class _ChatHistoryClearedNotifier extends StateNotifier<bool> {
  _ChatHistoryClearedNotifier(this.username) : super(false) {
    unawaited(_load());
  }

  /// The bucket owner (F-37) — see [_chatBucketUser].
  final String username;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      state = _readClearedBuckets(prefs)[username] ?? false;
    } on Object catch (_) {/* keep false */}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // F-37: "נקה היסטוריה" writes ONLY the current username's bucket —
      // every other account's flag survives untouched.
      final buckets = _readClearedBuckets(prefs);
      buckets[username] = state;
      await prefs.setString(_kHistoryClearedKey, jsonEncode(buckets));
    } on Object catch (_) {/* best-effort */}
  }

  void clearAll() {
    state = true;
    unawaited(_persist());
  }
}

final chatHistoryClearedProvider =
    StateNotifierProvider<_ChatHistoryClearedNotifier, bool>(
  (ref) => _ChatHistoryClearedNotifier(_chatBucketUser(ref)),
);

/// All thread ids — used by "השתק הכל". Reads the live shared engine (every
/// persona's threads) rather than the retired static seed.
Set<String> _allThreadIds(WidgetRef ref) =>
    {for (final t in ref.read(chatEngineProvider)) t.id};

/// True when every conversation is muted.
bool allChatsMuted(WidgetRef ref) {
  final muted = ref.read(chatMutedIdsProvider);
  return _allThreadIds(ref).every(muted.contains);
}

/// "השתק הכל" toggle: mute all when not all muted, otherwise unmute all.
void toggleMuteAllChats(WidgetRef ref) {
  final notifier = ref.read(chatMutedIdsProvider.notifier);
  notifier.setAll(allChatsMuted(ref) ? <String>{} : _allThreadIds(ref));
}

// ─── data ─────────────────────────────────────────────────────────────────────

typedef _Thread = ({
  String id,
  String avatar,
  String name,
  String subtitle,
  String time,
  _Direction direction,
  bool isBot,
  int unread,
  bool isOnline,
  _ThreadCategory category,
});

typedef _Message = ({String text, bool isMe, String time});

// ─── screen ──────────────────────────────────────────────────────────────────

/// The cross-persona chat screen (SPEC `SPEC-cross-persona-chat.md` CH-3). One
/// widget, parameterized by [persona]: the thread list reads the SHARED
/// [chatEngineProvider] filtered through `threadsFor(persona)`, and a message is
/// "mine" when `fromRole == persona`.
///
/// 🔒 ISOLATION (SPEC §2.5): the contractor is embedded as a tab inside
/// `home_shell`, so for it this is a bare body (no extra Scaffold). Every OTHER
/// persona opens this as a STANDALONE screen pushed from its own dashboard, so
/// it wraps itself in its own Scaffold + AppBar ("שיחות") whose back button only
/// `Navigator.pop`s to the caller — NO home_shell, NO role_picker, NO contractor
/// tabs, and no path anywhere into another persona's board.
class ChatsScreen extends ConsumerStatefulWidget {
  const ChatsScreen({
    super.key,
    this.persona = BsRole.contractor,
    this.audience = 'contractor',
    this.embedded = false,
  });

  /// The persona viewing the screen. Defaults to [BsRole.contractor] so existing
  /// `const ChatsScreen()` callers (the contractor home-shell tab) are unchanged.
  final BsRole persona;

  /// Which board's thread list to show (contract §3): 'contractor' (default —
  /// the legacy list, UNCHANGED) · 'worker' · 'courier'. A board audience shows
  /// ONLY its own threads (+ the shared bot thread) and swaps the filter chips
  /// for its role-specific set ([_audienceChipsFor]).
  final String audience;

  /// True when a role BOARD embeds this as a tab inside its own shell — the
  /// bare body is returned over a white surface (no own Scaffold/AppBar),
  /// like the contractor home-shell tab.
  final bool embedded;

  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> {
  bool _headerVisible = true;

  /// Inside the contractor home_shell tab — the only context that owns the
  /// shrinking-tab-header coordination ([tabHeaderHiddenProvider]).
  bool get _inHomeShell => widget.persona == BsRole.contractor;

  /// Wrap in our own Scaffold + "שיחות" AppBar only when pushed standalone —
  /// an [ChatsScreen.embedded] board tab gets the bare body instead.
  bool get _standalone => !_inHomeShell && !widget.embedded;

  void _setHeaderVisible(bool v) {
    if (_headerVisible == v) return;
    setState(() => _headerVisible = v);
    // The shrinking-tab-header coordination only exists inside home_shell (the
    // contractor tab); other personas — standalone or board-embedded — have no
    // such header to hide.
    if (_inHomeShell) {
      ref.read(tabHeaderHiddenProvider.notifier).state = !v;
    }
  }

  bool _handleScroll(ScrollNotification n) {
    if (n is ScrollUpdateNotification && n.depth == 0) {
      final delta = n.scrollDelta ?? 0;
      final px = n.metrics.pixels;
      if (delta > 6 && _headerVisible && px > 50) {
        _setHeaderVisible(false);
      } else if (delta < -6 && !_headerVisible) {
        _setHeaderVisible(true);
      } else if (px <= 2 && !_headerVisible) {
        _setHeaderVisible(true);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_inHomeShell) {
      ref.listen<bool>(tabHeaderHiddenProvider, (_, hidden) {
        if (!hidden && !_headerVisible) _setHeaderVisible(true);
      });
    }
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _headerVisible
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _SearchBar(),
                      _FilterChipsRow(audience: widget.audience),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScroll,
            child: _ThreadList(
              persona: widget.persona,
              audience: widget.audience,
            ),
          ),
        ),
      ],
    );

    // 🔒 Contractor: embedded tab — return the bare body (home_shell owns the
    // Scaffold/AppBar). A board-[ChatsScreen.embedded] tab gets the same bare
    // body over its own white surface. Every other persona: standalone Scaffold
    // with its own "שיחות" AppBar + a back button that only pops to its
    // dashboard.
    if (!_standalone) {
      return _inHomeShell
          ? body
          : ColoredBox(color: Colors.white, child: body);
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'חזרה',
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'שיחות',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(child: body),
    );
  }
}

// ─── search bar ──────────────────────────────────────────────────────────────

class _SearchBar extends ConsumerStatefulWidget {
  const _SearchBar();

  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText =
        ref.watch(_chatSearchQueryProvider.select((q) => q.isNotEmpty));
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: _controller,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        onChanged: (v) =>
            ref.read(_chatSearchQueryProvider.notifier).state = v,
        decoration: InputDecoration(
          hintText: 'חיפוש שיחות...',
          hintStyle: const TextStyle(color: Color(0xFF888888)),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF888888),
            size: 20,
          ),
          suffixIcon: hasText
              ? IconButton(
                  tooltip: 'נקה חיפוש',
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF888888),
                    size: 18,
                  ),
                  onPressed: () {
                    _controller.clear();
                    ref.read(_chatSearchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: BsTokens.brand, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ─── filter chips ─────────────────────────────────────────────────────────────

class _FilterChipsRow extends ConsumerWidget {
  const _FilterChipsRow({this.audience = 'contractor'});

  /// Which board's chip set to show (contract §3) — 'contractor' keeps the
  /// legacy נציגים/ספקים chips untouched.
  final String audience;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Board audiences (worker/courier) get their own chip set; selection is a
    // plain index into [_audienceChipsFor].
    final audienceChips = _audienceChipsFor(audience);
    if (audienceChips != null) {
      final raw = ref.watch(_audienceChipIndexProvider);
      final selected = raw < audienceChips.length ? raw : 0;
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < audienceChips.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _Pill(
                  label: audienceChips[i].label,
                  active: selected == i,
                  onTap: () => ref
                      .read(_audienceChipIndexProvider.notifier)
                      .state = i,
                ),
              ],
            ],
          ),
        ),
      );
    }

    final filter = ref.watch(_chatFilterProvider);

    void select(_ChatFilter f) =>
        ref.read(_chatFilterProvider.notifier).state = f;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _Pill(
              label: 'הכל',
              active: filter == _ChatFilter.all,
              onTap: () => select(_ChatFilter.all),
            ),
            const SizedBox(width: 8),
            _Pill(
              label: '👤 נציגים',
              active: filter == _ChatFilter.agents,
              onTap: () => select(_ChatFilter.agents),
            ),
            const SizedBox(width: 8),
            _Pill(
              label: '🏪 ספקים',
              active: filter == _ChatFilter.suppliers,
              onTap: () => select(_ChatFilter.suppliers),
            ),
            const SizedBox(width: 8),
            _Pill(
              label: '🤖 בוט',
              active: filter == _ChatFilter.bot,
              onTap: () => select(_ChatFilter.bot),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? BsTokens.brand : const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: active ? bsOnAccent(context) : const Color(0xFFAAAAAA),
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── thread list ──────────────────────────────────────────────────────────────

class _ThreadList extends ConsumerWidget {
  const _ThreadList({required this.persona, this.audience = 'contractor'});

  final BsRole persona;

  /// Which board's thread list to build (contract §3) — see
  /// [_visibleToAudience].
  final String audience;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(_chatSearchQueryProvider);
    final filter = ref.watch(_chatFilterProvider);
    final archivedIds = ref.watch(chatArchivedIdsProvider);
    // 🔒 ISOLATION: only the threads this persona takes part in (SPEC §2.5) —
    // the shared engine, filtered by participation. Adapted to the legacy
    // `_Thread` view-model so the rich rows below render unchanged.
    final lastRead = ref.watch(chatLastReadProvider);
    // Board audiences also apply their own chip filter here — over the raw
    // [ChatThread] — before adapting to the legacy `_Thread` view-model.
    final audienceChips = _audienceChipsFor(audience);
    final chipRaw = ref.watch(_audienceChipIndexProvider);
    final audienceChip = audienceChips == null
        ? null
        : audienceChips[chipRaw < audienceChips.length ? chipRaw : 0];
    final views = [
      for (final t in ref.watch(chatEngineProvider).where(
            (t) =>
                _visibleToAudience(t, persona, audience) &&
                (audienceChip == null || audienceChip.matches(t)),
          ))
        _viewOf(t, persona, lastRead),
    ];

    final threads = views.where((v) {
      final t = v.thread;
      if (archivedIds.contains(t.id)) {
        return false;
      }
      // The legacy נציגים/ספקים chips apply only to the contractor audience —
      // board audiences are filtered by their own _AudienceChip set above.
      if (audience == 'contractor') {
        if (filter == _ChatFilter.agents &&
            t.category != _ThreadCategory.agent) {
          return false;
        }
        if (filter == _ChatFilter.suppliers &&
            t.category != _ThreadCategory.supplier) {
          return false;
        }
        if (filter == _ChatFilter.bot && t.category != _ThreadCategory.bot) {
          return false;
        }
      }
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        if (!t.name.toLowerCase().contains(q) &&
            !t.subtitle.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    if (threads.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('💬', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text(
              'אין שיחות',
              style: TextStyle(
                color: BsTokens.inkLight,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'כשיהיו שיחות — הן יופיעו כאן',
              style: TextStyle(color: Color(0xFF888888), fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: threads.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 76, color: Color(0xFFF5F5F5)),
      itemBuilder: (context, i) => _DismissibleThread(view: threads[i]),
    );
  }
}

// ─── dismissible wrapper ──────────────────────────────────────────────────────

class _DismissibleThread extends ConsumerWidget {
  const _DismissibleThread({required this.view});

  final _ThreadView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thread = view.thread;
    return Dismissible(
      key: ValueKey(thread.id),
      direction: DismissDirection.endToStart,
      background: const ColoredBox(
        color: Color(0xFFF5F5F5),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(
              Icons.archive_outlined,
              color: Colors.black54,
              size: 26,
            ),
          ),
        ),
      ),
      onDismissed: (_) {
        final id = thread.id;
        final notifier = ref.read(chatArchivedIdsProvider.notifier);
        notifier.archive(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('שיחה הועברה לארכיון'),
            backgroundColor: const Color(0xFFF5F5F5),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'ביטול',
              textColor: BsTokens.brand,
              onPressed: () => notifier.restore(id),
            ),
          ),
        );
      },
      child: _ThreadRow(view: view),
    );
  }
}

// ─── thread row ───────────────────────────────────────────────────────────────

class _ThreadRow extends ConsumerWidget {
  const _ThreadRow({required this.view});

  final _ThreadView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thread = view.thread;
    final missed = thread.direction == _Direction.missed;
    final isUnread = thread.unread > 0;
    final muted = ref.watch(
        chatMutedIdsProvider.select((ids) => ids.contains(thread.id)));
    final showOnline = thread.isOnline &&
        showOnlinePresence(
            ref.watch(chatSettingsProvider.select((s) => s.lastSeenPrivacy)));
    final nameColor = missed ? BsTokens.brand : BsTokens.inkLight;
    final arrowIcon = thread.direction == _Direction.outgoing
        ? Icons.north_east_rounded
        : Icons.south_west_rounded;
    final arrowColor = missed ? BsTokens.brand : const Color(0xFF4CAF50);

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _ChatPage(
            view: (
              thread: thread,
              threadId: view.threadId,
              persona: view.persona,
            ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Avatar with online dot
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: thread.isBot
                        ? BsTokens.brand.withValues(alpha: 0.15)
                        : const Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                    border: missed
                        ? Border.all(color: BsTokens.brand, width: 1.5)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    thread.avatar,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                if (showOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Text area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          thread.name,
                          style: TextStyle(
                            color: nameColor,
                            fontSize: 16,
                            fontWeight:
                                isUnread ? FontWeight.w800 : FontWeight.w700,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (muted) ...[
                            const Icon(Icons.notifications_off,
                                color: Color(0xFF999999), size: 14),
                            const SizedBox(width: 4),
                          ],
                          Icon(arrowIcon, color: arrowColor, size: 13),
                          const SizedBox(width: 3),
                          Text(
                            thread.time,
                            style: TextStyle(
                              color: isUnread
                                  ? BsTokens.brand
                                  : const Color(0xFF888888),
                              fontSize: 12,
                              fontWeight: isUnread
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          thread.subtitle,
                          style: TextStyle(
                            color: isUnread
                                ? const Color(0xFF444444)
                                : const Color(0xFF888888),
                            fontSize: 12,
                            fontWeight: isUnread
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: muted
                                ? const Color(0xFFBDBDBD)
                                : BsTokens.brand,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${thread.unread}',
                            style: TextStyle(
                              color: bsOnAccent(context),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── chat page ────────────────────────────────────────────────────────────────

/// Opens a fresh, empty conversation with a new contact (from "שיחה חדשה").
/// This is a DETACHED chat (no engine thread / no [_ThreadView.threadId]) so it
/// keeps the legacy session-local message list + bot auto-reply — exactly as
/// before. Real seeded threads go through the shared engine instead.
void openNewChatWith(
  BuildContext context, {
  required String emoji,
  required String name,
}) {
  final now = DateTime.now();
  final thread = (
    id: 'new-${now.microsecondsSinceEpoch}',
    avatar: emoji,
    name: name,
    subtitle: '',
    time:
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
    direction: _Direction.outgoing,
    isBot: false,
    unread: 0,
    isOnline: true,
    category: _ThreadCategory.agent,
  );
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      // No threadId → detached/local (legacy "שיחה חדשה" behavior).
      builder: (_) => _ChatPage(
        view: (thread: thread, threadId: null, persona: BsRole.contractor),
      ),
    ),
  );
}

/// The chat page handle: the display [_Thread] plus — for an engine-backed
/// thread — its [threadId] and the reading [persona]. A null [threadId] marks a
/// detached chat (legacy local list + auto-reply).
typedef _ChatPageView = ({_Thread thread, String? threadId, BsRole persona});

class _ChatPage extends ConsumerStatefulWidget {
  const _ChatPage({required this.view});

  final _ChatPageView view;

  @override
  ConsumerState<_ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<_ChatPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  /// Session-local fallback messages — ONLY used for a detached chat
  /// (`threadId == null`). Engine-backed threads read from [chatEngineProvider].
  final List<_Message> _localMessages = [];
  bool _isTyping = false;

  static const _autoReplies = [
    'קיבלתי, תודה 👍',
    'בסדר גמור.',
    'אעדכן אותך בהקדם.',
    'מעולה.',
  ];
  int _replyIdx = 0;

  _Thread get _thread => widget.view.thread;
  String? get _threadId => widget.view.threadId;
  BsRole get _persona => widget.view.persona;
  bool get _engineBacked => _threadId != null;

  @override
  void initState() {
    super.initState();
    // Opening the chat marks it read (persisted lastReadAt → drives the real
    // unread badge). Deferred a microtask so the provider mutation doesn't
    // land mid-build during the route push.
    final tid = _threadId;
    if (tid != null) {
      Future.microtask(() {
        if (mounted) {
          ref.read(chatLastReadProvider.notifier).markRead(tid);
        }
      });
    }
    // Engine-backed threads source their messages from the shared store, not the
    // local list (see [_engineMessages] in build) — nothing to seed here.
    if (_engineBacked) return;
    // ── Detached chat (legacy) ──
    // Once history was cleared, every chat opens empty for the session (the flag
    // is persisted, so it holds across restarts) — no greeting, no seed.
    if (ref.read(chatHistoryClearedProvider)) {
      return;
    }
    // A brand-new chat starts empty; existing threads seed the last message.
    if (_thread.subtitle.isNotEmpty) {
      _localMessages.add((
        text: _thread.subtitle,
        isMe: false,
        time: _thread.time,
      ),);
    } else if (ref.read(chatSettingsProvider).greetingEnabled) {
      // Greeting message for a fresh, empty conversation.
      final chatSettings = ref.read(chatSettingsProvider);
      final greetText = chatSettings.greetingMessage.isNotEmpty
          ? chatSettings.greetingMessage
          : 'שלום! 👋 איך אפשר לעזור?';
      _localMessages.add((
        text: greetText,
        isMe: false,
        time: _nowTime(),
      ),);
    }
  }

  String _nowTime() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// The messages to render: from the shared engine thread for an engine-backed
  /// page (mapped to the legacy `_Message` shape, `isMe = fromRole == persona`),
  /// or the session-local list for a detached chat. Honors "מחיקת היסטוריה".
  List<_Message> _engineMessages() {
    if (ref.watch(chatHistoryClearedProvider)) return const [];
    final threads = ref.watch(chatEngineProvider);
    final match = threads.where((t) => t.id == _threadId);
    if (match.isEmpty) return const [];
    return [
      for (final m in match.first.messages)
        (text: m.text, isMe: m.fromRole == _persona, time: _hhmm(m.ts)),
    ];
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    final settings = ref.read(chatSettingsProvider);
    if (settings.chatVibration) {
      HapticFeedback.lightImpact();
    }

    // ── Engine-backed thread (cross-persona) ──
    // The message lands in the SHARED store and is instantly visible to the other
    // participant. The bot thread's auto-reply is produced by the engine's
    // `send` itself (mirroring the legacy behavior), so we don't append one here.
    if (_engineBacked) {
      final wasBot = _thread.isBot;
      final showTyping =
          wasBot && settings.botEnabled && settings.typingIndicator;
      // A8 (launch uid-migration) — stamp the signed-in sender's auth.uid on
      // the message (additive; '' when signed-out / Firebase-free). fromRole
      // still drives the mine/theirs UI; the eventual uid-scoping activates
      // later via the firestore rules (mirrors A3's checkout contractorUid).
      final fromUid = ref.read(currentUidProvider) ?? '';
      ref
          .read(chatEngineProvider.notifier)
          .send(_threadId!, _persona, text, fromUid: fromUid);
      // The bot reply (if any) lands synchronously at now+1ms and is read
      // on-screen — mark read just past it so the badge stays honest.
      ref.read(chatLastReadProvider.notifier).markRead(
            _threadId!,
            at: DateTime.now().add(const Duration(milliseconds: 5)),
          );
      setState(() {
        _controller.clear();
        _isTyping = showTyping;
      });
      _scrollToBottom();
      if (showTyping) {
        // Brief typing shimmer before revealing the (already-stored) bot reply.
        Future.delayed(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          setState(() => _isTyping = false);
          if (ref.read(chatSettingsProvider).messageAlertEnabled) {
            HapticFeedback.lightImpact();
          }
          _scrollToBottom();
        });
      }
      return;
    }

    // ── Detached chat (legacy local list + bot auto-reply) ──
    final showTyping = settings.botEnabled && settings.typingIndicator;
    setState(() {
      _localMessages.add((text: text, isMe: true, time: _nowTime()));
      _controller.clear();
      _isTyping = showTyping;
    });
    _scrollToBottom();
    // Auto-reply only when the chatbot is enabled.
    if (!settings.botEnabled) {
      return;
    }
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _isTyping = false;
        _localMessages.add((
          text: _autoReplies[_replyIdx % _autoReplies.length],
          isMe: false,
          time: _nowTime(),
        ),);
        _replyIdx++;
      });
      // New-message alert: a haptic when an incoming (bot) message arrives, gated
      // on the user's "new-message alert" setting (was: persisted but never read — W4).
      if (ref.read(chatSettingsProvider).messageAlertEnabled) {
        HapticFeedback.lightImpact();
      }
      _scrollToBottom();
    });
  }

  /// "עוד" overflow menu — real, working chat actions backed by the existing
  /// mute/archive providers (not a placeholder). Block/search-in-chat are
  /// honest stubs (no backing) shown inline.
  Future<void> _showChatMenu(BuildContext context) async {
    final id = _thread.id;
    final muted = ref.read(chatMutedIdsProvider).contains(id);
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(
                  muted ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                  color: Colors.black54,
                ),
                title: Text(muted ? 'בטל השתקה' : 'השתק שיחה'),
                onTap: () => Navigator.pop(sheetCtx, 'mute'),
              ),
              ListTile(
                leading: const Icon(Icons.archive_outlined,
                    color: Colors.black54),
                title: const Text('העבר לארכיון'),
                onTap: () => Navigator.pop(sheetCtx, 'archive'),
              ),
              ListTile(
                leading: const Icon(Icons.search, color: Colors.black54),
                title: const Text('חיפוש בשיחה'),
                // Honest: in-thread search has no backing index in the demo.
                enabled: false,
                onTap: null,
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.black54),
                title: const Text('חסום איש קשר'),
                // Honest: blocking requires a server contact list (not in demo).
                enabled: false,
                onTap: null,
              ),
            ],
          ),
        ),
      ),
    );
    if (!context.mounted || action == null) return;
    if (action == 'mute') {
      final notifier = ref.read(chatMutedIdsProvider.notifier);
      final next = {...ref.read(chatMutedIdsProvider)};
      if (muted) {
        next.remove(id);
      } else {
        next.add(id);
      }
      notifier.setAll(next);
      showToast(context, muted ? 'ההשתקה בוטלה' : 'השיחה הושתקה');
    } else if (action == 'archive') {
      ref.read(chatArchivedIdsProvider.notifier).archive(id);
      showToast(context, 'שיחה הועברה לארכיון');
      Navigator.of(context).pop(); // leave the now-archived chat page
    }
  }

  @override
  Widget build(BuildContext context) {
    final showOnline = _thread.isOnline &&
        showOnlinePresence(
            ref.watch(chatSettingsProvider.select((s) => s.lastSeenPrivacy)));
    // Engine-backed: live messages from the shared store (cross-persona);
    // detached: the session-local list. Both render through the same UI below.
    var messages = _engineBacked ? _engineMessages() : _localMessages;
    // Legacy bot feel: the engine appends the bot's reply synchronously, but we
    // briefly show the "מקליד..." bubble first — so while typing, hide that
    // just-added incoming reply and let the typing bubble stand in for it.
    if (_engineBacked &&
        _isTyping &&
        messages.isNotEmpty &&
        !messages.last.isMe) {
      messages = messages.sublist(0, messages.length - 1);
    }
    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          tooltip: 'חזרה',
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _thread.avatar,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                if (showOnline)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFFFFF),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _thread.name,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (showOnline)
                    const Text(
                      'פעיל כעת',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'אפשרויות',
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onPressed: () => _showChatMenu(context),
          ),
          // 📞/💬 — REAL hand-off to the dialer / WhatsApp (replaces the old
          // dead in-app voice/video buttons). The contact phone is the user's
          // registered number (userProfileProvider.contact — the only phone the
          // app holds; chat threads carry no per-contact number). Hidden when
          // the profile has no phone, so the bar never shows a dead button.
          ContactActions(
            phone: ref.watch(
              userProfileProvider.select((p) => p.contact),
            ),
            iconColor: Colors.black54,
            compact: true,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              itemCount: messages.length + (_isTyping ? 1 : 0) + 2,
              itemBuilder: (context, i) {
                if (i == 0) return const _PrivacyNotice();
                if (i == 1) return const _DateChip(date: 'היום');
                final msgIdx = i - 2;
                if (_isTyping && msgIdx == messages.length) {
                  return const _TypingBubble();
                }
                return _Bubble(msg: messages[msgIdx]);
              },
            ),
          ),
          _InputBar(controller: _controller, onSend: _send),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }
}

// ─── bubbles ──────────────────────────────────────────────────────────────────

/// Bubble side per SPEC §1 כיווניות (`sys_chat.dart`): the reading persona's OWN
/// messages render on the start edge (right in RTL), others on the end (left).
/// **Directional** (start/end) so it can't invert under RTL — guards the fix of
/// 2026-06-08 (was `Alignment.centerLeft/Right`, which don't flip for RTL).
/// Pinned by `test/chat_bubble_side_test.dart`.
AlignmentDirectional chatBubbleAlignment({required bool isMe}) =>
    isMe ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd;

class _Bubble extends ConsumerWidget {
  const _Bubble({required this.msg});

  final _Message msg;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readReceipts = ref.watch(
      chatSettingsProvider.select((s) => s.readReceipts),
    );
    const bubbleMe = Color(0xFFDCF8C6);
    const bubbleOther = Color(0xFFFFFFFF);
    const textColor = BsTokens.chatText;
    const timeColor = Color(0xFF777777);

    return Align(
      alignment: chatBubbleAlignment(isMe: msg.isMe),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 5),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: msg.isMe ? bubbleMe : bubbleOther,
          borderRadius: BorderRadiusDirectional.only(
            topStart: const Radius.circular(16),
            topEnd: const Radius.circular(16),
            bottomStart: msg.isMe
                ? const Radius.circular(4)
                : const Radius.circular(16),
            bottomEnd: msg.isMe
                ? const Radius.circular(16)
                : const Radius.circular(4),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              msg.text,
              textAlign: TextAlign.end,
              style: const TextStyle(color: textColor, fontSize: 14.5),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg.time,
                  style: const TextStyle(color: timeColor, fontSize: 10.5),
                ),
                if (msg.isMe) ...[
                  const SizedBox(width: 3),
                  // Read receipts: blue double-check when on, grey single when off.
                  Icon(
                    readReceipts ? Icons.done_all : Icons.done,
                    size: 13,
                    color: readReceipts
                        ? const Color(0xFF4FC3F7)
                        : const Color(0xFF999999),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: chatBubbleAlignment(isMe: false), // typing = incoming = other
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadiusDirectional.only(
            topStart: Radius.circular(16),
            topEnd: Radius.circular(16),
            bottomStart: Radius.circular(16),
            bottomEnd: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: const Text(
          'מקליד...',
          style: TextStyle(
            color: Color(0xFF888888),
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

// ─── date chip ───────────────────────────────────────────────────────────────

class _DateChip extends StatelessWidget {
  const _DateChip({required this.date});
  final String date;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFD9EDD3),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          date,
          style: const TextStyle(
            color: Color(0xFF4A5040),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── privacy notice ──────────────────────────────────────────────────────────

class _PrivacyNotice extends StatelessWidget {
  const _PrivacyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Text(
              '🔒 ההודעות בשיחה זו מוצפנות מקצה לקצה. רק המשתתפים יכולים לקרוא אותן.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF5C5C3A),
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── input-bar actions ─────────────────────────────────────────────────────────

/// Voice recording has no audio-capture backend in this build. Honest dialog
/// (not a "בבנייה" toast).
void _showVoiceUnavailable(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: const Text('הקלטת קול'),
      content: const Text(
        'הקלטת הודעות קוליות אינה זמינה בגרסת הדמו.',
        textAlign: TextAlign.right,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx),
          child: const Text('הבנתי'),
        ),
      ],
    ),
  );
}

/// Attachment options sheet. Camera is a real flow (opens the camera sheet);
/// document/location have no file-system/location backing in the demo and are
/// shown as honest disabled rows.
void _showAttachSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFFFFFFFF),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetCtx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined,
                  color: BsTokens.brand),
              title: const Text('מצלמה'),
              onTap: () {
                Navigator.pop(sheetCtx);
                openCameraSheet(context);
              },
            ),
            // Backend-blocked attachment kinds (document / location). Hidden for
            // Apple review (kHideUnderConstruction) so no "לא זמין בדמו"
            // placeholder shows; the rows stay in code (reversible).
            if (!kHideUnderConstruction) ...[
              const ListTile(
                leading: Icon(Icons.insert_drive_file_outlined,
                    color: Colors.black38),
                title: Text('מסמך'),
                subtitle: Text('לא זמין בדמו'),
                enabled: false,
              ),
              const ListTile(
                leading:
                    Icon(Icons.location_on_outlined, color: Colors.black38),
                title: Text('מיקום'),
                subtitle: Text('לא זמין בדמו'),
                enabled: false,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

/// Common chat emojis. Tapping inserts the glyph at the caret in [controller]
/// — a real, fully-working client-side flow (no backend needed).
const List<String> _kChatEmojis = [
  '😀', '😁', '😂', '🙂', '😉', '😍', '😘', '😎',
  '🤔', '👍', '👏', '🙏', '💪', '🔥', '✅', '❌',
  '🎉', '❤️', '👀', '🚗', '🚚', '🏗️', '🔧', '📦',
  '📐', '🧱', '🪛', '⏰', '💰', '📋', '⚠️', '😅',
];

void _showEmojiPicker(BuildContext context, TextEditingController controller) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFFFFFFFF),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetCtx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final e in _kChatEmojis)
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      _insertText(controller, e);
                      Navigator.pop(sheetCtx);
                    },
                    child: Center(
                      child: Text(e, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// Inserts [text] at the current caret (or appends), keeping the caret after it.
void _insertText(TextEditingController controller, String text) {
  final value = controller.value;
  final sel = value.selection;
  if (!sel.isValid) {
    controller.text = value.text + text;
    controller.selection =
        TextSelection.collapsed(offset: controller.text.length);
    return;
  }
  final newText = value.text.replaceRange(sel.start, sel.end, text);
  controller.value = value.copyWith(
    text: newText,
    selection: TextSelection.collapsed(offset: sel.start + text.length),
    composing: TextRange.empty,
  );
}

// ─── input bar ────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFECE5DD),
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 10),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Mic / Send FAB
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (ctx, val, __) {
                final hasText = val.text.trim().isNotEmpty;
                return _CircleFab(
                  icon: hasText ? Icons.send : Icons.mic,
                  semanticLabel: hasText ? 'שלח הודעה' : 'הקלטת הודעה קולית',
                  onTap: hasText
                      ? onSend
                      : () => _showVoiceUnavailable(ctx),
                );
              },
            ),
            const SizedBox(width: 6),
            // Text field pill
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Camera + attachment (left side in RTL = trailing)
                    IconButton(
                      tooltip: 'מצלמה',
                      padding: const EdgeInsets.all(10),
                      // ≥48dp tap target (a11y) — glyph unchanged.
                      constraints:
                          const BoxConstraints(minWidth: 48, minHeight: 48),
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        color: Color(0xFF777777),
                        size: 22,
                      ),
                      // Real flow — opens the in-app camera/scanner sheet.
                      onPressed: () => openCameraSheet(context),
                    ),
                    IconButton(
                      tooltip: 'צירוף',
                      padding: const EdgeInsets.all(10),
                      // ≥48dp tap target (a11y) — glyph unchanged.
                      constraints:
                          const BoxConstraints(minWidth: 48, minHeight: 48),
                      icon: const Icon(
                        Icons.attach_file,
                        color: Color(0xFF777777),
                        size: 22,
                      ),
                      onPressed: () => _showAttachSheet(context),
                    ),
                    // Text input
                    Expanded(
                      child: TextField(
                        controller: controller,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        onSubmitted: (_) => onSend(),
                        maxLines: 5,
                        minLines: 1,
                        style: const TextStyle(
                          color: BsTokens.chatText,
                          fontSize: 15,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'הודעה',
                          hintStyle: TextStyle(color: Color(0xFF999999)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    // Emoji (right side in RTL = leading) — real inline picker
                    // that inserts the chosen glyph into the message field.
                    IconButton(
                      tooltip: 'אימוג׳י',
                      padding: const EdgeInsets.all(10),
                      // ≥48dp tap target (a11y) — glyph unchanged.
                      constraints:
                          const BoxConstraints(minWidth: 48, minHeight: 48),
                      icon: const Icon(
                        Icons.emoji_emotions_outlined,
                        color: Color(0xFF777777),
                        size: 22,
                      ),
                      onPressed: () => _showEmojiPicker(context, controller),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleFab extends StatelessWidget {
  const _CircleFab({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    // a11y (#a11y-round3 idiom): the icon-only send/mic FAB is a bare
    // GestureDetector — additively label it for screen-reader + tooltip
    // without changing size/layout.
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Tooltip(
        message: semanticLabel,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: BsTokens.brand,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: bsOnAccent(context), size: 22),
          ),
        ),
      ),
    );
  }
}

// ─── archive screen ────────────────────────────────────────────────────────────

class ChatsArchiveScreen extends ConsumerWidget {
  const ChatsArchiveScreen({super.key, this.persona = BsRole.contractor});

  /// 🔒 The archive is persona-scoped too: only this persona's archived threads
  /// (its `threadsFor`) appear — the store never sees a contractor↔manager thread
  /// in its archive either.
  final BsRole persona;

  static Route<void> route({BsRole persona = BsRole.contractor}) =>
      MaterialPageRoute<void>(
        builder: (_) => ChatsArchiveScreen(persona: persona),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedIds = ref.watch(chatArchivedIdsProvider);
    final lastRead = ref.watch(chatLastReadProvider);
    final archived = [
      for (final t in ref.watch(chatEngineProvider))
        if (t.participants.contains(persona) && archivedIds.contains(t.id))
          _viewOf(t, persona, lastRead),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          tooltip: 'חזרה',
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ארכיון שיחות',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: archived.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.archive_outlined,
                      size: 48, color: Color(0xFFBBBBBB)),
                  SizedBox(height: 12),
                  Text(
                    'אין שיחות בארכיון',
                    style: TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'החלק שיחה שמאלה כדי לארכב אותה',
                    style: TextStyle(color: Color(0xFF888888), fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: archived.length,
              separatorBuilder: (_, __) => const Divider(
                  height: 1, indent: 76, color: Color(0xFFEEEEEE)),
              itemBuilder: (_, i) => _ArchivedRow(view: archived[i]),
            ),
    );
  }
}

class _ArchivedRow extends ConsumerWidget {
  const _ArchivedRow({required this.view});

  final _ThreadView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thread = view.thread;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: thread.isBot
              ? BsTokens.brand.withValues(alpha: 0.15)
              : const Color(0xFFF5F5F5),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(thread.avatar, style: const TextStyle(fontSize: 24)),
      ),
      title: Text(
        thread.name,
        style: const TextStyle(
          color: BsTokens.inkLight,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        thread.subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
      ),
      trailing: IconButton(
        tooltip: 'שחזר מהארכיון',
        icon: const Icon(Icons.unarchive_outlined, color: BsTokens.brand),
        onPressed: () {
          ref.read(chatArchivedIdsProvider.notifier).restore(thread.id);
          showToast(context, 'השיחה שוחזרה');
        },
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _ChatPage(
            view: (
              thread: thread,
              threadId: view.threadId,
              persona: view.persona,
            ),
          ),
        ),
      ),
    );
  }
}
