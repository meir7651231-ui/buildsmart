// Pins the grounding the LIVE "🤖 העוזר החכם" screen actually sends. The screen's
// `_send` calls `assistantIntentSystem` + `assistantIntentPrompt` (from
// logic/assistant_intent.dart) — the closed-set intent classifier. (The pre-agentic
// `assistantSystem`/`assistantTurnPrompt` were removed as dead after the agentic
// upgrade; this file used to assert on those, which the running model never saw —
// fixed here so the test guards the REAL prompt.) Pure — no gateway, no widget pump.
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/logic/assistant_intent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('assistantIntentSystem — the LIVE assistant grounding', () {
    test('bounds the domain to BuildSmart', () {
      expect(assistantIntentSystem, contains('BuildSmart'));
    });

    test('forbids inventing catalog specifics (anti-hallucination)', () {
      expect(assistantIntentSystem, contains('אל תמציא'),
          reason: 'the live system prompt must forbid invention');
    });

    test('is a closed-set classifier that returns strict JSON', () {
      expect(assistantIntentSystem, contains('רשימה סגורה'),
          reason: 'the action set is closed');
      expect(assistantIntentSystem, contains('JSON'),
          reason: 'one-line JSON is demanded');
    });
  });

  group('assistantIntentPrompt — what the screen actually folds + sends', () {
    test('includes the new message + prior turns, labelled', () {
      final p = assistantIntentPrompt(
          const [(user: true, text: 'שלום')], 'אני צריך ברז');
      expect(p, contains('אני צריך ברז'), reason: 'the new message is sent');
      expect(p, contains('שלום'), reason: 'prior turns give context');
      expect(p, contains(kCatalogProducts.first.categoryHe),
          reason: 'the closed category set is embedded for findProduct');
    });

    test('first message carries no history preamble', () {
      final p = assistantIntentPrompt(const [], 'שאלה ראשונה');
      expect(p, contains('שאלה ראשונה'));
      expect(p, isNot(contains('השיחה עד כה')),
          reason: 'no "conversation so far" block when there is none');
    });

    test('history is bounded to the window (prompt cannot grow unbounded)', () {
      final long = [
        for (var i = 0; i < 40; i++) (user: i.isEven, text: 'turn_$i'),
      ];
      final p = assistantIntentPrompt(long, 'now');
      expect(p, contains('turn_39'), reason: 'most-recent turns are kept');
      expect(p, isNot(contains('turn_0')),
          reason: 'oldest turns drop out of the bounded window');
    });
  });
}
