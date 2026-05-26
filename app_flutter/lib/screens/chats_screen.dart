import 'dart:async';

import 'package:buildsmart/state/chat_settings.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── enums ────────────────────────────────────────────────────────────────────

enum _Direction { outgoing, incoming, missed }

enum _ThreadCategory { agent, supplier, bot }

enum _ChatFilter { all, agents, suppliers, bot }

// ─── providers ────────────────────────────────────────────────────────────────

final _chatSearchQueryProvider = StateProvider<String>((_) => '');
final _chatFilterProvider =
    StateProvider<_ChatFilter>((_) => _ChatFilter.all);

const String _kArchiveKey = 'bs.chat-archived.v1';

class _ChatArchivedNotifier extends StateNotifier<Set<String>> {
  _ChatArchivedNotifier() : super(const {}) {
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_kArchiveKey);
      if (list != null) state = list.toSet();
    } on Object catch (_) {/* keep empty */}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kArchiveKey, state.toList());
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
  (_) => _ChatArchivedNotifier(),
);

const String _kMuteKey = 'bs.chat-muted.v1';

class _ChatMutedNotifier extends StateNotifier<Set<String>> {
  _ChatMutedNotifier() : super(const {}) {
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_kMuteKey);
      if (list != null) state = list.toSet();
    } on Object catch (_) {/* keep empty */}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kMuteKey, state.toList());
    } on Object catch (_) {/* best-effort */}
  }

  void setAll(Set<String> ids) {
    state = ids;
    unawaited(_persist());
  }
}

final chatMutedIdsProvider =
    StateNotifierProvider<_ChatMutedNotifier, Set<String>>(
  (_) => _ChatMutedNotifier(),
);

/// All thread ids — used by "השתק הכל".
Set<String> get _allThreadIds => {for (final t in _kThreads) t.id};

/// True when every conversation is muted.
bool allChatsMuted(WidgetRef ref) {
  final muted = ref.read(chatMutedIdsProvider);
  return _allThreadIds.every(muted.contains);
}

/// "השתק הכל" toggle: mute all when not all muted, otherwise unmute all.
void toggleMuteAllChats(WidgetRef ref) {
  final notifier = ref.read(chatMutedIdsProvider.notifier);
  notifier.setAll(allChatsMuted(ref) ? <String>{} : _allThreadIds);
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

const List<_Thread> _kThreads = [
  (
    id: 't1',
    avatar: '👷',
    name: 'הקבלן הראשי',
    subtitle: 'שלום, ההזמנה שלך תצא בעוד כ-20 דקות.',
    time: '08:14',
    direction: _Direction.incoming,
    isBot: false,
    unread: 2,
    isOnline: true,
    category: _ThreadCategory.agent,
  ),
  (
    id: 't2',
    avatar: '🏪',
    name: 'ספק חומרי בנייה',
    subtitle: 'אישור הזמנה #1234 — מוכנה לאיסוף',
    time: '07:50',
    direction: _Direction.outgoing,
    isBot: false,
    unread: 0,
    isOnline: false,
    category: _ThreadCategory.supplier,
  ),
  (
    id: 't3',
    avatar: '🛵',
    name: 'השליח',
    subtitle: 'מתי אפשר לאסוף את BS-1041?',
    time: 'אתמול',
    direction: _Direction.missed,
    isBot: false,
    unread: 1,
    isOnline: true,
    category: _ThreadCategory.agent,
  ),
  (
    id: 't4',
    avatar: '👔',
    name: 'מנהל המערכת',
    subtitle: 'עדכון סטטוס פרויקט A — בדיקה נדרשת',
    time: 'אתמול',
    direction: _Direction.outgoing,
    isBot: false,
    unread: 0,
    isOnline: false,
    category: _ThreadCategory.agent,
  ),
  (
    id: 't5',
    avatar: '🤖',
    name: 'צ׳אטבוט BuildSmart',
    subtitle: 'איך אפשר לעזור לך היום?',
    time: '22.5',
    direction: _Direction.incoming,
    isBot: true,
    unread: 0,
    isOnline: true,
    category: _ThreadCategory.bot,
  ),
  (
    id: 't6',
    avatar: '🏪',
    name: 'ספק צבעים',
    subtitle: 'מחיר עודכן — ₪3.85 לקילו',
    time: '22.5',
    direction: _Direction.missed,
    isBot: false,
    unread: 3,
    isOnline: false,
    category: _ThreadCategory.supplier,
  ),
];

// ─── screen ──────────────────────────────────────────────────────────────────

class ChatsScreen extends ConsumerStatefulWidget {
  const ChatsScreen({super.key});

  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> {
  bool _headerVisible = true;

  void _setHeaderVisible(bool v) {
    if (_headerVisible == v) return;
    setState(() => _headerVisible = v);
    ref.read(tabHeaderHiddenProvider.notifier).state = !v;
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
    ref.listen<bool>(tabHeaderHiddenProvider, (_, hidden) {
      if (!hidden && !_headerVisible) _setHeaderVisible(true);
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _headerVisible
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [_SearchBar(), _FilterChipsRow()],
                  )
                : const SizedBox.shrink(),
          ),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScroll,
            child: const _ThreadList(),
          ),
        ),
      ],
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
    final hasText = ref.watch(_chatSearchQueryProvider).isNotEmpty;
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
  const _FilterChipsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              color: active ? Colors.white : const Color(0xFFAAAAAA),
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
  const _ThreadList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(_chatSearchQueryProvider);
    final filter = ref.watch(_chatFilterProvider);
    final archivedIds = ref.watch(chatArchivedIdsProvider);

    final threads = _kThreads.where((t) {
      if (archivedIds.contains(t.id)) {
        return false;
      }
      if (filter == _ChatFilter.agents && t.category != _ThreadCategory.agent) {
        return false;
      }
      if (filter == _ChatFilter.suppliers &&
          t.category != _ThreadCategory.supplier) {
        return false;
      }
      if (filter == _ChatFilter.bot && t.category != _ThreadCategory.bot) {
        return false;
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
                color: Color(0xFF1A1A1A),
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
      itemBuilder: (context, i) => _DismissibleThread(thread: threads[i]),
    );
  }
}

// ─── dismissible wrapper ──────────────────────────────────────────────────────

class _DismissibleThread extends ConsumerWidget {
  const _DismissibleThread({required this.thread});

  final _Thread thread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      child: _ThreadRow(thread: thread),
    );
  }
}

// ─── thread row ───────────────────────────────────────────────────────────────

class _ThreadRow extends ConsumerWidget {
  const _ThreadRow({required this.thread});

  final _Thread thread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missed = thread.direction == _Direction.missed;
    final isUnread = thread.unread > 0;
    final muted = ref.watch(chatMutedIdsProvider).contains(thread.id);
    final nameColor = missed ? BsTokens.brand : const Color(0xFF1A1A1A);
    final arrowIcon = thread.direction == _Direction.outgoing
        ? Icons.north_east_rounded
        : Icons.south_west_rounded;
    final arrowColor = missed ? BsTokens.brand : const Color(0xFF4CAF50);

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => _ChatPage(thread: thread)),
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
                if (thread.isOnline)
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
                            style: const TextStyle(
                              color: Colors.white,
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
    MaterialPageRoute<void>(builder: (_) => _ChatPage(thread: thread)),
  );
}

class _ChatPage extends ConsumerStatefulWidget {
  const _ChatPage({required this.thread});

  final _Thread thread;

  @override
  ConsumerState<_ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<_ChatPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<_Message> _messages = [];
  bool _isTyping = false;

  static const _autoReplies = [
    'קיבלתי, תודה 👍',
    'בסדר גמור.',
    'אעדכן אותך בהקדם.',
    'מעולה.',
  ];
  int _replyIdx = 0;

  @override
  void initState() {
    super.initState();
    // A brand-new chat starts empty; existing threads seed the last message.
    if (widget.thread.subtitle.isNotEmpty) {
      _messages.add((
        text: widget.thread.subtitle,
        isMe: false,
        time: widget.thread.time,
      ),);
    } else if (ref.read(chatSettingsProvider).greetingEnabled) {
      // Greeting message for a fresh, empty conversation.
      _messages.add((
        text: 'שלום! 👋 איך אפשר לעזור?',
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
    final showTyping = settings.botEnabled && settings.typingIndicator;
    setState(() {
      _messages.add((text: text, isMe: true, time: _nowTime()));
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
        _messages.add((
          text: _autoReplies[_replyIdx % _autoReplies.length],
          isMe: false,
          time: _nowTime(),
        ),);
        _replyIdx++;
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
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
                    widget.thread.avatar,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                if (widget.thread.isOnline)
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
                    widget.thread.name,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (widget.thread.isOnline)
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
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onPressed: () => showToast(context, 'עוד — בבנייה'),
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Colors.black54),
            onPressed: () => showToast(context, 'שיחת וידאו — בבנייה'),
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined, color: Colors.black54),
            onPressed: () => showToast(context, 'שיחה — בבנייה'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              itemCount: _messages.length + (_isTyping ? 1 : 0) + 2,
              itemBuilder: (context, i) {
                if (i == 0) return const _PrivacyNotice();
                if (i == 1) return const _DateChip(date: 'היום');
                final msgIdx = i - 2;
                if (_isTyping && msgIdx == _messages.length) {
                  return const _TypingBubble();
                }
                return _Bubble(msg: _messages[msgIdx]);
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
    const textColor = Color(0xFF111111);
    const timeColor = Color(0xFF777777);

    return Align(
      alignment: msg.isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 5),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: msg.isMe ? bubbleMe : bubbleOther,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: msg.isMe
                ? const Radius.circular(4)
                : const Radius.circular(16),
            bottomRight: msg.isMe
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
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
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

// ─── mini pill ────────────────────────────────────────────────────────────────

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.search, color: Color(0xFF888888), size: 18),
      ),
    );
  }
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
                  onTap: hasText
                      ? onSend
                      : () => showToast(ctx, 'הקלטת קול — בבנייה'),
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
                      padding: const EdgeInsets.all(10),
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        color: Color(0xFF777777),
                        size: 22,
                      ),
                      onPressed: () => showToast(context, 'מצלמה — בבנייה'),
                    ),
                    IconButton(
                      padding: const EdgeInsets.all(10),
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.attach_file,
                        color: Color(0xFF777777),
                        size: 22,
                      ),
                      onPressed: () => showToast(context, 'צרף קובץ — בבנייה'),
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
                          color: Color(0xFF111111),
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
                    // Emoji (right side in RTL = leading)
                    IconButton(
                      padding: const EdgeInsets.all(10),
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.emoji_emotions_outlined,
                        color: Color(0xFF777777),
                        size: 22,
                      ),
                      onPressed: () => showToast(context, 'אמוג׳י — בבנייה'),
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
  const _CircleFab({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: BsTokens.brand,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

// ─── archive screen ────────────────────────────────────────────────────────────

class ChatsArchiveScreen extends ConsumerWidget {
  const ChatsArchiveScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const ChatsArchiveScreen());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedIds = ref.watch(chatArchivedIdsProvider);
    final archived =
        _kThreads.where((t) => archivedIds.contains(t.id)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ארכיון שיחות',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
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
                      color: Color(0xFF1A1A1A),
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
              itemBuilder: (_, i) => _ArchivedRow(thread: archived[i]),
            ),
    );
  }
}

class _ArchivedRow extends ConsumerWidget {
  const _ArchivedRow({required this.thread});

  final _Thread thread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          color: Color(0xFF1A1A1A),
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
        MaterialPageRoute<void>(builder: (_) => _ChatPage(thread: thread)),
      ),
    );
  }
}
