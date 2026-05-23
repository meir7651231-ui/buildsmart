import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';

// ─── data ─────────────────────────────────────────────────────────────────────

enum _Direction { outgoing, incoming, missed }

typedef _Thread = ({
  String avatar,
  String name,
  String subtitle,
  String time,
  _Direction direction,
  bool isBot,
});

const List<_Thread> _kThreads = [
  (
    avatar: '👷',
    name: 'הקבלן הראשי',
    subtitle: 'שלום, ההזמנה שלך תצא בעוד כ-20 דקות.',
    time: '24.5, 08:14',
    direction: _Direction.incoming,
    isBot: false,
  ),
  (
    avatar: '🏪',
    name: 'ספק חומרי בנייה',
    subtitle: 'אישור הזמנה #1234 — מוכנה לאיסוף',
    time: '24.5, 07:50',
    direction: _Direction.outgoing,
    isBot: false,
  ),
  (
    avatar: '🛵',
    name: 'השליח',
    subtitle: 'מתי אפשר לאסוף את BS-1041?',
    time: '23.5, 18:32',
    direction: _Direction.missed,
    isBot: false,
  ),
  (
    avatar: '👔',
    name: 'מנהל המערכת',
    subtitle: 'עדכון סטטוס פרויקט A — בדיקה נדרשת',
    time: '23.5, 14:10',
    direction: _Direction.outgoing,
    isBot: false,
  ),
  (
    avatar: '🤖',
    name: 'צ׳אטבוט BuildSmart',
    subtitle: 'איך אפשר לעזור לך היום?',
    time: '22.5, 11:47',
    direction: _Direction.incoming,
    isBot: true,
  ),
  (
    avatar: '🏪',
    name: 'ספק צבעים',
    subtitle: 'מחיר עודכן — ₪3.85 לקילו',
    time: '22.5, 09:03',
    direction: _Direction.missed,
    isBot: false,
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
        _SectionLabel(),
        Expanded(child: _ThreadList()),
      ],
    );
  }
}

// ─── section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          'אחרונות',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─── thread list ──────────────────────────────────────────────────────────────

class _ThreadList extends StatelessWidget {
  const _ThreadList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _kThreads.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFF222222)),
      itemBuilder: (context, i) => _ThreadRow(thread: _kThreads[i]),
    );
  }
}

class _ThreadRow extends StatelessWidget {
  const _ThreadRow({required this.thread});
  final _Thread thread;

  @override
  Widget build(BuildContext context) {
    final missed = thread.direction == _Direction.missed;
    final nameColor = missed ? BsTokens.brand : Colors.white;
    final arrowIcon = thread.direction == _Direction.outgoing
        ? Icons.north_east_rounded
        : Icons.south_west_rounded;
    final arrowColor =
        missed ? BsTokens.brand : const Color(0xFF4CAF50);

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => _ChatPage(thread: thread)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // RIGHT — avatar
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
              child: Text(thread.avatar,
                  style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),

            // MIDDLE
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
                            fontWeight: FontWeight.w700,
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
                              color: missed
                                  ? BsTokens.brand
                                  : const Color(0xFF888888),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '~ ${thread.subtitle}',
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
  final List<({String text, bool isMe})> _messages = [];

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
    _messages.add((text: widget.thread.subtitle, isMe: false));
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add((text: text, isMe: true));
      _controller.clear();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _messages.add((
          text: _autoReplies[_replyIdx % _autoReplies.length],
          isMe: false,
        ));
        _replyIdx++;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
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
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF2A2A2A),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(widget.thread.avatar,
                  style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.thread.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
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
              itemCount: _messages.length,
              itemBuilder: (context, i) => _Bubble(msg: _messages[i]),
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

class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg});
  final ({String text, bool isMe}) msg;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
        child: Text(
          msg.text,
          textAlign: TextAlign.end,
          style: TextStyle(
            color: msg.isMe ? Colors.white : const Color(0xFFDDDDDD),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  borderSide:
                      const BorderSide(color: BsTokens.brand, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
