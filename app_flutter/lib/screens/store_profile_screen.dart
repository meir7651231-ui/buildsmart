// #87.5 · אזור אישי — ספק (F-21) — the supplier board's personal area, in the
// courier_profile_screen.dart pattern (standalone wrapper + embeddable body):
//
//   🏪 כרטיס-זהות     — business-profile overrides (storeProfileProvider,
//                       bs.store-profile.v1, per-username) over the live
//                       [BoardSession]; ✏️ opens the edit sheet (#87.1).
//   📊 סטטיסטיקת חנות — live per-stage counts + active/delivered revenue off
//                       sysOrdersProvider (#87.2) — store-wide BY DESIGN.
//   אזור אישי         — פרופיל עסק · תעודות עסק (#87.3) · מסמכים (#87.4,
//                       SERVER-READY sheet) — ListTile rows ≥48dp.
//   פעולות            — ⚙️ הגדרות ספק (leaf — the settings screen must NOT
//                       link back here, the F-11 loop rule) · 🚪 יציאה
//                       (confirmDestructive → boardAuthProvider.logout()).
//
// [StoreCertsScreen] is COLOCATED here (the SupplierSettingsScreen-in-
// store_dashboard_screen.dart precedent): the business-certificate wallet
// reusing the shared cert model/notifier via storeCertsProvider
// (bs.store-certs.v1) with the kStoreCertPresets quick-add chips.
//
// SERVER-SWAP: the business profile/certificates are local stores until the
// backend lands (see state/store_profile_store.dart); the documents sheet is
// SERVER-READY (no invented amounts).

import 'package:buildsmart/data/contractor_seeds.dart' show fMoney;
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/screens/keyboard_tool_tree.dart'
    show KbToolNode, kbStoreProfileNodes;
import 'package:buildsmart/screens/store_dashboard_screen.dart'
    show SupplierSettingsScreen;
import 'package:buildsmart/screens/store_documents_sheet.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/keyboard_overlay.dart' show kKbGlobal;
import 'package:buildsmart/state/keyboard_screen_tools.dart' show KbScreen;
import 'package:buildsmart/state/store_profile_store.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/config_theme.dart' show cfgRadius;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/contact_actions.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// מסך עצמאי (נדחף מאייקון ה-person ב-AppBar של לוח הספק — F-19: לא עוד
/// ProfileScreen של הקבלן).
class StoreProfileScreen extends ConsumerWidget {
  const StoreProfileScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const StoreProfileScreen());

  static final List<KbToolNode> _kbNodes = kbStoreProfileNodes();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔒 BOARD GATE (חוק: מבחוץ לא רואים כלום) — אחרי logout/החלפת-תפקיד
    // כשהמסך עדיין בערימה נבנה שער הרישום, לא קליפה ריקה (אידיום העובד).
    final session = ref.watch(boardAuthProvider);
    if (session == null || session.role != BoardRole.store) {
      return const WelcomeScreen(boardRole: BoardRole.store);
    }

    final Widget body = Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          elevation: 0,
          title: CfgText(
            'store_profile_screen.appbar_title',
            'אזור אישי — ספק',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black54),
        ),
        body: const SafeArea(child: StoreProfileBody(standalone: true)),
      ),
    );
    return kKbGlobal ? KbScreen(tools: _kbNodes, child: body) : body;
  }
}

/// גוף האזור האישי — משמש גם כטאב 5 'אזור אישי' בלוח הספק (standalone=false,
/// F-21.2: `case 4: return const StoreProfileBody();`) וגם בתוך
/// [StoreProfileScreen] (standalone=true → logout גם קופץ חזרה ללוח).
class StoreProfileBody extends ConsumerWidget {
  const StoreProfileBody({this.standalone = false, super.key});

  final bool standalone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(boardAuthProvider);
    // כלל 4 — בלי session חנות אין תוכן לוח; הלוח עצמו כבר מציג את השער
    // (המסך ה-standalone נושא gate מלא ב-[StoreProfileScreen]).
    if (session == null || session.role != BoardRole.store) {
      return const SizedBox.shrink();
    }

    // #87.1 — ה-overrides של פרופיל-העסק (צריכה צרה דרך select).
    final profile = ref.watch(
      storeProfileProvider.select(
        (m) => m[session.username] ?? const StoreProfile(),
      ),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space5,
      ),
      children: [
        // ── זהות (session חי + overrides מהפרופיל) ────────────────────────
        _StoreIdentityCard(session: session, profile: profile),
        const SizedBox(height: BsTokens.space4),

        // ── סטטיסטיקת חנות (#87.2) — ConsumerWidget צר (F-44) ─────────────
        const _StoreStatsCard(),
        const SizedBox(height: BsTokens.space4),

        // ── אזור אישי (#87.3-4) — פרופיל עסק · תעודות עסק · מסמכים ────────
        _StorePersonalAreaCard(session: session),
        const SizedBox(height: BsTokens.space4),

        // ── פעולות ─────────────────────────────────────────────────────────
        Card(
          margin: EdgeInsets.zero,
          color: BsTokens.cardLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cfgRadius(context)),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Text('⚙️', style: TextStyle(fontSize: 20)),
                title: CfgText(
                  'store_profile_screen.settings_row',
                  'הגדרות ספק',
                  style: TextStyle(color: BsTokens.inkLight, fontSize: 15),
                ),
                trailing:
                    const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
                // ההגדרות נשארות עלה (leaf) בגרף הניווט — אסור שורת-פרופיל
                // בתוך ההגדרות שתחזיר לכאן (לולאת F-11).
                onTap: () =>
                    Navigator.of(context).push(SupplierSettingsScreen.route()),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              ListTile(
                leading: const Text('🚪', style: TextStyle(fontSize: 20)),
                title: CfgText(
                  'store_profile_screen.logout_row',
                  'יציאה מהחשבון',
                  style: TextStyle(
                    // AA על כרטיס לבן (redAccent = 3.19:1 נכשל) — token חוזה 9.
                    color: BsTokens.dangerDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
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

  /// יציאה — נוסח אחיד עם לוח העובד (F-53: כותרת/הודעה/'התנתק', בלי טוסט).
  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final ok = await confirmDestructive(
      context,
      title: 'יציאה מהחשבון?',
      message: 'תנותק מלוח חנות הספק ותחזור למסך ההרשמה.',
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

// ─── identity card (#87.1 — צד הקורא של ה-overrides) ─────────────────────────

/// כרטיס-זהות לבן: אווטאר (לוגו מהפרופיל או 🏪) + שם עסק (override → fallback
/// כן ל-displayName של ה-session), שורת מטא '@username · ספק', ח.פ./טלפון/
/// כתובת כשהוגדרו, צ'יפ 'דמו' אחיד, וכפתור ✏️ שפותח את sheet העריכה.
class _StoreIdentityCard extends StatelessWidget {
  const _StoreIdentityCard({required this.session, required this.profile});

  final BoardSession session;
  final StoreProfile profile;

  @override
  Widget build(BuildContext context) {
    // F-20 — שם-עסק override; ריק → displayName של ה-session (ליפסקי).
    final name = profile.businessName.isNotEmpty
        ? profile.businessName
        : session.displayName;
    final meta = [
      if (profile.businessId.isNotEmpty) 'ח.פ. ${profile.businessId}',
      if (profile.phone.isNotEmpty) '📞 ${profile.phone}',
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
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
          _StoreLogoAvatar(logo: profile.logo, size: 56),
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
                        // F-41 — שם ארוך לא מנפח את הכרטיס.
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
                      // צ'יפ demo אחיד עם לוח העובד (F-52).
                      CfgVisible(
                        // כל צ'יפ ה'דמו' נעלם עם הסתרת האלמנט (לא שלד ריק).
                        'store_profile_screen.demo_chip',
                        child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F3F5),
                          borderRadius:
                              BorderRadius.circular(BsTokens.radiusPill),
                        ),
                        child: CfgText(
                          'store_profile_screen.demo_chip',
                          'דמו',
                          style: TextStyle(
                            color: BsTokens.mutedLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '@${session.username} · ספק',
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
                if (profile.address.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '📍 ${profile.address}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: 13,
                    ),
                  ),
                ],
                // 📞/💬 — call or WhatsApp this supplier (hidden when no phone).
                ContactActions(phone: profile.phone),
              ],
            ),
          ),
          // #87.1 — פותח את עורך פרופיל-העסק (IconButton ≥48dp).
          IconButton(
            tooltip: 'עריכת פרופיל עסק',
            icon: const Icon(Icons.edit_outlined, color: BsTokens.mutedLight),
            onPressed: () =>
                showStoreProfileEditSheet(context, session: session),
          ),
        ],
      ),
    );
  }
}

/// אווטאר החנות — לוגו data-URL שמור (Image.memory בעיגול, פענוח הגנתי דרך
/// decodeDataUrlPhoto) או דיסקת 🏪.
class _StoreLogoAvatar extends StatelessWidget {
  const _StoreLogoAvatar({required this.logo, required this.size});

  final String? logo;
  final double size;

  @override
  Widget build(BuildContext context) {
    // Dual-render (A14): data-URL מפוענח מקומית; כתובת `https://…` שהועלתה
    // (kCloudPhotos ON) נטענת מ-R2 — שניהם דרך [imageProviderForRef]. F-43 —
    // thumb מפוענח לגודל התצוגה (ResizeImage חל על data-URL ו-network כאחד).
    final base = imageProviderForRef(logo);
    if (base != null) {
      final cacheW = (size * MediaQuery.devicePixelRatioOf(context)).round();
      return ClipOval(
        child: Image(
          image: ResizeImage(base, width: cacheW),
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          // payload פגום / טעינה שנכשלה → ברירת-המחדל, לעולם לא קריסה.
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
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
        // דקורטיבי: שם העסק המלא נקרא ממש לידו.
        child: ExcludeSemantics(
          child: Text('🏪', style: TextStyle(fontSize: size * 0.46)),
        ),
      );
}

// ─── store stats (#87.2) ─────────────────────────────────────────────────────

/// סטטיסטיקת חנות חיה — ספירה לכל [OrderStage] (countAt) + מחזור פעיל ומחזור
/// שנמסר, נגזרים מ-sysOrdersProvider בתוך הכרטיס עצמו (ConsumerWidget צר —
/// F-44: הלוח לא נבנה מחדש על כל advance).
///
/// by-design (#87.2 / F-23): ללוח החנות הסטטיסטיקה כלל-חנותית — כל ההזמנות
/// שייכות לחנות אחת (kStores.first); אין כאן צורך בסינון per-username
/// (להבדיל מ-courier_profile, ראה Fulfillment.courierUser). אפס מספרים
/// קשיחים — הכל מהמנוע החי.
class _StoreStatsCard extends ConsumerWidget {
  const _StoreStatsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(sysOrdersProvider);

    return Container(
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
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
          CfgText(
            'store_profile_screen.stats_title',
            '📊 סטטיסטיקת חנות',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: BsTokens.space3),
          // הזמנות לפי שלב — תוויות השלבים מילה-במילה מ-kOrderStageLabel.
          Row(
            children: [
              for (final s in const [
                OrderStage.newOrder,
                OrderStage.preparing,
                OrderStage.ready,
              ])
                _SStat(
                  value: '${orders.countAt(s)}',
                  label: kOrderStageLabel[s]!,
                ),
            ],
          ),
          const SizedBox(height: BsTokens.space2),
          Row(
            children: [
              for (final s in const [
                OrderStage.pickup,
                OrderStage.transit,
                OrderStage.delivered,
              ])
                _SStat(
                  value: '${orders.countAt(s)}',
                  label: kOrderStageLabel[s]!,
                ),
            ],
          ),
          const SizedBox(height: BsTokens.space3),
          // מחזור פעיל (new+preparing+ready) לצד מחזור שהושלם (delivered) —
          // שניהם Σ של o.sum בלבד (שדה המנוע, orders_engine.dart:51).
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(BsTokens.space3),
            decoration: BoxDecoration(
              color: BsTokens.bgLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEDEDED)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💰 מחזור פעיל: ${fMoney(orders.todayRevenue)}',
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '✅ מחזור שנמסר: ${fMoney(orders.deliveredRevenue)}',
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: BsTokens.space2),
          // ביאור כן: כלל-חנותי, נגזר חי — אין כאן מספר 'אישי'.
          CfgText(
            'store_profile_screen.stats_note',
            'נתונים חיים ממנוע ההזמנות — כלל ההזמנות של החנות.',
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

/// תיבת סטטיסטיקה קטנה (אותו מראה כמו _PStat של השליח).
class _SStat extends StatelessWidget {
  const _SStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: BsTokens.space2),
        decoration: BoxDecoration(
          color: BsTokens.bgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEDEDED)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: BsTokens.mutedLight, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── personal-area card (#87.3-4) ────────────────────────────────────────────

/// אזור אישי v2 — שלוש הכניסות בדפוס _PersonalAreaCard של העובד: פרופיל עסק ·
/// תעודות עסק · מסמכים. שורות ListTile ≥48dp, push רגיל (back מחזיר לטאב).
class _StorePersonalAreaCard extends StatelessWidget {
  const _StorePersonalAreaCard({required this.session});

  final BoardSession session;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      // Material מתחת ל-ListTiles — בלעדיו ה-ink נבלע וה-debug assertion של
      // Flutter ('ink splashes may be invisible') נזרק בבניית הטאב.
      child: Material(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        clipBehavior: Clip.antiAlias,
        child: Column(
        children: [
          ListTile(
            leading: const Text('🏪', style: TextStyle(fontSize: 20)),
            title: CfgText(
              'store_profile_screen.profile_row',
              'פרופיל עסק',
              style: TextStyle(color: BsTokens.inkLight, fontSize: 15),
            ),
            subtitle: CfgText(
              'store_profile_screen.profile_row_sub',
              'שם, טלפון, כתובת, ח.פ. ולוגו',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            ),
            trailing:
                const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
            onTap: () =>
                showStoreProfileEditSheet(context, session: session),
          ),
          const Divider(height: 1, color: Color(0xFFF2F3F5)),
          ListTile(
            leading: const Text('🪪', style: TextStyle(fontSize: 20)),
            title: CfgText(
              'store_profile_screen.certs_row',
              'תעודות עסק',
              style: TextStyle(color: BsTokens.inkLight, fontSize: 15),
            ),
            subtitle: CfgText(
              'store_profile_screen.certs_row_sub',
              'רישיון עסק · ביטוח עסק',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            ),
            trailing:
                const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
            onTap: () => Navigator.of(context).push(StoreCertsScreen.route()),
          ),
          const Divider(height: 1, color: Color(0xFFF2F3F5)),
          ListTile(
            leading: const Text('🧾', style: TextStyle(fontSize: 20)),
            title: CfgText(
              'store_profile_screen.docs_row',
              'מסמכים',
              style: TextStyle(color: BsTokens.inkLight, fontSize: 15),
            ),
            subtitle: CfgText(
              'store_profile_screen.docs_row_sub',
              'יחובר עם חיבור השרת',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            ),
            trailing:
                const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
            // SERVER-READY sheet (#87.4) — בלי סכומים מומצאים.
            onTap: () => showStoreDocumentsSheet(context),
          ),
        ],
        ),
      ),
    );
  }
}

// ─── #87.1 · sheet עריכת פרופיל-העסק ─────────────────────────────────────────

/// פותח את עורך פרופיל-העסק (modal bottom sheet, X לסגירה).
Future<void> showStoreProfileEditSheet(
  BuildContext context, {
  required BoardSession session,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EditStoreProfileSheet(session: session),
  );
}

/// עורך פרופיל-העסק — שם עסק · טלפון · כתובת · ח.פ. · לוגו (ה-seam המשותף
/// pickTaskPhoto — מצלמה אמיתית). נשמר per username דרך [storeProfileProvider]
/// (מפתח bs.store-profile.v1) ב-commit יחיד awaited — לא persist-להקשה (F-18);
/// rollback + טוסט כן על כשל quota. 'שעות פעילות' נערך במסך ההגדרות (ה-seam
/// הישן הוא הבעלים היחיד שלו) — ה-sheet הזה לא נוגע בו.
class _EditStoreProfileSheet extends ConsumerStatefulWidget {
  const _EditStoreProfileSheet({required this.session});

  final BoardSession session;

  @override
  ConsumerState<_EditStoreProfileSheet> createState() =>
      _EditStoreProfileSheetState();
}

class _EditStoreProfileSheetState
    extends ConsumerState<_EditStoreProfileSheet> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _bid;
  String? _logo;
  String? _phoneError;
  String? _bidError;

  /// מגן in-flight (F-38): double-tap על "שמור" לא מריץ save כפול / pop כפול.
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = ref.read(storeProfileProvider)[widget.session.username] ??
        const StoreProfile();
    _name = TextEditingController(text: p.businessName);
    _phone = TextEditingController(text: p.phone);
    _address = TextEditingController(text: p.address);
    _bid = TextEditingController(text: p.businessId);
    _logo = p.logo;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _bid.dispose();
    super.dispose();
  }

  /// צילום אמיתי דרך ה-seam המשותף — null = ביטול כן, בלי שינוי.
  Future<void> _pickLogo() async {
    final dataUrl = await pickTaskPhoto(context);
    if (!mounted) return;
    if (dataUrl == null) {
      showToast(context, 'לא נבחרה תמונה');
      return;
    }
    setState(() => _logo = dataUrl);
  }

  Future<void> _save() async {
    if (_saving) return; // מגן double-tap (in-flight)
    final phone = _phone.text.trim();
    // ולידציית פורמט בלבד (#64) — טלפון/ח.פ. אופציונליים, אבל ערך לא-ריק
    // חייב לעבור את בדיקת הפורמט.
    if (phone.isNotEmpty && !validIsraeliMobile(phone)) {
      setState(
        () => _phoneError = 'מספר נייד לא תקין — 10 ספרות, מתחיל ב-05',
      );
      return;
    }
    final bid = _bid.text.trim();
    if (bid.isNotEmpty && !validBusinessId(bid)) {
      setState(() => _bidError = 'ח.פ. חייב להכיל 9 ספרות');
      return;
    }
    setState(() => _saving = true);
    // ה-persist הוא AWAITED: כשל quota (לוגו גדול על web localStorage)
    // מדווח בכנות + rollback ב-store — לא 'הלוגו נשמר ✓' מזויף (F-18).
    final ok = await ref.read(storeProfileProvider.notifier).save(
          widget.session.username,
          StoreProfile(
            // '' = fallback כן (displayName של ה-session / seed החנות, F-20).
            businessName: _name.text.trim(),
            phone: phone,
            address: _address.text.trim(),
            businessId: bid,
            logo: _logo,
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

  @override
  Widget build(BuildContext context) {
    // עטיפת RTL מפורשת — חוק ה-sheets (F-46).
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
                      Expanded(
                        child: CfgText(
                          'store_profile_screen.edit_sheet_title',
                          'עריכת פרופיל עסק',
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
                  // ── לוגו (seam הצילום המשותף) ──
                  Row(
                    children: [
                      _StoreLogoAvatar(logo: _logo, size: 64),
                      const SizedBox(width: BsTokens.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OutlinedButton(
                              onPressed: _pickLogo,
                              child: Text(
                                _logo == null
                                    ? '📷 צלם / העלה לוגו'
                                    : '📷 החלף לוגו',
                              ),
                            ),
                            if (_logo != null)
                              CfgVisible(
                                // כל כפתור 'הסר לוגו' נעלם עם הסתרת האלמנט (לא שלד ריק).
                                'store_profile_screen.remove_logo',
                                child: TextButton(
                                onPressed: () =>
                                    setState(() => _logo = null),
                                child: CfgText(
                                  'store_profile_screen.remove_logo',
                                  'הסר לוגו',
                                  // AA: redAccent על לבן נכשל — token חוזה 9.
                                  style:
                                      TextStyle(color: BsTokens.dangerDark),
                                ),
                              ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: BsTokens.space3),
                  // ── שם העסק ──
                  TextField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    // F-41 — שם-עסק חסום ל-40 תווים (מוטמע בכותרת הלוח).
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(40),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'שם העסק',
                      hintText: 'שם העסק...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: BsTokens.space3),
                  // ── טלפון ──
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    // Latin digits render LTR (phone) under the RTL layout.
                    textDirection: TextDirection.ltr,
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
                  // ── כתובת ──
                  TextField(
                    controller: _address,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'כתובת',
                      hintText: 'רחוב, מספר, עיר...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: BsTokens.space3),
                  // ── ח.פ. ──
                  TextField(
                    controller: _bid,
                    keyboardType: TextInputType.number,
                    // Latin digits render LTR (ח.פ) under the RTL layout.
                    textDirection: TextDirection.ltr,
                    onChanged: (_) {
                      if (_bidError != null) {
                        setState(() => _bidError = null);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'ח.פ. / ע.מ. (אופציונלי)',
                      hintText: '9 ספרות...',
                      errorText: _bidError,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: BsTokens.space4),
                  // ── שמירה ──
                  CfgVisible(
                    // כל כרטיס-הכפתור נעלם עם הסתרת האלמנט (לא שלד ריק).
                    'store_profile_screen.save_profile_btn',
                    child: Material(
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
                          child: CfgText(
                            'store_profile_screen.save_profile_btn',
                            '✓ שמור פרופיל',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              // ניגודיות-גבוהה: לא Colors.white קשיח (F-28).
                              color: bsOnAccent(context),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
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

// ─────────────────────────────────────────────────────────────────────────────
// #87.3 · תעודות עסק — StoreCertsScreen (colocated — ההקצאה של H היא שלושה
// קבצים בלבד; התקדים: SupplierSettingsScreen בתוך store_dashboard_screen.dart)
// ─────────────────────────────────────────────────────────────────────────────

/// 🪪 תעודות עסק (#87.3) — ארנק תעודות-העסק של הספק: reuse מלא של מודל
/// [WorkerCert] + רמזור התפוגה (statusAt) דרך [storeCertsProvider]
/// (bs.store-certs.v1), עם presets ([kStoreCertPresets]) שממלאים את שדה השם
/// בלבד — מנפיק ותוקף נשארים קלט-משתמש (אין המצאות).
class StoreCertsScreen extends ConsumerWidget {
  const StoreCertsScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const StoreCertsScreen());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔒 BOARD GATE (חוק: מבחוץ לא רואים כלום) — מסך לוח-ספק (F-16 לסוג השער:
    // store, לא worker).
    final session = ref.watch(boardAuthProvider);
    if (session == null || session.role != BoardRole.store) {
      return const WelcomeScreen(boardRole: BoardRole.store);
    }
    final username = session.username;
    final certs = ref
        .watch(storeCertsProvider)
        .where((c) => c.username == username)
        .toList()
      ..sort((a, b) => a.expiry.compareTo(b.expiry));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          elevation: 0,
          title: CfgText(
            'store_profile_screen.certs_screen_title',
            '🪪 תעודות עסק',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black54),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            BsTokens.space4,
            BsTokens.space4,
            BsTokens.space4,
            BsTokens.space5,
          ),
          children: [
            _StoreCertsCard(
              certs: certs,
              onAdd: () => _openAddCertSheet(context, ref, username),
              onRemove: (c) => _removeCert(context, ref, c),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeCert(
    BuildContext context,
    WidgetRef ref,
    WorkerCert cert,
  ) async {
    final ok = await confirmDestructive(
      context,
      title: 'מחיקת תעודה?',
      message: '"${cert.name}" תימחק מהארנק לצמיתות.',
      confirmLabel: 'מחק',
    );
    if (!ok || !context.mounted) return;
    ref.read(storeCertsProvider.notifier).remove(cert.id);
    showToast(context, 'התעודה נמחקה');
  }

  /// "הוסף תעודה" bottom sheet — presets · שם · מנפיק · תוקף · צילום
  /// אופציונלי (seam המצלמה). השמירה awaited עם rollback: טוסט הצלחה רק על
  /// כתיבה שבאמת נחתה (F-8).
  Future<void> _openAddCertSheet(
    BuildContext context,
    WidgetRef ref,
    String username,
  ) async {
    final nameCtl = TextEditingController();
    final issuerCtl = TextEditingController();
    DateTime? expiry;
    String? photo;
    String? errName;
    String? errIssuer;
    String? errExpiry;
    var saved = false;
    var saving = false; // מגן in-flight (F-38)

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: BsTokens.cardLight,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(BsTokens.radiusCard)),
      ),
      // עטיפת RTL מפורשת — חוק ה-sheets (F-46).
      builder: (sheetCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (ctx, setSheetState) {
            Future<void> pickExpiry() async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: ctx,
                initialDate: expiry ?? now,
                // תעודה קיימת יכולה להיות כבר פגת-תוקף — מתעדים בכנות
                // (הרמזור האדום אומר זאת); בלי ולידציית 'עתיד בלבד' (F-17).
                firstDate: DateTime(now.year - 10),
                lastDate: DateTime(now.year + 15),
              );
              if (picked != null) setSheetState(() => expiry = picked);
            }

            Future<void> attachPhoto() async {
              // CAM-seam — null = ביטול כן.
              final p = await pickTaskPhoto(ctx);
              if (p == null || p.isEmpty) return;
              setSheetState(() => photo = p);
            }

            Future<void> save() async {
              if (saving) return;
              setSheetState(() {
                errName =
                    nameCtl.text.trim().isEmpty ? 'נא למלא שם תעודה' : null;
                errIssuer =
                    issuerCtl.text.trim().isEmpty ? 'נא למלא מנפיק' : null;
                errExpiry = expiry == null ? 'נא לבחור תוקף' : null;
              });
              if (errName != null || errIssuer != null || errExpiry != null) {
                return;
              }
              saving = true;
              // awaited + rollback ב-notifier (F-8): null = הכתיבה לא נחתה
              // (quota) — בלי 'נשמרה' מזויף.
              final cert = await ref.read(storeCertsProvider.notifier).add(
                    username: username,
                    name: nameCtl.text,
                    issuer: issuerCtl.text,
                    expiry: expiry!,
                    photo: photo,
                  );
              if (!ctx.mounted) return;
              if (cert == null) {
                saving = false;
                showToast(ctx, 'התמונה גדולה מדי — לא נשמרה');
                return; // ה-sheet נשאר פתוח — אפשר לצלם קטן יותר
              }
              saved = true;
              Navigator.of(sheetCtx).pop();
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  BsTokens.space4,
                  BsTokens.space3,
                  BsTokens.space4,
                  BsTokens.space4 + MediaQuery.of(ctx).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CfgText(
                              'store_profile_screen.add_cert_title',
                              '🪪 הוספת תעודה',
                              style: TextStyle(
                                color: BsTokens.inkLight,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          // X לסגירה (חוק ה-sheets).
                          IconButton(
                            tooltip: 'סגור',
                            icon: const Icon(Icons.close,
                                color: BsTokens.mutedLight),
                            onPressed: () => Navigator.of(sheetCtx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: BsTokens.space2),
                      // ── quick-add presets (#87.3) — ממלאים שם בלבד ──
                      Wrap(
                        spacing: BsTokens.space2,
                        runSpacing: BsTokens.space2,
                        children: [
                          for (final p in kStoreCertPresets)
                            Semantics(
                              button: true,
                              label: p,
                              excludeSemantics: true,
                              child: Material(
                                color: BsTokens.cardLight,
                                borderRadius:
                                    BorderRadius.circular(BsTokens.radiusPill),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(
                                      BsTokens.radiusPill),
                                  onTap: () => setSheetState(() {
                                    // preset = שם בלבד; מנפיק/תוקף נשארים
                                    // קלט-משתמש (אין המצאות).
                                    nameCtl.text = p;
                                    errName = null;
                                  }),
                                  child: Container(
                                    constraints:
                                        const BoxConstraints(minHeight: 48),
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: BsTokens.space4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          BsTokens.radiusPill),
                                      border: Border.all(
                                          color: const Color(0xFFE2E2E2)),
                                    ),
                                    child: Text(
                                      p,
                                      style: const TextStyle(
                                        color: BsTokens.inkLight,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: BsTokens.space3),
                      TextField(
                        controller: nameCtl,
                        decoration: InputDecoration(
                          labelText: 'שם התעודה (למשל: רישיון עסק)',
                          errorText: errName,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: BsTokens.space3),
                      TextField(
                        controller: issuerCtl,
                        decoration: InputDecoration(
                          labelText: 'מנפיק (למשל: הרשות המקומית)',
                          errorText: errIssuer,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: BsTokens.space3),
                      // שורת בורר התוקף (≥48dp).
                      Material(
                        color: BsTokens.bgLight,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: pickExpiry,
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 48),
                            padding: const EdgeInsets.symmetric(
                                horizontal: BsTokens.space3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: errExpiry == null
                                    ? const Color(0xFFE2E2E2)
                                    : BsTokens.danger,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Text('📅',
                                    style: TextStyle(fontSize: 16)),
                                const SizedBox(width: BsTokens.space2),
                                Expanded(
                                  child: Text(
                                    expiry == null
                                        ? (errExpiry ?? 'בתוקף עד')
                                        : 'בתוקף עד ${_fmtDate(expiry!)}',
                                    style: TextStyle(
                                      color: expiry == null
                                          ? (errExpiry == null
                                              ? BsTokens.mutedLight
                                              : BsTokens.danger)
                                          : BsTokens.inkLight,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: BsTokens.space3),
                      // צילום אופציונלי דרך seam המצלמה.
                      Material(
                        color: BsTokens.cardLight,
                        borderRadius:
                            BorderRadius.circular(BsTokens.radiusPill),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(BsTokens.radiusPill),
                          onTap: attachPhoto,
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 48),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(BsTokens.radiusPill),
                              border:
                                  Border.all(color: const Color(0xFFE2E2E2)),
                            ),
                            child: photo == null
                                ? CfgText(
                                    'store_profile_screen.attach_photo_btn',
                                    '📷 צרף צילום תעודה (לא חובה)',
                                    style: TextStyle(
                                      color: BsTokens.inkLight,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CfgText(
                                        'store_profile_screen.photo_attached',
                                        '📷 צילום צורף ✓',
                                        style: TextStyle(
                                          color: BsTokens.inkLight,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: BsTokens.space2),
                                      // X 'הסר צילום' — מטרת-מגע 48dp (F-17:
                                      // התבנית הייתה 40dp, מתחת לרצפה).
                                      Tooltip(
                                        message: 'הסר צילום',
                                        child: Semantics(
                                          button: true,
                                          label: 'הסר צילום',
                                          child: InkWell(
                                            customBorder:
                                                const CircleBorder(),
                                            onTap: () => setSheetState(
                                                () => photo = null),
                                            child: const SizedBox(
                                              width: 48,
                                              height: 48,
                                              child: Icon(
                                                Icons.close,
                                                size: 18,
                                                color: BsTokens.mutedLight,
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
                      const SizedBox(height: BsTokens.space3),
                      CfgVisible(
                        // כל כרטיס-הכפתור נעלם עם הסתרת האלמנט (לא שלד ריק).
                        'store_profile_screen.save_cert_btn',
                        child: Material(
                        color: BsTokens.brand,
                        borderRadius:
                            BorderRadius.circular(BsTokens.radiusPill),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(BsTokens.radiusPill),
                          onTap: save,
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 48),
                            alignment: Alignment.center,
                            child: CfgText(
                              'store_profile_screen.save_cert_btn',
                              '💾 שמור תעודה',
                              style: TextStyle(
                                // ניגודיות-גבוהה: לא Colors.white קשיח (F-28).
                                color: bsOnAccent(ctx),
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
            );
          },
        ),
      ),
    );
    nameCtl.dispose();
    issuerCtl.dispose();
    // טוסט רק על שמירה שבאמת נחתה (ה-sheet נסגר דרך save).
    if (saved && context.mounted) {
      showToast(context, '🪪 התעודה נשמרה בארנק');
    }
  }
}

/// כרטיס ארנק תעודות-העסק — מצב-ריק כן, שורות תעודה עם רמזור תפוגה, וכפתור
/// הוספה ≥48dp.
class _StoreCertsCard extends StatelessWidget {
  const _StoreCertsCard({
    required this.certs,
    required this.onAdd,
    required this.onRemove,
  });

  final List<WorkerCert> certs;
  final VoidCallback onAdd;
  final void Function(WorkerCert) onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '🪪 תעודות עסק (${certs.length})',
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: BsTokens.space3),
          if (certs.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: BsTokens.space3),
              child: CfgText(
                'store_profile_screen.certs_empty',
                'אין תעודות בארנק עדיין — הוסף את הראשונה.',
                style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
              ),
            )
          else
            for (final c in certs)
              _StoreCertRow(cert: c, onRemove: () => onRemove(c)),
          CfgVisible(
            // כל כפתור 'הוסף תעודה' נעלם עם הסתרת האלמנט (לא שלד ריק).
            'store_profile_screen.add_cert_btn',
            child: Semantics(
            button: true,
            label: 'הוסף תעודה',
            // הטקסט הפנימי זהה לתווית — בלי הכרזה כפולה ל-TalkBack (F-50).
            excludeSemantics: true,
            child: Material(
              color: BsTokens.brand,
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              child: InkWell(
                borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                onTap: onAdd,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  alignment: Alignment.center,
                  child: CfgText(
                    'store_profile_screen.add_cert_btn',
                    '➕ הוסף תעודה',
                    style: TextStyle(
                      // ניגודיות-גבוהה: לא Colors.white קשיח (F-28).
                      color: bsOnAccent(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }
}

/// שורת תעודה — שם, `מנפיק · בתוקף עד`, רמזור תפוגה (מילה-במילה: 'פג תוקף' /
/// 'פג בקרוב' / 'בתוקף'), thumbnail אמיתי לחיץ (showFullPhotoDialog —
/// Stack-based, בטוח לכל צורת תמונה, F-42) ומחיקה.
class _StoreCertRow extends StatelessWidget {
  const _StoreCertRow({required this.cert, required this.onRemove});

  final WorkerCert cert;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (cert.statusAt(DateTime.now())) {
      CertExpiryStatus.expired => ('פג תוקף', BsTokens.danger),
      CertExpiryStatus.expiringSoon => ('פג בקרוב', BsTokens.warnText),
      CertExpiryStatus.valid => ('בתוקף', BsTokens.successDark),
    };
    // פענוח הגנתי — data-URL שמור או URL מועלה (kCloudPhotos ON) דרך
    // [imageProviderForRef]; payload לא-תקין שומר את ה-📷 הסטטי, לעולם לא קריסה.
    final photoProvider = imageProviderForRef(cert.photo);
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space2),
      child: Container(
        padding: const EdgeInsets.all(BsTokens.space3),
        decoration: BoxDecoration(
          color: BsTokens.bgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEDEDED)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          cert.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: BsTokens.inkLight,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (photoProvider != null) ...[
                        const SizedBox(width: BsTokens.space2),
                        // thumbnail אמיתי → צפייה מלאה (מטרת-מגע 48dp).
                        Semantics(
                          button: true,
                          label: 'הצג צילום תעודה במסך מלא',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => showFullPhotoRefDialog(
                              context,
                              cert.photo,
                              label: cert.name,
                            ),
                            child: Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image(
                                  // F-43 — thumb מפוענח לגודל התצוגה (ResizeImage
                                  // חל על data-URL ו-network כאחד).
                                  image: ResizeImage(
                                    photoProvider,
                                    width: (40 *
                                            MediaQuery.devicePixelRatioOf(
                                                context))
                                        .round(),
                                  ),
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                  // payload פגום / טעינה שנכשלה → ה-📷 הכן.
                                  errorBuilder: (_, __, ___) => const Text(
                                    '📷',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ] else if (cert.photo != null) ...[
                        const SizedBox(width: BsTokens.space2),
                        const Text('📷', style: TextStyle(fontSize: 13)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${cert.issuer.isEmpty ? '' : '${cert.issuer} · '}'
                    'בתוקף עד ${_fmtDate(cert.expiry)}',
                    style: const TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: BsTokens.space2),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              tooltip: 'מחק תעודה',
              icon: const Icon(Icons.delete_outline,
                  color: BsTokens.mutedLight),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

String _fmtDate(DateTime d) => '${d.day}.${d.month}.${d.year}';
