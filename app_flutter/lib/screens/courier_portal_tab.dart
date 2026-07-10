// #74 — פורטל השליח כטאב (לא דיאלוג) + חיווט אמיתי ל-6 כלי הפורטל.
//
// אותם 6 אריחים מ-[kCourierPortalTiles] (persona_portal.dart), אבל כל אריח
// מחווט לכלי אמיתי במקום "כלי זה יחובר בהמשך הפיתוח":
//   📸 אישור מסירה → ה-[PersonaPodSheet] הקיים עבור המשלוח הפעיל (pickup/transit)
//   💬 צ׳אט עם חנות → ChatsScreen של השליח (audience:'courier')
//   🚛 צי רכב      → גיליון מקומי: kHaulTypes + זמינות demo (SERVER-SWAP) + kFleet
//   🗺️ אזורי הפצה  → רשימה מקומית מכתובות המשלוח האמיתיות + kDistZones (בלי מפה — ביושר)
//   🧭 ניווט למשלוח → SERVER-READY: כרטיס יעד מלא + מצב כן "יחובר עם חיבור השרת"
//   ⏱️ מעקב SLA    → SERVER-READY: פריסת טיימרים + יעדי kDistZones + אותו מצב כן
//
// אין המצאות: כל מספר/מחרוזת מגיעים מה-seeds הקיימים או מההזמנות החיות;
// יכולות תלויות-שרת (ניווט במפות, SLA חי) מוצגות במצב כן — לא כהצלחה מזויפת
// ולא כ-toast עירום.

import 'package:buildsmart/data/contractor_seeds.dart' show fMoney;
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/screens/persona_pod_sheet.dart';
import 'package:buildsmart/screens/persona_portal.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// זמינות צי לפי סוג רכב — demo seed להמחשה בלבד (כמה רכבים מכל סוג פנויים
/// היום). SERVER-SWAP: יוחלף בזמינות חיה ממערכת ניהול הצי עם חיבור השרת.
const Map<String, int> kHaulAvailabilityDemo = {
  'small': 1,
  'van': 2,
  'truck': 1,
};

/// טאב הפורטל של לוח השליח (#72 טאב 2) — הגריד של [kCourierPortalTiles]
/// כטאב קבוע, עם wiring פר-אריח (#74).
class CourierPortalTab extends ConsumerWidget {
  const CourierPortalTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space5,
      ),
      children: [
        CfgText(
          'courier_portal_tab.t01',
          '🧰 פורטל השליח',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 2),
        CfgText(
          'courier_portal_tab.t02',
          'ניווט, צי רכב, צ׳אט ומעקב SLA',
          style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
        ),
        const SizedBox(height: BsTokens.space4),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: BsTokens.space3,
          crossAxisSpacing: BsTokens.space3,
          childAspectRatio: 1.5,
          children: [
            for (final t in kCourierPortalTiles)
              HelpTarget(
                title: 'כלי הפורטל',
                body:
                    'ששת כלי השליח: אישור מסירה · צ׳אט עם החנות · צי רכב · '
                    'אזורי הפצה · ניווט למשלוח · מעקב SLA. '
                    'הקשה על אריח פותחת את הכלי המתאים.',
                child: PortalTileButton(
                  title: t.title,
                  sub: t.sub,
                  onTap: () => _open(context, ref, t),
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _open(BuildContext context, WidgetRef ref, PortalTileData tile) {
    final orders = ref.read(sysOrdersProvider);
    const activeStages = [
      OrderStage.ready,
      OrderStage.pickup,
      OrderStage.transit,
    ];
    final active = orders.where((o) => activeStages.contains(o.stage)).toList();

    switch (tile.kind) {
      case PortalKind.pod:
        _openPod(context, orders);
      case PortalKind.chatStore:
        // 🔒 בידוד: דוחפים רק את ChatsScreen — מסך עצמאי שה"חזרה" שלו חוזרת
        // לכאן בלבד. audience:'courier' → רשימת השיחות של לוח השליח (#75).
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder:
                (_) => const ChatsScreen(
                  persona: BsRole.courier,
                  audience: 'courier',
                ),
          ),
        );
      case PortalKind.fleet:
        _showFleetSheet(context, tile);
      case PortalKind.zones:
        _showZonesSheet(context, tile, active);
      case PortalKind.nav:
        _showNavSheet(context, tile, active);
      case PortalKind.sla:
        _showSlaSheet(context, tile, active);
      // ratings/bulk/barcode/autoStock/chatContractor אינם בגריד השליח —
      // fallback לגיליון המידע הכללי של persona_portal (לא אמור לקרות).
      case PortalKind.ratings:
      case PortalKind.bulk:
      case PortalKind.barcode:
      case PortalKind.autoStock:
      case PortalKind.chatContractor:
        showPortalSheet(context, tile);
    }
  }

  // ── 📸 אישור מסירה — PersonaPodSheet עבור המשלוח הפעיל ─────────────────────
  void _openPod(BuildContext context, List<SysOrder> orders) {
    // POD רלוונטי רק להזמנות שבידי השליח (pickup/transit) — כמו בכרטיס.
    final eligible =
        orders
            .where(
              (o) =>
                  o.stage == OrderStage.pickup || o.stage == OrderStage.transit,
            )
            .toList();
    if (eligible.isEmpty) {
      // ביושר: אין משלוח פעיל — לא מזייפים POD.
      _sheet(context, '📸 אישור מסירה', 'POD + צילום', [
        _row('אין כרגע משלוח בידי השליח — POD זמין משלב האיסוף (לקיחה/בדרך).'),
      ]);
      return;
    }
    if (eligible.length == 1) {
      showPodSheet(context, eligible.first.id);
      return;
    }
    // כמה משלוחים פעילים — בוחרים לאיזה מהם נפתח ה-POD.
    _sheet(context, '📸 אישור מסירה', 'בחר משלוח פעיל', [
      for (final o in eligible)
        _tapRow(
          context,
          '📦 ${o.id} · ${o.who} · ${kOrderStageLabel[o.stage]}',
          onTap: () {
            Navigator.of(context).pop();
            showPodSheet(context, o.id);
          },
        ),
    ]);
  }

  // ── 🚛 צי רכב — kHaulTypes + זמינות demo + רכבי kFleet ─────────────────────
  void _showFleetSheet(BuildContext context, PortalTileData tile) {
    _sheet(context, tile.title, tile.sub, [
      for (final h in kHaulTypes)
        _row(
          '${h.ic} ${h.name} · תוספת ${fMoney(h.extra)} · '
          'זמינים היום: ${kHaulAvailabilityDemo[h.id] ?? 0}',
        ),
      // ביושר: הזמינות לעיל היא demo seed (SERVER-SWAP בקובץ זה). מוסתר
      // ל-Apple review (אין הצגת "הדגמה"); הנתונים נשארים. הפיך.
      if (!kHideUnderConstruction)
        _note('זמינות להדגמה — תוחלף בנתוני צי חיים עם חיבור השרת'),
      const SizedBox(height: BsTokens.space2),
      _subhead('רכבי הצי'),
      for (final v in kFleet)
        _row('${v.name} · ${v.cap} · ${v.status} · נהג ${v.driver}'),
    ]);
  }

  // ── 🗺️ אזורי הפצה — כתובות אמיתיות מההזמנות החיות + kDistZones ─────────────
  void _showZonesSheet(
    BuildContext context,
    PortalTileData tile,
    List<SysOrder> active,
  ) {
    _sheet(context, tile.title, tile.sub, [
      _subhead('כתובות משלוח פעילות'),
      if (active.isEmpty)
        _row('✓ אין משלוחים פעילים כרגע')
      else
        for (final o in active)
          _row('📍 ${o.site} · ${o.id} · ${kOrderStageLabel[o.stage]}'),
      const SizedBox(height: BsTokens.space2),
      _subhead('אזורי שירות'),
      for (final z in kDistZones)
        _row('${z.name} · ${z.eta} · משלוח ${fMoney(z.fee)}'),
      // ביושר: אין מפה בדמו — רשימה בלבד. (מפה/ניווט = C6 location fleet — לא נגעתי.)
      _note('תצוגת מפה אינה זמינה בדמו — מפה חיה תחובר עם חיבור השרת'),
    ]);
  }

  // ── 🧭 ניווט למשלוח — SERVER-READY: כרטיסי יעד + מצב "יחובר עם חיבור השרת" ──
  void _showNavSheet(
    BuildContext context,
    PortalTileData tile,
    List<SysOrder> active,
  ) {
    _sheet(context, tile.title, tile.sub, [
      _serverPending('ניווט חי במפות (Waze / Google Maps) יחובר עם חיבור השרת'),
      const SizedBox(height: BsTokens.space2),
      if (active.isEmpty)
        _row('✓ אין משלוחים פעילים לניווט כרגע')
      else
        for (final o in active) _DestinationCard(order: o),
    ]);
  }

  // ── ⏱️ מעקב SLA — SERVER-READY: פריסת טיימרים + יעדי האזורים ────────────────
  void _showSlaSheet(
    BuildContext context,
    PortalTileData tile,
    List<SysOrder> active,
  ) {
    _sheet(context, tile.title, tile.sub, [
      _serverPending('טיימרי SLA חיים יחוברו עם חיבור השרת'),
      const SizedBox(height: BsTokens.space2),
      _subhead('משלוחים פעילים'),
      if (active.isEmpty)
        _row('✓ אין משלוחים פעילים כרגע')
      else
        for (final o in active)
          Padding(
            padding: const EdgeInsets.only(bottom: BsTokens.space2),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: BsTokens.space4,
                vertical: BsTokens.space3,
              ),
              decoration: BoxDecoration(
                color: BsTokens.bgLight,
                borderRadius: BorderRadius.circular(BsTokens.radiusCard),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '⏱️ ${o.id} · ${kOrderStageLabel[o.stage]}',
                      style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  // פריסת הטיימר מוכנה — הערך החי מגיע מהשרת (ביושר: ללא זיוף).
                  const Text(
                    '—:—',
                    style: TextStyle(
                      color: BsTokens.mutedLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
      const SizedBox(height: BsTokens.space2),
      _subhead('יעדי אספקה לפי אזור'),
      for (final z in kDistZones) _row('${z.name} · יעד אספקה: ${z.eta}'),
    ]);
  }

  // ── shell + rows (תואם ל-_PortalSheet של persona_portal) ────────────────────

  void _sheet(
    BuildContext context,
    String title,
    String sub,
    List<Widget> children,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BsTokens.cardLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                BsTokens.space4,
                BsTokens.space4,
                BsTokens.space4,
                BsTokens.space5,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: const TextStyle(
                        color: BsTokens.mutedLight,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: BsTokens.space4),
                    ...children,
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _row(String text) => Padding(
    padding: const EdgeInsets.only(bottom: BsTokens.space2),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: BsTokens.space4,
        vertical: BsTokens.space3,
      ),
      decoration: BoxDecoration(
        color: BsTokens.bgLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      ),
      child: Text(
        text,
        style: const TextStyle(color: BsTokens.inkLight, fontSize: 13.5),
      ),
    ),
  );

  Widget _tapRow(
    BuildContext context,
    String text, {
    required VoidCallback onTap,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: BsTokens.space2),
    child: Material(
      color: BsTokens.bgLight,
      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: BsTokens.space4,
            vertical: BsTokens.space3,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_left,
                color: BsTokens.mutedLight,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _subhead(String text) => Padding(
    padding: const EdgeInsets.only(bottom: BsTokens.space2),
    child: Text(
      text,
      style: const TextStyle(
        color: BsTokens.inkLight,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    ),
  );

  Widget _note(String text) => Padding(
    padding: const EdgeInsets.only(bottom: BsTokens.space2),
    child: Text(
      text,
      style: const TextStyle(color: BsTokens.mutedLight, fontSize: 11.5),
    ),
  );

  /// פס "יחובר עם חיבור השרת" — מצב SERVER-READY כן (ענבר, לא הצלחה ירוקה).
  Widget _serverPending(String text) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(
      horizontal: BsTokens.space4,
      vertical: BsTokens.space3,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF4D6),
      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
    ),
    child: Text(
      '🔌 $text',
      style: const TextStyle(
        color: Color(0xFF8A6D00),
        fontWeight: FontWeight.w700,
        fontSize: 12.5,
      ),
    ),
  );
}

/// כרטיס יעד לניווט — UI מלא ומוכן-לשרת; כפתור הניווט מושבת בכנות עד שיש שרת.
class _DestinationCard extends StatelessWidget {
  const _DestinationCard({required this.order});
  final SysOrder order;

  @override
  Widget build(BuildContext context) {
    final haul = haulInfo(order.haul);
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space2),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(BsTokens.space4),
        decoration: BoxDecoration(
          color: BsTokens.bgLight,
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '📦 ${order.id} · ${order.who}',
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '📍 ${order.site}',
              style: const TextStyle(color: BsTokens.inkLight, fontSize: 13.5),
            ),
            Text(
              '${haul.ic} ${haul.name} · ${kOrderStageLabel[order.stage]}',
              style: const TextStyle(
                color: BsTokens.mutedLight,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: BsTokens.space2),
            // SERVER-READY: הכפתור קיים ומעוצב אך מושבת בכנות — אין שרת ניווט.
            FilledButton(
              onPressed: null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                ),
              ),
              child: CfgText(
                'courier_portal_tab.t03',
                '🧭 פתח ניווט — יחובר עם חיבור השרת',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
