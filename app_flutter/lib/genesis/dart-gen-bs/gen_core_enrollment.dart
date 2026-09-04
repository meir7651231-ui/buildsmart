// 🧠 EnrollmentCoreScreen — גרעין-מהסכמה (GENMAX·G6b · הכרעה-24) · מחולל דטרמיניסטי: core-dart.mjs (מקור: core-registry.json ⇐ schema-fields + enum-values + entity-terms)
//   workflow: status:EnrollmentStatus ⇒ active→paused→ended→wait · מעבר = סדר-הצהרה (הצבה מוצהרת, חוק-7) · יחסים 4 · חוקים 22 · ערוצים 0 · policy = הכרעת-בעלים (שקע ריק)
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import '../dart-ui-bs/premium/feedback/status_chip.dart';
import '../dart-ui-bs/premium/feedback/alert_banner.dart';
import '../dart-ui-bs/premium/actions/soft_button.dart';

/// דאטה-הגרעין של Enrollment — נגזר, לא מומצא; המצבים בסדר-ההצהרה של domain.ts · ציבורי: מסכי-הישות (retarget) מייבאים ומשתמשים (G6c)
class EnrollmentCore {
  static const term = 'שיבוץ';
  static const states = <String>['active', 'paused', 'ended', 'wait'];
  static String? next(String s) { final i = states.indexOf(s); return i < 0 || i + 1 >= states.length ? null : states[i + 1]; } // הצבה: סדר-ההצהרה (אין אטום-מעבר לישות זו) — חוק-7
  static const relations = <List<String>>[['memberId', 'Member', 'name'], ['courseId', 'Course', 'name'], ['dueEventId', 'OrgEvent', 'suffix(Event)'], ['renewedToId', 'Enrollment', 'self?']];
  static const rules = <List<String>>[['required', 'memberId', ''], ['required', 'courseId', ''], ['required', 'plan', ''], ['required', 'purchased', ''], ['required', 'used', ''], ['required', 'group', ''], ['required', 'totalDue', ''], ['required', 'dueDate', ''], ['required', 'status', ''], ['required', 'note', ''], ['required', 'enrolledAt', ''], ['enum', 'plan', 'monthly|half_year|year|punch'], ['enum', 'status', 'active|paused|ended|wait'], ['enum', 'freqUnit', 'week|month'], ['enum', 'term', 'once|weekly|biweekly|monthly|months|half_year|year'], ['enum', 'tier', '|1|2|3'], ['enum', 'renew', 'yes|no|hold'], ['ref', 'memberId', 'Member'], ['ref', 'courseId', 'Course'], ['ref', 'dueEventId', 'OrgEvent'], ['ref', 'renewedToId', 'Enrollment'], ['unique', 'id', '']];
  static const channels = <List<String>>[];
  static const events = <List<String>>[['dueDate', 'due'], ['enrolledAt', 'enrolled'], ['endedAt', 'ended']];
}

class EnrollmentCoreScreen extends StatefulWidget {
  const EnrollmentCoreScreen({super.key});
  @override
  State<EnrollmentCoreScreen> createState() => EnrollmentCoreScreenState();
}

class EnrollmentCoreScreenState extends State<EnrollmentCoreScreen> {
  String _state = EnrollmentCore.states.first;
  @override
  Widget build(BuildContext context) {
    final next = EnrollmentCore.next(_state);
    return DsScaffold(
      title: '🧠 ${EnrollmentCore.term} · גרעין',
      subtitle: '${EnrollmentCore.states.length} מצבים · ${EnrollmentCore.relations.length} יחסים · ${EnrollmentCore.rules.length} חוקים · ${EnrollmentCore.channels.length} ערוצים',
      icon: '🧠',
      children: [
        DsSection(title: 'מחזור-חיים · status', children: [
          Wrap(spacing: 6, runSpacing: 6, children: [for (final s in EnrollmentCore.states) StatusChip(label: s, tone: s == _state ? 1 : 0)]),
          AlertBanner(message: next == null ? 'מצב-סופי: $_state' : 'הבא אחרי $_state: $next', tone: next == null ? 2 : 0, glyph: '➡️'),
          SoftButton(label: 'קדם מצב', onTap: next == null ? null : () => setState(() => _state = next)),
        ]),
        DsSection(title: 'יחסים', children: [DsTable(labels: const ['שדה', 'יעד', 'איך'], rows: EnrollmentCore.relations)]),
        DsSection(title: 'חוקים', children: [DsTable(labels: const ['סוג', 'שדה', 'פרטים'], rows: EnrollmentCore.rules)]),
        DsSection(title: 'אירועי-מחזור-חיים', children: [DsTable(labels: const ['שדה', 'אירוע'], rows: EnrollmentCore.events)]),
        DsSection(title: 'ערוצים', children: [const AlertBanner(message: 'אין שדות-ערוץ', tone: 0)]),
        const AlertBanner(message: 'policy-config (שבת/כשרות/הרשאות) = הכרעת-בעלים — שקע מוצהר, ריק', tone: 3, glyph: '🔒'),
      ],
    );
  }
}
