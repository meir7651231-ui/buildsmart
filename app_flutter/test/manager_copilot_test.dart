// Pins the Manager Co-Pilot brain (#manager-copilot): the context is a GROUNDED
// fold of real engine data, the prompts forbid invention, and the owner's question
// is length-capped. Pure — no gateway, no widget pump.
import 'package:buildsmart/logic/manager_copilot.dart';
import 'package:buildsmart/logic/manager_dashboard.dart'
    show managerAnalytics, mgrCustomerList;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final analytics = managerAnalytics; // seed: openOrders == 4
  final customers = mgrCustomerList(); // 4 seed buyers, sorted by spend desc
  const stageCounts = {'new': 1, 'preparing': 1, 'ready': 1, 'transit': 1};
  final ctx = buildManagerContext(
    analytics: analytics,
    customers: customers,
    stageCounts: stageCounts,
  );

  group('buildManagerContext — grounded snapshot of REAL numbers', () {
    test('folds open-orders, totals, pipeline and the top customer', () {
      final totalOrders =
          customers.fold<int>(0, (s, c) => s + c.orderCount);
      expect(ctx, contains('פתוחות ${analytics.openOrders}'));
      expect(ctx, contains('סה"כ $totalOrders'));
      expect(ctx, contains('התקבלה 1')); // stage 'new' label + count
      expect(ctx, contains('בהכנה 1'));
      // Top customer (highest spend) is listed first.
      expect(ctx, contains(customers.first.name));
      expect(ctx.indexOf(customers.first.name),
          lessThan(ctx.indexOf(customers.last.name)));
    });

    test('revenue == Σ customer spend (matches the dashboard, no invention)', () {
      final revenue = customers.fold<int>(0, (s, c) => s + c.totalSpend);
      // grouped ₪ string of the real revenue appears in the snapshot
      final grouped = revenue.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
      expect(ctx, contains('₪$grouped'));
    });
  });

  group('prompts — grounding + caps', () {
    test('system prompt forbids invention + pins Hebrew/context-only', () {
      expect(managerCopilotSystem, contains('אסור להמציא'));
      expect(managerCopilotSystem, contains('אך ורק לפי הנתונים'));
    });

    test('Q&A prompt embeds the context + question + grounding clause', () {
      final p = managerCopilotPrompt(ctx, 'מה בוער עכשיו?');
      expect(p, contains(ctx));
      expect(p, contains('מה בוער עכשיו?'));
      expect(p, contains('אך ורק לפי הנתונים'));
    });

    test('owner question is length-capped (DoS / context-stuffing guard)', () {
      final huge = 'א' * 1000;
      final p = managerCopilotPrompt('CTX', huge);
      expect(p.contains('א' * 401), isFalse); // capped to 400
    });

    test('morning brief asks for a grounded daily briefing', () {
      final p = managerMorningBriefPrompt(ctx);
      expect(p, contains('תדריך-בוקר'));
      expect(p, contains(ctx));
    });

    test('there are real suggested questions', () {
      expect(kManagerCopilotSuggestions, isNotEmpty);
      expect(kManagerCopilotSuggestions, contains('מה בוער עכשיו?'));
    });
  });
}
