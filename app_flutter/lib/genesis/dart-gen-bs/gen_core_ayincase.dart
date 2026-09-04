// 🧠 AyinCaseCoreScreen — גרעין-מהסכמה (GENMAX·G6b · הכרעה-24) · מחולל דטרמיניסטי: core-dart.mjs (מקור: core-registry.json ⇐ schema-fields + enum-values + entity-terms)
//   workflow: stage:AyinStage ⇒ new→lead→eyes→answer→done · מעבר = אטום-מדף next-stage · יחסים 0 · חוקים 8 · ערוצים 0 · policy = הכרעת-בעלים (שקע ריק)
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import '../dart-ui-bs/premium/feedback/status_chip.dart';
import '../dart-ui-bs/premium/feedback/alert_banner.dart';
import '../dart-ui-bs/premium/actions/soft_button.dart';
import '../dart-maor/next-stage.dart'; // מנוע-מדף: השלב הבא
import '../dart-maor/stage-index.dart'; // שקע: אינדקס-שלב
import '../dart-maor/ayin-stages.dart'; // דאטה-מדף: סדר-השלבים

/// דאטה-הגרעין של AyinCase — נגזר, לא מומצא; המצבים בסדר-ההצהרה של domain.ts · ציבורי: מסכי-הישות (retarget) מייבאים ומשתמשים (G6c)
class AyinCaseCore {
  static const term = 'AyinCase';
  static const states = <String>['new', 'lead', 'eyes', 'answer', 'done'];
  static String? next(String s) => nextStage(s, stageIndex, ayinStages);
  static const relations = <List<String>>[];
  static const rules = <List<String>>[['required', 'stage', ''], ['required', 'note', ''], ['required', 'answeredNote', ''], ['required', 'answerPushed', ''], ['required', 'nextTalk', ''], ['required', 'nextTalkTime', ''], ['required', 'lastTouch', ''], ['enum', 'stage', 'new|lead|eyes|answer|done']];
  static const channels = <List<String>>[];
  static const events = <List<String>>[];
}

class AyinCaseCoreScreen extends StatefulWidget {
  const AyinCaseCoreScreen({super.key});
  @override
  State<AyinCaseCoreScreen> createState() => AyinCaseCoreScreenState();
}

class AyinCaseCoreScreenState extends State<AyinCaseCoreScreen> {
  String _state = AyinCaseCore.states.first;
  @override
  Widget build(BuildContext context) {
    final next = AyinCaseCore.next(_state);
    return DsScaffold(
      title: '🧠 ${AyinCaseCore.term} · גרעין',
      subtitle: '${AyinCaseCore.states.length} מצבים · ${AyinCaseCore.relations.length} יחסים · ${AyinCaseCore.rules.length} חוקים · ${AyinCaseCore.channels.length} ערוצים',
      icon: '🧠',
      children: [
        DsSection(title: 'מחזור-חיים · stage', children: [
          Wrap(spacing: 6, runSpacing: 6, children: [for (final s in AyinCaseCore.states) StatusChip(label: s, tone: s == _state ? 1 : 0)]),
          AlertBanner(message: next == null ? 'מצב-סופי: $_state' : 'הבא אחרי $_state: $next', tone: next == null ? 2 : 0, glyph: '➡️'),
          SoftButton(label: 'קדם מצב', onTap: next == null ? null : () => setState(() => _state = next)),
        ]),
        DsSection(title: 'יחסים', children: [const AlertBanner(message: 'אין שדות-יחס בסכמה', tone: 0)]),
        DsSection(title: 'חוקים', children: [DsTable(labels: const ['סוג', 'שדה', 'פרטים'], rows: AyinCaseCore.rules)]),
        DsSection(title: 'אירועי-מחזור-חיים', children: [const AlertBanner(message: 'אין שדות-תאריך של מחזור-חיים', tone: 0)]),
        DsSection(title: 'ערוצים', children: [const AlertBanner(message: 'אין שדות-ערוץ', tone: 0)]),
        const AlertBanner(message: 'policy-config (שבת/כשרות/הרשאות) = הכרעת-בעלים — שקע מוצהר, ריק', tone: 3, glyph: '🔒'),
      ],
    );
  }
}
