// Step 79 — `summarizeDiff`, the pure ops→Hebrew PREVIEW mapping.
//
// This suite pins `logic/studio/diff_preview.dart` against the plan's DoD (§5/§8):
//   • a SMALL diff → correct per-op Hebrew rows (a known op → its expected he);
//   • §6 — each per-op [DiffLine] CARRIES its original op (the tap-to-edit anchor);
//   • §4 broadcast — many same-kind ops collapse to ONE "N שינויים" row (not N);
//   • §9 — a multi-kind broadcast produces the grouped-by-kind summary;
//   • §4 blocked-count — a passed [SafetyVerdict] with K blocked → a "נחסמו K" row;
//   • §10 — a registry-constrained SetStyle(color) renders the precise before→after;
//   • ANTI-VACUOUS — a real op yields a non-empty he for EVERY kind;
//   • §8 RTL purity — the SOURCE carries no forced left-alignment / direction
//     override / LTR-injection (the reviewer greps too).
import 'dart:io';

import 'package:buildsmart/logic/studio/diff_preview.dart';
import 'package:buildsmart/logic/studio/edit_safety.dart'
    show BlockedEntry, SafetyVerdict;
import 'package:buildsmart/logic/studio/registry_view.dart'
    show FakeRegistryView, RegistryView;
import 'package:buildsmart/state/studio/config_node.dart'
    show CfgAction, CfgStyle;
import 'package:buildsmart/state/studio/config_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // An empty registry (no value constraints) — the §10 before→after is skipped.
  final bareReg = FakeRegistryView.of();

  // A registry that CONSTRAINS `btn.buy`'s color to a closed token subset, so the
  // §10 before→after fragment can vouch for the new value.
  final colorReg = FakeRegistryView.of(
    allowedValues: {
      'btn.buy': {
        'color': {'success', 'muted'},
      },
    },
  );

  List<DiffLine> summ(List<ConfigOp> ops,
          {RegistryView? reg, SafetyVerdict? verdict}) =>
      summarizeDiff(ops, reg ?? bareReg, verdict: verdict);

  group('per-op rows — a small diff renders one human Hebrew row per op (§6)', () {
    test('each variant maps to its expected he', () {
      expect(summ([const SetText('home.title', 'שלום')]).single.he,
          'שינוי טקסט: home.title');
      expect(summ([const SetEmoji('cart.cta', '🛒')]).single.he,
          'שינוי אמוג׳י: cart.cta');
      expect(summ([const SetHidden('price.tag', true)]).single.he,
          'הסתרה: price.tag');
      expect(summ([const SetHidden('price.tag', false)]).single.he,
          'הצגה: price.tag');
      expect(summ([const SetOrder('list.item', 3)]).single.he,
          'שינוי סדר: list.item ← 3');
      expect(
          summ([const SetStyle('card', CfgStyle(fontScale: 1.2))]).single.he,
          'שינוי עיצוב: card');
      // SetAction uses the step-72 action catalog's Hebrew label.
      expect(
          summ([const SetAction('cta', CfgAction(kind: 'nav.screen'))]).single.he,
          'פעולה: מעבר למסך');
      // An unknown action kind degrades to itself (never throws / never blank).
      expect(
          summ([const SetAction('cta', CfgAction(kind: 'x.y'))]).single.he,
          'פעולה: x.y');
      expect(summ([const SetAction('cta', null)]).single.he,
          'ניקוי פעולה: cta');
    });

    test('§6 — each per-op DiffLine carries its ORIGINAL op (tap-to-edit anchor)',
        () {
      const a = SetText('t.a', 'x');
      const b = SetHidden('t.b', true);
      final rows = summ([a, b]);
      expect(rows.length, 2);
      expect(rows[0].op, same(a));
      expect(rows[1].op, same(b));
    });

    test('ANTI-VACUOUS — every kind yields a non-empty he', () {
      const ops = <ConfigOp>[
        SetText('a', 'x'),
        SetEmoji('b', '🛒'),
        SetHidden('c', true),
        SetOrder('d', 1),
        SetStyle('e', CfgStyle(colorToken: 'brand')),
        SetAction('f', CfgAction(kind: 'cart.open')),
      ];
      for (final op in ops) {
        expect(summ([op]).single.he.trim(), isNotEmpty, reason: 'blank he for $op');
      }
    });
  });

  group('§10 before→after — a constrained SetStyle(color) renders the new color',
      () {
    test('registry vouches for the token → precise Hebrew color', () {
      expect(
        summ([const SetStyle('btn.buy', CfgStyle(colorToken: 'success'))],
            reg: colorReg).single.he,
        'שינוי צבע: btn.buy ← ירוק',
      );
    });
    test('registry does NOT constrain the value → skip the fragment', () {
      expect(
        summ([const SetStyle('btn.buy', CfgStyle(colorToken: 'success'))])
            .single
            .he,
        'שינוי צבע: btn.buy',
      );
    });
  });

  group('§4 broadcast — many ops collapse, never N noisy rows', () {
    test('a same-kind broadcast → ONE "N שינויים" row (op: null)', () {
      final ops = <ConfigOp>[
        for (var i = 0; i < 8; i++) SetHidden('el.$i', true),
      ];
      final rows = summ(ops);
      expect(rows.length, 1); // NOT 8
      expect(rows.single.he, '8 שינויים');
      expect(rows.single.op, isNull); // a roll-up carries no single op
    });

    test('just below the threshold stays per-op', () {
      final ops = <ConfigOp>[
        for (var i = 0; i < kDiffBroadcastThreshold - 1; i++)
          SetHidden('el.$i', true),
      ];
      final rows = summ(ops);
      expect(rows.length, kDiffBroadcastThreshold - 1);
      expect(rows.first.op, isNotNull);
    });
  });

  group('§9 group-by-kind — a multi-kind broadcast → the grouped summary', () {
    test('one row, "🎨 N צבעים · 🙈 N הסתרות · ⚙️ N פעולה"', () {
      final ops = <ConfigOp>[
        for (var i = 0; i < 6; i++)
          SetStyle('c.$i', const CfgStyle(colorToken: 'success')),
        for (var i = 0; i < 3; i++) SetHidden('h.$i', true),
        const SetAction('a.0', CfgAction(kind: 'nav.screen')),
      ];
      final rows = summ(ops);
      expect(rows.length, 1); // collapsed to a single grouped row
      final he = rows.single.he;
      expect(he, contains('🎨 6 צבעים')); // all-color SetStyle group → "צבעים"
      expect(he, contains('🙈 3 הסתרות'));
      expect(he, contains('⚙️ 1 פעולות'));
      expect(rows.single.op, isNull);
    });

    test('a SetStyle group that is NOT all-color labels "עיצובים"', () {
      final ops = <ConfigOp>[
        for (var i = 0; i < 5; i++)
          SetStyle('s.$i', const CfgStyle(fontScale: 1.1)),
        const SetHidden('h.0', true),
      ];
      final he = summ(ops).single.he;
      expect(he, contains('עיצובים'));
      expect(he, isNot(contains('צבעים')));
    });
  });

  group('§4 blocked-count — from SafetyVerdict.blocked (K>0)', () {
    test('a passed verdict with K blocked → a trailing "נחסמו K" row', () {
      const applied = SetText('a', 'x');
      const b1 = SetHidden('crit.price', true);
      const b2 = SetText('crit.confirm', 'y');
      const verdict = SafetyVerdict(
        applied: [applied],
        blocked: [
          BlockedEntry(b1, 'אי-אפשר להסתיר מחיר'),
          BlockedEntry(b2, 'אי-אפשר לשנות את התווית'),
        ],
      );
      final rows = summ(const [applied], verdict: verdict);
      expect(rows.length, 2); // the applied op's row + the blocked-count row
      expect(rows.last.he, 'נחסמו 2'); // K = verdict.blocked.length
      expect(rows.last.op, isNull);
    });

    test('an all-applied verdict adds NO blocked row', () {
      const verdict = SafetyVerdict(applied: [SetText('a', 'x')], blocked: []);
      final rows = summ(const [SetText('a', 'x')], verdict: verdict);
      expect(rows.length, 1);
      expect(rows.single.he, isNot(contains('נחסמו')));
    });

    test('empty ops + a blocking verdict → only the "נחסמו K" row', () {
      const verdict = SafetyVerdict(
        applied: [],
        blocked: [BlockedEntry(SetHidden('x', true), 'סיבה')],
      );
      final rows = summ(const [], verdict: verdict);
      expect(rows.single.he, 'נחסמו 1');
    });

    test('no ops, no verdict → no rows', () {
      expect(summ(const []), isEmpty);
    });
  });

  group('§8 DoD — the SOURCE is RTL-pure (no forced LTR)', () {
    test('diff_preview.dart carries no left-alignment / direction override', () {
      final src = File('lib/logic/studio/diff_preview.dart');
      expect(src.existsSync(), isTrue, reason: 'source not found from ${Directory.current}');
      final text = src.readAsStringSync();
      for (final banned in const [
        'Alignment.centerLeft',
        'TextDirection',
        'Directionality',
        'textAlign',
        'Color(0x',
        'cloud_firestore',
      ]) {
        expect(text.contains(banned), isFalse, reason: 'source contains "$banned"');
      }
    });
  });
}
