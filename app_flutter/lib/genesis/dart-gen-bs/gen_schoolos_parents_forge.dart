// 🎨 schoolos_parents.dart בעור-forge (GENMAX·G12d) — מחולל דטרמיניסטי: skin-golden.mjs · הזהב לא נגע (טעינה-לצד, חוק-7) · עור: kpi=ForgeStatPlain · navTile=ForgeHubTile · stat=ForgeStatPlain · hero=ForgeStatPlain · button=ForgeSoftButton · statusChip=ForgeIntelPill · banner=ForgeSectionPill · emptyState=ForgeSearchEmptyState · mediaRow=ForgeContactTile · section=ForgeTitledSection · frame=ForgeStripPanelFrame · segmented=ForgeSegmentedPillToggleSelection · chip=ForgeFacetChip · meter=ForgeLinearProgressStatus · glass=ForgeGlassCard · timeline=ForgeNotifRow
//   החלפות: stat×0 · hero×1 · statRow×25 · button×47 · statusChip×30 · banner×24 · emptyState×11 · mediaRow×13 · section×5 · segmented×5 · meter×1 · frame×4 · timeline×4 · BareStat ב-Row נשאר DS (רצועת-4) · צבעי-מצב-DS לא מועברים · חיפוש/טבלאות/פילטרים = DS (אטומי-forge של קלט הם ציור, לא שדה)
// 👪 SchoolOS · הורים ותקשורת — נבנה בדרך (THE-WAY · הכרעה 23-ב/ג/ד) לפי SPEC-PARENTS-FULL-2026-09-04.
// מטרה: "ששום הורה לא יגלה משהו על ילדו מאוחר מדי — ושהצוות יגיע לכל הורה בערוץ הנכון,
//         בזמן הנכון, בטון הנכון, ויידע שההודעה נקראה."
// פעולות-יסוד (צעד-2): איתור · הערכת-מצב-קשר · זיהוי-חריגה · הכרעה (ערוץ/זמן/העלאה) · ביצוע · אימות · הרשאה.
// כל חלקיק-תובנה = כמה אטומים (תצוגה⊕לוגיקה) מהמדף (מאור + בנייה-חכמה + האורקל); עובדה = אטום-יחיד.
// 🔒 חוק-6: זהות/פרטי-קשר של הורים (שם · טלפון · מייל · איש-קשר-חירום) **מוזרקים בהצבה** דרך
//    `ParentsScreen(identity: …)` — לעולם לא בקובץ. בלי הזרקה ⇒ השקע מואר "🔒 מוזרק-בהצבה" (חוק-7).
// ⏱ אין Date.now במנוע: today/nowHour מוזרקים (דטרמיניסטי).
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_pure.dart';
import '../dart-ui-bs/ds/ds_seam.dart';
import '../dart-ui-bs/ds/ds_search.dart'; // איתור: חיפוש-מבוקר (value+onChanged)
import '../dart-ui-bs/ds/ds_table.dart'; // רשימה: טבלה-אמיתית (labels+rows) — לא DataGrid המזייף
import '../dart-ui-bs/ds/ds_field.dart'; // קלט-טקסט (הודעה/פנייה/הערה)
import '../dart-ui-bs/ds/ds_enum_field.dart'; // קלט-מקבוצה (ערוץ/סוג-אישור/תבנית)
import '../dart-ui-bs/ds/ds_date_field.dart'; // קלט-תאריך (מועד-אישור/פגישה)
import '../dart-ui-bs/ds/ds_bars.dart'; // השוואה-חזותית מנתונים-חיים (ערוצים · שפות)
import '../dart-ui-bs/bare_stat.dart'; // KPI · עובדה (ערך+תווית) — לא StatBlock המזייף
import '../dart-ui-bs/pure_bubble.dart'; // שיחה: בועת-הודעה עם receipt (sent/delivered/read) — מודעת-RTL
import '../dart-ui-bs/premium/surfaces/gradient_card.dart';
import '../dart-ui-bs/premium/surfaces/glass_card.dart'; // מיכל-פאנל (child שרירותי)
import '../dart-ui-bs/premium/surfaces/stat_hero.dart';
import '../dart-ui-bs/premium/lists/media_row.dart';
import '../dart-ui-bs/premium/lists/stat_row.dart'; // יחס (נקראו-מתוך-נשלחו · אישורים-מתוך-נשלחו)
import '../dart-ui-bs/premium/lists/timeline_item.dart'; // לוג-שליחה/אודיט — לא timeline_flow המזייף
import '../dart-ui-bs/premium/actions/segmented_switch.dart';
import '../dart-ui-bs/premium/actions/soft_button.dart';
import '../dart-ui-bs/premium/feedback/alert_banner.dart';
import '../dart-ui-bs/premium/feedback/status_chip.dart';
import '../dart-ui-bs/premium/feedback/empty_state.dart';
import '../dart-ui-bs/premium/feedback/badge_count.dart'; // מונה לא-נקרא (int count אמיתי)
import '../dart-ui-bs/premium/showcase/premium_toggle.dart'; // מתג-מבוקר (הרשאת-מדיה · חסימה)
import '../dart-ui-bs/screens__manager_dashboard_screen/filter_chip_pill.dart'; // צ׳יפ-סינון מבוקר
import '../dart-maor/support-unread.dart'; // מונה לא-נקרא פר-צד (maor supportChat.ts:82-86)
import '../dart-maor/sort-support-threads.dart'; // תיבה: לא-נקרא ראשון, אח"כ חדש-ראשון (יציב)
import '../dart-maor/sort-support-msgs.dart'; // שיחה: מיון-הודעות לפי at עולה
import '../dart-maor/support-msg-time.dart'; // HH:MM מ-ISO
import '../dart-maor/support-day-label.dart'; // היום/אתמול/dd/mm/yyyy
import '../dart-maor/support-preview.dart'; // קיצור-תצוגה של הודעה-אחרונה
import '../dart-maor/sanitize-support-text.dart'; // ניקוי+תקרה לפני שליחה
import '../dart-maor/is-sendable-support-text.dart'; // שער-שליחה (לא-ריק אחרי ניקוי)
import '../dart-maor/support-msg-max.dart'; // תקרת-אורך הודעה (2000)
import '../dart-maor/wa-digits.dart'; // טלפון⇒ספרות-E.164 (או null = לא-שליח)
import '../dart-maor/wa-link.dart'; // קישור wa.me עם טקסט
import '../dart-maor/bulk-wa-recipients.dart'; // נמענים-לשידור: דדופ לפי-ספרות, דילוג-על-לא-תקין
import '../dart-maor/phone-issue.dart'; // אבחון-טלפון (חסר-0 · קצר · אורך-חריג)
import '../dart-maor/format-israeli-phone.dart'; // עיצוב-תצוגה של טלפון
import '../dart-maor/render-template.dart'; // תבנית⇒טקסט (override מ-config או ברירת-מחדל)
import '../dart-maor/template-defs.dart'; // תבניות-המדף (wa.dialer/wa.payment/…)
import '../dart-maor/language-options.dart'; // שפות-הבית מהמדף (עברית/יידיש/רוסית/צרפתית/אנגלית)
import '../dart-maor/intel-day-diff.dart'; // ימים-מאז (today−iso) — הקרבה-בזמן
import '../dart-maor/task-overdue.dart'; // פנייה-חורגת (due<today ∧ !doneAt)
import '../dart-maor/open-tasks-for.dart'; // פניות-פתוחות ממוינות pri→due→createdAt
import '../dart-maor/cockpit-at-risk.dart'; // "שקט": ענה-בעבר ושותק ≥N ימים (דירוג-שתיקה)
import '../dart-maor/upcoming-meetings.dart'; // פגישות בחלון (shopEvents kind=meeting)
import '../dart-maor/expiring-intakes.dart'; // דבר-עם-תוקף שפוקע תוך חלון (⇒ אישורים-פגים)
import '../dart-maor/shop-expiry-warn-days.dart'; // סף-אזהרה =7 ימים
import '../dart-maor/count-by.dart'; // קיבוץ-ספירה (ערוץ · שפה · סטטוס)
import '../dart-maor/block-reason.dart'; // שבת/שישי/חוה"מ ⇒ סיבת-חסימה (שעות-מנוחה)
import '../dart-maor/heb-parts.dart'; // תאריך⇒חלקי-תאריך-עברי (שקע ל-blockReason)
import '../dart-maor/time-to-min.dart'; // 'HH:MM'⇒דקות (שעות-נוחות-לפנייה)
import '../dart-maor/tz-stale-days.dart'; // 90 ימים = קשר-לא-מעודכן
import '../dart-maor/role-of.dart'; // תפקיד-לפי-זהות admin/teacher/staff
import '../dart-maor/can-granted-action.dart'; // גידור-פעולה פר-מפתח
import '../dart-maor/smart-filter.dart'; // איתור: סינון+מיון-לפי-ציון
import '../dart-maor/smart-score.dart'; // איתור: ניקוד רב-מילתי AND
import '../dart-maor/norm-search.dart'; // איתור: נרמול-עברי
import '../dart-maor/finder-matches.dart'; // חריגה: סינון-רב-צירי AND על db.families
import '../dart-maor/to-csv.dart'; // ייצוא-לוג
import '../dart-maor/csv-escape.dart'; // הגנת-תא
import '../dart-maor/export-allowed.dart'; // שער-יציאת-מידע
import '../dart-maor/audit-report-lines.dart'; // דוח-אודיט טקסטואלי
import '../dart-data-maor/quiet-hours-data.dart'; // QUIET_FROM=21 · QUIET_TO=8 · PREFIX_TZ (דאטה-מדף)
import '../dart-data-maor/block-reason-data.dart'; // FULL_HOLIDAYS
import '../dart-data-maor/block-reason-strings.dart'; // BLOCK_REASON_T
import '../dart-data-maor/phone-issue-strings.dart'; // PHONE_ISSUE_T
import '../dart-data-maor/support-day-label-strings.dart'; // SUPPORT_DAY_LABEL_T
import '../dart/digest_lines.dart'; // סיכום (urgent/approvals/vacations) — term מוזרק ⇒ סיכום-שבועי-להורה
import '../dart-forge-bs/card/card.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/status/status.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/feedback/feedback.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/header/header.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/selection/selection.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/list/list.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

const _acc = DsTokens.accent;
const _danger = Color(0xFFF43F5E);
const _ok = Color(0xFF34D399);
const _muted = Color(0xFF9AA0BE);
const _ink = Color(0xFFF2F3FF);
const _warning = Color(0xFFF59E0B);

// ═══════════════════════════ דאטה-אמת + מנוע-טהור (אפס-DOM) ═══════════════════════════
// 🔴 סכמה = רק צורות עם מקור-אמת באימפריה (§20-ג אפס-זיוף):
//   משפחה  ← maor families {id, members[], phone, phone2…} (find-caller.dart:24-40 · run-audit.dart) — זהות=מוזרקת.
//   שיחה   ← maor supportChats {unreadAdmin, unreadUser, lastAt, lastFrom, lastText} + msgs {from, text, at}
//            (new/boxes/support-chat.contract.md · supportChat.ts:82-86); status-הודעה ← buildsmart MsgStatus
//            {pending, sent, delivered, failed} (app_flutter/lib/state/sys_chat.dart:60) — "נקרא" = unreadUser==0 (רמת-שיחה).
//   אישור  ← buildsmart ConsentDialog (מדיה) + תוקף בצורת ShopIntake.expiry (expiring-intakes.dart:22).
//   פנייה  ← maor tasks {assignee, title, ref{kind,id}, pri, due, doneAt, createdAt} (open-tasks-for.dart · task-overdue.dart).
//   פגישה  ← maor shopEvents {kind:'meeting', date, time, done, title} (upcoming-meetings.dart:29-36).
//   ערוץ   ← maor waLink/waDigits (וואטסאפ) · buildsmart notif-settings (push/sms/email) · שפה ← languageOptions.
//   שעות-מנוחה ← new/boxes/quiet-hours.mjs (contactWindow · QUIET_FROM/TO · PREFIX_TZ) · שבת/חג ← blockReason.
//   ⛔ ללא-מקור ⇒ מקום-שמור בלבד (portalLogin · eSignature · portalPayment · liveChat · translation-API).
class _PrData {
  static String today = '2026-09-04'; // הזרקת-תאריך (VERIFY: אין Date.now במנוע)
  static int nowHour = 20; // הזרקת-שעה-מקומית של הצוות (לשעות-מנוחה)
  static const orgName = 'תיכון עתיד';
  static const orgUtcOffset = 3; // ישראל (PREFIX_TZ '+972'.off)
  static const unreadAlertDays = 3; // לא-נקרא > 72 שעות
  static const silentDays = 14; // "שקט": ענה בעבר ושותק ≥14 יום
  static const unresponsiveSends = 2; // "לא-מגיב": ≥2 הודעות-צוות רצופות בלי מענה

  // ─── משפחות (זהות מוזרקת · חוק-6). שדות-אמת שאינם-זהות: ילדים+כיתות · הורים{תפקיד,ערוץ,שפה,שעות} ·
  //     משמורת · חסום · הרשאת-מדיה · עדכון-קשר · הערה · עדכון. contactUpdatedAt ← tzStaleDays (90).
  static const families = <Map<String, dynamic>>[
    {'id': 'f1', 'kids': [{'first': 'נועה', 'cls': 'י׳-1', 'sid': 's101'}, {'first': 'איתי', 'cls': 'ז׳-2', 'sid': 's102'}],
      'p1': {'role': 'אם', 'channel': 'wa', 'lang': 'עברית', 'hours': '16:00-21:00'}, 'p2': {'role': 'אב', 'channel': 'sms', 'lang': 'עברית', 'hours': '18:00-22:00'},
      'media': true, 'contactUpdatedAt': '2026-08-20', 'note': 'מעדיפים וואטסאפ', 'updatedAt': '2026-08-20'},
    {'id': 'f2', 'kids': [{'first': 'דניאל', 'cls': 'י׳-1', 'sid': 's103'}],
      'p1': {'role': 'אם', 'channel': 'sms', 'lang': 'רוסית', 'hours': '17:00-20:00'},
      'media': true, 'contactUpdatedAt': '2026-07-01', 'updatedAt': '2026-07-01'},
    {'id': 'f3', 'kids': [{'first': 'מאיה', 'cls': 'ח׳-3', 'sid': 's104'}],
      'p1': {'role': 'אם', 'channel': 'phone', 'lang': 'עברית', 'hours': '19:00-22:00'}, 'p2': {'role': 'אב', 'channel': 'wa', 'lang': 'עברית', 'hours': '16:00-19:00'},
      'custody': {'restricted': true, 'p2': ['attendance']}, // הסדר-ראייה: אב רואה נוכחות בלבד (רגיש)
      'media': false, 'contactUpdatedAt': '2026-09-01', 'note': 'הסדר-ראייה — לתאם דרך האם', 'updatedAt': '2026-09-01'},
    {'id': 'f4', 'kids': [{'first': 'יונתן', 'cls': 'ט׳-2', 'sid': 's105'}],
      'p1': {'role': 'אם', 'channel': 'email', 'lang': 'צרפתית', 'hours': '20:00-23:00'}, 'p2': {'role': 'אב', 'channel': 'wa', 'lang': 'צרפתית', 'hours': ''},
      'blocked': 'p2', // הורה-לא-מורשה (הנהלה)
      'media': true, 'contactUpdatedAt': '2026-08-28', 'updatedAt': '2026-08-28'},
    {'id': 'f5', 'kids': [{'first': 'רון', 'cls': 'י׳-1', 'sid': 's106'}],
      'p1': {'role': 'אב', 'channel': 'wa', 'lang': 'עברית', 'hours': '16:00-20:00'},
      'media': true, 'contactUpdatedAt': '2026-08-10', 'updatedAt': '2026-08-10'},
    {'id': 'f6', 'kids': [{'first': 'שרה', 'cls': 'ז׳-2', 'sid': 's107'}, {'first': 'משה', 'cls': 'ה׳-1', 'sid': 's108'}],
      'p1': {'role': 'אם', 'channel': 'wa', 'lang': 'יידיש', 'hours': '10:00-14:00'}, 'p2': {'role': 'אב', 'channel': 'phone', 'lang': 'יידיש', 'hours': '20:00-22:00'},
      'guardian': 'סבתא', // אפוטרופוס נוסף (זהות מוזרקת · תפקיד בלבד)
      'media': false, 'contactUpdatedAt': '2026-09-02', 'updatedAt': '2026-09-02'},
    {'id': 'f7', 'kids': [{'first': 'Emma', 'cls': 'ח׳-3', 'sid': 's109'}],
      'p1': {'role': 'אם', 'channel': 'wa', 'lang': 'אנגלית', 'hours': '15:00-20:00'},
      'media': true, 'contactUpdatedAt': '2026-08-30', 'note': 'משפחה בחו״ל חלק מהשנה', 'updatedAt': '2026-08-30'},
    {'id': 'f8', 'kids': [{'first': 'לירון', 'cls': 'ט׳-2', 'sid': 's110'}],
      'p1': {'role': 'אם', 'channel': 'sms', 'lang': 'עברית', 'hours': ''},
      'media': true, 'contactUpdatedAt': '2026-04-15', 'updatedAt': '2026-04-15'},
  ];
  static Map<String, dynamic> fam(String id) => families.firstWhere((f) => f['id'] == id);
  static String famLabel(Map<String, dynamic> f) => 'משפחת ${(f['kids'] as List).map((k) => (k as Map)['first']).join(' · ')}';
  static String kidsLabel(Map<String, dynamic> f) => (f['kids'] as List).map((k) => '${(k as Map)['first']} (${k['cls']})').join(' · ');
  static List<String> classesOf(Map<String, dynamic> f) => [for (final k in f['kids'] as List) '${(k as Map)['cls']}'];
  static List<String> parentKeys(Map<String, dynamic> f) => [if (f['p1'] != null) 'p1', if (f['p2'] != null) 'p2'];
  static Map<String, dynamic> parent(Map<String, dynamic> f, String pk) => (f[pk] as Map).cast<String, dynamic>();

  // ─── שיחות (maor supportChats) · הודעות (from/at/text + via + status) ───
  //   unreadUser>0 = ההורה טרם קרא · unreadAdmin>0 = הצוות טרם קרא · lastFrom = מי-דיבר-אחרון.
  static const threads = <Map<String, dynamic>>[
    {'famId': 'f1', 'unreadAdmin': 1, 'unreadUser': 0, 'lastAt': '2026-09-03T18:40', 'lastFrom': 'user', 'lastText': 'תודה, נאשר עד מחר'},
    {'famId': 'f2', 'unreadAdmin': 0, 'unreadUser': 2, 'lastAt': '2026-08-30T09:10', 'lastFrom': 'admin', 'lastText': 'תזכורת: אישור טיול'},
    {'famId': 'f3', 'unreadAdmin': 0, 'unreadUser': 0, 'lastAt': '2026-09-02T12:05', 'lastFrom': 'admin', 'lastText': 'סיכום פגישה נשלח'},
    {'famId': 'f4', 'unreadAdmin': 2, 'unreadUser': 0, 'lastAt': '2026-09-04T08:15', 'lastFrom': 'user', 'lastText': 'מתי אפשר לדבר עם היועצת?'},
    {'famId': 'f5', 'unreadAdmin': 0, 'unreadUser': 3, 'lastAt': '2026-09-01T14:00', 'lastFrom': 'admin', 'lastText': 'בקשה שלישית: נא לחזור אלינו'},
    {'famId': 'f6', 'unreadAdmin': 0, 'unreadUser': 0, 'lastAt': '2026-09-03T11:30', 'lastFrom': 'user', 'lastText': 'קיבלנו, תודה'},
    {'famId': 'f7', 'unreadAdmin': 0, 'unreadUser': 1, 'lastAt': '2026-09-03T22:10', 'lastFrom': 'admin', 'lastText': 'Trip consent form attached'},
  ];
  static const messages = <Map<String, dynamic>>[
    {'famId': 'f1', 'from': 'admin', 'to': 'p1', 'text': 'שלום, מצורף טופס אישור לטיול השנתי — נשמח לאישור עד 10.9', 'at': '2026-09-02T16:20', 'via': 'wa', 'status': 'delivered'},
    {'famId': 'f1', 'from': 'user', 'to': 'p1', 'text': 'קיבלנו. יש שאלה לגבי הסעה חזרה', 'at': '2026-09-03T18:20', 'via': 'wa', 'status': 'delivered'},
    {'famId': 'f1', 'from': 'user', 'to': 'p1', 'text': 'תודה, נאשר עד מחר', 'at': '2026-09-03T18:40', 'via': 'wa', 'status': 'delivered'},
    {'famId': 'f2', 'from': 'admin', 'to': 'p1', 'text': 'שלום, דניאל נעדר היום ללא הודעה — הכל בסדר?', 'at': '2026-08-27T10:00', 'via': 'sms', 'status': 'delivered'},
    {'famId': 'f2', 'from': 'admin', 'to': 'p1', 'text': 'תזכורת: אישור טיול', 'at': '2026-08-30T09:10', 'via': 'sms', 'status': 'delivered'},
    {'famId': 'f3', 'from': 'user', 'to': 'p1', 'text': 'נוכל להיפגש ביום שני?', 'at': '2026-09-01T19:30', 'via': 'phone', 'status': 'delivered'},
    {'famId': 'f3', 'from': 'admin', 'to': 'p1', 'text': 'סיכום פגישה נשלח', 'at': '2026-09-02T12:05', 'via': 'wa', 'status': 'delivered'},
    {'famId': 'f4', 'from': 'admin', 'to': 'p1', 'text': 'Bonjour, le formulaire de consentement média a expiré', 'at': '2026-09-03T15:00', 'via': 'email', 'status': 'delivered'},
    {'famId': 'f4', 'from': 'user', 'to': 'p1', 'text': 'שלחנו טופס חדש', 'at': '2026-09-04T08:00', 'via': 'email', 'status': 'delivered'},
    {'famId': 'f4', 'from': 'user', 'to': 'p1', 'text': 'מתי אפשר לדבר עם היועצת?', 'at': '2026-09-04T08:15', 'via': 'email', 'status': 'delivered'},
    {'famId': 'f5', 'from': 'admin', 'to': 'p1', 'text': 'שלום, רון נעדר 3 ימים ללא הודעה', 'at': '2026-08-25T09:00', 'via': 'wa', 'status': 'delivered'},
    {'famId': 'f5', 'from': 'admin', 'to': 'p1', 'text': 'ניסינו להשיג אתכם — נשמח שתחזרו אלינו', 'at': '2026-08-28T11:00', 'via': 'wa', 'status': 'delivered'},
    {'famId': 'f5', 'from': 'admin', 'to': 'p1', 'text': 'בקשה שלישית: נא לחזור אלינו', 'at': '2026-09-01T14:00', 'via': 'sms', 'status': 'failed'},
    {'famId': 'f6', 'from': 'admin', 'to': 'p1', 'text': 'טופס תרופות אושר, תודה', 'at': '2026-09-03T11:00', 'via': 'wa', 'status': 'delivered'},
    {'famId': 'f6', 'from': 'user', 'to': 'p1', 'text': 'קיבלנו, תודה', 'at': '2026-09-03T11:30', 'via': 'wa', 'status': 'delivered'},
    {'famId': 'f7', 'from': 'admin', 'to': 'p1', 'text': 'Trip consent form attached', 'at': '2026-09-03T22:10', 'via': 'wa', 'status': 'delivered'},
  ];
  // ─── אישורים (מה/מתי/סטטוס · תוקף בצורת expiry) ───
  static const consents = <Map<String, dynamic>>[
    {'id': 'c1', 'famId': 'f1', 'kind': 'trip', 'title': 'טיול שנתי · גליל', 'sentAt': '2026-09-02', 'due': '2026-09-10', 'status': 'pending', 'reminders': 0},
    {'id': 'c2', 'famId': 'f2', 'kind': 'trip', 'title': 'טיול שנתי · גליל', 'sentAt': '2026-08-27', 'due': '2026-09-06', 'status': 'pending', 'reminders': 1},
    {'id': 'c3', 'famId': 'f4', 'kind': 'media', 'title': 'צילום ופרסום מדיה', 'sentAt': '2025-09-01', 'due': '2026-08-31', 'status': 'pending', 'reminders': 2},
    {'id': 'c4', 'famId': 'f6', 'kind': 'meds', 'title': 'מתן תרופה בבית-הספר', 'sentAt': '2026-08-25', 'due': '2026-09-01', 'status': 'received', 'reminders': 0},
    {'id': 'c5', 'famId': 'f7', 'kind': 'trip', 'title': 'טיול שנתי · גליל', 'sentAt': '2026-09-03', 'due': '2026-09-08', 'status': 'pending', 'reminders': 0},
    {'id': 'c6', 'famId': 'f3', 'kind': 'media', 'title': 'צילום ופרסום מדיה', 'sentAt': '2026-08-20', 'due': '2026-09-05', 'status': 'declined', 'reminders': 0},
    {'id': 'c7', 'famId': 'f5', 'kind': 'trip', 'title': 'טיול שנתי · גליל', 'sentAt': '2026-08-25', 'due': '2026-09-03', 'status': 'pending', 'reminders': 2},
  ];
  // ─── פניות-הורים (צורת-task: pri/due/doneAt/createdAt · ref{kind:'family'}) ───
  static const inquiries = <Map<String, dynamic>>[
    {'id': 'q1', 'famId': 'f4', 'title': 'בקשה לשיחה עם היועצת', 'pri': 1, 'createdAt': '2026-09-04T08:15', 'due': '2026-09-07', 'doneAt': '', 'answeredAt': '', 'assignee': 'counselor', 'sensitive': true, 'ref': {'kind': 'family', 'id': 'f4'}},
    {'id': 'q2', 'famId': 'f5', 'title': 'ערעור על חיסור', 'pri': 2, 'createdAt': '2026-08-20T10:00', 'due': '2026-08-27', 'doneAt': '', 'answeredAt': '', 'assignee': 'teacher-1', 'sensitive': false, 'ref': {'kind': 'family', 'id': 'f5'}},
    {'id': 'q3', 'famId': 'f1', 'title': 'הסעה חזרה מהטיול', 'pri': 2, 'createdAt': '2026-09-03T18:20', 'due': '2026-09-06', 'doneAt': '', 'answeredAt': '2026-09-03T19:05', 'assignee': 'teacher-1', 'sensitive': false, 'ref': {'kind': 'family', 'id': 'f1'}},
    {'id': 'q4', 'famId': 'f6', 'title': 'שינוי כתובת למשלוח תעודה', 'pri': 3, 'createdAt': '2026-08-28T09:00', 'due': '2026-09-02', 'doneAt': '2026-08-29T12:00', 'answeredAt': '2026-08-28T15:00', 'assignee': 'sec', 'sensitive': false, 'ref': {'kind': 'family', 'id': 'f6'}},
    {'id': 'q5', 'famId': 'f3', 'title': 'עדכון הסדר-ראייה', 'pri': 1, 'createdAt': '2026-08-30T08:00', 'due': '2026-09-01', 'doneAt': '2026-08-31T10:00', 'answeredAt': '2026-08-30T12:00', 'assignee': 'mgmt', 'sensitive': true, 'ref': {'kind': 'family', 'id': 'f3'}},
  ];
  // ─── פגישות (shopEvents kind=meeting) ───
  static const meetings = <Map<String, dynamic>>[
    {'id': 'm1', 'famId': 'f1', 'kind': 'meeting', 'date': '2026-09-07', 'time': '17:30', 'done': false, 'title': 'שיחת-הורים תחילת שנה', 'summarySent': false},
    {'id': 'm2', 'famId': 'f3', 'kind': 'meeting', 'date': '2026-09-01', 'time': '18:00', 'done': true, 'title': 'תיאום הסדר-ראייה', 'summarySent': true},
    {'id': 'm3', 'famId': 'f5', 'kind': 'meeting', 'date': '2026-09-08', 'time': '16:00', 'done': false, 'title': 'ועדת-מעקב נוכחות', 'summarySent': false},
    {'id': 'm4', 'famId': 'f6', 'kind': 'meeting', 'date': '2026-09-02', 'time': '10:30', 'done': true, 'title': 'שיחת-הכרות', 'summarySent': false},
    {'id': 'm5', 'famId': 'f4', 'kind': 'meeting', 'date': '2026-09-10', 'time': '19:00', 'done': false, 'title': 'פגישה עם היועצת', 'summarySent': false},
  ];
  // ─── הזנות-בין-מודולים (שקעי-אינטגרציה · דמו ריאליסטי) ───
  //   נוכחות ⇒ חיסור-לא-מוצדק (הודעה-אוטו) · גבייה ⇒ דגל-חוב · תלמידים ⇒ מבט-הילד (נוכחות/ממוצע)
  static const absenceFeed = <Map<String, dynamic>>[
    {'sid': 's103', 'famId': 'f2', 'date': '2026-09-03', 'justified': false},
    {'sid': 's106', 'famId': 'f5', 'date': '2026-09-03', 'justified': false},
    {'sid': 's101', 'famId': 'f1', 'date': '2026-09-02', 'justified': true},
  ];
  static const feesFeed = <String, int>{'f5': 1450, 'f8': 320}; // חוב-פתוח (₪) מהגבייה
  static const childFeed = <String, Map<String, dynamic>>{
    's101': {'absences30': 1, 'avg': 88}, 's102': {'absences30': 0, 'avg': 91}, 's103': {'absences30': 4, 'avg': 72},
    's104': {'absences30': 2, 'avg': 79}, 's105': {'absences30': 1, 'avg': 84}, 's106': {'absences30': 6, 'avg': 61},
    's107': {'absences30': 0, 'avg': 93}, 's108': {'absences30': 1, 'avg': 87}, 's109': {'absences30': 2, 'avg': 90}, 's110': {'absences30': 0, 'avg': 82},
  };

  // ─── פנקס-פעולות (מצב=חיווט · חוק-1): התאמות מעל הבסיס-const, כמו פנקס אמיתי ───
  static final List<Map<String, dynamic>> extraMsgs = [];
  static final Map<String, Map<String, dynamic>> threadAdj = {}; // famId ⇒ {unreadAdmin, unreadUser, lastAt, lastFrom, lastText}
  static final Map<String, String> consentStatus = {}; // consentId ⇒ status
  static final Map<String, int> consentReminders = {};
  static final Map<String, String> inquiryDone = {}; // inquiryId ⇒ doneAt
  static final Map<String, String> inquiryAnswered = {};
  static final Set<String> inquiryEscalated = {};
  static final List<Map<String, dynamic>> extraInquiries = [];
  static final Map<String, bool> meetingSummary = {};
  static final List<Map<String, dynamic>> extraMeetings = [];
  static final Map<String, bool> mediaAdj = {};
  static final Map<String, String?> blockedAdj = {}; // famId ⇒ parentKey|null
  static final Set<String> markedUnresponsive = {};
  static final Set<String> absenceNotified = {};
  static final List<Map<String, dynamic>> log = []; // לוג-שליחה + אודיט {at, actor, action, famId, to, channel, status, note}
  static int _seq = 0;
  static void reset() {
    extraMsgs.clear(); threadAdj.clear(); consentStatus.clear(); consentReminders.clear(); inquiryDone.clear();
    inquiryAnswered.clear(); inquiryEscalated.clear(); extraInquiries.clear(); meetingSummary.clear(); extraMeetings.clear();
    mediaAdj.clear(); blockedAdj.clear(); markedUnresponsive.clear(); absenceNotified.clear(); log.clear(); _seq = 0;
  }
  static String nowIso() => '${today}T${nowHour.toString().padLeft(2, '0')}:${(_seq % 60).toString().padLeft(2, '0')}';
  static void audit(String actor, String action, String famId, {String to = '', String channel = '', String status = 'ok', String note = ''}) {
    _seq++;
    log.insert(0, {'at': nowIso(), 'actor': actor, 'action': action, 'famId': famId, 'to': to, 'channel': channel, 'status': status, 'note': note});
  }

  // ═══ הערכת-מצב-קשר (הכרעה 23-ג) = phoneIssue ⊕ waDigits ⊕ formatIsraeliPhone ⊕ tzStaleDays ═══
  //   זהות מוזרקת: identity[famId] = {p1Name, p1Phone, p2Name, p2Phone, email, emergencyName, emergencyPhone}
  static Map<String, Map<String, String>> identity = {};
  static String? phoneOf(String famId, String pk) => identity[famId]?['${pk}Phone'];
  static String? nameOf(String famId, String pk) => identity[famId]?['${pk}Name'];
  static Map<String, dynamic> get _phoneT => PHONE_ISSUE_T.cast<String, dynamic>();
  // מצב-קשר של הורה: 'none' (לא-הוזרק) · 'bad' (אבחון-שגיאה / לא-שליח) · 'ok'
  //   תיקון-רנדר (§6, 4.9): מספר בקידומת-בינ"ל (+1/+44…) תקין לוואטסאפ אך phoneIssue (ישראלי) פוסל אותו ⇒
  //   בינ"ל נשפט ב-waDigits (E.164) בלבד; מקומי נשפט ב-phoneIssue ⊕ waDigits.
  static String contactState(String famId, String pk) {
    final p = phoneOf(famId, pk);
    if (p == null || p.trim().isEmpty) return 'none';
    if (_intlPrefix(p) != null) return waDigits(p) == null ? 'bad' : 'ok';
    if (phoneIssue(p, _phoneT) != null || waDigits(p) == null) return 'bad';
    return 'ok';
  }
  static String contactWhy(String famId, String pk) {
    final p = phoneOf(famId, pk);
    if (_intlPrefix(p) != null) return waDigits(p) == null ? 'לא-שליח (מחוץ ל-E.164)' : '';
    return phoneIssue(p, _phoneT) ?? (waDigits(p) == null ? 'לא-שליח (מחוץ ל-E.164)' : '');
  }
  static String phoneShown(String famId, String pk) {
    final p = phoneOf(famId, pk);
    return p == null || p.trim().isEmpty ? '🔒 מוזרק-בהצבה' : formatIsraeliPhone(p);
  }
  // משפחה "עם קשר-תקין" = לפחות הורה-מורשה-אחד עם טלפון-תקין
  static bool contactOk(Map<String, dynamic> f) =>
      parentKeys(f).any((pk) => !isBlocked(f, pk) && contactState(f['id'] as String, pk) == 'ok');
  static bool contactFresh(Map<String, dynamic> f) => dayDiff('${f['contactUpdatedAt']}', today) <= tzStaleDays;
  static bool isBlocked(Map<String, dynamic> f, String pk) => (blockedAdj.containsKey(f['id']) ? blockedAdj[f['id']] : f['blocked']) == pk;
  static String? blockedOf(Map<String, dynamic> f) => blockedAdj.containsKey(f['id']) ? blockedAdj[f['id']] : f['blocked'] as String?;
  static bool mediaOf(Map<String, dynamic> f) => mediaAdj[f['id']] ?? (f['media'] as bool? ?? false);

  // ═══ שיחה (23-ג) = sortSupportMsgs ⊕ supportUnread ⊕ supportMsgTime ⊕ supportDayLabel ⊕ PureBubble ═══
  static Map<String, dynamic>? thread(String famId) {
    Map<String, dynamic>? base;
    for (final t in threads) {
      if (t['famId'] == famId) base = t;
    }
    final adj = threadAdj[famId];
    if (base == null && adj == null) return null;
    return {...?base, ...?adj, 'famId': famId};
  }
  static List<Map<String, dynamic>> msgsOf(String famId) =>
      (sortSupportMsgs([...messages, ...extraMsgs].where((m) => m['famId'] == famId).toList()) as List).cast<Map<String, dynamic>>();
  static int unreadByStaff(String famId) => (supportUnread(thread(famId), 'admin') as num).toInt(); // הצוות טרם קרא
  static int unreadByParent(String famId) => (supportUnread(thread(famId), 'user') as num).toInt(); // ההורה טרם קרא
  static String? lastAdminAt(String famId) {
    String? at;
    for (final m in msgsOf(famId)) {
      if (m['from'] == 'admin') at = '${m['at']}';
    }
    return at;
  }
  static String? lastUserAt(String famId) {
    String? at;
    for (final m in msgsOf(famId)) {
      if (m['from'] == 'user') at = '${m['at']}';
    }
    return at;
  }
  // לא-נקרא>72ש׳: ההורה טרם קרא ∧ ההודעה-האחרונה-של-הצוות בת ≥3 ימים (dayDiff מהמדף)
  static bool unreadStale(Map<String, dynamic> f) {
    final id = f['id'] as String;
    final la = lastAdminAt(id);
    return unreadByParent(id) > 0 && la != null && dayDiff(la, today) >= unreadAlertDays;
  }
  static bool hasFailed(Map<String, dynamic> f) => msgsOf(f['id'] as String).any((m) => m['status'] == 'failed');
  // "לא-מגיב": ≥2 הודעות-צוות רצופות אחרונות בלי מענה-הורה (או סומן-ידנית)
  static bool unresponsive(Map<String, dynamic> f) {
    final id = f['id'] as String;
    if (markedUnresponsive.contains(id)) return true;
    final ms = msgsOf(id);
    var streak = 0;
    for (final m in ms.reversed) {
      if (m['from'] == 'admin') {
        streak++;
      } else {
        break;
      }
    }
    return streak >= unresponsiveSends;
  }
  // "שקט" (cockpitAtRisk מהמדף): ענה-בעבר ושותק ≥silentDays — דירוג-שתיקה יורד
  static List<Map<String, dynamic>> get silentFamilies => cockpitAtRisk(
        families, today, silentDays,
        (sp) => msgsOf(sp['id'] as String).where((m) => m['from'] == 'user').length,
        (sp) => (lastUserAt(sp['id'] as String) ?? '').split('T').first,
        (iso, t) => dayDiff(iso, t),
      ).cast<Map<String, dynamic>>();
  // סטטוס-מעורבות מאוחד (הכרעה 23-ד: חיבור-אותות בהחלטה): לא-מגיב ⊃ שקט ⊃ פעיל
  static String engagement(Map<String, dynamic> f) => unresponsive(f)
      ? 'unresponsive'
      : silentFamilies.any((s) => s['id'] == f['id'])
          ? 'quiet'
          : 'active';
  static const engagementLabel = {'active': '🟢 פעיל', 'quiet': '🟠 שקט', 'unresponsive': '🔴 לא-מגיב'};

  // ═══ ערוץ-חכם (23-ד): הערוץ שההורה ענה בו לאחרונה גובר על המועדף-המוצהר ═══
  static const channelLabel = {'wa': 'וואטסאפ', 'sms': 'SMS', 'email': 'מייל', 'phone': 'טלפון'};
  static String smartChannel(Map<String, dynamic> f, String pk) {
    String? via;
    for (final m in msgsOf(f['id'] as String)) {
      if (m['from'] == 'user' && m['to'] == pk) via = '${m['via']}';
    }
    return via ?? '${parent(f, pk)['channel']}';
  }
  static bool channelOverridden(Map<String, dynamic> f, String pk) => smartChannel(f, pk) != parent(f, pk)['channel'];

  // ═══ שעות-מנוחה (23-ג) = contactWindow (new/boxes/quiet-hours.mjs) ⊕ blockReason ⊕ timeToMin ═══
  //   contactWindow: קידומת-בינ"ל ⇒ היסט-UTC (PREFIX_TZ) ⇒ שעה-מקומית-אצל-ההורה ⇒ quiet אם ≥QUIET_FROM ∨ <QUIET_TO.
  //   (הקופסה קיימת ב-JS בלבד — הרכבה בדארט מאותם אטומי-דאטה; חוב-המרה מתועד ב-CLOSED.)
  static String? _intlPrefix(String? phone) {
    var s = (phone ?? '').replaceAll(RegExp(r'[\s()\-.]'), '');
    if (s.startsWith('00')) s = '+${s.substring(2)}';
    if (!s.startsWith('+')) return null;
    String? best;
    for (final e in PREFIX_TZ) {
      final p = e['p'] as String;
      if (s.startsWith(p) && (best == null || p.length > best.length)) best = p;
    }
    return best;
  }
  static Map<String, dynamic> contactWindow(String? phone, int hour) {
    final p = _intlPrefix(phone);
    Map<String, Object>? entry;
    if (p != null) {
      for (final e in PREFIX_TZ) {
        if (e['p'] == p) entry = e;
      }
    }
    final intl = entry != null && entry['p'] != '+972';
    final shift = intl ? (entry['off'] as int) - orgUtcOffset : 0;
    var local = (hour + shift) % 24;
    if (local < 0) local += 24;
    final quiet = local >= QUIET_FROM || local < QUIET_TO;
    return {'quiet': quiet, 'localHour': local, 'region': intl ? entry['label'] : '', 'intl': intl};
  }
  static bool get localQuiet => nowHour >= QUIET_FROM || nowHour < QUIET_TO;
  // שבת/שישי/חוה"מ מהמדף (blockReason ⊕ hebParts). מפת-חגים-נקובים = שקע-הזרקה (מקום-שמור: ריק ⇒ רק שבת/שישי/חוה"מ)
  static Map<String, String> holidays = {};
  static ({int day, String month, int year}) _parts(DateTime d) {
    final p = hebParts(d);
    return (day: (p['day'] as num).toInt(), month: '${p['month']}', year: (p['year'] as num).toInt());
  }
  static String? get restBlock => blockReason(DateTime.parse('${today}T12:00:00'), _parts, holidays, FULL_HOLIDAYS, BLOCK_REASON_T.cast<String, dynamic>());
  // שעות-נוחות-לפנייה של ההורה ('HH:MM-HH:MM') מול השעה-המקומית — timeToMin מהמדף
  static bool inConvenientHours(Map<String, dynamic> f, String pk) {
    final h = '${parent(f, pk)['hours'] ?? ''}';
    if (!h.contains('-')) return true; // לא-הוגדר ⇒ אין-מגבלה
    final parts = h.split('-');
    final a = timeToMin(parts[0]), b = timeToMin(parts[1]);
    if (a is! num || b is! num || a.isNaN || b.isNaN) return true;
    final now = nowHour * 60;
    return now >= a && now <= b;
  }
  // הכרעת-שליחה מאוחדת (23-ד): חסום ⊕ קשר ⊕ מנוחה-מקומית-אצל-ההורה ⊕ שבת ⊕ שעות-נוחות ⇒ סיבה-לעיכוב או null
  static String? sendHold(Map<String, dynamic> f, String pk, {bool crisis = false}) {
    if (isBlocked(f, pk)) return 'הורה חסום';
    if (crisis) return null; // חירום (הנהלה) גובר על מנוחה — לא על חסימה
    final w = contactWindow(phoneOf(f['id'] as String, pk), nowHour);
    if (w['quiet'] == true) return 'שעות-מנוחה${w['intl'] == true ? ' (${w['region']} · ${w['localHour']}:00 מקומית)' : ''}';
    final rb = restBlock;
    if (rb != null) return rb;
    if (!inConvenientHours(f, pk)) return 'מחוץ לשעות-הנוחות (${parent(f, pk)['hours']})';
    return null;
  }

  // ═══ ביצוע: שליחה (23-ג) = sanitizeSupportText ⊕ isSendableSupportText ⊕ sendHold ⊕ waLink ⊕ פנקס ═══
  static String _sanitize(Object? raw) => sanitizeSupportText(raw, supportMsgMax) as String;
  // מחזיר סטטוס: 'sent' · 'queued' (מוחזק לחלון) · 'failed' (קשר-לא-תקין) · 'blocked' · 'empty'
  static String send(String actor, Map<String, dynamic> f, String pk, String text, {String? channel, bool crisis = false}) {
    if (!isSendableSupportText(text, _sanitize)) return 'empty';
    final id = f['id'] as String;
    final ch = channel ?? smartChannel(f, pk);
    final hold = sendHold(f, pk, crisis: crisis);
    final cs = contactState(id, pk);
    final status = hold == 'הורה חסום'
        ? 'blocked'
        : hold != null
            ? 'queued'
            : (ch == 'email' ? (identity[id]?['email'] ?? '').isEmpty : cs != 'ok')
                ? 'failed'
                : 'sent';
    final clean = _sanitize(text);
    if (status != 'blocked') {
      _seq++;
      extraMsgs.add({'famId': id, 'from': 'admin', 'to': pk, 'text': clean, 'at': nowIso(), 'via': ch,
        'status': status == 'sent' ? 'delivered' : status == 'queued' ? 'pending' : 'failed'});
      final t = thread(id) ?? {'unreadAdmin': 0, 'unreadUser': 0};
      threadAdj[id] = {...t, 'unreadUser': ((t['unreadUser'] as num?) ?? 0).toInt() + (status == 'sent' ? 1 : 0),
        'lastAt': nowIso(), 'lastFrom': 'admin', 'lastText': clean};
    }
    audit(actor, 'הודעה', id, to: pk, channel: ch, status: status, note: hold ?? (status == 'failed' ? contactWhy(id, pk) : ''));
    return status;
  }
  // שידור לכיתה/מוסד = bulkWaRecipients (דדופ-ספרות · דילוג-לא-תקין) ⊕ send פר-נמען
  static Map<String, int> broadcast(String actor, String text, {String? cls}) {
    final targets = <Map<String, dynamic>>[];
    for (final f in families) {
      if (cls != null && !classesOf(f).contains(cls)) continue;
      for (final pk in parentKeys(f)) {
        if (isBlocked(f, pk)) continue;
        targets.add({'id': '${f['id']}|$pk', 'name': pk, 'phone': phoneOf(f['id'] as String, pk) ?? ''});
      }
    }
    final reach = bulkWaRecipients(targets, waDigits); // מי-שאפשר-להגיע-אליו בוואטסאפ (מדף)
    final reachable = {for (final r in reach) r['id'] as String};
    final out = {'sent': 0, 'queued': 0, 'failed': 0, 'skipped': 0};
    for (final t in targets) {
      final parts = (t['id'] as String).split('|');
      final f = fam(parts[0]);
      final st = reachable.contains(t['id']) ? send(actor, f, parts[1], text, channel: 'wa') : send(actor, f, parts[1], text, channel: smartChannel(f, parts[1]));
      out[st == 'sent' ? 'sent' : st == 'queued' ? 'queued' : st == 'failed' ? 'failed' : 'skipped'] = (out[st == 'sent' ? 'sent' : st == 'queued' ? 'queued' : st == 'failed' ? 'failed' : 'skipped'] ?? 0) + 1;
    }
    audit(actor, cls == null ? 'הודעה-מוסדית' : 'הודעה-לכיתה', cls ?? '*', note: '${targets.length} נמענים · ${reach.length} ברי-השגה בוואטסאפ');
    return out;
  }
  static String? waHrefOf(String famId, String pk, String text) => waLink(phoneOf(famId, pk) ?? '', text, waDigits) as String?;
  static void markReadByStaff(String famId) {
    final t = thread(famId);
    if (t == null) return;
    threadAdj[famId] = {...t, 'unreadAdmin': 0};
  }
  static void receive(String famId, String pk, String text, String via) { // מענה-הורה (סימולציית-צד-שני בפורטל)
    _seq++;
    extraMsgs.add({'famId': famId, 'from': 'user', 'to': pk, 'text': _sanitize(text), 'at': nowIso(), 'via': via, 'status': 'delivered'});
    final t = thread(famId) ?? {'unreadAdmin': 0, 'unreadUser': 0};
    threadAdj[famId] = {...t, 'unreadAdmin': ((t['unreadAdmin'] as num?) ?? 0).toInt() + 1, 'unreadUser': 0, 'lastAt': nowIso(), 'lastFrom': 'user', 'lastText': _sanitize(text)};
    markedUnresponsive.remove(famId);
  }

  // ═══ אישורים (23-ג) = expiringIntakes ⊕ shopExpiryWarnDays ⊕ StatusChip ⊕ SoftButton ═══
  static String consentState(Map<String, dynamic> c) {
    final s = consentStatus[c['id']] ?? c['status'] as String;
    if (s == 'pending' && '${c['due']}'.compareTo(today) < 0) return 'expired';
    return s;
  }
  static const consentLabel = {'pending': '⏳ ממתין', 'received': '✅ התקבל', 'expired': '⛔ פג', 'declined': '✋ סורב'};
  static const consentKind = {'trip': '🚌 טיול', 'media': '📷 מדיה', 'meds': '💊 תרופה'};
  static List<Map<String, dynamic>> consentsOf(String famId) => consents.where((c) => c['famId'] == famId).toList();
  static List<Map<String, dynamic>> get pendingConsents => consents.where((c) => consentState(c) == 'pending').toList();
  static List<Map<String, dynamic>> get expiredConsents => consents.where((c) => consentState(c) == 'expired').toList();
  static String _iso(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  // אישורים-פוקעים תוך חלון (expiringIntakes: itemId+expiry — אותה צורת-"דבר-עם-תוקף")
  static List<Map<String, dynamic>> get expiringConsents => expiringIntakes({
        'shopIntakes': [for (final c in pendingConsents) {'itemId': c['id'], 'expiry': c['due']}],
        'shopItems': [for (final c in consents) {'id': c['id'], 'name': '${famLabel(fam(c['famId'] as String))} · ${c['title']}'}],
      }, today, _iso, shopExpiryWarnDays);
  static int remindersOf(Map<String, dynamic> c) => consentReminders[c['id']] ?? (c['reminders'] as int);
  // תזכורת-מדורגת: 1=ידידותית · 2=דחופה · ≥3=העלאה-להנהלה (הכרעה בהחלטה, לא בתצוגה)
  static String reminderTier(Map<String, dynamic> c) => remindersOf(c) >= 2 ? 'escalate' : remindersOf(c) == 1 ? 'urgent' : 'friendly';

  // ═══ פניות (23-ג) = openTasksFor ⊕ taskOverdue ⊕ TimelineItem ═══
  static List<Map<String, dynamic>> get allInquiries => [
        for (final q in [...inquiries, ...extraInquiries])
          {...q, 'doneAt': inquiryDone[q['id']] ?? q['doneAt'], 'answeredAt': inquiryAnswered[q['id']] ?? q['answeredAt'], 'escalated': inquiryEscalated.contains(q['id'])},
      ];
  static List<Map<String, dynamic>> get openInquiries => openTasksFor(allInquiries, '*', (a) => '*'); // כל-הפתוחות, ממוינות pri→due
  static List<Map<String, dynamic>> inquiriesOf(String famId) => allInquiries.where((q) => q['famId'] == famId).toList();
  static bool overdue(Map<String, dynamic> q) => taskOverdue(q, today);
  static List<Map<String, dynamic>> get overdueInquiries => openInquiries.where(overdue).toList();
  // זמן-תגובה-ממוצע (שעות) = ממוצע(answeredAt−createdAt) על פניות-שנענו (חישוב-שפה: DateTime.difference)
  static double get avgResponseHours {
    var n = 0;
    var sum = 0.0;
    for (final q in allInquiries) {
      final a = '${q['answeredAt']}';
      if (a.isEmpty) continue;
      sum += DateTime.parse(a).difference(DateTime.parse('${q['createdAt']}')).inMinutes / 60;
      n++;
    }
    return n == 0 ? 0 : sum / n;
  }

  // ═══ פגישות (23-ג) = upcomingMeetings ⊕ TimelineItem ⊕ SoftButton ═══
  static List<Map<String, dynamic>> get allMeetings => [
        for (final m in [...meetings, ...extraMeetings]) {...m, 'summarySent': meetingSummary[m['id']] ?? m['summarySent']},
      ];
  static Map<String, Object?> get _evDb => {'shopEvents': [for (final m in allMeetings) m.cast<String, Object?>()], 'shopAssignments': <Map<String, Object?>>[], 'rooms': <Map<String, Object?>>[]};
  static List<Map<String, Object?>> get weekMeetings => upcomingMeetings(_evDb, today, 7, null, _iso, (db, a, c) => '');
  static List<Map<String, dynamic>> meetingsOf(String famId) => allMeetings.where((m) => m['famId'] == famId).toList();
  static List<Map<String, dynamic>> get summariesDue => allMeetings.where((m) => m['done'] == true && m['summarySent'] != true).toList();

  // ═══ תבניות = renderTemplate ⊕ templateDefs (מדף: wa.dialer/wa.payment/…) + תבניות-בית-ספר ═══
  static List<Map<String, String>> get templateList => [
        for (final d in templateDefs) {'key': '${(d as Map)['key']}', 'label': '${d['label']}', 'def': '${d['def']}'},
        const {'key': 'sc.absence', 'label': '🏫 חיסור-לא-מוצדק', 'def': 'שלום, {first} נעדר/ה היום ({date}) ללא הודעה — נשמח לעדכון. {org}'},
        const {'key': 'sc.consent', 'label': '📝 תזכורת-אישור', 'def': 'שלום, טרם קיבלנו את האישור ל{what} (עד {due}). {org}'},
        const {'key': 'sc.consent.urgent', 'label': '📝 תזכורת-אישור דחופה', 'def': 'תזכורת דחופה: האישור ל{what} פג ב-{due}. בלי אישור לא נוכל לשתף את {first}. {org}'},
        const {'key': 'sc.meeting', 'label': '📅 תזכורת-פגישה', 'def': 'תזכורת: פגישה ב-{date} בשעה {time} — {what}. {org}'},
        const {'key': 'sc.summary', 'label': '🗒 סיכום-פגישה', 'def': 'סיכום הפגישה מ-{date} ({what}): {note}. {org}'},
        const {'key': 'sc.weekly', 'label': '📬 סיכום-שבועי', 'def': 'סיכום שבועי ל{first}: {absences} חיסורים ב-30 יום · ממוצע {avg}. {org}'},
        const {'key': 'sc.letter', 'label': '🖨 מכתב-להורים', 'def': 'לכבוד הורי {first},\nהנדון: {what}\n{note}\nבברכה, {org}'},
      ];
  static Map<String, dynamic> templateCfg = {}; // {'templates': {key: override}} — עריכות-תבנית (state)
  static String render(String key, Map<String, String> vars) => renderTemplate(templateCfg, key, {'org': orgName, ...vars}, templateList);

  // ═══ אוטומציות (23-ג): חיסור⇒הודעה · אישור-פג⇒תזכורת · פנייה-חורגת⇒העלאה · סיכום-שבועי (digestLines) ═══
  static List<Map<String, dynamic>> get absencesToNotify =>
      absenceFeed.where((a) => a['justified'] != true && !absenceNotified.contains('${a['sid']}|${a['date']}')).toList();
  static String notifyAbsence(String actor, Map<String, dynamic> a) {
    final f = fam(a['famId'] as String);
    final kid = (f['kids'] as List).firstWhere((k) => (k as Map)['sid'] == a['sid']) as Map;
    final st = send(actor, f, parentKeys(f).first, render('sc.absence', {'first': '${kid['first']}', 'date': '${a['date']}'}));
    absenceNotified.add('${a['sid']}|${a['date']}');
    return st;
  }
  static String remindConsent(String actor, Map<String, dynamic> c) {
    final f = fam(c['famId'] as String);
    final tier = reminderTier(c);
    final key = tier == 'friendly' ? 'sc.consent' : 'sc.consent.urgent';
    final st = send(actor, f, parentKeys(f).first, render(key, {'what': '${c['title']}', 'due': '${c['due']}', 'first': '${(f['kids'] as List).first['first']}'}));
    consentReminders[c['id'] as String] = remindersOf(c) + 1;
    if (tier == 'escalate') audit(actor, 'העלאה-להנהלה', f['id'] as String, note: 'אישור לא-חזר אחרי ${remindersOf(c)} תזכורות: ${c['title']}');
    return st;
  }
  static void escalate(String actor, Map<String, dynamic> q) {
    inquiryEscalated.add(q['id'] as String);
    audit(actor, 'העלאה-להנהלה', q['famId'] as String, note: 'פנייה ללא-מענה מעבר לסף: ${q['title']}');
  }
  // סיכום-שבועי-להורה: digestLines (מדף, term מוזרק) — דחוף/אישורים/פניות ⇒ שורות
  static List<String> weeklyDigest(Map<String, dynamic> f) {
    final id = f['id'] as String;
    final crit = [if (unreadStale(f) || hasFailed(f)) (crit: true, navTab: 0)];
    final lines = digestLines(
      term: (k) => switch (k) {
        'pryt-kryty-achd-dvrsh-typvl' => '⚠ הודעה מהצוות ממתינה לקריאה',
        'xi_prytym-krytyym-dvrshym-typvl' => ' הודעות ממתינות',
        'xi_mshymvt-mmtynvt-layshvr' => ' אישורים ממתינים לחתימה',
        'xi_bkshvt-chvpshh-mmtynvt' => ' פניות פתוחות',
        _ => 'הכל מעודכן — אין פעולה נדרשת השבוע',
      },
      pendingApprovals: consentsOf(id).where((c) => consentState(c) == 'pending').length,
      pendingVacations: inquiriesOf(id).where((q) => '${q['doneAt']}'.isEmpty).length,
      attentionItems: () => crit,
    );
    return [for (final l in lines) l.text, for (final k in f['kids'] as List) render('sc.weekly', {'first': '${(k as Map)['first']}', 'absences': '${childFeed[k['sid']]?['absences30'] ?? '—'}', 'avg': '${childFeed[k['sid']]?['avg'] ?? '—'}'})];
  }

  // ═══ איתור (23-ג) = DsSearch ⊕ smartFilter ⊕ smartScore ⊕ normSearch — הורה/תלמיד/כיתה ═══
  static const Map<String, String> _finals = {'k1': 'כ', 'k2': 'מ', 'k3': 'נ', 'k4': 'פ', 'k5': 'צ'};
  static String _norm(dynamic q) => normSearch(q, _finals);
  static Iterable _expand(dynamic q, dynamic norm) => [norm(q)];
  static num _score(dynamic exp, dynamic term) => _norm(term).contains('$exp') ? 100 : 0;
  static num _scoreOf(dynamic q, dynamic terms) => smartScore(q, terms, _norm, _expand, _score) as num;
  static bool _hasQuery(dynamic q) => (q as String).trim().isNotEmpty;
  static List<String> _termsOf(Map<String, dynamic> f) => [
        famLabel(f), ...classesOf(f), for (final k in f['kids'] as List) '${(k as Map)['first']}',
        for (final pk in parentKeys(f)) ...[nameOf(f['id'] as String, pk) ?? '', '${parent(f, pk)['lang']}', channelLabel[parent(f, pk)['channel']] ?? ''],
      ];
  static List<Map<String, dynamic>> search(List<Map<String, dynamic>> items, String q) =>
      (smartFilter(q, items, (it) => _termsOf(it as Map<String, dynamic>), _hasQuery, _scoreOf) as List).cast<Map<String, dynamic>>();

  // ═══ חריגה (23-ג) = FilterChipPill ⊕ finderMatches — 11 צירי-סינון של המפרט ═══
  static const filterDefs = <Map<String, String>>[
    {'axis': 'all', 'label': 'הכל'},
    {'axis': 'badContact', 'label': '📵 קשר-לא-תקין'},
    {'axis': 'unread', 'label': '👁 לא-נקרא'},
    {'axis': 'consentPending', 'label': '⏳ אישור-ממתין'},
    {'axis': 'consentExpired', 'label': '⛔ אישור-פג'},
    {'axis': 'inquiryOpen', 'label': '📨 פנייה-פתוחה'},
    {'axis': 'unresponsive', 'label': '🔴 לא-מגיב'},
    {'axis': 'meetingWeek', 'label': '📅 פגישה-השבוע'},
    {'axis': 'blocked', 'label': '🚫 הורה-חסום'},
    {'axis': 'custody', 'label': '⚖️ הסדר-ראייה'},
  ];
  static String axisValue(Map<dynamic, dynamic> db, dynamic f, dynamic axis) {
    final s = f as Map<String, dynamic>;
    final id = s['id'] as String;
    bool v;
    switch (axis) {
      case 'badContact': v = !contactOk(s);
      case 'unread': v = unreadByParent(id) > 0;
      case 'consentPending': v = consentsOf(id).any((c) => consentState(c) == 'pending');
      case 'consentExpired': v = consentsOf(id).any((c) => consentState(c) == 'expired');
      case 'inquiryOpen': v = inquiriesOf(id).any((q) => '${q['doneAt']}'.isEmpty);
      case 'unresponsive': v = engagement(s) == 'unresponsive';
      case 'meetingWeek': v = weekMeetings.any((m) => (m['ev'] as Map)['famId'] == id);
      case 'blocked': v = blockedOf(s) != null;
      case 'custody': v = (s['custody'] as Map?)?['restricted'] == true;
      default: return (s[axis] ?? '').toString();
    }
    return v ? '1' : '0';
  }
  static List<Map<String, dynamic>> filter(List<Map<String, dynamic>> items, String axis, {String? cls, String? channel, String? lang}) {
    final locks = <dynamic, dynamic>{if (axis != 'all') axis: '1'};
    var out = finderMatches({'families': items}, locks, axisValue).cast<Map<String, dynamic>>();
    if (cls != null) out = out.where((f) => classesOf(f).contains(cls)).toList();
    if (channel != null) out = out.where((f) => parentKeys(f).any((pk) => smartChannel(f, pk) == channel)).toList();
    if (lang != null) out = out.where((f) => parentKeys(f).any((pk) => parent(f, pk)['lang'] == lang)).toList();
    return out;
  }
  static List<String> get allClasses => {for (final f in families) ...classesOf(f)}.toList()..sort();

  // ═══ הרשאות (23-ג · חוק-6) = roleOf ⊕ canGrantedAction · 5 תפקידים · משמורת גוברת ═══
  static const roleDefs = <Map<String, dynamic>>[
    {'label': '👑 הנהלה', 'id': 'mgmt', 'config': {'adminEmails': ['mgmt']}},
    {'label': '🧑‍🏫 מחנך/ת', 'id': 'teacher-1', 'classes': ['י׳-1'], 'config': {'roles': {'teachers': {'teacher-1': true}}, 'features': {'pr.msg': true, 'pr.class': true, 'pr.inquiry': true, 'pr.meeting': true, 'pr.consent.mark': true}}},
    {'label': '🗂 מזכירות', 'id': 'sec', 'config': {'features': {'pr.msg': true, 'pr.class': true, 'pr.org': true, 'pr.consent': true, 'pr.consent.mark': true, 'pr.contact': true, 'pr.export': true, 'pr.meeting': true, 'pr.templates': true}}},
    {'label': '🧭 יועץ/ת', 'id': 'counselor', 'config': {'features': {'pr.msg': true, 'pr.inquiry': true, 'pr.sensitive': true, 'pr.meeting': true}}},
    {'label': '👪 הורה', 'id': 'parent-f3', 'family': 'f3', 'parent': 'p2', 'config': {'features': {'pr.portal': true}}},
  ];
  static bool _isAdmin(Map<String, dynamic> config, String email) => roleOf(config, email) == 'admin';
  static bool can(int role, String key) {
    final r = roleDefs[role];
    return canGrantedAction((r['config'] as Map).cast<String, dynamic>(), r['id'] as String, false, key, _isAdmin);
  }
  static String roleName(int role) => roleOf((roleDefs[role]['config'] as Map).cast<String, dynamic>(), roleDefs[role]['id'] as String);
  static bool isParent(int role) => roleDefs[role]['family'] != null;
  // היקף-ראייה: הנהלה/מזכירות/יועץ=הכל · מחנך=כיתותיו · הורה=משפחתו
  static List<Map<String, dynamic>> scope(int role) {
    final r = roleDefs[role];
    if (r['family'] != null) return [fam(r['family'] as String)];
    if (r['classes'] != null) return families.where((f) => classesOf(f).any((c) => (r['classes'] as List).contains(c))).toList();
    return families;
  }
  // 🔒 משמורת (חוק-6): הסדר-ראייה גובר על כל-הרשאה — מה הורה-נתון רואה על הילד
  static const childViews = ['attendance', 'grades', 'fees'];
  static const childViewLabel = {'attendance': '📆 נוכחות', 'grades': '📊 ציונים', 'fees': '💳 חוב'};
  static List<String> visibleViews(Map<String, dynamic> f, String pk) {
    if (isBlocked(f, pk)) return const [];
    final c = f['custody'] as Map?;
    if (c != null && c['restricted'] == true && c[pk] is List) return (c[pk] as List).cast<String>();
    return childViews;
  }
  static bool sensitiveOk(int role, Map<String, dynamic> q) => q['sensitive'] != true || can(role, 'pr.sensitive');

  // ═══ ייצוא-לוג = toCsv ⊕ csvEscape ⊕ exportAllowed ⊕ can ═══
  static const _csvHeader = ['מועד', 'מבצע', 'פעולה', 'משפחה', 'נמען', 'ערוץ', 'סטטוס', 'הערה'];
  static String csvOfLog() => toCsv([_csvHeader, for (final e in log) [e['at'], e['actor'], e['action'], e['famId'], e['to'], e['channel'], e['status'], e['note']]], csvEscape) as String;
  static bool exportOk(int role) => exportAllowed(false) && can(role, 'pr.export');
  static List<String> auditLines() => auditReportLines(orgName, [for (final e in log) {'cat': '${e['action']}', 'title': '${e['at']} · ${e['actor']} · ${e['famId']}${'${e['to']}'.isEmpty ? '' : '/${e['to']}'} · ${e['status']}${'${e['note']}'.isEmpty ? '' : ' · ${e['note']}'}'}], today, term: (k) => switch (k) { 'dvch-tkynvt-ntvnym' => 'דוח-אודיט תקשורת · ', 'hvpk' => 'הופק: ', _ => k });

  // ═══ KPI-10 (המפרט) — כולם מנועי-מדף/שדות-אמת ═══
  static int get sentThisMonth => [...messages, ...extraMsgs].where((m) => m['from'] == 'admin' && '${m['at']}'.startsWith(today.substring(0, 7)) && m['status'] != 'failed').length;
  static int get readThisMonth => [...messages, ...extraMsgs].where((m) => m['from'] == 'admin' && '${m['at']}'.startsWith(today.substring(0, 7)) && m['status'] == 'delivered' && unreadByParent(m['famId'] as String) == 0).length;
  static int get readPct => sentThisMonth == 0 ? 0 : (readThisMonth * 100 / sentThisMonth).round();

  // ═══ חוזה-עמודות · מקום-שמור (חוק-7) — 16 עמודות-הליבה + מתקדמים כשקעי-דאטה ═══
  //   נגזרת(get)=תמיד · שדה(key)=מוארת רק כשמשפחה נושאת ערך · שדה-זהות = מוזרק (identity).
  static final List<Map<String, Object?>> columnDefs = <Map<String, Object?>>[
    {'label': 'משפחה', 'get': (Map<String, dynamic> f) => famLabel(f)},
    {'label': 'הורה-1', 'get': (Map<String, dynamic> f) => _parentCell(f, 'p1')},
    {'label': 'הורה-2', 'get': (Map<String, dynamic> f) => f['p2'] == null ? '—' : _parentCell(f, 'p2')},
    {'label': 'ילדים+כיתות', 'get': (Map<String, dynamic> f) => kidsLabel(f)},
    {'label': 'ערוץ-מועדף', 'get': (Map<String, dynamic> f) => [for (final pk in parentKeys(f)) '${channelLabel[smartChannel(f, pk)]}${channelOverridden(f, pk) ? '*' : ''}'].join(' / ')},
    {'label': 'שפה', 'get': (Map<String, dynamic> f) => {for (final pk in parentKeys(f)) '${parent(f, pk)['lang']}'}.join(' / ')},
    {'label': 'קשר-תקין?', 'get': (Map<String, dynamic> f) => contactOk(f) ? '✅' : parentKeys(f).every((pk) => contactState(f['id'] as String, pk) == 'none') ? '🔒 לא-הוזרק' : '⚠️'},
    {'label': 'הודעה-אחרונה', 'get': (Map<String, dynamic> f) => thread(f['id'] as String) == null ? '—' : '${supportDayLabel('${thread(f['id'] as String)!['lastAt']}', today, SUPPORT_DAY_LABEL_T.cast<String, dynamic>())} · ${supportPreview(thread(f['id'] as String)!['lastText'], 24)}'},
    {'label': 'נקראה?', 'get': (Map<String, dynamic> f) => thread(f['id'] as String) == null ? '—' : unreadByParent(f['id'] as String) == 0 ? '✓✓' : '✓ (${unreadByParent(f['id'] as String)})'},
    {'label': 'אישורים-פתוחים', 'get': (Map<String, dynamic> f) => '${consentsOf(f['id'] as String).where((c) => consentState(c) == 'pending' || consentState(c) == 'expired').length}'},
    {'label': 'פניות-פתוחות', 'get': (Map<String, dynamic> f) => '${inquiriesOf(f['id'] as String).where((q) => '${q['doneAt']}'.isEmpty).length}'},
    {'label': 'פגישה-הבאה', 'get': (Map<String, dynamic> f) => _nextMeeting(f)},
    {'label': 'מעורבות', 'get': (Map<String, dynamic> f) => engagementLabel[engagement(f)]!},
    {'label': 'הרשאת-מדיה', 'get': (Map<String, dynamic> f) => mediaOf(f) ? '📷 כן' : '🚫 לא'},
    {'key': 'note', 'label': 'הערה'},
    {'key': 'updatedAt', 'label': 'עדכון'},
    // ── שדות-מתקדמים (מקום-שמור: מאירים כשמשפחה נושאת ערך) ──
    {'label': 'משמורת', 'get': (Map<String, dynamic> f) => (f['custody'] as Map?)?['restricted'] == true ? '⚖️ מגביל' : ''},
    {'key': 'guardian', 'label': 'אפוטרופוס'},
    {'label': 'חסום', 'get': (Map<String, dynamic> f) => blockedOf(f) == null ? '' : '🚫 ${parent(f, blockedOf(f)!)['role']}'},
    {'key': 'emergency', 'label': 'איש-קשר-חירום'}, // זהות ⇒ מוזרק
    {'key': 'translation', 'label': 'תרגום'}, // מקום-שמור
    {'key': 'portalLogin', 'label': 'פורטל-מזוהה'}, // מקום-שמור
    {'key': 'eSignature', 'label': 'חתימה-דיגיטלית'}, // מקום-שמור
    {'key': 'portalPayment', 'label': 'תשלום-מהפורטל'}, // מקום-שמור
    {'key': 'liveChat', 'label': 'צ׳אט-חי'}, // מקום-שמור
  ];
  static String _parentCell(Map<String, dynamic> f, String pk) {
    final n = nameOf(f['id'] as String, pk);
    return '${parent(f, pk)['role']}${n == null || n.isEmpty ? ' 🔒' : ' · $n'}';
  }
  static String _nextMeeting(Map<String, dynamic> f) {
    final up = allMeetings.where((m) => m['famId'] == f['id'] && m['done'] != true && '${m['date']}'.compareTo(today) >= 0).toList()..sort((a, b) => '${a['date']}'.compareTo('${b['date']}'));
    return up.isEmpty ? '—' : '${up.first['date']} ${up.first['time']}';
  }
  static bool colShown(Map<String, Object?> c, List<Map<String, dynamic>> rows) =>
      c['get'] != null ? rows.any((f) => (c['get'] as String Function(Map<String, dynamic>))(f).isNotEmpty) : rows.any((f) => f[c['key']] != null && '${f[c['key']]}'.trim().isNotEmpty);
}

// ═══════════════════════════════ המסך ═══════════════════════════════
/// מסך-הורים ותקשורת (SchoolOS). זהות/קשר מוזרקים (חוק-6); today/nowHour מוזרקים (אפס-Date.now).
class ParentsScreen extends StatefulWidget {
  const ParentsScreen({super.key, this.identity, this.today = '2026-09-04', this.nowHour = 20, this.holidays});
  /// famId ⇒ {p1Name, p1Phone, p2Name, p2Phone, email, emergencyName, emergencyPhone} — שקע-הצבה.
  final Map<String, Map<String, String>>? identity;
  final String today;
  final int nowHour;
  /// מפת-חגים 'Month day' ⇒ שם (ל-blockReason) — שקע-הצבה (מקום-שמור).
  final Map<String, String>? holidays;
  @override
  State<ParentsScreen> createState() => _ParentsScreenState();
}

class _ParentsScreenState extends State<ParentsScreen> {
  String _q = '';
  String _filter = 'all';
  String? _cls;
  String? _chan;
  String? _lang;
  int _mode = 0; // 0=👪 משפחות (טריאז') · 1=📥 תיבה · 2=📋 טבלה
  int _role = 0;
  bool _loading = false;
  String? _error; // מקום-שמור: שגיאת-fetch
  bool _crisis = false; // מצב-משבר (הנהלה): עוקף שעות-מנוחה

  @override
  void initState() {
    super.initState();
    _PrData.reset();
    _PrData.today = widget.today;
    _PrData.nowHour = widget.nowHour;
    _PrData.identity = {for (final e in (widget.identity ?? const {}).entries) e.key: Map<String, String>.from(e.value)};
    _PrData.holidays = widget.holidays ?? {};
  }

  String get _actor => _PrData.roleDefs[_role]['id'] as String;
  bool _can(String k) => _PrData.can(_role, k);

  Widget _fchip(String axis, String label) => FilterChipPill(
        label: label, selected: _filter == axis, onTap: () => setState(() => _filter = axis),
        activeFillColor: _acc, surfaceColor: const Color(0xFF14162E), activeTextColor: const Color(0xFF0B0B15),
        inkColor: _ink, outlineColor: const Color(0xFF2A2D4A), pillRadius: 999,
      );
  Widget _gap([double h = 10]) => SizedBox(height: h);
  Widget _wrap(List<Widget> kids, {double top = 6}) => Padding(padding: EdgeInsets.only(top: top, right: 4), child: Wrap(spacing: 8, runSpacing: 6, children: kids));
  Widget _card(Widget inner) => Padding(padding: const EdgeInsets.only(bottom: 12), child: ForgeStripPanelFrame(fields: ['', ''], child: inner));
  Widget _label(String t) => Text(t, style: const TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800));

  @override
  Widget build(BuildContext context) {
    final inner = _build(context);
    // חריץ-הערכה: PureBubble/DsSeam דורשים PureScope — כשהמסך עצמאי (בדיקה/ניווט-ישיר) מספקים ברירת-מחדל.
    if (context.dependOnInheritedWidgetOfExactType<PureScope>() != null) return inner;
    return PureScope(theme: DsPure.themes[DsPure.defaultTheme]!, child: Directionality(textDirection: TextDirection.rtl, child: inner));
  }

  Widget _build(BuildContext context) {
    if (_PrData.isParent(_role)) return _portalScreen();
    final scope = _PrData.scope(_role);
    // ── KPI-10 (הערכת-מצב) על ההיקף ──
    final famN = scope.length;
    final freshN = scope.where(_PrData.contactFresh).length;
    final badN = scope.where((f) => !_PrData.contactOk(f)).length;
    final sentN = _PrData.sentThisMonth;
    final readPct = _PrData.readPct;
    final pendN = _PrData.pendingConsents.where((c) => scope.any((f) => f['id'] == c['famId'])).length;
    final expN = _PrData.expiredConsents.where((c) => scope.any((f) => f['id'] == c['famId'])).length;
    final openQ = _PrData.openInquiries.where((q) => scope.any((f) => f['id'] == q['famId'])).length;
    final avgH = _PrData.avgResponseHours;
    final weekM = _PrData.weekMeetings.where((m) => scope.any((f) => f['id'] == (m['ev'] as Map)['famId'])).length;
    final staleN = scope.where(_PrData.unreadStale).length;
    final unrespN = scope.where((f) => _PrData.engagement(f) == 'unresponsive').length;
    final overdueQ = _PrData.overdueInquiries.where((q) => scope.any((f) => f['id'] == q['famId'])).length;
    final hero = scope.where((f) => !_PrData.contactOk(f) || _PrData.unreadStale(f) || _PrData.engagement(f) == 'unresponsive' || _PrData.inquiriesOf(f['id'] as String).any(_PrData.overdue) || _PrData.consentsOf(f['id'] as String).any((c) => _PrData.consentState(c) == 'expired')).length;
    // ── איתור⊕חריגה: פייפליין אחד מזין טריאז'/תיבה/טבלה ──
    final visible = _PrData.filter(_PrData.search(scope, _q), _filter, cls: _cls, channel: _chan, lang: _lang);
    final buckets = <String, List<Map<String, dynamic>>>{'act': [], 'unresponsive': [], 'quiet': [], 'active': []};
    for (final f in visible) {
      final act = !_PrData.contactOk(f) || _PrData.unreadStale(f) || _PrData.hasFailed(f) || _PrData.inquiriesOf(f['id'] as String).any(_PrData.overdue) || _PrData.consentsOf(f['id'] as String).any((c) => _PrData.consentState(c) == 'expired');
      buckets[act ? 'act' : _PrData.engagement(f)]!.add(f);
    }
    const secTitle = {'act': '🔴 דורש-פעולה עכשיו', 'unresponsive': '🟠 לא-מגיב', 'quiet': '🟡 שקט', 'active': '🟢 פעיל'};
    const secTone = {'act': 2, 'unresponsive': 3, 'quiet': 3, 'active': 1};
    final rb = _PrData.restBlock;
    final chanCounts = countBy([for (final f in scope) for (final pk in _PrData.parentKeys(f)) _PrData.smartChannel(f, pk)], (c) => '$c');
    final langCounts = countBy([for (final f in scope) for (final pk in _PrData.parentKeys(f)) '${_PrData.parent(f, pk)['lang']}'], (c) => '$c');
    return DsScaffold(
      title: 'הורים ותקשורת', subtitle: '$famN משפחות · ${_PrData.roleName(_role)} · ${_PrData.today} ${_PrData.nowHour}:00', icon: '👪',
      children: [
        // בורר-תפקיד (חוק-6 · זהות-מוזרקת)
        Align(alignment: Alignment.centerRight, child: ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in [for (final r in _PrData.roleDefs) r['label'] as String]) [s]], selected: {_role}, onSelect: (i) => setState(() => _role = i))),
        _gap(10),
        // פס-עליון: חיפוש + פעולות-יצירה מגודרות
        Row(children: [
          Expanded(child: DsSearch(value: _q, onChanged: (v) => setState(() => _q = v))),
          const SizedBox(width: 6),
          Padding(padding: const EdgeInsets.only(bottom: 12), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _refresh, child: ForgeSoftButton(fields: ['🔄']))),
        ]),
        Wrap(spacing: 8, runSpacing: 6, children: [
          if (_can('pr.msg')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openCompose(null), child: ForgeSoftButton(fields: ['✉️ הודעה-חדשה'])),
          if (_can('pr.class')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openBroadcast(cls: true), child: ForgeSoftButton(fields: ['🏫 הודעה-לכיתה'])),
          if (_can('pr.org')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openBroadcast(cls: false), child: ForgeSoftButton(fields: ['🏛 הודעה-מוסדית'])),
          if (_can('pr.consent')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openConsentRequest(null), child: ForgeSoftButton(fields: ['📝 בקשת-אישור'])),
          if (_can('pr.meeting')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openMeeting(null), child: ForgeSoftButton(fields: ['📅 פגישה'])),
          if (_PrData.exportOk(_role)) GestureDetector(behavior: HitTestBehavior.opaque, onTap: _openExport, child: ForgeSoftButton(fields: ['⬇ ייצוא-לוג'])),
          if (_can('pr.crisis')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _crisis = !_crisis), child: ForgeSoftButton(fields: [_crisis ? '🚨 משבר: פעיל' : '🚨 מצב-משבר'])),
        ]),
        _gap(8),
        // צ׳יפי-חריגה (finderMatches) + צירי-כיתה/ערוץ/שפה
        Wrap(spacing: 8, runSpacing: 6, children: [
          for (final d in _PrData.filterDefs) _fchip(d['axis']!, d['label']!),
        ]),
        _gap(6),
        Wrap(spacing: 8, runSpacing: 6, children: [
          SizedBox(width: 150, child: DsEnumField(label: 'כיתה', options: ['הכל', ..._PrData.allClasses], value: _cls ?? 'הכל', onChanged: (v) => setState(() => _cls = v == 'הכל' ? null : v))),
          SizedBox(width: 150, child: DsEnumField(label: 'ערוץ', options: ['הכל', ..._PrData.channelLabel.values], value: _chan == null ? 'הכל' : _PrData.channelLabel[_chan]!, onChanged: (v) => setState(() => _chan = v == 'הכל' ? null : _PrData.channelLabel.entries.firstWhere((e) => e.value == v).key))),
          SizedBox(width: 150, child: DsEnumField(label: 'שפה', options: ['הכל', ...languageOptions], value: _lang ?? 'הכל', onChanged: (v) => setState(() => _lang = v == 'הכל' ? null : v))),
        ]),
        _gap(8),
        // KPI-10: hero = הורים דורשי-פעולה (המטרה) + 10 מדדי-מצב-התקשורת
        ForgeStripPanelFrame(fields: ['', ''], child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: ForgeStatPlain(fields: ['משפחות דורשות-פעולה', '$hero'])),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: ForgeStatPlain(fields: ['👪 משפחות', '$famN'])),
            Expanded(child: ForgeStatPlain(fields: ['🔄 קשר-מעודכן', '$freshN'])),
            Expanded(child: ForgeStatPlain(fields: ['📵 ללא-קשר-תקין', '$badN'])),
            Expanded(child: ForgeStatPlain(fields: ['📤 נשלחו-החודש', '$sentN'])),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: ForgeStatPlain(fields: ['👁 נקראו', '$readPct%'])),
            Expanded(child: ForgeStatPlain(fields: ['⏳ אישורים-ממתינים', '$pendN'])),
            Expanded(child: ForgeStatPlain(fields: ['⛔ אישורים-פגים', '$expN'])),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: ForgeStatPlain(fields: ['📨 פניות-פתוחות', '$openQ'])),
            Expanded(child: ForgeStatPlain(fields: ['⏱ זמן-תגובה-ממוצע', '${avgH.toStringAsFixed(1)} ש׳'])),
            Expanded(child: ForgeStatPlain(fields: ['📅 פגישות-השבוע', '$weekM'])),
          ]),
          const SizedBox(height: 10),
          ForgeLinearProgressStatus(fields: ['נקראו מתוך נשלחו-החודש', '${_PrData.readThisMonth} מתוך $sentN'], values: [sentN == 0 ? 0 : _PrData.readThisMonth / sentN]),
        ])),
        _gap(8),
        // ── מרכז-אוטומציות (פרואקטיבי): המערכת מתריעה לפני שדבר נשמט ──
        if (_PrData.localQuiet) ...[ForgeSectionPill(fields: ['שעות-מנוחה (${QUIET_FROM}:00–${QUIET_TO}:00): הודעות יוחזקו עד הבוקר${_crisis ? ' · 🚨 משבר: שליחה מיידית' : ''}', '']), _gap(8)],
        if (rb != null) ...[ForgeSectionPill(fields: ['מנוחה: $rb — הודעות לא-דחופות מוחזקות${_crisis ? ' · 🚨 משבר: שליחה מיידית' : ''}', '']), _gap(8)],
        if (staleN > 0) ...[ForgeSectionPill(fields: ['$staleN הודעות לא-נקראו מעל ${_PrData.unreadAlertDays * 24} שעות — לשקול ערוץ-אחר', '']), _gap(8)],
        if (unrespN > 0) ...[ForgeSectionPill(fields: ['$unrespN הורים לא-מגיבים ⇒ דגל-סיכון לתלמיד: ${scope.where((f) => _PrData.engagement(f) == 'unresponsive').map(_PrData.famLabel).join(' · ')}', '']), _gap(8)],
        if (_PrData.expiringConsents.isNotEmpty) ...[
          ForgeSectionPill(fields: ['${_PrData.expiringConsents.length} אישורים פוקעים תוך $shopExpiryWarnDays ימים: ${_PrData.expiringConsents.map((e) => e['itemName']).join(' · ')}', '']),
          if (_can('pr.consent') || _can('pr.consent.mark')) _wrap([for (final c in _PrData.pendingConsents.where((c) => dayDiff('${c['due']}', _PrData.today) >= -shopExpiryWarnDays)) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _PrData.remindConsent(_actor, c)), child: ForgeSoftButton(fields: ['🔔 תזכורת · ${c['title']} (${_PrData.remindersOf(c)})']))]),
          _gap(8),
        ],
        if (overdueQ > 0) ...[
          ForgeSectionPill(fields: ['$overdueQ פניות ללא-מענה מעבר לסף ⇒ העלאה-להנהלה', '']),
          _wrap([for (final q in _PrData.overdueInquiries.where((q) => !(q['escalated'] as bool) && _PrData.sensitiveOk(_role, q))) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _PrData.escalate(_actor, q)), child: ForgeSoftButton(fields: ['⬆ העלה: ${q['title']}']))]),
          _gap(8),
        ],
        if (_PrData.absencesToNotify.isNotEmpty && _can('pr.msg')) ...[
          ForgeSectionPill(fields: ['${_PrData.absencesToNotify.length} חיסורים לא-מוצדקים (מנוכחות) ממתינים להודעה-אוטומטית להורים', '']),
          _wrap([for (final a in _PrData.absencesToNotify) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _act(() => _PrData.notifyAbsence(_actor, a)), child: ForgeSoftButton(fields: ['📤 הודע · ${_PrData.famLabel(_PrData.fam(a['famId'] as String))} · ${a['date']}']))]),
          _gap(8),
        ],
        if (_PrData.summariesDue.isNotEmpty && _can('pr.meeting')) ...[
          ForgeSectionPill(fields: ['${_PrData.summariesDue.length} פגישות הסתיימו בלי סיכום להורים', '']),
          _gap(8),
        ],
        // בורר-מבט
        Align(alignment: Alignment.centerRight, child: ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in const ['👪 משפחות', '📥 תיבה', '📋 טבלה']) [s]], selected: {_mode}, onSelect: (i) => setState(() => _mode = i))),
        const SizedBox(height: 10),
        if (_loading)
          _loadingView()
        else if (_error != null)
          ForgeSectionPill(fields: [_error!, ''])
        else if (visible.isEmpty)
          Padding(padding: const EdgeInsets.only(top: 24), child: ForgeSearchEmptyState(fields: [scope.isEmpty ? 'אין הורים בהיקף שלך' : 'אין משפחות תואמות לחיפוש/סינון', '']))
        else if (_mode == 2)
          _table(visible)
        else if (_mode == 1)
          _inbox(visible)
        else
          for (final st in const ['act', 'unresponsive', 'quiet', 'active'])
            if (buckets[st]!.isNotEmpty)
              ForgeTitledSection(fields: ['${secTitle[st]} · ${buckets[st]!.length}', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[for (final f in buckets[st]!) _row(f)]])),
        _gap(8),
        // מוסדי: התפלגות ערוצים/שפות (DsBars מנתונים-חיים) — מזין "בחירת-ערוץ" ו"תרגום-אוטו"
        DsBars(title: '📡 ערוצים בפועל (מה-ההורה-עונה-לו)', labels: [for (final c in chanCounts) _PrData.channelLabel['${c[0]}'] ?? '${c[0]}'], values: [for (final c in chanCounts) (c[1] as int).toDouble()]),
        DsBars(title: '🗣 שפות-הבית (תרגום-אוטו לכל שפה ≠ עברית)', labels: [for (final c in langCounts) '${c[0]}'], values: [for (final c in langCounts) (c[1] as int).toDouble()]),
      ],
    );
  }

  void _act(void Function() f) => setState(f);

  void _refresh() {
    setState(() { _loading = true; _error = null; });
    Future.delayed(const Duration(milliseconds: 700), () { if (mounted) setState(() => _loading = false); });
  }

  Widget _loadingView() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
          CircularProgressIndicator(color: _acc), const SizedBox(height: 14),
          const Text('טוען הורים…', style: TextStyle(color: _muted, fontSize: 14)),
        ]),
      );

  // 📋 טבלה מונחית-חוזה (columnDefs · מקום-שמור)
  Widget _table(List<Map<String, dynamic>> rows) {
    final cols = [for (final c in _PrData.columnDefs) if (_PrData.colShown(c, rows)) c];
    return DsTable(
      labels: [for (final c in cols) c['label'] as String],
      rows: [for (final f in rows) [for (final c in cols) c['get'] != null ? (c['get'] as String Function(Map<String, dynamic>))(f) : '${f[c['key']] ?? '—'}']],
    );
  }

  // 📥 תיבת-הודעות: sortSupportThreads (לא-נקרא-צוות ראשון, חדש-ראשון) ⊕ BadgeCount ⊕ MediaRow
  Widget _inbox(List<Map<String, dynamic>> fams) {
    final ids = {for (final f in fams) f['id'] as String};
    final ts = [for (final f in fams) if (_PrData.thread(f['id'] as String) != null) _PrData.thread(f['id'] as String)!];
    final sorted = (sortSupportThreads(ts) as List).cast<Map<String, dynamic>>();
    final noThread = fams.where((f) => _PrData.thread(f['id'] as String) == null).toList();
    return ForgeTitledSection(fields: ['📥 תיבת-הודעות · ${sorted.length}', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[
      if (sorted.isEmpty) const ForgeSearchEmptyState(fields: ['אין שיחות', '']),
      for (final t in sorted)
        if (ids.contains(t['famId']))
          () {
            final f = _PrData.fam(t['famId'] as String);
            final un = _PrData.unreadByStaff(f['id'] as String);
            final byParent = _PrData.unreadByParent(f['id'] as String);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                Expanded(child: ForgeContactTile(fields: [_PrData.famLabel(f), '${supportDayLabel('${t['lastAt']}', _PrData.today, SUPPORT_DAY_LABEL_T.cast<String, dynamic>())} ${supportMsgTime('${t['lastAt']}')} · ${supportPreview(t['lastText'], 36)}'])),
                if (un > 0) BadgeCount(count: un),
                if (un == 0) Flexible(child: ForgeIntelPill(fields: [byParent == 0 ? '✓✓ נקרא' : '✓ ${byParent} לא-נקרא'])),
                IconButton(onPressed: () => _openPanel(f, tab: 0), icon: const Icon(Icons.chevron_left, color: _acc, size: 26), tooltip: 'פתח שיחה'),
              ]),
            );
          }(),
      if (noThread.isNotEmpty) ...[
        _gap(6), _label('ללא שיחה עדיין · ${noThread.length}'),
        for (final f in noThread) Row(children: [Expanded(child: ForgeContactTile(fields: [_PrData.famLabel(f), _PrData.kidsLabel(f)])), if (_can('pr.msg')) Flexible(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openCompose(f), child: ForgeSoftButton(fields: ['✉️'])))]),
      ],
    ]]));
  }

  // ═══ כרטיס-משפחה (טריאז'): כותרת + מצב-קשר פר-הורה + חריגות + פעולות-מהירות ═══
  Widget _row(Map<String, dynamic> f) {
    final id = f['id'] as String;
    final byParent = _PrData.unreadByParent(id);
    final header = Row(children: [
      Expanded(child: ForgeContactTile(fields: [_PrData.famLabel(f), _PrData.kidsLabel(f)])),
      if (_PrData.unreadByStaff(id) > 0) BadgeCount(count: _PrData.unreadByStaff(id)),
      IconButton(onPressed: () => _openPanel(f), icon: const Icon(Icons.chevron_left, color: _acc, size: 26), tooltip: 'פרטים ופעולות'),
    ]);
    final chips = <Widget>[
      ForgeIntelPill(fields: [_PrData.engagementLabel[_PrData.engagement(f)]!]),
      for (final pk in _PrData.parentKeys(f)) _contactChip(f, pk),
      if (_PrData.unreadStale(f)) ForgeIntelPill(fields: ['👁 לא-נקרא ${dayDiff(_PrData.lastAdminAt(id)!, _PrData.today)} י׳ · $byParent']),
      if (_PrData.hasFailed(f)) const ForgeIntelPill(fields: ['⚠️ הודעה-נכשלה']),
      for (final c in _PrData.consentsOf(id)) if (_PrData.consentState(c) != 'received') ForgeIntelPill(fields: ['${_PrData.consentKind[c['kind']]} ${_PrData.consentLabel[_PrData.consentState(c)]}']),
      for (final q in _PrData.inquiriesOf(id)) if ('${q['doneAt']}'.isEmpty && _PrData.sensitiveOk(_role, q)) ForgeIntelPill(fields: ['📨 ${q['title']}${_PrData.overdue(q) ? ' · חורג' : ''}${q['escalated'] == true ? ' · ⬆' : ''}']),
      if (_PrData.feesFeed[id] != null && _can('pr.org')) ForgeIntelPill(fields: ['💳 חוב ₪${_PrData.feesFeed[id]}']),
      if ((f['custody'] as Map?)?['restricted'] == true) const ForgeIntelPill(fields: ['⚖️ הסדר-ראייה מגביל']),
      if (_PrData.blockedOf(f) != null) ForgeIntelPill(fields: ['🚫 ${_PrData.parent(f, _PrData.blockedOf(f)!)['role']} חסום/ה']),
      for (final pk in _PrData.parentKeys(f)) if (_PrData.parent(f, pk)['lang'] != 'עברית') ForgeIntelPill(fields: ['🌐 תרגום-אוטו: ${_PrData.parent(f, pk)['lang']}']),
      if (!_PrData.contactFresh(f)) ForgeIntelPill(fields: ['🕰 קשר לא-עודכן ${dayDiff('${f['contactUpdatedAt']}', _PrData.today)} י׳']),
    ];
    final next = _PrData.columnDefs[11]['get'] as String Function(Map<String, dynamic>);
    return _card(Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      header,
      _wrap(chips),
      if (next(f) != '—') Padding(padding: const EdgeInsets.only(top: 6, right: 4), child: Text('📅 פגישה הבאה: ${next(f)}', style: const TextStyle(color: _muted, fontSize: 12.5))),
      _wrap([
        if (_can('pr.msg')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openCompose(f), child: ForgeSoftButton(fields: ['✉️ הודעה'])),
        if (_can('pr.inquiry')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openInquiry(f), child: ForgeSoftButton(fields: ['📨 פתח-פנייה'])),
        if (_can('pr.meeting')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openMeeting(f), child: ForgeSoftButton(fields: ['📅 פגישה'])),
      ], top: 10),
    ]));
  }

  // מצב-קשר פר-הורה = ערוץ-חכם ⊕ contactState ⊕ שעות-נוחות — עובדות מורכבות בשבב אחד לכל הורה
  Widget _contactChip(Map<String, dynamic> f, String pk) {
    final id = f['id'] as String;
    final st = _PrData.contactState(id, pk);
    final ch = _PrData.channelLabel[_PrData.smartChannel(f, pk)];
    final label = '${_PrData.parent(f, pk)['role']} · $ch${_PrData.channelOverridden(f, pk) ? '*' : ''} · ${st == 'ok' ? '✅' : st == 'bad' ? '⚠️ ${_PrData.contactWhy(id, pk)}' : '🔒 לא-הוזרק'}';
    return ForgeIntelPill(fields: [label]);
  }

  // ═══ פאנל הורה/שיחה-נבחר · GlassCard · 9 טאבים (SegmentedSwitch) ═══
  void _openPanel(Map<String, dynamic> f, {int tab = 0}) {
    final id = f['id'] as String;
    var sel = tab;
    var portalParent = _PrData.parentKeys(f).first;
    var reply = '';
    var editKey = _PrData.templateList.first['key']!;
    var editText = '';
    _PrData.markReadByStaff(id);
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        void act(void Function() fn) { fn(); setSheet(() {}); setState(() {}); }
        const tabs = ['💬 שיחה', '📝 אישורים', '📨 פניות', '📅 פגישות', '🧩 תבניות', '🏛 מוסדי', '👁 פורטל', '📜 לוג', '🔍 אודיט'];
        Widget body;
        switch (sel) {
          case 0: body = _convo(f, reply, (v) => setSheet(() => reply = v), act);
          case 1: body = _consentsTab(f, act);
          case 2: body = _inquiriesTab(f, act);
          case 3: body = _meetingsTab(f, act);
          case 4: body = _templatesTab(editKey, editText, (k, t) => setSheet(() { editKey = k; editText = t; }), act);
          case 5: body = _orgTab(act);
          case 6: body = _portalTab(f, portalParent, (pk) => setSheet(() => portalParent = pk), act);
          case 7: body = _logTab(id);
          default: body = _auditTab();
        }
        return DraggableScrollableSheet(
          initialChildSize: 0.8, minChildSize: 0.4, maxChildSize: 0.96, expand: false,
          builder: (ctx, scroll) => Padding(padding: const EdgeInsets.all(12), child: ForgeStripPanelFrame(fields: ['', ''], child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
            ForgeContactTile(fields: [_PrData.famLabel(f), _PrData.kidsLabel(f)]),
            _gap(8),
            // זהות+ילדים · ערוץ+שפה+שעות — פר-הורה (זהות מוזרקת)
            for (final pk in _PrData.parentKeys(f))
              Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Wrap(spacing: 8, runSpacing: 6, children: [
                ForgeIntelPill(fields: ['${_PrData.parent(f, pk)['role']}: ${_PrData.nameOf(id, pk) ?? '🔒 מוזרק-בהצבה'}']),
                ForgeIntelPill(fields: ['📞 ${_PrData.phoneShown(id, pk)}']),
                ForgeIntelPill(fields: ['📡 ${_PrData.channelLabel[_PrData.smartChannel(f, pk)]}${_PrData.channelOverridden(f, pk) ? ' (ענה-כאן, מועדף: ${_PrData.channelLabel[_PrData.parent(f, pk)['channel']]})' : ''}']),
                ForgeIntelPill(fields: ['🗣 ${_PrData.parent(f, pk)['lang']}']),
                ForgeIntelPill(fields: ['🕐 ${'${_PrData.parent(f, pk)['hours']}'.isEmpty ? 'שעות-נוחות: לא-הוגדר' : _PrData.parent(f, pk)['hours']}']),
                if (_PrData.isBlocked(f, pk)) const ForgeIntelPill(fields: ['🚫 חסום/ה']),
                if (_PrData.sendHold(f, pk) != null && !_PrData.isBlocked(f, pk)) ForgeIntelPill(fields: ['⏸ ${_PrData.sendHold(f, pk)}']),
              ])),
            if (f['guardian'] != null) ForgeIntelPill(fields: ['🧓 אפוטרופוס: ${f['guardian']} · ${_PrData.identity[id]?['emergencyName'] ?? '🔒 מוזרק-בהצבה'}']),
            Wrap(spacing: 8, runSpacing: 6, children: [
              ForgeIntelPill(fields: ['🆘 חירום: ${_PrData.identity[id]?['emergencyName'] ?? '🔒 מוזרק-בהצבה'}']),
              ForgeIntelPill(fields: ['✉️ מייל: ${(_PrData.identity[id]?['email'] ?? '').isEmpty ? '🔒 מוזרק-בהצבה' : _PrData.identity[id]!['email']}']),
              ForgeIntelPill(fields: ['📷 מדיה: ${_PrData.mediaOf(f) ? 'מאושר' : 'לא'}']),
            ]),
            _gap(10),
            // מבט-הילד (מה-שההורה-רואה): נוכחות/ציונים/חוב — הזנות-בין-מודולים
            _label('מבט-הילד'),
            for (final k in f['kids'] as List)
              Row(children: [
                Expanded(child: ForgeStatPlain(fields: ['${k['cls']}', '${(k as Map)['first']}'])),
                Expanded(child: ForgeStatPlain(fields: ['📆 חיסורים/30י', '${_PrData.childFeed[k['sid']]?['absences30'] ?? '—'}'])),
                Expanded(child: ForgeStatPlain(fields: ['📊 ממוצע', '${_PrData.childFeed[k['sid']]?['avg'] ?? '—'}'])),
                Expanded(child: ForgeStatPlain(fields: ['💳 חוב', _PrData.feesFeed[id] == null ? '✓' : '₪${_PrData.feesFeed[id]}'])),
              ]),
            _gap(10),
            _label('פעולות'),
            _gap(6),
            Builder(builder: (_) {
              final acts = <Widget>[
                if (_can('pr.msg')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openCompose(f), child: ForgeSoftButton(fields: ['✉️ הודעה-אישית'])),
                if (_can('pr.consent')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openConsentRequest(f), child: ForgeSoftButton(fields: ['📝 בקשת-אישור'])),
                if (_can('pr.inquiry')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openInquiry(f), child: ForgeSoftButton(fields: ['📨 פתח-פנייה'])),
                if (_can('pr.meeting')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openMeeting(f), child: ForgeSoftButton(fields: ['📅 קבע-פגישה'])),
                if (_can('pr.contact')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openContact(f), child: ForgeSoftButton(fields: ['📞 עדכן-קשר'])),
                if (_can('pr.contact')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() { _PrData.mediaAdj[id] = !_PrData.mediaOf(f); _PrData.audit(_actor, 'הרשאת-מדיה', id, note: _PrData.mediaOf(f) ? 'כן' : 'לא'); }), child: ForgeSoftButton(fields: [_PrData.mediaOf(f) ? '📷 בטל הרשאת-מדיה' : '📷 אשר מדיה'])),
                if (_can('pr.msg')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() { _PrData.markedUnresponsive.contains(id) ? _PrData.markedUnresponsive.remove(id) : _PrData.markedUnresponsive.add(id); _PrData.audit(_actor, 'סימון לא-מגיב', id); }), child: ForgeSoftButton(fields: [_PrData.markedUnresponsive.contains(id) ? '↩ בטל לא-מגיב' : '🔴 סמן לא-מגיב'])),
                if (_can('pr.block')) for (final pk in _PrData.parentKeys(f)) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() { _PrData.blockedAdj[id] = _PrData.isBlocked(f, pk) ? null : pk; _PrData.audit(_actor, 'חסימת-הורה', id, to: pk, note: _PrData.isBlocked(f, pk) ? 'חסום' : 'שוחרר'); }), child: ForgeSoftButton(fields: [_PrData.isBlocked(f, pk) ? '✅ בטל חסימת ${_PrData.parent(f, pk)['role']}' : '🚫 חסום ${_PrData.parent(f, pk)['role']}'])),
                if (_can('pr.msg')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openLetter(f), child: ForgeSoftButton(fields: ['🖨 הדפס-מכתב'])),
                if (_can('pr.msg')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() { for (final l in _PrData.weeklyDigest(f)) { _PrData.send(_actor, f, _PrData.parentKeys(f).first, l); } }), child: ForgeSoftButton(fields: ['📬 סיכום-שבועי'])),
              ];
              return acts.isEmpty ? const ForgeSectionPill(fields: ['צפייה-בלבד — אין הרשאת-פעולה', '']) : Wrap(spacing: 8, runSpacing: 8, children: acts);
            }),
            _gap(14),
            Align(alignment: Alignment.centerRight, child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in tabs) [s]], selected: {sel}, onSelect: (i) => setSheet(() => sel = i)))),
            _gap(12),
            body,
          ]))),
        );
      }),
    );
  }

  // 💬 שיחה: ציר-הודעות דו-כיווני (PureBubble ⊕ receipt) + מפרידי-יום (supportDayLabel) + מענה-מהיר
  Widget _convo(Map<String, dynamic> f, String reply, ValueChanged<String> onReply, void Function(void Function()) act) {
    final id = f['id'] as String;
    final ms = _PrData.msgsOf(id);
    final byParent = _PrData.unreadByParent(id);
    final children = <Widget>[];
    String? lastDay;
    final unreadCut = ms.where((m) => m['from'] == 'admin').length - byParent; // הודעות-צוות שנקראו = הכל פחות לא-נקרא
    var adminIdx = 0;
    for (final m in ms) {
      final day = '${m['at']}'.split('T').first;
      if (day != lastDay) {
        children.add(Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: PureBubble(text: '${supportDayLabel('${m['at']}', _PrData.today, SUPPORT_DAY_LABEL_T.cast<String, dynamic>())}', kind: PureBubbleKind.system)));
        lastDay = day;
      }
      final out = m['from'] == 'admin';
      PureReceipt r = PureReceipt.none;
      if (out) {
        r = m['status'] == 'failed' ? PureReceipt.none : m['status'] == 'pending' ? PureReceipt.sent : adminIdx < unreadCut ? PureReceipt.read : PureReceipt.delivered;
        adminIdx++;
      }
      children.add(Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: PureBubble(
        text: '${m['status'] == 'failed' ? '⚠️ נכשל · ' : m['status'] == 'pending' ? '⏸ מוחזק · ' : ''}${m['text']}',
        time: '${supportMsgTime('${m['at']}')} · ${_PrData.channelLabel[m['via']]}',
        kind: out ? (m['status'] == 'pending' ? PureBubbleKind.sending : PureBubbleKind.outgoing) : PureBubbleKind.incoming,
        receipt: r,
      )));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        _label('שיחה · ${ms.length}'),
        const Spacer(),
        Flexible(child: ForgeIntelPill(fields: [byParent == 0 ? '✓✓ ההורה קרא הכל' : '✓ $byParent טרם נקראו'])),
      ]),
      _gap(8),
      if (ms.isEmpty) const ForgeSearchEmptyState(fields: ['אין הודעות עדיין — פתח בהודעה-אישית', '']) else ...children,
      _gap(10),
      if (_can('pr.msg')) ...[
        DsField(label: 'מענה מהיר', hint: 'כתוב/י הודעה…', value: reply, onChanged: onReply),
        _wrap([
          for (final pk in _PrData.parentKeys(f)) if (!_PrData.isBlocked(f, pk)) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() { _PrData.send(_actor, f, pk, reply, crisis: _crisis); onReply(''); }), child: ForgeSoftButton(fields: ['📤 שלח ל${_PrData.parent(f, pk)['role']} (${_PrData.channelLabel[_PrData.smartChannel(f, pk)]})'])),
          for (final pk in _PrData.parentKeys(f)) if (_PrData.waHrefOf(id, pk, reply) != null) ForgeIntelPill(fields: ['🔗 wa.me מוכן ל${_PrData.parent(f, pk)['role']}']),
        ]),
      ],
    ]);
  }

  // 📝 אישורים: טבלה מה/מתי/סטטוס (DsTable) + פעולות סמן-התקבל/תזכורת-מדורגת
  Widget _consentsTab(Map<String, dynamic> f, void Function(void Function()) act) {
    final cs = _PrData.consentsOf(f['id'] as String);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _label('אישורים · ${cs.length}'),
      _gap(6),
      if (cs.isEmpty) const ForgeSearchEmptyState(fields: ['אין בקשות-אישור', '']) else
        DsTable(labels: const ['מה', 'סוג', 'נשלח', 'עד', 'סטטוס', 'תזכורות'], rows: [for (final c in cs) ['${c['title']}', _PrData.consentKind[c['kind']]!, '${c['sentAt']}', '${c['due']}', _PrData.consentLabel[_PrData.consentState(c)]!, '${_PrData.remindersOf(c)}']]),
      _wrap([
        for (final c in cs) if (_PrData.consentState(c) == 'pending' || _PrData.consentState(c) == 'expired') ...[
          if (_can('pr.consent.mark')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() { _PrData.consentStatus[c['id'] as String] = 'received'; _PrData.audit(_actor, 'אישור-התקבל', f['id'] as String, note: '${c['title']}'); }), child: ForgeSoftButton(fields: ['✅ התקבל: ${c['title']}'])),
          if (_can('pr.consent') || _can('pr.consent.mark')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _PrData.remindConsent(_actor, c)), child: ForgeSoftButton(fields: ['🔔 תזכורת ${_PrData.reminderTier(c) == 'escalate' ? '⬆ + העלאה' : _PrData.reminderTier(c) == 'urgent' ? 'דחופה' : 'ידידותית'}'])),
        ],
      ]),
      _gap(8),
      const ForgeSectionPill(fields: ['מקום-שמור: חתימה-דיגיטלית-על-אישור — מאיר כשיחובר ספק-חתימה', '']),
    ]);
  }

  // 📨 פניות: פתוחות (openTasksFor) + חורגות (taskOverdue) + ענה/סגור/העלה — רגישות מגודרות (יועץ/הנהלה)
  Widget _inquiriesTab(Map<String, dynamic> f, void Function(void Function()) act) {
    final qs = _PrData.inquiriesOf(f['id'] as String).where((q) => _PrData.sensitiveOk(_role, q)).toList();
    final hidden = _PrData.inquiriesOf(f['id'] as String).length - qs.length;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _label('פניות · ${qs.length}${hidden > 0 ? ' · $hidden רגישות מוסתרות' : ''}'),
      _gap(6),
      if (qs.isEmpty) const ForgeSearchEmptyState(fields: ['אין פניות', '']),
      for (final q in qs)
        ForgeNotifRow(items: [['${'${q['doneAt']}'.isNotEmpty ? '✅' : _PrData.overdue(q) ? '⛔' : '📨'} ${q['title']}${q['sensitive'] == true ? ' · 🔒 רגיש' : ''}${q['escalated'] == true ? ' · ⬆ הנהלה' : ''}', '${q['createdAt']} → עד ${q['due']}']]),
      _wrap([
        for (final q in qs) if ('${q['doneAt']}'.isEmpty && _can('pr.inquiry')) ...[
          if ('${q['answeredAt']}'.isEmpty) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() { _PrData.inquiryAnswered[q['id'] as String] = _PrData.nowIso(); _PrData.send(_actor, f, _PrData.parentKeys(f).first, 'בנוגע לפנייתך "${q['title']}": טופל, נעדכן בהמשך.', crisis: _crisis); _PrData.audit(_actor, 'מענה-לפנייה', f['id'] as String, note: '${q['title']}'); }), child: ForgeSoftButton(fields: ['💬 ענה: ${q['title']}'])),
          GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() { _PrData.inquiryDone[q['id'] as String] = _PrData.nowIso(); _PrData.audit(_actor, 'סגירת-פנייה', f['id'] as String, note: '${q['title']}'); }), child: ForgeSoftButton(fields: ['✔ סגור: ${q['title']}'])),
          if (_PrData.overdue(q) && q['escalated'] != true) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _PrData.escalate(_actor, q)), child: ForgeSoftButton(fields: ['⬆ העלה-להנהלה'])),
        ],
      ]),
    ]);
  }

  // 📅 פגישות: upcomingMeetings (7 ימים) + היסטוריה + סיכום-פגישה (renderTemplate) + תזכורת
  Widget _meetingsTab(Map<String, dynamic> f, void Function(void Function()) act) {
    final ms = _PrData.meetingsOf(f['id'] as String)..sort((a, b) => '${b['date']}'.compareTo('${a['date']}'));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _label('פגישות · ${ms.length}'),
      _gap(6),
      if (ms.isEmpty) const ForgeSearchEmptyState(fields: ['אין פגישות', '']),
      for (final m in ms)
        ForgeNotifRow(items: [['${m['done'] == true ? '✅' : '📅'} ${m['title']}', '${m['date']} ${m['time']}']]),
      _wrap([
        for (final m in ms) if (_can('pr.meeting')) ...[
          if (m['done'] != true) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _PrData.send(_actor, f, _PrData.parentKeys(f).first, _PrData.render('sc.meeting', {'date': '${m['date']}', 'time': '${m['time']}', 'what': '${m['title']}'}), crisis: _crisis)), child: ForgeSoftButton(fields: ['🔔 תזכורת: ${m['title']}'])),
          if (m['done'] == true && m['summarySent'] != true) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() { _PrData.send(_actor, f, _PrData.parentKeys(f).first, _PrData.render('sc.summary', {'date': '${m['date']}', 'what': '${m['title']}', 'note': 'סוכם המשך מעקב'}), crisis: _crisis); _PrData.meetingSummary[m['id'] as String] = true; }), child: ForgeSoftButton(fields: ['🗒 שלח-סיכום: ${m['title']}'])),
          if (m['done'] != true) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() { final i = _PrData.extraMeetings.indexWhere((x) => x['id'] == m['id']); if (i >= 0) { _PrData.extraMeetings[i] = {..._PrData.extraMeetings[i], 'done': true}; } else { _PrData.extraMeetings.add({...m, 'done': true, 'id': '${m['id']}-done'}); } _PrData.audit(_actor, 'פגישה-התקיימה', f['id'] as String, note: '${m['title']}'); }), child: ForgeSoftButton(fields: ['✔ התקיימה: ${m['title']}'])),
        ],
      ]),
    ]);
  }

  // 🧩 תבניות: templateDefs (מדף) + בית-ספר · עריכה (override ב-templateCfg) · תצוגה-מקדימה ברנדר
  Widget _templatesTab(String key, String text, void Function(String, String) onEdit, void Function(void Function()) act) {
    final defs = _PrData.templateList;
    final cur = defs.firstWhere((d) => d['key'] == key);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _label('תבניות-הודעה · ${defs.length}'),
      _gap(6),
      DsEnumField(label: 'תבנית', options: [for (final d in defs) d['label']!], value: cur['label']!, onChanged: (v) => onEdit(defs.firstWhere((d) => d['label'] == v)['key']!, '')),
      Text('ברירת-מחדל: ${cur['def']}', style: const TextStyle(color: _muted, fontSize: 12.5)),
      _gap(6),
      Text('תצוגה-מקדימה: ${_PrData.render(key, const {'first': 'נועה', 'date': '2026-09-04', 'what': 'טיול', 'due': '2026-09-10', 'time': '17:30', 'note': '…', 'name': 'הורה', 'amount': '0', 'link': '—', 'absences': '1', 'avg': '88'})}', style: const TextStyle(color: _ink, fontSize: 13)),
      if (_can('pr.templates') || _can('pr.org')) ...[
        DsField(label: 'עריכת-תבנית (משתנים ב-{סוגריים})', hint: cur['def']!, value: text, onChanged: (v) => onEdit(key, v)),
        _wrap([
          GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() { _PrData.templateCfg = {'templates': {...?(_PrData.templateCfg['templates'] as Map?), key: text}}; _PrData.audit(_actor, 'עריכת-תבנית', '*', note: key); }), child: ForgeSoftButton(fields: ['💾 שמור עריכה'])),
          GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() { _PrData.templateCfg = {'templates': {...?(_PrData.templateCfg['templates'] as Map?)}..remove(key)}; }), child: ForgeSoftButton(fields: ['↩ ברירת-מחדל'])),
        ]),
      ],
    ]);
  }

  // 🏛 מוסדי: הודעות-כלל + שידורי-כיתה מהלוג + נמענים-ברי-השגה (bulkWaRecipients)
  Widget _orgTab(void Function(void Function()) act) {
    final bcasts = _PrData.log.where((e) => e['action'] == 'הודעה-מוסדית' || e['action'] == 'הודעה-לכיתה').toList();
    final targets = [for (final f in _PrData.families) for (final pk in _PrData.parentKeys(f)) if (!_PrData.isBlocked(f, pk)) {'id': '${f['id']}|$pk', 'name': pk, 'phone': _PrData.phoneOf(f['id'] as String, pk) ?? ''}];
    final reach = bulkWaRecipients(targets, waDigits);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _label('הודעות-כלל'),
      _gap(6),
      Row(children: [
        Expanded(child: ForgeStatPlain(fields: ['הורים מורשים', '${targets.length}'])),
        Expanded(child: ForgeStatPlain(fields: ['ברי-השגה בוואטסאפ', '${reach.length}'])),
        Expanded(child: ForgeStatPlain(fields: ['ערוץ-חלופי/לא-הוזרק', '${targets.length - reach.length}'])),
      ]),
      _gap(8),
      if (bcasts.isEmpty) const ForgeSearchEmptyState(fields: ['טרם נשלחו הודעות-כלל', '']),
      for (final e in bcasts) ForgeNotifRow(items: [['${e['action']} · ${e['famId']}', '${e['at']}']]),
      _wrap([
        if (_can('pr.class')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openBroadcast(cls: true), child: ForgeSoftButton(fields: ['🏫 הודעה-לכיתה'])),
        if (_can('pr.org')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openBroadcast(cls: false), child: ForgeSoftButton(fields: ['🏛 הודעה-מוסדית'])),
      ]),
    ]);
  }

  // 👁 פורטל (תצוגת-הורה): מבט-הילד לפי הסדר-ראייה (חוק-6 · משמורת גוברת) — מי-רואה-מה
  Widget _portalTab(Map<String, dynamic> f, String pk, ValueChanged<String> onParent, void Function(void Function()) act) {
    final pks = _PrData.parentKeys(f);
    final views = _PrData.visibleViews(f, pk);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [_label('תצוגת-הורה'), const Spacer(), Flexible(child: ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in [for (final k in pks) '${_PrData.parent(f, k)['role']}']) [s]], selected: {pks.indexOf(pk)}, onSelect: (i) => onParent(pks[i])))]),
      _gap(8),
      if (_PrData.isBlocked(f, pk)) const ForgeSectionPill(fields: ['הורה חסום — אין גישה לפורטל', ''])
      else ...[
        if ((f['custody'] as Map?)?['restricted'] == true) ForgeSectionPill(fields: ['הסדר-ראייה מגביל: ${_PrData.parent(f, pk)['role']} רואה ${views.map((v) => _PrData.childViewLabel[v]).join(' · ')}${views.length == _PrData.childViews.length ? ' (הכל)' : ' בלבד'}', '']),
        _gap(6),
        for (final k in f['kids'] as List)
          Row(children: [
            Expanded(child: ForgeStatPlain(fields: ['${k['cls']}', '${(k as Map)['first']}'])),
            if (views.contains('attendance')) Expanded(child: ForgeStatPlain(fields: ['📆 חיסורים', '${_PrData.childFeed[k['sid']]?['absences30'] ?? '—'}'])),
            if (views.contains('grades')) Expanded(child: ForgeStatPlain(fields: ['📊 ממוצע', '${_PrData.childFeed[k['sid']]?['avg'] ?? '—'}'])),
            if (views.contains('fees')) Expanded(child: ForgeStatPlain(fields: ['💳 חוב', _PrData.feesFeed[f['id']] == null ? '✓' : '₪${_PrData.feesFeed[f['id']]}'])),
          ]),
        _gap(6),
        _label('המערכת · שקע-אינטגרציה (חוגים/מערכת) — מאיר כשיחובר'),
        _gap(8),
        const ForgeSectionPill(fields: ['מקום-שמור: פורטל-מזוהה (login) · תשלום-מהפורטל · צ׳אט-חי — מאירים כשיחוברו ספקי-זהות/סליקה', '']),
      ],
    ]);
  }

  // 📜 לוג-שליחה (למשפחה) · 🔍 אודיט (כל-הלוג · הנהלה)
  Widget _logTab(String famId) {
    final es = _PrData.log.where((e) => e['famId'] == famId).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _label('לוג-שליחה · ${es.length}'),
      if (es.isEmpty) const ForgeSearchEmptyState(fields: ['אין פעולות רשומות למשפחה בסשן זה', '']),
      for (final e in es) ForgeNotifRow(items: [['${e['action']} · ${e['status']}', '${e['at']}']]),
    ]);
  }
  Widget _auditTab() {
    if (!_can('pr.audit') && !_can('pr.org')) return const ForgeSectionPill(fields: ['אודיט מלא — הנהלה/מזכירות בלבד', '']);
    final lines = _PrData.auditLines();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _label('אודיט · ${_PrData.log.length}'),
      for (final l in lines) Text(l, style: const TextStyle(color: _ink, fontSize: 12.5, height: 1.5)),
      if (_PrData.log.isEmpty) const ForgeSearchEmptyState(fields: ['אין פעולות בסשן זה', '']),
    ]);
  }

  // ═══ גיליונות-פעולה (DsField/DsEnumField/DsDateField ⊕ GlassCard) ═══
  void _sheet(Widget Function(BuildContext ctx, void Function(void Function()) setSheet) builder) {
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) => DraggableScrollableSheet(
        initialChildSize: 0.66, minChildSize: 0.4, maxChildSize: 0.95, expand: false,
        builder: (ctx, scroll) => Padding(padding: const EdgeInsets.all(12), child: ForgeStripPanelFrame(fields: ['', ''], child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [builder(ctx, setSheet)]))),
      )),
    );
  }

  // ✉️ הודעה-אישית: נמען ⊕ ערוץ (חכם) ⊕ תבנית ⊕ טקסט ⊕ הכרעת-שליחה (sendHold) — תוצאה בלוג
  void _openCompose(Map<String, dynamic>? f0) {
    var famId = f0?['id'] as String? ?? _PrData.scope(_role).first['id'] as String;
    var pk = 'p1';
    var text = '';
    String? channel;
    String? result;
    var tpl = 'ללא';
    _sheet((ctx, setSheet) {
      final f = _PrData.fam(famId);
      final hold = _PrData.sendHold(f, pk, crisis: _crisis);
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ForgeContactTile(fields: ['הודעה-אישית', _PrData.famLabel(f)]),
        DsEnumField(label: 'משפחה', options: [for (final x in _PrData.scope(_role)) _PrData.famLabel(x)], value: _PrData.famLabel(f), onChanged: (v) => setSheet(() { famId = _PrData.scope(_role).firstWhere((x) => _PrData.famLabel(x) == v)['id'] as String; pk = 'p1'; })),
        DsEnumField(label: 'נמען', options: [for (final k in _PrData.parentKeys(f)) '${_PrData.parent(f, k)['role']}'], value: '${_PrData.parent(f, pk)['role']}', onChanged: (v) => setSheet(() => pk = _PrData.parentKeys(f).firstWhere((k) => _PrData.parent(f, k)['role'] == v))),
        DsEnumField(label: 'ערוץ (ברירת-מחדל: חכם = מה-ההורה-עונה-לו)', options: ['חכם: ${_PrData.channelLabel[_PrData.smartChannel(f, pk)]}', ..._PrData.channelLabel.values], value: channel == null ? 'חכם: ${_PrData.channelLabel[_PrData.smartChannel(f, pk)]}' : _PrData.channelLabel[channel]!, onChanged: (v) => setSheet(() => channel = v.startsWith('חכם') ? null : _PrData.channelLabel.entries.firstWhere((e) => e.value == v).key)),
        DsEnumField(label: 'תבנית', options: ['ללא', for (final d in _PrData.templateList) d['label']!], value: tpl, onChanged: (v) => setSheet(() { tpl = v; if (v != 'ללא') text = _PrData.render(_PrData.templateList.firstWhere((d) => d['label'] == v)['key']!, {'first': '${(f['kids'] as List).first['first']}', 'date': _PrData.today, 'what': 'הטיול השנתי', 'due': '2026-09-10', 'time': '17:30', 'note': '', 'name': '${_PrData.parent(f, pk)['role']}', 'amount': '${_PrData.feesFeed[famId] ?? 0}', 'link': '—', 'absences': '${_PrData.childFeed[(f['kids'] as List).first['sid']]?['absences30'] ?? '—'}', 'avg': '${_PrData.childFeed[(f['kids'] as List).first['sid']]?['avg'] ?? '—'}'}); })),
        DsField(label: 'הודעה (עד $supportMsgMax תווים · ${_PrData.parent(f, pk)['lang'] != 'עברית' ? 'תרגום-אוטו ל${_PrData.parent(f, pk)['lang']} — מקום-שמור' : 'עברית'})', hint: 'תוכן ההודעה…', value: text, onChanged: (v) => setSheet(() => text = v)),
        if (hold != null) ForgeSectionPill(fields: [hold == 'הורה חסום' ? 'הורה חסום — לא ניתן לשלוח' : 'תוחזק: $hold — תישלח בחלון הבא${_can('pr.crisis') ? ' (או במצב-משבר)' : ''}', '']),
        if (_PrData.contactState(famId, pk) != 'ok' && (channel ?? _PrData.smartChannel(f, pk)) != 'email') ForgeSectionPill(fields: ['קשר-לא-תקין (${_PrData.contactState(famId, pk) == 'none' ? 'טלפון לא-הוזרק' : _PrData.contactWhy(famId, pk)}) — השליחה תיכשל; עדכן-קשר תחילה', '']),
        _gap(8),
        _wrap([
          GestureDetector(behavior: HitTestBehavior.opaque, onTap: () { final st = _PrData.send(_actor, f, pk, text, channel: channel, crisis: _crisis); setSheet(() => result = st); setState(() {}); }, child: ForgeSoftButton(fields: ['📤 שלח'])),
          if (result != null) ForgeIntelPill(fields: [{'sent': '✅ נשלח', 'queued': '⏸ מוחזק לחלון', 'failed': '⚠️ נכשל (קשר)', 'blocked': '🚫 חסום', 'empty': '✋ ריק'}[result]!]),
        ]),
      ]);
    });
  }

  // 🏫/🏛 שידור: כיתה/מוסד ⊕ תבנית ⊕ bulkWaRecipients ⊕ תוצאה מקובצת
  void _openBroadcast({required bool cls}) {
    var target = cls ? (_PrData.roleDefs[_role]['classes'] as List?)?.first as String? ?? _PrData.allClasses.first : '*';
    var text = '';
    Map<String, int>? result;
    _sheet((ctx, setSheet) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ForgeContactTile(fields: [cls ? 'הודעה-לכיתה' : 'הודעה-מוסדית', cls ? 'כל הורי הכיתה (ללא חסומים)' : 'כל ההורים המורשים']),
      if (cls) DsEnumField(label: 'כיתה', options: (_PrData.roleDefs[_role]['classes'] as List?)?.cast<String>() ?? _PrData.allClasses, value: target, onChanged: (v) => setSheet(() => target = v)),
      DsField(label: 'הודעה', hint: 'תוכן ההודעה לכולם…', value: text, onChanged: (v) => setSheet(() => text = v)),
      _gap(8),
      _wrap([
        GestureDetector(behavior: HitTestBehavior.opaque, onTap: () { final r = _PrData.broadcast(_actor, text, cls: cls ? target : null); setSheet(() => result = r); setState(() {}); }, child: ForgeSoftButton(fields: ['📤 שדר'])),
        if (result != null) ...[
          ForgeIntelPill(fields: ['✅ נשלחו ${result!['sent']}']),
          ForgeIntelPill(fields: ['⏸ מוחזקים ${result!['queued']}']),
          ForgeIntelPill(fields: ['⚠️ נכשלו ${result!['failed']}']),
        ],
      ]),
    ]));
  }

  // 📝 בקשת-אישור: סוג (טיול/מדיה/תרופה) ⊕ מועד ⊕ שליחה עם תבנית
  void _openConsentRequest(Map<String, dynamic>? f0) {
    var famId = f0?['id'] as String? ?? _PrData.scope(_role).first['id'] as String;
    var kind = 'trip';
    var title = 'טיול שנתי';
    var due = '2026-09-14';
    _sheet((ctx, setSheet) {
      final f = _PrData.fam(famId);
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ForgeContactTile(fields: ['בקשת-אישור', _PrData.famLabel(f)]),
        DsEnumField(label: 'משפחה', options: [for (final x in _PrData.scope(_role)) _PrData.famLabel(x)], value: _PrData.famLabel(f), onChanged: (v) => setSheet(() => famId = _PrData.scope(_role).firstWhere((x) => _PrData.famLabel(x) == v)['id'] as String)),
        DsEnumField(label: 'סוג', options: _PrData.consentKind.values.toList(), value: _PrData.consentKind[kind]!, onChanged: (v) => setSheet(() => kind = _PrData.consentKind.entries.firstWhere((e) => e.value == v).key)),
        DsField(label: 'מה', hint: 'למשל: טיול שנתי · גליל', value: title, onChanged: (v) => setSheet(() => title = v)),
        DsDateField(label: 'עד', value: due, onChanged: (v) => setSheet(() => due = v)),
        _gap(8),
        GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {
          _PrData.send(_actor, f, _PrData.parentKeys(f).first, _PrData.render('sc.consent', {'what': title, 'due': due, 'first': '${(f['kids'] as List).first['first']}'}), crisis: _crisis);
          _PrData.audit(_actor, 'בקשת-אישור', famId, note: '$title עד $due');
          Navigator.pop(ctx); setState(() {});
        }, child: ForgeSoftButton(fields: ['📤 שלח בקשה'])),
        const ForgeSectionPill(fields: ['האישור עצמו נרשם כשההורה מחזיר (סמן-התקבל) — חתימה-דיגיטלית = מקום-שמור', '']),
      ]);
    });
  }

  // 📨 פתיחת-פנייה
  void _openInquiry(Map<String, dynamic> f) {
    var title = '';
    var pri = 'רגילה';
    var sensitive = false;
    _sheet((ctx, setSheet) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ForgeContactTile(fields: ['פנייה חדשה', _PrData.famLabel(f)]),
      DsField(label: 'נושא', hint: 'תוכן הפנייה…', value: title, onChanged: (v) => setSheet(() => title = v)),
      DsEnumField(label: 'עדיפות', options: const ['דחופה', 'רגילה', 'נמוכה'], value: pri, onChanged: (v) => setSheet(() => pri = v)),
      PremiumToggle(value: sensitive, label: '🔒 פנייה רגישה (יועץ/ת · הנהלה בלבד)', onChanged: (v) => setSheet(() => sensitive = v)),
      _gap(8),
      GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {
        if (title.trim().isEmpty) return;
        _PrData.extraInquiries.add({'id': 'q-${_PrData.log.length + 100}', 'famId': f['id'], 'title': title.trim(), 'pri': pri == 'דחופה' ? 1 : pri == 'רגילה' ? 2 : 3, 'createdAt': _PrData.nowIso(), 'due': _PrData.today, 'doneAt': '', 'answeredAt': '', 'assignee': sensitive ? 'counselor' : _actor, 'sensitive': sensitive, 'ref': {'kind': 'family', 'id': f['id']}});
        _PrData.audit(_actor, 'פתיחת-פנייה', f['id'] as String, note: title.trim());
        Navigator.pop(ctx); setState(() {});
      }, child: ForgeSoftButton(fields: ['➕ פתח'])),
    ]));
  }

  // 📅 קביעת-פגישה ⇒ תזכורת נשלחת מיד (פגישה⇒תזכורת+סיכום)
  void _openMeeting(Map<String, dynamic>? f0) {
    var famId = f0?['id'] as String? ?? _PrData.scope(_role).first['id'] as String;
    var date = '2026-09-09';
    var time = '17:00';
    var title = 'שיחת-הורים';
    _sheet((ctx, setSheet) {
      final f = _PrData.fam(famId);
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ForgeContactTile(fields: ['קביעת-פגישה', _PrData.famLabel(f)]),
        DsEnumField(label: 'משפחה', options: [for (final x in _PrData.scope(_role)) _PrData.famLabel(x)], value: _PrData.famLabel(f), onChanged: (v) => setSheet(() => famId = _PrData.scope(_role).firstWhere((x) => _PrData.famLabel(x) == v)['id'] as String)),
        DsDateField(label: 'תאריך', value: date, onChanged: (v) => setSheet(() => date = v)),
        DsField(label: 'שעה', hint: 'HH:MM', value: time, onChanged: (v) => setSheet(() => time = v)),
        DsField(label: 'נושא', hint: 'נושא הפגישה', value: title, onChanged: (v) => setSheet(() => title = v)),
        _gap(8),
        GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {
          _PrData.extraMeetings.add({'id': 'm-${_PrData.log.length + 100}', 'famId': famId, 'kind': 'meeting', 'date': date, 'time': time, 'done': false, 'title': title, 'summarySent': false});
          _PrData.send(_actor, f, _PrData.parentKeys(f).first, _PrData.render('sc.meeting', {'date': date, 'time': time, 'what': title}), crisis: _crisis);
          _PrData.audit(_actor, 'קביעת-פגישה', famId, note: '$title · $date $time');
          Navigator.pop(ctx); setState(() {});
        }, child: ForgeSoftButton(fields: ['📅 קבע + שלח תזכורת'])),
      ]);
    });
  }

  // 📞 עדכון-קשר: כותב לשקע-הזהות המוזרק (state בזמן-ריצה · לא לקוד) — phoneIssue מאבחן מיד
  void _openContact(Map<String, dynamic> f) {
    final id = f['id'] as String;
    final draft = {for (final pk in _PrData.parentKeys(f)) pk: _PrData.phoneOf(id, pk) ?? ''};
    var email = _PrData.identity[id]?['email'] ?? '';
    _sheet((ctx, setSheet) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ForgeContactTile(fields: ['עדכון-קשר', '${_PrData.famLabel(f)} · זהות = שקע-הצבה (חוק-6)']),
      for (final pk in _PrData.parentKeys(f)) ...[
        DsField(label: 'טלפון ${_PrData.parent(f, pk)['role']}', hint: '05x-xxxxxxx', value: draft[pk]!, onChanged: (v) => setSheet(() => draft[pk] = v)),
        if (draft[pk]!.trim().isNotEmpty && phoneIssue(draft[pk], PHONE_ISSUE_T.cast<String, dynamic>()) != null) ForgeSectionPill(fields: [phoneIssue(draft[pk], PHONE_ISSUE_T.cast<String, dynamic>())!, '']),
        if (draft[pk]!.trim().isNotEmpty && phoneIssue(draft[pk], PHONE_ISSUE_T.cast<String, dynamic>()) == null) ForgeIntelPill(fields: ['✅ ${formatIsraeliPhone(draft[pk])} · wa: ${waDigits(draft[pk]) ?? 'לא-שליח'}']),
      ],
      DsField(label: 'מייל', hint: 'כתובת מייל', value: email, onChanged: (v) => setSheet(() => email = v)),
      _gap(8),
      GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {
        final cur = Map<String, String>.from(_PrData.identity[id] ?? {});
        for (final e in draft.entries) { cur['${e.key}Phone'] = e.value.trim(); }
        cur['email'] = email.trim();
        _PrData.identity[id] = cur;
        _PrData.audit(_actor, 'עדכון-קשר', id, note: [for (final pk in draft.keys) '$pk: ${_PrData.contactState(id, pk)}'].join(' · '));
        Navigator.pop(ctx); setState(() {});
      }, child: ForgeSoftButton(fields: ['💾 שמור'])),
    ]));
  }

  // 🖨 מכתב: renderTemplate('sc.letter') ⇒ תצוגה-להדפסה (SelectableText) + רישום-אודיט
  void _openLetter(Map<String, dynamic> f) {
    final txt = _PrData.render('sc.letter', {'first': _PrData.kidsLabel(f), 'what': 'עדכון להורים', 'note': _PrData.weeklyDigest(f).join('\n')});
    _PrData.audit(_actor, 'הדפסת-מכתב', f['id'] as String);
    _sheet((ctx, setSheet) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ForgeContactTile(fields: ['מכתב להורים', _PrData.famLabel(f)]),
      _gap(8),
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF0C0D1E), borderRadius: BorderRadius.circular(10)), child: SelectableText(txt, style: const TextStyle(color: _ink, fontSize: 13, height: 1.6))),
    ]));
  }

  // ⬇ ייצוא-לוג: toCsv⊕csvEscape⊕exportAllowed — תצוגה (הורדה חסומה בסנדבוקס)
  void _openExport() {
    final allowed = _PrData.exportOk(_role);
    final csv = allowed ? _PrData.csvOfLog() : '';
    _PrData.audit(_actor, 'ייצוא-לוג', '*', status: allowed ? 'ok' : 'blocked');
    _sheet((ctx, setSheet) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ForgeContactTile(fields: ['ייצוא-לוג CSV', '${_PrData.log.length} רשומות · ${_PrData._csvHeader.length} עמודות']),
      _gap(8),
      if (!allowed) const ForgeSectionPill(fields: ['ייצוא חסום (שער-הרשאות)', ''])
      else Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF0C0D1E), borderRadius: BorderRadius.circular(10)), child: SelectableText(csv, textDirection: TextDirection.ltr, style: const TextStyle(color: _ink, fontSize: 12, height: 1.6))),
    ]));
  }

  // ═══ פורטל-הורה (תפקיד הורה): ילדו בלבד · צפייה · אישור · פנייה · תשלום-שמור · הסדר-ראייה גובר ═══
  Widget _portalScreen() {
    final r = _PrData.roleDefs[_role];
    final f = _PrData.fam(r['family'] as String);
    final pk = r['parent'] as String;
    final id = f['id'] as String;
    final views = _PrData.visibleViews(f, pk);
    final ms = _PrData.msgsOf(id);
    final cs = _PrData.consentsOf(id);
    return DsScaffold(
      title: 'הפורטל שלי', subtitle: '${_PrData.famLabel(f)} · ${_PrData.parent(f, pk)['role']} · ${_PrData.nameOf(id, pk) ?? '🔒 מוזרק-בהצבה'}', icon: '👁',
      children: [
        Align(alignment: Alignment.centerRight, child: ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in [for (final x in _PrData.roleDefs) x['label'] as String]) [s]], selected: {_role}, onSelect: (i) => setState(() => _role = i))),
        _gap(10),
        if (_PrData.isBlocked(f, pk)) const ForgeSectionPill(fields: ['הגישה חסומה — פנה/י למזכירות', ''])
        else ...[
          if ((f['custody'] as Map?)?['restricted'] == true) ForgeSectionPill(fields: ['לפי הסדר-הראייה מוצג: ${views.map((v) => _PrData.childViewLabel[v]).join(' · ')}', '']),
          _gap(8),
          ForgeTitledSection(fields: ['הילד/ה שלי', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[
            for (final k in f['kids'] as List)
              Row(children: [
                Expanded(child: ForgeStatPlain(fields: ['${k['cls']}', '${(k as Map)['first']}'])),
                if (views.contains('attendance')) Expanded(child: ForgeStatPlain(fields: ['📆 חיסורים/30י', '${_PrData.childFeed[k['sid']]?['absences30'] ?? '—'}'])),
                if (views.contains('grades')) Expanded(child: ForgeStatPlain(fields: ['📊 ממוצע', '${_PrData.childFeed[k['sid']]?['avg'] ?? '—'}'])),
                if (views.contains('fees')) Expanded(child: ForgeStatPlain(fields: ['💳 חוב', _PrData.feesFeed[id] == null ? '✓' : '₪${_PrData.feesFeed[id]}'])),
              ]),
            if (views.contains('fees') && _PrData.feesFeed[id] != null) const ForgeSectionPill(fields: ['תשלום-מהפורטל = מקום-שמור (מאיר כשתחובר סליקה)', '']),
          ]])),
          ForgeTitledSection(fields: ['הודעות מבית-הספר · ${ms.length}', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[
            if (ms.isEmpty) const ForgeSearchEmptyState(fields: ['אין הודעות', '']),
            for (final m in ms) Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: PureBubble(text: '${m['text']}', time: '${supportMsgTime('${m['at']}')}', kind: m['from'] == 'user' ? PureBubbleKind.outgoing : PureBubbleKind.incoming)),
            _wrap([
              GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() { final t = _PrData.thread(id); if (t != null) _PrData.threadAdj[id] = {...t, 'unreadUser': 0}; }), child: ForgeSoftButton(fields: ['👁 סמן: קראתי'])),
              GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _PrData.receive(id, pk, 'פנייה מההורה דרך הפורטל', _PrData.smartChannel(f, pk))), child: ForgeSoftButton(fields: ['📨 שלח פנייה'])),
            ]),
          ]])),
          ForgeTitledSection(fields: ['אישורים · ${cs.length}', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[
            if (cs.isEmpty) const ForgeSearchEmptyState(fields: ['אין בקשות', '']),
            for (final c in cs)
              Row(children: [
                Expanded(child: ForgeContactTile(fields: ['${c['title']}', '${_PrData.consentKind[c['kind']]} · עד ${c['due']} · ${_PrData.consentLabel[_PrData.consentState(c)]}'])),
                if (_PrData.consentState(c) == 'pending' || _PrData.consentState(c) == 'expired') Flexible(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() { _PrData.consentStatus[c['id'] as String] = 'received'; _PrData.audit('parent:$pk', 'אישור-מהפורטל', id, note: '${c['title']}'); }), child: ForgeSoftButton(fields: ['✅ מאשר/ת']))),
              ]),
            const ForgeSectionPill(fields: ['חתימה-דיגיטלית · פורטל-מזוהה · צ׳אט-חי — מקום-שמור', '']),
          ]])),
        ],
      ],
    );
  }
}
