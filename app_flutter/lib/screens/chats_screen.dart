import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── enums ────────────────────────────────────────────────────────────────────

enum _Direction { outgoing, incoming, missed }

enum _ThreadCategory { agent, supplier, bot }

enum _ChatFilter { all, agents, suppliers, bot }

// ─── providers ────────────────────────────────────────────────────────────────

final _chatSearchQueryProvider = StateProvider<String>((_) => '');
final _chatFilterProvider =
    StateProvider<_ChatFilter>((_) => _ChatFilter.all);
final _chatArchivedIdsProvider = StateProvider<Set<String>>((_) => {});

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

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SearchBar(),
        _FilterChipsRow(),
        Expanded(child: _ThreadList()),
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
          fillColor: const Color(0xFF2A2A2A),
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
      color: active ? BsTokens.brand : const Color(0xFF2A2A2A),
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
    final archivedIds = ref.watch(_chatArchivedIdsProvider);

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
                color: Colors.white,
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
          const Divider(height: 1, indent: 76, color: Color(0xFF2A2A2A)),
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
        color: Color(0xFF2A2A2A),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(
              Icons.archive_outlined,
              color: Colors.white70,
              size: 26,
            ),
          ),
        ),
      ),
      onDismissed: (_) {
        final id = thread.id;
        final notifier = ref.read(_chatArchivedIdsProvider.notifier);
        notifier.state = Set<String>.from(notifier.state)..add(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('שיחה הועברה לארכיון'),
            backgroundColor: const Color(0xFF2A2A2A),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'ביטול',
              textColor: BsTokens.brand,
              onPressed: () =>
                  notifier.state =
                      Set<String>.from(notifier.state)..remove(id),
            ),
          ),
        );
      },
      child: _ThreadRow(thread: thread),
    );
  }
}

// ─── thread row ───────────────────────────────────────────────────────────────

class _ThreadRow extends StatelessWidget {
  const _ThreadRow({required this.thread});

  final _Thread thread;

  @override
  Widget build(BuildContext context) {
    final missed = thread.direction == _Direction.missed;
    final isUnread = thread.unread > 0;
    final nameColor = missed ? BsTokens.brand : Colors.white;
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
                        : const Color(0xFF2A2A2A),
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
                          color: const Color(0xFF111111),
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
                                ? const Color(0xFFCCCCCC)
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
                            color: BsTokens.brand,
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

class _ChatPage extends StatefulWidget {
  const _ChatPage({required this.thread});

  final _Thread thread;

  @override
  State<_ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<_ChatPage> {
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
    _messages.add((
      text: widget.thread.subtitle,
      isMe: false,
      time: widget.thread.time,
    ),);
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
    setState(() {
      _messages.add((text: text, isMe: true, time: _nowTime()));
      _controller.clear();
      _isTyping = true;
    });
    _scrollToBottom();
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
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
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
                    color: Color(0xFF2A2A2A),
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
                          color: const Color(0xFF1A1A1A),
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
                      color: Colors.white,
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
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            onPressed: () => showToast(context, 'עוד — בבנייה'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, i) {
                if (_isTyping && i == _messages.length) {
                  return const _TypingBubble();
                }
                return _Bubble(msg: _messages[i]);
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

class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg});

  final _Message msg;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.fromLTRB(14, 9, 14, 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: msg.isMe ? BsTokens.brand : const Color(0xFF2A2A2A),
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              msg.text,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: msg.isMe ? Colors.white : const Color(0xFFDDDDDD),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              msg.time,
              style: TextStyle(
                color: msg.isMe
                    ? Colors.white.withValues(alpha: 0.6)
                    : const Color(0xFF666666),
                fontSize: 10,
              ),
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
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
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

// ─── input bar ────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.send, color: BsTokens.brand),
            onPressed: onSend,
            tooltip: 'שלח',
          ),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              onSubmitted: (_) => onSend(),
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'כתוב הודעה…',
                hintStyle: const TextStyle(color: Color(0xFF888888)),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
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
                  borderSide: const BorderSide(
                    color: BsTokens.brand,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
