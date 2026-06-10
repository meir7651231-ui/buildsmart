// #20 — פרופיל מנהל ייעודי (מודל: courier_profile_screen.dart, #73).
//
// מציג את ה-session החי מ-[boardAuthProvider] (שם תצוגה, שם משתמש, מצב demo),
// סטטיסטיקת הזמנות חיה ממנוע ההזמנות המשותף, ושלוש פעולות:
//   ⚙️ הגדרות         → CatalogSettingsScreen (אותו יעד כמו פעולת ההגדרות בלוח)
//   🔁 החלפת תפקיד   → חסום בדיאלוג קוד-מעבר (kRoleSwitchCode) → showRolePicker
//   🚪 יציאה          → confirmDestructive → boardAuthProvider.logout()
//                       (הלוח עצמו נבנה מחדש כשער הרישום — כלל 4).

import 'package:buildsmart/data/board_accounts_local.dart';
import 'package:buildsmart/data/contractor_seeds.dart' show fMoney;
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/screens/catalog_settings_screen.dart';
import 'package:buildsmart/screens/role_picker_sheet.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/toast.dart';
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
              if (session.demo)
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
                leading: const Text('🔁', style: TextStyle(fontSize: 20)),
                title: const Text(
                  'החלפת תפקיד',
                  style: TextStyle(color: BsTokens.inkLight),
                ),
                subtitle: const Text(
                  'מוגן בקוד מעבר',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
                ),
                trailing:
                    const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
                onTap: () => _askRoleSwitch(context),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              ListTile(
                leading: const Text('🚪', style: TextStyle(fontSize: 20)),
                title: const Text(
                  'יציאה מהחשבון',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => _logout(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// #20 — החלפת תפקיד חסומה בדיאלוג קוד (kRoleSwitchCode); קוד נכון פותח את
  /// בורר התפקידים הקיים (showRolePicker).
  Future<void> _askRoleSwitch(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const Directionality(
        textDirection: TextDirection.rtl,
        child: _RoleSwitchCodeDialog(),
      ),
    );
    if ((ok ?? false) && context.mounted) {
      await showRolePicker(context);
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final ok = await confirmDestructive(
      context,
      title: 'יציאה מהחשבון?',
      message: 'תנותק ממרכז השליטה ותחזור למסך הרישום.',
      confirmLabel: 'יציאה',
    );
    if (!ok || !context.mounted) return;
    ref.read(boardAuthProvider.notifier).logout();
    showToast(context, 'התנתקת ממרכז השליטה');
    // מסך עצמאי: קופצים חזרה ללוח — שעכשיו נבנה מחדש כשער הרישום (כלל 4).
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

/// דיאלוג קוד-המעבר — שדה קוד + שגיאה inline על קוד שגוי (בלי לזייף הצלחה).
class _RoleSwitchCodeDialog extends StatefulWidget {
  const _RoleSwitchCodeDialog();

  @override
  State<_RoleSwitchCodeDialog> createState() => _RoleSwitchCodeDialogState();
}

class _RoleSwitchCodeDialogState extends State<_RoleSwitchCodeDialog> {
  final TextEditingController _code = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_code.text.trim() == kRoleSwitchCode) {
      Navigator.pop(context, true);
    } else {
      setState(() => _error = 'קוד שגוי — נסה שוב');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFFFFFFF),
      title: const Text(
        'החלפת תפקיד',
        style: TextStyle(color: BsTokens.inkLight),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'הזן את קוד המעבר כדי לפתוח את בורר התפקידים.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: BsTokens.space3),
          TextField(
            controller: _code,
            obscureText: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            autofocus: true,
            onSubmitted: (_) => _confirm(),
            decoration: InputDecoration(
              hintText: 'קוד מעבר',
              errorText: _error,
              filled: true,
              fillColor: const Color(0xFFF5F5F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('ביטול'),
        ),
        TextButton(
          onPressed: _confirm,
          style: TextButton.styleFrom(foregroundColor: BsTokens.brandDark),
          child: const Text('אישור'),
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
