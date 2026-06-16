// #20 — פרופיל מנהל ייעודי (מודל: courier_profile_screen.dart, #73).
//
// מציג את ה-session החי מ-[boardAuthProvider] (שם תצוגה, שם משתמש),
// סטטיסטיקת הזמנות חיה ממנוע ההזמנות המשותף, ושתי פעולות:
//   ⚙️ הגדרות         → CatalogSettingsScreen (אותו יעד כמו פעולת ההגדרות בלוח)
//   🖥️ מעבר בין מסכים → showManagerScreensSheet (התחזות לכל לוח — שלב 3)
//
// מנהל = חשבון הבעלים: אין כאן 'יציאה'/logout (דרישת מוצר — "המנהל לא מתנתק").

import 'package:buildsmart/data/contractor_seeds.dart' show fMoney;
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/screens/catalog_settings_screen.dart';
import 'package:buildsmart/screens/manager_screens_sheet.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// מסך עצמאי (נדחף מאייקון הפרופיל ב-AppBar של מרכז השליטה).
class ManagerProfileScreen extends StatelessWidget {
  const ManagerProfileScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const ManagerProfileScreen());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          elevation: 0,
          title: const Text(
            'אזור אישי — מנהל המערכת',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black54),
        ),
        body: const SafeArea(child: _ManagerProfileBody()),
      ),
    );
  }
}

/// גוף הפרופיל — session חי + סטטיסטיקת הזמנות חיה + פעולות.
class _ManagerProfileBody extends ConsumerWidget {
  const _ManagerProfileBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(boardAuthProvider);
    // כלל 4 — בלי session מנהל אין תוכן לוח; הלוח עצמו כבר מציג את השער.
    if (session == null || session.role != BoardRole.manager) {
      return const SizedBox.shrink();
    }

    final orders = ref.watch(sysOrdersProvider);
    final active = orders.countAt(OrderStage.newOrder) +
        orders.countAt(OrderStage.preparing) +
        orders.countAt(OrderStage.ready);
    final onRoad = orders.countAt(OrderStage.pickup) +
        orders.countAt(OrderStage.transit);
    final delivered = orders.countAt(OrderStage.delivered);
    final revenue = orders.todayRevenue;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space5,
      ),
      children: [
        // ── זהות (session חי) ──────────────────────────────────────────────
        Container(
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
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF0E3),
                  shape: BoxShape.circle,
                ),
                child: const Text('👔', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: BsTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.displayName,
                      style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '@${session.username} · מנהל המערכת',
                      style: const TextStyle(
                        color: BsTokens.mutedLight,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // "מצב הדגמה" pill — a self-declared demo badge the App Store
              // rejects; hidden for review (kHideUnderConstruction). The
              // session.demo state is untouched; flip the flag to restore.
              if (session.demo && !kHideUnderConstruction)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4D6),
                    borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                  ),
                  child: const Text(
                    'מצב הדגמה',
                    style: TextStyle(
                      color: Color(0xFF8A6D00),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: BsTokens.space4),

        // ── הזמנות — סטטיסטיקה חיה (אותו מנוע משותף של הלוח) ───────────────
        const Text(
          'הזמנות — סטטיסטיקה',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: BsTokens.space2),
        Row(
          children: [
            _PStat(value: '$active', label: 'פעילות 📋'),
            _PStat(value: '$onRoad', label: 'בדרך 🚚'),
            _PStat(value: '$delivered', label: 'נמסרו ✅'),
          ],
        ),
        const SizedBox(height: BsTokens.space2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(BsTokens.space3),
          decoration: BoxDecoration(
            color: BsTokens.cardLight,
            borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          ),
          child: Text(
            'הכנסות היום (פעילות): ${fMoney(revenue)}',
            style: const TextStyle(color: BsTokens.inkLight, fontSize: 13.5),
          ),
        ),
        const SizedBox(height: BsTokens.space4),

        // ── פעולות ─────────────────────────────────────────────────────────
        Card(
          margin: EdgeInsets.zero,
          color: BsTokens.cardLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Text('⚙️', style: TextStyle(fontSize: 20)),
                title: const Text(
                  'הגדרות',
                  style: TextStyle(color: BsTokens.inkLight),
                ),
                trailing:
                    const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
                onTap: () =>
                    Navigator.of(context).push(CatalogSettingsScreen.route()),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              ListTile(
                leading: const Text('🖥️', style: TextStyle(fontSize: 20)),
                title: const Text(
                  'מעבר בין מסכים',
                  style: TextStyle(color: BsTokens.inkLight),
                ),
                subtitle: const Text(
                  'צפייה בכל לוח — מצב מנהל',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
                ),
                trailing:
                    const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
                onTap: () => showManagerScreensSheet(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

}

/// תיבת סטטיסטיקה קטנה (אותו מראה כמו _PStat בפרופיל השליח).
class _PStat extends StatelessWidget {
  const _PStat({required this.value, required this.label});
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
