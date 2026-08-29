// ⚛️ אטום-Dart (דרגת-חוזה) · parseAssistantIntent
// תפקיד: שער-האנטי-הזיה של העוזר — מפרש+מאמת תשובת-מודל לכוונה-אמינה; **טוטאלי**:
//        כל כשל (לא-JSON / פעולה-זרה / מפתח-מחוץ-לקבוצה / JSON-פגום) ⇒ answer רגיל.
//        לעולם לא זורק, לעולם לא פולט פעולה לא-מאומתת.
// מוצא: buildsmart/app_flutter/lib/logic/assistant_intent.dart:170-213 (‏parseAssistantIntent;
//        חוק-4 — התנהגות זהה, לא-משופרת. קובץ-המקור הוסר מ-working-tree של בנייה-חכמה;
//        אומת ביט-זהה מול git show claude/align-main — הטיוטה היא הקוד-החלוץ הקדוש).
// אחים ⇒ שקעים (חוק-1/חוק-3 — חוט לא מייבא חוט):
//   • `_actionFromString` (‏:99-123) ⇒ שקע `actionFromString` (האח action_from_string.dart).
//   • `matchAssistantCategory` (‏:60-81) ⇒ שקע `matchCategory` (האח match_assistant_category.dart).
//   • `matchAssistantRecipeKey` (‏:82-98) ⇒ שקע `matchRecipeKey` (האח match_assistant_recipe_key.dart).
// אחים שהוטבעו (טיפוס-שכן, הכרעה-2): ‏enum `AssistantAction` (‏:27-33; תקדים-הטבעה
//        ב-action_from_string.dart) + ‏class `AssistantIntent` כולל factory `.answer` (‏:37-48) — verbatim.
// טוהר: ‏dart:convert בלבד (ספריית-שפה/סטנדרט — מותר באטום); אפס import-אטום, אפס state.
//        מחרוזות-הנפילה העבריות = התנהגות-המקור verbatim (חוק-4), לא דאטה-קטלוג.

import 'dart:convert';

/// The CLOSED assistant action set (BuildSmart procurement copilot).
/// Verbatim assistant_intent.dart:27-33.
enum AssistantAction {
  answer,
  findProduct,
  summarizeOrders,
  checkBudget,
  addToCart,
}

/// A validated intent: the action, an optional validated [key] (a real catalog
/// category for findProduct), and the conversational [say] shown to the user.
/// Verbatim assistant_intent.dart:37-48.
class AssistantIntent {
  const AssistantIntent({required this.action, this.key = '', this.say = ''});

  final AssistantAction action;
  final String key;
  final String say;

  /// The safe fallback — used whenever the model reply can't be trusted as an
  /// action; the whole reply (or a honest line) becomes plain conversation.
  factory AssistantIntent.answer(String say) =>
      AssistantIntent(action: AssistantAction.answer, say: say);
}

/// Parse + VALIDATE the model reply into a trusted intent. TOTAL: any failure
/// (not JSON / missing or unknown action / category outside the real set) →
/// a plain `answer`. Never throws, never yields an un-validated action.
/// verbatim assistant_intent.dart:170-213; שלושת-האחים מוזרקים כשקעים.
AssistantIntent parseAssistantIntent(
  String raw, {required String Function(String) term, 
  required AssistantAction? Function(String) actionFromString,
  required String? Function(String) matchCategory,
  required String? Function(String) matchRecipeKey,
}) {
  final text = raw.trim();
  final start = text.indexOf('{');
  final end = text.lastIndexOf('}');
  if (start < 0 || end <= start) {
    return AssistantIntent.answer(text); // not JSON → treat as a plain answer
  }
  try {
    final decoded = jsonDecode(text.substring(start, end + 1));
    if (decoded is! Map) return AssistantIntent.answer(text);
    final actionStr =
        decoded['action'] is String ? (decoded['action'] as String).trim() : '';
    final key =
        decoded['key'] is String ? (decoded['key'] as String).trim() : '';
    final say =
        decoded['say'] is String ? (decoded['say'] as String).trim() : '';
    final action = actionFromString(actionStr);
    if (action == null) {
      // Unknown action → fall back to conversation (carry say if any).
      return AssistantIntent.answer(say.isNotEmpty ? say : text);
    }
    if (action == AssistantAction.findProduct) {
      final cat = matchCategory(key); // closed-set validation
      if (cat == null) {
        return AssistantIntent.answer(
            say.isNotEmpty ? say : term('la-hbnty-ayzh-mvtsr-nsh-ltar-achrt'));
      }
      return AssistantIntent(action: action, key: cat, say: say);
    }
    if (action == AssistantAction.addToCart) {
      final recipe = matchRecipeKey(key); // closed-set validation
      if (recipe == null) {
        return AssistantIntent.answer(
            say.isNotEmpty ? say : term('la-hbnty-ayzv-arkh-nsh-ltar-achrt'));
      }
      return AssistantIntent(action: action, key: recipe, say: say);
    }
    // Read-only, no key needed.
    return AssistantIntent(action: action, say: say);
  } catch (_) {
    return AssistantIntent.answer(text); // malformed JSON → plain answer
  }
}
