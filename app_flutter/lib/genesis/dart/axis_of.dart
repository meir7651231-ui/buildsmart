// ⚛️ אטום-Dart (דרגת-חוזה) · axisOf
// תפקיד: מיפוי סוג-ConfigOp לצַיר-העריכה שלו (text/emoji/hidden/order/style/action).
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_intent.dart:218-230 (‏_axisOf; פרטי-במקור; חוק-4).
// אחים: היררכיית ה-ConfigOp (SetText/SetEmoji/SetHidden/SetOrder/SetStyle/SetAction) הוטבעה
//       inline כ-sealed class עם 6 תת-מחלקות-סמן (השדות שלהן לא-רלוונטיים ל-switch לפי-טיפוס).
// טוהר: dart:core בלבד.

/// switch לפי-טיפוס על ConfigOp ⇒ מחרוזת-הציר. verbatim edit_intent.dart:218-230.
String axisOf(ConfigOp op) => switch (op) {
      SetText() => 'text',
      SetEmoji() => 'emoji',
      SetHidden() => 'hidden',
      SetOrder() => 'order',
      SetStyle() => 'style',
      SetAction() => 'action',
    };

// — טיפוסי-שכן מוטבעים (מחלקות-סמן; השדות המקוריים לא נדרשים ל-switch לפי-טיפוס) —
sealed class ConfigOp {
  const ConfigOp();
}

class SetText extends ConfigOp {
  const SetText();
}

class SetEmoji extends ConfigOp {
  const SetEmoji();
}

class SetHidden extends ConfigOp {
  const SetHidden();
}

class SetOrder extends ConfigOp {
  const SetOrder();
}

class SetStyle extends ConfigOp {
  const SetStyle();
}

class SetAction extends ConfigOp {
  const SetAction();
}
