// Pins the grounded AI assistant (#ai-assistant). A conversational assistant is
// open by nature, so the SAFETY lives in the system prompt + the prompt builder:
// domain-bounded, invention-forbidden, routes catalog actions to the real tools,
// and folds a BOUNDED history. Pure — no gateway, no widget pump.
import 'package:buildsmart/screens/ai_assistant_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('assistantSystem — the grounding lives here', () {
    test('bounds the domain to BuildSmart / the trade', () {
      expect(assistantSystem, contains('BuildSmart'));
      expect(assistantSystem, contains('אינסטלטור'));
    });

    test('forbids inventing catalog specifics (anti-hallucination)', () {
      expect(assistantSystem, contains('אל תמציא'),
          reason: 'must not invent product names/SKUs/prices');
      expect(assistantSystem, contains('מק"ט'));
      expect(assistantSystem, contains('מחיר'));
    });

    test('routes catalog actions to the REAL grounded tools', () {
      // Instead of fabricating a cart/price, it points at the real features.
      expect(assistantSystem, contains('תאר עבודה → סל'));
      expect(assistantSystem, contains('חיפוש חכם'));
    });
  });

  group('assistantTurnPrompt — bounded, contextual history', () {
    test('includes the new message + prior turns, labelled', () {
      final p = assistantTurnPrompt(
        const [
          AssistantTurn(user: true, text: 'שלום'),
          AssistantTurn(user: false, text: 'היי, איך אפשר לעזור?'),
        ],
        'אני צריך ברז',
      );
      expect(p, contains('אני צריך ברז'), reason: 'the new message is included');
      expect(p, contains('שלום'), reason: 'prior turns give context');
      expect(p, contains('משתמש:'));
      expect(p, contains('עוזר:'));
    });

    test('first message carries no history preamble', () {
      final p = assistantTurnPrompt(const [], 'שאלה ראשונה');
      expect(p, contains('שאלה ראשונה'));
      expect(p, isNot(contains('השיחה עד כה')),
          reason: 'no "conversation so far" block when there is none');
    });

    test('history is capped to the window (prompt cannot grow unbounded)', () {
      final long = [
        for (var i = 0; i < 40; i++)
          AssistantTurn(user: i.isEven, text: 'turn_$i'),
      ];
      final p = assistantTurnPrompt(long, 'now');
      expect(p, contains('turn_39'), reason: 'most-recent turns are kept');
      expect(p, isNot(contains('turn_0')),
          reason: 'oldest turns drop out of the bounded window');
      expect(p, contains('now'));
    });
  });
}
