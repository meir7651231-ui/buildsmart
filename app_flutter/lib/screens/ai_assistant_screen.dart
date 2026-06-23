// ─────────────────────────────────────────────────────────────────────────────
// AiAssistantScreen — "🤖 העוזר החכם" (#ai-assistant): a real, grounded Claude
// assistant for the BuildSmart contractor. The legacy `kBotAutoReplies` bot in
// sys_chat is a canned demo thread wired through Firestore; this is the LIVE
// assistant — its own local conversation, so it touches NONE of the load-bearing
// chat engine (persistence / uid-scoping / Firestore sync stay untouched).
//
// GROUNDING (honest, domain-bounded — not a closed set): a conversational
// assistant is open by nature, so the system prompt does the grounding — it (1)
// bounds the domain to plumbing / construction / procurement, (2) FORBIDS
// inventing product names, SKUs, prices, or stock (it has no catalog access),
// and (3) ROUTES every catalog action to the app's REAL grounded tools
// ("תאר עבודה → סל", the smart finder, the product card). So it reasons over
// general trade knowledge but never claims app-specific data it doesn't hold.
//
// Gated by `claudeGatewayProvider` (null unless useFirebaseBackend && kClaudeAi):
// OFF → an honest "requires connection" state with the input disabled; the
// demo/test build is unchanged.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/claude_functions.dart'
    show claudeGatewayProvider;
import 'package:buildsmart/logic/ai_hub_logic.dart'
    show computeAnalyticsInsights;
import 'package:buildsmart/logic/assistant_intent.dart';
import 'package:buildsmart/screens/ai_finder_screen.dart'
    show productsInCategory;
import 'package:buildsmart/state/orders_engine.dart' show ordersEngineProvider;
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A single conversation turn (kept local — never persisted to the chat engine).
class AssistantTurn {
  const AssistantTurn({required this.user, required this.text});
  final bool user; // true = the contractor, false = the assistant
  final String text;
}

/// The system prompt — this IS the grounding for an open assistant: domain-bound,
/// invention-forbidden, and routes catalog actions to the real tools.
const String assistantSystem =
    'אתה "העוזר החכם" של BuildSmart — אפליקציית-רכש לאינסטלטורים וקבלני-בנייה. '
    'ענה בעברית, קצר ולעניין.\n'
    'מותר: שאלות מקצועיות כלליות באינסטלציה/בנייה/רכש, הסבר על תהליכי-עבודה, '
    'עזרה בניסוח.\n'
    'אסור: להמציא שמות-מוצר, מק"טים, מחירים או זמינות-מלאי ספציפיים — אין לך גישה '
    'לקטלוג החי, אז לעולם אל תַמְצִיא נתון כזה.\n'
    'כשהמשתמש רוצה לבנות סל / למצוא מוצר / לבדוק מחיר — הַפְנֵה אותו לכלים האמיתיים '
    'באפליקציה: "תאר עבודה → סל" (בונה סל מתיאור), "חיפוש חכם / מאתר חכם" (מוצא '
    'מוצר מתיאור), וכרטיס-המוצר ("מתאים לתנאים שלי?" · "מה עוד צריך להתקנה?").\n'
    'אם אינך יודע — אמור זאת בכנות. אל תמציא.';

/// The maximum prior turns folded into a single prompt (the `askClaude` callable
/// takes ONE user message, so we serialize a bounded history into it).
const int kAssistantHistoryWindow = 12;

/// Fold the (bounded) prior turns + the new message into one prompt string.
String assistantTurnPrompt(List<AssistantTurn> history, String userText) {
  final recent = history.length > kAssistantHistoryWindow
      ? history.sublist(history.length - kAssistantHistoryWindow)
      : history;
  final b = StringBuffer();
  if (recent.isNotEmpty) {
    b.writeln('השיחה עד כה:');
    for (final m in recent) {
      b.writeln('${m.user ? "משתמש" : "עוזר"}: ${m.text}');
    }
    b.writeln();
  }
  b.write('משתמש: $userText');
  return b.toString();
}

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const AiAssistantScreen());

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantState();
}

class _AiAssistantState extends ConsumerState<AiAssistantScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<AssistantTurn> _turns = [];
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send() async {
    final gw = ref.read(claudeGatewayProvider);
    final text = _controller.text.trim();
    if (gw == null || text.isEmpty || _loading) return;
    FocusScope.of(context).unfocus();
    // The history handed to the model EXCLUDES the message we're adding now
    // (decoupled records, not the widget model — the logic layer is pure).
    final history = [for (final t in _turns) (user: t.user, text: t.text)];
    setState(() {
      _turns.add(AssistantTurn(user: true, text: text));
      _controller.clear();
      _loading = true;
    });
    _scrollToEnd();
    try {
      final r = await gw.ask(
        prompt: assistantIntentPrompt(history, text),
        system: assistantIntentSystem,
        maxTokens: 256,
      );
      if (!mounted) return;
      // Parse + closed-set-validate; a garbled/hallucinated reply degrades to a
      // plain answer (never acts wrongly). Then run the action over REAL engines.
      final reply = _dispatchIntent(parseAssistantIntent(r.text));
      setState(() {
        _turns.add(AssistantTurn(
            user: false,
            text: reply.isEmpty
                ? 'לא הצלחתי לנסח תשובה — נסה לנסח אחרת.'
                : reply));
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _turns.add(const AssistantTurn(
            user: false, text: 'משהו השתבש בחיבור — נסה שוב עוד רגע.'));
        _loading = false;
      });
    }
    _scrollToEnd();
  }

  /// Run a VALIDATED intent over the REAL engines and format a Hebrew reply.
  /// READ-ONLY — never mutates state (Phase 1). Every product/number comes from
  /// the engines (kCatalogProducts via productsInCategory / computeAnalyticsInsights),
  /// never the model; the model supplied only the validated key + the prose `say`.
  String _dispatchIntent(AssistantIntent intent) {
    switch (intent.action) {
      case AssistantAction.answer:
        return intent.say;
      case AssistantAction.findProduct:
        final products = productsInCategory(intent.key);
        final head = intent.say.isNotEmpty
            ? intent.say
            : 'מצאתי בקטגוריה "${intent.key}":';
        if (products.isEmpty) {
          return '$head\n(אין מוצרים בקטגוריה הזו כרגע.)';
        }
        final lines =
            [for (final p in products.take(8)) '• ${p.nameHe}'].join('\n');
        return '$head\n📂 ${intent.key} · ${products.length} מוצרים\n$lines';
      case AssistantAction.summarizeOrders:
        final insights =
            computeAnalyticsInsights(ref.read(ordersEngineProvider));
        final rows = [
          for (final it in insights)
            if (it.ic != '📊') '${it.ic} ${it.title}',
        ].join('\n');
        final head = intent.say.isNotEmpty ? intent.say : '📊 ההזמנות שלך:';
        return rows.isEmpty ? '$head\n(אין הזמנות עדיין.)' : '$head\n$rows';
      case AssistantAction.checkBudget:
        final insights =
            computeAnalyticsInsights(ref.read(ordersEngineProvider));
        final budget = insights.where((it) => it.ic == '📊').toList();
        final head = intent.say.isNotEmpty ? intent.say : '📊 התקציב:';
        if (budget.isEmpty) return '$head\n(אין נתוני תקציב.)';
        return '$head\n${budget.map((it) => '${it.ic} ${it.title} · ${it.sub}').join('\n')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiAvailable = ref.watch(claudeGatewayProvider) != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          elevation: 0,
          title: const Text('🤖 העוזר החכם',
              style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
        ),
        body: !aiAvailable
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(BsTokens.space5),
                  child: Text('💡 העוזר החכם דורש חיבור לשרת.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: BsTokens.mutedLight, fontSize: 14)),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: _turns.isEmpty
                        ? _emptyState()
                        : ListView.builder(
                            controller: _scroll,
                            padding: const EdgeInsets.all(BsTokens.space4),
                            itemCount: _turns.length + (_loading ? 1 : 0),
                            itemBuilder: (context, i) {
                              if (i >= _turns.length) return _typingBubble();
                              return _bubble(_turns[i]);
                            },
                          ),
                  ),
                  _inputRow(),
                ],
              ),
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(BsTokens.space5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('🤖', style: TextStyle(fontSize: 40)),
              SizedBox(height: BsTokens.space3),
              Text('שאל אותי כל דבר על אינסטלציה, רכש או עבודה.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: BsTokens.inkLight, fontSize: 15)),
              SizedBox(height: 6),
              Text('לבניית סל או חיפוש מוצר — אפנה אותך לכלים החכמים באפליקציה.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: BsTokens.mutedLight, fontSize: 12)),
            ],
          ),
        ),
      );

  Widget _bubble(AssistantTurn t) {
    final isUser = t.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isUser ? BsTokens.brand : BsTokens.cardLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(t.text,
            style: TextStyle(
                color: isUser ? Colors.white : BsTokens.inkLight,
                fontSize: 14,
                height: 1.4)),
      ),
    );
  }

  Widget _typingBubble() => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: BsTokens.cardLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );

  Widget _inputRow() => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'כתוב הודעה…',
                    filled: true,
                    fillColor: BsTokens.cardLight,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _loading ? null : _send,
                icon: const Icon(Icons.send),
                tooltip: 'שלח',
              ),
            ],
          ),
        ),
      );
}
