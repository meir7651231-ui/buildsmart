// Pins the agentic assistant's intent layer (#ai-assistant-agentic): the model
// names an action from a CLOSED set as one-line JSON; this pure layer parses +
// validates it, and DEGRADES anything untrustworthy to a plain `answer` — so a
// malformed or hallucinated reply can never trigger a wrong action. Pure — no
// gateway, no widget pump (mirrors describe_to_cart_test).
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/data/smart_tree.dart' show kSmartProducts;
import 'package:buildsmart/logic/assistant_intent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseAssistantIntent — closed-set + total safety', () {
    test('a valid read-only action parses', () {
      final i = parseAssistantIntent('{"action":"summarizeOrders","say":"הנה"}');
      expect(i.action, AssistantAction.summarizeOrders);
      expect(i.say, 'הנה');
    });

    test('findProduct with a REAL category stays findProduct (validated key)',
        () {
      final cat = kCatalogProducts.first.categoryHe;
      final i =
          parseAssistantIntent('{"action":"findProduct","key":"$cat","say":""}');
      expect(i.action, AssistantAction.findProduct);
      expect(i.key, cat, reason: 'the validated category is carried through');
    });

    test('findProduct with an INVENTED category downgrades to answer (G2)', () {
      final i = parseAssistantIntent(
          '{"action":"findProduct","key":"קטגוריה-מומצאת-שלא-קיימת","say":"x"}');
      expect(i.action, AssistantAction.answer,
          reason: 'a category outside the real set must NOT act');
    });

    test('an unknown action downgrades to answer (G1)', () {
      final i = parseAssistantIntent('{"action":"frobnicate","say":"hi"}');
      expect(i.action, AssistantAction.answer);
    });

    test('malformed / non-JSON / partial inputs ALL → answer, never throw (G3)',
        () {
      for (final raw in <String>[
        '',
        'just a plain hebrew answer שלום',
        '{"action":',
        'not json at all {oops',
        '{}',
        '{"key":"x"}',
      ]) {
        final i = parseAssistantIntent(raw);
        expect(i.action, AssistantAction.answer,
            reason: 'untrustworthy reply must degrade to answer: "$raw"');
      }
    });

    test('prose-wrapped JSON is still extracted (tolerant, like matchRecipe)',
        () {
      final i = parseAssistantIntent(
          'בטח! הנה: {"action":"checkBudget","say":"מציג"} זהו.');
      expect(i.action, AssistantAction.checkBudget);
    });
  });

  group('matchAssistantCategory — the closed catalog set', () {
    test('a real category resolves; junk → null', () {
      final cat = kCatalogProducts.first.categoryHe;
      expect(matchAssistantCategory(cat), cat);
      expect(matchAssistantCategory('זזזזז-לא-קטגוריה'), isNull);
    });
  });

  group('assistantIntentPrompt — grounds the closed sets', () {
    test('lists the action names, a real category, and the JSON shape', () {
      final p = assistantIntentPrompt(
          const [(user: true, text: 'שלום')], 'אני צריך ברז');
      expect(p, contains('אני צריך ברז'), reason: 'the new message is included');
      expect(p, contains('findProduct'));
      expect(p, contains('summarizeOrders'));
      expect(p, contains('checkBudget'));
      expect(p, contains(kCatalogProducts.first.categoryHe),
          reason: 'the closed category set is embedded for findProduct');
      expect(p, contains('addToCart'), reason: 'Phase 2 action is offered');
      expect(p, contains(kSmartProducts.first.key),
          reason: 'the closed recipe-key set is embedded for addToCart');
      expect(p, contains('"action"'), reason: 'demands the JSON shape');
    });

    test('history is bounded to the window', () {
      final long = [
        for (var i = 0; i < 40; i++) (user: i.isEven, text: 'turn_$i'),
      ];
      final p = assistantIntentPrompt(long, 'now');
      expect(p, contains('turn_39'));
      expect(p, isNot(contains('turn_0')),
          reason: 'oldest turns drop out of the bounded window');
    });
  });

  group('addToCart — the Phase 2 mutator is also closed-set-guarded', () {
    test('a REAL recipe key stays addToCart (validated)', () {
      final rk = kSmartProducts.first.key;
      final i =
          parseAssistantIntent('{"action":"addToCart","key":"$rk","say":""}');
      expect(i.action, AssistantAction.addToCart);
      expect(i.key, rk, reason: 'the validated recipe key is carried through');
    });

    test('an INVENTED recipe key downgrades to answer (no wrong add)', () {
      final i = parseAssistantIntent(
          '{"action":"addToCart","key":"ערכה-מומצאת-שלא-קיימת","say":"x"}');
      expect(i.action, AssistantAction.answer,
          reason: 'a recipe outside the real set must NOT add to the cart');
    });

    test('matchAssistantRecipeKey resolves a real key; junk → null', () {
      final rk = kSmartProducts.first.key;
      expect(matchAssistantRecipeKey(rk), rk);
      expect(matchAssistantRecipeKey('זזזזז-לא-ערכה'), isNull);
    });
  });
}
