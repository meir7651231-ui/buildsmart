// ─────────────────────────────────────────────────────────────────────────────
// DailyReportScreen — "✨ נסח דוח-יום" (#ai-daily-report): a SHARED narrator for
// the worker + courier daily reports. Each tab already composes the day's real
// numbers (worker: approved / submitted / first-pass% / streak; courier:
// delivered / POD / value) from its live engines; this screen takes those
// pre-formatted lines and Claude NARRATES them into a short, flowing Hebrew
// report the user can copy and send. The numbers are the engine's; Claude only
// phrases them.
//
// ANTI-HALLUCINATION (grounded — narrate-only): the prompt HANDS Claude the real
// report lines and FORBIDS inventing, changing, or adding any number; it may only
// weave the given figures into prose.
//
// Gated by `claudeGatewayProvider` (null unless useFirebaseBackend && kClaudeAi):
// OFF → an honest "requires connection" state; the demo/test build is unchanged.
// The caller only renders the entry button when the gateway is live.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/claude_functions.dart'
    show claudeGatewayProvider;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/ai_result_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The grounded prompt — hands the model the REAL report lines and asks ONLY for
/// a short narration; every number must be used as-is, none invented.
String dailyReportPrompt(String title, List<String> reportLines) {
  return '$title — הנתונים שנרשמו היום:\n${reportLines.join('\n')}\n\n'
      'נסח מהם דוח-יום קצר וזורם בעברית (2–4 משפטים), מוכן לשליחה ללקוח/לחנות. '
      'השתמש אך ורק במספרים שניתנו לך — אל תמציא, תשנה או תוסיף שום מספר.';
}

const String _kSystem =
    'אתה עוזר שמנסח דוח-יום קצר ומקצועי מנתונים שכבר נרשמו. השתמש אך ורק במספרים '
    'שניתנו לך; לעולם אל תמציא, תשנה או תוסיף מספר.';

class DailyReportScreen extends ConsumerStatefulWidget {
  const DailyReportScreen({
    super.key,
    required this.title,
    required this.reportLines,
  });

  final String title;
  final List<String> reportLines;

  static Route<void> route({
    required String title,
    required List<String> reportLines,
  }) =>
      MaterialPageRoute<void>(
        builder: (_) =>
            DailyReportScreen(title: title, reportLines: reportLines),
      );

  @override
  ConsumerState<DailyReportScreen> createState() => _DailyReportState();
}

class _DailyReportState extends ConsumerState<DailyReportScreen> {
  bool _loading = false;
  bool _failed = false;
  String? _report;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _compose());
  }

  Future<void> _compose() async {
    final gw = ref.read(claudeGatewayProvider);
    if (gw == null || widget.reportLines.isEmpty) return;
    setState(() {
      _loading = true;
      _failed = false;
      _report = null;
    });
    try {
      final r = await gw.ask(
        prompt: dailyReportPrompt(widget.title, widget.reportLines),
        system: _kSystem,
        maxTokens: 400,
      );
      if (mounted) {
        setState(() {
          final reply = r.text.trim();
          if (reply.isEmpty) {
            _failed = true; // 200-empty → honest retry, not a blank box
          } else {
            _report = reply;
          }
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
    final text = _report;
    if (text == null || text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('הדוח הועתק'), duration: Duration(seconds: 2)),
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
          title: const Text('✨ ניסוח חכם',
              style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(BsTokens.space4),
          children: [
            Text(widget.title,
                style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: BsTokens.space2),
            // ── The REAL recorded numbers (data, never the model). ──
            for (final line in widget.reportLines)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $line',
                    style: const TextStyle(
                        color: BsTokens.inkLight, fontSize: 13)),
              ),
            const Divider(height: BsTokens.space5, color: BsTokens.divider),

            if (!aiAvailable)
              const AiOffState('💡 ניסוח-הדוח החכם דורש חיבור לשרת.')
            else if (_loading)
              const AiLoadingState()
            else if (_failed)
              AiFailedState(onRetry: _compose)
            else if (_report != null) ...[
              Text(_report!,
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
            const Text('⚙️ המספרים נרשמו במערכת; ה-AI רק מנסח אותם לדוח.',
                style: TextStyle(fontSize: 11, color: BsTokens.mutedDark)),
          ],
        ),
      ),
    );
  }
}
