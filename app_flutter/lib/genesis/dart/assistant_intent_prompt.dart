// ⚛️ אטום-Dart (דרגת-חוזה) · assistantIntentPrompt — מנוע-נקי (הכרעת-בעלים "אפס-דאטה במנוע").
// תפקיד: בונה את מחרוזת-ה-prompt לסיווג-כוונת-משתמש (BuildSmart) — שיחה-אחרונה + קטגוריות + ערכות.
// מוצא: buildsmart/app_flutter/lib/logic/assistant_intent.dart:124-169 (חוק-4 — נוסח verbatim).
// אחים שהוטבעו/סוקטו (חוק-3, כדפוס branch_label):
//   • kIntentHistoryWindow (const-מודול) ⇒ שקע `historyWindow`.
//   • assistantCategories() ⇒ שקע `categories` (List<String>).
//   • kSmartProducts ⇒ שקע `recipes` (רשומות key/name); בניית שורות ה-'key=name' inline (מנגנון).
//   • promptSafeText(text, maxLen:) ⇒ שקע-פונקציה `promptSafeText`.
//   • טיפוס-השכן IntentTurn (.user/.text) ⇒ הוטבע inline.
// ♻️ **נוסח-ה-prompt (15 מקטעי-קופי) חולץ לדאטה מוזרקת `copy`** (dart-data/assistant-prompt-copy.dart).
//    המנוע=הרכבת-buffer בלבד (סדר · חלון-שיחה · לולאות). מקטעי-הקופי מושחלים דרך `copy['key']!`.
//    התנהגות זהה-ביט כשמזריקים את הנוסח-המקורי. **נשמר במנוע (מנגנון):** `maxLen: 600` = קבוע-קיצוץ-בטיחות.
// טוהר: dart:core בלבד, אפס import.

/// prompt-הסיווג verbatim assistant_intent.dart:124-169: חלון-שיחה אחרון (עד [historyWindow]),
/// רשימת-הקטגוריות ורשימת-הערכות (key=name), עטופים בהוראות ה-JSON-שורה-אחת (מ-[copy]).
String assistantIntentPrompt(
  List<IntentTurn> history,
  String userText, {
  required int historyWindow,
  required List<String> categories,
  required List<({String key, String name})> recipes,
  required String Function(String text, {required int maxLen}) promptSafeText,
  required Map<String, String> copy,
}) {
  final recent = history.length > historyWindow
      ? history.sublist(history.length - historyWindow)
      : history;
  final cats = categories.join('\n');
  final recipeLines =
      [for (final r in recipes) '${r.key}=${r.name}'].join('\n');
  final b = StringBuffer();
  if (recent.isNotEmpty) {
    b.writeln(copy['historyHeader']!);
    for (final m in recent) {
      b.writeln(
          '${m.user ? copy['roleUser']! : copy['roleAsst']!}: ${promptSafeText(m.text, maxLen: 600)}');
    }
    b.writeln();
  }
  b.writeln(
      '${copy['userWrotePre']!}${promptSafeText(userText, maxLen: 600)}${copy['userWroteSuf']!}');
  b.writeln(copy['chooseLine']!);
  b.writeln(copy['optAnswer']!);
  b.writeln(copy['optFindProduct']!);
  b.writeln(copy['optSummarize']!);
  b.writeln(copy['optBudget']!);
  b.writeln(copy['optAddToCart']!);
  b.writeln();
  b.writeln(copy['catsHeader']!);
  b.writeln(cats);
  b.writeln();
  b.writeln(copy['recipesHeader']!);
  b.writeln(recipeLines);
  b.writeln();
  b.writeln(copy['formatLine']!);
  b.writeln(copy['fallbackLine']!);
  return b.toString();
}

// — טיפוס-השכן מוטבע (השדות הנקראים ע"י האטום בלבד) —
class IntentTurn {
  const IntentTurn({required this.user, required this.text});
  final bool user;
  final String text;
}
