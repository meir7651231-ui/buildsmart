// 🧠 ShopAssignmentCoreScreen — גרעין-מהסכמה (GENMAX·G6b · הכרעה-24) · מחולל דטרמיניסטי: core-dart.mjs (מקור: core-registry.json ⇐ schema-fields + enum-values + entity-terms)
//   workflow: status:ShopAssignmentStatus ⇒ active→done→stopped · מעבר = סדר-הצהרה (הצבה מוצהרת, חוק-7) · יחסים 3 · חוקים 11 · ערוצים 0 · policy = הכרעת-בעלים (שקע ריק)
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import '../dart-ui-bs/premium/feedback/status_chip.dart';
import '../dart-ui-bs/premium/feedback/alert_banner.dart';
import '../dart-ui-bs/premium/actions/soft_button.dart';

/// דאטה-הגרעין של ShopAssignment — נגזר, לא מומצא; המצבים בסדר-ההצהרה של domain.ts · ציבורי: מסכי-הישות (retarget) מייבאים ומשתמשים (G6c)
class ShopAssignmentCore {
  static const term = 'שיוך';
  static const states = <String>['active', 'done', 'stopped'];
  static String? next(String s) { final i = states.indexOf(s); return i < 0 || i + 1 >= states.length ? null : states[i + 1]; } // הצבה: סדר-ההצהרה (אין אטום-מעבר לישות זו) — חוק-7
  static const relations = <List<String>>[['productId', 'ShopProduct', 'suffix+ns'], ['famId', 'Family', 'prefix(shortest)'], ['memberId', 'Member', 'name']];
  static const rules = <List<String>>[['required', 'productId', ''], ['required', 'famId', ''], ['required', 'memberId', ''], ['required', 'since', ''], ['required', 'status', ''], ['required', 'notes', ''], ['enum', 'status', 'active|done|stopped'], ['ref', 'productId', 'ShopProduct'], ['ref', 'famId', 'Family'], ['ref', 'memberId', 'Member'], ['unique', 'id', '']];
  static const channels = <List<String>>[];
  static const events = <List<String>>[];
}

class ShopAssignmentCoreScreen extends StatefulWidget {
  const ShopAssignmentCoreScreen({super.key});
  @override
  State<ShopAssignmentCoreScreen> createState() => ShopAssignmentCoreScreenState();
}

class ShopAssignmentCoreScreenState extends State<ShopAssignmentCoreScreen> {
  String _state = ShopAssignmentCore.states.first;
  @override
  Widget build(BuildContext context) {
    final next = ShopAssignmentCore.next(_state);
    return DsScaffold(
      title: '🧠 ${ShopAssignmentCore.term} · גרעין',
      subtitle: '${ShopAssignmentCore.states.length} מצבים · ${ShopAssignmentCore.relations.length} יחסים · ${ShopAssignmentCore.rules.length} חוקים · ${ShopAssignmentCore.channels.length} ערוצים',
      icon: '🧠',
      children: [
        DsSection(title: 'מחזור-חיים · status', children: [
          Wrap(spacing: 6, runSpacing: 6, children: [for (final s in ShopAssignmentCore.states) StatusChip(label: s, tone: s == _state ? 1 : 0)]),
          AlertBanner(message: next == null ? 'מצב-סופי: $_state' : 'הבא אחרי $_state: $next', tone: next == null ? 2 : 0, glyph: '➡️'),
          SoftButton(label: 'קדם מצב', onTap: next == null ? null : () => setState(() => _state = next)),
        ]),
        DsSection(title: 'יחסים', children: [DsTable(labels: const ['שדה', 'יעד', 'איך'], rows: ShopAssignmentCore.relations)]),
        DsSection(title: 'חוקים', children: [DsTable(labels: const ['סוג', 'שדה', 'פרטים'], rows: ShopAssignmentCore.rules)]),
        DsSection(title: 'אירועי-מחזור-חיים', children: [const AlertBanner(message: 'אין שדות-תאריך של מחזור-חיים', tone: 0)]),
        DsSection(title: 'ערוצים', children: [const AlertBanner(message: 'אין שדות-ערוץ', tone: 0)]),
        const AlertBanner(message: 'policy-config (שבת/כשרות/הרשאות) = הכרעת-בעלים — שקע מוצהר, ריק', tone: 3, glyph: '🔒'),
      ],
    );
  }
}
