// Phase-B (B0) DoD guard: the seed foundation is present, has the verbatim
// COUNTS, and the pure math helpers compute the prototype's values. Locks the
// counts/sums so a future edit that drops or mangles a seed fails here.
//
// Sources are the prototype `index.html` line anchors noted per `expect`.
import 'package:buildsmart/data/phaseb_seeds.dart';
// Reused seeds proven present (NOT rebuilt by B0 — assert they still exist):
import 'package:buildsmart/data/projects.dart';
import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/data/contractor_seeds.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase-B seeds (B0) — counts', () {
    test('PROJECTS — 3 demo projects (reused, projects.dart) [L6447]', () {
      expect(kProjects, hasLength(3));
      expect(kActiveProjectId, 'PRJ-1');
      expect(kProjects.first.name, 'מגדל הרצליה — קומה 4');
    });

    test('ARCHIVED_PROJECTS — 3 completed [L19849]', () {
      expect(kArchivedProjects, hasLength(3));
      expect(kArchivedProjects.first.name, 'מגדל הרצליה — שלב א׳');
      expect(kArchivedProjects.first.units, 24);
      expect(kArchivedProjects.every((p) => p.status == 'הושלם'), isTrue);
    });

    test('SITE_TREE — 3 floors, each 2 apartments [L19841]', () {
      expect(kSiteTree, hasLength(3));
      expect(kSiteTree.map((f) => f.floor).toList(),
          ['קומה 1', 'קומה 2', 'קומה 3']);
      expect(kSiteTree.every((f) => f.apts.length == 2), isTrue);
      expect(kSiteTree.first.apts.first.n, 'דירה 1');
      expect(kSiteTree.first.apts.first.rooms, ['סלון', 'מטבח', 'חדר רחצה']);
    });

    test('STOCK_DEMO — 11 items (warehouse|site) [L6202]', () {
      expect(kStockDemo, hasLength(11));
      expect(kStockDemo['סרט טפלון'], 'warehouse');
      expect(kStockDemo['ברזי ניל זוויתיים'], 'site');
      expect(kStockDemo.values.toSet(), {'warehouse', 'site'});
    });

    test('TASKS — 5 tasks (reused, persona_data) + their steps [L8023]', () {
      expect(kPersonaTasks, hasLength(5));
      expect(kWorkers, hasLength(2));
      // The verbatim per-task step STRING lists (B0 restored these).
      expect(kTaskSteps, hasLength(5));
      expect(kTaskSteps.keys.toList(), [1, 2, 3, 4, 5]);
      // Per-id step counts == the count kept on persona_data (4/4/6/3/4).
      expect(kTaskSteps[1], hasLength(4));
      expect(kTaskSteps[3], hasLength(6));
      expect(kTaskSteps[4], hasLength(3));
      expect(kTaskSteps[1]!.first, 'סימון מסלול הצנרת על הקיר');
      // Each task id has a matching steps list, of the same length as its count.
      for (final t in kPersonaTasks) {
        expect(kTaskSteps[t.id], isNotNull, reason: 'steps for task ${t.id}');
        expect(kTaskSteps[t.id], hasLength(t.steps),
            reason: 'steps count for task ${t.id}');
      }
    });

    test('WORK_LOG — 2 days [L8156]', () {
      expect(kWorkLog, hasLength(2));
      expect(kWorkLog.map((d) => d.date).toList(), ['אתמול', 'שלשום']);
      expect(kWorkLog.first.items, hasLength(3));
      expect(kWorkLog[1].items, hasLength(2));
      expect(kWorkLog.first.items.first.task, 'בניית מחיצת גבס — חדר רחצה');
    });

    test('GANTT_TASKS — 6 rows, span 27 [L19815]', () {
      expect(kGanttTasks, hasLength(6));
      expect(kGanttTasks.first.name, 'יסודות וחפירה');
      expect(kGanttTasks.first.done, 100);
      expect(kGanttTasks.last.done, 0);
      expect(ganttSpan(), 27); // max(start+len) = 21+6
    });

    test('snagList — 2 open snags [L19823]', () {
      expect(kSnagList, hasLength(2));
      expect(kSnagList.first.id, 'SNG-01');
      expect(kSnagList.first.severity, 'בינוני');
      expect(kSnagList[1].severity, 'חמור');
    });

    test('inspections — 2 planned [L19829]', () {
      expect(kInspections, hasLength(2));
      expect(kInspections.first.what, 'ביקורת מהנדס — שלד');
      expect(kInspections.every((i) => i.status == 'מתוכננת'), isTrue);
    });

    test('subcontractors — 3 with allocated/spent [L19469]', () {
      expect(kSubcontractors, hasLength(3));
      expect(kSubcontractors.first.name, 'אינסטלציה — דוד לוי');
      expect(kSubcontractors.first.allocated, 18000);
      expect(kSubcontractors.first.spent, 11200);
    });

    test('approvalQueue — 2 pending [L19475]', () {
      expect(kApprovalQueue, hasLength(2));
      expect(kApprovalQueue.first.id, 'AP-201');
      expect(kApprovalQueue.first.amount, 8400);
      expect(kApprovalQueue[1].amount, 2600);
      expect(kApprovalQueue.every((a) => a.status == 'ממתין'), isTrue);
    });

    test('PAYMENT_TERMS — 4 (מיידי/net30/net60/אבני-דרך) [L19461]', () {
      expect(kPaymentTerms, hasLength(4));
      expect(kPaymentTerms.map((t) => t.id).toList(),
          ['now', 'net30', 'net60', 'milestone']);
      expect(kPaymentTerms.first.days, 0); // מיידי
      expect(kPaymentTerms[1].days, 30);
      expect(kPaymentTerms[2].days, 60);
      expect(kPaymentTerms.last.days, isNull); // לפי אבני דרך
      expect(kActivePaymentTerm, 'net30');
    });

    test('FX_RATES — USD/EUR/GBP [L19482]', () {
      expect(kFxRates.keys.toSet(), {'USD', 'EUR', 'GBP'});
      expect(kFxRates['USD'], 3.72);
      expect(kFxRates['EUR'], 4.05);
      expect(kFxRates['GBP'], 4.71);
    });

    test('BUILD_INDEX — base 121.3 / current 128.7 [L19459]', () {
      expect(kBuildIndex.base, 121.3);
      expect(kBuildIndex.current, 128.7);
      expect(kBuildIndex.label, 'מדד תשומות הבנייה');
    });

    test('projectBudget + budgetCategories(4) (reused) [L7150]', () {
      expect(kBudgetTotal, 15000);
      expect(kBudgetSpent, 9840);
      expect(kBudgetCategories, hasLength(4));
      final sum = kBudgetCategories.fold<int>(0, (a, c) => a + c.amount);
      expect(sum, kBudgetSpent); // Σ categories == spent
    });

    test('DEMO_HISTORY — 2 reorder items [L7013]', () {
      expect(kDemoHistory, hasLength(2));
      expect(kDemoHistory.first.name, 'מקדחה רוטטת בוש GBH');
      expect(kDemoHistory.first.price, 640);
      expect(kDemoHistory[1].price, 31);
    });
  });

  group('Phase-B math helpers', () {
    test('budget pct == 66 (round 9840/15000*100) [L19634]', () {
      expect(budgetPct(), 66);
    });

    test('build-index delta ≈ 6.10% (121.3→128.7) [L19521]', () {
      final d = buildIndexDeltaPct();
      expect(double.parse(d.toStringAsFixed(2)), 6.10); // displayed value
      expect(d, closeTo(6.10, 0.01));
      // Index-linked budget: round(15000*(1+d/100)) == 15915.
      expect(linkedBudget(kBudgetTotal), 15915);
    });

    test('ROI == value × 1.42 [L19659]', () {
      expect(roiValue(15000), 21300);
      expect(roiValue(1000), 1420);
      final roi = projectRoi();
      expect(roi.contractValue, 21300); // round(15000*1.42)
      expect(roi.profit, 6300); // 21300 - 15000
      expect(roi.roiPct, closeTo(42.0, 0.001));
    });

    test('invoice split by category weight sums to 12,800 [L19679]', () {
      const total = 12800;
      expect(kInvoiceTotal, total);
      final split = invoiceSplit();
      expect(split, hasLength(4));
      expect(split.values.fold<int>(0, (a, b) => a + b), total);
      // Per-row shares (round(12800*amount/9840)).
      expect(split['אינסטלציה'], 4865);
      expect(split['חשמל'], 3460);
      expect(split['גמר'], 2693);
      expect(split['אחר'], 1782);
    });
  });
}
