// 🗺️ קובץ-ראשי · פירוק-מסך מנהל-המערכת (מרכז השליטה) — buildsmart
// מוצא קדוש (חוק-2): scratchpad/all-screens/screens__manager_dashboard_screen.dart (5,540ש)
// מפת-מכונה: screens-seed/machine/screens__manager_dashboard_screen.json
// תוכן: dart-data-bs/screens__manager_dashboard_screen_content.dart (שמות-סמנטיים, verbatim)
//
// ── אטומי-מדף (הכרעה-5: צריכה, לא שכפול) ────────────────────────────────────
// נבדק מול widget-dedup.json + עשרת אטומי-המדף ב-dart-ui-bs/. תוצאה:
//  • widget-dedup מיפה מהמסך הזה רק את 4 שלדי-ה-State הטריוויאליים (6ש:
//    _OrdersTab/_CustomersTab/_PendingApprovalPanel/_ManageTab) — קבוצת-שלדים
//    כללית, לא מנגנון-תצוגה. אף widget חזותי של המסך לא קובץ עם אטום-מדף.
//  • HeroCard (מדף) = כרטיס-שטוח (cardColor+border, glyph 28); ההירואים כאן =
//    גרדיאנט-מותג + glyph 34 + badge — מנגנון שונה ⇒ gradient_hero_card.dart.
//  • PillButton (מדף) = ריפוד קבוע 16/12, fs14; כפתורי-הגלולה כאן = 4 וריאנטים
//    (8/14·fs13 · 14·fs15 · 9·fs13.5+מסגרת · 12·fs14) — המקור קדוש ⇒
//    pill_cta_button.dart פרמטרי אחד שמאחד את ארבעתם.
//  • StatTile/BareStat (מדף) = טיפוגרפיה 17/12 + צל; פסי-הסטטיסטיקה כאן =
//    20/12.5 בתוך כרטיס-מסגרת אחד ⇒ summary_stat_strip.dart (איחוד
//    _OrderSummary+_CustomerSummary — מנגנון זהה ביט-אחר-ביט ×2 במקור).
//  • OrderCard/TitledSection/QuickToolsList/WorkPathCard/EmptyStateCard/
//    PlaceholderRow — אין מקבילה מבנית במסך (נבדק מול הגוף).
//
// ── איחודי-מנגנון בתוך-המסך (הכרעה-5 פנימית) ────────────────────────────────
//  gradient_hero_card   ← _CopilotHero + _StudioHero
//  summary_stat_strip   ← _OrderSummary + _CustomerSummary
//  filter_chip_pill     ← chip() של _OrderStageChips + _CustomerStatusChips + _AccountFilterChips
//  tinted_tag           ← _StagePill + _ApprovalBadge + _RoleBadge + _RfmPill
//  pill_cta_button      ← _AdvanceButton + _SheetAdvanceButton + _ApprovalButton + כפתור-הרגרסיה
//  sheet_stat_tile      ← tile() של _OrderDetailSheet + _CustomerDetailSheet
//  label_value_row      ← row() של שני הגיליונות + _ManageRow + שורות _SavedCustomerSection
//  muted_note           ← _JourneyEmpty + _ManageHint + כל שורות-הריק/ההערה המושתקות
//  sheet_header         ← ראש שני הגיליונות (glyph·כותרת·תת-כותרת ממורכזים)
//  outlined_action_button ← 6 מופעי OutlinedButton.icon (חשבונית/קבלה/תעודה/CSV/צ׳אט/הסבר-אשראי)
//
// ── התרת-סבך: קריאת-provider ⇒ prop/callback (מה הקופסה תזרים) ──────────────
//  boardAuthProvider        ⇒ הקופסה בונה שער-כניסה (WelcomeScreen) לפני ההרכבה
//  managerTabProvider       ⇒ SegmentedPillToggle.activeIndex + onSelect(i);
//                             AttentionRow.onTap / MetricTile.onTap / ProgressStatRow.onTap
//                             = כתיבת-טאב ע"י הקופסה (drillTab מה-content)
//  orgConfigProvider+kIntelLive ⇒ הקופסה גוזרת כמה טאבים להרכיב (4/5)
//  connectionStatusProvider ⇒ LiveStatusPill.text/colors (connectionPillContent)
//  managerAnalyticsProvider ⇒ ערכי MetricTile (value) + גופי-ניהול (קטגוריות/עץ)
//  ordersEngineProvider     ⇒ ספירות-שלב (ProgressStatRow.fraction/count), רשימת
//                             OrderRowCard, גיליון-ההזמנה; advance() = callback
//  screenSectionsProvider   ⇒ סדר/הסתרת סקציות-הקוקפיט (הקופסה ממיינת ילדים)
//  claudeGatewayProvider    ⇒ בחירת subtitle חי/כבוי להירו (content.live/offline)
//  studioCoEditorProvider   ⇒ שער-הרכבה להירו-הסטודיו + בחירת subtitle
//  attentionItemsProvider   ⇒ שורות AttentionRow (tag/title/sev) — ריק ⇒ לא מרכיבים
//  customerCreditProvider/fleetCreditProvider/customerScoreProvider
//                           ⇒ מספרי-אשראי/RFM מפורמטים לפני ההזרקה לכרטיס
//  directoryProvider        ⇒ שורות PendingCheckRow + תגי-סטטוס/תפקיד
//  userApproverProvider/userDeleterProvider/vacationRequestsProvider/tasksProvider/
//  workerNotifsProvider/chatEngineProvider/usersLookupProvider/currentUidProvider/
//  savedCustomerForProvider/savedCustomersProvider/intelLogProvider
//                           ⇒ callbacks בלבד (onApprove/onReject/onDelete/onSend…)
//  HelpTarget (#31)         ⇒ עטיפת-קופסה (wrapPill/סלוט) — לא ידע-אטום
//  CfgText/CfgVisible (studio) ⇒ הקופסה מזריקה את הטקסט-האפקטיבי / מגדרת הרכבה
//  ContactActions / taskPhotoWidget ⇒ סלוטי-Widget (contact/photo) שהקופסה מזרימה
//
// ── רשימת-האטומים בתיקייה ────────────────────────────────────────────────────
const managerDashboardAtoms = [
  'status_dot', 'live_status_pill', 'segmented_pill_toggle',
  'gradient_hero_card', 'outlined_card_section', 'attention_row',
  'metric_tile', 'two_per_row_grid', 'progress_stat_row',
  'summary_stat_strip', 'filter_chip_pill', 'tinted_tag',
  'mini_stage_tracker', 'pill_cta_button', 'order_row_card',
  'sheet_header', 'sheet_stat_tile', 'label_value_row', 'notice_bar',
  'outlined_action_button', 'credit_bar', 'customer_card',
  'pending_check_row', 'journey_row', 'muted_note',
  'accordion_section_card', 'count_badge', 'intro_banner',
  'approval_task_card', 'vacation_request_card', 'brand_list_row',
];
