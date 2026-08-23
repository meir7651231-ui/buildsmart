// Pins the AI adapter/gap-bridge explainer (#ai-adapter-explain): the prompt is
// GROUNDED on the part's REAL verified ends + material and forbids invention —
// Claude only reasons at the adapter-TYPE level. Also pins that every EndType has
// a Hebrew label (no end is ever unlabeled). Pure — no gateway, no widget pump.
import 'package:buildsmart/data/lipskey_verified_connections.dart'
    show EndType;
import 'package:buildsmart/screens/adapter_explain_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adapterExplainPrompt grounds the model in the REAL ends + material', () {
    final p = adapterExplainPrompt(
      product: 'מעבר PEX-נחושת',
      ends: const ['פרס PEX 16 מ"מ', 'פרס נחושת 15 מ"מ'],
      material: 'פליז',
    );
    expect(p, contains('מעבר PEX-נחושת'), reason: 'the part is named');
    expect(p, contains('פרס PEX 16 מ"מ'), reason: 'every real end is offered');
    expect(p, contains('פרס נחושת 15 מ"מ'));
    expect(p, contains('פליז'), reason: 'the real material is given');
    expect(p, contains('מתאם'), reason: 'asks which adapter type bridges the gap');
  });

  test('adapterExplainPrompt forbids invention (anti-hallucination)', () {
    final p = adapterExplainPrompt(
      product: 'X',
      ends: const ['תבריג חיצוני BSP 1/2'],
      material: 'M',
    );
    expect(p, contains('אל תמציא'),
        reason: 'no invented product names / SKUs / prices');
    expect(p, contains('ברמת סוג-המתאם בלבד'),
        reason: 'stays at adapter-TYPE level, never a specific product');
  });

  test('endTypeHe labels every EndType (no end goes unlabeled)', () {
    for (final t in EndType.values) {
      final label = endTypeHe(t);
      expect(label.trim(), isNotEmpty,
          reason: 'EndType.$t must have a Hebrew label for grounding');
    }
  });
}
