// 🧠 CallEntryCoreScreen — גרעין-מהסכמה (GENMAX·G6b · הכרעה-24) · מחולל דטרמיניסטי: core-dart.mjs (מקור: core-registry.json ⇐ schema-fields + enum-values + entity-terms)
//   workflow: outcome:DialOutcome ⇒ donated→noanswer→refused→callback→done→skip · מעבר = סדר-הצהרה (הצבה מוצהרת, חוק-7) · יחסים 0 · חוקים 3 · ערוצים 0 · policy = הכרעת-בעלים (שקע ריק)
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import '../dart-ui-bs/premium/feedback/status_chip.dart';
import '../dart-ui-bs/premium/feedback/alert_banner.dart';
import '../dart-ui-bs/premium/actions/soft_button.dart';

/// דאטה-הגרעין של CallEntry — נגזר, לא מומצא; המצבים בסדר-ההצהרה של domain.ts
class _CallEntryCore {
  static const term = 'CallEntry';
  static const states = <String>['donated', 'noanswer', 'refused', 'callback', 'done', 'skip'];
  static String? next(String s) { final i = states.indexOf(s); return i < 0 || i + 1 >= states.length ? null : states[i + 1]; } // הצבה: סדר-ההצהרה (אין אטום-מעבר לישות זו) — חוק-7
  static const relations = <List<String>>[];
  static const rules = <List<String>>[['required', 'at', ''], ['required', 'outcome', ''], ['enum', 'outcome', 'donated|noanswer|refused|callback|done|skip']];
  static const channels = <List<String>>[];
  static const events = <List<String>>[['at', 'at']];
}

class CallEntryCoreScreen extends StatefulWidget {
  const CallEntryCoreScreen({super.key});
  @override
  State<CallEntryCoreScreen> createState() => _CallEntryCoreScreenState();
}

class _CallEntryCoreScreenState extends State<CallEntryCoreScreen> {
  String _state = _CallEntryCore.states.first;
  @override
  Widget build(BuildContext context) {
    final next = _CallEntryCore.next(_state);
    return DsScaffold(
      title: '🧠 ${_CallEntryCore.term} · גרעין',
      subtitle: '${_CallEntryCore.states.length} מצבים · ${_CallEntryCore.relations.length} יחסים · ${_CallEntryCore.rules.length} חוקים · ${_CallEntryCore.channels.length} ערוצים',
      icon: '🧠',
      children: [
        DsSection(title: 'מחזור-חיים · outcome', children: [
          Wrap(spacing: 6, runSpacing: 6, children: [for (final s in _CallEntryCore.states) StatusChip(label: s, tone: s == _state ? 1 : 0)]),
          AlertBanner(message: next == null ? 'מצב-סופי: $_state' : 'הבא אחרי $_state: $next', tone: next == null ? 2 : 0, glyph: '➡️'),
          SoftButton(label: 'קדם מצב', onTap: next == null ? null : () => setState(() => _state = next)),
        ]),
        DsSection(title: 'יחסים', children: [const AlertBanner(message: 'אין שדות-יחס בסכמה', tone: 0)]),
        DsSection(title: 'חוקים', children: [DsTable(labels: const ['סוג', 'שדה', 'פרטים'], rows: _CallEntryCore.rules)]),
        DsSection(title: 'אירועי-מחזור-חיים', children: [DsTable(labels: const ['שדה', 'אירוע'], rows: _CallEntryCore.events)]),
        DsSection(title: 'ערוצים', children: [const AlertBanner(message: 'אין שדות-ערוץ', tone: 0)]),
        const AlertBanner(message: 'policy-config (שבת/כשרות/הרשאות) = הכרעת-בעלים — שקע מוצהר, ריק', tone: 3, glyph: '🔒'),
      ],
    );
  }
}
