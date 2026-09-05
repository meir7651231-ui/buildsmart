// ⚛️ אטום-Dart (דרגת-חוזה) · broadcastRow
// תפקיד: מסכם קבוצת-ops לשורת-diff אחת: כולן מאותו-סוג ⇒ '$N שינויים' (§4); אחרת קיבוץ-לפי-סוג
//        בסדר-ה-enum, '$emoji $count $plural' מופרד ב-' · ' (§9). styleAllColor מחדד את התווית
//        רק כשכל SetStyle הם שינוי-צבע (op.style?.colorToken!=null).
// מוצא: buildsmart/app_flutter/lib/logic/studio/diff_preview.dart:112-139 (‏_broadcastRow; פרטי; חוק-4).
// אחים שהוטבעו/סוקטו (חוק-3):
//   • _kindEmoji(kind) / _kindPlural(kind, allColor) (עוזרים-פרטיים, גופם לא-בטיוטה) ⇒ שקעים.
//   • ConfigOpKind (enum) ⇒ הוטבע inline; **סדר-האיברים הוסק מסדר-ה-case ב-axis_of** (edit_intent.dart:
//     text→emoji→hidden→order→style→action, אותו מודול-סטודיו) — קובע את סדר-הפרגמנטים.
//   • ConfigOp (בסיס עם .kind) + SetStyle (.style?.colorToken) + DiffLine ⇒ הוטבעו inline.
// טוהר: dart:core בלבד.

/// verbatim diff_preview.dart:112-139 (kindEmoji/kindPlural כשקעים; enum/טיפוסים מוטבעים).
DiffLine broadcastRow(
  List<ConfigOp> ops, {required String Function(String) term, 
  required String Function(ConfigOpKind kind) kindEmoji,
  required String Function(ConfigOpKind kind, bool allColor) kindPlural,
}) {
  final counts = <ConfigOpKind, int>{};
  var styleAllColor = true;
  for (final op in ops) {
    final kind = op.kind;
    counts[kind] = (counts[kind] ?? 0) + 1;
    if (kind == ConfigOpKind.setStyle &&
        !(op is SetStyle && op.style?.colorToken != null)) {
      styleAllColor = false;
    }
  }
  // §4 — קבוצה מאותו-סוג מתמוטטת לסכום פשוט.
  if (counts.length == 1) {
    return DiffLine('${ops.length}${term('shynvyym')}');
  }
  // §9 — קיבוץ-לפי-סוג בסדר-ה-enum היציב.
  final frags = <String>[
    for (final kind in ConfigOpKind.values)
      if (counts[kind] != null)
        '${kindEmoji(kind)} ${counts[kind]} ${kindPlural(kind, styleAllColor)}',
  ];
  return DiffLine(frags.join(' · '));
}

// — enum מוטבע (סדר מוסק מ-axis_of; ראה כותרת) —
enum ConfigOpKind { setText, setEmoji, setHidden, setOrder, setStyle, setAction }

// — טיפוסי-שכן מוטבעים —
class DiffLine {
  const DiffLine(this.text);
  final String text;
}

class OpStyle {
  const OpStyle({this.colorToken});
  final String? colorToken;
}

sealed class ConfigOp {
  const ConfigOp();
  ConfigOpKind get kind;
}

class SetText extends ConfigOp {
  const SetText();
  @override
  ConfigOpKind get kind => ConfigOpKind.setText;
}

class SetEmoji extends ConfigOp {
  const SetEmoji();
  @override
  ConfigOpKind get kind => ConfigOpKind.setEmoji;
}

class SetHidden extends ConfigOp {
  const SetHidden();
  @override
  ConfigOpKind get kind => ConfigOpKind.setHidden;
}

class SetOrder extends ConfigOp {
  const SetOrder();
  @override
  ConfigOpKind get kind => ConfigOpKind.setOrder;
}

class SetStyle extends ConfigOp {
  const SetStyle({this.style});
  final OpStyle? style;
  @override
  ConfigOpKind get kind => ConfigOpKind.setStyle;
}

class SetAction extends ConfigOp {
  const SetAction();
  @override
  ConfigOpKind get kind => ConfigOpKind.setAction;
}
