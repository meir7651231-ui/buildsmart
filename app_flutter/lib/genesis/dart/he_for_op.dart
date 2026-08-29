// ⚛️ אטום-Dart (דרגת-חוזה) · heForOp
// תפקיד: שורת-התצוגה-העברית לאופ-עריכה יחיד בתצוגת-ה-diff (שורה-פר-אופ בדיף קטן).
// מוצא: buildsmart/app_flutter/lib/logic/studio/diff_preview.dart:165-178 (‏_heForOp; פרטי; חוק-4).
// אחים-שסוקטו (חוק-3):
//   • actionHe(kind) (שכן מ-action_catalog.dart:254; קיים כאטום action_he) ⇒ שקע.
//   • _styleHe(op.id, style, registry) (שכן פרטי; קיים כאטום style_he) ⇒ שקע `styleHe` —
//     ה-registry המקורי נצרך אך ורק בתוכו, ולכן נבלע בשקע (האטום לא מכיר RegistryView).
// טיפוסים-שהוטבעו (מינימום-verbatim, config_store.dart:46-159 + config_node.dart:61,157):
//   ConfigOp (sealed, id) + 6 וריאנטים · OpStyle{colorToken} (=CfgStyle מצומצם, תקדים
//   broadcast_row) · OpAction{kind} (=CfgAction מצומצם — :177 קורא רק .kind).
// טוהר: dart:core בלבד.
//
// קלט:  op       — האופ (אחד מ-6 הווריאנטים החתומים).
//       actionHe — שקע: סוג-פעולה ⇒ עברית-מהקטלוג (null = לא-בקטלוג ⇒ דרדור-לסוג).
//       styleHe  — שקע: (id, style) ⇒ שורת-עיצוב-עברית (עוטף את הרישום).
// פלט:  שורה עברית לא-ריקה; SetAction עם פעולה — בלי id בשורה (verbatim מהמקור).

/// verbatim diff_preview.dart:165-178 (‏actionHe/_styleHe כשקעים; טיפוסים מוטבעים).
String heForOp(
  ConfigOp op, {required String Function(String) term, 
  required String? Function(String kind) actionHe,
  required String Function(String id, OpStyle? style) styleHe,
}) =>
    switch (op) {
      SetText() => '${term('shynvy-tkst')}${op.id}',
      SetEmoji() => '${term('shynvy-amvgy')}${op.id}',
      SetHidden(:final hidden) => hidden == null
          ? '${term('shynvy-nravt')}${op.id}'
          : (hidden ? '${term('hstrh')}${op.id}' : '${term('htsgh')}${op.id}'),
      SetOrder(:final order) => order == null
          ? '${term('shynvy-sdr')}${op.id}'
          : '${term('shynvy-sdr')}${op.id} ← $order', // before→after: the new position
      SetStyle(:final style) => styleHe(op.id, style),
      SetAction(:final action) => action == null
          ? '${term('nykvy-pavlh')}${op.id}'
          : '${term('pavlh')}${actionHe(action.kind) ?? action.kind}',
    };

// — טיפוסי-שכן מוטבעים (מינימום-verbatim) —

/// CfgStyle מצומצם לשדה-הנצרך במורד (colorToken) — תקדים broadcast_row.
class OpStyle {
  const OpStyle({this.colorToken});
  final String? colorToken;
}

/// CfgAction מצומצם לשדה-הנצרך (kind) — config_node.dart:157.
class OpAction {
  const OpAction(this.kind);
  final String kind;
}

/// המשפחה החתומה — config_store.dart:46-159, מצומצמת לשדות ש-heForOp קורא.
sealed class ConfigOp {
  const ConfigOp(this.id);
  final String id;
}

final class SetText extends ConfigOp {
  const SetText(super.id);
}

final class SetEmoji extends ConfigOp {
  const SetEmoji(super.id);
}

final class SetHidden extends ConfigOp {
  const SetHidden(super.id, this.hidden);
  final bool? hidden;
}

final class SetOrder extends ConfigOp {
  const SetOrder(super.id, this.order);
  final int? order;
}

final class SetStyle extends ConfigOp {
  const SetStyle(super.id, this.style);
  final OpStyle? style;
}

final class SetAction extends ConfigOp {
  const SetAction(super.id, this.action);
  final OpAction? action;
}
