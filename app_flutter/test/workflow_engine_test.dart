// GIANT Phase-2 wave-1b — the workflow KERNEL (the Maor ayin.ts state machine,
// re-implemented in Dart). Pure: nameable 5-stage machine, per-stage guards, the
// 2-press dispatch, dedup-by-normalized-name, next-touch + handled-today report.
// Mirrors ayin.test.ts's behavioral contract, construction-skinned.

import 'package:buildsmart/config/org_config.dart';
import 'package:buildsmart/logic/workflow_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('stages + labels', () {
    test('5 stages in order; key round-trips; next/index', () {
      expect(kWfStages, hasLength(5));
      for (final s in kWfStages) {
        expect(wfStageFromKey(wfStageKey(s)), s);
      }
      expect(wfStageFromKey('nope'), isNull);
      expect(wfStageIndex(WfStage.intake), 0);
      expect(wfNextStage(WfStage.intake), WfStage.prep);
      expect(wfNextStage(WfStage.done), isNull);
    });

    test('term fallbacks out of the box; an override renames only its key', () {
      const cfg = OrgConfig();
      expect(wfFeatureLabel(cfg), 'מעקב טיפול');
      expect(wfStageLabel(cfg, WfStage.prep), 'בהכנה');
      expect(wfStageLabel(cfg, WfStage.done), 'הושלם');
      const branded = OrgConfig(terms: {
        'nav.workflow': 'מעקב-משלוחים',
        'workflow.stage.prep': 'תזמון',
      });
      expect(wfFeatureLabel(branded), 'מעקב-משלוחים');
      expect(wfStageLabel(branded, WfStage.prep), 'תזמון');
      expect(wfStageLabel(branded, WfStage.done), 'הושלם', reason: 'un-overridden');
    });
  });

  group('guards (wfActionVisible)', () {
    test('intake needs a name; ready needs a counted name; done is terminal', () {
      expect(wfActionVisible(const WfCase()), isFalse, reason: 'intake, no names');
      expect(
          wfActionVisible(const WfCase(names: [WfName(id: '1', name: 'א')])),
          isTrue);
      expect(
          wfActionVisible(const WfCase(
              stage: WfStage.ready, names: [WfName(id: '1', name: 'א')])),
          isFalse,
          reason: 'ready but no counted name');
      expect(
          wfActionVisible(const WfCase(
              stage: WfStage.ready,
              names: [WfName(id: '1', name: 'א', units: 3)])),
          isTrue);
      expect(wfActionVisible(const WfCase(stage: WfStage.done)), isFalse);
    });
  });

  group('planWfAdvance transitions', () {
    const cfg = OrgConfig();
    test('intake → prep, event not-done, title carries the name', () {
      const a = WfCase(names: [WfName(id: '1', name: 'שמעון')]);
      final p = planWfAdvance(cfg, 'שמעון', a)!;
      expect(p.patch.stage, WfStage.prep);
      expect(p.event!.done, isFalse);
      expect(p.event!.title, contains('שמעון'));
    });

    test('prep → ready, event done:true', () {
      const a = WfCase(stage: WfStage.prep, names: [WfName(id: '1', name: 'א')]);
      final p = planWfAdvance(cfg, 'א', a)!;
      expect(p.patch.stage, WfStage.ready);
      expect(p.event!.done, isTrue);
    });

    test('ready → dispatch, title carries the units TOTAL', () {
      const a = WfCase(stage: WfStage.ready, names: [
        WfName(id: '1', name: 'א', units: 4),
        WfName(id: '2', name: 'ב', units: 3),
      ]);
      final p = planWfAdvance(cfg, 'א', a)!;
      expect(p.patch.stage, WfStage.dispatch);
      expect(p.event!.title, contains('7'));
    });

    test('dispatch is 2-press: press-1 sets pushed (stays), press-2 → done', () {
      const a = WfCase(stage: WfStage.dispatch, names: [WfName(id: '1', name: 'א')]);
      final p1 = planWfAdvance(cfg, 'א', a)!;
      expect(p1.patch.dispatchPushed, isTrue);
      expect(p1.patch.stage, WfStage.dispatch, reason: 'stays until the 2nd press');
      final p2 = planWfAdvance(cfg, 'א', a.copyWith(dispatchPushed: true))!;
      expect(p2.patch.stage, WfStage.done);
      expect(p2.event!.done, isTrue);
    });

    test('not-visible → null (a done case never advances)', () {
      expect(planWfAdvance(cfg, 'א', const WfCase(stage: WfStage.done)), isNull);
      expect(planWfAdvance(cfg, 'א', const WfCase()), isNull, reason: 'no names');
    });
  });

  group('revert', () {
    test('reverting BEFORE dispatch clears the pushed flag; at/after keeps it',
        () {
      const pushed = WfCase(stage: WfStage.dispatch, dispatchPushed: true);
      expect(wfRevertPatch(pushed, WfStage.prep).dispatchPushed, isFalse);
      expect(wfRevertPatch(pushed, WfStage.dispatch).dispatchPushed, isTrue);
      expect(wfRevertPatch(pushed, WfStage.prep).stage, WfStage.prep);
    });
  });

  group('advance labels', () {
    const cfg = OrgConfig();
    test('per-stage smart-button text', () {
      expect(wfAdvanceLabel(cfg, const WfCase()), contains('בהכנה'));
      expect(
          wfAdvanceLabel(cfg, const WfCase(stage: WfStage.dispatch)),
          contains('דחיפה'));
      expect(
          wfAdvanceLabel(
              cfg, const WfCase(stage: WfStage.dispatch, dispatchPushed: true)),
          contains('הושלם'));
    });
  });

  group('planAddName (dedup)', () {
    test('fresh ok; blank rejected; normalized duplicate rejected; count logs',
        () {
      const a = WfCase(names: [WfName(id: '1', name: 'בן דוד')]);
      expect(planAddName(a, '', null, '2', todayIso: '2026-07-26'), isNull);
      // final-letter + whitespace fold: 'בןדוד' ≡ 'בן דוד'
      expect(planAddName(a, ' בןדוד ', null, '2', todayIso: '2026-07-26'), isNull);
      final ok = planAddName(a, 'לוי', 5, '2', todayIso: '2026-07-26')!;
      expect(ok.names, hasLength(2));
      expect(ok.log!.first.units, 5);
      final noCount = planAddName(a, 'כהן', null, '3', todayIso: '2026-07-26')!;
      expect(noCount.log, isNull);
    });
  });

  group('wfDailyRows (handled today)', () {
    const cfg = OrgConfig();
    const today = '2026-07-26';
    test('only entities touched today; header shape; stage label; units summed',
        () {
      final rows = wfDailyRows(cfg, [
        (
          name: 'עמית',
          phone: '050',
          wf: const WfCase(stage: WfStage.prep, lastTouch: today)
        ),
        (name: 'דנה', phone: '052', wf: const WfCase(lastTouch: '2026-07-01')),
        (name: 'בלי', phone: '', wf: null),
      ], today);
      expect(rows.first[0], 'שם');
      expect(rows.first[2], 'כמות היום');
      expect(rows, hasLength(2), reason: 'header + the one touched-today row');
      expect(rows[1][0], 'עמית');
      expect(rows[1][3], 'בהכנה');
    });

    test('nobody touched → header only', () {
      final rows = wfDailyRows(cfg, [
        (name: 'ד', phone: '', wf: const WfCase(lastTouch: '2020-01-01')),
      ], today);
      expect(rows, hasLength(1));
    });
  });

  test('wfActive: null false; a fresh untouched intake false; any touch true',
      () {
    expect(wfActive(null), isFalse);
    expect(wfActive(const WfCase()), isFalse);
    expect(wfActive(const WfCase(names: [WfName(id: '1', name: 'א')])), isTrue);
    expect(wfActive(const WfCase(lastTouch: '2026-07-26')), isTrue);
  });
}
