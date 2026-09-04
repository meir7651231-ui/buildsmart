// 🧠 TzBoxCoreScreen — גרעין-מהסכמה (GENMAX·G6b · הכרעה-24) · מחולל דטרמיניסטי: core-dart.mjs (מקור: core-registry.json ⇐ schema-fields + enum-values + entity-terms)
//   workflow: status:TzBoxStatus ⇒ home→office→lost→retired · מעבר = סדר-הצהרה (הצבה מוצהרת, חוק-7) · יחסים 2 · חוקים 12 · ערוצים 0 · policy = הכרעת-בעלים (שקע ריק)
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import '../dart-ui-bs/premium/feedback/status_chip.dart';
import '../dart-ui-bs/premium/feedback/alert_banner.dart';
import '../dart-ui-bs/premium/actions/soft_button.dart';

/// דאטה-הגרעין של TzBox — נגזר, לא מומצא; המצבים בסדר-ההצהרה של domain.ts · ציבורי: מסכי-הישות (retarget) מייבאים ומשתמשים (G6c)
class TzBoxCore {
  static const term = 'קופה';
  static const states = <String>['home', 'office', 'lost', 'retired'];
  static String? next(String s) { final i = states.indexOf(s); return i < 0 || i + 1 >= states.length ? null : states[i + 1]; } // הצבה: סדר-ההצהרה (אין אטום-מעבר לישות זו) — חוק-7
  static const relations = <List<String>>[['coordinatorId', 'TzCoordinator', 'suffix+ns'], ['famId', 'Family', 'prefix(shortest)']];
  static const rules = <List<String>>[['required', 'num', ''], ['required', 'coordinatorId', ''], ['required', 'famId', ''], ['required', 'holderKind', ''], ['required', 'since', ''], ['required', 'status', ''], ['required', 'notes', ''], ['enum', 'holderKind', 'donor|supported|'], ['enum', 'status', 'home|office|lost|retired'], ['ref', 'coordinatorId', 'TzCoordinator'], ['ref', 'famId', 'Family'], ['unique', 'id', '']];
  static const channels = <List<String>>[];
  static const events = <List<String>>[];
}

class TzBoxCoreScreen extends StatefulWidget {
  const TzBoxCoreScreen({super.key});
  @override
  State<TzBoxCoreScreen> createState() => TzBoxCoreScreenState();
}

class TzBoxCoreScreenState extends State<TzBoxCoreScreen> {
  String _state = TzBoxCore.states.first;
  @override
  Widget build(BuildContext context) {
    final next = TzBoxCore.next(_state);
    return DsScaffold(
      title: '🧠 ${TzBoxCore.term} · גרעין',
      subtitle: '${TzBoxCore.states.length} מצבים · ${TzBoxCore.relations.length} יחסים · ${TzBoxCore.rules.length} חוקים · ${TzBoxCore.channels.length} ערוצים',
      icon: '🧠',
      children: [
        DsSection(title: 'מחזור-חיים · status', children: [
          Wrap(spacing: 6, runSpacing: 6, children: [for (final s in TzBoxCore.states) StatusChip(label: s, tone: s == _state ? 1 : 0)]),
          AlertBanner(message: next == null ? 'מצב-סופי: $_state' : 'הבא אחרי $_state: $next', tone: next == null ? 2 : 0, glyph: '➡️'),
          SoftButton(label: 'קדם מצב', onTap: next == null ? null : () => setState(() => _state = next)),
        ]),
        DsSection(title: 'יחסים', children: [DsTable(labels: const ['שדה', 'יעד', 'איך'], rows: TzBoxCore.relations)]),
        DsSection(title: 'חוקים', children: [DsTable(labels: const ['סוג', 'שדה', 'פרטים'], rows: TzBoxCore.rules)]),
        DsSection(title: 'אירועי-מחזור-חיים', children: [const AlertBanner(message: 'אין שדות-תאריך של מחזור-חיים', tone: 0)]),
        DsSection(title: 'ערוצים', children: [const AlertBanner(message: 'אין שדות-ערוץ', tone: 0)]),
        const AlertBanner(message: 'policy-config (שבת/כשרות/הרשאות) = הכרעת-בעלים — שקע מוצהר, ריק', tone: 3, glyph: '🔒'),
      ],
    );
  }
}
