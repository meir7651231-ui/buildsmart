// טאב דוחות של לוח השליח (#72 טאב 3) — היסטוריית מסירות + סטטיסטיקה כנה
// ממנוע ההזמנות המשותף ([sysOrdersProvider] → ordersEngine) ומ-side-car ה-POD
// ([fulfillmentProvider]).
//
// אין המצאות: כל המספרים נגזרים חיים מההזמנות הקיימות; אין במנוע חותמות-זמן
// מסירה או מדדי SLA היסטוריים — ולכן הם לא מוצגים, רק שורת-אמת שזה יחובר עם
// חיבור השרת.

import 'package:buildsmart/data/contractor_seeds.dart' show fMoney;
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/state/persona_fulfillment.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CourierReportsTab extends ConsumerWidget {
  const CourierReportsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(sysOrdersProvider);
    final fulfillment = ref.watch(fulfillmentProvider);

    final delivered =
        orders.where((o) => o.stage == OrderStage.delivered).toList();
    final deliveredSum = delivered.fold<int>(0, (a, o) => a + o.sum);
    const activeStages = [
      OrderStage.ready,
      OrderStage.pickup,
      OrderStage.transit,
    ];
    final active = orders.where((o) => activeStages.contains(o.stage)).length;
    final podCount = orders
        .where((o) => fulfillment[o.id]?.podCaptured ?? false)
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space5,
      ),
      children: [
        const Text(
          '📊 דוחות',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'נתונים חיים ממנוע ההזמנות המשותף',
          style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
        ),
        const SizedBox(height: BsTokens.space4),

        // Live stats — derived, not invented.
        Row(
          children: [
            _RStat(value: '${delivered.length}', label: 'נמסרו ✅'),
            _RStat(value: '$active', label: 'פעילים 🚚'),
            _RStat(value: '$podCount', label: 'POD 📸'),
          ],
        ),
        const SizedBox(height: BsTokens.space3),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(BsTokens.space4),
          decoration: BoxDecoration(
            color: BsTokens.cardLight,
            borderRadius: BorderRadius.circular(BsTokens.radiusCard),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'סה״כ ערך משלוחים שנמסרו: ${fMoney(deliveredSum)}',
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: BsTokens.space4),

        // Delivered history.
        const Text(
          'היסטוריית מסירות',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: BsTokens.space2),
        if (delivered.isEmpty)
          // מצב-ריק כן: עוד לא נמסר כלום במשמרת הזו.
          const Padding(
            padding: EdgeInsets.symmetric(vertical: BsTokens.space5),
            child: Center(
              child: Column(
                children: [
                  Text('📭', style: TextStyle(fontSize: 40)),
                  SizedBox(height: 8),
                  Text(
                    'אין עדיין מסירות שהושלמו',
                    style: TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'משלוח שיסומן "נמסר ללקוח" יופיע כאן',
                    style: TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          )
        else
          for (final o in delivered)
            Padding(
              padding: const EdgeInsets.only(bottom: BsTokens.space2),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(BsTokens.space4),
                decoration: BoxDecoration(
                  color: BsTokens.cardLight,
                  borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '📦 ${o.id}',
                            style: const TextStyle(
                              color: BsTokens.inkLight,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD7F5DF),
                            borderRadius:
                                BorderRadius.circular(BsTokens.radiusPill),
                          ),
                          child: const Text(
                            'נמסר ✓',
                            style: TextStyle(
                              color: Color(0xFF1F8A4C),
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '👤 ${o.who} · 📍 ${o.site}',
                      style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${o.items} פריטים · ${fMoney(o.sum)} · '
                      '${(fulfillment[o.id]?.podCaptured ?? false) ? '📸 POD נשמר ✓' : '📸 ללא POD'}',
                      style: const TextStyle(
                        color: BsTokens.mutedLight,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: BsTokens.space2),

        // ביושר: אין במנוע חותמות-זמן/SLA היסטוריים — לא ממציאים אותם.
        const Text(
          'דוחות זמני-מסירה ו-SLA היסטוריים יחוברו עם חיבור השרת — כאן מוצג רק '
          'מה שקיים במנוע ההזמנות.',
          style: TextStyle(color: BsTokens.mutedLight, fontSize: 11.5),
        ),
      ],
    );
  }
}

/// תיבת סטטיסטיקה — אותו מראה כמו _Stat של לוח השליח.
class _RStat extends StatelessWidget {
  const _RStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: BsTokens.space3),
        decoration: BoxDecoration(
          color: BsTokens.cardLight,
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
