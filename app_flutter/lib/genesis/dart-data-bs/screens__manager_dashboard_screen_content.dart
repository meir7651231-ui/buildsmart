// 📦 דאטה-תוכן · מסך מנהל-המערכת (מרכז השליטה) — כל התוכן שהיה צרוב ב-widgets.
// מוצא: buildsmart screens/manager_dashboard_screen.dart (5,540ש) — verbatim, אפס-המצאה.
// ליטוש-סוכן מעל פלט-המכונה (screen-lift): שמות-סמנטיים במקום tpl_x/translit,
// קיבוץ פר-מנגנון, והשלמת מה שהמכונה פספסה (מחלקות-State, קבועי-צמרת, מפות-שלבים).
// מוסכמות:
//  • `// = uiTerms t_xxxx` — המונח קיים בקטלוג-המונחים (screens-seed/terms-catalog.json,
//    dart-data-bs/ui_terms.dart); הקופסה רשאית לצרוך termOf(key) — לא הגדרה-חדשה,
//    הערך כאן משוכפל רק לקריאוּת ולבדיקת-השימור.
//  • `Tpl` בסוף שם = תבנית-`$` מהמקור (raw string): הקופסה מפרמטת, המנגנון מקבל
//    מחרוזת-מוכנה (הכרעת props-plan: "תבניות-$ — הקופסה מפרמטת").
//  • צבעי-שלב/סטטוס = int hex (פיגמנט-דאטה); הקופסה עוטפת Color(x).

// ── שלד-המסך: AppBar + פעולות (ManagerDashboardScreen) ──────────────────────
const managerShellContent = (
  title: 'מרכז השליטה', // cfg: manager.dash.title
  subtitle: 'מנהל המערכת', // cfg: manager.dash.subtitle · = uiTerms t_2da6cebc
  exitLabel: '‹ יציאה', // cfg: manager.dash.exit · = uiTerms t_83d2297d
  chatTooltip: 'שיחות', // = uiTerms t_e537a4bf
  chatHelpTitle: 'שיחות',
  chatHelpBody:
      'פותח את מרכז השיחות של מנהל המערכת — קריאה ומענה לשרשורי '
      'הצ׳אט מול עובדים, קבלנים, חנויות ושליחים. נפתח כמסך עצמאי '
      'וחוזר אחורה ללוח; אינו מתנתק ואינו מחליף תפקיד.',
  profileTooltip: 'פרופיל', // = uiTerms t_e1ea2811
  profileHelpTitle: 'אזור אישי', // = uiTerms t_ffda2cc1
  profileHelpBody:
      'פותח את האזור האישי של מנהל המערכת: פרטי החשבון, סטטיסטיקת '
      'הזמנות חיה, ומעבר להגדרות ולהחלפת תפקיד מוגנת בקוד.',
  settingsTooltip: 'הגדרות', // = uiTerms t_47cfdefb
  settingsHelpTitle: 'הגדרות הקטלוג',
  settingsHelpBody:
      'פותח את הגדרות הקטלוג והאפליקציה — שליטת No-Code על '
      'הפרמטרים שכל הקבלנים רואים.',
);

/// 4 הטאבים + הטאב-החמישי מגודר-קומפילציה (kIntelLive) — מקור: _kManagerTabs.
const managerTabsContent = [
  (emoji: '📊', label: 'לוח בקרה'),
  (emoji: '🚚', label: 'הזמנות'), // = uiTerms t_d0776cb6
  (emoji: '👥', label: 'לקוחות'),
  (emoji: '🛠️', label: 'ניהול'),
  (emoji: '📡', label: 'מודיעין לקוחות'), // רק כש-kIntelLive && moduleOn('intel')
];

/// עזרת-#31 פר-טאב (title, body) בנעילת-אינדקס עם managerTabsContent — _kManagerTabHelp.
const managerTabHelpContent = [
  (
    title: 'לוח בקרה',
    body: 'מציג את לוח הבקרה החי: אריחי מדדים (הזמנות פתוחות, מוצרים, חנויות) '
        'וצינור ההזמנות לפי שלב.',
  ),
  (
    title: 'הזמנות',
    body: 'פותח את מרכז ניהול ההזמנות החי — רשימת ההזמנות, סינון לפי שלב וקידום '
        'שלב (עקיפת-מנהל).',
  ),
  (
    title: 'לקוחות',
    body: 'מציג את רשימת הקבלנים-הלקוחות החיה: ניצול אשראי, מספר אתרים והזמנות '
        'לכל קבלן.',
  ),
  (
    title: 'ניהול',
    body: 'פותח את מרכז הניהול (No-Code): אישורי משימות, בקשות חופשה, קטגוריות, '
        'הגדרות אפליקציה, עץ מוצרים, מותגים ושיוך תפקידים.',
  ),
  (
    title: 'מודיעין לקוחות',
    body: 'מציג מודיעין לקוחות חי: משפך המרה, פלחי לקוחות, שימור ומי מחובר כעת — '
        'מקופל מהמכשיר, קריאה בלבד למנהל.',
  ),
];

/// גלולת-סטטוס-החיבור (_LivePill) — הקופסה ממפה ConnectionStatus ⇒ שורה.
const connectionPillContent = [
  (status: 'connected', label: 'חי', fg: 0xFF1B7A3D, bg: 0xFFE7F6EC),
  (status: 'disconnected', label: 'מנותק', fg: 0xFFB23B3B, bg: 0xFFFCE9E7),
  (status: 'demo', label: 'דמו', fg: 0xFF6F6656, bg: 0xFFEDEAE3), // = uiTerms t_e9791e31
];

// ── 📊 לוח בקרה (M2) ─────────────────────────────────────────────────────────
const copilotHeroContent = (
  glyph: '🤖',
  title: 'שאל את העסק שלך', // cfg: manager.cockpit.copilot.title
  semanticsLabel: 'קו-פיילוט — שאל את העסק שלך',
  liveSubtitle: 'מה בוער? מי הלקוח הכי שווה? — אני עונה מהנתונים החיים',
  offlineSubtitle: 'מודיעין-עסקי AI · דורש חיבור לשרת',
);

const studioHeroContent = (
  glyph: '🎬',
  title: 'סטודיו — ערוך את האפליקציה', // cfg: manager_dashboard_screen.studio_hero_title
  semanticsLabel: 'סטודיו — ערוך את האפליקציה',
  experimentalBadge: 'ניסיוני', // cfg: manager_dashboard_screen.studio_experimental_badge
  aiSubtitle: 'תאר בעברית מה לשנות — או בנה ידנית · אני עורך את הנתונים',
  manualSubtitle: 'בנייה ידנית עובדת תמיד · העורך החכם דורש חיבור לשרת',
);

const attentionCardContent = (title: '🔔 דורש טיפול');

/// 5 אריחי-ה-KPI (_MetricGrid) — value חי מ-managerAnalyticsProvider; drillTab =
/// הטאב שהקופסה כותבת ל-managerTabProvider בלחיצה.
const metricTilesContent = [
  (emoji: '🚚', label: 'הזמנות פתוחות', cfgId: 'manager.cockpit.kpi.openOrders', drillTab: 1),
  (emoji: '📦', label: 'מוצרים בקטלוג', cfgId: 'manager.cockpit.kpi.products', drillTab: 3),
  (emoji: '🧰', label: 'אביזרים נלווים', cfgId: 'manager.cockpit.kpi.accessories', drillTab: 3),
  (emoji: '✅', label: 'זמינים כעת', cfgId: 'manager.cockpit.kpi.available', drillTab: 3),
  (emoji: '🏪', label: 'חנויות פעילות', cfgId: 'manager.cockpit.kpi.stores', drillTab: 3),
];

const pipelineCardContent = (title: 'צינור ההזמנות'); // cfg: manager.dash.pipeline.title

/// תוויות-הצינור הקצרות + צבע-שלב (_OrderPipeline._stageLabel/_stageColor) —
/// verbatim מהלגאסי md-pipe; pickup ירש את ירוק-ready.
const pipelineStages = [
  (stage: 'new', label: 'התקבלה', color: 0xFF1F6F6B),
  (stage: 'preparing', label: 'בהכנה', color: 0xFFF2A516),
  (stage: 'ready', label: 'מוכן', color: 0xFF1F8A4C),
  (stage: 'pickup', label: 'נאסף', color: 0xFF1F8A4C),
  (stage: 'transit', label: 'בדרך', color: 0xFF2B7DB8),
  (stage: 'delivered', label: 'נמסר', color: 0xFF8B8D8F),
];

// ── 🚚 הזמנות (M3) ───────────────────────────────────────────────────────────
/// תוויות-השלב המלאות + צבע-גלולה (_kOrderStageLabel/_kOrderStageColor) —
/// verbatim מהלגאסי ORDER_STAGE; נבדלות במכוון מהקצרות של הצינור.
const orderStages = [
  (stage: 'new', label: 'התקבלה', color: 0xFF1F6F6B),
  (stage: 'preparing', label: 'בהכנה', color: 0xFFF2A516),
  (stage: 'ready', label: 'מוכן לאיסוף', color: 0xFF1F8A4C),
  (stage: 'pickup', label: 'נאסף', color: 0xFF1F8A4C),
  (stage: 'transit', label: 'בדרך לאתר', color: 0xFF1F8A4C),
  (stage: 'delivered', label: 'נמסר ✓', color: 0xFF8B8D8F),
];

const orderSummaryContent = (
  totalLabel: 'הזמנות', // = uiTerms t_d0776cb6
  openLabel: 'פתוחות',
  revenueLabel: 'מחזור',
);

const orderStageChipsContent = (
  allLabel: 'הכל', // = uiTerms t_5f8fb8a5
  helpTitle: 'סינון לפי שלב',
  helpBody: 'מסנן את רשימת ההזמנות לשלב שנבחר; ׳הכל׳ מציג את כולן. רק שלבים '
      'שיש בהם הזמנות מופיעים. סינון תצוגה בלבד — אינו משנה דאטה.',
);

/// _OrdersTabState (מחלקת-State — המכונה לא סרקה): שורת-ריק + טוסטים-בפעולה.
const ordersTabContent = (
  emptyLine: 'לא נמצאו הזמנות תואמות.', // cfg: manager.orders.empty
  alreadyDeliveredToast: 'ההזמנה כבר הושלמה',
  advancedToastTpl: r'הזמנה ${o.id} → ${_kOrderStageLabel[live.stage] ?? live.stage}',
);

const orderRowContent = (
  idPrefixGlyph: '📦', // הקופסה מרכיבה '📦 ${order.id}'
  semanticsTpl: r'📦 ${order.id} · ${order.who} · $stageLabel',
  idTpl: r'📦 ${order.id}',
  footerTpl: r'${order.items} פריטים · ₪${_grouped(order.sum)}',
  completedBadge: '✓ הושלם', // cfg: manager_dashboard_screen.order_completed_badge
  helpTitle: 'פרטי הזמנה',
  helpBody: 'פותח את גיליון פרטי ההזמנה: מעקב 6 שלבים, פריטים/סכום, '
      'קבלן/אתר/סטטוס ופעולת קידום שלב.',
  advanceHelpTitle: 'קדם שלב להזמנה',
  advanceHelpBody: 'מקדם את ההזמנה לשלב הבא בצינור '
      '(התקבלה→בהכנה→מוכן→נאסף→בדרך→נמסר). עקיפת-מנהל '
      'המעדכנת מיד את כל הלוחות. הזמנה שנמסרה אינה ניתנת '
      'לקידום.',
);

const advanceButtonContent = (label: 'קדם שלב ›'); // cfg+gate: manager.orders.advance

const orderDetailSheetContent = (
  glyph: '📦',
  itemsLabel: 'פריטים',
  sumLabel: 'סכום',
  stepLabel: 'שלב',
  contractorLabel: 'קבלן', // = uiTerms t_804ba9cf
  siteLabel: 'אתר',
  statusLabel: 'סטטוס',
  advanceToTpl: r'קדם ל"${_kOrderStageLabel[next] ?? next}"',
  completedNote: '✓ ההזמנה הושלמה ונמסרה', // cfg: manager_dashboard_screen.order_completed_delivered
  printFallbackToast: 'הדפסה זמינה בדפדפן',
  invoiceButton: '🧾 הפק חשבונית', // gate: orders.invoicing
  receiptButton: '💵 הפק קבלה', // gate: orders.invoicing
  deliveryNoteButton: '📦 תעודת משלוח', // gate: orders.deliveryNote
);

const sheetAdvanceButtonContent = (
  label: 'קדם לשלב הבא',
  helpTitle: 'קדם לשלב הבא',
  helpBody: 'מקדם את ההזמנה לשלב הבא ישירות מתוך גיליון הפרטים. אותה עקיפת-מנהל '
      'כמו ׳קדם שלב׳ ברשימה; השלב מתעדכן בכל הלוחות.',
);

// ── 👥 לקוחות (M4) ───────────────────────────────────────────────────────────
/// סטטוס-לקוח (רשימה) — _kCustomerStatusLabel/_kCustomerStatusColor, verbatim לגאסי.
const customerStatuses = [
  (status: 'live', label: 'פעיל', color: 0xFF1F8A4C),
  (status: 'low', label: '⚠️ אשראי גבוה', color: 0xFFF2A516),
  (status: 'off', label: 'לא פעיל', color: 0xFF8B8D8F),
];

/// תגית-הסטטוס הארוכה בגיליון-הפרטים — _CustomerDetailSheet._tagLabel.
const customerDetailTags = [
  (status: 'live', label: '🟢 קבלן פעיל'),
  (status: 'low', label: '⚠️ ניצול אשראי גבוה'),
  (status: 'off', label: 'לא פעיל'),
];

const customerSummaryContent = (
  contractorsLabel: 'קבלנים',
  totalSpendLabel: 'סך רכש',
  creditPctLabel: 'ניצול אשראי',
);

const customerStatusChipsContent = (
  allLabel: 'הכל', // = uiTerms t_5f8fb8a5
  liveChip: 'פעיל',
  lowChip: 'אשראי גבוה',
  helpTitle: 'סינון קבלנים',
  helpBody: 'מסנן את רשימת הקבלנים לפי סטטוס אשראי (פעיל / אשראי גבוה); '
      '׳הכל׳ מציג את כולם. סינון תצוגה בלבד.',
);

/// #reg-approval — צ׳יפי-סינון-חשבון (_AccountFilterChips._options), verbatim.
const accountFilterOptions = [
  (key: 'all', label: 'הכל'), // = uiTerms t_5f8fb8a5
  (key: 'pending', label: 'ממתינים'),
  (key: 'active', label: 'פעילים'),
  (key: 'customers', label: 'לקוחות בלבד'),
];

/// _CustomersTabState (מחלקת-State — המכונה לא סרקה).
const customersTabContent = (
  emptyLine: 'לא נמצאו קבלנים תואמים.', // cfg: manager.customers.empty
  csvImportButton: '⬆️ ייבוא לקוחות מ-CSV', // gate: manager.customers
  searchHintPrefix: 'חיפוש ', // הקופסה משרשרת orgTerm('nav.customers', 'לקוחות')
  searchHintEntityFallback: 'לקוחות',
  searchClearTooltip: 'נקה', // = uiTerms t_e8b3a3d5
);

/// GIANT Phase-2 — דרגות-RFM (_kRfmTierEmoji/_kRfmTierLabel) + מצב-סיכון.
const rfmTiers = [
  (tier: 'champion', emoji: '🏆', label: 'לקוח מוביל'), // term: scoring.tier.champion
  (tier: 'loyal', emoji: '⭐', label: 'לקוח קבוע'),
  (tier: 'occasional', emoji: '🔹', label: 'לקוח מזדמן'),
  (tier: 'dormant', emoji: '💤', label: 'רדום'),
];
const rfmAtRiskContent = (emoji: '⚠️', label: 'בסיכון', color: 0xFFB54708);

const customerCardContent = (
  glyph: '👷',
  semanticsTpl: r'👷 ${c.name} · $statusLabel',
  subTpl: r'${c.orderCount} הזמנות · ${view.sites} אתרים',
  noCreditLine: 'אשראי: לא רשומה',
  creditLineTpl: r'ניצול אשראי: ₪${_grouped(c.totalSpend)} / ₪${_grouped(liveLimit)} ($pct%)',
  helpTitle: 'פרטי קבלן',
  helpBody: 'פותח את גיליון פרטי הקבלן: מסגרת אשראי, נוצל, יתרה זמינה, אתרי '
      'בנייה ורשימת ההזמנות שלו. תצוגה בלבד.',
);

const creditBarContent = (semanticsTpl: r'ניצול אשראי $pct%');

const customerDetailSheetContent = (
  glyph: '👷',
  ordersLabel: 'הזמנות', // = uiTerms t_d0776cb6
  totalSpendLabel: 'סך רכש',
  creditLabel: 'אשראי',
  creditLimitRow: 'מסגרת אשראי',
  notRegistered: 'לא רשומה',
  usedRow: 'נוצל',
  balanceRow: 'יתרה זמינה',
  sitesRow: 'אתרי בנייה',
  creditExplainButton: 'הסבר אשראי', // cfg: manager_dashboard_screen.credit_explain_btn
  creditExplainGlyph: '💳',
  customerOrdersTpl: r'ההזמנות של ${c.name}',
  orderIdTpl: r'📦 ${o.id}',
);

/// _CustomerChatButtonState (מחלקת-State; המקור בגרשיים-כפולים — המכונה לא תפסה).
const customerChatContent = (
  chatButton: "צ'אט עם הלקוח",
  glyph: '💬',
  signInFirstToast: "יש להתחבר כדי לפתוח צ'אט",
  noAccountToast: "ללקוח אין עדיין חשבון בצ'אט",
);

// ── #reg-approval — אישורי-הרשמה ─────────────────────────────────────────────
/// תווית-תפקיד עברית פר-BsRole (_kBsRoleLabel); bot = ריק במכוון.
const bsRoleLabels = [
  (role: 'contractor', label: 'קבלן'), // = uiTerms t_804ba9cf
  (role: 'manager', label: 'מנהל'), // = uiTerms t_409634c7
  (role: 'store', label: 'חנות'),
  (role: 'courier', label: 'שליח'),
  (role: 'worker', label: 'עובד'),
  (role: 'bot', label: ''),
];

const approvalBadgeContent = (
  pendingLabel: '⏳ ממתין',
  pendingColor: 0xFFB07400,
  activeLabel: '✓ פעיל',
  activeColor: 0xFF1F8A4C,
);

/// _CustomerActionRowState (מחלקת-State — המכונה לא סרקה).
const customerActionsContent = (
  approveButton: '✓ אשר',
  suspendButton: '⏸️ השהה',
  changeRoleButton: '🔑 שנה תפקיד',
  deleteButton: '🗑️ מחק',
  approvedToast: '✓ אושר',
  suspendedToast: '⏸️ הושהה',
  noopToast: 'לא בוצעה פעולה',
  failedToast: 'הפעולה נכשלה — נסה שוב',
  deleteConfirmTitle: 'מחיקת משתמש',
  deleteConfirmTpl: r'למחוק לצמיתות את ${widget.view.customer.name} מכל המערכות '
      '(חשבון + כל הנתונים)? הפעולה בלתי-הפיכה.',
  deleteConfirmLabel: 'מחק', // = uiTerms t_09b6bcca
  deletedToast: 'המשתמש נמחק',
  deleteFailedToast: 'המחיקה נכשלה — נסה שוב',
);

/// _PendingApprovalPanelState (מחלקת-State — המכונה לא סרקה).
const pendingApprovalPanelContent = (
  bellGlyph: '🔔',
  titleTpl: r'אישור משתמשים חדשים (${pending.length})',
  body: 'משתמשים חדשים נולדים כ״ממתינים״ ואינם יכולים לקנות עד לאישור. '
      'בחר את מי לאשר (ברירת-מחדל: הכל).',
  approveAllTpl: r'אשר הכל (${pendingUids.length})',
  approveSelectedTpl: r'אשר מסומנים (${selected.length})',
  approvedNToast: r'✓ אושרו $n משתמשים',
  noneApprovedToast: 'לא בוצע אישור',
  approveFailedToast: 'האישור נכשל — נסה שוב',
);

const pendingRowContent = (
  pendingTag: '⏳ ממתין',
  pendingTagColor: 0xFFB07400,
  nameWithRoleTpl: r'${entry.displayName} · $roleLabel',
);

// ── 🧭 מסע-הלקוח (kIntelLive) ────────────────────────────────────────────────
const journeyContent = (
  title: '🧭 מסע הלקוח', // cfg: manager_dashboard_screen.journey_title
  noKeyEmpty: 'אין מזהה לקוח לשיוך — המסע יופיע כשייווצר מזהה יציב.',
  noActivityEmpty: 'אין פעילות מתועדת ללקוח זה עדיין.',
  stuckPill: 'תקוע',
  stuckSemanticsSuffix: ', תקוע',
);

/// GIANT Phase-2 — כרטיס-הלקוח-השמור (_SavedCustomerSection/_SavedCustomerEditor).
const savedCustomerContent = (
  sectionTitle: 'פרטי לקוח', // term: entity.customer (orgTerm)
  phoneLabel: 'טלפון', // = uiTerms t_737232c2
  emailLabel: 'מייל',
  notesLabel: 'הערות',
  tagsLabel: 'תגיות (מופרדות בפסיק)',
  emptyLine: 'אין פרטי לקוח שמורים עדיין',
  addButton: 'הוסף פרטי לקוח',
  addGlyph: '➕',
  editButton: 'ערוך פרטי לקוח',
  editGlyph: '✏️',
  saveButton: 'שמור', // = uiTerms t_f50251bc
  editorTitleTpl: r'👷 ${widget.displayName}',
);

// ── 🛠️ ניהול (M5) ────────────────────────────────────────────────────────────
const manageIntroContent = (
  text: '🛠️ שליטה מלאה על אפליקציית הקבלן — כל שינוי מתעדכן מיידית.', // cfg: manager.manage.intro
);

/// מקטעי-האקורדיון (_ManageTabState) — emoji+title+sub verbatim; gate = תנאי-ההרכבה.
const manageSectionsContent = [
  (key: 'approvals', emoji: '👷', title: 'אישורי עובדים', sub: 'משימות שעובדים שלחו לאישור', cfgId: 'manager.manage.approvals.title', gate: '!kHrRelocationFlag'),
  (key: 'approvals', emoji: '👷', title: 'אישורי עובדים', sub: 'מנוהל בלוח-הקבלן', cfgId: 'manager.manage.approvals.title', gate: 'kHrRelocationFlag'),
  (key: 'vacations', emoji: '🏖️', title: 'בקשות חופשה', sub: 'בקשות חופשה שעובדים ושליחים הגישו', cfgId: 'manager.manage.vacations.title', gate: ''),
  (key: 'cats', emoji: '🗂️', title: 'קטגוריות', sub: 'ניהול קטגוריות הקטלוג', cfgId: 'manager.manage.cats.title', gate: ''),
  (key: 'settings', emoji: '⚙️', title: 'הגדרות אפליקציה', sub: 'פרמטרים שהקבלן רואה', cfgId: 'manager.manage.settings.title', gate: ''),
  (key: 'trees', emoji: '🌳', title: 'עץ המוצרים', sub: 'עריכת האביזרים המשלימים של כל מוצר', cfgId: 'manager.manage.trees.title', gate: ''),
  (key: 'brands', emoji: '🏷️', title: 'מותגים ומחירים', sub: 'עריכת המותגים והמחירים של כל מוצר', cfgId: 'manager.manage.brands.title', gate: ''),
  (key: 'regression', emoji: '🔬', title: 'בדיקות רגרסיה', sub: 'הרצת חבילת הבדיקות המלאה של האפליקציה', cfgId: 'manager.manage.regression.title', gate: 'kDebugMode'),
  (key: 'systemSetup', emoji: '🔌', title: 'הקמת המערכת', sub: 'בניית ענף חדש והגדרת החברה — הכל במקום אחד', cfgId: 'manager.manage.systemSetup.title', gate: 'kOrgConfigFlag'),
];

const manageSectionHelpContent = (
  title: 'מקטע ניהול',
  body: 'פותח/סוגר מקטע ניהול באקורדיון (מקטע אחד פתוח בכל רגע). '
      'חל על כל המקטעים: אישורי עובדים, בקשות חופשה, קטגוריות, '
      'הגדרות אפליקציה, עץ מוצרים, מותגים, בדיקות רגרסיה ושיוך '
      'תפקידים.',
);

/// _ManageTabState — פיקוח-HR + טוסטי-החלטה (מחלקת-State — המכונה לא סרקה).
const manageTabContent = (
  hrOversightTpl: r'👷 ${pending.length} אישורי-עובדים ממתינים אצל הקבלנים · פיקוח בלבד',
  taskApprovedToastTpl: r'✅ אושר: ${t.name}',
  taskRejectedToastTpl: r'↩️ נדחה: ${t.name}',
  vacationApprovedBell: 'בקשת החופשה אושרה',
  vacationRejectedBell: 'בקשת החופשה נדחתה',
  vacationApprovedChatTpl: r'✅ בקשת החופשה שלך (${r.range}) אושרה',
  vacationRejectedChatTpl: r'❌ בקשת החופשה שלך (${r.range}) נדחתה',
  vacationApprovedToastTpl: r'✅ אושרה חופשה: ${r.workerName} · ${r.range}',
  vacationRejectedToastTpl: r'❌ נדחתה חופשה: ${r.workerName} · ${r.range}',
);

const countBadgeContent = (semanticsTpl: r'ממתינים לאישור: $count');

const approvalsBodyContent = (emptyLine: '🎉 אין משימות הממתינות לאישור.'); // cfg: manager_dashboard_screen.approvals_empty

const approvalRowContent = (
  metaTpl: r'🦺 ${kWorkers[(task.worker >= 0 && task.worker < kWorkers.length) ? task.worker : 0]} · 🕒 ${task.days} ימים · ${task.steps} שלבים',
  approveButton: '✅ אשר', // = uiTerms t_c46f59d0
  approveHelpTitle: 'אשר משימה',
  approveHelpBody: 'מאשר משימה שעובד שלח לאישור: המשימה עוברת ל׳בוצע׳, מזכה '
      'מטבעות ושולחת התראת ✅ לעובד. כתיבה למנוע המשותף — '
      'נראית מיד בלוח העובד.',
  rejectButton: '↩️ דחה',
  rejectHelpTitle: 'דחה משימה',
  rejectHelpBody: 'דוחה משימה שנשלחה לאישור ומחזיר אותה לעובד עם סיבת '
      'דחייה. הסיבה והסטטוס מתעדכנים מיד בלוח העובד.',
);

const vacationsBodyContent = (emptyLine: 'אין בקשות חופשה.'); // cfg: manager_dashboard_screen.vacations_empty

const vacationRequestRowContent = (
  courierGlyph: '🛵',
  workerGlyph: '🦺',
  titleTpl: r"${_isCourierVacationRequest(request) ? '🛵' : '🦺'} ${request.workerName} · ${request.range}",
  approvedPill: 'אושרה',
  rejectedPill: 'נדחתה',
  approveButton: '✅ אשר', // = uiTerms t_c46f59d0
  approveHelpTitle: 'אשר בקשת חופשה',
  approveHelpBody: 'מאשר בקשת חופשה שעובד/שליח הגיש: מעדכן את רשימת '
      'הבקשות שלו ושולח התראה. הסטטוס מתעדכן מיד אצל המבקש.',
  rejectButton: '❌ דחה', // = uiTerms t_5000b14b
  rejectHelpTitle: 'דחה בקשת חופשה',
  rejectHelpBody: 'דוחה את בקשת החופשה ומעדכן את המבקש בהתראה. הסטטוס '
      'מתעדכן מיד אצל העובד/שליח.',
);

const categoriesBodyContent = (
  headerTpl: r'קטגוריות פעילות (${entries.length})',
  countRowTpl: r'${e.value} מוצרים',
  hint: 'שינוי שם קטגוריה מעדכן את כל המוצרים שבה.',
);

const appSettingsBodyContent = (
  expressFeeLabel: 'תוספת משלוח אקספרס',
  expressFee: 120, // @legacy EXPRESS_FEE, מתוקן ל-120 (deliveryFeeFor)
  creditLimitLabel: 'מסגרת אשראי לקבלן',
  creditLimit: 50000, // @legacy creditLimit
  vatLabel: 'שיעור מע״מ', // הערך: (kVatRate*100).round() — חי מהקטלוג
  hintTpl: r'המע״מ קבוע לפי חוק ($_vatPercent%). תוספת האקספרס והאשראי נראים מיד בעגלת הקבלן.',
);

const productTreeBodyContent = (
  intro: 'עריכת האביזרים המשלימים של כל מוצר — בחירת מוצר חושפת את עץ האביזרים שלו.', // cfg: manager_dashboard_screen.producttree_intro
  productsRow: 'מוצרים בעץ',
  categoriesRow: 'קטגוריות', // = uiTerms t_eb826680
  hint: 'כל מוצר נושא עץ אביזרים משלימים (חובה / אופציונלי).',
);

const brandsBodyContent = (
  headerTpl: r'מותגים (${kBrands.length})',
  countTpl: r'${b.productCount} מוצרים',
);

const regressionBodyContent = (
  intro: 'הרצת חבילת בדיקות הרגרסיה המלאה (קטלוג · מאתר · מנוע תאימות · state · '
      'ניווט) על המכשיר.', // cfg: manager_dashboard_screen.regression_intro
  openButton: '🔬 פתח מרכז בדיקות רגרסיה', // cfg+gate: manager.manage.regression.open
  helpTitle: 'בדיקות רגרסיה',
  helpBody: 'פותח את מרכז בדיקות הרגרסיה (כלי פיתוח). קיים רק בבילד debug.',
);
