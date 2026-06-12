// טאב דוחות של לוח השליח (#72 טאב 3) — COURIER v2(d): דוחות באיכות לוח-העובד.
//   ① סטטיסטיקה חיה — נמסרו / פעילים / POD ממנוע ההזמנות המשותף
//      ([sysOrdersProvider]) ומ-side-car ה-POD ([fulfillmentProvider]).
//   ② מטבעות + רצף — BuildCoins חיים מ-[rewardsProvider] (מוענקים על מסירה,
//      spec (b)) + רצף כן הנגזר מחותמות שעון-המשלוחים (ימים קלנדריים רצופים
//      שמסתיימים היום עם איסוף/מסירה; אין חותמות → '—').
//   ③ % מסירה-ראשונה — מסירות שנמדדו בלי ניסיון חוזר מתוך כלל הנמדדות.
//   ④ מסירות לפי יום — תרשים עמודות שבועי מחותמות deliveredAt (עמודות-Container,
//      בלי ספריית תרשימים) + דלי 'ללא חותמת' כן למסירות שקדמו לשעון.
//   ⑤ זמן איסוף→מסירה — ממוצע + פירוט מהחותמות בלבד; אין מדידות → מצב-ריק כן.
//   ⑥ היסטוריית מסירות — תמונת POD אמיתית (data-URL) כתמונה ממוזערת לחיצה
//      (≥48dp) שנפתחת במסך מלא עם X מפורש; ללא תמונה → טקסט כן, לא-לחיץ.
//   ⑦ שלח דוח-יומי לחנות — הודעת צ׳אט אמיתית לשיחת 'חנות ליפסקי'
//      (th-courier-lipskey, מנוע sys_chat — החנות משתתפת בשיחה) + התראת-פעמון
//      תחת המשתמש 'lipskey' ([workerNotifsProvider]) שפעמון הספק (#82) קורא.
//
// #86.6 (F-13): הערך הכספי ומוני ה"נמסרו"/"POD" בדוח-היומי, בפעמון ובכרטיס-
// הערך מסוננים ל-`courierUser` של הסשן המחובר (ייחוס per-שליח, F-1) — רשומות
// legacy ללא ייחוס אינן נספרות כ"שלי", בכנות. "פעילים" נשאר כלל-מערכתי עם
// תווית כנה (אין ייחוס שליח לפני רגע המסירה).
//
// אין המצאות: כל המספרים נגזרים חיים; מקום שאין בו דאטה אומר זאת בכנות.
//
// SIDE-MAP CONTRACTS:
//   bs.courier-clock.v1  {orderId: {pickedUpAt: iso, deliveredAt: iso,
//                         attempts: n}} — read-only here; WRITTEN by the shared
//                         [stampCourierClock] helper (state/courier_clock.dart,
//                         F-10) at the courierAdvance moments (pickup→transit =
//                         pickedUpAt · transit→delivered = deliveredAt;
//                         attempts defaults to 1, incremented only by a real
//                         failed-attempt flow when one exists).
//   bs.pod-photos.v1     {orderId: 'data:image/...;base64,…'} — the REAL POD
//                         photo captured via pickTaskPhoto (spec (a)), written
//                         by [FulfillmentNotifier.capturePod]. [podPhotosProvider]
//                         below no longer re-reads prefs — it derives the map
//                         synchronously from the in-memory fulfillment state
//                         (hydrated once at load), zero jsonDecode per rebuild
//                         (F-6).

import 'dart:convert';
import 'dart:typed_data';

import 'package:buildsmart/data/contractor_seeds.dart' show fMoney;
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/persona_fulfillment.dart';
import 'package:buildsmart/state/rewards_state.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/state/worker_notifs.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── side-map keys ───────────────────────────────────────────────────────────

/// `{orderId: {pickedUpAt, deliveredAt, attempts}}` — written by the courier
/// flow at the moment of `courierAdvance` (honest wall-clock capture).
const String kCourierClockKey = 'bs.courier-clock.v1';

/// `{orderId: dataUrl}` — the real POD photo (camera-seam data-URL), written by
/// the POD sheet when a photo is actually captured (spec (a)). Documented here
/// for the contract; this file no longer reads the key directly — the photos
/// arrive through the in-memory fulfillment state (F-6).
const String kPodPhotosKey = 'bs.pod-photos.v1';

// ─── courier delivery clock (read-only view of bs.courier-clock.v1) ──────────

/// One order's delivery-clock entry. All stamps optional — an order delivered
/// before the clock landed has neither, a carried order has only [pickedUpAt].
class CourierClockEntry {
  const CourierClockEntry({this.pickedUpAt, this.deliveredAt, this.attempts});

  /// Stamped when the courier confirms receipt (pickup→transit).
  final DateTime? pickedUpAt;

  /// Stamped when the courier marks delivered (transit→delivered).
  final DateTime? deliveredAt;

  /// Delivery attempts — null/absent means 1 (the engine has no re-attempt
  /// flow; a writer increments this only when a real failed attempt happens).
  final int? attempts;

  /// Wall-clock pickup→delivered — null unless both stamps exist and are
  /// ordered (corrupt/clock-skewed pairs are not shown).
  Duration? get pickupToDelivered => pickedUpAt != null &&
          deliveredAt != null &&
          deliveredAt!.isAfter(pickedUpAt!)
      ? deliveredAt!.difference(pickedUpAt!)
      : null;
}

/// The bs.courier-clock.v1 side-map, re-read whenever the order list mutates
/// (a stage advance is exactly when the writer stamps the clock).
final courierClockProvider =
    FutureProvider<Map<String, CourierClockEntry>>((ref) async {
  ref.watch(sysOrdersProvider); // any order mutation → re-read the side-map
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kCourierClockKey);
    if (raw == null || raw.isEmpty) return const {};
    final m = jsonDecode(raw) as Map<String, dynamic>;
    final out = <String, CourierClockEntry>{};
    m.forEach((id, v) {
      if (v is! Map) return;
      final p = DateTime.tryParse('${v['pickedUpAt']}');
      final d = DateTime.tryParse('${v['deliveredAt']}');
      final a = v['attempts'] is num ? (v['attempts'] as num).toInt() : null;
      if (p == null && d == null) return;
      out[id] = CourierClockEntry(pickedUpAt: p, deliveredAt: d, attempts: a);
    });
    return out;
  } on Object catch (_) {
    return const {}; // corrupt payload — honest "no measurements" state
  }
});

/// POD data-URLs derived SYNCHRONOUSLY from the in-memory fulfillment state
/// (the side-car hydrates `podPhoto` from bs.pod-photos.v1 once at load) —
/// zero prefs reads and zero jsonDecode of the photo map per rebuild (F-6).
/// Only real camera data-URLs pass; the legacy `'demo'` marker is filtered.
final podPhotosProvider = Provider<Map<String, String>>((ref) {
  final f = ref.watch(fulfillmentProvider);
  return {
    for (final e in f.entries)
      if (e.value.podPhoto != null &&
          e.value.podPhoto!.startsWith('data:image'))
        e.key: e.value.podPhoto!,
  };
});

// ─── helpers ─────────────────────────────────────────────────────────────────

/// Hebrew week-day letters, Sunday-first (index = weekday % 7) — the
/// worker-reports chart idiom.
const List<String> _kDayLetters = ['א׳', 'ב׳', 'ג׳', 'ד׳', 'ה׳', 'ו׳', 'ש׳'];

String _fmtDuration(Duration d) {
  if (d.inMinutes < 1) return 'פחות מדקה';
  if (d.inHours < 1) return '${d.inMinutes} דק׳';
  if (d.inDays < 1) {
    final m = d.inMinutes % 60;
    return m == 0 ? '${d.inHours} שע׳' : '${d.inHours} שע׳ $m דק׳';
  }
  final h = d.inHours % 24;
  return h == 0 ? '${d.inDays} ימים' : '${d.inDays} ימים $h שע׳';
}

// ─── the tab ─────────────────────────────────────────────────────────────────

class CourierReportsTab extends ConsumerWidget {
  const CourierReportsTab({super.key});

  /// The seeded courier↔store thread (`th-courier-lipskey`, chat_seeds.dart —
  /// participants store+courier) the daily report is posted into.
  static const String kStoreThreadId = 'th-courier-lipskey';

  /// The store board's login username (board_accounts_local.dart) — the bell
  /// notification feed the #82 supplier bell reads.
  static const String kStoreUsername = 'lipskey';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(boardAuthProvider);
    final orders = ref.watch(sysOrdersProvider);
    final fulfillment = ref.watch(fulfillmentProvider);
    final clock = ref.watch(courierClockProvider).asData?.value ??
        const <String, CourierClockEntry>{};
    final podPhotos = ref.watch(podPhotosProvider);
    final rewards = ref.watch(rewardsProvider);

    final delivered =
        orders.where((o) => o.stage == OrderStage.delivered).toList();
    // #86.6 (F-13): the MONEY figure is attributed to the logged-in courier
    // only — delivered orders whose fulfillment record carries MY courierUser
    // stamp. Legacy records without attribution are honestly excluded.
    final su = (session != null && session.role == BoardRole.courier)
        ? session.username
        : null;
    final mineDelivered = su == null
        ? const <SysOrder>[]
        : delivered
            .where((o) => fulfillment[o.id]?.courierUser == su)
            .toList();
    final deliveredSum = mineDelivered.fold<int>(0, (a, o) => a + o.sum);
    const activeStages = [
      OrderStage.ready,
      OrderStage.pickup,
      OrderStage.transit,
    ];
    final active = orders.where((o) => activeStages.contains(o.stage)).length;
    final podCount = orders
        .where((o) =>
            (fulfillment[o.id]?.podCaptured ?? false) ||
            podPhotos.containsKey(o.id))
        .length;

    // ── ② honest streak — consecutive calendar days ENDING TODAY with a
    // pickup/delivery stamp on the courier clock. No stamps at all → '—'.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final activityDays = <DateTime>{};
    for (final e in clock.values) {
      for (final ts in [e.pickedUpAt, e.deliveredAt]) {
        if (ts != null) activityDays.add(DateTime(ts.year, ts.month, ts.day));
      }
    }
    var streak = 0;
    while (activityDays
        .contains(DateTime(today.year, today.month, today.day - streak))) {
      streak++;
    }
    final streakLabel = activityDays.isEmpty ? '—' : '$streak ימים';

    // ── ③ first-attempt % — over MEASURED deliveries only (deliveredAt stamp
    // exists); attempts defaults to 1 (no re-attempt flow in the engine yet).
    final measuredDelivered =
        delivered.where((o) => clock[o.id]?.deliveredAt != null).toList();
    final firstAttempt = measuredDelivered
        .where((o) => (clock[o.id]?.attempts ?? 1) <= 1)
        .length;
    final firstAttemptLabel = measuredDelivered.isEmpty
        ? '—'
        : '${(firstAttempt * 100 / measuredDelivered.length).round()}%';

    // ── ④ weekly buckets — Sunday-first; only deliveries stamped THIS week
    // land on a bar. Delivered orders without a stamp (before the delivery
    // clock landed) go to the honest 'ללא חותמת' bucket.
    final weekStart = today.subtract(Duration(days: today.weekday % 7));
    final perDay = List<int>.filled(7, 0);
    var noStamp = 0;
    for (final o in delivered) {
      final d = clock[o.id]?.deliveredAt;
      if (d == null) {
        noStamp++;
        continue;
      }
      final dayIdx = DateTime(d.year, d.month, d.day).difference(weekStart).inDays;
      if (dayIdx >= 0 && dayIdx < 7) perDay[dayIdx]++;
      // a delivery stamped in a previous week is simply outside this chart.
    }
    final weekTotal = perDay.fold<int>(0, (a, b) => a + b);

    // ── ⑤ pickup→delivered durations — only pairs the clock actually measured.
    final timed = [
      for (final o in delivered)
        if (clock[o.id]?.pickupToDelivered != null) o,
    ];
    Duration? avg;
    if (timed.isNotEmpty) {
      final totalMin = timed.fold<int>(
        0,
        (a, o) => a + clock[o.id]!.pickupToDelivered!.inMinutes,
      );
      avg = Duration(minutes: (totalMin / timed.length).round());
    }

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
          'נתונים חיים ממנוע ההזמנות המשותף — ללא המצאות',
          style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
        ),
        const SizedBox(height: BsTokens.space4),

        // ── ① live stats — derived, not invented. ──
        Row(
          children: [
            _RStat(value: '${delivered.length}', label: 'נמסרו ✅'),
            _RStat(value: '$active', label: 'פעילים 🚚'),
            _RStat(value: '$podCount', label: 'POD 📸'),
          ],
        ),
        const SizedBox(height: BsTokens.space2),

        // ── ② + ③ KPI row: BuildCoins · streak · first-attempt % ──
        Row(
          children: [
            // F-33: מאזן המטבעות הוא overlay אחד לכל המכשיר (bs.rewards.v1,
            // ללא username) — תווית כנה, לא מספר שמתחזה ל-per-שליח.
            _RStat(value: '${rewards.coins}', label: 'BuildCoins (מועדון משותף) 🪙'),
            _RStat(value: streakLabel, label: 'רצף פעילות 🔥'),
            _RStat(value: firstAttemptLabel, label: 'מסירה-ראשונה 🎯'),
          ],
        ),
        const SizedBox(height: BsTokens.space2),
        Text(
          measuredDelivered.isEmpty
              ? 'מטבעות — מאזן מועדון BuildSmart המשותף לכל התפקידים במכשיר (אינו נצבר לשליח בנפרד); הרצף ו-% מסירה-ראשונה נמדדים מחותמות שעון-המשלוחים — עדיין אין מסירות שנמדדו.'
              : 'מטבעות — מאזן מועדון BuildSmart המשותף לכל התפקידים במכשיר (אינו נצבר לשליח בנפרד); הרצף נמדד מחותמות שעון-המשלוחים. מסירה-ראשונה: $firstAttempt מתוך ${measuredDelivered.length} מסירות שנמדדו — ללא ניסיון חוזר.',
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 11.5),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                // F-13: רק מסירות המיוחסות לשליח המחובר (courierUser) נסכמות.
                'סה״כ ערך שנמסר על-ידי: ${fMoney(deliveredSum)}',
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                // ביאור כן (כמו F-3): רשומות legacy בלי ייחוס לא נספרות.
                'מסירות ישנות ללא ייחוס אינן נספרות',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 11.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: BsTokens.space4),

        // ── ④ deliveries-per-day chart ──
        _RCard(
          title: '📅 מסירות לפי יום',
          children: [
            if (weekTotal == 0 && noStamp == 0)
              Text(
                delivered.isEmpty
                    ? 'עוד אין מסירות שהושלמו — מסירה שתסומן "נמסר ללקוח" תופיע כאן.'
                    : 'אין מסירות שנמדדו השבוע.',
                style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
              )
            else ...[
              _WeekBars(counts: perDay, todayIndex: today.weekday % 7),
              if (noStamp > 0) ...[
                const SizedBox(height: BsTokens.space2),
                Text(
                  // Honest bucket — delivered before the delivery clock landed.
                  '🗓️ ללא חותמת: $noStamp ${noStamp == 1 ? 'מסירה' : 'מסירות'} בלי חותמת-זמן (לפני הפעלת שעון-המשלוחים)',
                  style:
                      const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
                ),
              ],
            ],
          ],
        ),
        const SizedBox(height: BsTokens.space3),

        // ── ⑤ avg pickup→delivered ──
        _RCard(
          title: '⏱️ זמן איסוף→מסירה',
          children: [
            if (timed.isEmpty)
              const Text(
                'אין עדיין מדידות זמן — הזמן נמדד אוטומטית מרגע אישור האיסוף ועד המסירה ללקוח.',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
              )
            else ...[
              _KvRow(label: 'ממוצע (${timed.length} מסירות)', value: _fmtDuration(avg!)),
              for (final o in timed)
                _KvRow(
                  label: '📦 ${o.id}',
                  value: _fmtDuration(clock[o.id]!.pickupToDelivered!),
                ),
            ],
          ],
        ),
        const SizedBox(height: BsTokens.space4),

        // ── ⑥ delivered history with tappable POD thumbs ──
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
              child: _DeliveredCard(
                order: o,
                podCaptured: fulfillment[o.id]?.podCaptured ?? false,
                podPhoto: podPhotos[o.id],
                deliveredAt: clock[o.id]?.deliveredAt,
              ),
            ),
        const SizedBox(height: BsTokens.space4),

        // ── ⑦ send daily report to the store — a REAL chat message + bell ──
        Semantics(
          button: true,
          label: 'שלח דוח יומי לחנות',
          child: Material(
            color: BsTokens.brand,
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            child: InkWell(
              key: const ValueKey('courier-send-daily-report'),
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              onTap: () => _sendDailyReport(context, ref),
              child: Container(
                height: 48, // ≥48dp target
                alignment: Alignment.center,
                child: Text(
                  '🏪 שלח דוח-יומי לחנות',
                  style: TextStyle(
                    color: bsOnAccent(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: BsTokens.space2),
        const Text(
          'הדוח נשלח כהודעה אמיתית לשיחת "חנות ליפסקי" (מנוע הצ׳אט המשותף — החנות משתתפת בשיחה) + התראת-פעמון לחנות. מוני המסירות והערך מיוחסים לשליח המחובר בלבד, בלי המצאות.',
          textAlign: TextAlign.center,
          style: TextStyle(color: BsTokens.mutedLight, fontSize: 11.5),
        ),
      ],
    );
  }

  /// Compose the live delivery counts into Hebrew text and post it into the
  /// courier↔store thread ([kStoreThreadId]) via the shared chat engine, PLUS a
  /// bell notification under the store username ([kStoreUsername]) in the
  /// per-username notification store — the surface the #82 supplier bell reads.
  void _sendDailyReport(BuildContext context, WidgetRef ref) {
    // F-13: הדוח יוצא בשם שליח ספציפי — בלי סשן שליח אין את מי לייחס,
    // ולא שולחים דוח עם מספרים של כולם בשם אף-אחד (אין חצי-עבודה).
    final s = ref.read(boardAuthProvider);
    if (s == null || s.role != BoardRole.courier) {
      showToast(context, 'אין שליח מחובר — הדוח לא נשלח');
      return;
    }
    final orders = ref.read(sysOrdersProvider);
    final fulfillment = ref.read(fulfillmentProvider);
    final clock = ref.read(courierClockProvider).asData?.value ??
        const <String, CourierClockEntry>{};

    final delivered =
        orders.where((o) => o.stage == OrderStage.delivered).toList();
    // F-13: כל המונים המיוחסים-אישית מסוננים ל-courierUser של הסשן; רשומות
    // legacy ללא ייחוס אינן נספרות. "פעילים" נשאר כלל-מערכתי עם תווית כנה.
    final mine = delivered
        .where((o) => fulfillment[o.id]?.courierUser == s.username)
        .toList();
    final deliveredSum = mine.fold<int>(0, (a, o) => a + o.sum);
    const activeStages = [
      OrderStage.ready,
      OrderStage.pickup,
      OrderStage.transit,
    ];
    final active = orders.where((o) => activeStages.contains(o.stage)).length;
    final podCount = orders
        .where((o) =>
            fulfillment[o.id]?.courierUser == s.username &&
            (fulfillment[o.id]?.podCaptured ?? false))
        .length;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deliveredToday = mine.where((o) {
      final d = clock[o.id]?.deliveredAt;
      return d != null && DateTime(d.year, d.month, d.day) == today;
    }).length;

    final text = 'דוח יומי — שליח ${s.displayName} (${now.day}.${now.month}):\n'
        '✅ נמסרו היום על-ידי (נמדד): $deliveredToday\n'
        '📦 סה״כ נמסרו על-ידי: ${mine.length}\n'
        '🚚 משלוחים פעילים (כלל המערכת): $active\n'
        '📸 POD שלי: $podCount\n'
        '💰 ערך שנמסר על-ידי: ${fMoney(deliveredSum)}';

    // Guard: send() is a silent no-op on an unknown thread — never toast a
    // success that did not happen (אין חצי-עבודה).
    final exists =
        ref.read(chatEngineProvider).any((t) => t.id == kStoreThreadId);
    if (!exists) {
      showToast(context, 'שיחת החנות לא נמצאה — הדוח לא נשלח');
      return;
    }
    ref
        .read(chatEngineProvider.notifier)
        .send(kStoreThreadId, BsRole.courier, text);
    // Bell notification under the STORE username — persisted in the shared
    // per-username feed; the supplier bell (#82) renders it on the store board.
    ref.read(workerNotifsProvider.notifier).addNotification(
          username: kStoreUsername,
          emoji: '📋',
          title: 'דוח יומי מהשליח 🛵',
          // F-13: גם בפעמון — מוני "שלי" בלבד, עם שם השליח המדווח.
          body:
              '${s.displayName} — נמסרו על-ידו: ${mine.length} · פעילים: $active · ${fMoney(deliveredSum)}',
        );
    showToast(context, '🏪 הדוח נשלח לחנות — שיחה + התראת-פעמון');
  }
}

// ─── building blocks ─────────────────────────────────────────────────────────

/// One delivered-history card: order line + status pill + the POD block —
/// a REAL photo renders as a ≥48dp tappable thumbnail (full-screen viewer with
/// an explicit X close, the shared [showFullPhotoDialog]); no photo keeps the
/// honest non-tappable text.
class _DeliveredCard extends StatefulWidget {
  const _DeliveredCard({
    required this.order,
    required this.podCaptured,
    required this.podPhoto,
    required this.deliveredAt,
  });

  final SysOrder order;
  final bool podCaptured;

  /// The real POD data-URL (bs.pod-photos.v1) — null until spec (a) stores one.
  final String? podPhoto;
  final DateTime? deliveredAt;

  @override
  State<_DeliveredCard> createState() => _DeliveredCardState();
}

class _DeliveredCardState extends State<_DeliveredCard> {
  /// Decoded ONCE per photo string (F-43) — a POD data-URL is ~100KB+ of
  /// base64 and the list rebuilds on every engine mutation; full base64Decode
  /// per build per card was pure waste.
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = decodeDataUrlPhoto(widget.podPhoto);
  }

  @override
  void didUpdateWidget(_DeliveredCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // identical() is the cheap fast-path: the sync podPhotosProvider hands
    // back the SAME string instance unless the record actually mutated.
    if (!identical(oldWidget.podPhoto, widget.podPhoto)) {
      _bytes = decodeDataUrlPhoto(widget.podPhoto);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final podCaptured = widget.podCaptured;
    final deliveredAt = widget.deliveredAt;
    final bytes = _bytes;
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tappable POD thumb — only when a REAL photo exists (≥48dp target).
          if (bytes != null) ...[
            Semantics(
              button: true,
              label: 'הצג אישור מסירה במסך מלא',
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => showFullPhotoDialog(
                  context,
                  bytes,
                  label: '📦 ${order.id} — אישור מסירה',
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    bytes,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    // F-43: decode at thumb resolution — the full-res bytes
                    // are reserved for the full-screen viewer below.
                    cacheWidth:
                        (56 * MediaQuery.devicePixelRatioOf(context)).round(),
                    gaplessPlayback: true,
                    // A corrupt payload renders an honest placeholder, no crash.
                    errorBuilder: (_, __, ___) => Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      color: const Color(0xFFF2F3F5),
                      child: const Text(
                        '📷',
                        style: TextStyle(
                          fontSize: 18,
                          color: BsTokens.mutedLight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: BsTokens.space3),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '📦 ${order.id}',
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
                          // F-34: AA on the light-green pill.
                          color: BsTokens.successDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '👤 ${order.who} · 📍 ${order.site}',
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${order.items} פריטים · ${fMoney(order.sum)} · '
                  // POD line — honest per state: real photo → tap hint; legacy
                  // simulated capture → saved (no file); none → ללא POD.
                  '${bytes != null ? '📸 POD — הקש לתצוגה' : podCaptured ? '📸 POD נשמר ✓' : '📸 ללא POD'}'
                  '${deliveredAt != null ? ' · 🕒 ${deliveredAt!.day}.${deliveredAt!.month} ${deliveredAt!.hour.toString().padLeft(2, '0')}:${deliveredAt!.minute.toString().padLeft(2, '0')}' : ''}',
                  style: const TextStyle(
                    color: BsTokens.mutedLight,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

/// White card with a bold title — the worker-reports card style.
class _RCard extends StatelessWidget {
  const _RCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: BsTokens.space3),
          ...children,
        ],
      ),
    );
  }
}

/// Label-value row (order id ← → metric), RTL-safe.
class _KvRow extends StatelessWidget {
  const _KvRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: BsTokens.inkLight, fontSize: 13.5),
            ),
          ),
          const SizedBox(width: BsTokens.space2),
          Text(
            value,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// The weekly bar chart — plain Containers, no chart lib (the worker-reports
/// idiom). Sunday-first; under the board's RTL Directionality the first child
/// renders on the RIGHT, so ראשון starts at the right edge as a Hebrew
/// calendar reads.
class _WeekBars extends StatelessWidget {
  const _WeekBars({required this.counts, required this.todayIndex});

  /// Delivered count per weekday, index = weekday % 7 (0 = ראשון).
  final List<int> counts;
  final int todayIndex;

  @override
  Widget build(BuildContext context) {
    final maxC = counts.fold<int>(1, (a, b) => b > a ? b : a);
    return SizedBox(
      height: 112,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (counts[i] > 0)
                    Text(
                      '${counts[i]}',
                      style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Container(
                    width: 18,
                    height: 6 + (counts[i] / maxC) * 56,
                    decoration: BoxDecoration(
                      color: counts[i] > 0
                          ? BsTokens.brand
                          : const Color(0xFFEDEDED),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _kDayLetters[i],
                    style: TextStyle(
                      color: i == todayIndex
                          ? BsTokens.brandDark
                          : BsTokens.mutedLight,
                      fontWeight:
                          i == todayIndex ? FontWeight.w800 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
