// ─────────────────────────────────────────────────────────────────────────────
// assistant_intent — the closed-set ACTION layer that turns "🤖 העוזר החכם" from
// chat-only into agentic (#ai-assistant-agentic, Phase 1: read-only actions). The
// model returns ONE line of strict JSON naming an action from a FIXED list; this
// pure layer parses + validates it. Mirrors the proven `matchRecipe`/`matchCategory`
// discipline: the model may only NAME a key from a closed set, and deterministic
// Dart decides what runs — it can never invent a product, price, or order.
//
// ANTI-HALLUCINATION: `parseAssistantIntent` is total — ANY malformed / partial /
// prose-wrapped reply, an unknown action, or a category outside the real catalog
// set DEGRADES to a plain `answer` (never throws, never acts). So a hallucinated
// reply becomes harmless conversation, never a wrong action. Read-only actions
// (findProduct / summarizeOrders / checkBudget) run over REAL engines in the
// screen; nothing here mutates state.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';

import 'package:buildsmart/data/catalog_source.dart'
    show resolvedCatalogProducts;
import 'package:buildsmart/data/smart_tree.dart' show kSmartProducts;
import 'package:buildsmart/logic/prompt_sanitize.dart';

/// The CLOSED action set the model must pick from. Read-only actions (Phase 1)
/// + `addToCart` (Phase 2 — the sole mutator, and even it only PROPOSES; the
/// cart write happens in the screen behind an explicit user confirmation tap).
enum AssistantAction {
  answer,
  findProduct,
  summarizeOrders,
  checkBudget,
  addToCart,
}

/// A validated intent: the action, an optional validated [key] (a real catalog
/// category for findProduct), and the conversational [say] shown to the user.
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

/// The distinct catalog categories — the CLOSED set `findProduct` may pick from
/// (same source as the finder: `resolvedCatalogProducts.categoryHe`).
List<String> assistantCategories() {
  // stage-3.1 — follows the ACTIVE catalog source (v2-aware).
  final set = <String>{for (final p in resolvedCatalogProducts) p.categoryHe};
  return set.toList()..sort();
}

/// Resolve a category reply to a REAL category — exact first, then contained.
/// Returns null when the reply names no real category (the closed-set guard).
String? matchAssistantCategory(String reply) {
  final r = reply.trim();
  if (r.isEmpty) return null;
  final cats = assistantCategories();
  for (final c in cats) {
    if (r == c) return c;
  }
  // Longest contained match (a category name may be a substring of a longer one);
  // first-match could grab a shorter prefix category on a wrapped reply.
  String? best;
  for (final c in cats) {
    if (r.contains(c) && (best == null || c.length > best.length)) {
      best = c;
    }
  }
  return best;
}

/// Resolve a recipe reply to a REAL `kSmartProducts` key — exact then contained.
/// Returns null when the reply names no real recipe (the closed-set guard for
/// `addToCart`; mirrors `matchRecipe`). The screen turns the key into the real
/// kit and only writes the cart on the user's confirm tap.
String? matchAssistantRecipeKey(String reply) {
  final r = reply.trim();
  if (r.isEmpty) return null;
  for (final p in kSmartProducts) {
    if (r == p.key) return p.key;
  }
  // Longest contained key — keys collide by prefix (faucet⊂kitchenFaucet,
  // basin⊂basinTrap), so first-match would propose the wrong kit on a wrapped reply.
  String? best;
  for (final p in kSmartProducts) {
    if (r.contains(p.key) && (best == null || p.key.length > best.length)) {
      best = p.key;
    }
  }
  return best;
}

AssistantAction? _actionFromString(String s) {
  switch (s) {
    case 'answer':
      return AssistantAction.answer;
    case 'findProduct':
      return AssistantAction.findProduct;
    case 'summarizeOrders':
      return AssistantAction.summarizeOrders;
    case 'checkBudget':
      return AssistantAction.checkBudget;
    case 'addToCart':
      return AssistantAction.addToCart;
    default:
      return null;
  }
}

/// A single prior turn, decoupled from the screen's widget model (a plain record).
typedef IntentTurn = ({bool user, String text});

const int kIntentHistoryWindow = 12;

/// The grounded prompt — folds the bounded history, lists the CLOSED action set +
/// the real category set, and demands ONE line of strict JSON. Mirrors how
/// `describeToCartPrompt`/`aiFinderPrompt` embed their closed sets.
String assistantIntentPrompt(List<IntentTurn> history, String userText) {
  final recent = history.length > kIntentHistoryWindow
      ? history.sublist(history.length - kIntentHistoryWindow)
      : history;
  final cats = assistantCategories().join('\n');
  final recipes =
      [for (final r in kSmartProducts) '${r.key}=${r.name}'].join('\n');
  final b = StringBuffer();
  if (recent.isNotEmpty) {
    b.writeln('השיחה עד כה:');
    for (final m in recent) {
      b.writeln(
          '${m.user ? "משתמש" : "עוזר"}: ${promptSafeText(m.text, maxLen: 600)}');
    }
    b.writeln();
  }
  b.writeln('המשתמש כתב: "${promptSafeText(userText, maxLen: 600)}".');
  b.writeln('בחר פעולה אחת מהרשימה הסגורה והחזר שורת-JSON אחת בלבד:');
  b.writeln('- "answer": ענה ישירות. שים את התשובה ב-say, key="".');
  b.writeln('- "findProduct": המשתמש מחפש מוצר. key = קטגוריה אחת מרשימת '
      'הקטגוריות למטה בדיוק (שורה אחת).');
  b.writeln('- "summarizeOrders": המשתמש שואל על ההזמנות/הרכש שלו.');
  b.writeln('- "checkBudget": המשתמש שואל על התקציב / כמה נשאר.');
  b.writeln('- "addToCart": המשתמש מבקש להוסיף ערכה לסל. key = מפתח-ערכה אחד '
      'מרשימת הערכות למטה בדיוק (החלק שלפני ה-=).');
  b.writeln();
  b.writeln('קטגוריות זמינות ל-findProduct:');
  b.writeln(cats);
  b.writeln();
  b.writeln('ערכות זמינות ל-addToCart (מפתח=שם):');
  b.writeln(recipes);
  b.writeln();
  b.writeln('החזר אך ורק שורת-JSON אחת בפורמט: '
      '{"action":"...","key":"...","say":"..."}');
  b.writeln('אם אף קטגוריה/ערכה לא מתאימה — השתמש ב-answer.');
  return b.toString();
}

const String assistantIntentSystem =
    'אתה מסווג בקשת-משתמש לפעולה אחת מתוך רשימה סגורה, ב-BuildSmart (רכש '
    'לאינסטלטורים). החזר אך ורק שורת-JSON אחת: action מהרשימה, key (קטגוריה '
    'מהרשימה או ""), ו-say בעברית. לעולם אל תמציא קטגוריה, מוצר, מחיר או מספר.';

/// Parse + VALIDATE the model reply into a trusted intent. TOTAL: any failure
/// (not JSON / missing or unknown action / category outside the real set) →
/// a plain `answer`. Never throws, never yields an un-validated action.
AssistantIntent parseAssistantIntent(String raw) {
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
    final action = _actionFromString(actionStr);
    if (action == null) {
      // Unknown action → fall back to conversation (carry say if any).
      return AssistantIntent.answer(say.isNotEmpty ? say : text);
    }
    if (action == AssistantAction.findProduct) {
      final cat = matchAssistantCategory(key); // closed-set validation
      if (cat == null) {
        return AssistantIntent.answer(
            say.isNotEmpty ? say : 'לא הבנתי איזה מוצר — נסה לתאר אחרת.');
      }
      return AssistantIntent(action: action, key: cat, say: say);
    }
    if (action == AssistantAction.addToCart) {
      final recipe = matchAssistantRecipeKey(key); // closed-set validation
      if (recipe == null) {
        return AssistantIntent.answer(
            say.isNotEmpty ? say : 'לא הבנתי איזו ערכה — נסה לתאר אחרת.');
      }
      return AssistantIntent(action: action, key: recipe, say: say);
    }
    // Read-only, no key needed.
    return AssistantIntent(action: action, say: say);
  } catch (_) {
    return AssistantIntent.answer(text); // malformed JSON → plain answer
  }
}
