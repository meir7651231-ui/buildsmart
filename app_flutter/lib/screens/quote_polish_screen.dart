// ─────────────────────────────────────────────────────────────────────────────
// QuotePolishScreen — "✨ נסח הצעה מקצועית" (#ai-quote-polish): turns the raw
// `quoteTextFor` price quote (a plain list of real numbers — product / accessories
// / labour / total) into a polished, customer-facing Hebrew message the contractor
// can send straight to a client. The NUMBERS come from the deterministic line-cost
// estimate; Claude only RE-PHRASES — greeting, structure, a polite call-to-action.
//
// ANTI-HALLUCINATION (grounded — rewrite-only): the prompt HANDS Claude the raw
// quote and FORBIDS changing, adding, or removing any number / price / SKU; it may
// only rephrase. A quote that invents or mutates a price is a business disaster, so
// the discipline here is strict: the figures shown are the data's, never the model's.
//
// Gated by `claudeGatewayProvider` (null unless useFirebaseBackend && kClaudeAi):
// OFF → an honest "requires connection" state; the demo/test build is unchanged.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/claude_functions.dart'
    show claudeGatewayProvider;
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The grounded prompt — hands the model the REAL raw quote and asks ONLY for a
/// professional re-phrasing; every number must be preserved verbatim.
String quotePolishPrompt(String rawQuote) {
  return 'הצעת-המחיר הגולמית (מתוך נתוני-המערכת):\n$rawQuote\n\n'
      'נסח אותה מחדש כהודעה מקצועית ומנומסת ללקוח בעברית — פתיחה קצרה, פירוט '
      'הסעיפים בצורה ברורה, וסיום עם הזמנה מנומסת לאישור. שמור על כל מספר, מחיר '
      'ומק"ט בדיוק כפי שהם — אל תשנה, תוסיף או תמחק שום סכום/מחיר/פריט, ואל תמציא '
      'פרטים שלא ניתנו לך.';
}

const String _kSystem =
    'אתה עוזר-מכירות מנוסה לאינסטלטור. אתה מנסח הצעות-מחיר מקצועיות ומשכנעות '
    'ללקוחות. שמור על כל מספר ומחיר בדיוק כפי שניתן לך; לעולם אל תשנה, תוסיף או '
    'תמציא מחיר, סכום או פריט.';

class QuotePolishScreen extends ConsumerStatefulWidget {
  const QuotePolishScreen({
    super.key,
    required this.rawQuote,
    required this.productName,
  });

  final String rawQuote;
  final String productName;

  static Route<void> route({
    required String rawQuote,
    required String productName,
  }) =>
      MaterialPageRoute<void>(
        builder: (_) =>
            QuotePolishScreen(rawQuote: rawQuote, productName: productName),
      );

  @override
  ConsumerState<QuotePolishScreen> createState() => _QuotePolishState();
}

class _QuotePolishState extends ConsumerState<QuotePolishScreen> {
  bool _loading = false;
  bool _failed = false;
  String? _polished;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _polish());
  }

  Future<void> _polish() async {
    final gw = ref.read(claudeGatewayProvider);
    if (gw == null) return;
    setState(() {
      _loading = true;
      _failed = false;
      _polished = null;
    });
    try {
      final r = await gw.ask(
        prompt: quotePolishPrompt(widget.rawQuote),
        system: _kSystem,
        maxTokens: 512,
      );
      if (mounted) {
        setState(() {
          _polished = r.text.trim();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _failed = true;
          _loading = false;
        });
      }
    }
  }

  void _copy() {
    final text = _polished;
    if (text == null || text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('ההצעה המנוסחת הועתקה'),
          duration: Duration(seconds: 2)),
    );
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
          title: const Text('✨ הצעה מקצועית',
              style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(BsTokens.space4),
          children: [
            Text(widget.productName,
                style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: BsTokens.space2),
            // The raw quote (the source of truth — same numbers, before phrasing).
            Container(
              padding: const EdgeInsets.all(BsTokens.space3),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F7F9),
                borderRadius: BorderRadius.circular(BsTokens.radiusCard),
              ),
              child: Text(widget.rawQuote,
                  style: const TextStyle(
                      color: BsTokens.mutedLight, fontSize: 12, height: 1.5)),
            ),
            const Divider(height: BsTokens.space5, color: Color(0xFFEEEEEE)),

            if (!aiAvailable)
              const Text('💡 הניסוח המקצועי דורש חיבור לשרת.',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 13))
            else if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_failed)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('משהו השתבש — נסה שוב.',
                      style: TextStyle(color: BsTokens.danger, fontSize: 14)),
                  const SizedBox(height: BsTokens.space3),
                  OutlinedButton.icon(
                    onPressed: _polish,
                    icon: const Text('🔄'),
                    label: const Text('נסה שוב'),
                  ),
                ],
              )
            else if (_polished != null) ...[
              Text(_polished!,
                  style: const TextStyle(
                      color: BsTokens.inkLight, fontSize: 15, height: 1.6)),
              const SizedBox(height: BsTokens.space4),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _copy,
                  icon: const Text('📋'),
                  label: const Text('העתק לשליחה'),
                ),
              ),
            ],
            const SizedBox(height: BsTokens.space4),
            const Text('⚙️ המספרים מנתוני-המערכת; ה-AI רק מנסח — לא משנה מחירים.',
                style: TextStyle(fontSize: 11, color: Color(0xFF9AA3B2))),
          ],
        ),
      ),
    );
  }
}
