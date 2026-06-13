// #73 + #86 — פרופיל שליח ייעודי (וגם גוף טאב "אזור אישי" של לוח השליח, #72 טאב 4).
//
// v2 (#86): כרטיס-זהות עם overrides נערכים (שם/טלפון/תמונה/סוג-רכב-מועדף —
// `courierProfileProvider`, מפתח bs.courier-profile.v1, per-username), סטטיסטיקת
// מסירות PER-COURIER (מסונן לפי Fulfillment.courierUser — תיקון הבאג הגלובלי,
// #86.6), כרטיס "אזור אישי" (נוכחות · טפסים · תעודות נהג · תלושי שכר) וכרטיס
// פעולות:
//   ⚙️ הגדרות שליח   → CourierSettingsScreen
//   🔁 החלפת תפקיד   → חסום בדיאלוג קוד-מעבר (kRoleSwitchCode) → showRolePicker
//   🚪 יציאה          → confirmDestructive → boardAuthProvider.logout()
//                       (הלוח עצמו נבנה מחדש כשער הרישום — כלל 4).
//
// SERVER-SWAP: ייחוס המסירות נגזר מ-side-car ה-fulfillment המקומי
// (courierUser, bs.fulfillment.v1); עם חיבור השרת הסינון יהיה לפי ה-uid
// המאומת. תלושי השכר הם sheet מוכן-לשרת ("יחובר עם חיבור השרת") — reuse של
// showWorkerPayslipsSheet ה-role-agnostic, בלי לשכפל ובלי להמציא סכומים.

import 'dart:convert';

import 'package:buildsmart/data/board_accounts_local.dart';
import 'package:buildsmart/data/contractor_seeds.dart' show fMoney;
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/screens/courier_attendance_screen.dart';
import 'package:buildsmart/screens/courier_certs_screen.dart';
import 'package:buildsmart/screens/courier_forms_screen.dart';
import 'package:buildsmart/screens/courier_settings_screen.dart';
import 'package:buildsmart/screens/role_picker_sheet.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/screens/worker_payslips_sheet.dart';
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/courier_profile_store.dart';
import 'package:buildsmart/state/persona_fulfillment.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/contact_actions.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// מסך עצמאי (נדחף מאייקון הפרופיל ב-AppBar של לוח השליח).
class CourierProfileScreen extends ConsumerWidget {
  const CourierProfileScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const CourierProfileScreen());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔒 BOARD GATE (חוק: מבחוץ לא רואים כלום) — אחרי logout/החלפת-תפקיד
    // כשהמסך עדיין בערימה נבנה שער הרישום, לא קליפה ריקה (האידיום של העובד).
    final session = ref.watch(boardAuthProvider);
    if (session == null || session.role != BoardRole.courier) {
      return const WelcomeScreen(boardRole: BoardRole.courier);
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          elevation: 0,
          title: const Text(
            'פרופיל שליח',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black54),
        ),
        body: const SafeArea(child: CourierProfileBody(standalone: true)),
      ),
    );
  }
}

/// גוף הפרופיל — משמש גם כטאב "אזור אישי" בלוח השליח (standalone=false) וגם
/// בתוך [CourierProfileScreen] (standalone=true → logout גם קופץ חזרה ללוח).
class CourierProfileBody extends ConsumerWidget {
  const CourierProfileBody({this.standalone = false, this.vehicle, super.key});

  final bool standalone;

  /// רכב-המשמרת מהלוח (null = מסך עצמאי / לא נבחר רכב). מזין את סמנטיקת
  /// "בדרך" רכב-זכאי; כשאין רכב נופלים ל"סוג רכב מועדף" מהפרופיל, ואם גם הוא
  /// ריק — מציגים מונה כלל-מערכתי עם תווית כנה (אין מספר שמתחזה לאישי).
  final String? vehicle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(boardAuthProvider);
    // כלל 4 — בלי session שליח אין תוכן לוח; הלוח עצמו כבר מציג את השער
    // (המסך ה-standalone נושא gate מלא ב-[CourierProfileScreen]).
    if (session == null || session.role != BoardRole.courier) {
      return const SizedBox.shrink();
    }

    // #86.1 — ה-overrides של הפרופיל (צריכה צרה דרך select).
    final profile = ref.watch(
      courierProfileProvider.select(
        (m) => m[session.username] ?? const CourierProfile(),
      ),
    );

    final orders = ref.watch(sysOrdersProvider);

    // #86.6 — סטטיסטיקה PER-COURIER: רק הזמנות delivered שה-side-car מייחס
    // לשליח המחובר (Fulfillment.courierUser). נגזר דרך select של רשומת-מונים —
    // הטאב נבנה מחדש רק כשהמונים עצמם משתנים (ערכי המפה מחזיקים POD ענקיים).
    // רשומות legacy (courierUser == null) לא נספרות כ"שלי" — אין המצאות.
    final stats = ref.watch(
      fulfillmentProvider.select((m) {
        var delivered = 0;
        var pod = 0;
        var sum = 0;
        var unattributed = 0;
        for (final o in orders) {
          if (o.stage != OrderStage.delivered) continue;
          final f = m[o.id];
          if (f != null && f.courierUser == session.username) {
            delivered++;
            sum += o.sum;
            if (f.podCaptured) pod++;
          } else if (f == null || f.courierUser == null) {
            unattributed++;
          }
        }
        return (
          delivered: delivered,
          pod: pod,
          sum: sum,
          unattributed: unattributed,
        );
      }),
    );

    // "בדרך" — אותה סמנטיקת רכב-זכאי כמו טאב המשלוחים (courierJobs):
    // רכב-משמרת → רכב-מועדף מהפרופיל (רק id חוקי) → מונה גלובלי עם תווית כנה.
    final preferred =
        kVehicleRank.containsKey(profile.preferredHaul)
            ? profile.preferredHaul
            : null;
    final effectiveVehicle = vehicle ?? preferred;
    final int onRoad;
    final String onRoadLabel;
    if (effectiveVehicle != null) {
      onRoad = orders
          .courierJobs(effectiveVehicle)
          .where(
            (o) =>
                o.stage == OrderStage.pickup || o.stage == OrderStage.transit,
          )
          .length;
      onRoadLabel = 'בדרך (מתאים לרכב) 🚚';
    } else {
      onRoad = orders
          .where(
            (o) =>
                o.stage == OrderStage.pickup || o.stage == OrderStage.transit,
          )
          .length;
      onRoadLabel = 'בדרך (כלל המערכת)';
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space5,
      ),
      children: [
        // ── זהות (session חי + overrides מהפרופיל) ────────────────────────
        _CourierIdentityCard(session: session, profile: profile),
        const SizedBox(height: BsTokens.space4),

        // ── מסירות — סטטיסטיקה חיה (שלי בלבד, #86.6) ──────────────────────
        const Text(
          'מסירות — סטטיסטיקה',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: BsTokens.space2),
        Row(
          children: [
            _PStat(value: '${stats.delivered}', label: 'נמסרו על-ידי ✅'),
            _PStat(value: '$onRoad', label: onRoadLabel),
            _PStat(value: '${stats.pod}', label: 'POD שלי 📸'),
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
            'סה״כ ערך שנמסר על-ידי: ${fMoney(stats.sum)}',
            style: const TextStyle(color: BsTokens.inkLight, fontSize: 13.5),
          ),
        ),
        if (stats.unattributed > 0) ...[
          const SizedBox(height: BsTokens.space2),
          // ביאור כן: רשומות שנמסרו לפני נחיתת הייחוס per-courier נשארות
          // ללא courierUser ולא נספרות כ"שלי" (back-compat, לא ממציאים).
          Text(
            'מסירות ישנות ללא ייחוס אינן נספרות (${stats.unattributed})',
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
          ),
        ],
        const SizedBox(height: BsTokens.space4),

        // ── אזור אישי (#86.7) — נוכחות · טפסים · תעודות נהג · תלושי שכר ───
        const _CourierPersonalAreaCard(),
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
                  'הגדרות שליח',
                  style: TextStyle(color: BsTokens.inkLight),
                ),
                trailing:
                    const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
                onTap: () =>
                    Navigator.of(context).push(CourierSettingsScreen.route()),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              ListTile(
                leading: const Text('🔁', style: TextStyle(fontSize: 20)),
                title: const Text(
                  'החלפת תפקיד',
                  style: TextStyle(color: BsTokens.inkLight),
                ),
                subtitle: const Text(
                  'מוגן בקוד',
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
                    // AA על כרטיס לבן (redAccent = 3.19:1 נכשל) — token חוזה 9.
                    color: BsTokens.dangerDark,
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

  /// #73 — החלפת תפקיד חסומה בדיאלוג קוד (kRoleSwitchCode); קוד נכון פותח את
  /// בורר התפקידים הקיים (showRolePicker).
  Future<void> _askRoleSwitch(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const Directionality(
        textDirection: TextDirection.rtl,
        child: _RoleSwitchCodeDialog(),
      ),
    );
    if (ok == true && context.mounted) {
      await showRolePicker(context);
    }
  }

  /// יציאה — נוסח אחיד עם לוח העובד (כותרת/הודעה/'התנתק', בלי טוסט).
  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final ok = await confirmDestructive(
      context,
      title: 'יציאה מהחשבון?',
      message: 'תנותק מלוח השליח ותחזור למסך ההרשמה.',
      confirmLabel: 'התנתק',
    );
    if (!ok || !context.mounted) return;
    ref.read(boardAuthProvider.notifier).logout();
    // במסך עצמאי: קופצים חזרה ללוח — שעכשיו נבנה מחדש כשער הרישום (כלל 4).
    if (standalone && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

// ─── identity card (#86.1 — צד הקורא של ה-overrides) ─────────────────────────

/// כרטיס-זהות לבן: אווטאר (תמונת-פרופיל או 🛵) + שם (override → fallback כן
/// ל-displayName של ה-session), שורת מטא '@username · שליח', רכב-מועדף וטלפון
/// כשהוגדרו, צ'יפ 'דמו' אחיד, וכפתור ✏️ שפותח את sheet העריכה.
class _CourierIdentityCard extends StatelessWidget {
  const _CourierIdentityCard({required this.session, required this.profile});

  final BoardSession session;
  final CourierProfile profile;

  @override
  Widget build(BuildContext context) {
    final name = profile.displayName.isNotEmpty
        ? profile.displayName
        : session.displayName;
    // רכב-מועדף מוצג רק כשה-id חוקי (kVehicleRank) — בלי haulInfo fallback
    // שממציא רכב שהמשתמש לא בחר.
    final hasHaul = kVehicleRank.containsKey(profile.preferredHaul);
    final meta = [
      if (hasHaul)
        '${haulInfo(profile.preferredHaul).ic} '
            '${haulInfo(profile.preferredHaul).name}',
      if (profile.phone.isNotEmpty) '📞 ${profile.phone}',
    ].join(' · ');

    return Container(
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
          _CourierAvatar(photo: profile.photo, size: 56),
          const SizedBox(width: BsTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    if (session.demo) ...[
                      const SizedBox(width: BsTokens.space2),
                      // צ'יפ demo אחיד עם לוח העובד.
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F3F5),
                          borderRadius:
                              BorderRadius.circular(BsTokens.radiusPill),
                        ),
                        child: const Text(
                          'דמו',
                          style: TextStyle(
                            color: BsTokens.mutedLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '@${session.username} · שליח',
                  style: const TextStyle(
                    color: BsTokens.mutedLight,
                    fontSize: 13,
                  ),
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: 13,
                    ),
                  ),
                ],
                // 📞/💬 — call or WhatsApp this courier (hidden when no phone).
                ContactActions(phone: profile.phone),
              ],
            ),
          ),
          // #86.1 — פותח את עורך הפרופיל (IconButton ≥48dp).
          IconButton(
            tooltip: 'עריכת פרופיל',
            icon: const Icon(Icons.edit_outlined, color: BsTokens.mutedLight),
            onPressed: () =>
                showCourierProfileEditSheet(context, session: session),
          ),
        ],
      ),
    );
  }
}

/// אווטאר השליח — תמונת data-URL שמורה (Image.memory בעיגול) או דיסקת 🛵.
class _CourierAvatar extends StatelessWidget {
  const _CourierAvatar({required this.photo, required this.size});

  final String? photo;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = photo;
    if (p != null && p.startsWith('data:image') && p.contains(',')) {
      try {
        final bytes = base64Decode(p.substring(p.indexOf(',') + 1));
        return ClipOval(
          child: Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            // F-43 — אווטאר מפוענח לגודל התצוגה, לא full-res.
            cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
            // payload פגום מרנדר את ברירת-המחדל — לעולם לא קריסה.
            errorBuilder: (_, __, ___) => _fallback(),
          ),
        );
      } on FormatException catch (_) {
        // base64 שבור — נופלים לאווטאר ברירת-המחדל.
      }
    }
    return _fallback();
  }

  Widget _fallback() => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFFFFF0E3),
          shape: BoxShape.circle,
        ),
        // דקורטיבי: השם המלא נקרא ממש לידו.
        child: ExcludeSemantics(
          child: Text('🛵', style: TextStyle(fontSize: size * 0.46)),
        ),
      );
}

// ─── personal-area card (#86.7) ──────────────────────────────────────────────

/// אזור אישי v2 — ארבע הכניסות בדפוס _PersonalAreaCard של העובד: נוכחות ·
/// טפסים · תעודות נהג · תלושי שכר. שורות ListTile ≥48dp, push רגיל (back
/// מחזיר לטאב הפרופיל). תלושי-שכר = reuse של ה-sheet המשותף ה-role-agnostic
/// (אסור לשכפל ואסור להמציא בו סכומים).
class _CourierPersonalAreaCard extends StatelessWidget {
  const _CourierPersonalAreaCard();

  @override
  Widget build(BuildContext context) {
    return Container(
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
          ListTile(
            leading: const Text('🕐', style: TextStyle(fontSize: 20)),
            title: const Text(
              'נוכחות',
              style: TextStyle(color: BsTokens.inkLight, fontSize: 15),
            ),
            subtitle: const Text(
              'כניסה/יציאה ודוח חודשי',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            ),
            trailing:
                const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
            onTap: () =>
                Navigator.of(context).push(CourierAttendanceScreen.route()),
          ),
          const Divider(height: 1, color: Color(0xFFF2F3F5)),
          ListTile(
            leading: const Text('📄', style: TextStyle(fontSize: 20)),
            title: const Text(
              'טפסים',
              style: TextStyle(color: BsTokens.inkLight, fontSize: 15),
            ),
            subtitle: const Text(
              'טופס 101 · בקשת חופשה · אישור מחלה',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            ),
            trailing:
                const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
            onTap: () =>
                Navigator.of(context).push(CourierFormsScreen.route()),
          ),
          const Divider(height: 1, color: Color(0xFFF2F3F5)),
          ListTile(
            leading: const Text('🪪', style: TextStyle(fontSize: 20)),
            title: const Text(
              'תעודות נהג',
              style: TextStyle(color: BsTokens.inkLight, fontSize: 15),
            ),
            subtitle: const Text(
              'רישיון נהיגה · ביטוח רכב · רישיון רכב',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            ),
            trailing:
                const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
            onTap: () =>
                Navigator.of(context).push(CourierCertsScreen.route()),
          ),
          const Divider(height: 1, color: Color(0xFFF2F3F5)),
          ListTile(
            leading: const Text('💰', style: TextStyle(fontSize: 20)),
            title: const Text(
              'תלושי שכר',
              style: TextStyle(color: BsTokens.inkLight, fontSize: 15),
            ),
            subtitle: const Text(
              'יחובר עם חיבור השרת',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            ),
            trailing:
                const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
            // reuse כמו-שהוא — ה-sheet role-agnostic ומוכן-לשרת (#86.5).
            onTap: () => showWorkerPayslipsSheet(context),
          ),
        ],
      ),
    );
  }
}

// ─── #86.1 · sheet עריכת הפרופיל ─────────────────────────────────────────────

/// פותח את עורך פרופיל-השליח (modal bottom sheet, X לסגירה).
Future<void> showCourierProfileEditSheet(
  BuildContext context, {
  required BoardSession session,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EditCourierProfileSheet(session: session),
  );
}

/// עורך הפרופיל — שם-תצוגה · טלפון · סוג רכב מועדף (צ'יפים מ-kHaulTypes) ·
/// תמונת-פרופיל (ה-seam המשותף pickTaskPhoto — מצלמה אמיתית). נשמר per
/// username דרך [courierProfileProvider] (מפתח bs.courier-profile.v1); כל שדה
/// ריק שומר fallback כן (שם → session.displayName, בלי תמונה → 🛵).
class _EditCourierProfileSheet extends ConsumerStatefulWidget {
  const _EditCourierProfileSheet({required this.session});

  final BoardSession session;

  @override
  ConsumerState<_EditCourierProfileSheet> createState() =>
      _EditCourierProfileSheetState();
}

class _EditCourierProfileSheetState
    extends ConsumerState<_EditCourierProfileSheet> {
  late final TextEditingController _name;
  late final TextEditingController _phone;

  /// id מתוך kHaulTypes ('small'|'van'|'truck') או '' = לא נבחר.
  late String _preferredHaul;
  String? _photo;
  String? _phoneError;

  /// מגן in-flight: double-tap על "שמור" לא מריץ save כפול / pop כפול.
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = ref.read(courierProfileProvider)[widget.session.username] ??
        const CourierProfile();
    _name = TextEditingController(
      text: p.displayName.isNotEmpty
          ? p.displayName
          : widget.session.displayName,
    );
    _phone = TextEditingController(text: p.phone);
    // ערך persisted לא-מוכר ננקה ל-'' (לא-נבחר) — בלי haulInfo fallback
    // שממציא העדפה.
    _preferredHaul =
        kVehicleRank.containsKey(p.preferredHaul) ? p.preferredHaul : '';
    _photo = p.photo;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  /// צילום אמיתי דרך ה-seam המשותף — null = ביטול כן, בלי שינוי.
  Future<void> _pickPhoto() async {
    final dataUrl = await pickTaskPhoto(context);
    if (!mounted) return;
    if (dataUrl == null) {
      showToast(context, 'לא נבחרה תמונה');
      return;
    }
    setState(() => _photo = dataUrl);
  }

  Future<void> _save() async {
    if (_saving) return; // מגן double-tap (in-flight)
    final phone = _phone.text.trim();
    // ולידציית פורמט בלבד (#64) — הטלפון אופציונלי, אבל ערך לא-ריק חייב
    // להיות נייד ישראלי תקין.
    if (phone.isNotEmpty && !validIsraeliMobile(phone)) {
      setState(
        () => _phoneError = 'מספר נייד לא תקין — 10 ספרות, מתחיל ב-05',
      );
      return;
    }
    setState(() => _saving = true);
    final name = _name.text.trim();
    // ה-persist הוא AWAITED: כשל quota (תמונה גדולה על web localStorage)
    // מדווח בכנות + rollback ב-store — לא '✓ נשמר' מזויף.
    final ok = await ref.read(courierProfileProvider.notifier).save(
          widget.session.username,
          CourierProfile(
            // שמירת '' משמרת את ה-fallback הכן ל-displayName של ה-session.
            displayName: name == widget.session.displayName ? '' : name,
            phone: phone,
            preferredHaul: _preferredHaul,
            photo: _photo,
          ),
        );
    if (!mounted) return;
    if (!ok) {
      setState(() => _saving = false); // מאפשר retry עם תמונה קטנה יותר
      showToast(context, 'התמונה גדולה מדי — לא נשמרה');
      return; // ה-sheet נשאר פתוח
    }
    showToast(context, '✓ הפרופיל נשמר');
    Navigator.of(context).pop();
  }

  /// צ'יפ רכב אחד — מילוי מותג כשנבחר; הקשה חוזרת מנקה (≥48dp). הצ'יפים
  /// נבנים מ-kHaulTypes — אין רשימת-רכבים חדשה.
  Widget _haulChip(HaulType h) {
    final on = _preferredHaul == h.id;
    return Semantics(
      button: true,
      selected: on,
      label: h.name,
      excludeSemantics: true,
      child: Material(
        color: on ? BsTokens.brand : BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: () => setState(() => _preferredHaul = on ? '' : h.id),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: BsTokens.space4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              border: on ? null : Border.all(color: const Color(0xFFE2E2E2)),
            ),
            child: Text(
              '${h.ic} ${h.name}',
              style: TextStyle(
                color: on ? bsOnAccent(context) : BsTokens.inkLight,
                fontSize: 13.5,
                fontWeight: on ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        // שומר את השדות מעל המקלדת.
        padding:
            EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: BsTokens.cardLight,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(BsTokens.radiusCard),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(BsTokens.space4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'עריכת פרופיל',
                          style: TextStyle(
                            color: BsTokens.inkLight,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      // X לסגירה (חוק ה-sheets).
                      IconButton(
                        tooltip: 'סגור',
                        icon: const Icon(
                          Icons.close,
                          color: BsTokens.mutedLight,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: BsTokens.space2),
                  // ── תמונת פרופיל (seam הצילום המשותף) ──
                  Row(
                    children: [
                      _CourierAvatar(photo: _photo, size: 64),
                      const SizedBox(width: BsTokens.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OutlinedButton(
                              onPressed: _pickPhoto,
                              child: Text(
                                _photo == null
                                    ? '📷 הוסף תמונת פרופיל'
                                    : '📷 החלף תמונה',
                              ),
                            ),
                            if (_photo != null)
                              TextButton(
                                onPressed: () =>
                                    setState(() => _photo = null),
                                child: const Text(
                                  'הסר תמונה',
                                  // AA: redAccent על לבן נכשל — token חוזה 9.
                                  style:
                                      TextStyle(color: BsTokens.dangerDark),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: BsTokens.space3),
                  // ── שם תצוגה ──
                  TextField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(40),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'שם תצוגה',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: BsTokens.space3),
                  // ── טלפון ──
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    onChanged: (_) {
                      if (_phoneError != null) {
                        setState(() => _phoneError = null);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'טלפון (אופציונלי)',
                      hintText: '050-1234567',
                      errorText: _phoneError,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: BsTokens.space3),
                  // ── סוג רכב מועדף (במקום "התמחות" של העובד) ──
                  const Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      'סוג רכב מועדף',
                      style: TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: BsTokens.space2),
                  Wrap(
                    spacing: BsTokens.space2,
                    runSpacing: BsTokens.space2,
                    children: [
                      for (final h in kHaulTypes) _haulChip(h),
                    ],
                  ),
                  const SizedBox(height: BsTokens.space4),
                  // ── שמירה ──
                  Material(
                    color: BsTokens.brand,
                    borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(BsTokens.radiusPill),
                      onTap: _saving ? null : _save,
                      child: Opacity(
                        opacity: _saving ? 0.6 : 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          child: Text(
                            '✓ שמור פרופיל',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: bsOnAccent(context),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── role-switch code dialog ─────────────────────────────────────────────────

/// דיאלוג קוד-המעבר — שדה קוד + שגיאה inline על קוד שגוי (בלי לזייף הצלחה).
/// טקסטים מיושרים לנוסח לוח העובד.
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
            'מעבר בין לוחות מוגן בקוד. הזן את קוד החלפת התפקיד:',
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
              // תווית נראית גם בזמן הקלדה (לא hint חולף בלבד).
              labelText: 'קוד מעבר',
              hintText: 'קוד',
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

/// תיבת סטטיסטיקה קטנה (אותו מראה כמו _Stat בלוח).
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
