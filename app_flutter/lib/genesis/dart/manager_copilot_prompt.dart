// ⚛️ אטום-Dart (דרגת-חוזה) · managerCopilotPrompt
// תפקיד: בונה את מחרוזת-ה-prompt ל"קופיילוט-המנהל" — מצב-העסק (context) + שאלת-הבעלים המחוטאת.
// מוצא: buildsmart/app_flutter/lib/logic/manager_copilot.dart:101-108 (‏managerCopilotPrompt; חוק-4).
// אחים: `promptSafeText(question, maxLen: 400)` (קריאה-לשכן) קופלה לשקע-פונקציה `promptSafeText`
//       (חוק-3). ה-const 400 (‏maxLen) הוטבע verbatim בקריאה.
// טוהר: dart:core בלבד; אפס import, אפס state.

/// מחרוזת prompt: מצב-אמת [context] + [question] מחוטאת (‏promptSafeText, maxLen 400).
/// verbatim manager_copilot.dart:101-108 (promptSafeText ⇒ שקע).
String managerCopilotPrompt(
  String context,
  String question, {required String Function(String) term, 
  required String Function(String text, {int maxLen}) promptSafeText,
}) {
  final q = promptSafeText(question, maxLen: 400);
  return '${term('xi_mtsbhask-kat-ntvnyamt')}$context\n\n'
      '${term('xi_shalthbalym')}$q"\n'
      '${term('xi_anh-babryt-ak-vrk-lpy-hntvnym-shlmalh')}';
}
