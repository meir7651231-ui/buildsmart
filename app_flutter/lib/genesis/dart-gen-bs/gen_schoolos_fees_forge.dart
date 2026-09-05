// 🎨 schoolos_fees.dart בעור-forge (GENMAX·G12d) — מחולל דטרמיניסטי: skin-golden.mjs · הזהב לא נגע (טעינה-לצד, חוק-7) · עור: kpi=ForgeStatPlain · navTile=ForgeHubTile · stat=ForgeStatPlain · hero=ForgeStatPlain · button=ForgeSoftButton · statusChip=ForgeStatusChip · banner=ForgeSectionPill · emptyState=ForgeSearchEmptyState · mediaRow=ForgeContactTile · section=ForgeTitledSection · frame=ForgeStripPanelFrame · segmented=ForgeSegmentedPillToggleSelection · chip=ForgeFacetChip · meter=ForgeLinearProgressStatus · glass=ForgeGlassCard · timeline=ForgeNotifRow · field=ForgeDsField · enumField=ForgeDsEnumField · numberField=ForgeDsNumberField · dateField=ForgeDsDateFieldInput · search=ForgeDsSearch · pageHeader=ForgeCenteredPageHeader · table=ForgeDataGrid · bars=ForgeBarChart
//   החלפות: stat×0 · hero×2 · chipRow×1 · chip×3 · statRow×31 · button×25 · statusChip×15 · banner×23 · emptyState×14 · mediaRow×9 · section×9 · segmented×3 · meter×3 · frame×8 · timeline×10 · field×2 · enumField×7 · numberField×2 · dateField×2 · search×1 · pageHeader×1 · table×1 · bars×4 · BareStat ב-Row נשאר DS (רצועת-4) · צבעי-מצב-DS לא מועברים · חיפוש/טבלאות/פילטרים = DS (אטומי-forge של קלט הם ציור, לא שדה)
// 💰 SchoolOS · מסך-גבייה ותשלומים (FEES) — נבנה בדרך (THE-WAY · הכרעה 23-ב/ג/ד) לפי SPEC-FEES-FULL-2026-09-04.
// מטרה: "שכל שקל שמגיע ייגבה בזמן, ששום משפחה לא תיפול בין הכיסאות, ושהמנהל/ת יידע בדיוק
//         מה נגבה, מה חסר ומה בסיכון — בלי לבייש איש."
// פעולות-יסוד (צעד 2): איתור · הערכת-מצב (חיוב−תשלום=יתרה · ותק) · זיהוי-חריגה (ותיק · הו״ק-נכשלה ·
//   הסדר-בפיגור · כפול) · הכרעה (סיכון-מאוחד: ותק ⊕ דפוס-תשלום-RFM ⊕ מגמה ⇒ הפעולה-הנכונה) · ביצוע · אימות.
// ⚠️ גבול-כספי חרוט: המסך רושם חיובים/תשלומים ומזכיר — אינו מנפיק קבלות-מס ואינו סולק. קבלה/סליקה/קישור =
//   שער-חיצוני = מקום-שמור (חוק-7). אין המצאת-מספרי-קבלה. אין Date.now במנוע (today מוזרק).
// חלקיק-תובנה = כמה אטומים (תצוגה⊕לוגיקה) · עובדה = אטום-יחיד · מזייפים (StatBlock/DataGrid/…) לא נוגעים.
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_search.dart'; // איתור: חיפוש-מבוקר (value+onChanged)
import '../dart-ui-bs/ds/ds_table.dart'; // טבלה-אמיתית מונחית-חוזה (labels+rows) — לא DataGrid
import '../dart-ui-bs/ds/ds_bars.dart'; // פירוק-לפי-סוג: פסים-אמיתיים (labels+values) — לא bar_chart
import '../dart-ui-bs/ds/ds_enum_field.dart'; // בורר-ערך-מקבוצה (פילטרים: כיתה/סוג/אמצעי/שנה · טפסים)
import '../dart-ui-bs/ds/ds_number_field.dart'; // שדה-סכום (טופס חיוב/תשלום)
import '../dart-ui-bs/ds/ds_date_field.dart'; // שדה-תאריך (טופס)
import '../dart-ui-bs/ds/ds_field.dart'; // שדה-טקסט (הערה/סיבת-ביטול)
import '../dart-ui-bs/bare_stat.dart'; // עובדה-מספרית (ערך+תווית, צבע-מוזרק) — KPI
import '../dart-ui-bs/premium/surfaces/gradient_card.dart';
import '../dart-ui-bs/premium/surfaces/glass_card.dart'; // מיכל-פאנל-משפחה
import '../dart-ui-bs/premium/surfaces/stat_hero.dart'; // המדד-הבולט (יתרה-פתוחה)
import '../dart-ui-bs/premium/lists/media_row.dart'; // זהות (glyph+title+subtitle)
import '../dart-ui-bs/premium/lists/stat_row.dart'; // יחס שולם/חיוב (בר-מילוי)
import '../dart-ui-bs/premium/lists/timeline_item.dart'; // ציר-תשלומים/חיובים/אודיט — לא timeline_flow
import '../dart-ui-bs/premium/dataviz/neon_bars.dart'; // השוואה חיוב·שולם·יתרה (פסים-אמיתיים)
import '../dart-ui-bs/premium/dataviz/trend_stat.dart'; // מגמת-גבייה חודשית (ערך+delta%)
import '../dart-ui-bs/premium/actions/segmented_switch.dart'; // בורר-מבוקר (תפקיד · מבטים · טאבים)
import '../dart-ui-bs/premium/actions/soft_button.dart'; // פעולה
import '../dart-ui-bs/premium/feedback/alert_banner.dart'; // התראה/מצב/הכרעה
import '../dart-ui-bs/premium/feedback/status_chip.dart'; // עובדה-שבב
import '../dart-ui-bs/premium/feedback/status_dot.dart'; // נקודת-מצב (הו״ק)
import '../dart-ui-bs/premium/feedback/empty_state.dart'; // אין-תוצאות/אין-חיובים
import '../dart-ui-bs/screens__manager_dashboard_screen/filter_chip_pill.dart'; // צ׳יפ-סינון מבוקר
// ─── שכבת-הלוגיקה (§21) — מנועי-מדף, אפס inline ───
import '../dart-maor/shekel.dart'; // ₪-פורמט
import '../dart-maor/pay-bal.dart'; // יתרה = totalDue + carryBalance − שולם (≥0)
import '../dart-maor/pay-credit.dart'; // זכות = שולם-יתר
import '../dart-maor/enrollment-paid-status.dart'; // paid/partial/unpaid
import '../dart-maor/max-discount-pct.dart'; // מדיניות-הנחה: הגבוה-מנצח (אחים/סוציו/מלגה)
import '../dart-maor/effective-price.dart'; // מחיר-אחרי-הנחה (עיגול, ≥0)
import '../dart-maor/intel-day-diff.dart'; // ותק-בימים (dayDiff — today מוזרק)
import '../dart-maor/hok-effectively-active.dart'; // הו״ק פעילה-אפקטיבית (kevaId ⇒ סליקה-חיה תוך 2 חודשים)
import '../dart-maor/hok-recorded-this-month.dart'; // הו״ק נרשמה-החודש
import '../dart-maor/hok-due.dart'; // רשימת-הו״ק-לרישום-חודשי (ממוינת לפי יום-חיוב)
import '../dart-maor/hok-monthly-total.dart'; // צפוי-החודש מהו״ק
import '../dart-maor/hok-method-label.dart'; // תווית-אמצעי-הו״ק
import '../dart-maor/hok-cat.dart'; // קטגוריית-הו״ק (קבוע-מערכת)
import '../dart-maor/sup-score.dart'; // דפוס-תשלום RFM (טריות·תדירות·סכום) 130–1000
import '../dart-maor/sup-last.dart'; // תשלום-אחרון
import '../dart-maor/sup-count.dart'; // מספר-תשלומים
import '../dart-maor/sup-ils.dart'; // Σ₪ ששולם
import '../dart-maor/sup-usd.dart'; // Σ$ (0 כאן — שקע-האטום דורש)
import '../dart-maor/sup-total-ils.dart'; // שווי-כולל ₪
import '../dart-maor/tier-of.dart'; // דרגת-אמינות לפי-ניקוד (titan/lion/pale/red)
import '../dart-maor/intel-trend-from-scan.dart'; // מגמה מחודשים (dir/pct)
import '../dart-maor/segula-reminders.dart'; // תזכורת-מדורגת: תאריך-התחלה+דילוגים ⇒ לוח-תזכורות
import '../dart-maor/wa-payment-text.dart'; // נוסח-תזכורת (תבנית-מוזרקת, סכום מעוצב)
import '../dart-maor/overdue-contact-task-drafts.dart'; // משימות-מעקב למי-שעבר-מועד
import '../dart-maor/charge-dedup-key.dart'; // מפתח-דדופ לחיוב (חיוב-כפול-חשוד)
import '../dart-maor/strong-match-for-charge.dart'; // התאמת-תשלום-נכנס למשפחה (phone/email/idNum)
import '../dart-maor/pay-link.dart'; // קישור-תשלום (שער-חיצוני · מקום-שמור: payUrl ריק ⇒ null)
import '../dart-maor/date-in-range.dart'; // סינון חודש/שנה
import '../dart-maor/month-key.dart'; // YYYY-MM
import '../dart-maor/donation-years.dart'; // שנות-תשלום קיימות
import '../dart-maor/fmt-date.dart'; // dd/mm/yyyy
import '../dart-maor/count-by.dart'; // קיבוץ-מונה
import '../dart-maor/grand-total.dart'; // Σ-לפי-מפתח
import '../dart-maor/smart-filter.dart'; // איתור: סינון+מיון-לפי-ציון
import '../dart-maor/smart-score.dart'; // איתור: ניקוד רב-מילתי AND
import '../dart-maor/norm-search.dart'; // איתור: נרמול-עברי
import '../dart-maor/finder-matches.dart'; // חריגה: סינון-רב-צירי AND
import '../dart-maor/to-csv.dart'; // ייצוא
import '../dart-maor/csv-escape.dart'; // ייצוא: חסימת-הזרקה
import '../dart-maor/export-allowed.dart'; // ייצוא: שער
import '../dart-maor/role-of.dart'; // הרשאות: תפקיד-לפי-זהות-מוזרקת
import '../dart-maor/can-granted-action.dart'; // הרשאות: גידור-פעולה
// ─── שכבת-הדאטה (§21) — תאומי-דאטה של המנועים (מונחים · שקעי-T) ───
import '../dart-data-maor/hok-effectively-active-sockets.dart' as skHokActive;
import '../dart-data-maor/hok-recorded-this-month-sockets.dart' as skHokRec;
import '../dart-data-maor/hok-method-label-terms.dart' as tdHokMethod;
import '../dart-data-maor/tier-of-terms.dart' as tdTier;
import '../dart-data-maor/overdue-contact-task-drafts-sockets.dart' as skOverdue;
import '../dart-forge-bs/selection/selection.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/card/card.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/status/status.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/feedback/feedback.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/header/header.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/list/list.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/input/input.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/spatial/spatial.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/dataviz/dataviz.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

const _acc = DsTokens.accent;
// פיגמנטים מוזרקים לאטומים-טהורים (חוק-6: צבע=הצבה)
const _danger = Color(0xFFF43F5E);
const _ok = Color(0xFF34D399);
const _muted = Color(0xFF9AA0BE);
const _ink = Color(0xFFF2F3FF);
const _warning = Color(0xFFF59E0B);

// ═══════════════════════════════════════════════════════════════════════════════════════
// 🧮 _FeesData — לוגיקה-טהורה + חוזה-דאטה (אפס-DOM). מקורות-אמת (§20-ג · אפס-זיוף):
//   משפחה   → maor Family (name·father·mother·phone·email·discount·status·members) · Member (first·grade·idNum)
//   חיוב    → maor PlannedCharge (id·date·amount·cur·method·cat·installmentOf·cancelledAt·note) + Enrollment.memberId/dueDate
//   תשלום   → maor Payment (rid·date·amount·method) · Enrollment.totalDue/carryBalance/paidFull ⇒ payBal/payCredit
//   הו״ק    → maor Hok (amount·cur·day·method·active·startedAt·kevaId) + Supporter.hist (d·a·c·clearer) ⇒ hokEffectivelyActive
//   תזכורת  → Supporter.calls (CallEntry: at·outcome) + Supporter.nextDate/nextNote
//   הנחה    → קריטריוני-הנחה {id·discountPct} (max-discount-pct.contract) · Family.discount
//   ⛔ ללא-מקור-אמת ⇒ מקום-שמור, לא זיוף: receiptNo · clearingRef · invoiceNo · payUrl (שער-חיצוני)
// ═══════════════════════════════════════════════════════════════════════════════════════
class _FeesData {
  static const today = '2026-09-04'; // תאריך-הזרקה דטרמיניסטי (אין Date.now במנוע)
  static const year = '2026';
  static const orgName = 'תיכון עתיד';
  static const oldDebtDays = 90; // סף חוב-ותיק (המפרט: >90 יום)
  static const gentleDays = 14; // סף תזכורת-ראשונה (עדינה)

  // ─── מדיניות-הנחה (מנוע max-discount-pct: הגבוה-מנצח, לא מצטבר · צורת-הקלט {id,discountPct}) ───
  static const criteria = <Map<String, dynamic>>[
    {'id': 'sib2', 'discountPct': 10, 'label': 'אח/ות שני/ה'},
    {'id': 'sib3', 'discountPct': 20, 'label': 'שלושה אחים+'},
    {'id': 'socio', 'discountPct': 50, 'label': 'סוציו-אקונומי'},
    {'id': 'full', 'discountPct': 100, 'label': 'מלגה מלאה'},
  ];
  static const chargeTypes = ['שכר-לימוד', 'חוג', 'טיול', 'ציוד'];
  static const arrangementType = 'הסדר'; // תשלומי-פריסה — נגזרים מיתרה-נטו ⇒ לא-ברי-הנחה (discountableTypes לא כולל)
  static const discountableTypes = {'שכר-לימוד'}; // ההנחה חלה על שכ״ל בלבד (מדיניות)
  static const payMethodsSchool = ['הו״ק', 'אשראי', 'מזומן', 'העברה']; // המפרט: אמצעי (הו״ק/אשראי/מזומן/העברה)

  // ─── דאטה-בסיס (const · מקור-האמת) — 8 משפחות ריאליסטיות, רק שדות-עם-מקור ───
  static const families = <Map<String, dynamic>>[
    {
      'id': 'f1', 'name': 'משפחת כהן', 'payer': 'דוד כהן', 'phone': '050-1111111', 'email': 'cohen@family', 'idNum': '012345678',
      'members': [{'first': 'נועה', 'grade': 'י\'-3'}, {'first': 'איתי', 'grade': 'ח\'-1'}],
      'charges': [
        {'id': 'c1', 'date': '2026-08-20', 'amount': 4200, 'cur': '₪', 'cat': 'שכר-לימוד', 'method': '', 'memberId': 'נועה'},
        {'id': 'c2', 'date': '2026-08-20', 'amount': 4200, 'cur': '₪', 'cat': 'שכר-לימוד', 'method': '', 'memberId': 'איתי'},
        {'id': 'c3', 'date': '2026-09-01', 'amount': 350, 'cur': '₪', 'cat': 'טיול', 'method': '', 'memberId': 'נועה', 'note': 'טיול שנתי י\''},
      ],
      'payments': [
        {'rid': 'p1', 'date': '2026-08-05', 'amount': 700, 'method': 'הו״ק'},
        {'rid': 'p2', 'date': '2026-09-03', 'amount': 700, 'method': 'הו״ק'},
      ],
      'hok': {'amount': 700, 'cur': '₪', 'day': 5, 'method': 'bank', 'active': true, 'startedAt': '2025-09-05'},
      'criteria': ['sib2'],
      'calls': <Map<String, dynamic>>[],
      'carryBalance': 0,
    },
    {
      'id': 'f2', 'name': 'משפחת לוי', 'payer': 'רחל לוי', 'phone': '052-2222222', 'email': 'levi@family', 'idNum': '023456789',
      'members': [{'first': 'יונתן', 'grade': 'ט\'-2'}],
      'charges': [
        {'id': 'c4', 'date': '2026-05-10', 'amount': 4200, 'cur': '₪', 'cat': 'שכר-לימוד', 'method': '', 'memberId': 'יונתן'},
        {'id': 'c5', 'date': '2026-06-01', 'amount': 480, 'cur': '₪', 'cat': 'חוג', 'method': '', 'memberId': 'יונתן', 'note': 'רובוטיקה'},
      ],
      'payments': [
        {'rid': 'p3', 'date': '2026-05-20', 'amount': 1000, 'method': 'אשראי'},
      ],
      'hok': {'amount': 350, 'cur': '₪', 'day': 10, 'method': 'card', 'active': true, 'startedAt': '2026-01-10', 'kevaId': 'kv-77'},
      'hist': [
        {'d': '2026-04-10', 'a': 350, 'c': '₪', 'clearer': 'נדרים', 'kevaId': 'kv-77'},
        {'d': '2026-05-10', 'a': 350, 'c': '₪', 'clearer': 'נדרים', 'kevaId': 'kv-77'},
      ],
      'criteria': <String>[],
      'calls': [
        {'at': '2026-07-01', 'outcome': 'reminder', 'grade': 'עדינה'},
        {'at': '2026-08-01', 'outcome': 'reminder', 'grade': 'רגילה'},
        {'at': '2026-08-25', 'outcome': 'reminder', 'grade': 'הנהלה'},
      ],
      'nextDate': '2026-09-02', 'nextNote': 'שיחת-הסדר עם רחל',
      'carryBalance': 600,
    },
    {
      'id': 'f3', 'name': 'משפחת מזרחי', 'payer': 'יוסי מזרחי', 'phone': '054-3333333', 'email': 'mizrahi@family', 'idNum': '034567890',
      'members': [{'first': 'שירה', 'grade': 'יא\'-1'}, {'first': 'עומר', 'grade': 'ט\'-1'}, {'first': 'טל', 'grade': 'ז\'-2'}],
      'charges': [
        {'id': 'c6', 'date': '2026-08-20', 'amount': 4200, 'cur': '₪', 'cat': 'שכר-לימוד', 'method': '', 'memberId': 'שירה'},
        {'id': 'c7', 'date': '2026-08-20', 'amount': 4200, 'cur': '₪', 'cat': 'שכר-לימוד', 'method': '', 'memberId': 'עומר'},
        {'id': 'c8', 'date': '2026-08-20', 'amount': 4200, 'cur': '₪', 'cat': 'שכר-לימוד', 'method': '', 'memberId': 'טל'},
        {'id': 'c9', 'date': '2026-09-01', 'amount': 220, 'cur': '₪', 'cat': 'ציוד', 'method': '', 'memberId': 'טל', 'note': 'ערכת מעבדה'},
      ],
      'payments': [
        {'rid': 'p4', 'date': '2026-08-22', 'amount': 3000, 'method': 'העברה'},
      ],
      'criteria': ['sib3'],
      'calls': <Map<String, dynamic>>[],
      'carryBalance': 0,
    },
    {
      'id': 'f4', 'name': 'משפחת אברהם', 'payer': 'מרים אברהם', 'phone': '053-4444444', 'email': 'avraham@family', 'idNum': '045678901',
      'members': [{'first': 'אליה', 'grade': 'י\'-1'}],
      'charges': [
        {'id': 'c10', 'date': '2026-08-20', 'amount': 4200, 'cur': '₪', 'cat': 'שכר-לימוד', 'method': '', 'memberId': 'אליה'},
      ],
      'payments': <Map<String, dynamic>>[],
      'criteria': ['full'],
      'calls': <Map<String, dynamic>>[],
      'carryBalance': 0,
    },
    {
      'id': 'f5', 'name': 'משפחת פרץ', 'payer': 'אבי פרץ', 'phone': '058-5555555', 'email': 'peretz@family', 'idNum': '056789012',
      'members': [{'first': 'ליאור', 'grade': 'ח\'-2'}],
      'charges': [
        {'id': 'c12', 'date': '2026-08-20', 'amount': 1400, 'cur': '₪', 'cat': 'הסדר', 'method': '', 'memberId': 'ליאור', 'installmentOf': 'arr-1', 'note': 'הסדר 3/1'},
        {'id': 'c13', 'date': '2026-09-20', 'amount': 1400, 'cur': '₪', 'cat': 'הסדר', 'method': '', 'memberId': 'ליאור', 'installmentOf': 'arr-1', 'note': 'הסדר 3/2'},
        {'id': 'c14', 'date': '2026-10-20', 'amount': 1400, 'cur': '₪', 'cat': 'הסדר', 'method': '', 'memberId': 'ליאור', 'installmentOf': 'arr-1', 'note': 'הסדר 3/3'},
        {'id': 'c15', 'date': '2026-08-20', 'amount': 4200, 'cur': '₪', 'cat': 'שכר-לימוד', 'method': '', 'memberId': 'ליאור', 'cancelledAt': '2026-08-21', 'note': 'הוחלף בהסדר-פריסה'},
      ],
      'payments': <Map<String, dynamic>>[],
      'criteria': <String>[],
      'calls': [
        {'at': '2026-09-03', 'outcome': 'reminder', 'grade': 'עדינה'},
      ],
      'carryBalance': 0,
    },
    {
      'id': 'f6', 'name': 'משפחת שמעוני', 'payer': 'גלית שמעוני', 'phone': '050-6666666', 'email': 'shimoni@family', 'idNum': '067890123',
      'members': [{'first': 'רון', 'grade': 'י\'-1'}],
      'charges': [
        {'id': 'c16', 'date': '2026-08-20', 'amount': 4200, 'cur': '₪', 'cat': 'שכר-לימוד', 'method': '', 'memberId': 'רון'},
        {'id': 'c17', 'date': '2026-09-01', 'amount': 350, 'cur': '₪', 'cat': 'טיול', 'method': '', 'memberId': 'רון', 'note': 'טיול שנתי י\''},
      ],
      'payments': [
        {'rid': 'p5', 'date': '2026-08-21', 'amount': 4200, 'method': 'אשראי'},
        {'rid': 'p6', 'date': '2026-09-02', 'amount': 350, 'method': 'אשראי'},
      ],
      'criteria': <String>[],
      'calls': <Map<String, dynamic>>[],
      'carryBalance': 0,
    },
    {
      'id': 'f7', 'name': 'משפחת ביטון', 'payer': 'שלומי ביטון', 'phone': '052-7777777', 'email': 'biton@family', 'idNum': '078901234',
      'members': [{'first': 'מאיה', 'grade': 'י\'-2'}, {'first': 'עידו', 'grade': 'ז\'-1'}],
      'charges': [
        {'id': 'c18', 'date': '2026-08-20', 'amount': 4200, 'cur': '₪', 'cat': 'שכר-לימוד', 'method': '', 'memberId': 'מאיה'},
        {'id': 'c19', 'date': '2026-08-20', 'amount': 4200, 'cur': '₪', 'cat': 'שכר-לימוד', 'method': '', 'memberId': 'עידו'},
        {'id': 'c20', 'date': '2026-09-01', 'amount': 480, 'cur': '₪', 'cat': 'חוג', 'method': '', 'memberId': 'עידו', 'note': 'כדורסל'},
        {'id': 'c21', 'date': '2026-09-01', 'amount': 480, 'cur': '₪', 'cat': 'חוג', 'method': '', 'memberId': 'עידו', 'note': 'כדורסל'},
      ],
      'payments': [
        {'rid': 'p7', 'date': '2026-08-25', 'amount': 5000, 'method': 'העברה'},
      ],
      'hok': {'amount': 600, 'cur': '₪', 'day': 15, 'method': 'bank', 'active': true, 'startedAt': '2026-09-01'},
      'criteria': ['sib2', 'socio'],
      'calls': <Map<String, dynamic>>[],
      'carryBalance': 0,
    },
    {
      'id': 'f8', 'name': 'משפחת נחום', 'payer': 'הדס נחום', 'phone': '054-8888888', 'email': 'nahum@family', 'idNum': '089012345',
      'members': [{'first': 'הדר', 'grade': 'ח\'-2'}],
      'charges': <Map<String, dynamic>>[],
      'payments': <Map<String, dynamic>>[],
      'criteria': <String>[],
      'calls': <Map<String, dynamic>>[],
      'carryBalance': 0,
    },
  ];

  // ─── פנקס-פעולות (state · חוק-1: מצב=חיווט): הבסיס const, הפעולות רושמות תוספות/דגלים + אודיט ───
  static final Map<String, List<Map<String, dynamic>>> extraCharges = {};
  static final Map<String, List<Map<String, dynamic>>> extraPayments = {};
  static final Map<String, List<Map<String, dynamic>>> extraCalls = {};
  static final Set<String> cancelledIds = {}; // ביטול-חיוב (סיבה ב-audit)
  static final Map<String, String> cancelReason = {};
  static final Map<String, List<String>> extraCriteria = {}; // הענקת-הנחה/מלגה
  static final Map<String, bool> hokOverride = {}; // הפעל/הפסק-הו״ק
  static final Set<String> writtenOff = {}; // סומן-כחוב-אבוד (הנהלה)
  static final List<Map<String, dynamic>> audit = []; // יומן-אודיט (מי·מה·מתי — role מוזרק)
  static int _seq = 100;
  static String _nid(String p) => '$p${_seq++}';

  // איפוס-פנקס (רתמת-בדיקה · דטרמיניזם): מחזיר את המצב לבסיס-ה-const — אפס-תלות בסדר-הבדיקות
  static void reset() {
    extraCharges.clear(); extraPayments.clear(); extraCalls.clear(); cancelledIds.clear(); cancelReason.clear();
    extraCriteria.clear(); hokOverride.clear(); writtenOff.clear(); audit.clear(); _seq = 100;
  }
  static void _log(String role, String fid, String what) =>
      audit.insert(0, {'date': today, 'role': role, 'family': fid, 'what': what});

  // ─── גישה מאוחדת: בסיס + תוספות ───
  static List<Map<String, dynamic>> chargesOf(Map<String, dynamic> f) =>
      [...(f['charges'] as List).cast<Map<String, dynamic>>(), ...(extraCharges[f['id']] ?? const [])];
  static List<Map<String, dynamic>> liveCharges(Map<String, dynamic> f) =>
      chargesOf(f).where((c) => c['cancelledAt'] == null && !cancelledIds.contains(c['id'])).toList();
  static List<Map<String, dynamic>> paymentsOf(Map<String, dynamic> f) =>
      [...(f['payments'] as List).cast<Map<String, dynamic>>(), ...(extraPayments[f['id']] ?? const [])];
  static List<Map<String, dynamic>> callsOf(Map<String, dynamic> f) =>
      [...(f['calls'] as List).cast<Map<String, dynamic>>(), ...(extraCalls[f['id']] ?? const [])];
  static List<String> criteriaOf(Map<String, dynamic> f) =>
      [...(f['criteria'] as List).cast<String>(), ...(extraCriteria[f['id']] ?? const [])];
  static int studentsN(Map<String, dynamic> f) => (f['members'] as List).length;
  static String gradesOf(Map<String, dynamic> f) => (f['members'] as List).map((m) => (m as Map)['grade']).join(' · ');
  static String studentsOf(Map<String, dynamic> f) => (f['members'] as List).map((m) => (m as Map)['first']).join(', ');

  // ─── הנחה (הכרעה 23-ג): הנחת-אחים-אוטו (נגזרת ממספר-התלמידים) ⊕ קריטריונים-ידניים ⇒ maxDiscountPct ───
  static List<String> effectiveCriteria(Map<String, dynamic> f) {
    final n = studentsN(f);
    return {if (n >= 3) 'sib3' else if (n == 2) 'sib2', ...criteriaOf(f)}.toList();
  }
  static num discountPct(Map<String, dynamic> f) => maxDiscountPct(effectiveCriteria(f), criteria);
  static bool fullScholarship(Map<String, dynamic> f) => discountPct(f) >= 100;
  static String discountLabel(Map<String, dynamic> f) {
    final ids = effectiveCriteria(f);
    final best = criteria.where((c) => ids.contains(c['id'])).fold<Map<String, dynamic>?>(null, (b, c) => b == null || (c['discountPct'] as num) > (b['discountPct'] as num) ? c : b);
    return best == null ? '' : '${best['label']} ${best['discountPct']}%';
  }
  // סכום-חיוב-נטו: שכ״ל אחרי-הנחה (effectivePrice⊕maxDiscountPct), שאר-הסוגים מלא
  static int netOf(Map<String, dynamic> f, Map<String, dynamic> c) => discountableTypes.contains(c['cat'])
      ? effectivePrice(c['amount'] as num, effectiveCriteria(f), criteria, maxDiscountPct)
      : (c['amount'] as num).toInt();
  static int grossOf(Map<String, dynamic> f, Map<String, dynamic> c) => (c['amount'] as num).toInt();

  // ─── הערכת-מצב (פעולת-יסוד): חיוב · שולם · יתרה (payBal) · זכות (payCredit) · סטטוס ───
  static int charged(Map<String, dynamic> f) => grandTotal(liveCharges(f), (c) => netOf(f, c as Map<String, dynamic>)).toInt();
  static int grossCharged(Map<String, dynamic> f) => grandTotal(liveCharges(f), (c) => grossOf(f, c as Map<String, dynamic>)).toInt();
  static int scholarshipOf(Map<String, dynamic> f) => grossCharged(f) - charged(f);
  static int paid(Map<String, dynamic> f) => grandTotal(paymentsOf(f), (p) => (p as Map)['amount'] as num).toInt();
  static num _paidOf(Map e) => paid(e['__f'] as Map<String, dynamic>);
  // שיבוץ-בצורת-Enrollment (totalDue·carryBalance) — הקלט האמיתי של payBal/payCredit/enrollmentPaidStatus
  static Map<String, dynamic> enrollmentOf(Map<String, dynamic> f) =>
      {'totalDue': charged(f), 'carryBalance': f['carryBalance'] ?? 0, '__f': f};
  static int balance(Map<String, dynamic> f) => writtenOff.contains(f['id']) ? 0 : payBal(enrollmentOf(f), _paidOf).toInt();
  static int credit(Map<String, dynamic> f) => payCredit(enrollmentOf(f), (e) => _paidOf(e)).toInt();
  static String paidStatus(Map<String, dynamic> f) =>
      enrollmentPaidStatus(enrollmentOf(f), (e) => payBal(e, _paidOf), (e) => _paidOf(e));

  // ותק-החוב: החיוב הפתוח הוותיק-ביותר (הקצאת-FIFO: תשלומים מכסים חיובים לפי-תאריך) ⇒ dayDiff מול today
  static String? oldestOpenDate(Map<String, dynamic> f) {
    if (balance(f) <= 0) return null;
    final cs = [...liveCharges(f)]..sort((a, b) => '${a['date']}'.compareTo('${b['date']}'));
    var cover = paid(f) - ((f['carryBalance'] as num?) ?? 0);
    for (final c in cs) {
      cover -= netOf(f, c);
      if (cover < 0) return c['date'] as String;
    }
    return cs.isEmpty ? null : cs.last['date'] as String;
  }
  static int agingDays(Map<String, dynamic> f) {
    final d = oldestOpenDate(f);
    if (d == null) return 0;
    final n = dayDiff(d, today);
    return n.isFinite ? n.toInt().clamp(0, 1 << 20) : 0;
  }
  static bool oldDebt(Map<String, dynamic> f) => balance(f) > 0 && agingDays(f) > oldDebtDays;
  static int agingBand(Map<String, dynamic> f) { // 0=אין-חוב · 1=טרי(≤14) · 2=בפיגור(≤90) · 3=ותיק(>90)
    if (balance(f) <= 0) return 0;
    final d = agingDays(f);
    return d > oldDebtDays ? 3 : d > gentleDays ? 2 : 1;
  }

  // ─── תשלומים: אחרון · אמצעי · חודש ───
  static String lastPaymentDate(Map<String, dynamic> f) => supLast({'last': '', 'hist': [for (final p in paymentsOf(f)) {'d': p['date']}]}) as String;
  static String lastMethod(Map<String, dynamic> f) {
    final ps = paymentsOf(f);
    if (ps.isEmpty) return '';
    final s = [...ps]..sort((a, b) => '${b['date']}'.compareTo('${a['date']}'));
    return s.first['method'] as String;
  }
  static int paidInMonth(Map<String, dynamic> f, String ym) =>
      grandTotal(paymentsOf(f).where((p) => monthKey(p['date'] as String) == ym).toList(), (p) => (p as Map)['amount'] as num).toInt();

  // ─── הו״ק (מנועי-מדף): sp בצורת-Supporter (hok·donations·hist) ───
  static Map<String, Object?> spOf(Map<String, dynamic> f) {
    final h = f['hok'] as Map?;
    final active = hokOverride[f['id']] ?? (h?['active'] == true);
    return {
      'id': f['id'], 'name': f['name'], 'phone': f['phone'], 'email': f['email'],
      'hok': h == null ? null : {...h, 'active': active},
      'donations': [for (final p in paymentsOf(f)) {'date': p['date'], 'amount': p['amount'], 'cur': '₪', 'cat': p['method'] == 'הו״ק' ? hokCat : 'תשלום'}],
      'hist': (f['hist'] as List?) ?? const [],
    };
  }
  static bool hasHok(Map<String, dynamic> f) => f['hok'] != null;
  static bool hokFlag(Map<String, dynamic> f) => hasHok(f) && (hokOverride[f['id']] ?? ((f['hok'] as Map)['active'] == true));
  static bool hokActive(Map<String, dynamic> f) => hokEffectivelyActive(spOf(f), today, skHokActive.hokEffectivelyActive_T);
  static bool hokFailed(Map<String, dynamic> f) => hokFlag(f) && !hokActive(f); // מסומנת-פעילה אך הסליקה פסקה (>2 חודשים)
  static bool hokRecorded(Map<String, dynamic> f) => hokRecordedThisMonth(spOf(f), today, hokCat, skHokRec.hokRecordedThisMonth_T);
  static String hokMethod(Map<String, dynamic> f) => hasHok(f) ? hokMethodLabel('${(f['hok'] as Map)['method'] ?? ''}', term: (k) => tdHokMethod.kTerms[k] ?? k) : '';
  static bool _active(Map<String, Object?> sp, String t) => hokEffectivelyActive(sp, t, skHokActive.hokEffectivelyActive_T);
  static bool _recorded(Map<String, Object?> sp, String t) => hokRecordedThisMonth(sp, t, hokCat, skHokRec.hokRecordedThisMonth_T);
  // רשימת-הו״ק-לרישום-החודש (ממוינת לפי יום-חיוב) — הבסיס לרישום-מרוכז דו-שלבי
  static List<Map<String, dynamic>> hokDueList(List<Map<String, dynamic>> fs) {
    final sps = [for (final f in fs) spOf(f)];
    final due = hokDue(sps, today, _active, _recorded);
    return [for (final sp in due) fs.firstWhere((f) => f['id'] == sp['id'])];
  }
  // צפוי-מהו״ק-החודש = hokDue (טרם-נרשמו) ⊕ hokMonthlyTotal (Σ סכומי-ההו״ק-הפעילות) — הרכבת שני מנועים
  static int hokExpected(List<Map<String, dynamic>> fs) =>
      hokMonthlyTotal([for (final f in hokDueList(fs)) spOf(f)], 1, today, (sp, t) => _active((sp as Map).cast<String, Object?>(), t as String));

  // ─── סיכון-גבייה (23-ד · חיבור-מודלים בהחלטה): ותק ⊕ דפוס-תשלום-RFM (supScore⊕tierOf) ⊕ מגמה (trendFromScan) ───
  static Map<String, dynamic> _rfmSp(Map<String, dynamic> f) =>
      {'ils': paid(f), 'usd': 0, 'count': paymentsOf(f).where((p) => (p['amount'] as num) > 0).length, 'last': lastPaymentDate(f), 'hist': const []};
  static int rfm(Map<String, dynamic> f) => supScore(_rfmSp(f),
      rate: 1, nowMs: DateTime.parse('${today}T12:00:00').millisecondsSinceEpoch,
      supTotalIls: (sp, r) => supTotalIls(sp, rate: r, supIls: supIls, supUsd: supUsd),
      supLast: (sp) => supLast(sp as Map), supCount: supCount);
  static String tierKey(Map<String, dynamic> f) => (tierOf(rfm(f), 500, term: (k) => tdTier.kTerms[k] ?? k) as Map)['key'] as String;
  static String tierLabel(Map<String, dynamic> f) => (tierOf(rfm(f), 500, term: (k) => tdTier.kTerms[k] ?? k) as Map)['label'] as String;
  static List<num> monthly(Map<String, dynamic> f, [int months = 6]) { // Σתשלומים פר-חודש, 6 חודשים אחרונים
    final t = DateTime.parse('${today}T12:00:00');
    return [for (var i = months - 1; i >= 0; i--) paidInMonth(f, _ym(DateTime(t.year, t.month - i, 1)))];
  }
  static String _ym(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';
  static String ymOf(DateTime d) => _ym(d);
  static Map<String, dynamic> trend(Map<String, dynamic> f) => trendFromScan({'monthly': monthly(f)});
  // 0=נמוך · 1=בינוני · 2=גבוה. חוב-ותיק או דרגת-red ⇒ גבוה; בפיגור/pale/מגמה-יורדת ⇒ בינוני.
  static int risk(Map<String, dynamic> f) {
    if (balance(f) <= 0 || fullScholarship(f) || writtenOff.contains(f['id'])) return 0;
    final band = agingBand(f), tier = tierKey(f), dir = trend(f)['dir'];
    if (band == 3 || tier == 'red' || hokFailed(f)) return 2;
    if (hokFlag(f) && hokActive(f) && hokRecorded(f)) return 0; // הו״ק חיה ונרשמה החודש = משלמים-בקצב ⇒ לא-בסיכון
    if (band == 2 || tier == 'pale' || dir == 'down' || arrangementLate(f)) return 1;
    return 0;
  }
  static String riskLabel(int r) => r == 2 ? 'גבוה' : r == 1 ? 'בינוני' : 'נמוך';

  // ─── הסדר-תשלומים: תשלומי-הסדר (installmentOf) · פיגור = תשלום-הסדר שמועדו עבר ולא-מכוסה ───
  static List<Map<String, dynamic>> installments(Map<String, dynamic> f) => liveCharges(f).where((c) => c['installmentOf'] != null).toList();
  static bool hasArrangement(Map<String, dynamic> f) => installments(f).isNotEmpty;
  static bool arrangementLate(Map<String, dynamic> f) {
    if (!hasArrangement(f) || balance(f) <= 0) return false;
    final od = oldestOpenDate(f);
    return od != null && installments(f).any((c) => c['date'] == od) && dayDiff(od, today) > 0;
  }

  // ─── חיוב-כפול-חשוד (chargeDedupKey על אסמכתא-פנימית: סוג|סכום|תאריך|עבור-מי) ───
  static String _refOf(Map<String, dynamic> c) => '${c['cat']}|${c['amount']}|${c['date']}|${c['memberId']}';
  static List<Map<String, dynamic>> duplicateCharges(Map<String, dynamic> f) {
    final seen = <String>{};
    final out = <Map<String, dynamic>>[];
    for (final c in liveCharges(f)) {
      final k = chargeDedupKey({'txnId': '', 'reference': _refOf(c)});
      if (!seen.add(k)) out.add(c);
    }
    return out;
  }

  // ─── תזכורת-מדורגת (segulaReminders: התחלה=חיוב-פתוח-ותיק, דילוגים=דרגות) · מגן-כבוד: פרטית, לא חוסמת ───
  static const gradeOffsets = [14, 45, 90]; // עדינה · רגילה · הנהלה
  static const gradeNames = ['עדינה', 'רגילה', 'הנהלה'];
  static List<Map<String, dynamic>> reminderPlan(Map<String, dynamic> f) {
    final start = oldestOpenDate(f);
    if (start == null) return const [];
    final plan = segulaReminders(start, gradeOffsets) as List;
    return [for (var i = 0; i < plan.length; i++) {'grade': gradeNames[i], 'date': (plan[i] as Map)['date'], 'final': (plan[i] as Map)['final']}];
  }
  static List<Map<String, dynamic>> remindersSent(Map<String, dynamic> f) => callsOf(f).where((c) => c['outcome'] == 'reminder').toList();
  static int remindersThisMonth(Map<String, dynamic> f) => remindersSent(f).where((c) => monthKey(c['at'] as String) == monthKey(today)).length;
  // הדרגה-הבאה: הראשונה בלוח שמועדה הגיע ועדיין לא נשלחה (מספר-שנשלחו < אינדקס+1)
  static Map<String, dynamic>? nextReminder(Map<String, dynamic> f) {
    if (balance(f) <= 0 || fullScholarship(f) || (hokFlag(f) && hokActive(f) && hokRecorded(f))) return null;
    final plan = reminderPlan(f), sent = remindersSent(f).length;
    for (var i = sent; i < plan.length; i++) {
      if ('${plan[i]['date']}'.compareTo(today) <= 0) return plan[i];
    }
    return null;
  }
  static String _tpl(dynamic cfg, String key, Map vars) { // שקע-renderTemplate (תבנית-לפי-דרגה מוזרקת ב-cfg)
    var t = ((cfg as Map)['templates'] as Map)[key] as String;
    vars.forEach((k, v) => t = t.split('{$k}').join('$v'));
    return t;
  }
  static const _templates = {
    'עדינה': 'שלום {org}: תזכורת ידידותית — יתרה פתוחה עבור {what} בסך ₪{amount}. אם כבר שולם, נא להתעלם. תודה 🌷',
    'רגילה': 'שלום, מ{org}: יתרה לתשלום עבור {what} — ₪{amount}. נשמח לתיאום הסדר נוח. תודה רבה!',
    'הנהלה': 'שלום, מהנהלת {org}: יתרה פתוחה עבור {what} — ₪{amount}. נבקש ליצור קשר לתיאום. בברכה.',
  };
  static String reminderText(Map<String, dynamic> f, String grade) => waPaymentText(orgName, 'שכר-לימוד ${year}', balance(f),
      {'templates': {'wa.payment': _templates[grade] ?? _templates['רגילה']!}}, _tpl, (o) => '$o') as String;

  // ─── משימות-מעקב (overdueContactTaskDrafts): מי שעבר-מועד-מעקב (nextDate ≤ today) ⇒ טיוטת-משימה ───
  static List<Map<String, dynamic>> followUps(List<Map<String, dynamic>> fs) => overdueContactTaskDrafts(
      [for (final f in fs) {'id': f['id'], 'name': f['name'], 'nextDate': f['nextDate'] ?? ''}],
      const [], 'treasury', today, (a) => '$a', skOverdue.overdueContactTaskDrafts_T);

  // ─── הפעולה-הנכונה (23-ד · הכרעה מאוחדת): מלגה? הסדר? תזכורת? — נגזרת מהסיכון+הותק+הו״ק ───
  static Map<String, dynamic> rightAction(Map<String, dynamic> f) {
    if (writtenOff.contains(f['id'])) return {'glyph': '🗂', 'tone': 0, 'text': 'סומן כחוב-אבוד — מעקב הנהלה בלבד'};
    if (balance(f) <= 0 && liveCharges(f).isEmpty) return {'glyph': '📭', 'tone': 0, 'text': 'אין חיובים — לרשום חיוב-שנה'};
    if (fullScholarship(f)) return {'glyph': '🎓', 'tone': 1, 'text': 'מלגה מלאה — אפס-חוב, אין תזכורות'};
    if (balance(f) <= 0) return {'glyph': '✅', 'tone': 1, 'text': credit(f) > 0 ? 'הכל שולם · זכות ${shekel(credit(f))} להחזר/קיזוז' : 'הכל שולם — תודה'};
    if (hokFailed(f)) return {'glyph': '⚠️', 'tone': 2, 'text': 'הו״ק נכשלה — התרעה + ניסיון-חיוב-חוזר לפני תזכורת'};
    if (arrangementLate(f)) return {'glyph': '📆', 'tone': 3, 'text': 'הסדר בפיגור — שיחה עדינה לעדכון-פריסה'};
    final r = risk(f), nr = nextReminder(f);
    if (r == 2) return {'glyph': '🤝', 'tone': 2, 'text': 'חוב-ותיק/סיכון-גבוה — להציע הסדר או לבחון מלגה (הנהלה)'};
    if (hokFlag(f) && hokActive(f) && hokRecorded(f)) return {'glyph': '💳', 'tone': 1, 'text': 'הו״ק פעילה ונרשמה החודש — היתרה נגבית בהדרגה, אין צורך בתזכורת'};
    if (nr != null) return {'glyph': '🔔', 'tone': 3, 'text': 'תזכורת ${nr['grade']} מועדה הגיע (${fmtDate(nr['date'] as String?)}) — לשלוח בפרטיות'};
    if (hokFlag(f) && hokActive(f)) return {'glyph': '💳', 'tone': 1, 'text': 'הו״ק פעילה — ממתינה לרישום החודש'};
    return {'glyph': '⏳', 'tone': 0, 'text': 'חוב טרי — להמתין למועד התזכורת הראשונה'};
  }

  // ─── סטטוס-משפחה (המפרט: תקין/בפיגור/הסדר/מלגה-מלאה) ───
  static String statusOf(Map<String, dynamic> f) => writtenOff.contains(f['id'])
      ? 'חוב-אבוד'
      : fullScholarship(f)
          ? 'מלגה-מלאה'
          : hasArrangement(f) && balance(f) > 0
              ? (arrangementLate(f) ? 'הסדר-בפיגור' : 'הסדר')
              : balance(f) <= 0
                  ? 'תקין'
                  : agingBand(f) >= 2
                      ? 'בפיגור'
                      : 'תקין';

  // ─── פירוק-לפי-סוג (countBy⊕grandTotal) ───
  static Map<String, int> byType(Map<String, dynamic> f) {
    final m = <String, int>{};
    for (final c in liveCharges(f)) {
      m[c['cat'] as String] = (m[c['cat'] as String] ?? 0) + netOf(f, c);
    }
    return m;
  }

  // ─── ביצוע (פעולות = state + אודיט) ───
  static void addCharge(Map<String, dynamic> f, String role, {required String cat, required int amount, required String date, required String memberId, String note = '', String? installmentOf}) {
    if (amount <= 0) return;
    (extraCharges[f['id']] ??= []).add({'id': _nid('c'), 'date': date, 'amount': amount, 'cur': '₪', 'cat': cat, 'method': '', 'memberId': memberId, 'note': note, if (installmentOf != null) 'installmentOf': installmentOf});
    _log(role, f['id'] as String, 'חיוב $cat ${shekel(amount)} עבור $memberId${note.isEmpty ? '' : ' · $note'}');
  }
  static void addPayment(Map<String, dynamic> f, String role, {required int amount, required String method, required String date, String note = ''}) {
    if (amount <= 0) return;
    (extraPayments[f['id']] ??= []).add({'rid': _nid('p'), 'date': date, 'amount': amount, 'method': method, if (note.isNotEmpty) 'note': note});
    _log(role, f['id'] as String, 'תשלום ${shekel(amount)} ב$method${note.isEmpty ? '' : ' · $note'}');
  }
  static void refund(Map<String, dynamic> f, String role) { // 💸 החזר-זכות: תשלום-שלילי (הפחתת-שולם) בגובה-הזכות
    final c = credit(f);
    if (c <= 0) return;
    (extraPayments[f['id']] ??= []).add({'rid': _nid('r'), 'date': today, 'amount': -c, 'method': 'החזר', 'note': 'החזר-זכות'});
    _log(role, f['id'] as String, 'החזר-זכות ${shekel(c)}');
  }
  static void cancelCharge(Map<String, dynamic> f, String role, Map<String, dynamic> c, String reason) {
    cancelledIds.add(c['id'] as String);
    cancelReason[c['id'] as String] = reason;
    _log(role, f['id'] as String, 'ביטול-חיוב ${c['cat']} ${shekel(c['amount'] as num)} · סיבה: $reason');
  }
  static void grantDiscount(Map<String, dynamic> f, String role, String criterionId) {
    if (criteriaOf(f).contains(criterionId)) return;
    (extraCriteria[f['id']] ??= []).add(criterionId);
    _log(role, f['id'] as String, 'הענקת-הנחה/מלגה: ${criteria.firstWhere((c) => c['id'] == criterionId)['label']}');
  }
  static void setArrangement(Map<String, dynamic> f, String role, int parts) { // פריסת-היתרה ל-N תשלומים חודשיים (הסדר)
    final bal = balance(f);
    if (bal <= 0 || parts < 2) return;
    final arr = _nid('arr');
    final per = (bal / parts).ceil();
    final t = DateTime.parse('${today}T12:00:00');
    // מבטלים את החיובים הפתוחים ומחליפים בפריסה — כמו f5 במקור (cancelledAt + installmentOf)
    for (final c in liveCharges(f)) {
      cancelledIds.add(c['id'] as String);
      cancelReason[c['id'] as String] = 'הוחלף בהסדר $arr';
    }
    final already = paid(f) - ((f['carryBalance'] as num?) ?? 0);
    if (already > 0) (extraCharges[f['id']] ??= []).add({'id': _nid('c'), 'date': today, 'amount': already, 'cur': '₪', 'cat': arrangementType, 'method': '', 'memberId': studentsOf(f), 'note': 'שולם עד ההסדר'});
    for (var i = 0; i < parts; i++) {
      final d = DateTime(t.year, t.month + i, 20);
      (extraCharges[f['id']] ??= []).add({'id': _nid('c'), 'date': '${_ym(d)}-20', 'amount': i == parts - 1 ? bal - per * (parts - 1) : per, 'cur': '₪', 'cat': arrangementType, 'method': '', 'memberId': studentsOf(f), 'installmentOf': arr, 'note': 'הסדר $parts/${i + 1}'});
    }
    _log(role, f['id'] as String, 'הסדר-תשלומים: ${shekel(bal)} ב-$parts תשלומים');
  }
  static void toggleHok(Map<String, dynamic> f, String role) {
    if (!hasHok(f)) return;
    hokOverride[f['id'] as String] = !hokFlag(f);
    _log(role, f['id'] as String, hokFlag(f) ? 'הפעלת-הו״ק' : 'הפסקת-הו״ק');
  }
  static void sendReminder(Map<String, dynamic> f, String role, String grade) {
    (extraCalls[f['id']] ??= []).add({'at': today, 'outcome': 'reminder', 'grade': grade});
    _log(role, f['id'] as String, 'תזכורת $grade נשלחה (פרטית)');
  }
  static void writeOff(Map<String, dynamic> f, String role) {
    writtenOff.add(f['id'] as String);
    _log(role, f['id'] as String, 'סומן כחוב-אבוד (${shekel(payBal(enrollmentOf(f), _paidOf))})');
  }
  // רישום-הו״ק-חודשי-מרוכז (השלב-השני של האישור-הדו-שלבי): תשלום פר-משפחה-בתור בסכום-ההו״ק
  static int runHokBatch(List<Map<String, dynamic>> fs, String role) {
    final due = hokDueList(fs);
    for (final f in due) {
      addPayment(f, role, amount: ((f['hok'] as Map)['amount'] as num).toInt(), method: 'הו״ק', date: today, note: 'רישום-מרוכז');
    }
    if (due.isNotEmpty) _log(role, '*', 'רישום-הו״ק-מרוכז: ${due.length} משפחות');
    return due.length;
  }

  // ─── התאמת-תשלום-לחיוב (matching · strongMatchForCharge): תשלומים-נכנסים משער-חיצוני ⇒ משפחה ───
  //   הצורה = תשלום-נכנס (phone/email/zeout/amount). זה המקום-השמור לשער-הסליקה; הדוגמה מדגימה את המנוע.
  static const incoming = <Map<String, dynamic>>[
    {'id': 'in1', 'date': '2026-09-04', 'amount': 1000, 'phone': '052-2222222', 'email': '', 'zeout': '', 'toremId': '', 'name': 'רחל לוי'},
    {'id': 'in2', 'date': '2026-09-04', 'amount': 480, 'phone': '', 'email': 'unknown@family', 'zeout': '', 'toremId': '', 'name': 'לא ידוע'},
  ];
  static List<String> _keysOf(Map<String, dynamic> m) => [
        if ('${m['extId'] ?? ''}'.isNotEmpty) 'ext:${m['extId']}',
        if ('${m['idNum'] ?? m['zeout'] ?? ''}'.isNotEmpty) 'id:${m['idNum'] ?? m['zeout']}',
        if ('${m['phone'] ?? ''}'.replaceAll('-', '').isNotEmpty) 'ph:${'${m['phone']}'.replaceAll('-', '')}',
        if ('${m['email'] ?? ''}'.isNotEmpty) 'em:${'${m['email']}'.toLowerCase()}',
      ];
  static Map<String, dynamic>? matchIncoming(Map<String, dynamic> inc, List<Map<String, dynamic>> fs) =>
      strongMatchForCharge(inc, fs, (m) => _keysOf((m as Map).cast<String, dynamic>())) as Map<String, dynamic>?;

  // ─── קישור-תשלום (שער-חיצוני · מקום-שמור · חוק-7): payUrl = קונפיגורציית-הצבה (חוק-6). ריק ⇒ null ⇒ הכפתור שמור ───
  static const String payUrl = ''; // מוזרק בהצבה (למשל https://…/pay/{amount}/{name}); כאן ריק במכוון
  static String? _safeHttps(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    final u = Uri.tryParse(t);
    return u != null && u.scheme == 'https' && u.host.isNotEmpty ? u.toString() : null;
  }
  static String? payLinkOf(Map<String, dynamic> f) => payLink(payUrl, balance(f), f['payer'] as String, _safeHttps);

  // ═══ איתור (23-ג · תובנה) = DsSearch ⊕ smartFilter ⊕ smartScore ⊕ normSearch — משפחה/הורה/תלמיד/טלפון ═══
  static const Map<String, String> _finals = {'k1': 'כ', 'k2': 'מ', 'k3': 'נ', 'k4': 'פ', 'k5': 'צ'};
  static String _norm(dynamic q) => normSearch(q, _finals);
  static Iterable _expand(dynamic q, dynamic norm) => [norm(q)];
  static num _score(dynamic exp, dynamic term) => _norm(term).contains('$exp') ? 100 : 0;
  static num _scoreOf(dynamic q, dynamic terms) => smartScore(q, terms, _norm, _expand, _score) as num;
  static bool _hasQuery(dynamic q) => (q as String).trim().isNotEmpty;
  static List<String> _termsOf(Map<String, dynamic> f) =>
      ['${f['name']}', '${f['payer']}', '${f['phone']}', ...(f['members'] as List).map((m) => '${(m as Map)['first']}'), gradesOf(f)];
  static List<Map<String, dynamic>> search(List<Map<String, dynamic>> fs, String q) =>
      (smartFilter(q, fs, (it) => _termsOf(it as Map<String, dynamic>), _hasQuery, _scoreOf) as List).cast<Map<String, dynamic>>();

  // ═══ חריגה/פילטרים (23-ג) = FilterChipPill/DsEnumField ⊕ finderMatches (AND על נעילות-צירים) ═══
  //   13 צירי-המפרט: כיתה · חוג · סוג-חיוב · סטטוס · יתרה>0 · ותק>N · הו״ק · מלגה · ללא-תזכורת · תזכורת>2 · אמצעי · חודש/שנה · טקסט(=search)
  static String axisValue(Map<dynamic, dynamic> db, dynamic x, dynamic axis) {
    final f = x as Map<String, dynamic>;
    switch ('$axis') {
      case 'debt': return balance(f) > 0 ? '1' : '0';
      case 'old': return oldDebt(f) ? '1' : '0';
      case 'hok': return hokFlag(f) ? '1' : '0';
      case 'scholar': return discountPct(f) > 0 ? '1' : '0';
      case 'noremind': return balance(f) > 0 && remindersSent(f).isEmpty ? '1' : '0';
      case 'remind2': return remindersSent(f).length > 2 ? '1' : '0';
      case 'arr': return hasArrangement(f) ? '1' : '0';
      case 'risk': return risk(f) >= 1 ? '1' : '0';
      case 'status': return statusOf(f);
      case 'grade': return (f['members'] as List).any((m) => '${(m as Map)['grade']}'.startsWith('${db['grade']}')) ? '1' : '0';
      case 'type': return liveCharges(f).any((c) => c['cat'] == db['type']) ? '1' : '0';
      case 'course': return liveCharges(f).any((c) => c['cat'] == 'חוג' && '${c['note'] ?? ''}' == '${db['course']}') ? '1' : '0';
      case 'method': return paymentsOf(f).any((p) => p['method'] == db['method']) || (db['method'] == 'הו״ק' && hokFlag(f)) ? '1' : '0';
      case 'year': return liveCharges(f).any((c) => dateInRange(c['date'] as String, '${db['year']}-01-01', '${db['year']}-12-31')) || paymentsOf(f).any((p) => dateInRange(p['date'] as String, '${db['year']}-01-01', '${db['year']}-12-31')) ? '1' : '0';
    }
    return '';
  }
  static List<Map<String, dynamic>> filter(List<Map<String, dynamic>> fs, Map<dynamic, dynamic> locks, Map<String, String> ctx) =>
      finderMatches({'families': fs, ...ctx}, locks, axisValue).cast<Map<String, dynamic>>();
  static List<String> grades(List<Map<String, dynamic>> fs) =>
      {for (final f in fs) for (final m in f['members'] as List) '${(m as Map)['grade']}'.split('-').first}.toList()..sort();
  static List<String> courses(List<Map<String, dynamic>> fs) =>
      {for (final f in fs) for (final c in liveCharges(f)) if (c['cat'] == 'חוג' && c['note'] != null) '${c['note']}'}.toList()..sort();
  static List<String> years(List<Map<String, dynamic>> fs) =>
      donationYears([for (final f in fs) for (final p in paymentsOf(f)) {'date': p['date']}, for (final f in fs) for (final c in liveCharges(f)) {'date': c['date']}]);

  // ═══ KPI-10 (המפרט) — כולם מנועי-מדף/שדות-אמת ═══
  static int kCharged(List<Map<String, dynamic>> fs) => grandTotal(fs, (f) => charged(f as Map<String, dynamic>)).toInt();
  static int kPaid(List<Map<String, dynamic>> fs) => grandTotal(fs, (f) => paid(f as Map<String, dynamic>)).toInt();
  static int kOpen(List<Map<String, dynamic>> fs) => grandTotal(fs, (f) => balance(f as Map<String, dynamic>)).toInt();
  static int kPct(List<Map<String, dynamic>> fs) => kCharged(fs) == 0 ? 0 : ((kPaid(fs) - grandTotal(fs, (f) => credit(f as Map<String, dynamic>))) * 100 / kCharged(fs)).round().clamp(0, 100);
  static int kInDebt(List<Map<String, dynamic>> fs) => fs.where((f) => balance(f) > 0).length;
  static int kOld(List<Map<String, dynamic>> fs) => grandTotal(fs.where(oldDebt).toList(), (f) => balance(f as Map<String, dynamic>)).toInt();
  static int kExpected(List<Map<String, dynamic>> fs) { // צפוי-החודש = הו״ק-שטרם-נרשמו ⊕ תשלומי-הסדר-שמועדם-החודש
    final ym = monthKey(today);
    final arr = grandTotal([for (final f in fs) for (final c in installments(f)) if (monthKey(c['date'] as String) == ym && balance(f) > 0) netOf(f, c)], (x) => x as num).toInt();
    return hokExpected(fs) + arr;
  }
  static int kHokActive(List<Map<String, dynamic>> fs) => fs.where((f) => hokFlag(f) && hokActive(f)).length;
  static int kScholar(List<Map<String, dynamic>> fs) => grandTotal(fs, (f) => scholarshipOf(f as Map<String, dynamic>)).toInt();
  static int kReminders(List<Map<String, dynamic>> fs) => grandTotal(fs, (f) => remindersThisMonth(f as Map<String, dynamic>)).toInt();
  static int collectedInMonth(List<Map<String, dynamic>> fs, String ym) => grandTotal(fs, (f) => paidInMonth(f as Map<String, dynamic>, ym)).toInt();
  static Map<String, dynamic> collectionTrend(List<Map<String, dynamic>> fs) {
    final t = DateTime.parse('${today}T12:00:00');
    return trendFromScan({'monthly': [for (var i = 5; i >= 0; i--) collectedInMonth(fs, _ym(DateTime(t.year, t.month - i, 1)))]});
  }
  static List<List<Object>> statusCounts(List<Map<String, dynamic>> fs) => countBy(fs, (f) => statusOf(f as Map<String, dynamic>));

  // ═══ ייצוא (23-ג) = toCsv ⊕ csvEscape ⊕ exportAllowed ═══
  static const csvHeader = ['משפחה', 'תלמידים', 'כיתות', 'חיובים', 'שולם', 'יתרה', 'ותק', 'תשלום-אחרון', 'אמצעי', 'הו״ק', 'הנחה', 'תזכורות', 'סיכון', 'סטטוס', 'הורה-משלם', 'טלפון'];
  static List<List<Object?>> csvRows(List<Map<String, dynamic>> fs) => [
        csvHeader,
        for (final f in fs)
          [f['name'], studentsN(f), gradesOf(f), charged(f), paid(f), balance(f), agingDays(f), lastPaymentDate(f), lastMethod(f), hokFlag(f) ? (hokActive(f) ? 'פעילה' : 'נכשלה') : '', discountLabel(f), remindersSent(f).length, riskLabel(risk(f)), statusOf(f), f['payer'], f['phone']],
      ];
  static String csvOf(List<Map<String, dynamic>> fs) => toCsv(csvRows(fs), csvEscape) as String;
  static bool exportOk(int role) => exportAllowed(false) && can(role, 'fees.export');

  // ═══ חוזה-עמודות (חוק-7 · מקום-שמור): 16 עמודות-הליבה + שדות-השער-החיצוני כשקעים ═══
  //   נגזרת(get)=תמיד · שדה(key)=מוארת רק כשמשפחה נושאת ערך (receiptNo/clearingRef/invoiceNo — יאירו כשהשער יחובר)
  static final List<Map<String, Object?>> columnDefs = <Map<String, Object?>>[
    {'label': 'משפחה', 'get': (Map<String, dynamic> f) => '${f['name']}'},
    {'label': 'תלמידים', 'get': (Map<String, dynamic> f) => '${studentsN(f)}'},
    {'label': 'כיתות', 'get': (Map<String, dynamic> f) => gradesOf(f)},
    {'label': 'סך-חיובים', 'get': (Map<String, dynamic> f) => shekel(charged(f)), 'money': true},
    {'label': 'שולם', 'get': (Map<String, dynamic> f) => shekel(paid(f)), 'money': true},
    {'label': 'יתרה', 'get': (Map<String, dynamic> f) => shekel(balance(f)), 'money': true},
    {'label': 'ותק (ימים)', 'get': (Map<String, dynamic> f) => balance(f) > 0 ? '${agingDays(f)}' : '—'},
    {'label': 'תשלום-אחרון', 'get': (Map<String, dynamic> f) => fmtDate(lastPaymentDate(f))},
    {'label': 'אמצעי', 'get': (Map<String, dynamic> f) => lastMethod(f).isEmpty ? '—' : lastMethod(f)},
    {'label': 'הו״ק', 'get': (Map<String, dynamic> f) => !hasHok(f) ? '—' : hokFlag(f) ? (hokActive(f) ? '✅ פעילה' : '⚠️ נכשלה') : '⏸ מופסקת'},
    {'label': 'הנחה/מלגה', 'get': (Map<String, dynamic> f) => discountLabel(f).isEmpty ? '—' : discountLabel(f)},
    {'label': 'תזכורות', 'get': (Map<String, dynamic> f) => '${remindersSent(f).length}'},
    {'label': 'סיכון', 'get': (Map<String, dynamic> f) => riskLabel(risk(f))},
    {'label': 'סטטוס', 'get': (Map<String, dynamic> f) => statusOf(f)},
    {'label': 'הורה-משלם', 'get': (Map<String, dynamic> f) => '${f['payer']} · ${f['phone']}'},
    {'label': 'הערה', 'get': (Map<String, dynamic> f) => '${f['nextNote'] ?? '—'}'}, // Supporter.nextNote
    {'key': 'receiptNo', 'label': 'מס׳-קבלה (חיצוני)', 'money': true}, // מקום-שמור · שער-חיצוני
    {'key': 'clearingRef', 'label': 'אישור-סליקה'}, // מקום-שמור · שער-חיצוני
    {'key': 'invoiceNo', 'label': 'חשבונית'}, // מקום-שמור · שער-חיצוני
    {'key': 'payLinkSent', 'label': 'קישור-תשלום נשלח'}, // מקום-שמור · מואר כשהשער מוגדר
  ];
  static bool colShown(Map<String, Object?> c, List<Map<String, dynamic>> rows) =>
      c['get'] != null || rows.any((f) => f[c['key']] != null && '${f[c['key']]}'.trim().isNotEmpty);
  // שדות-מטא של תשלום (מקום-שמור): מאירים בציר-התשלומים כשהתשלום נושא אותם
  static const paymentMeta = <Map<String, String>>[
    {'key': 'receiptNo', 'prefix': '🧾 קבלה ', 'suffix': ''},
    {'key': 'clearingRef', 'prefix': '🔐 סליקה ', 'suffix': ''},
    {'key': 'invoiceNo', 'prefix': '📄 חשבונית ', 'suffix': ''},
    {'key': 'note', 'prefix': '', 'suffix': ''},
  ];

  // ═══ הרשאות (חוק-6 זהות=הזרקה) = roleOf ⊕ canGrantedAction · סכומים = הרשאת-כספים (מחנך: דגל בלבד) ═══
  static const roleDefs = <Map<String, dynamic>>[
    {'label': '💼 גזבר/ת', 'email': 'gizbar@school', 'config': {'adminEmails': ['gizbar@school']}}, // admin ⇒ הכל
    {'label': '🗂 מזכירות', 'email': 'office@school', 'config': {'features': {'fees.amounts': true, 'fees.pay': true, 'fees.charge': true, 'fees.remind': true, 'fees.export': true, 'fees.hok': true}}},
    {'label': '🏛 הנהלה', 'email': 'mgmt@school', 'config': {'features': {'fees.amounts': true, 'fees.scholarship': true, 'fees.arrangement': true, 'fees.writeoff': true, 'fees.export': true, 'fees.remind': true}}},
    {'label': '🧑‍🏫 מחנך/ת', 'email': 'teacher@school', 'config': {'features': {'fees.flag': true}}}, // דגל-חוב בלבד, ללא-סכומים
    {'label': '👨‍👩‍👧 הורה', 'email': 'cohen@family', 'config': {'features': {'fees.self': true, 'fees.amounts': true}}}, // החוב-שלי + תשלום
    {'label': '👁 צפייה', 'email': 'view@school', 'config': {'features': {'fees.amounts': true}}}, // תמונה בלבד, אפס-פעולות
  ];
  static bool _isAdmin(Map<String, dynamic> config, String email) => roleOf(config, email) == 'admin';
  static bool can(int role, String key) {
    final r = roleDefs[role];
    return canGrantedAction((r['config'] as Map).cast<String, dynamic>(), r['email'] as String, false, key, _isAdmin);
  }
  static bool amounts(int role) => can(role, 'fees.amounts');
  static bool isParent(int role) => can(role, 'fees.self') && !can(role, 'fees.charge');
  static String roleName(int role) => roleDefs[role]['label'] as String;
  // הורה רואה רק את משפחתו (זהות-מוזרקת: המייל של התפקיד = המייל של המשפחה)
  static List<Map<String, dynamic>> visibleFor(int role) =>
      isParent(role) ? families.where((f) => f['email'] == roleDefs[role]['email']).toList() : families;
}

// ═══════════════════════════════════════════════════════════════════════════════════════
// 💰 FeesScreen — המסך (const · ללא main). המנהל מחבר לניווט-הבית.
// ═══════════════════════════════════════════════════════════════════════════════════════
class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});
  /// איפוס פנקס-הפעולות לבסיס-האמת (לרתמות-בדיקה/דמו; חיבור-אסינק אמיתי יטען מחדש מהמקור)
  static void resetLedger() => _FeesData.reset();
  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  int _role = 0; // 0=גזבר · 1=מזכירות · 2=הנהלה · 3=מחנך · 4=הורה · 5=צפייה
  String _q = '';
  int _chip = 0; // 0=הכל · 1=יתרה>0 · 2=ותק>90 · 3=הו״ק · 4=מלגה · 5=ללא-תזכורת · 6=תזכורת>2 · 7=הסדר · 8=בסיכון
  String _grade = '', _type = '', _course = '', _method = '', _year = '', _status = '';
  int _mode = 0; // 0=🎯 חייבים · 1=📋 טבלה · 2=💳 הו״ק · 3=🔔 תזכורות · 4=📊 דוחות · 5=🧾 אודיט
  bool _loading = false;
  String? _error;
  bool _hokArmed = false; // אישור-דו-שלבי לרישום-הו״ק-מרוכז
  bool _filtersOpen = false;

  String get _roleName => _FeesData.roleName(_role);
  bool get _amounts => _FeesData.amounts(_role);
  String _m(num v) => _amounts ? shekel(v) : '🔒'; // נעילת-הרשאה-כספית: סכום ⇒ מנעול

  static const _chipAxis = {1: 'debt', 2: 'old', 3: 'hok', 4: 'scholar', 5: 'noremind', 6: 'remind2', 7: 'arr', 8: 'risk'};

  Widget _fchip(int i, String label) => FilterChipPill(
        label: label, selected: _chip == i, onTap: () => setState(() => _chip = i),
        activeFillColor: _acc, surfaceColor: const Color(0xFF14162E),
        activeTextColor: const Color(0xFF0B0B15), inkColor: _ink,
        outlineColor: const Color(0xFF2A2D4A), pillRadius: 999,
      );

  Map<dynamic, dynamic> get _locks => {
        if (_chip != 0) _chipAxis[_chip]!: '1',
        if (_grade.isNotEmpty) 'grade': '1',
        if (_type.isNotEmpty) 'type': '1',
        if (_course.isNotEmpty) 'course': '1',
        if (_method.isNotEmpty) 'method': '1',
        if (_year.isNotEmpty) 'year': '1',
        if (_status.isNotEmpty) 'status': _status,
      };

  @override
  Widget build(BuildContext context) {
    final all = _FeesData.visibleFor(_role);
    // דירוג: סיכון-יורד ⇒ ותק-יורד ⇒ יתרה-יורדת (המפרט: חוב · ותק-חוב · סיכון)
    final ranked = [...all]..sort((a, b) {
        final r = _FeesData.risk(b).compareTo(_FeesData.risk(a));
        if (r != 0) return r;
        final ag = _FeesData.agingDays(b).compareTo(_FeesData.agingDays(a));
        return ag != 0 ? ag : _FeesData.balance(b).compareTo(_FeesData.balance(a));
      });
    final visible = _FeesData.filter(_FeesData.search(ranked, _q), _locks,
        {'grade': _grade, 'type': _type, 'course': _course, 'method': _method, 'year': _year});
    // KPI-10 על כל-המשפחות-הנראות-לתפקיד (הורה ⇒ משפחתו בלבד)
    final kCharged = _FeesData.kCharged(all), kPaid = _FeesData.kPaid(all), kOpen = _FeesData.kOpen(all), kPct = _FeesData.kPct(all);
    final inDebt = _FeesData.kInDebt(all), oldN = all.where(_FeesData.oldDebt).length, kOld = _FeesData.kOld(all);
    final kExp = _FeesData.kExpected(all), kHok = _FeesData.kHokActive(all), kSch = _FeesData.kScholar(all), kRem = _FeesData.kReminders(all);
    final failed = all.where(_FeesData.hokFailed).toList();
    final late = all.where(_FeesData.arrangementLate).toList();
    final dups = [for (final f in all) if (_FeesData.duplicateCharges(f).isNotEmpty) f];
    final hokDue = _FeesData.hokDueList(all);
    final follow = _FeesData.followUps(all);
    final tripDebt = all.where((f) => _FeesData.balance(f) > 0 && _FeesData.liveCharges(f).any((c) => c['cat'] == 'טיול')).toList();
    final buckets = <int, List<Map<String, dynamic>>>{2: [], 1: [], 0: [], -1: []};
    for (final f in visible) {
      // דגל-בלבד (מחנך): שני דליים — דגל/תקין; אין דירוג-סיכון גלוי
      buckets[_FeesData.balance(f) <= 0 ? -1 : _amounts ? _FeesData.risk(f) : 0]!.add(f);
    }
    final secTitle = {2: '🔴 סיכון-גבוה / חוב-ותיק', 1: '🟠 בפיגור / בינוני', 0: _amounts ? '🟢 חוב-טרי' : '🚩 דגל-חוב', -1: '✅ ללא-חוב'};
    const secTone = {2: 2, 1: 3, 0: 0, -1: 1};
    final trend = _FeesData.collectionTrend(all);
    final thisMonth = _FeesData.collectedInMonth(all, monthKey(_FeesData.today));

    return DsScaffold(title: 'גבייה ותשלומים', subtitle: '${all.length} משפחות · ${_FeesData.year} · $_roleName', icon: '💰', header: false, children: [ForgeCenteredPageHeader(fields: ['', 'גבייה ותשלומים', '${all.length} משפחות · ${_FeesData.year} · $_roleName']), ...[
        // בורר-תפקיד (חוק-6 · זהות-מוזרקת) — מדגים גידור-הרשאות (roleOf⊕canGrantedAction)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in [for (final r in _FeesData.roleDefs) r['label'] as String]) [s]], selected: {_role}, onSelect: (i) => setState(() { _role = i; _hokArmed = false; })),
        ),
        _gap(10),
        if (!_amounts) ...[
          ForgeSectionPill(items: [['נעילת-הרשאה-כספית: תפקיד זה רואה דגל-חוב בלבד — אפס-סכומים, אפס-פרטי-חוב (מגן-כבוד)']], variants: const <int>[0]),
          _gap(8),
        ],
        // פס-עליון: חיפוש (DsSearch) · רענון · חיוב-חדש · רישום-תשלום · ייצוא — מגודרים פר-הרשאה
        Row(children: [
          Expanded(child: ForgeDsSearch(control: DsSearch(value: _q, onChanged: (v) => setState(() => _q = v), bare: true))),
          const SizedBox(width: 6),
          Padding(padding: const EdgeInsets.only(bottom: 12), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _refresh, child: ForgeSoftButton(fields: ['🔄']))),
          if (_FeesData.can(_role, 'fees.charge')) ...[
            const SizedBox(width: 6),
            Padding(padding: const EdgeInsets.only(bottom: 12), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openChargeForm(null, visible), child: ForgeSoftButton(fields: ['➕ חיוב']))),
          ],
          if (_FeesData.can(_role, 'fees.pay')) ...[
            const SizedBox(width: 6),
            Padding(padding: const EdgeInsets.only(bottom: 12), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openPaymentForm(null, visible), child: ForgeSoftButton(fields: ['💳 תשלום']))),
          ],
          if (_FeesData.exportOk(_role)) ...[
            const SizedBox(width: 6),
            Padding(padding: const EdgeInsets.only(bottom: 12), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openExport(visible), child: ForgeSoftButton(fields: ['⬇ CSV']))),
          ],
        ]),
        // צ׳יפי-חריגה (FilterChipPill מבוקר ⊕ finderMatches) — פעולת-יסוד "זיהוי-חריגה"
        Builder(builder: (_) { final chips = <(String, bool, VoidCallback)>[(('הכל'), _chip == (0), () => setState(() => _chip = (0))), (('🚩 דגל-חוב · $inDebt'), _chip == (1), () => setState(() => _chip = (1))), if (_amounts) ...[(('⏰ ותק>${_FeesData.oldDebtDays} · $oldN'), _chip == (2), () => setState(() => _chip = (2))), (('💳 הו״ק · ${all.where(_FeesData.hokFlag).length}'), _chip == (3), () => setState(() => _chip = (3))), (('🎓 מלגה/הנחה · ${all.where((f) => _FeesData.discountPct(f) > 0).length}'), _chip == (4), () => setState(() => _chip = (4))), (('🔕 ללא-תזכורת · ${all.where((f) => _FeesData.balance(f) > 0 && _FeesData.remindersSent(f).isEmpty).length}'), _chip == (5), () => setState(() => _chip = (5))), (('🔔 תזכורת>2 · ${all.where((f) => _FeesData.remindersSent(f).length > 2).length}'), _chip == (6), () => setState(() => _chip = (6))), (('📆 הסדר · ${all.where(_FeesData.hasArrangement).length}'), _chip == (7), () => setState(() => _chip = (7))), (('⚠️ בסיכון · ${all.where((f) => _FeesData.risk(f) >= 1).length}'), _chip == (8), () => setState(() => _chip = (8))), (_filtersOpen ? '▲ פילטרים' : '▼ פילטרים (כיתה·חוג·סוג·אמצעי·שנה·סטטוס)', _filtersOpen, () => setState(() => _filtersOpen = !_filtersOpen))]]; return ForgeFacetChip(bare: true, items: [for (final ch in chips) [ch.$1]], selected: <int>{for (final (k, ch) in chips.indexed) if (ch.$2) k}, onSelect: (k) => chips[k].$3()); }),
        if (_filtersOpen) ...[
          _gap(8),
          // פילטרי-ערך (DsEnumField מבוקר ⇒ נעילת-ציר ב-finderMatches): כיתה · חוג · סוג-חיוב · אמצעי · שנה · סטטוס
          Wrap(spacing: 10, runSpacing: 6, children: [
            _enum('כיתה', ['', ..._FeesData.grades(all)], _grade, (v) => setState(() => _grade = v)),
            _enum('חוג', ['', ..._FeesData.courses(all)], _course, (v) => setState(() => _course = v)),
            _enum('סוג-חיוב', ['', ..._FeesData.chargeTypes, _FeesData.arrangementType], _type, (v) => setState(() => _type = v)),
            _enum('אמצעי', ['', ..._FeesData.payMethodsSchool], _method, (v) => setState(() => _method = v)),
            _enum('שנה', ['', ..._FeesData.years(all)], _year, (v) => setState(() => _year = v)),
            _enum('סטטוס', const ['', 'תקין', 'בפיגור', 'הסדר', 'הסדר-בפיגור', 'מלגה-מלאה', 'חוב-אבוד'], _status, (v) => setState(() => _status = v)),
          ]),
        ],
        const SizedBox(height: 12),
        // KPI-10 (המפרט): hero=יתרה-פתוחה (המטרה: מה חסר) + 10 מדדי-מצב (BareStat, ערכי-אמת) + יחס-גבייה (StatRow)
        if (!_amounts)
          ForgeStripPanelFrame(fields: ['', ''], child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: ForgeStatPlain(fields: ['משפחות עם דגל-חוב מתוך ${all.length}', '$inDebt'])),
              const SizedBox(height: 8),
              const Text('פרטים וסכומים = גזברות בלבד. לתיאום: לפנות לגזבר/ת, לא לתלמיד.', style: TextStyle(color: _muted, fontSize: 12.5)),
            ]))
        else
        ForgeStripPanelFrame(fields: ['', ''], child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: ForgeStatPlain(fields: ['יתרה פתוחה · $inDebt משפחות בחוב', _m(kOpen)])),
            const SizedBox(height: 12),
            ForgeLinearProgressStatus(fields: ['אחוז-גבייה (שולם מתוך חיובים)', '$kPct%'], values: [kPct / 100]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: ForgeStatPlain(fields: ['🧾 סך-חיובים', _m(kCharged)])),
              Expanded(child: ForgeStatPlain(fields: ['✅ נגבה', _m(kPaid)])),
              Expanded(child: ForgeStatPlain(fields: ['💸 יתרה-פתוחה', _m(kOpen)])),
              Expanded(child: ForgeStatPlain(fields: ['📈 אחוז-גבייה', '$kPct%'])),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: ForgeStatPlain(fields: ['👨‍👩‍👧 משפחות-בחוב', '$inDebt'])),
              Expanded(child: ForgeStatPlain(fields: ['⏰ חוב-ותיק >${_FeesData.oldDebtDays}י׳ · $oldN', _m(kOld)])),
              Expanded(child: ForgeStatPlain(fields: ['📅 צפוי-החודש', _m(kExp)])),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: ForgeStatPlain(fields: ['💳 הו״ק-פעילות', '$kHok'])),
              Expanded(child: ForgeStatPlain(fields: ['🎓 מלגות/הנחות', _m(kSch)])),
              Expanded(child: ForgeStatPlain(fields: ['🔔 תזכורות-החודש', '$kRem'])),
            ]),
          ])),
        const SizedBox(height: 8),
        // מרכז-אוטומציות (23-ג · פרואקטיבי): הו״ק-נכשלה · הסדר-בפיגור · חיוב-כפול · הו״ק-לרישום · מעקב-שעבר-מועד · חוב-לפני-טיול
        if (failed.isNotEmpty && _amounts) ...[
          ForgeSectionPill(items: [['${failed.length} הו״ק נכשלה (הסליקה פסקה >2 חודשים) — התרעה + ניסיון-חוזר: ${failed.map((f) => f['name']).join(' · ')}']], variants: const <int>[0]),
          _gap(8),
        ],
        if (late.isNotEmpty && _amounts) ...[
          ForgeSectionPill(items: [['${late.length} הסדר-בפיגור: ${late.map((f) => f['name']).join(' · ')}']], variants: const <int>[0]),
          _gap(8),
        ],
        if (dups.isNotEmpty && _amounts) ...[
          ForgeSectionPill(items: [['חיוב-כפול-חשוד (אותו סוג·סכום·תאריך·תלמיד): ${dups.map((f) => '${f['name']} (${_FeesData.duplicateCharges(f).map((c) => c['cat']).join(',')})').join(' · ')}']], variants: const <int>[0]),
          _gap(8),
        ],
        if (tripDebt.isNotEmpty && _amounts) ...[
          ForgeSectionPill(items: [['חוב לפני-טיול (התרעה-מוקדמת, לא-מניעה): ${tripDebt.map((f) => f['name']).join(' · ')}']], variants: const <int>[0]),
          _gap(8),
        ],
        if (follow.isNotEmpty && _FeesData.can(_role, 'fees.remind')) ...[
          ForgeSectionPill(items: [['מעקב שעבר-מועד: ${follow.map((t) => t['title']).join(' · ')}']], variants: const <int>[0]),
          _gap(8),
        ],
        if (hokDue.isNotEmpty && _FeesData.can(_role, 'fees.hok')) ...[
          ForgeSectionPill(items: [['${hokDue.length} הו״ק לרישום החודש (${_m(_FeesData.hokExpected(all))}) — ראה מבט הו״ק']], variants: const <int>[0]),
          _gap(8),
        ],
        // בורר-מבט (SegmentedSwitch מבוקר)
        if (_amounts)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in const ['🎯 חייבים', '📋 טבלה', '💳 הו״ק', '🔔 תזכורות', '📊 דוחות', '🧾 אודיט']) [s]], selected: {_mode}, onSelect: (i) => setState(() => _mode = i)),
          ),
        const SizedBox(height: 10),
        // מצבי-מסך שמורים: טעינה · שגיאה · ריק
        if (_loading)
          _loadingView()
        else if (_error != null)
          ForgeSectionPill(items: [[_error!]], variants: const <int>[0])
        else if (_mode == 2 && _amounts)
          _hokView(all, hokDue)
        else if (_mode == 3 && _amounts)
          _remindersView(visible)
        else if (_mode == 4 && _amounts)
          _reportsView(all, trend, thisMonth)
        else if (_mode == 5 && _amounts)
          _auditView()
        else if (all.isEmpty)
          const Padding(padding: EdgeInsets.only(top: 24), child: ForgeSearchEmptyState(fields: ['אין משפחות/חיובים — התחל בחיוב-שנה', '']))
        else if (visible.isEmpty)
          const Padding(padding: EdgeInsets.only(top: 24), child: ForgeSearchEmptyState(fields: ['אין משפחות תואמות לחיפוש/סינון', '']))
        else if (_mode == 1 && _amounts)
          _table(visible)
        else
          for (final st in const [2, 1, 0, -1])
            if (buckets[st]!.isNotEmpty)
              ForgeTitledSection(fields: ['${secTitle[st]} · ${buckets[st]!.length}', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[
                for (final f in buckets[st]!) _row(f),
              ]])),
      ]]);
  }

  Widget _enum(String label, List<String> options, String value, void Function(String) on) => SizedBox(
        width: 170,
        child: ForgeDsEnumField(fields: [label], control: DsEnumField(label: label, options: options, value: value, onChanged: on, bare: true)),
      );

  void _refresh() {
    setState(() { _loading = true; _error = null; });
    Future.delayed(const Duration(milliseconds: 700), () { if (mounted) setState(() => _loading = false); });
  }

  Widget _loadingView() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
          CircularProgressIndicator(color: _acc),
          const SizedBox(height: 14),
          const Text('טוען גבייה…', style: TextStyle(color: _muted, fontSize: 14)),
        ]),
      );

  // 📋 טבלה מונחית-חוזה (columnDefs · מקום-שמור): עמודות-נגזרות תמיד, שדות-שער-חיצוני מוארים כשיש נתון
  Widget _table(List<Map<String, dynamic>> rows) {
    final cols = [for (final c in _FeesData.columnDefs) if (_FeesData.colShown(c, rows)) c];
    final labels = [for (final c in cols) c['label'] as String];
    final data = <List<String>>[
      for (final f in rows)
        [
          for (final c in cols)
            if (c['money'] == true && !_amounts)
              '🔒'
            else if (c['get'] != null)
              (c['get'] as String Function(Map<String, dynamic>))(f)
            else
              '${f[c['key']] ?? '—'}',
        ],
    ];
    return ForgeDataGrid(bare: true, columns: labels, items: data);
  }

  // ═══ שורת-משפחה (טריאז'): זהות ⊕ יחס-שולם (StatRow) ⊕ BareStat×3 ⊕ facts ⊕ הפעולה-הנכונה (AlertBanner) ═══
  Widget _row(Map<String, dynamic> f) {
    final charged = _FeesData.charged(f), paid = _FeesData.paid(f), bal = _FeesData.balance(f);
    final band = _FeesData.agingBand(f);
    final act = _FeesData.rightAction(f);
    final balColor = band == 3 ? _danger : band == 2 ? _warning : band == 1 ? _acc : _ok;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ForgeStripPanelFrame(fields: ['', ''], child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: ForgeContactTile(fields: [f['name'] as String, '${_FeesData.studentsOf(f)} · ${_FeesData.gradesOf(f)}'])),
            IconButton(onPressed: () => _openPanel(f), icon: const Icon(Icons.chevron_left, color: _acc, size: 26), tooltip: 'פאנל משפחה'),
          ]),
          _gap(8),
          if (_amounts) ...[
            ForgeLinearProgressStatus(fields: ['שולם מתוך חיובים', '${shekel(paid)} / ${shekel(charged)}'], values: [charged == 0 ? (paid > 0 ? 1 : 0) : paid / charged]),
            _gap(8),
            Row(children: [
              Expanded(child: ForgeStatPlain(fields: ['חיובים', shekel(charged)])),
              Expanded(child: ForgeStatPlain(fields: ['שולם', shekel(paid)])),
              Expanded(child: ForgeStatPlain(fields: [bal > 0 ? '= יתרה · ${_FeesData.agingDays(f)} י׳' : '= יתרה', shekel(bal)])),
            ]),
          ] else
            Row(children: [
              Expanded(child: ForgeStatPlain(fields: [bal > 0 ? 'דגל-חוב (ללא-סכום)' : 'תקין', bal > 0 ? '🚩' : '✅'])),
            ]),
          if (_amounts) ...[
            _wrap(_facts(f)),
            _gap(8),
            ForgeSectionPill(items: [[act['text'] as String]], variants: [const <int>[0, 0, 0, 0][(act['tone'] as int) % 4]]),
          ],
        ])),
    );
  }

  // עובדות-שבב (אטום-יחיד לגיטימי): סטטוס · הו״ק · הנחה · תזכורות · סיכון · אמצעי
  List<Widget> _facts(Map<String, dynamic> f) {
    final r = _FeesData.risk(f);
    return [
      ForgeStatusChip(items: [[_FeesData.statusOf(f)]], variants: [const <int>[0, 1, 3, 2][(_FeesData.statusOf(f) == 'תקין' || _FeesData.statusOf(f) == 'מלגה-מלאה' ? 1 : _FeesData.statusOf(f).contains('פיגור') ? 2 : 3) % 4]]),
      if (_FeesData.hasHok(f)) ForgeStatusChip(items: [[_FeesData.hokFlag(f) ? (_FeesData.hokActive(f) ? '💳 הו״ק ${_amounts ? shekel((f['hok'] as Map)['amount'] as num) : ''} · יום ${(f['hok'] as Map)['day']}' : '⚠️ הו״ק נכשלה') : '⏸ הו״ק מופסקת']], variants: [const <int>[0, 1, 3, 2][(_FeesData.hokFailed(f) ? 2 : _FeesData.hokFlag(f) ? 1 : 0) % 4]]),
      if (_FeesData.discountLabel(f).isNotEmpty) ForgeStatusChip(items: [['🎓 ${_FeesData.discountLabel(f)}']], variants: const <int>[0]),
      if (_FeesData.remindersSent(f).isNotEmpty) ForgeStatusChip(items: [['🔔 ${_FeesData.remindersSent(f).length} תזכורות']], variants: [const <int>[0, 1, 3, 2][(_FeesData.remindersSent(f).length > 2 ? 3 : 0) % 4]]),
      if (_FeesData.balance(f) > 0) ForgeStatusChip(items: [['סיכון ${_FeesData.riskLabel(r)} · ${_FeesData.tierLabel(f)}']], variants: [const <int>[0, 1, 3, 2][(r == 2 ? 2 : r == 1 ? 3 : 1) % 4]]),
      if (_FeesData.lastMethod(f).isNotEmpty) ForgeStatusChip(items: [['${_FeesData.lastMethod(f)} · ${fmtDate(_FeesData.lastPaymentDate(f))}']], variants: const <int>[0]),
      if (f['nextNote'] != null) ForgeStatusChip(items: [['📝 ${f['nextNote']}']], variants: const <int>[0]),
    ];
  }

  // ═══ 💳 מבט-הו״ק: תור-לרישום-החודש (hokDue) + רישום-מרוכז דו-שלבי + מצב-כל-ההו״ק ═══
  Widget _hokView(List<Map<String, dynamic>> all, List<Map<String, dynamic>> due) {
    final withHok = all.where(_FeesData.hasHok).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ForgeTitledSection(fields: ['💳 הו״ק לרישום החודש · ${due.length} · ${_m(_FeesData.hokExpected(all))}', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[
        if (due.isEmpty)
          ForgeSearchEmptyState(fields: ['כל ההו״ק הפעילות נרשמו החודש', ''])
        else ...[
          for (final f in due)
            ForgeNotifRow(items: [['${f['name']} · יום ${(f['hok'] as Map)['day']}', _FeesData.hokMethod(f)]]),
          if (_FeesData.can(_role, 'fees.hok')) ...[
            _gap(8),
            // אישור-דו-שלבי: שלב-1 חימוש (הצגת-סיכום) · שלב-2 ביצוע (SoftButton danger) · ביטול
            if (!_hokArmed)
              _wrap([GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _hokArmed = true), child: ForgeSoftButton(fields: ['🧾 רישום-הו״ק-חודשי-מרוכז']))], top: 0)
            else ...[
              ForgeSectionPill(items: [['שלב 2/2: יירשמו ${due.length} תשלומי-הו״ק בסך ${_m(_FeesData.hokExpected(all))} (${due.map((f) => f['name']).join(' · ')}). לאשר?']], variants: const <int>[0]),
              _wrap([
                GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() { _FeesData.runHokBatch(all, _roleName); _hokArmed = false; }), child: ForgeSoftButton(fields: ['✅ אשר ורשום ${due.length}'])),
                GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _hokArmed = false), child: ForgeSoftButton(fields: ['בטל'])),
              ], top: 8),
            ],
          ],
        ],
      ]])),
      ForgeTitledSection(fields: ['📇 כל הוראות-הקבע · ${withHok.length}', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[
        for (final f in withHok)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              StatusDot(tone: _FeesData.hokFailed(f) ? 2 : _FeesData.hokFlag(f) ? 1 : 3),
              const SizedBox(width: 10),
              Expanded(child: ForgeContactTile(fields: [f['name'] as String, '${_m((f['hok'] as Map)['amount'] as num)} · יום ${(f['hok'] as Map)['day']} · ${_FeesData.hokMethod(f)} · מ-${fmtDate((f['hok'] as Map)['startedAt'] as String?)}'])),
              Flexible(child: ForgeStatusChip(items: [[_FeesData.hokFailed(f) ? 'נכשלה' : _FeesData.hokFlag(f) ? (_FeesData.hokRecorded(f) ? 'נרשמה החודש' : 'ממתינה') : 'מופסקת']], variants: [const <int>[0, 1, 3, 2][(_FeesData.hokFailed(f) ? 2 : _FeesData.hokFlag(f) ? 1 : 0) % 4]])),
              if (_FeesData.can(_role, 'fees.hok')) ...[
                const SizedBox(width: 8),
                GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _FeesData.toggleHok(f, _roleName)), child: ForgeSoftButton(fields: [_FeesData.hokFlag(f) ? '⏸ הפסק' : '▶ הפעל'])),
              ],
            ]),
          ),
        if (withHok.isEmpty) ForgeSearchEmptyState(fields: ['אין הוראות-קבע', '']),
      ]])),
    ]);
  }

  // ═══ 🔔 מבט-תזכורות: תזכורת-מדורגת פר-משפחה (segulaReminders) + נוסח (waPaymentText) — פרטי, לא פומבי ═══
  Widget _remindersView(List<Map<String, dynamic>> fs) {
    final due = fs.where((f) => _FeesData.nextReminder(f) != null).toList();
    final sentAll = [for (final f in fs) for (final c in _FeesData.remindersSent(f)) {'f': f, 'c': c}]..sort((a, b) => '${(b['c'] as Map)['at']}'.compareTo('${(a['c'] as Map)['at']}'));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ForgeSectionPill(items: [['מגן-כבוד: תזכורות פרטיות בלבד · אין תזכורת פומבית · אין חסימת-תלמיד · מלגה-מלאה = אפס-תזכורות']], variants: const <int>[0]),
      _gap(8),
      ForgeTitledSection(fields: ['🔔 מועד-תזכורת הגיע · ${due.length}', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[
        if (due.isEmpty)
          ForgeSearchEmptyState(fields: ['אין תזכורות שמועדן הגיע', ''])
        else
          for (final f in due) _reminderCard(f),
      ]])),
      ForgeTitledSection(fields: ['📜 היסטוריית-תזכורות · ${sentAll.length}', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[
        if (sentAll.isEmpty) ForgeSearchEmptyState(fields: ['טרם נשלחו תזכורות', '']) else
          for (final x in sentAll)
            ForgeNotifRow(items: [['${(x['f'] as Map)['name']} · ${(x['c'] as Map)['grade'] ?? 'תזכורת'}', fmtDate((x['c'] as Map)['at'] as String?)]]),
      ]])),
    ]);
  }

  Widget _reminderCard(Map<String, dynamic> f) {
    final nr = _FeesData.nextReminder(f)!;
    final grade = nr['grade'] as String;
    final plan = _FeesData.reminderPlan(f);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ForgeContactTile(fields: ['${f['name']} · דרגה: $grade', 'יתרה ${_m(_FeesData.balance(f))} · ותק ${_FeesData.agingDays(f)} י׳ · נשלחו ${_FeesData.remindersSent(f).length}']),
        _wrap([for (final p in plan) ForgeStatusChip(items: [['${p['grade']} · ${fmtDate(p['date'] as String?)}']], variants: [const <int>[0, 1, 3, 2][(p['grade'] == grade ? 3 : 0) % 4]])]),
        if (_amounts) ...[
          _gap(6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF0C0D1E), borderRadius: BorderRadius.circular(10)),
            child: SelectableText(_FeesData.reminderText(f, grade), style: const TextStyle(color: _ink, fontSize: 12.5, height: 1.5)),
          ),
        ],
        if (_FeesData.can(_role, 'fees.remind'))
          _wrap([GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _FeesData.sendReminder(f, _roleName, grade)), child: ForgeSoftButton(fields: ['📨 שלח תזכורת $grade (פרטי)']))], top: 8),
      ]),
    );
  }

  // ═══ 📊 דוחות: מגמת-גבייה (TrendStat⊕trendFromScan) · פירוק-סטטוס (DsBars⊕countBy) · דוח-גזבר-שבועי · סוף-שנה ═══
  Widget _reportsView(List<Map<String, dynamic>> all, Map<String, dynamic> trend, int thisMonth) {
    final counts = _FeesData.statusCounts(all);
    final t = DateTime.parse('${_FeesData.today}T12:00:00');
    final wa = DateTime(t.year, t.month, t.day - 7); // חשבון-תאריך אמיתי (חוצה-חודש) — לא clamp בתוך החודש
    final weekAgo = '${_FeesData.ymOf(wa)}-${wa.day.toString().padLeft(2, '0')}';
    final weekPaid = grandTotal([for (final f in all) for (final p in _FeesData.paymentsOf(f)) if (dateInRange(p['date'] as String, weekAgo, _FeesData.today)) p['amount']], (x) => x as num).toInt();
    final weekRem = grandTotal([for (final f in all) for (final c in _FeesData.remindersSent(f)) if (dateInRange(c['at'] as String, weekAgo, _FeesData.today)) 1], (x) => x as num).toInt();
    final byType = <String, int>{};
    for (final f in all) {
      _FeesData.byType(f).forEach((k, v) => byType[k] = (byType[k] ?? 0) + v);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: TrendStat(value: _m(thisMonth), delta: (trend['pct'] as num).toDouble(), label: 'נגבה החודש · מגמה מול חצי-שנה')),
      ]),
      _gap(10),
      if (_amounts) ForgeBarChart(fields: ['חיובים לפי-סוג', ''], values: (() { final _vs = [for (final v in byType.values) v.toDouble()]; final _m = _vs.fold<double>(0.0, (a, b) => a > b ? a : b); return [for (final v in _vs) _m == 0 ? 0.0 : v / _m]; })()),
      _gap(10),
      ForgeBarChart(fields: ['משפחות לפי-סטטוס', ''], values: (() { final _vs = [for (final c in counts) (c[1] as int).toDouble()]; final _m = _vs.fold<double>(0.0, (a, b) => a > b ? a : b); return [for (final v in _vs) _m == 0 ? 0.0 : v / _m]; })()),
      _gap(10),
      ForgeTitledSection(fields: ['🗓 דוח-גזבר שבועי · מ-${fmtDate(weekAgo)} עד ${fmtDate(_FeesData.today)}', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[
        Row(children: [
          Expanded(child: ForgeStatPlain(fields: ['נגבה השבוע', _m(weekPaid)])),
          Expanded(child: ForgeStatPlain(fields: ['תזכורות השבוע', '$weekRem'])),
          Expanded(child: ForgeStatPlain(fields: ['הו״ק נכשלו', '${all.where(_FeesData.hokFailed).length}'])),
          Expanded(child: ForgeStatPlain(fields: ['חוב-ותיק', '${all.where(_FeesData.oldDebt).length}'])),
        ]),
      ]])),
      ForgeTitledSection(fields: ['🏁 סוף-שנה · סגירת-חשבונות', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[
        Row(children: [
          Expanded(child: ForgeStatPlain(fields: ['משפחות סגורות', '${all.where((f) => _FeesData.balance(f) <= 0).length}/${all.length}'])),
          Expanded(child: ForgeStatPlain(fields: ['יתרה להעברה (carryBalance)', _m(_FeesData.kOpen(all))])),
          Expanded(child: ForgeStatPlain(fields: ['זכויות להחזר', _m(grandTotal(all, (f) => _FeesData.credit(f as Map<String, dynamic>)))])),
        ]),
        ForgeSectionPill(items: [['סגירת-שנה = העברת-יתרות ל-carryBalance של השנה-הבאה (מקום-שמור: פעולת-סוף-שנה נעולה עד אישור-הנהלה)']], variants: const <int>[0]),
      ]])),
      // מקום-שמור: התאמת-תשלומים-נכנסים (matching · strongMatchForCharge) — השער-החיצוני יזין את הרשימה
      ForgeTitledSection(fields: ['🔗 התאמת-תשלומים-נכנסים לחיוב (שער-חיצוני · מקום-שמור)', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[
        for (final inc in _FeesData.incoming)
          () {
            final m = _FeesData.matchIncoming(inc, all);
            return ForgeNotifRow(items: [[m == null ? '❓ ${inc['name']} — ללא-התאמה (ידני)' : '✅ ${inc['name']} — הותאם: ${m['name']}', fmtDate(inc['date'] as String?)]]);
          }(),
      ]])),
    ]);
  }

  // ═══ 🧾 אודיט: כל פעולה (מי·מה·מתי) — TimelineItem ═══
  Widget _auditView() => ForgeTitledSection(fields: ['🧾 יומן-אודיט · ${_FeesData.audit.length}', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[
        if (_FeesData.audit.isEmpty)
          ForgeSearchEmptyState(fields: ['אין פעולות עדיין — כל חיוב/תשלום/ביטול/הנחה/תזכורת יירשם כאן', ''])
        else
          for (final a in _FeesData.audit)
            ForgeNotifRow(items: [['${a['role']} · ${a['family'] == '*' ? 'כלל-המערכת' : _FeesData.families.firstWhere((f) => f['id'] == a['family'], orElse: () => const {'name': '?'})['name']}', fmtDate(a['date'] as String?)]]),
      ]]));

  // ═══ פאנל משפחה-נבחרת (GlassCard · bottom-sheet): זהות · יתרה (צבועה-לפי-ותק) · פירוק · טאבים-9 · הפעולה-הנכונה · פעולות ═══
  void _openPanel(Map<String, dynamic> f) {
    var tab = 0;
    if (!_amounts) { // דגל-בלבד: פאנל מצומצם (זהות + דגל + הפניה) — אפס-פרטי-חוב
      showModalBottomSheet<void>(
        context: context, backgroundColor: Colors.transparent,
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(12),
          child: ForgeStripPanelFrame(fields: ['', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              ForgeContactTile(fields: [f['name'] as String, '${_FeesData.studentsOf(f)} · ${_FeesData.gradesOf(f)}']),
              _gap(10),
              ForgeSectionPill(items: [[_FeesData.balance(f) > 0 ? 'דגל-חוב — פרטים וסכומים בגזברות בלבד. לא לפנות לתלמיד/ה (מגן-כבוד).' : 'תקין — אין דגל-חוב']], variants: [const <int>[0, 0, 0, 0][(_FeesData.balance(f) > 0 ? 3 : 1) % 4]]),
            ])),
        ),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        void act(void Function() fn) { fn(); setSheet(() {}); setState(() {}); }
        final charged = _FeesData.charged(f), paid = _FeesData.paid(f), bal = _FeesData.balance(f), band = _FeesData.agingBand(f);
        final balColor = band == 3 ? _danger : band == 2 ? _warning : band == 1 ? _acc : _ok;
        final actn = _FeesData.rightAction(f);
        return DraggableScrollableSheet(
          initialChildSize: 0.85, minChildSize: 0.4, maxChildSize: 0.97, expand: false,
          builder: (ctx, scroll) => Padding(
            padding: const EdgeInsets.all(12),
            child: ForgeStripPanelFrame(fields: ['', ''], child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
                ForgeContactTile(fields: [f['name'] as String, '${f['payer']} · ${f['phone']} · ${_FeesData.studentsOf(f)} (${_FeesData.gradesOf(f)})']),
                _gap(10),
                Row(children: [
                  Expanded(child: ForgeStatPlain(fields: [bal > 0 ? 'יתרה · ותק ${_FeesData.agingDays(f)} י׳' : 'יתרה', _m(bal)])),
                  Expanded(child: ForgeStatPlain(fields: ['חיובים', _m(charged)])),
                  Expanded(child: ForgeStatPlain(fields: ['שולם', _m(paid)])),
                  if (_FeesData.credit(f) > 0) Expanded(child: ForgeStatPlain(fields: ['זכות', _m(_FeesData.credit(f))])),
                ]),
                _gap(8),
                ForgeSectionPill(items: [['הפעולה-הנכונה: ${actn['text']}']], variants: [const <int>[0, 0, 0, 0][(actn['tone'] as int) % 4]]),
                _gap(10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in const ['סקירה', 'חיובים', 'תשלומים', 'הו״ק', 'תזכורות', 'הנחות', 'הסדר', 'דוחות', 'אודיט']) [s]], selected: {tab}, onSelect: (i) => setSheet(() => tab = i)),
                ),
                _gap(10),
                ...switch (tab) {
                  1 => _tabCharges(f, act),
                  2 => _tabPayments(f),
                  3 => _tabHok(f, act),
                  4 => _tabReminders(f, act),
                  5 => _tabDiscounts(f, act),
                  6 => _tabArrangement(f, act),
                  7 => _tabStatement(f),
                  8 => _tabAudit(f),
                  _ => _tabOverview(f, charged, paid, bal),
                },
                _gap(14),
                const Text('פעולות', style: TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800)),
                _gap(8),
                Builder(builder: (_) {
                  final acts = <Widget>[
                    if (_FeesData.can(_role, 'fees.charge')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openChargeForm(f, [f], onDone: () => setSheet(() {})), child: ForgeSoftButton(fields: ['➕ חיוב'])),
                    if (_FeesData.can(_role, 'fees.pay')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openPaymentForm(f, [f], onDone: () => setSheet(() {})), child: ForgeSoftButton(fields: ['💳 רשום תשלום'])),
                    if (_FeesData.can(_role, 'fees.pay') && bal > 0) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _FeesData.addPayment(f, _roleName, amount: (bal / 2).ceil(), method: 'מזומן', date: _FeesData.today, note: 'תשלום-חלקי')), child: ForgeSoftButton(fields: ['➗ תשלום-חלקי (½)'])),
                    if (_FeesData.can(_role, 'fees.remind') && _FeesData.nextReminder(f) != null) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _FeesData.sendReminder(f, _roleName, _FeesData.nextReminder(f)!['grade'] as String)), child: ForgeSoftButton(fields: ['📨 תזכורת ${_FeesData.nextReminder(f)!['grade']}'])),
                    if (_FeesData.can(_role, 'fees.arrangement') && bal > 0 && !_FeesData.hasArrangement(f)) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _FeesData.setArrangement(f, _roleName, 3)), child: ForgeSoftButton(fields: ['📆 הסדר 3 תשלומים'])),
                    if (_FeesData.can(_role, 'fees.hok') && _FeesData.hasHok(f)) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _FeesData.toggleHok(f, _roleName)), child: ForgeSoftButton(fields: [_FeesData.hokFlag(f) ? '⏸ הפסק הו״ק' : '▶ הפעל הו״ק'])),
                    if (_FeesData.can(_role, 'fees.writeoff') && bal > 0 && _FeesData.oldDebt(f)) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _FeesData.writeOff(f, _roleName)), child: ForgeSoftButton(fields: ['🗂 סמן חוב-אבוד'])),
                    if (_FeesData.can(_role, 'fees.refund') && _FeesData.credit(f) > 0) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _FeesData.refund(f, _roleName)), child: ForgeSoftButton(fields: ['💸 החזר-זכות ${_m(_FeesData.credit(f))}'])),
                    if ((_FeesData.can(_role, 'fees.pay') || _FeesData.can(_role, 'fees.self')) && bal > 0)
                      // שער-חיצוני (מקום-שמור): payLink מחזיר null כש-payUrl ריק ⇒ הכפתור שמור, לא מזייף קישור
                      GestureDetector(behavior: HitTestBehavior.opaque, onTap: _FeesData.payLinkOf(f) == null ? null : () {}, child: ForgeSoftButton(fields: [_FeesData.payLinkOf(f) == null ? '🔗 קישור-תשלום (שער לא-מוגדר)' : '🔗 שלח קישור-תשלום'])),
                    GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setSheet(() => tab = 7), child: ForgeSoftButton(fields: ['🖨 מצב-חשבון'])),
                  ];
                  return acts.isEmpty
                      ? ForgeSectionPill(items: [['צפייה-בלבד — אין הרשאת-פעולה']], variants: const <int>[0])
                      : Wrap(spacing: 8, runSpacing: 8, children: acts);
                }),
              ])),
          ),
        );
      }),
    );
  }

  // סקירה: השוואה (NeonBars) · יחס (StatRow) · פירוק-לפי-סוג (DsBars) · תלמידים · מדדי-דפוס (RFM·מגמה)
  List<Widget> _tabOverview(Map<String, dynamic> f, int charged, int paid, int bal) => [
        if (_amounts) ...[
          ForgeBarChart(fields: ['', ''], values: (() { final _vs = [charged.toDouble(), paid.toDouble(), bal.toDouble()]; final _m = _vs.fold<double>(0.0, (a, b) => a > b ? a : b); return [for (final v in _vs) _m == 0 ? 0.0 : v / _m]; })()),
          _gap(8),
          ForgeLinearProgressStatus(fields: ['שולם מתוך חיובים', '${shekel(paid)} / ${shekel(charged)}'], values: [charged == 0 ? 0 : paid / charged]),
          _gap(8),
          if (_FeesData.byType(f).isNotEmpty) ForgeBarChart(fields: ['פירוק-חיובים לפי-סוג', ''], values: (() { final _vs = [for (final v in _FeesData.byType(f).values) v.toDouble()]; final _m = _vs.fold<double>(0.0, (a, b) => a > b ? a : b); return [for (final v in _vs) _m == 0 ? 0.0 : v / _m]; })()),
        ],
        _wrap([for (final m in f['members'] as List) ForgeStatusChip(items: [['🎓 ${(m as Map)['first']} · ${m['grade']}']], variants: const <int>[0])]),
        _wrap(_facts(f)),
        _gap(8),
        Row(children: [
          Expanded(child: ForgeStatPlain(fields: ['דפוס-תשלום (RFM) · ${_FeesData.tierLabel(f)}', '${_FeesData.rfm(f)}'])),
          Expanded(child: ForgeStatPlain(fields: ['מגמת-תשלומים (6 חודשים)', '${_FeesData.trend(f)['dir'] == 'up' ? '↑' : _FeesData.trend(f)['dir'] == 'down' ? '↓' : '→'} ${_FeesData.trend(f)['pct']}%'])),
          Expanded(child: ForgeStatPlain(fields: ['סיכון-גבייה (ותק · דפוס · מגמה)', _FeesData.riskLabel(_FeesData.risk(f))])),
        ]),
      ];

  // חיובים: פירוט (סוג/סכום/תאריך/עבור-מי) + ביטול (סיבה) + כפולים
  List<Widget> _tabCharges(Map<String, dynamic> f, void Function(void Function()) act) {
    final cs = _FeesData.chargesOf(f);
    final dups = _FeesData.duplicateCharges(f).map((c) => c['id']).toSet();
    return [
      if (cs.isEmpty) ForgeSearchEmptyState(fields: ['אין חיובים למשפחה — לרשום חיוב-שנה', '']),
      for (final c in cs)
        () {
          final cancelled = c['cancelledAt'] != null || _FeesData.cancelledIds.contains(c['id']);
          final net = _FeesData.netOf(f, c), gross = _FeesData.grossOf(f, c);
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            ForgeNotifRow(items: [['${cancelled ? '🚫 ' : dups.contains(c['id']) ? '👯 ' : ''}${c['cat']} · ${c['memberId']}${c['installmentOf'] != null ? ' · הסדר' : ''}', fmtDate(c['date'] as String?)]]),
            if (!cancelled && _FeesData.can(_role, 'fees.writeoff'))
              _wrap([GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _FeesData.cancelCharge(f, _roleName, c, dups.contains(c['id']) ? 'חיוב-כפול' : 'ביטול-ידני')), child: ForgeSoftButton(fields: ['✖ בטל חיוב']))], top: 2),
          ]);
        }(),
    ];
  }

  // תשלומים: ציר (TimelineItem) + שדות-מטא-שמורים (קבלה/סליקה/חשבונית — מאירים כשיש)
  List<Widget> _tabPayments(Map<String, dynamic> f) {
    final ps = [..._FeesData.paymentsOf(f)]..sort((a, b) => '${b['date']}'.compareTo('${a['date']}'));
    return [
      if (ps.isEmpty) ForgeSearchEmptyState(fields: ['אין תשלומים רשומים', '']),
      for (final p in ps)
        ForgeNotifRow(items: [['${p['method']}${p['method'] == 'הו״ק' ? ' 💳' : ''}', fmtDate(p['date'] as String?)]]),
      ForgeSectionPill(items: [['קבלת-מס / אישור-סליקה / חשבונית = שער-חיצוני (מקום-שמור: מס׳-קבלה יואר כאן כשיגיע מהשער; המסך אינו מנפיק)']], variants: const <int>[0]),
    ];
  }

  // הו״ק: מצב-החודש (hokEffectivelyActive⊕hokRecordedThisMonth) + היסטוריית-סליקה + הפעל/הפסק
  List<Widget> _tabHok(Map<String, dynamic> f, void Function(void Function()) act) {
    if (!_FeesData.hasHok(f)) return [ForgeSearchEmptyState(fields: ['אין הוראת-קבע למשפחה (מקום-שמור: תוגדר בשער-הסליקה)', ''])];
    final h = f['hok'] as Map;
    final hist = (f['hist'] as List?) ?? const [];
    return [
      Row(children: [
        StatusDot(tone: _FeesData.hokFailed(f) ? 2 : _FeesData.hokFlag(f) ? 1 : 3),
        const SizedBox(width: 10),
        Expanded(child: ForgeContactTile(fields: ['${_m(h['amount'] as num)} · יום ${h['day']} בחודש', '${_FeesData.hokMethod(f)} · מ-${fmtDate(h['startedAt'] as String?)}${h['kevaId'] != null ? ' · סליקה ${h['kevaId']}' : ' · ידנית'}'])),
      ]),
      _wrap([
        ForgeStatusChip(items: [[_FeesData.hokFlag(f) ? 'מסומנת פעילה' : 'מופסקת']], variants: [const <int>[0, 1, 3, 2][(_FeesData.hokFlag(f) ? 1 : 0) % 4]]),
        ForgeStatusChip(items: [[_FeesData.hokActive(f) ? 'סליקה חיה' : 'סליקה פסקה >2 חודשים']], variants: [const <int>[0, 1, 3, 2][(_FeesData.hokActive(f) ? 1 : 2) % 4]]),
        ForgeStatusChip(items: [[_FeesData.hokRecorded(f) ? 'נרשמה החודש ✅' : 'טרם נרשמה החודש']], variants: [const <int>[0, 1, 3, 2][(_FeesData.hokRecorded(f) ? 1 : 3) % 4]]),
      ]),
      if (_FeesData.hokFailed(f)) ...[
        _gap(6),
        ForgeSectionPill(items: [['הו״ק נכשלה — התרעה נשלחה; ניסיון-חיוב-חוזר = שער-הסליקה (מקום-שמור). בינתיים: תזכורת עדינה']], variants: const <int>[0]),
      ],
      _gap(6),
      Text('היסטוריית-סליקה · ${hist.length}', style: const TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800)),
      for (final e in hist) ForgeNotifRow(items: [['${(e as Map)['clearer']}', fmtDate(e['d'] as String?)]]),
      if (hist.isEmpty) ForgeSearchEmptyState(fields: ['אין היסטוריית-סליקה (הו״ק ידנית)', '']),
    ];
  }

  // תזכורות: לוח-מדורג + היסטוריה + תגובה (nextNote)
  List<Widget> _tabReminders(Map<String, dynamic> f, void Function(void Function()) act) {
    final plan = _FeesData.reminderPlan(f), sent = _FeesData.remindersSent(f), nr = _FeesData.nextReminder(f);
    return [
      if (_FeesData.fullScholarship(f)) ForgeSectionPill(items: [['מלגה מלאה — אפס-תזכורות (מגן-כבוד)']], variants: const <int>[0]) else if (plan.isEmpty) ForgeSearchEmptyState(fields: ['אין חוב פתוח — אין לוח-תזכורות', '']) else ...[
        Text('לוח מדורג (מהחיוב-הפתוח-הוותיק ${fmtDate(_FeesData.oldestOpenDate(f))})', style: const TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800)),
        _wrap([for (var i = 0; i < plan.length; i++) ForgeStatusChip(items: [['${i < sent.length ? '✅' : '${plan[i]['date']}'.compareTo(_FeesData.today) <= 0 ? '⏰' : '⏳'} ${plan[i]['grade']} · ${fmtDate(plan[i]['date'] as String?)}']], variants: [const <int>[0, 1, 3, 2][(i < sent.length ? 1 : nr != null && nr['grade'] == plan[i]['grade'] ? 3 : 0) % 4]])]),
        if (nr != null && _FeesData.can(_role, 'fees.remind')) _wrap([GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _FeesData.sendReminder(f, _roleName, nr['grade'] as String)), child: ForgeSoftButton(fields: ['📨 שלח תזכורת ${nr['grade']} (פרטי)']))], top: 8),
      ],
      _gap(8),
      Text('היסטוריה · ${sent.length}', style: const TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800)),
      for (final c in sent) ForgeNotifRow(items: [['תזכורת ${c['grade'] ?? ''}', fmtDate(c['at'] as String?)]]),
      if (f['nextNote'] != null) ForgeSectionPill(items: [['תגובה/מעקב: ${f['nextNote']} (${fmtDate(f['nextDate'] as String?)})']], variants: const <int>[0]),
    ];
  }

  // הנחות-ומלגות: מדיניות (maxDiscountPct הגבוה-מנצח) · הענקה (הנהלה)
  List<Widget> _tabDiscounts(Map<String, dynamic> f, void Function(void Function()) act) {
    final ids = _FeesData.effectiveCriteria(f);
    return [
      Row(children: [
        Expanded(child: ForgeStatPlain(fields: ['הנחה אפקטיבית (הגבוהה מנצחת)', '${_FeesData.discountPct(f)}%'])),
        Expanded(child: ForgeStatPlain(fields: ['שווי-ההנחה השנה', _m(_FeesData.scholarshipOf(f))])),
        Expanded(child: ForgeStatPlain(fields: ['אחים (הנחת-אחים אוטו)', '${_FeesData.studentsN(f)}'])),
      ]),
      _wrap([for (final c in _FeesData.criteria) ForgeStatusChip(items: [['${ids.contains(c['id']) ? '✅ ' : ''}${c['label']} ${c['discountPct']}%']], variants: [const <int>[0, 1, 3, 2][(ids.contains(c['id']) ? 1 : 0) % 4]])]),
      if (_FeesData.can(_role, 'fees.scholarship'))
        _wrap([for (final c in _FeesData.criteria) if (!ids.contains(c['id'])) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _FeesData.grantDiscount(f, _roleName, c['id'] as String)), child: ForgeSoftButton(fields: ['🎓 הענק ${c['label']}']))], top: 8)
      else
        ForgeSectionPill(items: [['הענקת-מלגה/הנחה = הרשאת-הנהלה']], variants: const <int>[0]),
    ];
  }

  // הסדר: פריסה (installmentOf) · מצב-כל-תשלום · פיגור
  List<Widget> _tabArrangement(Map<String, dynamic> f, void Function(void Function()) act) {
    final ins = _FeesData.installments(f);
    return [
      if (ins.isEmpty) ...[
        ForgeSearchEmptyState(fields: ['אין הסדר-תשלומים', '']),
        if (_FeesData.can(_role, 'fees.arrangement') && _FeesData.balance(f) > 0)
          _wrap([for (final n in const [2, 3, 6]) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _FeesData.setArrangement(f, _roleName, n)), child: ForgeSoftButton(fields: ['📆 פריסה ל-$n']))], top: 4),
      ] else ...[
        if (_FeesData.arrangementLate(f)) ForgeSectionPill(items: [['הסדר בפיגור — תשלום שמועדו עבר לא כוסה']], variants: const <int>[0]),
        for (final c in ins)
          ForgeNotifRow(items: [['${c['note'] ?? 'תשלום-הסדר'}', fmtDate(c['date'] as String?)]]),
      ],
    ];
  }

  // מצב-חשבון (הדפסה = מקום-שמור): שורות-אמת להעתקה
  List<Widget> _tabStatement(Map<String, dynamic> f) {
    final lines = <String>[
      'מצב-חשבון · ${f['name']} · ${_FeesData.orgName} · ${fmtDate(_FeesData.today)}',
      'הורה-משלם: ${f['payer']} · ${f['phone']}',
      'תלמידים: ${_FeesData.studentsOf(f)} (${_FeesData.gradesOf(f)})',
      '',
      'חיובים:',
      for (final c in _FeesData.liveCharges(f)) '  ${fmtDate(c['date'] as String?)}  ${c['cat']}  ${c['memberId']}  ${shekel(_FeesData.netOf(f, c))}',
      'תשלומים:',
      for (final p in _FeesData.paymentsOf(f)) '  ${fmtDate(p['date'] as String?)}  ${p['method']}  ${shekel(p['amount'] as num)}',
      '',
      'סך-חיובים ${shekel(_FeesData.charged(f))} · שולם ${shekel(_FeesData.paid(f))} · יתרה ${shekel(_FeesData.balance(f))}',
    ];
    return [
      if (!_amounts) ForgeSectionPill(items: [['מצב-חשבון דורש הרשאת-כספים']], variants: const <int>[0]) else
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFF0C0D1E), borderRadius: BorderRadius.circular(10)),
          child: SelectableText(lines.join('\n'), style: const TextStyle(color: _ink, fontSize: 12, height: 1.6)),
        ),
      ForgeSectionPill(items: [['הדפסה/PDF = שער-חיצוני (מקום-שמור) — הטקסט לעיל ניתן להעתקה']], variants: const <int>[0]),
    ];
  }

  List<Widget> _tabAudit(Map<String, dynamic> f) {
    final rows = _FeesData.audit.where((a) => a['family'] == f['id']).toList();
    return [
      if (rows.isEmpty) ForgeSearchEmptyState(fields: ['אין פעולות למשפחה זו עדיין', '']) else
        for (final a in rows) ForgeNotifRow(items: [['${a['role']}', fmtDate(a['date'] as String?)]]),
    ];
  }

  // ═══ טפסים (DsEnumField⊕DsNumberField⊕DsDateField⊕DsField⊕DsPrimaryButton): חיוב-חדש / חיוב-מרוכז · רישום-תשלום ═══
  void _openChargeForm(Map<String, dynamic>? fixed, List<Map<String, dynamic>> pool, {VoidCallback? onDone}) {
    var fam = fixed?['id'] as String? ?? (pool.isNotEmpty ? pool.first['id'] as String : '');
    var cat = _FeesData.chargeTypes.first, amount = '', date = _FeesData.today, note = '', member = '', bulk = '';
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        final f = _FeesData.families.firstWhere((x) => x['id'] == fam, orElse: () => _FeesData.families.first);
        final members = [for (final m in f['members'] as List) '${(m as Map)['first']}'];
        if (!members.contains(member)) member = members.first;
        final grades = _FeesData.grades(_FeesData.families);
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: DraggableScrollableSheet(
            initialChildSize: 0.75, minChildSize: 0.4, maxChildSize: 0.95, expand: false,
            builder: (ctx, scroll) => Padding(
              padding: const EdgeInsets.all(12),
              child: ForgeStripPanelFrame(fields: ['', ''], child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
                  ForgeContactTile(fields: ['חיוב חדש / חיוב-מרוכז', 'סוג · סכום · תאריך · עבור-מי — או מרוכז לכל כיתה']),
                  _gap(8),
                  ForgeDsEnumField(fields: ['משפחה'], control: DsEnumField(label: 'משפחה', options: [for (final x in _FeesData.families) '${x['name']}'], value: '${f['name']}', onChanged: (v) => setSheet(() => fam = _FeesData.families.firstWhere((x) => x['name'] == v)['id'] as String), bare: true)),
                  ForgeDsEnumField(fields: ['עבור-מי'], control: DsEnumField(label: 'עבור-מי', options: members, value: member, onChanged: (v) => setSheet(() => member = v), bare: true)),
                  ForgeDsEnumField(fields: ['סוג-חיוב'], control: DsEnumField(label: 'סוג-חיוב', options: _FeesData.chargeTypes, value: cat, onChanged: (v) => setSheet(() => cat = v), bare: true)),
                  ForgeDsNumberField(fields: ['סכום (₪)'], control: DsNumberField(label: 'סכום (₪)', value: amount, onChanged: (v) => amount = v, bare: true)),
                  ForgeDsDateFieldInput(fields: ['תאריך'], control: DsDateField(label: 'תאריך', value: date, onChanged: (v) => setSheet(() => date = v), bare: true)),
                  ForgeDsField(state: (note).toString().trim().isEmpty ? ForgeDsFieldState.empty : ForgeDsFieldState.filled, fields: ['הערה', ''], control: DsField(label: 'הערה', hint: 'למשל: טיול שנתי / שם-חוג', value: note, onChanged: (v) => note = v, bare: true)),
                  _gap(6),
                  ForgeDsEnumField(fields: ['חיוב-מרוכז לכיתה (אופציונלי)'], control: DsEnumField(label: 'חיוב-מרוכז לכיתה (אופציונלי)', options: ['', ...grades], value: bulk, onChanged: (v) => setSheet(() => bulk = v), bare: true)),
                  _gap(10),
                  GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {
                    final a = int.tryParse(amount.trim()) ?? 0;
                    if (a <= 0) return;
                    if (bulk.isEmpty) {
                      _FeesData.addCharge(f, _roleName, cat: cat, amount: a, date: date, memberId: member, note: note);
                    } else {
                      for (final x in _FeesData.families) {
                        for (final m in x['members'] as List) {
                          if ('${(m as Map)['grade']}'.startsWith(bulk)) _FeesData.addCharge(x, _roleName, cat: cat, amount: a, date: date, memberId: '${m['first']}', note: note.isEmpty ? 'חיוב-מרוכז $bulk' : note);
                        }
                      }
                    }
                    Navigator.of(ctx).pop();
                    setState(() {});
                    onDone?.call();
                  }, child: ForgeSoftButton(fields: [bulk.isEmpty ? 'שמור חיוב' : 'חיוב-מרוכז לכל $bulk'])),
                ])),
            ),
          ),
        );
      }),
    );
  }

  void _openPaymentForm(Map<String, dynamic>? fixed, List<Map<String, dynamic>> pool, {VoidCallback? onDone}) {
    var fam = fixed?['id'] as String? ?? (pool.isNotEmpty ? pool.first['id'] as String : '');
    var method = 'אשראי', amount = '', date = _FeesData.today, note = '';
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        final f = _FeesData.families.firstWhere((x) => x['id'] == fam, orElse: () => _FeesData.families.first);
        final bal = _FeesData.balance(f);
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: DraggableScrollableSheet(
            initialChildSize: 0.7, minChildSize: 0.4, maxChildSize: 0.95, expand: false,
            builder: (ctx, scroll) => Padding(
              padding: const EdgeInsets.all(12),
              child: ForgeStripPanelFrame(fields: ['', ''], child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
                  ForgeContactTile(fields: ['רישום תשלום', 'יתרה נוכחית ${_m(bal)} · המסך רושם — אינו סולק']),
                  _gap(8),
                  ForgeDsEnumField(fields: ['משפחה'], control: DsEnumField(label: 'משפחה', options: [for (final x in _FeesData.families) '${x['name']}'], value: '${f['name']}', onChanged: (v) => setSheet(() => fam = _FeesData.families.firstWhere((x) => x['name'] == v)['id'] as String), bare: true)),
                  ForgeDsEnumField(fields: ['אמצעי'], control: DsEnumField(label: 'אמצעי', options: _FeesData.payMethodsSchool, value: method, onChanged: (v) => setSheet(() => method = v), bare: true)),
                  ForgeDsNumberField(fields: ['סכום (₪) · ריק = מלוא-היתרה'], control: DsNumberField(label: 'סכום (₪) · ריק = מלוא-היתרה', value: amount, onChanged: (v) => amount = v, bare: true)),
                  ForgeDsDateFieldInput(fields: ['תאריך'], control: DsDateField(label: 'תאריך', value: date, onChanged: (v) => setSheet(() => date = v), bare: true)),
                  ForgeDsField(state: (note).toString().trim().isEmpty ? ForgeDsFieldState.empty : ForgeDsFieldState.filled, fields: ['הערה / אסמכתא', ''], control: DsField(label: 'הערה / אסמכתא', hint: 'אסמכתת-העברה (לא מס׳-קבלה)', value: note, onChanged: (v) => note = v, bare: true)),
                  _gap(10),
                  GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {
                    final a = amount.trim().isEmpty ? bal : (int.tryParse(amount.trim()) ?? 0);
                    if (a <= 0) return;
                    _FeesData.addPayment(f, _roleName, amount: a, method: method, date: date, note: note);
                    Navigator.of(ctx).pop();
                    setState(() {});
                    onDone?.call();
                  }, child: ForgeSoftButton(fields: ['רשום תשלום'])),
                ])),
            ),
          ),
        );
      }),
    );
  }

  // ═══ ייצוא (toCsv⊕csvEscape⊕exportAllowed) — הרשימה-הנראית; בסנדבוקס ההורדה חסומה ⇒ תצוגה+העתקה ═══
  void _openExport(List<Map<String, dynamic>> fs) {
    final csv = _FeesData.csvOf(fs);
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.92, expand: false,
        builder: (ctx, scroll) => Padding(
          padding: const EdgeInsets.all(12),
          child: ForgeStripPanelFrame(fields: ['', ''], child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
              ForgeContactTile(fields: ['ייצוא CSV', '${fs.length} משפחות · ${_FeesData.csvHeader.length} עמודות (PDF = שער-חיצוני, מקום-שמור)']),
              _gap(10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF0C0D1E), borderRadius: BorderRadius.circular(10)),
                child: SelectableText(csv, textDirection: TextDirection.ltr, style: const TextStyle(color: _ink, fontSize: 12, height: 1.6)),
              ),
            ])),
        ),
      ),
    );
  }

  Widget _wrap(List<Widget> kids, {double top = 6}) => Padding(
        padding: EdgeInsets.only(top: top, right: 4),
        child: Wrap(spacing: 8, runSpacing: 6, children: kids),
      );
  Widget _gap([double h = 10]) => SizedBox(height: h);
}
