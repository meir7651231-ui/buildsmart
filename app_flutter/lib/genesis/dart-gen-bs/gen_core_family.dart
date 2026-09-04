// 🧠 FamilyCoreScreen — גרעין-מהסכמה (GENMAX·G6b · הכרעה-24) · מחולל דטרמיניסטי: core-dart.mjs (מקור: core-registry.json ⇐ schema-fields + enum-values + entity-terms)
//   workflow: status:FamilyStatus ⇒ active→pending→inactive · מעבר = סדר-הצהרה (הצבה מוצהרת, חוק-7) · יחסים 0 · חוקים 22 · ערוצים 3 · policy = הכרעת-בעלים (שקע ריק)
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import '../dart-ui-bs/premium/feedback/status_chip.dart';
import '../dart-ui-bs/premium/feedback/alert_banner.dart';
import '../dart-ui-bs/premium/actions/soft_button.dart';

/// דאטה-הגרעין של Family — נגזר, לא מומצא; המצבים בסדר-ההצהרה של domain.ts
class _FamilyCore {
  static const term = 'משפחה';
  static const states = <String>['active', 'pending', 'inactive'];
  static String? next(String s) { final i = states.indexOf(s); return i < 0 || i + 1 >= states.length ? null : states[i + 1]; } // הצבה: סדר-ההצהרה (אין אטום-מעבר לישות זו) — חוק-7
  static const relations = <List<String>>[];
  static const rules = <List<String>>[['required', 'name', ''], ['required', 'father', ''], ['required', 'fatherId', ''], ['required', 'mother', ''], ['required', 'motherId', ''], ['required', 'phone', ''], ['required', 'phone2', ''], ['required', 'email', ''], ['required', 'city', ''], ['required', 'address', ''], ['required', 'community', ''], ['required', 'maritalStatus', ''], ['required', 'language', ''], ['required', 'tzedaka', ''], ['required', 'fullSefach', ''], ['required', 'discount', ''], ['required', 'status', ''], ['required', 'notes', ''], ['required', 'cred', ''], ['required', 'createdAt', ''], ['enum', 'status', 'active|pending|inactive'], ['unique', 'id', '']];
  static const channels = <List<String>>[['phone', 'phone'], ['phone2', 'phone'], ['email', 'email']];
  static const events = <List<String>>[['createdAt', 'created']];
}

class FamilyCoreScreen extends StatefulWidget {
  const FamilyCoreScreen({super.key});
  @override
  State<FamilyCoreScreen> createState() => _FamilyCoreScreenState();
}

class _FamilyCoreScreenState extends State<FamilyCoreScreen> {
  String _state = _FamilyCore.states.first;
  @override
  Widget build(BuildContext context) {
    final next = _FamilyCore.next(_state);
    return DsScaffold(
      title: '🧠 ${_FamilyCore.term} · גרעין',
      subtitle: '${_FamilyCore.states.length} מצבים · ${_FamilyCore.relations.length} יחסים · ${_FamilyCore.rules.length} חוקים · ${_FamilyCore.channels.length} ערוצים',
      icon: '🧠',
      children: [
        DsSection(title: 'מחזור-חיים · status', children: [
          Wrap(spacing: 6, runSpacing: 6, children: [for (final s in _FamilyCore.states) StatusChip(label: s, tone: s == _state ? 1 : 0)]),
          AlertBanner(message: next == null ? 'מצב-סופי: $_state' : 'הבא אחרי $_state: $next', tone: next == null ? 2 : 0, glyph: '➡️'),
          SoftButton(label: 'קדם מצב', onTap: next == null ? null : () => setState(() => _state = next)),
        ]),
        DsSection(title: 'יחסים', children: [const AlertBanner(message: 'אין שדות-יחס בסכמה', tone: 0)]),
        DsSection(title: 'חוקים', children: [DsTable(labels: const ['סוג', 'שדה', 'פרטים'], rows: _FamilyCore.rules)]),
        DsSection(title: 'אירועי-מחזור-חיים', children: [DsTable(labels: const ['שדה', 'אירוע'], rows: _FamilyCore.events)]),
        DsSection(title: 'ערוצים', children: [Wrap(spacing: 6, children: [for (final c in _FamilyCore.channels) StatusChip(label: '${c[0]} · ${c[1]}', tone: 1)])]),
        const AlertBanner(message: 'policy-config (שבת/כשרות/הרשאות) = הכרעת-בעלים — שקע מוצהר, ריק', tone: 3, glyph: '🔒'),
      ],
    );
  }
}
