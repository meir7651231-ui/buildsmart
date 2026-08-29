// GIANT Phase-2 wave-2d — the pure RFM customer-scoring kernel. Absolute-
// threshold bands (no population needed), FM-only degrade when recency is
// unknown, tier keys, and the at-risk signal. Clock-free (recency arrives as a
// day count); the provider does the DateTime.now().

import 'package:buildsmart/logic/customer_score.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FM-only (recency unknown → maxPoints 4)', () {
    test('high frequency + high monetary → champion, r=-1, no at-risk', () {
      final s = scoreCustomer(
          const RfmInput(orderCount: 6, totalSpend: 12000)); // recency null
      expect(s.r, -1);
      expect(s.f, 2);
      expect(s.m, 2);
      expect(s.points, 4);
      expect(s.maxPoints, 4);
      expect(s.tier, 'champion');
      expect(s.atRisk, isFalse, reason: 'no recency ⇒ never at-risk');
    });

    test('one small order → dormant', () {
      final s = scoreCustomer(const RfmInput(orderCount: 1, totalSpend: 100));
      expect(s.points, 0);
      expect(s.maxPoints, 4);
      expect(s.tier, 'dormant');
    });

    test('mid frequency + mid monetary → loyal (ratio 0.5 of 4)', () {
      final s = scoreCustomer(const RfmInput(orderCount: 3, totalSpend: 3000));
      expect(s.f, 1);
      expect(s.m, 1);
      expect(s.points, 2);
      expect(s.tier, 'loyal');
    });
  });

  group('full RFM (recency known → maxPoints 6)', () {
    test('fresh + valuable → champion', () {
      final s = scoreCustomer(
          const RfmInput(orderCount: 6, totalSpend: 12000, recencyDays: 10));
      expect(s.r, 2);
      expect(s.points, 6);
      expect(s.maxPoints, 6);
      expect(s.tier, 'champion');
      expect(s.atRisk, isFalse);
    });

    test('valuable but gone COLD → at-risk (r=0, F+M≥3)', () {
      final s = scoreCustomer(
          const RfmInput(orderCount: 6, totalSpend: 12000, recencyDays: 120));
      expect(s.r, 0);
      expect(s.points, 4, reason: 'F2+M2, R0');
      expect(s.maxPoints, 6);
      expect(s.tier, 'loyal', reason: '4/6 ≈ 0.67');
      expect(s.atRisk, isTrue);
    });

    test('cold but was never valuable → NOT at-risk (F+M<3)', () {
      final s = scoreCustomer(
          const RfmInput(orderCount: 3, totalSpend: 3000, recencyDays: 120));
      expect(s.f, 1);
      expect(s.m, 1);
      expect(s.r, 0);
      expect(s.points, 2);
      expect(s.tier, 'occasional', reason: '2/6 ≈ 0.33');
      expect(s.atRisk, isFalse, reason: 'F+M=2 < 3');
    });
  });

  group('band thresholds', () {
    test('frequency bands at kRfmFreqMid / kRfmFreqHigh', () {
      expect(scoreCustomer(const RfmInput(orderCount: 1, totalSpend: 0)).f, 0);
      expect(
          scoreCustomer(const RfmInput(orderCount: kRfmFreqMid, totalSpend: 0))
              .f,
          1);
      expect(
          scoreCustomer(const RfmInput(orderCount: kRfmFreqHigh, totalSpend: 0))
              .f,
          2);
    });

    test('monetary bands at kRfmMoneyMid / kRfmMoneyHigh', () {
      expect(scoreCustomer(const RfmInput(orderCount: 0, totalSpend: 1999)).m, 0);
      expect(
          scoreCustomer(
                  const RfmInput(orderCount: 0, totalSpend: kRfmMoneyMid))
              .m,
          1);
      expect(
          scoreCustomer(
                  const RfmInput(orderCount: 0, totalSpend: kRfmMoneyHigh))
              .m,
          2);
    });

    test('recency bands at kRfmRecentDays / kRfmStaleDays', () {
      int r(int days) => scoreCustomer(
              RfmInput(orderCount: 0, totalSpend: 0, recencyDays: days))
          .r;
      expect(r(kRfmRecentDays), 2, reason: 'fresh');
      expect(r(kRfmRecentDays + 1), 1, reason: 'aging');
      expect(r(kRfmStaleDays), 1);
      expect(r(kRfmStaleDays + 1), 0, reason: 'cold');
    });
  });
}
