// 🧠 DeliveryCoreScreen — גרעין-מהסכמה (GENMAX·G6b · הכרעה-24) · מחולל דטרמיניסטי: core-dart.mjs (מקור: core-registry.json ⇐ schema-fields + enum-values + entity-terms)
//   workflow: status:DeliveryStatus ⇒ pickup→enroute→delivered · מעבר = אטום-מדף advance-status · יחסים 4 · חוקים 12 · ערוצים 0 · policy = הכרעת-בעלים (שקע ריק)
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_table.dart';
import '../dart-ui-bs/premium/feedback/status_chip.dart';
import '../dart-ui-bs/premium/feedback/alert_banner.dart';
import '../dart-ui-bs/premium/actions/soft_button.dart';
import '../dart-maor/advance-status.dart'; // מנוע-מדף: המצב הבא (קדימה בלבד)

/// דאטה-הגרעין של Delivery — נגזר, לא מומצא; המצבים בסדר-ההצהרה של domain.ts
class _DeliveryCore {
  static const term = 'Delivery';
  static const states = <String>['pickup', 'enroute', 'delivered'];
  static String? next(String s) { final n = advanceStatus(s); return n == s ? null : n; }
  static const relations = <List<String>>[['dayId', 'DistributionDay', 'suffix'], ['assignmentId', 'ShopAssignment', 'suffix'], ['volunteerId', 'Volunteer', 'name'], ['familyId', 'Family', 'name']];
  static const rules = <List<String>>[['required', 'dayId', ''], ['required', 'assignmentId', ''], ['required', 'volunteerId', ''], ['required', 'familyId', ''], ['required', 'status', ''], ['required', 'note', ''], ['enum', 'status', 'pickup|enroute|delivered'], ['ref', 'dayId', 'DistributionDay'], ['ref', 'assignmentId', 'ShopAssignment'], ['ref', 'volunteerId', 'Volunteer'], ['ref', 'familyId', 'Family'], ['unique', 'id', '']];
  static const channels = <List<String>>[];
  static const events = <List<String>>[['deliveredAt', 'delivered']];
}

class DeliveryCoreScreen extends StatefulWidget {
  const DeliveryCoreScreen({super.key});
  @override
  State<DeliveryCoreScreen> createState() => _DeliveryCoreScreenState();
}

class _DeliveryCoreScreenState extends State<DeliveryCoreScreen> {
  String _state = _DeliveryCore.states.first;
  @override
  Widget build(BuildContext context) {
    final next = _DeliveryCore.next(_state);
    return DsScaffold(
      title: '🧠 ${_DeliveryCore.term} · גרעין',
      subtitle: '${_DeliveryCore.states.length} מצבים · ${_DeliveryCore.relations.length} יחסים · ${_DeliveryCore.rules.length} חוקים · ${_DeliveryCore.channels.length} ערוצים',
      icon: '🧠',
      children: [
        DsSection(title: 'מחזור-חיים · status', children: [
          Wrap(spacing: 6, runSpacing: 6, children: [for (final s in _DeliveryCore.states) StatusChip(label: s, tone: s == _state ? 1 : 0)]),
          AlertBanner(message: next == null ? 'מצב-סופי: $_state' : 'הבא אחרי $_state: $next', tone: next == null ? 2 : 0, glyph: '➡️'),
          SoftButton(label: 'קדם מצב', onTap: next == null ? null : () => setState(() => _state = next)),
        ]),
        DsSection(title: 'יחסים', children: [DsTable(labels: const ['שדה', 'יעד', 'איך'], rows: _DeliveryCore.relations)]),
        DsSection(title: 'חוקים', children: [DsTable(labels: const ['סוג', 'שדה', 'פרטים'], rows: _DeliveryCore.rules)]),
        DsSection(title: 'אירועי-מחזור-חיים', children: [DsTable(labels: const ['שדה', 'אירוע'], rows: _DeliveryCore.events)]),
        DsSection(title: 'ערוצים', children: [const AlertBanner(message: 'אין שדות-ערוץ', tone: 0)]),
        const AlertBanner(message: 'policy-config (שבת/כשרות/הרשאות) = הכרעת-בעלים — שקע מוצהר, ריק', tone: 3, glyph: '🔒'),
      ],
    );
  }
}
