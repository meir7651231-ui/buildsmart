// 🎯 EnrollmentScreen — retarget של schoolos_fees.dart לישות Enrollment (GENMAX·G5c/G5d · הכרעה-24) · מחולל דטרמיניסטי: retarget.mjs --module schoolos_fees.dart --entity Enrollment
//   זרע-ראשי: families (מועמדים: families(36/38) charges(9/10) charges(7/8) charges(7/8) charges(7/8) charges(7/8) charges(7/8) incoming(7/8) charges(6/7) hist(5/5) criteria(3/3) calls(3/3) payments(3/4) payments(3/4) payments(3/4) payments(3/4) calls(3/3) payments(3/4)) · מיפוי שם 4 · ערוץ 0 · טיפוס-יחיד 1 · מקום-שמור 14 · חוזה-מנוע (לא משתנה) 19
//   id⇒id(name) · memberId⇒memberId(name) · note⇒note(name) · payments⇒payments(name) · name⇒∅(engine-contract) · phone⇒∅(engine-contract) · email⇒∅(engine-contract) · idNum⇒∅(engine-contract) · date⇒∅(engine-contract) · amount⇒∅(engine-contract) · cur⇒∅(engine-contract) · cat⇒∅(engine-contract) · hok⇒∅(engine-contract) · day⇒∅(engine-contract) · active⇒∅(engine-contract) · carryBalance⇒∅(engine-contract) · kevaId⇒∅(engine-contract) · hist⇒∅(engine-contract) · d⇒∅(engine-contract) · a⇒∅(engine-contract) · c⇒∅(engine-contract) · clearer⇒∅(engine-contract) · nextDate⇒∅(engine-contract) · payer⇒∅(reserved(2 מועמדים)) · members⇒absences(unique) · grade⇒∅(reserved(2 מועמדים)) · first⇒∅(reserved(2 מועמדים)) · charges⇒∅(reserved) · method⇒∅(reserved(2 מועמדים)) · rid⇒∅(reserved(3 מועמדים)) · startedAt⇒∅(reserved(4 מועמדים)) · criteria⇒∅(reserved) · calls⇒∅(reserved) · at⇒∅(reserved(4 מועמדים)) · outcome⇒∅(reserved(2 מועמדים)) · nextNote⇒∅(reserved(2 מועמדים)) · installmentOf⇒∅(reserved(2 מועמדים)) · cancelledAt⇒∅(reserved(4 מועמדים))
//   תפר-עובדות (G9b): EnrollmentFacts · count=families.length (static-const) · מדדים 0 · hero=count · שורות-מדד (G10a) ∅ · תפר-כניסה initialPanelId · תפר-סינון-מדד ∅
//   שדות-Enrollment בלי מקור (מקום-שמור, יאירו כשיוזרם נתון): courseId, plan, purchased, used, group, presents, totalDue, dueDate, dueEventId, status, enrolledAt, endedAt, paidFull, freq, freqUnit, term, termMonths, tier, renew, renewNote, renewedToId · תוויות: מונחי Supporter (תורם/—) ⇒ Enrollment (שיבוץ/שיבוצים) · 0 החלפות · הזרע = זרע-הצבה של המקור, לא ערך-אמת של Enrollment
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
import 'gen_core_enrollment.dart'; // G6c · הגרעין-מהסכמה של Enrollment (מצבים · מעבר · חוקים · ערוצים)

const _acc = DsTokens.accent;
// פיגמנטים מוזרקים לאטומים-טהורים (חוק-6: צבע=הצבה)
const _danger = Color(0xFFF43F5E);
const _ok = Color(0xFF34D399);
const _muted = Color(0xFF9AA0BE);
const _ink = Color(0xFFF2F3FF);
const _warning = Color(0xFFF59E0B);

// ═══════════════════════════════════════════════════════════════════════════════════════
// 🧮 _EnrollmentData — לוגיקה-טהורה + חוזה-דאטה (אפס-DOM). מקורות-אמת (§20-ג · אפס-זיוף):
//   משפחה   → maor Family (name·father·mother·phone·email·discount·status·members) · Member (first·grade·idNum)
//   חיוב    → maor PlannedCharge (id·date·amount·cur·method·cat·installmentOf·cancelledAt·note) + Enrollment.memberId/dueDate
//   תשלום   → maor Payment (rid·date·amount·method) · Enrollment.totalDue/carryBalance/paidFull ⇒ payBal/payCredit
//   הו״ק    → maor Hok (amount·cur·day·method·active·startedAt·kevaId) + Supporter.hist (d·a·c·clearer) ⇒ hokEffectivelyActive
//   תזכורת  → Supporter.calls (CallEntry: at·outcome) + Supporter.nextDate/nextNote
//   הנחה    → קריטריוני-הנחה {id·discountPct} (max-discount-pct.contract) · Family.discount
//   ⛔ ללא-מקור-אמת ⇒ מקום-שמור, לא זיוף: receiptNo · clearingRef · invoiceNo · payUrl (שער-חיצוני)
// ═══════════════════════════════════════════════════════════════════════════════════════
class _EnrollmentData {
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
      'absences': [{'first': 'נועה', 'grade': 'י\'-3'}, {'first': 'איתי', 'grade': 'ח\'-1'}],
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
      'absences': [{'first': 'יונתן', 'grade': 'ט\'-2'}],
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
      'absences': [{'first': 'שירה', 'grade': 'יא\'-1'}, {'first': 'עומר', 'grade': 'ט\'-1'}, {'first': 'טל', 'grade': 'ז\'-2'}],
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
      'absences': [{'first': 'אליה', 'grade': 'י\'-1'}],
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
      'absences': [{'first': 'ליאור', 'grade': 'ח\'-2'}],
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
      'absences': [{'first': 'רון', 'grade': 'י\'-1'}],
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
      'absences': [{'first': 'מאיה', 'grade': 'י\'-2'}, {'first': 'עידו', 'grade': 'ז\'-1'}],
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
      'absences': [{'first': 'הדר', 'grade': 'ח\'-2'}],
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
  static int studentsN(Map<String, dynamic> f) => (f['absences'] as List).length;
  static String gradesOf(Map<String, dynamic> f) => (f['absences'] as List).map((m) => (m as Map)['grade']).join(' · ');
  static String studentsOf(Map<String, dynamic> f) => (f['absences'] as List).map((m) => (m as Map)['first']).join(', ');

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
      ['${f['name']}', '${f['payer']}', '${f['phone']}', ...(f['absences'] as List).map((m) => '${(m as Map)['first']}'), gradesOf(f)];
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
      case 'grade': return (f['absences'] as List).any((m) => '${(m as Map)['grade']}'.startsWith('${db['grade']}')) ? '1' : '0';
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
      {for (final f in fs) for (final m in f['absences'] as List) '${(m as Map)['grade']}'.split('-').first}.toList()..sort();
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
    // ═══ חוזה-העמודות של Enrollment (G5h · חוק-7): 20 שדות-סכמה בלי מקור בזרע — עמודות-מקום-שמור, לא מזויפות ולא מושמטות ═══
    {'key': 'courseId', 'label': 'courseId'}, // G5h · מקום-שמור: שדה-Enrollment מהסכמה (Id) — מאיר כשהנתון מוזרם
    {'key': 'plan', 'label': 'plan'}, // G5h · מקום-שמור: שדה-Enrollment מהסכמה (PricingModel) — מאיר כשהנתון מוזרם
    {'key': 'purchased', 'label': 'purchased'}, // G5h · מקום-שמור: שדה-Enrollment מהסכמה (number) — מאיר כשהנתון מוזרם
    {'key': 'used', 'label': 'used'}, // G5h · מקום-שמור: שדה-Enrollment מהסכמה (number) — מאיר כשהנתון מוזרם
    {'key': 'group', 'label': 'group'}, // G5h · מקום-שמור: שדה-Enrollment מהסכמה (string) — מאיר כשהנתון מוזרם
    {'key': 'totalDue', 'label': 'totalDue'}, // G5h · מקום-שמור: שדה-Enrollment מהסכמה (number) — מאיר כשהנתון מוזרם
    {'key': 'dueDate', 'label': 'dueDate'}, // G5h · מקום-שמור: שדה-Enrollment מהסכמה (IsoDate | '') — מאיר כשהנתון מוזרם
    {'key': 'dueEventId', 'label': 'dueEventId'}, // G5h · מקום-שמור: שדה-Enrollment מהסכמה (Id) — מאיר כשהנתון מוזרם
    {'key': 'status', 'label': 'status'}, // G5h · מקום-שמור: שדה-Enrollment מהסכמה (EnrollmentStatus) — מאיר כשהנתון מוזרם
    {'key': 'enrolledAt', 'label': 'enrolledAt'}, // G5h · מקום-שמור: שדה-Enrollment מהסכמה (IsoDate) — מאיר כשהנתון מוזרם
    {'key': 'endedAt', 'label': 'endedAt'}, // G5h · מקום-שמור: שדה-Enrollment מהסכמה (IsoDate) — מאיר כשהנתון מוזרם
    {'key': 'paidFull', 'label': 'paidFull'}, // G5h · מקום-שמור: שדה-Enrollment מהסכמה (boolean) — מאיר כשהנתון מוזרם
    {'key': 'freq', 'label': 'freq'}, // G5h · מקום-שמור: שדה-Enrollment מהסכמה (number) — מאיר כשהנתון מוזרם
    {'key': 'freqUnit', 'label': 'freqUnit'}, // G5h · מקום-שמור: שדה-Enrollment מהסכמה ('week' | 'month') — מאיר כשהנתון מוזרם
    {'key': 'term', 'label': 'term'}, // G5h · מקום-שמור: שדה-Enrollment מהסכמה (PricingTerm) — מאיר כשהנתון מוזרם
    {'key': 'termMonths', 'label': 'termMonths'}, // G5h · מקום-שמור: שדה-Enrollment מהסכמה (number) — מאיר כשהנתון מוזרם
    {'key': 'tier', 'label': 'tier'}, // G5h · מקום-שמור: שדה-Enrollment מהסכמה ('' | '1' | '2' | '3') — מאיר כשהנתון מוזרם
    {'key': 'renew', 'label': 'renew'}, // G5h · מקום-שמור: שדה-Enrollment מהסכמה ('yes' | 'no' | 'hold') — מאיר כשהנתון מוזרם
    {'key': 'renewNote', 'label': 'renewNote'}, // G5h · מקום-שמור: שדה-Enrollment מהסכמה (string) — מאיר כשהנתון מוזרם
    {'key': 'renewedToId', 'label': 'renewedToId'}, // G5h · מקום-שמור: שדה-Enrollment מהסכמה (Id) — מאיר כשהנתון מוזרם
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
// 💰 EnrollmentScreen — המסך (const · ללא main). המנהל מחבר לניווט-הבית.
// ═══════════════════════════════════════════════════════════════════════════════════════
class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({this.initialPanelId, super.key});
  final String? initialPanelId; // G10a · תפר-כניסה: מזהה-רשומה שכרטיסה נפתח אחרי הפריים-הראשון (צורת initialPanel של זהב-המורים; הרכזת קופצת לרשומת-ה-hero)
  /// איפוס פנקס-הפעולות לבסיס-האמת (לרתמות-בדיקה/דמו; חיבור-אסינק אמיתי יטען מחדש מהמקור)
  static void resetLedger() => _EnrollmentData.reset();
  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  @override
  void initState() {
    super.initState();
    final p0 = widget.initialPanelId == null ? null : EnrollmentFacts.byId(widget.initialPanelId!); // G10a
    if (p0 != null) WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _openPanel(p0); });
  }
  final Map<String, String> _coreState = {}; // G6d · פנקס-מצבי-הגרעין לפי id — overlay על הזרע (הזרע const; אין כתיבה אליו)
  int _role = 0; // 0=גזבר · 1=מזכירות · 2=הנהלה · 3=מחנך · 4=הורה · 5=צפייה
  String _q = '';
  int _chip = 0; // 0=הכל · 1=יתרה>0 · 2=ותק>90 · 3=הו״ק · 4=מלגה · 5=ללא-תזכורת · 6=תזכורת>2 · 7=הסדר · 8=בסיכון
  String _grade = '', _type = '', _course = '', _method = '', _year = '', _status = '';
  int _mode = 0; // 0=🎯 חייבים · 1=📋 טבלה · 2=💳 הו״ק · 3=🔔 תזכורות · 4=📊 דוחות · 5=🧾 אודיט
  bool _loading = false;
  String? _error;
  bool _hokArmed = false; // אישור-דו-שלבי לרישום-הו״ק-מרוכז
  bool _filtersOpen = false;

  String get _roleName => _EnrollmentData.roleName(_role);
  bool get _amounts => _EnrollmentData.amounts(_role);
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
    final all = _EnrollmentData.visibleFor(_role);
    // דירוג: סיכון-יורד ⇒ ותק-יורד ⇒ יתרה-יורדת (המפרט: חוב · ותק-חוב · סיכון)
    final ranked = [...all]..sort((a, b) {
        final r = _EnrollmentData.risk(b).compareTo(_EnrollmentData.risk(a));
        if (r != 0) return r;
        final ag = _EnrollmentData.agingDays(b).compareTo(_EnrollmentData.agingDays(a));
        return ag != 0 ? ag : _EnrollmentData.balance(b).compareTo(_EnrollmentData.balance(a));
      });
    final visible = _EnrollmentData.filter(_EnrollmentData.search(ranked, _q), _locks,
        {'grade': _grade, 'type': _type, 'course': _course, 'method': _method, 'year': _year});
    // KPI-10 על כל-המשפחות-הנראות-לתפקיד (הורה ⇒ משפחתו בלבד)
    final kCharged = _EnrollmentData.kCharged(all), kPaid = _EnrollmentData.kPaid(all), kOpen = _EnrollmentData.kOpen(all), kPct = _EnrollmentData.kPct(all);
    final inDebt = _EnrollmentData.kInDebt(all), oldN = all.where(_EnrollmentData.oldDebt).length, kOld = _EnrollmentData.kOld(all);
    final kExp = _EnrollmentData.kExpected(all), kHok = _EnrollmentData.kHokActive(all), kSch = _EnrollmentData.kScholar(all), kRem = _EnrollmentData.kReminders(all);
    final failed = all.where(_EnrollmentData.hokFailed).toList();
    final late = all.where(_EnrollmentData.arrangementLate).toList();
    final dups = [for (final f in all) if (_EnrollmentData.duplicateCharges(f).isNotEmpty) f];
    final hokDue = _EnrollmentData.hokDueList(all);
    final follow = _EnrollmentData.followUps(all);
    final tripDebt = all.where((f) => _EnrollmentData.balance(f) > 0 && _EnrollmentData.liveCharges(f).any((c) => c['cat'] == 'טיול')).toList();
    final buckets = <int, List<Map<String, dynamic>>>{2: [], 1: [], 0: [], -1: []};
    for (final f in visible) {
      // דגל-בלבד (מחנך): שני דליים — דגל/תקין; אין דירוג-סיכון גלוי
      buckets[_EnrollmentData.balance(f) <= 0 ? -1 : _amounts ? _EnrollmentData.risk(f) : 0]!.add(f);
    }
    final secTitle = {2: '🔴 סיכון-גבוה / חוב-ותיק', 1: '🟠 בפיגור / בינוני', 0: _amounts ? '🟢 חוב-טרי' : '🚩 דגל-חוב', -1: '✅ ללא-חוב'};
    const secTone = {2: 2, 1: 3, 0: 0, -1: 1};
    final trend = _EnrollmentData.collectionTrend(all);
    final thisMonth = _EnrollmentData.collectedInMonth(all, monthKey(_EnrollmentData.today));

    return DsScaffold(
      title: 'גבייה ותשלומים', subtitle: '${all.length} משפחות · ${_EnrollmentData.year} · $_roleName', icon: '💰',
      children: [
        // ═══ הגרעין-מהסכמה (G6c): EnrollmentCore — מצבים חצובים ⊕ מעבר מאטום-המדף ⊕ חוקים/ערוצים — לא מומצא, לא מצויר-ביד ═══
        DsSection(title: '🧠 מחזור-חיים · ${EnrollmentCore.term} (גרעין)', children: [
          Wrap(spacing: 6, runSpacing: 6, children: [for (final s in EnrollmentCore.states) StatusChip(label: s, tone: s == EnrollmentCore.states.first ? 1 : 0)]),
          AlertBanner(message: 'הבא אחרי ${EnrollmentCore.states.first}: ${EnrollmentCore.next(EnrollmentCore.states.first) ?? 'סופי'} · ${EnrollmentCore.rules.length} חוקים · ${EnrollmentCore.channels.length} ערוצים · ${EnrollmentCore.relations.length} יחסים', tone: 0, glyph: '🧠'),
        ]),
        // בורר-תפקיד (חוק-6 · זהות-מוזרקת) — מדגים גידור-הרשאות (roleOf⊕canGrantedAction)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedSwitch(items: [for (final r in _EnrollmentData.roleDefs) r['label'] as String], selected: _role, onSelect: (i) => setState(() { _role = i; _hokArmed = false; })),
        ),
        _gap(10),
        if (!_amounts) ...[
          const AlertBanner(glyph: '🔒', tone: 3, message: 'נעילת-הרשאה-כספית: תפקיד זה רואה דגל-חוב בלבד — אפס-סכומים, אפס-פרטי-חוב (מגן-כבוד)'),
          _gap(8),
        ],
        // פס-עליון: חיפוש (DsSearch) · רענון · חיוב-חדש · רישום-תשלום · ייצוא — מגודרים פר-הרשאה
        Row(children: [
          Expanded(child: DsSearch(value: _q, onChanged: (v) => setState(() => _q = v))),
          const SizedBox(width: 6),
          Padding(padding: const EdgeInsets.only(bottom: 12), child: SoftButton(label: '🔄', tone: 0, onTap: _refresh)),
          if (_EnrollmentData.can(_role, 'fees.charge')) ...[
            const SizedBox(width: 6),
            Padding(padding: const EdgeInsets.only(bottom: 12), child: SoftButton(label: '➕ חיוב', tone: 0, onTap: () => _openChargeForm(null, visible))),
          ],
          if (_EnrollmentData.can(_role, 'fees.pay')) ...[
            const SizedBox(width: 6),
            Padding(padding: const EdgeInsets.only(bottom: 12), child: SoftButton(label: '💳 תשלום', tone: 1, onTap: () => _openPaymentForm(null, visible))),
          ],
          if (_EnrollmentData.exportOk(_role)) ...[
            const SizedBox(width: 6),
            Padding(padding: const EdgeInsets.only(bottom: 12), child: SoftButton(label: '⬇ CSV', tone: 0, onTap: () => _openExport(visible))),
          ],
        ]),
        // צ׳יפי-חריגה (FilterChipPill מבוקר ⊕ finderMatches) — פעולת-יסוד "זיהוי-חריגה"
        Wrap(spacing: 8, runSpacing: 6, children: [
          _fchip(0, 'הכל'),
          _fchip(1, '🚩 דגל-חוב · $inDebt'),
          if (_amounts) ...[
          _fchip(2, '⏰ ותק>${_EnrollmentData.oldDebtDays} · $oldN'),
          _fchip(3, '💳 הו״ק · ${all.where(_EnrollmentData.hokFlag).length}'),
          _fchip(4, '🎓 מלגה/הנחה · ${all.where((f) => _EnrollmentData.discountPct(f) > 0).length}'),
          _fchip(5, '🔕 ללא-תזכורת · ${all.where((f) => _EnrollmentData.balance(f) > 0 && _EnrollmentData.remindersSent(f).isEmpty).length}'),
          _fchip(6, '🔔 תזכורת>2 · ${all.where((f) => _EnrollmentData.remindersSent(f).length > 2).length}'),
          _fchip(7, '📆 הסדר · ${all.where(_EnrollmentData.hasArrangement).length}'),
          _fchip(8, '⚠️ בסיכון · ${all.where((f) => _EnrollmentData.risk(f) >= 1).length}'),
          FilterChipPill(
            label: _filtersOpen ? '▲ פילטרים' : '▼ פילטרים (כיתה·חוג·סוג·אמצעי·שנה·סטטוס)', selected: _filtersOpen, onTap: () => setState(() => _filtersOpen = !_filtersOpen),
            activeFillColor: const Color(0xFF2A2D4A), surfaceColor: const Color(0xFF14162E), activeTextColor: _ink, inkColor: _ink, outlineColor: const Color(0xFF2A2D4A), pillRadius: 999,
          ),
          ],
        ]),
        if (_filtersOpen) ...[
          _gap(8),
          // פילטרי-ערך (DsEnumField מבוקר ⇒ נעילת-ציר ב-finderMatches): כיתה · חוג · סוג-חיוב · אמצעי · שנה · סטטוס
          Wrap(spacing: 10, runSpacing: 6, children: [
            _enum('כיתה', ['', ..._EnrollmentData.grades(all)], _grade, (v) => setState(() => _grade = v)),
            _enum('חוג', ['', ..._EnrollmentData.courses(all)], _course, (v) => setState(() => _course = v)),
            _enum('סוג-חיוב', ['', ..._EnrollmentData.chargeTypes, _EnrollmentData.arrangementType], _type, (v) => setState(() => _type = v)),
            _enum('אמצעי', ['', ..._EnrollmentData.payMethodsSchool], _method, (v) => setState(() => _method = v)),
            _enum('שנה', ['', ..._EnrollmentData.years(all)], _year, (v) => setState(() => _year = v)),
            _enum('סטטוס', const ['', 'תקין', 'בפיגור', 'הסדר', 'הסדר-בפיגור', 'מלגה-מלאה', 'חוב-אבוד'], _status, (v) => setState(() => _status = v)),
          ]),
        ],
        const SizedBox(height: 12),
        // KPI-10 (המפרט): hero=יתרה-פתוחה (המטרה: מה חסר) + 10 מדדי-מצב (BareStat, ערכי-אמת) + יחס-גבייה (StatRow)
        if (!_amounts)
          GradientCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              StatHero(value: '$inDebt', label: 'משפחות עם דגל-חוב מתוך ${all.length}'),
              const SizedBox(height: 8),
              const Text('פרטים וסכומים = גזברות בלבד. לתיאום: לפנות לגזבר/ת, לא לתלמיד.', style: TextStyle(color: _muted, fontSize: 12.5)),
            ]),
          )
        else
        GradientCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            StatHero(value: _m(kOpen), label: 'יתרה פתוחה · $inDebt משפחות בחוב'),
            const SizedBox(height: 12),
            StatRow(label: 'אחוז-גבייה (שולם מתוך חיובים)', value: '$kPct%', fraction: kPct / 100),
            const SizedBox(height: 12),
            Row(children: [
              BareStat(value: _m(kCharged), label: '🧾 סך-חיובים', inkColor: _ink, mutedColor: _muted),
              BareStat(value: _m(kPaid), label: '✅ נגבה', inkColor: _ok, mutedColor: _muted),
              BareStat(value: _m(kOpen), label: '💸 יתרה-פתוחה', inkColor: kOpen > 0 ? _warning : _ok, mutedColor: _muted),
              BareStat(value: '$kPct%', label: '📈 אחוז-גבייה', inkColor: kPct >= 80 ? _ok : _warning, mutedColor: _muted),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              BareStat(value: '$inDebt', label: '👨‍👩‍👧 משפחות-בחוב', inkColor: inDebt > 0 ? _warning : _ok, mutedColor: _muted),
              BareStat(value: _m(kOld), label: '⏰ חוב-ותיק >${_EnrollmentData.oldDebtDays}י׳ · $oldN', inkColor: kOld > 0 ? _danger : _ok, mutedColor: _muted),
              BareStat(value: _m(kExp), label: '📅 צפוי-החודש', inkColor: _acc, mutedColor: _muted),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              BareStat(value: '$kHok', label: '💳 הו״ק-פעילות', inkColor: _ink, mutedColor: _muted),
              BareStat(value: _m(kSch), label: '🎓 מלגות/הנחות', inkColor: _acc, mutedColor: _muted),
              BareStat(value: '$kRem', label: '🔔 תזכורות-החודש', inkColor: _ink, mutedColor: _muted),
            ]),
          ]),
        ),
        const SizedBox(height: 8),
        // מרכז-אוטומציות (23-ג · פרואקטיבי): הו״ק-נכשלה · הסדר-בפיגור · חיוב-כפול · הו״ק-לרישום · מעקב-שעבר-מועד · חוב-לפני-טיול
        if (failed.isNotEmpty && _amounts) ...[
          AlertBanner(glyph: '⚠️', tone: 2, message: '${failed.length} הו״ק נכשלה (הסליקה פסקה >2 חודשים) — התרעה + ניסיון-חוזר: ${failed.map((f) => f['name']).join(' · ')}'),
          _gap(8),
        ],
        if (late.isNotEmpty && _amounts) ...[
          AlertBanner(glyph: '📆', tone: 3, message: '${late.length} הסדר-בפיגור: ${late.map((f) => f['name']).join(' · ')}'),
          _gap(8),
        ],
        if (dups.isNotEmpty && _amounts) ...[
          AlertBanner(glyph: '👯', tone: 3, message: 'חיוב-כפול-חשוד (אותו סוג·סכום·תאריך·תלמיד): ${dups.map((f) => '${f['name']} (${_EnrollmentData.duplicateCharges(f).map((c) => c['cat']).join(',')})').join(' · ')}'),
          _gap(8),
        ],
        if (tripDebt.isNotEmpty && _amounts) ...[
          AlertBanner(glyph: '🚌', tone: 0, message: 'חוב לפני-טיול (התרעה-מוקדמת, לא-מניעה): ${tripDebt.map((f) => f['name']).join(' · ')}'),
          _gap(8),
        ],
        if (follow.isNotEmpty && _EnrollmentData.can(_role, 'fees.remind')) ...[
          AlertBanner(glyph: '📞', tone: 0, message: 'מעקב שעבר-מועד: ${follow.map((t) => t['title']).join(' · ')}'),
          _gap(8),
        ],
        if (hokDue.isNotEmpty && _EnrollmentData.can(_role, 'fees.hok')) ...[
          AlertBanner(glyph: '💳', tone: 0, message: '${hokDue.length} הו״ק לרישום החודש (${_m(_EnrollmentData.hokExpected(all))}) — ראה מבט הו״ק'),
          _gap(8),
        ],
        // בורר-מבט (SegmentedSwitch מבוקר)
        if (_amounts)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedSwitch(items: const ['🎯 חייבים', '📋 טבלה', '💳 הו״ק', '🔔 תזכורות', '📊 דוחות', '🧾 אודיט'], selected: _mode, onSelect: (i) => setState(() => _mode = i)),
          ),
        const SizedBox(height: 10),
        // מצבי-מסך שמורים: טעינה · שגיאה · ריק
        if (_loading)
          _loadingView()
        else if (_error != null)
          AlertBanner(glyph: '⚠️', tone: 2, message: _error!)
        else if (_mode == 2 && _amounts)
          _hokView(all, hokDue)
        else if (_mode == 3 && _amounts)
          _remindersView(visible)
        else if (_mode == 4 && _amounts)
          _reportsView(all, trend, thisMonth)
        else if (_mode == 5 && _amounts)
          _auditView()
        else if (all.isEmpty)
          const Padding(padding: EdgeInsets.only(top: 24), child: EmptyState(glyph: '📭', message: 'אין משפחות/חיובים — התחל בחיוב-שנה'))
        else if (visible.isEmpty)
          const Padding(padding: EdgeInsets.only(top: 24), child: EmptyState(glyph: '🔍', message: 'אין משפחות תואמות לחיפוש/סינון'))
        else if (_mode == 1 && _amounts)
          _table(visible)
        else
          for (final st in const [2, 1, 0, -1])
            if (buckets[st]!.isNotEmpty)
              DsSection(title: '${secTitle[st]} · ${buckets[st]!.length}', tone: secTone[st]!, children: [
                for (final f in buckets[st]!) _row(f),
              ]),
      ],
    );
  }

  Widget _enum(String label, List<String> options, String value, void Function(String) on) => SizedBox(
        width: 170,
        child: DsEnumField(label: label, options: options, value: value, onChanged: on),
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
    final cols = [for (final c in _EnrollmentData.columnDefs) if (_EnrollmentData.colShown(c, rows)) c];
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
    return DsTable(labels: labels, rows: data);
  }

  // ═══ שורת-משפחה (טריאז'): זהות ⊕ יחס-שולם (StatRow) ⊕ BareStat×3 ⊕ facts ⊕ הפעולה-הנכונה (AlertBanner) ═══
  Widget _row(Map<String, dynamic> f) {
    final charged = _EnrollmentData.charged(f), paid = _EnrollmentData.paid(f), bal = _EnrollmentData.balance(f);
    final band = _EnrollmentData.agingBand(f);
    final act = _EnrollmentData.rightAction(f);
    final balColor = band == 3 ? _danger : band == 2 ? _warning : band == 1 ? _acc : _ok;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GradientCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: MediaRow(glyph: '👨‍👩‍👧', title: f['name'] as String, subtitle: '${_EnrollmentData.studentsOf(f)} · ${_EnrollmentData.gradesOf(f)}')),
            IconButton(onPressed: () => _openPanel(f), icon: const Icon(Icons.chevron_left, color: _acc, size: 26), tooltip: 'פאנל משפחה'),
          ]),
          _gap(8),
          if (_amounts) ...[
            StatRow(label: 'שולם מתוך חיובים', value: '${shekel(paid)} / ${shekel(charged)}', fraction: charged == 0 ? (paid > 0 ? 1 : 0) : paid / charged),
            _gap(8),
            Row(children: [
              BareStat(value: shekel(charged), label: 'חיובים', inkColor: _ink, mutedColor: _muted),
              BareStat(value: shekel(paid), label: 'שולם', inkColor: _ok, mutedColor: _muted),
              BareStat(value: shekel(bal), label: bal > 0 ? '= יתרה · ${_EnrollmentData.agingDays(f)} י׳' : '= יתרה', inkColor: balColor, mutedColor: _muted),
            ]),
          ] else
            Row(children: [
              BareStat(value: bal > 0 ? '🚩' : '✅', label: bal > 0 ? 'דגל-חוב (ללא-סכום)' : 'תקין', inkColor: bal > 0 ? _warning : _ok, mutedColor: _muted),
            ]),
          if (_amounts) ...[
            _wrap(_facts(f)),
            _gap(8),
            AlertBanner(glyph: act['glyph'] as String, tone: act['tone'] as int, message: act['text'] as String),
          ],
        ]),
      ),
    );
  }

  // עובדות-שבב (אטום-יחיד לגיטימי): סטטוס · הו״ק · הנחה · תזכורות · סיכון · אמצעי
  List<Widget> _facts(Map<String, dynamic> f) {
    final r = _EnrollmentData.risk(f);
    return [
      StatusChip(label: _EnrollmentData.statusOf(f), tone: _EnrollmentData.statusOf(f) == 'תקין' || _EnrollmentData.statusOf(f) == 'מלגה-מלאה' ? 1 : _EnrollmentData.statusOf(f).contains('פיגור') ? 2 : 3),
      if (_EnrollmentData.hasHok(f)) StatusChip(label: _EnrollmentData.hokFlag(f) ? (_EnrollmentData.hokActive(f) ? '💳 הו״ק ${_amounts ? shekel((f['hok'] as Map)['amount'] as num) : ''} · יום ${(f['hok'] as Map)['day']}' : '⚠️ הו״ק נכשלה') : '⏸ הו״ק מופסקת', tone: _EnrollmentData.hokFailed(f) ? 2 : _EnrollmentData.hokFlag(f) ? 1 : 0),
      if (_EnrollmentData.discountLabel(f).isNotEmpty) StatusChip(label: '🎓 ${_EnrollmentData.discountLabel(f)}', tone: 0),
      if (_EnrollmentData.remindersSent(f).isNotEmpty) StatusChip(label: '🔔 ${_EnrollmentData.remindersSent(f).length} תזכורות', tone: _EnrollmentData.remindersSent(f).length > 2 ? 3 : 0),
      if (_EnrollmentData.balance(f) > 0) StatusChip(label: 'סיכון ${_EnrollmentData.riskLabel(r)} · ${_EnrollmentData.tierLabel(f)}', tone: r == 2 ? 2 : r == 1 ? 3 : 1),
      if (_EnrollmentData.lastMethod(f).isNotEmpty) StatusChip(label: '${_EnrollmentData.lastMethod(f)} · ${fmtDate(_EnrollmentData.lastPaymentDate(f))}', tone: 0),
      if (f['nextNote'] != null) StatusChip(label: '📝 ${f['nextNote']}', tone: 0),
    ];
  }

  // ═══ 💳 מבט-הו״ק: תור-לרישום-החודש (hokDue) + רישום-מרוכז דו-שלבי + מצב-כל-ההו״ק ═══
  Widget _hokView(List<Map<String, dynamic>> all, List<Map<String, dynamic>> due) {
    final withHok = all.where(_EnrollmentData.hasHok).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      DsSection(title: '💳 הו״ק לרישום החודש · ${due.length} · ${_m(_EnrollmentData.hokExpected(all))}', tone: 0, children: [
        if (due.isEmpty)
          const EmptyState(glyph: '✅', message: 'כל ההו״ק הפעילות נרשמו החודש')
        else ...[
          for (final f in due)
            TimelineItem(title: '${f['name']} · יום ${(f['hok'] as Map)['day']}', time: _EnrollmentData.hokMethod(f), body: '${_m((f['hok'] as Map)['amount'] as num)} — טרם נרשם החודש'),
          if (_EnrollmentData.can(_role, 'fees.hok')) ...[
            _gap(8),
            // אישור-דו-שלבי: שלב-1 חימוש (הצגת-סיכום) · שלב-2 ביצוע (SoftButton danger) · ביטול
            if (!_hokArmed)
              _wrap([SoftButton(label: '🧾 רישום-הו״ק-חודשי-מרוכז', tone: 0, onTap: () => setState(() => _hokArmed = true))], top: 0)
            else ...[
              AlertBanner(glyph: '⚠️', tone: 3, message: 'שלב 2/2: יירשמו ${due.length} תשלומי-הו״ק בסך ${_m(_EnrollmentData.hokExpected(all))} (${due.map((f) => f['name']).join(' · ')}). לאשר?'),
              _wrap([
                SoftButton(label: '✅ אשר ורשום ${due.length}', tone: 2, onTap: () => setState(() { _EnrollmentData.runHokBatch(all, _roleName); _hokArmed = false; })),
                SoftButton(label: 'בטל', tone: 0, onTap: () => setState(() => _hokArmed = false)),
              ], top: 8),
            ],
          ],
        ],
      ]),
      DsSection(title: '📇 כל הוראות-הקבע · ${withHok.length}', children: [
        for (final f in withHok)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              StatusDot(tone: _EnrollmentData.hokFailed(f) ? 2 : _EnrollmentData.hokFlag(f) ? 1 : 3),
              const SizedBox(width: 10),
              Expanded(child: MediaRow(glyph: '💳', title: f['name'] as String, subtitle: '${_m((f['hok'] as Map)['amount'] as num)} · יום ${(f['hok'] as Map)['day']} · ${_EnrollmentData.hokMethod(f)} · מ-${fmtDate((f['hok'] as Map)['startedAt'] as String?)}')),
              StatusChip(label: _EnrollmentData.hokFailed(f) ? 'נכשלה' : _EnrollmentData.hokFlag(f) ? (_EnrollmentData.hokRecorded(f) ? 'נרשמה החודש' : 'ממתינה') : 'מופסקת', tone: _EnrollmentData.hokFailed(f) ? 2 : _EnrollmentData.hokFlag(f) ? 1 : 0),
              if (_EnrollmentData.can(_role, 'fees.hok')) ...[
                const SizedBox(width: 8),
                SoftButton(label: _EnrollmentData.hokFlag(f) ? '⏸ הפסק' : '▶ הפעל', tone: _EnrollmentData.hokFlag(f) ? 2 : 1, onTap: () => setState(() => _EnrollmentData.toggleHok(f, _roleName))),
              ],
            ]),
          ),
        if (withHok.isEmpty) const EmptyState(glyph: '💳', message: 'אין הוראות-קבע'),
      ]),
    ]);
  }

  // ═══ 🔔 מבט-תזכורות: תזכורת-מדורגת פר-משפחה (segulaReminders) + נוסח (waPaymentText) — פרטי, לא פומבי ═══
  Widget _remindersView(List<Map<String, dynamic>> fs) {
    final due = fs.where((f) => _EnrollmentData.nextReminder(f) != null).toList();
    final sentAll = [for (final f in fs) for (final c in _EnrollmentData.remindersSent(f)) {'f': f, 'c': c}]..sort((a, b) => '${(b['c'] as Map)['at']}'.compareTo('${(a['c'] as Map)['at']}'));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const AlertBanner(glyph: '🛡', tone: 1, message: 'מגן-כבוד: תזכורות פרטיות בלבד · אין תזכורת פומבית · אין חסימת-תלמיד · מלגה-מלאה = אפס-תזכורות'),
      _gap(8),
      DsSection(title: '🔔 מועד-תזכורת הגיע · ${due.length}', tone: due.isEmpty ? 1 : 3, children: [
        if (due.isEmpty)
          const EmptyState(glyph: '🕊', message: 'אין תזכורות שמועדן הגיע')
        else
          for (final f in due) _reminderCard(f),
      ]),
      DsSection(title: '📜 היסטוריית-תזכורות · ${sentAll.length}', children: [
        if (sentAll.isEmpty) const EmptyState(glyph: '📭', message: 'טרם נשלחו תזכורות') else
          for (final x in sentAll)
            TimelineItem(title: '${(x['f'] as Map)['name']} · ${(x['c'] as Map)['grade'] ?? 'תזכורת'}', time: fmtDate((x['c'] as Map)['at'] as String?), body: 'נשלחה בפרטיות'),
      ]),
    ]);
  }

  Widget _reminderCard(Map<String, dynamic> f) {
    final nr = _EnrollmentData.nextReminder(f)!;
    final grade = nr['grade'] as String;
    final plan = _EnrollmentData.reminderPlan(f);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MediaRow(glyph: '🔔', title: '${f['name']} · דרגה: $grade', subtitle: 'יתרה ${_m(_EnrollmentData.balance(f))} · ותק ${_EnrollmentData.agingDays(f)} י׳ · נשלחו ${_EnrollmentData.remindersSent(f).length}'),
        _wrap([for (final p in plan) StatusChip(label: '${p['grade']} · ${fmtDate(p['date'] as String?)}', tone: p['grade'] == grade ? 3 : 0)]),
        if (_amounts) ...[
          _gap(6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF0C0D1E), borderRadius: BorderRadius.circular(10)),
            child: SelectableText(_EnrollmentData.reminderText(f, grade), style: const TextStyle(color: _ink, fontSize: 12.5, height: 1.5)),
          ),
        ],
        if (_EnrollmentData.can(_role, 'fees.remind'))
          _wrap([SoftButton(label: '📨 שלח תזכורת $grade (פרטי)', tone: 3, onTap: () => setState(() => _EnrollmentData.sendReminder(f, _roleName, grade)))], top: 8),
      ]),
    );
  }

  // ═══ 📊 דוחות: מגמת-גבייה (TrendStat⊕trendFromScan) · פירוק-סטטוס (DsBars⊕countBy) · דוח-גזבר-שבועי · סוף-שנה ═══
  Widget _reportsView(List<Map<String, dynamic>> all, Map<String, dynamic> trend, int thisMonth) {
    final counts = _EnrollmentData.statusCounts(all);
    final t = DateTime.parse('${_EnrollmentData.today}T12:00:00');
    final wa = DateTime(t.year, t.month, t.day - 7); // חשבון-תאריך אמיתי (חוצה-חודש) — לא clamp בתוך החודש
    final weekAgo = '${_EnrollmentData.ymOf(wa)}-${wa.day.toString().padLeft(2, '0')}';
    final weekPaid = grandTotal([for (final f in all) for (final p in _EnrollmentData.paymentsOf(f)) if (dateInRange(p['date'] as String, weekAgo, _EnrollmentData.today)) p['amount']], (x) => x as num).toInt();
    final weekRem = grandTotal([for (final f in all) for (final c in _EnrollmentData.remindersSent(f)) if (dateInRange(c['at'] as String, weekAgo, _EnrollmentData.today)) 1], (x) => x as num).toInt();
    final byType = <String, int>{};
    for (final f in all) {
      _EnrollmentData.byType(f).forEach((k, v) => byType[k] = (byType[k] ?? 0) + v);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: TrendStat(value: _m(thisMonth), delta: (trend['pct'] as num).toDouble(), label: 'נגבה החודש · מגמה מול חצי-שנה')),
      ]),
      _gap(10),
      if (_amounts) DsBars(title: 'חיובים לפי-סוג', labels: byType.keys.toList(), values: [for (final v in byType.values) v.toDouble()]),
      _gap(10),
      DsBars(title: 'משפחות לפי-סטטוס', labels: [for (final c in counts) c[0] as String], values: [for (final c in counts) (c[1] as int).toDouble()]),
      _gap(10),
      DsSection(title: '🗓 דוח-גזבר שבועי · מ-${fmtDate(weekAgo)} עד ${fmtDate(_EnrollmentData.today)}', children: [
        Row(children: [
          BareStat(value: _m(weekPaid), label: 'נגבה השבוע', inkColor: _ok, mutedColor: _muted),
          BareStat(value: '$weekRem', label: 'תזכורות השבוע', inkColor: _ink, mutedColor: _muted),
          BareStat(value: '${all.where(_EnrollmentData.hokFailed).length}', label: 'הו״ק נכשלו', inkColor: all.any(_EnrollmentData.hokFailed) ? _danger : _ok, mutedColor: _muted),
          BareStat(value: '${all.where(_EnrollmentData.oldDebt).length}', label: 'חוב-ותיק', inkColor: all.any(_EnrollmentData.oldDebt) ? _danger : _ok, mutedColor: _muted),
        ]),
      ]),
      DsSection(title: '🏁 סוף-שנה · סגירת-חשבונות', children: [
        Row(children: [
          BareStat(value: '${all.where((f) => _EnrollmentData.balance(f) <= 0).length}/${all.length}', label: 'משפחות סגורות', inkColor: _ink, mutedColor: _muted),
          BareStat(value: _m(_EnrollmentData.kOpen(all)), label: 'יתרה להעברה (carryBalance)', inkColor: _EnrollmentData.kOpen(all) > 0 ? _warning : _ok, mutedColor: _muted),
          BareStat(value: _m(grandTotal(all, (f) => _EnrollmentData.credit(f as Map<String, dynamic>))), label: 'זכויות להחזר', inkColor: _acc, mutedColor: _muted),
        ]),
        const AlertBanner(glyph: '🔒', tone: 0, message: 'סגירת-שנה = העברת-יתרות ל-carryBalance של השנה-הבאה (מקום-שמור: פעולת-סוף-שנה נעולה עד אישור-הנהלה)'),
      ]),
      // מקום-שמור: התאמת-תשלומים-נכנסים (matching · strongMatchForCharge) — השער-החיצוני יזין את הרשימה
      DsSection(title: '🔗 התאמת-תשלומים-נכנסים לחיוב (שער-חיצוני · מקום-שמור)', children: [
        for (final inc in _EnrollmentData.incoming)
          () {
            final m = _EnrollmentData.matchIncoming(inc, all);
            return TimelineItem(title: m == null ? '❓ ${inc['name']} — ללא-התאמה (ידני)' : '✅ ${inc['name']} — הותאם: ${m['name']}', time: fmtDate(inc['date'] as String?), body: '${_m(inc['amount'] as num)} · מפתח: ${inc['phone'] != '' ? 'טלפון' : 'מייל'}');
          }(),
      ]),
    ]);
  }

  // ═══ 🧾 אודיט: כל פעולה (מי·מה·מתי) — TimelineItem ═══
  Widget _auditView() => DsSection(title: '🧾 יומן-אודיט · ${_EnrollmentData.audit.length}', children: [
        if (_EnrollmentData.audit.isEmpty)
          const EmptyState(glyph: '🧾', message: 'אין פעולות עדיין — כל חיוב/תשלום/ביטול/הנחה/תזכורת יירשם כאן')
        else
          for (final a in _EnrollmentData.audit)
            TimelineItem(title: '${a['role']} · ${a['family'] == '*' ? 'כלל-המערכת' : _EnrollmentData.families.firstWhere((f) => f['id'] == a['family'], orElse: () => const {'name': '?'})['name']}', time: fmtDate(a['date'] as String?), body: a['what'] as String),
      ]);

  // ═══ פאנל משפחה-נבחרת (GlassCard · bottom-sheet): זהות · יתרה (צבועה-לפי-ותק) · פירוק · טאבים-9 · הפעולה-הנכונה · פעולות ═══
  void _openPanel(Map<String, dynamic> f) {
    var tab = 0;
    if (!_amounts) { // דגל-בלבד: פאנל מצומצם (זהות + דגל + הפניה) — אפס-פרטי-חוב
      showModalBottomSheet<void>(
        context: context, backgroundColor: Colors.transparent,
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(12),
          child: GlassCard(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // ═══ הגרעין על הרשומה (G6d): מצב-הרשומה ⊕ EnrollmentCore.next ⊕ פנקס-overlay — מצב שאינו במחזור-החיים החצוב מדווח כפער, לא מתוקן בשקט ═══
              Builder(builder: (_) {
                final cur = _coreState['${f['id']}'] ?? '${f['status'] ?? EnrollmentCore.states.first}';
                if (!EnrollmentCore.states.contains(cur)) return AlertBanner(message: 'מצב הרשומה "$cur" אינו במחזור-החיים החצוב (${EnrollmentCore.states.join('→')}) — פער זרע/סכמה, מקום-שמור', tone: 3, glyph: '🧠');
                final nx = EnrollmentCore.next(cur);
                return DsSection(title: '🧠 מחזור-חיים · רשומה (גרעין)', children: [
                  Wrap(spacing: 6, runSpacing: 6, children: [for (final st in EnrollmentCore.states) StatusChip(label: st, tone: st == cur ? 1 : 0)]),
                  AlertBanner(message: nx == null ? 'מצב-סופי: $cur' : 'הבא אחרי $cur: $nx', tone: 0, glyph: '🧠'),
                  SoftButton(label: nx == null ? 'אין מעבר' : 'קדם מצב ⇒ $nx', onTap: nx == null ? null : () => setState(() => _coreState['${f['id']}'] = nx)),
                ]);
              }),
              MediaRow(glyph: '👨‍👩‍👧', title: f['name'] as String, subtitle: '${_EnrollmentData.studentsOf(f)} · ${_EnrollmentData.gradesOf(f)}'),
              _gap(10),
              AlertBanner(glyph: _EnrollmentData.balance(f) > 0 ? '🚩' : '✅', tone: _EnrollmentData.balance(f) > 0 ? 3 : 1, message: _EnrollmentData.balance(f) > 0 ? 'דגל-חוב — פרטים וסכומים בגזברות בלבד. לא לפנות לתלמיד/ה (מגן-כבוד).' : 'תקין — אין דגל-חוב'),
            ]),
          ),
        ),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        void act(void Function() fn) { fn(); setSheet(() {}); setState(() {}); }
        final charged = _EnrollmentData.charged(f), paid = _EnrollmentData.paid(f), bal = _EnrollmentData.balance(f), band = _EnrollmentData.agingBand(f);
        final balColor = band == 3 ? _danger : band == 2 ? _warning : band == 1 ? _acc : _ok;
        final actn = _EnrollmentData.rightAction(f);
        return DraggableScrollableSheet(
          initialChildSize: 0.85, minChildSize: 0.4, maxChildSize: 0.97, expand: false,
          builder: (ctx, scroll) => Padding(
            padding: const EdgeInsets.all(12),
            child: GlassCard(
              child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
                MediaRow(glyph: '👨‍👩‍👧', title: f['name'] as String, subtitle: '${f['payer']} · ${f['phone']} · ${_EnrollmentData.studentsOf(f)} (${_EnrollmentData.gradesOf(f)})'),
                _gap(10),
                Row(children: [
                  BareStat(value: _m(bal), label: bal > 0 ? 'יתרה · ותק ${_EnrollmentData.agingDays(f)} י׳' : 'יתרה', inkColor: balColor, mutedColor: _muted),
                  BareStat(value: _m(charged), label: 'חיובים', inkColor: _ink, mutedColor: _muted),
                  BareStat(value: _m(paid), label: 'שולם', inkColor: _ok, mutedColor: _muted),
                  if (_EnrollmentData.credit(f) > 0) BareStat(value: _m(_EnrollmentData.credit(f)), label: 'זכות', inkColor: _acc, mutedColor: _muted),
                ]),
                _gap(8),
                AlertBanner(glyph: actn['glyph'] as String, tone: actn['tone'] as int, message: 'הפעולה-הנכונה: ${actn['text']}'),
                _gap(10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SegmentedSwitch(items: const ['סקירה', 'חיובים', 'תשלומים', 'הו״ק', 'תזכורות', 'הנחות', 'הסדר', 'דוחות', 'אודיט'], selected: tab, onSelect: (i) => setSheet(() => tab = i)),
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
                    if (_EnrollmentData.can(_role, 'fees.charge')) SoftButton(label: '➕ חיוב', tone: 0, onTap: () => _openChargeForm(f, [f], onDone: () => setSheet(() {}))),
                    if (_EnrollmentData.can(_role, 'fees.pay')) SoftButton(label: '💳 רשום תשלום', tone: 1, onTap: () => _openPaymentForm(f, [f], onDone: () => setSheet(() {}))),
                    if (_EnrollmentData.can(_role, 'fees.pay') && bal > 0) SoftButton(label: '➗ תשלום-חלקי (½)', tone: 1, onTap: () => act(() => _EnrollmentData.addPayment(f, _roleName, amount: (bal / 2).ceil(), method: 'מזומן', date: _EnrollmentData.today, note: 'תשלום-חלקי'))),
                    if (_EnrollmentData.can(_role, 'fees.remind') && _EnrollmentData.nextReminder(f) != null) SoftButton(label: '📨 תזכורת ${_EnrollmentData.nextReminder(f)!['grade']}', tone: 3, onTap: () => act(() => _EnrollmentData.sendReminder(f, _roleName, _EnrollmentData.nextReminder(f)!['grade'] as String))),
                    if (_EnrollmentData.can(_role, 'fees.arrangement') && bal > 0 && !_EnrollmentData.hasArrangement(f)) SoftButton(label: '📆 הסדר 3 תשלומים', tone: 0, onTap: () => act(() => _EnrollmentData.setArrangement(f, _roleName, 3))),
                    if (_EnrollmentData.can(_role, 'fees.hok') && _EnrollmentData.hasHok(f)) SoftButton(label: _EnrollmentData.hokFlag(f) ? '⏸ הפסק הו״ק' : '▶ הפעל הו״ק', tone: _EnrollmentData.hokFlag(f) ? 2 : 1, onTap: () => act(() => _EnrollmentData.toggleHok(f, _roleName))),
                    if (_EnrollmentData.can(_role, 'fees.writeoff') && bal > 0 && _EnrollmentData.oldDebt(f)) SoftButton(label: '🗂 סמן חוב-אבוד', tone: 2, onTap: () => act(() => _EnrollmentData.writeOff(f, _roleName))),
                    if (_EnrollmentData.can(_role, 'fees.refund') && _EnrollmentData.credit(f) > 0) SoftButton(label: '💸 החזר-זכות ${_m(_EnrollmentData.credit(f))}', tone: 1, onTap: () => act(() => _EnrollmentData.refund(f, _roleName))),
                    if ((_EnrollmentData.can(_role, 'fees.pay') || _EnrollmentData.can(_role, 'fees.self')) && bal > 0)
                      // שער-חיצוני (מקום-שמור): payLink מחזיר null כש-payUrl ריק ⇒ הכפתור שמור, לא מזייף קישור
                      SoftButton(label: _EnrollmentData.payLinkOf(f) == null ? '🔗 קישור-תשלום (שער לא-מוגדר)' : '🔗 שלח קישור-תשלום', tone: 0, onTap: _EnrollmentData.payLinkOf(f) == null ? null : () {}),
                    SoftButton(label: '🖨 מצב-חשבון', tone: 0, onTap: () => setSheet(() => tab = 7)),
                  ];
                  return acts.isEmpty
                      ? const AlertBanner(message: 'צפייה-בלבד — אין הרשאת-פעולה', glyph: '🔒', tone: 2)
                      : Wrap(spacing: 8, runSpacing: 8, children: acts);
                }),
              ]),
            ),
          ),
        );
      }),
    );
  }

  // סקירה: השוואה (NeonBars) · יחס (StatRow) · פירוק-לפי-סוג (DsBars) · תלמידים · מדדי-דפוס (RFM·מגמה)
  List<Widget> _tabOverview(Map<String, dynamic> f, int charged, int paid, int bal) => [
        if (_amounts) ...[
          NeonBars(labels: const ['חיובים', 'שולם', 'יתרה'], values: [charged.toDouble(), paid.toDouble(), bal.toDouble()], tone: bal > 0 ? (_EnrollmentData.agingBand(f) == 3 ? 2 : 3) : 1),
          _gap(8),
          StatRow(label: 'שולם מתוך חיובים', value: '${shekel(paid)} / ${shekel(charged)}', fraction: charged == 0 ? 0 : paid / charged),
          _gap(8),
          if (_EnrollmentData.byType(f).isNotEmpty) DsBars(title: 'פירוק-חיובים לפי-סוג', labels: _EnrollmentData.byType(f).keys.toList(), values: [for (final v in _EnrollmentData.byType(f).values) v.toDouble()]),
        ],
        _wrap([for (final m in f['absences'] as List) StatusChip(label: '🎓 ${(m as Map)['first']} · ${m['grade']}', tone: 0)]),
        _wrap(_facts(f)),
        _gap(8),
        Row(children: [
          BareStat(value: '${_EnrollmentData.rfm(f)}', label: 'דפוס-תשלום (RFM) · ${_EnrollmentData.tierLabel(f)}', inkColor: _EnrollmentData.tierKey(f) == 'red' ? _danger : _ink, mutedColor: _muted),
          BareStat(value: '${_EnrollmentData.trend(f)['dir'] == 'up' ? '↑' : _EnrollmentData.trend(f)['dir'] == 'down' ? '↓' : '→'} ${_EnrollmentData.trend(f)['pct']}%', label: 'מגמת-תשלומים (6 חודשים)', inkColor: _EnrollmentData.trend(f)['dir'] == 'down' ? _danger : _ok, mutedColor: _muted),
          BareStat(value: _EnrollmentData.riskLabel(_EnrollmentData.risk(f)), label: 'סיכון-גבייה (ותק · דפוס · מגמה)', inkColor: _EnrollmentData.risk(f) == 2 ? _danger : _EnrollmentData.risk(f) == 1 ? _warning : _ok, mutedColor: _muted),
        ]),
      ];

  // חיובים: פירוט (סוג/סכום/תאריך/עבור-מי) + ביטול (סיבה) + כפולים
  List<Widget> _tabCharges(Map<String, dynamic> f, void Function(void Function()) act) {
    final cs = _EnrollmentData.chargesOf(f);
    final dups = _EnrollmentData.duplicateCharges(f).map((c) => c['id']).toSet();
    return [
      if (cs.isEmpty) const EmptyState(glyph: '📭', message: 'אין חיובים למשפחה — לרשום חיוב-שנה'),
      for (final c in cs)
        () {
          final cancelled = c['cancelledAt'] != null || _EnrollmentData.cancelledIds.contains(c['id']);
          final net = _EnrollmentData.netOf(f, c), gross = _EnrollmentData.grossOf(f, c);
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TimelineItem(
              title: '${cancelled ? '🚫 ' : dups.contains(c['id']) ? '👯 ' : ''}${c['cat']} · ${c['memberId']}${c['installmentOf'] != null ? ' · הסדר' : ''}',
              time: fmtDate(c['date'] as String?),
              body: '${cancelled ? 'בוטל: ${_EnrollmentData.cancelReason[c['id']] ?? c['note'] ?? ''}' : _amounts ? (net != gross ? '${shekel(net)} (ברוטו ${shekel(gross)}, הנחה)' : shekel(net)) : '🔒'}${c['note'] != null && !cancelled ? ' · ${c['note']}' : ''}',
            ),
            if (!cancelled && _EnrollmentData.can(_role, 'fees.writeoff'))
              _wrap([SoftButton(label: '✖ בטל חיוב', tone: 2, onTap: () => act(() => _EnrollmentData.cancelCharge(f, _roleName, c, dups.contains(c['id']) ? 'חיוב-כפול' : 'ביטול-ידני')))], top: 2),
          ]);
        }(),
    ];
  }

  // תשלומים: ציר (TimelineItem) + שדות-מטא-שמורים (קבלה/סליקה/חשבונית — מאירים כשיש)
  List<Widget> _tabPayments(Map<String, dynamic> f) {
    final ps = [..._EnrollmentData.paymentsOf(f)]..sort((a, b) => '${b['date']}'.compareTo('${a['date']}'));
    return [
      if (ps.isEmpty) const EmptyState(glyph: '💳', message: 'אין תשלומים רשומים'),
      for (final p in ps)
        TimelineItem(
          title: '${p['method']}${p['method'] == 'הו״ק' ? ' 💳' : ''}',
          time: fmtDate(p['date'] as String?),
          body: '${_m(p['amount'] as num)}${[for (final m in _EnrollmentData.paymentMeta) if (p[m['key']] != null) ' · ${m['prefix']}${p[m['key']]}${m['suffix']}'].join()}',
        ),
      const AlertBanner(glyph: '🧾', tone: 0, message: 'קבלת-מס / אישור-סליקה / חשבונית = שער-חיצוני (מקום-שמור: מס׳-קבלה יואר כאן כשיגיע מהשער; המסך אינו מנפיק)'),
    ];
  }

  // הו״ק: מצב-החודש (hokEffectivelyActive⊕hokRecordedThisMonth) + היסטוריית-סליקה + הפעל/הפסק
  List<Widget> _tabHok(Map<String, dynamic> f, void Function(void Function()) act) {
    if (!_EnrollmentData.hasHok(f)) return [const EmptyState(glyph: '💳', message: 'אין הוראת-קבע למשפחה (מקום-שמור: תוגדר בשער-הסליקה)')];
    final h = f['hok'] as Map;
    final hist = (f['hist'] as List?) ?? const [];
    return [
      Row(children: [
        StatusDot(tone: _EnrollmentData.hokFailed(f) ? 2 : _EnrollmentData.hokFlag(f) ? 1 : 3),
        const SizedBox(width: 10),
        Expanded(child: MediaRow(glyph: '💳', title: '${_m(h['amount'] as num)} · יום ${h['day']} בחודש', subtitle: '${_EnrollmentData.hokMethod(f)} · מ-${fmtDate(h['startedAt'] as String?)}${h['kevaId'] != null ? ' · סליקה ${h['kevaId']}' : ' · ידנית'}')),
      ]),
      _wrap([
        StatusChip(label: _EnrollmentData.hokFlag(f) ? 'מסומנת פעילה' : 'מופסקת', tone: _EnrollmentData.hokFlag(f) ? 1 : 0),
        StatusChip(label: _EnrollmentData.hokActive(f) ? 'סליקה חיה' : 'סליקה פסקה >2 חודשים', tone: _EnrollmentData.hokActive(f) ? 1 : 2),
        StatusChip(label: _EnrollmentData.hokRecorded(f) ? 'נרשמה החודש ✅' : 'טרם נרשמה החודש', tone: _EnrollmentData.hokRecorded(f) ? 1 : 3),
      ]),
      if (_EnrollmentData.hokFailed(f)) ...[
        _gap(6),
        const AlertBanner(glyph: '⚠️', tone: 2, message: 'הו״ק נכשלה — התרעה נשלחה; ניסיון-חיוב-חוזר = שער-הסליקה (מקום-שמור). בינתיים: תזכורת עדינה'),
      ],
      _gap(6),
      Text('היסטוריית-סליקה · ${hist.length}', style: const TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800)),
      for (final e in hist) TimelineItem(title: '${(e as Map)['clearer']}', time: fmtDate(e['d'] as String?), body: _m(e['a'] as num)),
      if (hist.isEmpty) const EmptyState(glyph: '📭', message: 'אין היסטוריית-סליקה (הו״ק ידנית)'),
    ];
  }

  // תזכורות: לוח-מדורג + היסטוריה + תגובה (nextNote)
  List<Widget> _tabReminders(Map<String, dynamic> f, void Function(void Function()) act) {
    final plan = _EnrollmentData.reminderPlan(f), sent = _EnrollmentData.remindersSent(f), nr = _EnrollmentData.nextReminder(f);
    return [
      if (_EnrollmentData.fullScholarship(f)) const AlertBanner(glyph: '🎓', tone: 1, message: 'מלגה מלאה — אפס-תזכורות (מגן-כבוד)') else if (plan.isEmpty) const EmptyState(glyph: '🕊', message: 'אין חוב פתוח — אין לוח-תזכורות') else ...[
        Text('לוח מדורג (מהחיוב-הפתוח-הוותיק ${fmtDate(_EnrollmentData.oldestOpenDate(f))})', style: const TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800)),
        _wrap([for (var i = 0; i < plan.length; i++) StatusChip(label: '${i < sent.length ? '✅' : '${plan[i]['date']}'.compareTo(_EnrollmentData.today) <= 0 ? '⏰' : '⏳'} ${plan[i]['grade']} · ${fmtDate(plan[i]['date'] as String?)}', tone: i < sent.length ? 1 : nr != null && nr['grade'] == plan[i]['grade'] ? 3 : 0)]),
        if (nr != null && _EnrollmentData.can(_role, 'fees.remind')) _wrap([SoftButton(label: '📨 שלח תזכורת ${nr['grade']} (פרטי)', tone: 3, onTap: () => act(() => _EnrollmentData.sendReminder(f, _roleName, nr['grade'] as String)))], top: 8),
      ],
      _gap(8),
      Text('היסטוריה · ${sent.length}', style: const TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800)),
      for (final c in sent) TimelineItem(title: 'תזכורת ${c['grade'] ?? ''}', time: fmtDate(c['at'] as String?), body: 'נשלחה בפרטיות'),
      if (f['nextNote'] != null) AlertBanner(glyph: '📝', tone: 0, message: 'תגובה/מעקב: ${f['nextNote']} (${fmtDate(f['nextDate'] as String?)})'),
    ];
  }

  // הנחות-ומלגות: מדיניות (maxDiscountPct הגבוה-מנצח) · הענקה (הנהלה)
  List<Widget> _tabDiscounts(Map<String, dynamic> f, void Function(void Function()) act) {
    final ids = _EnrollmentData.effectiveCriteria(f);
    return [
      Row(children: [
        BareStat(value: '${_EnrollmentData.discountPct(f)}%', label: 'הנחה אפקטיבית (הגבוהה מנצחת)', inkColor: _acc, mutedColor: _muted),
        BareStat(value: _m(_EnrollmentData.scholarshipOf(f)), label: 'שווי-ההנחה השנה', inkColor: _ink, mutedColor: _muted),
        BareStat(value: '${_EnrollmentData.studentsN(f)}', label: 'אחים (הנחת-אחים אוטו)', inkColor: _ink, mutedColor: _muted),
      ]),
      _wrap([for (final c in _EnrollmentData.criteria) StatusChip(label: '${ids.contains(c['id']) ? '✅ ' : ''}${c['label']} ${c['discountPct']}%', tone: ids.contains(c['id']) ? 1 : 0)]),
      if (_EnrollmentData.can(_role, 'fees.scholarship'))
        _wrap([for (final c in _EnrollmentData.criteria) if (!ids.contains(c['id'])) SoftButton(label: '🎓 הענק ${c['label']}', tone: 0, onTap: () => act(() => _EnrollmentData.grantDiscount(f, _roleName, c['id'] as String)))], top: 8)
      else
        const AlertBanner(glyph: '🔒', tone: 0, message: 'הענקת-מלגה/הנחה = הרשאת-הנהלה'),
    ];
  }

  // הסדר: פריסה (installmentOf) · מצב-כל-תשלום · פיגור
  List<Widget> _tabArrangement(Map<String, dynamic> f, void Function(void Function()) act) {
    final ins = _EnrollmentData.installments(f);
    return [
      if (ins.isEmpty) ...[
        const EmptyState(glyph: '📆', message: 'אין הסדר-תשלומים'),
        if (_EnrollmentData.can(_role, 'fees.arrangement') && _EnrollmentData.balance(f) > 0)
          _wrap([for (final n in const [2, 3, 6]) SoftButton(label: '📆 פריסה ל-$n', tone: 0, onTap: () => act(() => _EnrollmentData.setArrangement(f, _roleName, n)))], top: 4),
      ] else ...[
        if (_EnrollmentData.arrangementLate(f)) const AlertBanner(glyph: '📆', tone: 3, message: 'הסדר בפיגור — תשלום שמועדו עבר לא כוסה'),
        for (final c in ins)
          TimelineItem(title: '${c['note'] ?? 'תשלום-הסדר'}', time: fmtDate(c['date'] as String?), body: '${_m(_EnrollmentData.netOf(f, c))} · ${'${c['date']}'.compareTo(_EnrollmentData.today) <= 0 ? (_EnrollmentData.oldestOpenDate(f) != null && '${c['date']}'.compareTo(_EnrollmentData.oldestOpenDate(f)!) >= 0 ? 'פתוח' : 'כוסה') : 'עתידי'}'),
      ],
    ];
  }

  // מצב-חשבון (הדפסה = מקום-שמור): שורות-אמת להעתקה
  List<Widget> _tabStatement(Map<String, dynamic> f) {
    final lines = <String>[
      'מצב-חשבון · ${f['name']} · ${_EnrollmentData.orgName} · ${fmtDate(_EnrollmentData.today)}',
      'הורה-משלם: ${f['payer']} · ${f['phone']}',
      'תלמידים: ${_EnrollmentData.studentsOf(f)} (${_EnrollmentData.gradesOf(f)})',
      '',
      'חיובים:',
      for (final c in _EnrollmentData.liveCharges(f)) '  ${fmtDate(c['date'] as String?)}  ${c['cat']}  ${c['memberId']}  ${shekel(_EnrollmentData.netOf(f, c))}',
      'תשלומים:',
      for (final p in _EnrollmentData.paymentsOf(f)) '  ${fmtDate(p['date'] as String?)}  ${p['method']}  ${shekel(p['amount'] as num)}',
      '',
      'סך-חיובים ${shekel(_EnrollmentData.charged(f))} · שולם ${shekel(_EnrollmentData.paid(f))} · יתרה ${shekel(_EnrollmentData.balance(f))}',
    ];
    return [
      if (!_amounts) const AlertBanner(glyph: '🔒', tone: 2, message: 'מצב-חשבון דורש הרשאת-כספים') else
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFF0C0D1E), borderRadius: BorderRadius.circular(10)),
          child: SelectableText(lines.join('\n'), style: const TextStyle(color: _ink, fontSize: 12, height: 1.6)),
        ),
      const AlertBanner(glyph: '🖨', tone: 0, message: 'הדפסה/PDF = שער-חיצוני (מקום-שמור) — הטקסט לעיל ניתן להעתקה'),
    ];
  }

  List<Widget> _tabAudit(Map<String, dynamic> f) {
    final rows = _EnrollmentData.audit.where((a) => a['family'] == f['id']).toList();
    return [
      if (rows.isEmpty) const EmptyState(glyph: '🧾', message: 'אין פעולות למשפחה זו עדיין') else
        for (final a in rows) TimelineItem(title: '${a['role']}', time: fmtDate(a['date'] as String?), body: a['what'] as String),
    ];
  }

  // ═══ טפסים (DsEnumField⊕DsNumberField⊕DsDateField⊕DsField⊕DsPrimaryButton): חיוב-חדש / חיוב-מרוכז · רישום-תשלום ═══
  void _openChargeForm(Map<String, dynamic>? fixed, List<Map<String, dynamic>> pool, {VoidCallback? onDone}) {
    var fam = fixed?['id'] as String? ?? (pool.isNotEmpty ? pool.first['id'] as String : '');
    var cat = _EnrollmentData.chargeTypes.first, amount = '', date = _EnrollmentData.today, note = '', member = '', bulk = '';
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        final f = _EnrollmentData.families.firstWhere((x) => x['id'] == fam, orElse: () => _EnrollmentData.families.first);
        final members = [for (final m in f['absences'] as List) '${(m as Map)['first']}'];
        if (!members.contains(member)) member = members.first;
        final grades = _EnrollmentData.grades(_EnrollmentData.families);
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: DraggableScrollableSheet(
            initialChildSize: 0.75, minChildSize: 0.4, maxChildSize: 0.95, expand: false,
            builder: (ctx, scroll) => Padding(
              padding: const EdgeInsets.all(12),
              child: GlassCard(
                child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
                  const MediaRow(glyph: '➕', title: 'חיוב חדש / חיוב-מרוכז', subtitle: 'סוג · סכום · תאריך · עבור-מי — או מרוכז לכל כיתה'),
                  _gap(8),
                  DsEnumField(label: 'משפחה', options: [for (final x in _EnrollmentData.families) '${x['name']}'], value: '${f['name']}', onChanged: (v) => setSheet(() => fam = _EnrollmentData.families.firstWhere((x) => x['name'] == v)['id'] as String)),
                  DsEnumField(label: 'עבור-מי', options: members, value: member, onChanged: (v) => setSheet(() => member = v)),
                  DsEnumField(label: 'סוג-חיוב', options: _EnrollmentData.chargeTypes, value: cat, onChanged: (v) => setSheet(() => cat = v)),
                  DsNumberField(label: 'סכום (₪)', value: amount, onChanged: (v) => amount = v),
                  DsDateField(label: 'תאריך', value: date, onChanged: (v) => setSheet(() => date = v)),
                  DsField(label: 'הערה', hint: 'למשל: טיול שנתי / שם-חוג', value: note, onChanged: (v) => note = v),
                  _gap(6),
                  DsEnumField(label: 'חיוב-מרוכז לכיתה (אופציונלי)', options: ['', ...grades], value: bulk, onChanged: (v) => setSheet(() => bulk = v)),
                  _gap(10),
                  DsPrimaryButton(label: bulk.isEmpty ? 'שמור חיוב' : 'חיוב-מרוכז לכל $bulk', onTap: () {
                    final a = int.tryParse(amount.trim()) ?? 0;
                    if (a <= 0) return;
                    if (bulk.isEmpty) {
                      _EnrollmentData.addCharge(f, _roleName, cat: cat, amount: a, date: date, memberId: member, note: note);
                    } else {
                      for (final x in _EnrollmentData.families) {
                        for (final m in x['absences'] as List) {
                          if ('${(m as Map)['grade']}'.startsWith(bulk)) _EnrollmentData.addCharge(x, _roleName, cat: cat, amount: a, date: date, memberId: '${m['first']}', note: note.isEmpty ? 'חיוב-מרוכז $bulk' : note);
                        }
                      }
                    }
                    Navigator.of(ctx).pop();
                    setState(() {});
                    onDone?.call();
                  }),
                ]),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _openPaymentForm(Map<String, dynamic>? fixed, List<Map<String, dynamic>> pool, {VoidCallback? onDone}) {
    var fam = fixed?['id'] as String? ?? (pool.isNotEmpty ? pool.first['id'] as String : '');
    var method = 'אשראי', amount = '', date = _EnrollmentData.today, note = '';
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        final f = _EnrollmentData.families.firstWhere((x) => x['id'] == fam, orElse: () => _EnrollmentData.families.first);
        final bal = _EnrollmentData.balance(f);
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: DraggableScrollableSheet(
            initialChildSize: 0.7, minChildSize: 0.4, maxChildSize: 0.95, expand: false,
            builder: (ctx, scroll) => Padding(
              padding: const EdgeInsets.all(12),
              child: GlassCard(
                child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
                  MediaRow(glyph: '💳', title: 'רישום תשלום', subtitle: 'יתרה נוכחית ${_m(bal)} · המסך רושם — אינו סולק'),
                  _gap(8),
                  DsEnumField(label: 'משפחה', options: [for (final x in _EnrollmentData.families) '${x['name']}'], value: '${f['name']}', onChanged: (v) => setSheet(() => fam = _EnrollmentData.families.firstWhere((x) => x['name'] == v)['id'] as String)),
                  DsEnumField(label: 'אמצעי', options: _EnrollmentData.payMethodsSchool, value: method, onChanged: (v) => setSheet(() => method = v)),
                  DsNumberField(label: 'סכום (₪) · ריק = מלוא-היתרה', value: amount, onChanged: (v) => amount = v),
                  DsDateField(label: 'תאריך', value: date, onChanged: (v) => setSheet(() => date = v)),
                  DsField(label: 'הערה / אסמכתא', hint: 'אסמכתת-העברה (לא מס׳-קבלה)', value: note, onChanged: (v) => note = v),
                  _gap(10),
                  DsPrimaryButton(label: 'רשום תשלום', onTap: () {
                    final a = amount.trim().isEmpty ? bal : (int.tryParse(amount.trim()) ?? 0);
                    if (a <= 0) return;
                    _EnrollmentData.addPayment(f, _roleName, amount: a, method: method, date: date, note: note);
                    Navigator.of(ctx).pop();
                    setState(() {});
                    onDone?.call();
                  }),
                ]),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ═══ ייצוא (toCsv⊕csvEscape⊕exportAllowed) — הרשימה-הנראית; בסנדבוקס ההורדה חסומה ⇒ תצוגה+העתקה ═══
  void _openExport(List<Map<String, dynamic>> fs) {
    final csv = _EnrollmentData.csvOf(fs);
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.92, expand: false,
        builder: (ctx, scroll) => Padding(
          padding: const EdgeInsets.all(12),
          child: GlassCard(
            child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
              MediaRow(glyph: '⬇', title: 'ייצוא CSV', subtitle: '${fs.length} משפחות · ${_EnrollmentData.csvHeader.length} עמודות (PDF = שער-חיצוני, מקום-שמור)'),
              _gap(10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF0C0D1E), borderRadius: BorderRadius.circular(10)),
                child: SelectableText(csv, textDirection: TextDirection.ltr, style: const TextStyle(color: _ink, fontSize: 12, height: 1.6)),
              ),
            ]),
          ),
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

// ═══ תפר-עובדות ציבורי (G9b · לרכזת-האפליקציה): EnrollmentFacts — נגזרות-אמת של דאטה-המודול; כל ערך = ביטוי חי על הזרע/המנועים (§20-ג), אפס ליטרל-מומצא. מחולל: retarget.mjs ═══
class EnrollmentFacts {
  static const String entity = 'Enrollment';
  static const String label = 'שיבוצים'; // מונח-הישות מ-entity-terms (דאטה)
  static int get count => _EnrollmentData.families.length; // רשומות הזרע-הראשי "families" (static-const)
  static const List<Map<String, String>> metricDefs = <Map<String, String>>[]; // 0 מדדים חצובים משורת-ה-KPI של הזהב (BareStat/StatHero ⇐ getter-סטטי מספרי) — אין getter-סטטי בשורת-ה-KPI ⇒ ריק, לא מומצא
  static Map<String, String> get metrics => <String, String>{};
  static const String heroKey = 'count'; // אין מדדים ⇒ count
  static String get hero => metrics[heroKey] ?? '$count';
  static String get heroLabel => label;
  static const String idKey = 'id'; // מפתח-המזהה בזרע (אחרי retarget)
  static List<Map<String, dynamic>> get rows => _EnrollmentData.families; // כל רשומות הזרע-הראשי (static-const)
  static Map<String, dynamic>? byId(String id) { for (final r in [for (final k in const <String>[]) ...heroRows(k), ...rows]) { if ('${r[idKey] ?? r['id']}' == id) return r; } return null; } // שורות-המדד קודם (הן מסוג-הרשומה שהפאנל צורך — בזהב-התלמידים הפאנל פותח תלמיד, הזרע-הראשי-לפי-מפתחות הוא families), ואז הזרע-הראשי
  static List<Map<String, dynamic>> heroRows(String key) { switch (key) {  default: return const []; } } // G10a · 0 מדדים עם שורות (צורת X.where(P).length)
  static String? get heroFirstId { final r = heroRows(heroKey); return r.isEmpty ? null : '${r.first[idKey]}'; } // הרשומה-הראשונה של ה-hero — יעד-הקפיצה מהרכזת
}
