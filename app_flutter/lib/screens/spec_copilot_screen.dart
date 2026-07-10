// ─────────────────────────────────────────────────────────────────────────────
// SpecCopilotScreen — the first Claude-backed feature (#ai-spec-copilot). For a
// catalog product, answers "האם זה מחזיק את התנאים שלי?" (temperature).
//
// ZERO-HALLUCINATION DESIGN: the YES/NO verdict is computed in DART from the
// product's VERIFIED spec (`VerifiedSpec.suitableForTemp` — `tempC <= maxTempC`),
// so it is always correct and works OFFLINE. Claude's ONLY job is to PHRASE that
// pre-computed verdict in a friendly Hebrew sentence, grounded on the verified
// fields passed in the prompt — it never decides and never invents a number.
//
// Gated by `claudeGatewayProvider` (null unless `useFirebaseBackend && kClaudeAi`):
// OFF → the deterministic verdict still shows, with an honest "הסבר-AI דורש חיבור"
// note instead of the phrased explanation. So the demo/test build is unchanged.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/lipskey_verified_connections.dart'
    show VerifiedSpec, kVerifiedSpecs;
import 'package:buildsmart/data/repositories/claude_functions.dart'
    show claudeGatewayProvider;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The verified temperature verdict for [product] at [tempC] — pure, the single
/// source of truth (`VerifiedSpec.suitableForTemp`). `ok` is null when the product
/// has no verified spec (we then can't make a claim).
({bool? ok, double? maxTempC, VerifiedSpec? spec}) specTempVerdict(
  LipskeyCatalogProduct product,
  int tempC,
) {
  final spec = kVerifiedSpecs[product.sku];
  if (spec == null) return (ok: null, maxTempC: null, spec: null);
  return (ok: spec.suitableForTemp(tempC.toDouble()), maxTempC: spec.maxTempC, spec: spec);
}

/// Build the GROUNDED prompt — the verdict is pre-computed in Dart and handed to
/// the model, which only phrases it. The model is told to use ONLY these numbers.
String specCopilotPrompt(LipskeyCatalogProduct product, int tempC, VerifiedSpec spec) {
  final ok = spec.suitableForTemp(tempC.toDouble());
  final pressure =
      spec.pressureRating != null ? 'דירוג-לחץ: ${spec.pressureRating}. ' : '';
  return 'מוצר: ${product.nameHe}. חומר: ${spec.material}. '
      'טמפ׳-מקסימום מאומתת: ${spec.maxTempC}°C. $pressure'
      'השאלה: האם הוא מתאים לקו של $tempC°C? '
      'התשובה הדטרמיניסטית (חושבה מראש): ${ok ? 'כן' : 'לא'} '
      '($tempC ${ok ? '≤' : '>'} ${spec.maxTempC}). '
      'נסח את התשובה הזו במשפט אחד קצר וברור בעברית, כולל המספרים. '
      'אל תמציא נתונים ואל תסתור את התשובה הדטרמיניסטית.';
}

const String _kCopilotSystem =
    'אתה עוזר-מפרט לאינסטלטור. ענה במשפט אחד קצר בעברית בלבד, מבוסס אך ורק על '
    'הנתונים המאומתים שניתנו. לעולם אל תמציא מספרים ואל תסתור את התשובה הנתונה.';

class SpecCopilotScreen extends ConsumerStatefulWidget {
  const SpecCopilotScreen({required this.product, super.key});

  final LipskeyCatalogProduct product;

  static Route<void> route(LipskeyCatalogProduct product) =>
      MaterialPageRoute<void>(
        builder: (_) => SpecCopilotScreen(product: product),
      );

  @override
  ConsumerState<SpecCopilotScreen> createState() => _SpecCopilotState();
}

class _SpecCopilotState extends ConsumerState<SpecCopilotScreen> {
  static const _presets = [40, 60, 80, 95];
  int _temp = 60;
  String? _explanation;
  bool _loading = false;
  bool _failed = false;

  Future<void> _explain() async {
    final gw = ref.read(claudeGatewayProvider);
    // Snapshot the temp this request is for — if the user changes the chip while
    // the call is in flight, the late reply (which captured THIS temp) is dropped
    // so it can't render under the now-different verdict (swarm race fix).
    final reqTemp = _temp;
    final v = specTempVerdict(widget.product, reqTemp);
    if (gw == null || v.spec == null) return; // honest: no AI / no spec
    setState(() {
      _loading = true;
      _failed = false;
      _explanation = null;
    });
    try {
      final r = await gw.ask(
        prompt: specCopilotPrompt(widget.product, reqTemp, v.spec!),
        system: _kCopilotSystem,
        maxTokens: 200,
      );
      if (mounted && _temp == reqTemp) {
        setState(() {
          final reply = r.text.trim();
          if (reply.isEmpty) {
            _failed = true; // 200-empty → honest retry, not a bare "🤖 " stub
          } else {
            _explanation = reply;
          }
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted && _temp == reqTemp) {
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
    final v = specTempVerdict(widget.product, _temp);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          elevation: 0,
          title: const CfgText(
              'spec_copilot_screen.t01', '🌡️ מתאים לתנאים שלי?',
              style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(BsTokens.space4),
          children: [
            Text(widget.product.nameHe,
                style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: BsTokens.space3),
            const CfgText('spec_copilot_screen.t02', 'טמפרטורת הקו:',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                for (final t in _presets)
                  ChoiceChip(
                    label: Text('$t°C'),
                    selected: _temp == t,
                    onSelected: (_) => setState(() {
                      _temp = t;
                      _explanation = null;
                      _failed = false;
                      _loading = false; // a chip change cancels any in-flight spinner
                    }),
                  ),
              ],
            ),
            const SizedBox(height: BsTokens.space4),
            // ── the deterministic verdict (always shown, offline-safe) ──
            if (v.ok == null)
              const CfgText(
                  'spec_copilot_screen.t03', 'אין מפרט מאומת למוצר זה — לא ניתן לקבוע.',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 14))
            else
              Container(
                padding: const EdgeInsets.all(BsTokens.space3),
                decoration: BoxDecoration(
                  color: (v.ok! ? BsTokens.success : BsTokens.danger)
                      .withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                ),
                child: Text(
                  v.ok!
                      ? '✓ כן — מחזיק $_temp°C (מקס׳ מאומת ${v.maxTempC!.toInt()}°C)'
                      : '✗ לא — מעבר למקס׳ המאומת (${v.maxTempC!.toInt()}°C)',
                  style: TextStyle(
                      // a11y (swarm): *Dark token for TEXT — success/danger fail
                      // WCAG AA on the light tint; the tint background stays.
                      color: v.ok! ? BsTokens.successDark : BsTokens.dangerDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w800),
                ),
              ),
            const SizedBox(height: BsTokens.space4),
            // ── the AI explanation (only when the gateway is live) ──
            if (v.ok != null) ...[
              if (!aiAvailable)
                const CfgText(
                    'spec_copilot_screen.t04', '💡 הסבר-AI דורש חיבור לשרת.',
                    style: TextStyle(color: BsTokens.mutedLight, fontSize: 12.5))
              else if (_loading)
                const Row(children: [
                  SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  CfgText('spec_copilot_screen.t05', 'מנסח הסבר…',
                      style:
                          TextStyle(color: BsTokens.mutedLight, fontSize: 13)),
                ])
              else if (_explanation != null)
                Container(
                  padding: const EdgeInsets.all(BsTokens.space3),
                  decoration: BoxDecoration(
                    color: BsTokens.cardLight,
                    borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                    border: Border.all(color: const Color(0xFFEDEDED)),
                  ),
                  child: Text('🤖 $_explanation',
                      style: const TextStyle(
                          color: BsTokens.inkLight, fontSize: 14, height: 1.5)),
                )
              else
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: _explain,
                    icon: const Text('🤖'),
                    label: Text(_failed ? 'נסה שוב' : 'הסבר לי'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
