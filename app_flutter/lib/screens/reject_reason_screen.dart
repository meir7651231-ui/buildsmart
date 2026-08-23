// ─────────────────────────────────────────────────────────────────────────────
// RejectReasonScreen — "✨ נסח סיבת-דחייה" (#ai-reject-reason): drafts a polite,
// professional denial reason for a role request, so a manager rejecting a worker/
// store/courier doesn't leave it blank (which kills morale). Unlike the other AI
// features this one GENERATES text rather than narrating data, so it is grounded
// by a CLOSED SET of acceptable reason-categories the model must choose from, and
// is FORBIDDEN to invent specific facts about the person — it only phrases a
// generic, respectful reason the manager edits/copies before sending.
//
// Gated by `claudeGatewayProvider` (null unless useFirebaseBackend && kClaudeAi):
// OFF → an honest "requires connection" state; the demo/test build is unchanged.
// The caller only renders the entry button when the gateway is live.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/repositories/claude_functions.dart'
    show claudeGatewayProvider;
import 'package:buildsmart/logic/prompt_sanitize.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/ai_result_states.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The grounded prompt — hands the model a CLOSED set of reason-categories and
/// asks it to phrase ONE politely; it may not invent facts about the person.
String rejectReasonPrompt({required String role, required String name}) {
  // `name` is an attacker-controlled profile displayName, and this reply is shown
  // as PROSE (no closed-set after it) — the one live injection lever. Collapse
  // newlines + hard-cap so it can't carry an "ignore the above…" payload.
  final who = name.trim().isEmpty
      ? 'המבקש'
      : promptSafeText(name, maxLen: 60, collapseWhitespace: true);
  return 'מנהל דוחה בקשה להצטרף כ-"$role" מאת $who.\n'
      'קטגוריות-סיבה מקובלות (בחר אחת בלבד ונסח אותה בעדינות):\n'
      '• מסמכים/אימות שטרם הושלמו\n'
      '• הדרכה נדרשת שטרם בוצעה\n'
      '• ממתין לבדיקת-רקע / אישור\n'
      '• אין כרגע מקום פנוי לתפקיד\n\n'
      'נסח הודעת-דחייה קצרה, מנומסת ומקצועית בעברית, מופנית למבקש, שמסתיימת '
      'בהזמנה להגיש שוב בעתיד. אל תמציא עובדות ספציפיות על האדם — הישאר '
      'ברמת-הקטגוריה בלבד.';
}

const String _kSystem =
    'אתה מנסח הודעת-דחייה מנומסת ומקצועית לבקשת-תפקיד. בחר סיבה כללית ומכובדת '
    'מתוך הקטגוריות שניתנו, נסח אותה בעדינות, ולעולם אל תמציא עובדות ספציפיות על '
    'האדם. קצר, מכבד, ומסתיים בהזמנה להגיש שוב.';

class RejectReasonScreen extends ConsumerStatefulWidget {
  const RejectReasonScreen({super.key, required this.role, required this.name});

  final String role;
  final String name;

  static Route<void> route({required String role, required String name}) =>
      MaterialPageRoute<void>(
        builder: (_) => RejectReasonScreen(role: role, name: name),
      );

  @override
  ConsumerState<RejectReasonScreen> createState() => _RejectReasonState();
}

class _RejectReasonState extends ConsumerState<RejectReasonScreen> {
  bool _loading = false;
  bool _failed = false;
  String? _draft;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _draftReason());
  }

  Future<void> _draftReason() async {
    final gw = ref.read(claudeGatewayProvider);
    if (gw == null) return;
    setState(() {
      _loading = true;
      _failed = false;
      _draft = null;
    });
    try {
      final r = await gw.ask(
        prompt: rejectReasonPrompt(role: widget.role, name: widget.name),
        system: _kSystem,
        maxTokens: 256,
      );
      if (mounted) {
        setState(() {
          final reply = r.text.trim();
          if (reply.isEmpty) {
            _failed = true; // 200-empty → honest retry, not a blank box
          } else {
            _draft = reply;
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
    final text = _draft;
    if (text == null || text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: CfgText('reject_reason_screen.copied', 'הנוסח הועתק'),
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
          title: const CfgText('reject_reason_screen.title', '✨ סיבת-דחייה',
              style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(BsTokens.space4),
          children: [
            Text(
                'בקשת-תפקיד: ${widget.role}'
                '${widget.name.trim().isEmpty ? '' : ' · ${widget.name.trim()}'}',
                style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
            const Divider(height: BsTokens.space5, color: BsTokens.divider),

            if (!aiAvailable)
              const AiOffState('💡 ניסוח-הסיבה החכם דורש חיבור לשרת.')
            else if (_loading)
              const AiLoadingState()
            else if (_failed)
              AiFailedState(onRetry: _draftReason)
            else if (_draft != null) ...[
              Text(_draft!,
                  style: const TextStyle(
                      color: BsTokens.inkLight, fontSize: 15, height: 1.6)),
              const SizedBox(height: BsTokens.space4),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _copy,
                  icon: const Text('📋'),
                  label: const CfgText('reject_reason_screen.copy', 'העתק'),
                ),
              ),
            ],
            const SizedBox(height: BsTokens.space4),
            const CfgText('reject_reason_screen.note',
                '⚙️ נוסח כללי ומכובד; ערוך לפי הצורך לפני שליחה. ה-AI לא ממציא '
                'פרטים על המבקש.',
                style: TextStyle(fontSize: 11, color: BsTokens.mutedDark)),
          ],
        ),
      ),
    );
  }
}
