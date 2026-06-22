// ─────────────────────────────────────────────────────────────────────────────
// AltExplainScreen — "למה החלופה הזולה שווה?" (#ai-alt-explain): the AI explainer
// on top of the deterministic "חלופות זולות" sheet. The cheaper-brand swap and
// every number (recommended price, alternative price, savings) come from the REAL
// `cheaperAlternativesAcrossCatalog()` scan — Claude only PHRASES the tradeoff in
// plain Hebrew so the contractor can decide.
//
// ANTI-HALLUCINATION (grounded, not closed-set): the prompt HANDS Claude the two
// real brand names + their real prices + the real savings; it is told to explain
// the brand-tier tradeoff in general terms and name the ONE thing to verify, and
// is FORBIDDEN to invent specs, numbers, or product names it was not given. The
// numbers shown on screen are the data's — never the model's.
//
// Gated by `claudeGatewayProvider` (null unless useFirebaseBackend && kClaudeAi):
// OFF → an honest "requires connection" state; the demo/test build is unchanged.
// The caller only renders the entry button when the gateway is live.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/claude_functions.dart'
    show claudeGatewayProvider;
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The grounded prompt — hands the model the REAL swap (names + prices + savings)
/// and asks ONLY for a short tradeoff explanation; it may not invent specs.
String altExplainPrompt({
  required String product,
  required String recName,
  required int recPrice,
  required String altName,
  required int altPrice,
}) {
  final savings = recPrice - altPrice;
  return 'מוצר: "$product".\n'
      'מותג מומלץ: $recName — ₪$recPrice.\n'
      'מותג חלופי זול יותר: $altName — ₪$altPrice (חיסכון ₪$savings).\n\n'
      'הסבר לאינסטלטור, ב-2–3 משפטים קצרים בעברית, למה $altName יכול להיות החלפה '
      'סבירה ל-$recName לאותו מוצר, ומה הדבר האחד שכדאי לוודא לפני שקונים את הזול '
      '(אחריות / זמינות / טיב-החומר). אל תמציא מפרטים, מספרים או שמות-מוצר שלא '
      'ניתנו לך, ואל תבטיח שהזול תמיד עדיף.';
}

const String _kSystem =
    'אתה יועץ-רכש מנוסה לאינסטלטורים. אתה מסביר בקצרה ובכנות tradeoff בין מותגים '
    'לאותו מוצר. לעולם אל תמציא מפרט, מספר או שם-מוצר שלא ניתן לך, ואל תטען שהזול '
    'תמיד עדיף — תן לקבלן להחליט.';

class AltExplainScreen extends ConsumerStatefulWidget {
  const AltExplainScreen({
    super.key,
    required this.product,
    required this.recName,
    required this.recPrice,
    required this.altName,
    required this.altPrice,
  });

  final String product;
  final String recName;
  final int recPrice;
  final String altName;
  final int altPrice;

  int get savings => recPrice - altPrice;

  static Route<void> route({
    required String product,
    required String recName,
    required int recPrice,
    required String altName,
    required int altPrice,
  }) =>
      MaterialPageRoute<void>(
        builder: (_) => AltExplainScreen(
          product: product,
          recName: recName,
          recPrice: recPrice,
          altName: altName,
          altPrice: altPrice,
        ),
      );

  @override
  ConsumerState<AltExplainScreen> createState() => _AltExplainState();
}

class _AltExplainState extends ConsumerState<AltExplainScreen> {
  bool _loading = false;
  bool _failed = false;
  String? _explanation;

  @override
  void initState() {
    super.initState();
    // The screen exists to show the explanation — fetch it on open.
    WidgetsBinding.instance.addPostFrameCallback((_) => _explain());
  }

  Future<void> _explain() async {
    final gw = ref.read(claudeGatewayProvider);
    if (gw == null) return;
    setState(() {
      _loading = true;
      _failed = false;
      _explanation = null;
    });
    try {
      final r = await gw.ask(
        prompt: altExplainPrompt(
          product: widget.product,
          recName: widget.recName,
          recPrice: widget.recPrice,
          altName: widget.altName,
          altPrice: widget.altPrice,
        ),
        system: _kSystem,
        maxTokens: 256,
      );
      if (mounted) {
        setState(() {
          _explanation = r.text.trim();
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
          title: const Text('💡 למה החלופה שווה?',
              style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(BsTokens.space4),
          children: [
            // ── The REAL swap (data, never the model). ──
            Text(widget.product,
                style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: BsTokens.space2),
            Text('המלצה: ${widget.recName} · ₪${widget.recPrice}',
                style:
                    const TextStyle(color: BsTokens.mutedLight, fontSize: 13)),
            Text('חלופה: ${widget.altName} · ₪${widget.altPrice}',
                style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: BsTokens.space2),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8D6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('חיסכון ₪${widget.savings}',
                    style: const TextStyle(
                        color: BsTokens.brand,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const Divider(height: BsTokens.space5, color: Color(0xFFEEEEEE)),

            // ── Claude's phrasing of the tradeoff. ──
            if (!aiAvailable)
              const Text('💡 ההסבר החכם דורש חיבור לשרת.',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 13))
            else if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_failed)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('משהו השתבש — נסה שוב.',
                      style:
                          TextStyle(color: BsTokens.danger, fontSize: 14)),
                  const SizedBox(height: BsTokens.space3),
                  OutlinedButton.icon(
                    onPressed: _explain,
                    icon: const Text('🔄'),
                    label: const Text('נסה שוב'),
                  ),
                ],
              )
            else if (_explanation != null)
              Text(_explanation!,
                  style: const TextStyle(
                      color: BsTokens.inkLight, fontSize: 15, height: 1.5)),
            const SizedBox(height: BsTokens.space4),
            const Text('⚙️ המחירים מתוך נתוני-הקטלוג; ה-AI רק מנסח את ההשוואה.',
                style: TextStyle(fontSize: 11, color: Color(0xFF9AA3B2))),
          ],
        ),
      ),
    );
  }
}
