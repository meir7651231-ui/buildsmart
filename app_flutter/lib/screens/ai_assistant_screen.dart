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

import 'package:buildsmart/data/fuzzy_search.dart' show fuzzySearchProducts;
import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;
import 'package:buildsmart/data/repositories/claude_functions.dart'
    show claudeGatewayProvider;
import 'package:buildsmart/logic/ai_hub_logic.dart'
    show computeAnalyticsInsights;
import 'package:buildsmart/logic/assistant_intent.dart';
import 'package:buildsmart/screens/ai_finder_screen.dart'
    show productsInCategory;
import 'package:buildsmart/screens/describe_to_cart_screen.dart'
    show matchRecipe, resolvedKitProducts;
import 'package:buildsmart/state/orders_engine.dart' show ordersEngineProvider;
import 'package:buildsmart/state/smart_cart.dart'
    show SmartCartLine, smartCartProvider;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A single conversation turn (kept local — never persisted to the chat engine).
/// A bot turn may carry a [kit] — a PROPOSED add-to-cart (Phase 2). The kit is
/// the REAL resolved products; the cart is written only when the user taps the
/// confirm button on this turn (tracked by index in `_confirmedKitTurns`).
class AssistantTurn {
  const AssistantTurn({
    required this.user,
    required this.text,
    this.kit = const [],
  });
  final bool user; // true = the contractor, false = the assistant
  final String text;
  final List<LipskeyCatalogProduct> kit;
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
  // Turn indices whose proposed add-to-cart the user has CONFIRMED — the only
  // gate to the cart write. Until a turn is in here its kit is just a proposal.
  final Set<int> _confirmedKitTurns = {};
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
      final turn = _dispatchIntent(parseAssistantIntent(r.text), text);
      setState(() {
        _turns.add(turn);
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

  /// Run a VALIDATED intent over the REAL engines and build the assistant's turn.
  /// Every product/number comes from the engines (productsInCategory /
  /// computeAnalyticsInsights / resolvedKitProducts — real SKUs), never the model;
  /// the model supplied only the validated key + prose `say`. `addToCart` only
  /// PROPOSES a kit (carried on the turn) — the cart write waits for the confirm tap.
  AssistantTurn _dispatchIntent(AssistantIntent intent, String userText) {
    switch (intent.action) {
      case AssistantAction.answer:
        final say = intent.say.trim();
        return AssistantTurn(
            user: false,
            text: say.isEmpty ? 'לא הצלחתי לנסח תשובה — נסה לנסח אחרת.' : say);
      case AssistantAction.findProduct:
        // Literal-first (mirrors the finder): the user's words often name a
        // color/size/material the single-category map can't reach ("שחור" →
        // "נחושת"). Prefer real NAME-matches; only when there are none fall back
        // to the model's category pick. Both are grounded (real catalog rows).
        final literal = fuzzySearchProducts(userText);
        final fromLiteral = literal.isNotEmpty;
        final products = fromLiteral ? literal : productsInCategory(intent.key);
        final head = intent.say.isNotEmpty
            ? intent.say
            : (fromLiteral
                ? 'מצאתי עבור "$userText":'
                : 'מצאתי בקטגוריה "${intent.key}":');
        if (products.isEmpty) {
          return AssistantTurn(
              user: false, text: '$head\n(לא נמצאו מוצרים מתאימים כרגע.)');
        }
        final label =
            fromLiteral ? '🔎 "$userText"' : '📂 ${intent.key}';
        final lines =
            [for (final p in products.take(8)) '• ${p.nameHe}'].join('\n');
        return AssistantTurn(
            user: false,
            text: '$head\n$label · ${products.length} מוצרים\n$lines');
      case AssistantAction.summarizeOrders:
        final insights =
            computeAnalyticsInsights(ref.read(ordersEngineProvider));
        final rows = [
          for (final it in insights)
            if (it.ic != '📊') '${it.ic} ${it.title}',
        ].join('\n');
        final head = intent.say.isNotEmpty ? intent.say : '📊 ההזמנות שלך:';
        return AssistantTurn(
            user: false,
            text: rows.isEmpty ? '$head\n(אין הזמנות עדיין.)' : '$head\n$rows');
      case AssistantAction.checkBudget:
        final insights =
            computeAnalyticsInsights(ref.read(ordersEngineProvider));
        final budget = insights.where((it) => it.ic == '📊').toList();
        final head = intent.say.isNotEmpty ? intent.say : '📊 התקציב:';
        return AssistantTurn(
            user: false,
            text: budget.isEmpty
                ? '$head\n(אין נתוני תקציב.)'
                : '$head\n${budget.map((it) => '${it.ic} ${it.title} · ${it.sub}').join('\n')}');
      case AssistantAction.addToCart:
        final recipe = matchRecipe(intent.key);
        final List<LipskeyCatalogProduct> products =
            recipe == null ? const [] : resolvedKitProducts(recipe);
        if (products.isEmpty) {
          return AssistantTurn(
              user: false,
              text: intent.say.isNotEmpty
                  ? intent.say
                  : 'לא הצלחתי להרכיב את הערכה — נסה לתאר אחרת.');
        }
        final head =
            intent.say.isNotEmpty ? intent.say : 'הרכבתי ערכה — להוסיף לסל?';
        final lines =
            [for (final p in products.take(8)) '• ${p.nameHe}'].join('\n');
        return AssistantTurn(
            user: false,
            text: '$head\n${products.length} פריטים:\n$lines',
            kit: products);
    }
  }

  /// The ONLY cart-write path — reachable solely by the user tapping confirm on a
  /// proposed-kit turn (G5). Reuses describe→cart's exact SmartCartLine write.
  void _confirmAdd(List<LipskeyCatalogProduct> kit, int turnIndex) {
    final notifier = ref.read(smartCartProvider.notifier);
    for (final p in kit) {
      notifier.add(SmartCartLine(
        productKey: 'lip:${p.sku}',
        productName: p.nameHe,
        productEmoji: p.typeEmoji,
        brandName: p.brand,
        brandPrice: 0,
        productQty: 1,
        accessories: const [],
      ));
    }
    setState(() => _confirmedKitTurns.add(turnIndex));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('נוספו ${kit.length} פריטים לסל ✓'),
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
    ));
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
          title: const CfgText('ai_assistant_screen.title', '🤖 העוזר החכם',
              style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
        ),
        body: !aiAvailable
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(BsTokens.space5),
                  child: CfgText('ai_assistant_screen.offline', '💡 העוזר החכם דורש חיבור לשרת.',
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
                              return _bubble(_turns[i], i);
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
              CfgText('ai_assistant_screen.empty_prompt', 'שאל אותי כל דבר על אינסטלציה, רכש או עבודה.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: BsTokens.inkLight, fontSize: 15)),
              SizedBox(height: 6),
              CfgText('ai_assistant_screen.empty_examples', 'אפשר גם לבקש: "תמצא לי ברז" · "מה מצב ההזמנות" · '
                  '"כמה נשאר בתקציב" · "תוסיף ערכה לסל".',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: BsTokens.mutedLight, fontSize: 12)),
            ],
          ),
        ),
      );

  Widget _bubble(AssistantTurn t, int index) {
    final isUser = t.user;
    final hasKit = !isUser && t.kit.isNotEmpty;
    final confirmed = _confirmedKitTurns.contains(index);
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dark ink on BOTH bubbles — white-on-brand was ~2.7:1 (fails WCAG
            // AA); dark-on-brand is ~6:1 and keeps the brand-colored user bubble
            // (same fix already applied to the manager Co-Pilot bubble).
            Text(t.text,
                style: const TextStyle(
                    color: BsTokens.inkLight, fontSize: 14, height: 1.4)),
            // #ai-assistant-agentic Phase 2 — the cart write is gated behind THIS
            // explicit tap (G5); until confirmed the kit is only a proposal.
            if (hasKit) ...[
              const SizedBox(height: 8),
              if (confirmed)
                const CfgText('ai_assistant_screen.added', '✓ נוסף לסל',
                    style: TextStyle(
                        color: Color(0xFF0F766E),
                        fontSize: 13,
                        fontWeight: FontWeight.w800))
              else
                FilledButton.icon(
                  onPressed: () => _confirmAdd(t.kit, index),
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: Text('הוסף ${t.kit.length} לסל'),
                ),
            ],
          ],
        ),
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
