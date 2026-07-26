// GIANT Phase-2 wave-1 — the attention engine: the PURE fan-in ranker (crit
// before warn, stable within a band, aggregate past 3, terms applied) + the
// gated dashboard mount (default-OFF ⇒ nothing renders; ON ⇒ ranked rows that
// drill to their manager tab). The Maor homeData pattern, construction-skinned.

import 'package:buildsmart/config/org_config.dart';
import 'package:buildsmart/logic/attention_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('pure engine', () {
    test('empty input → no items, and the digest is the quiet line', () {
      final items = attentionItems(const AttentionInput(), cfg: const OrgConfig());
      expect(items, isEmpty);
      final digest = digestLines(const AttentionInput(), cfg: const OrgConfig());
      expect(digest, hasLength(1));
      expect(digest.single.key, 'quiet');
    });

    test('aging orders: ≥7d → crit, 3..6d → warn, <3d dropped by the source '
        '(engine only sees what it is handed)', () {
      const inp = AttentionInput(agingOrders: [
        AgingOrder('BS-1', 9),
        AgingOrder('BS-2', 4),
      ]);
      final items = attentionItems(inp, cfg: const OrgConfig());
      expect(items, hasLength(2));
      expect(items.first.key, 'order:BS-1', reason: 'crit sorts before warn');
      expect(items.first.sev, AttentionSev.crit);
      expect(items[1].sev, AttentionSev.warn);
      expect(items.every((i) => i.navTab == 1), isTrue);
    });

    test('more than 3 aging orders → 3 rows + one aggregate row', () {
      const inp = AttentionInput(agingOrders: [
        AgingOrder('A', 3), AgingOrder('B', 4), AgingOrder('C', 5),
        AgingOrder('D', 6), AgingOrder('E', 8),
      ]);
      final items = attentionItems(inp, cfg: const OrgConfig());
      final orderRows = items.where((i) => i.key.startsWith('order:')).toList();
      expect(orderRows, hasLength(4));
      expect(orderRows.any((i) => i.key == 'order:more'), isTrue);
      // sorted by age desc → the crit E(8) leads, D(6),C(5) next, then aggregate
      expect(items.first.key, 'order:E');
    });

    test('crit-before-warn is a STABLE partition — a later-inserted CRIT '
        '(approvals backlog) jumps ahead of an earlier WARN order', () {
      const inp = AttentionInput(
        agingOrders: [AgingOrder('W', 4)], // warn (inserted FIRST)
        pendingApprovals: 12, // ≥8 ⇒ crit (inserted SECOND)
        pendingVacations: 1, // warn (inserted LAST)
      );
      final items = attentionItems(inp, cfg: const OrgConfig());
      expect(items.map((i) => i.key).toList(),
          ['approvals', 'order:W', 'vacations'],
          reason: 'the crit is pulled to the front; the two warns keep their '
              'engine insertion order (a stable partition, not List.sort)');
    });

    test('approvals backlog ≥8 is crit; below is warn', () {
      expect(
          attentionItems(const AttentionInput(pendingApprovals: 8),
                  cfg: const OrgConfig())
              .single
              .sev,
          AttentionSev.crit);
      expect(
          attentionItems(const AttentionInput(pendingApprovals: 7),
                  cfg: const OrgConfig())
              .single
              .sev,
          AttentionSev.warn);
    });

    test('each needs-action queue yields its labelled row', () {
      const inp = AttentionInput(
        pendingApprovals: 1,
        pendingVacations: 3,
        pendingAccountReqs: 2,
      );
      final items = attentionItems(inp, cfg: const OrgConfig());
      expect(items.map((i) => i.key).toSet(),
          {'approvals', 'vacations', 'accountReqs'});
      expect(items.firstWhere((i) => i.key == 'approvals').title,
          'משימה אחת ממתינה לאישור');
      expect(items.firstWhere((i) => i.key == 'vacations').title,
          '3 בקשות חופשה ממתינות');
    });

    test('termOf rebrands the tag; default keeps the fallback', () {
      const inp = AttentionInput(pendingApprovals: 1);
      expect(attentionItems(inp, cfg: const OrgConfig()).single.tag, 'אישור');
      expect(
        attentionItems(inp,
                cfg: const OrgConfig(terms: {'attn.tag.approval': 'לאשר!'}))
            .single
            .tag,
        'לאשר!',
      );
    });

    test('digest: a crit item produces the urgent head line', () {
      const inp = AttentionInput(
          agingOrders: [AgingOrder('X', 9)], pendingApprovals: 1);
      final digest = digestLines(inp, cfg: const OrgConfig());
      expect(digest.first.key, 'urgent');
      expect(digest.first.urgent, isTrue);
    });
  });
}
