// 📦 דאטה-תוכן · screens__home_shell (בנייה-חכמה) — ליטוש-ידני של פלט screen-lift.
// מוצא קדוש: scratchpad/all-screens/screens__home_shell.dart — הכול verbatim, אפס-המצאה.
// כל מונח מסומן במפתחו בקטלוג-המונחים (uiTerms ב-ui_terms.dart) — הקופסה צורכת
// termOf(key), לא מגדירה-מחדש; מזהי-CfgText (דריסות-Studio) נשמרים 🔑 כ-cfgId.
// תבניות-$ נשמרות raw — הקופסה מפרמטת, האטום מקבל מחרוזת-מוכנה.
// צבעים (גלולות-הסטטוס, פיגמנטי-BsTokens) אינם תוכן — ראו wiring_notes.

// ─── שלד-הבית (HomeShell) ────────────────────────────────────────────────────
const homeShellContent = (
  keyboardFabTooltip: 'מקלדת חכמה', // t_73a37f0b · ה-FAB של המקלדת (kKeyboardToolStrip)
  homeSectionId: 'בית', // t_dda9882b · ערך-מצב: catalogSectionProvider בלחיצת טאב-הבית
  cartFabHeroTag: 'cart-fab', // זהות-Hero של ה-FAB (חיווט, לא-עברית — כאן לתיעוד-מלא)
  keyboardFabHeroTag: 'keyboard-fab',
);
const cartFabHelp = (
  title: 'סל הקנייה', // t_2578cdcd
  body1: 'הסל הצף מציג כמה פריטים נאספו. לחיצה עליו קופצת ', // t_cb4abbd7
  body2: 'לחנות עם הסל המסונן — משם ממשיכים להזמנה.', // t_91e66f23 · שתי מחרוזות-סמוכות במקור
);

// ─── עזרת-הטאבים (#31, _kTabHelp — INDEX-keyed בסדר-הטאבים) ─────────────────
const tabHelp = [
  (
    title: 'בית', // t_dda9882b
    body: 'מסך הבית החכם — נחיתה עם תוכן מותאם ("תוכן הבית"), ומשם כניסה לקטלוג המלא.', // t_39e3d72f
  ),
  (
    title: 'מחלקות', // t_c5c976c4
    body: 'רשת המחלקות — דפדוף לפי קטגוריות מוצרים (אינסטלציה · גמר · כלים…) לניווט מהיר בקטלוג.', // t_1f2dadc8
  ),
  (
    title: 'עדכונים', // t_064aeb66
    body: 'ההתראות והשיחות במקום אחד — הזמנות, חוסרים והודעות מספקים ומהצוות. התג מציג כמה לא נקראו.', // t_c4df5004
  ),
  (
    title: 'חנות', // t_70974bec
    body: 'החנות — הסל שלך, ההזמנות והמעקב אחריהן. כאן משלימים את הרכישה.', // t_e6946880
  ),
];

// ─── ניווט-תחתון (_BottomNav ⇒ BottomNavCell-מדף + BadgedIcon) ──────────────
// giant-v3: nav.* מחליף את התווית-המוצגת בלבד; tabHelp נשאר באוצר-המילים הקנוני.
const bottomNavTabs = (
  home: (termId: 'nav.home', fallback: 'בית'), // t_dda9882b
  departments: (termId: 'nav.catalog', fallback: 'מחלקות'), // t_c5c976c4
  updates: (termId: 'nav.updates', fallback: 'עדכונים'), // t_064aeb66
  store: (termId: 'nav.store', fallback: 'חנות'), // t_70974bec
);
const unreadBadgeOverflowLabel = '9+'; // תקרת-התג (count>9) — הקופסה מפרמטת ל-BadgedIcon

// ─── שכבת-ההיכרות (_HelpModeOverlay ⇒ HelpFreezeOverlay) ───────────────────
const helpModeOverlayContent = (
  bannerCfgId: 'home.helpmode.banner', // 🔑
  banner: 'מצב היכרות — לחצו על אלמנט מודגש כדי ללמוד מה הוא עושה', // t_45edcadc
  exitLabel: 'צא ממצב היכרות', // t_a7fb69dc · Semantics + Tooltip (אותה מחרוזת במקור)
  scrimSnackbar1: 'במצב היכרות — לחצו על כפתור מודגש (📷 או הסל). ', // t_46508bae
  scrimSnackbar2: '✕ או 💡 ליציאה.', // t_cb15c148 · שתי מחרוזות-סמוכות במקור (SnackBar אחד)
);

// ─── בועת-הסל (_CartChatBubble ⇒ CartChatBubble) ────────────────────────────
const cartChatBubbleContent = (
  closeSemanticsLabel: 'הסר התראה זו', // t_d9191f71
  closeTooltip: 'הסר', // t_10666b28
  priceTpl: r'₪${line.total}', // הקופסה מפרמטת ⇒ priceLabel
  qtyTpl: r'×${line.productQty}', // הקופסה מפרמטת ⇒ qtyLabel
);

// ─── האפבר (_HomeAppBar — קופסה; חלקיו: NameChip · StatusDotChip · PulsingStatus) ──
const appBarContent = (
  logoTooltip: 'BS',
  brandCfgId: 'home.topbar.brand', // 🔑 · הערך = AppBrand.name (זהות-הצבה, לא תוכן — חוק-6)
  smartTreeSectionId: 'עץ חכם', // t_abddecf3 · ערך-ההשוואה מול catalogSectionProvider
  smartTreeActive: 'עץ חכם הופעל', // t_c366717b · הטקסט המוזרם ל-PulsingStatus
  smartTreeCfgId: 'home.status.smarttree', // 🔑
  versionChromeTpl: r'$kVersionLabel · $kBuild', // זהות-build מוזרקת בלוח (חוק-6)
  profileChipLabel: 'הפרופיל שלי', // t_bba6fed3 · Semantics + Tooltip של צ׳יפ-השם
  searchTooltip: 'חיפוש', // t_6d6d7964
  cameraTooltip: 'מצלמה', // t_a7dc1317
  menuTooltip: 'תפריט', // t_cf15ec8c · משותף ל-4 כפתורי-ה-⋮
  helpModeTooltip: 'מצב היכרות (לחיצה ארוכה: סיור)', // t_30103541
);

// עזרות-האפבר (HelpTarget פר-אלמנט; מחרוזות-סמוכות נשמרו כחלקים):
const appBarHelp = (
  logo: (
    title: 'החלפת לוח / זהות', // t_36b0989f
    body1: 'לחיצה על הלוגו פותחת את בורר התפקידים — מעבר בין ', // t_c7386e11
    body2: 'לוח קבלן · מנהל · חנות · שליח · עובד. כך עוברים בין ', // t_4779d6a3
    body3: 'סוגי המשתמשים באפליקציה.', // t_531cfa6d
  ),
  profileChip: (
    title: 'הפרופיל שלי', // t_bba6fed3
    body1: 'פותח כרטיס פרופיל לקריאה — שם · מקצוע · ', // t_5a1b158c
    body2: 'כתובת · ח.פ. · איש קשר; ומשם "ערוך פרופיל" ', // t_62fbebab
    body3: 'לעריכה מלאה.', // t_d4180123
  ),
  search: (
    title: 'חיפוש', // t_6d6d7964
    body1: 'מחזיר את שורת החיפוש של הטאב הפעיל (שנעלמה בגלילה) ', // t_b71469fd
    body2: 'כדי לחפש מוצר או פריט במהירות.', // t_b0d3d4b8
  ),
  camera: (
    title: 'מצלמה / סורק', // t_11208b02
    body1: 'פותח את הסורק: צילום ברקוד או מק"ט לזיהוי מוצר, ', // t_28716081
    body2: 'או סריקת תוכנית כדי להפיק ממנה רשימת מוצרים — בלי להקליד ידנית.', // t_b11aa1db
  ),
  catalogMenu: (
    title: 'תפריט הקטלוג', // t_264f18f2
    body1: 'כלים נוספים של הקטלוג — בינה מלאכותית ואוטומציה, ', // t_cd6ab6b4
    body2: 'והגדרות האפליקציה.', // t_a27dd10f
  ),
  chatsMenu: (
    title: 'תפריט השיחות', // t_f069b84a
    body1: 'כלים לשיחות — פתיחת שיחה חדשה, ארכיון, ', // t_3a4c16f6
    body2: 'והשתקת כל השיחות.', // t_399bf1be
  ),
  notifMenu: (
    title: 'תפריט ההתראות', // t_b30958fa
    body1: 'כלים להתראות — סימון הכל כנקרא, ניקוי הכל, ', // t_03bfed54
    body2: 'והגדרות התראות.', // t_a77edc43
  ),
  storeMenu: (
    title: 'תפריט החנות', // t_4b89e06e
    body: 'כלים לחנות — הסל שלי, ההזמנות, שירותים, והגדרות החנות.', // t_e80f5f03
  ),
);

// ─── 4 תפריטי-ה-⋮ (קופסה: PopupMenuButton + MenuRow ×N; value = מזהה-dispatch) ──
const catalogMenuItems = [
  (value: 'ai_hub', emoji: '🤖', label: 'בינה מלאכותית ואוטומציה', cfgId: 'home.catalogmenu.aihub'), // t_e0c01b78 · שער modOn(ai) + divider אחריו
  (value: 'settings', emoji: '⚙️', label: 'הגדרות', cfgId: null), // t_47cfdefb
];
const chatsMenuItems = [
  (value: 'new_chat', emoji: '✏️', label: 'שיחה חדשה', cfgId: null), // t_82c40bcf
  (value: 'archive', emoji: '🗂️', label: 'ארכיון שיחות', cfgId: 'home.chatsmenu.archive'), // t_dca9d772
  // mute_all — שורה דינמית: allMuted ⇒ (🔔, בטל השתקת הכל) אחרת (🔇, השתק הכל):
];
const muteAllRow = (
  value: 'mute_all',
  mutedEmoji: '🔔',
  mutedLabel: 'בטל השתקת הכל', // t_863131ba
  unmutedEmoji: '🔇',
  unmutedLabel: 'השתק הכל', // t_743f1fc8
);
const muteAllConfirm = (
  title: 'השתקת כל השיחות?', // t_048cf57e
  message: 'כל השיחות יושתקו עד לביטול ההשתקה.', // t_a26070fd
  confirmLabel: 'השתק', // t_ee25aa75
);
const muteAllToasts = (
  unmuted: 'ההשתקה בוטלה', // t_94cafe81
  muted: 'כל השיחות הושתקו', // t_a54b10cb
);
const notifMenuItems = [
  (value: 'mark_all_read', emoji: '✅', label: 'סמן הכל כנקרא', cfgId: 'home.notifmenu.readall'), // t_fc4def53
  (value: 'clear_all', emoji: '🗑️', label: 'נקה הכל', cfgId: 'home.notifmenu.clearall'), // t_ebbc108b
  (value: 'notif_settings', emoji: '🔔', label: 'הגדרות התראות', cfgId: 'home.notifmenu.settings'), // t_9983adc2
];
const notifMenuToasts = (
  allRead: 'כל ההתראות סומנו כנקרא', // t_dc4748fe
  allCleared: 'כל ההתראות נמחקו', // t_190d8007
);
const clearAllConfirm = (
  title: 'ניקוי כל ההתראות?', // t_2d243895
  message: 'כל ההתראות יימחקו לצמיתות.', // t_130d59eb
  confirmLabel: 'נקה הכל', // t_ebbc108b
);
const storeMenuItems = [
  (value: 'cart', emoji: '🛒', label: 'הסל שלי', cfgId: 'home.storemenu.cart'), // t_f682e3d3
  (value: 'orders', emoji: '📦', label: 'הזמנות', cfgId: 'home.storemenu.orders'), // t_d0776cb6
  (value: 'services', emoji: '🔧', label: 'שירותים', cfgId: null), // t_c5cdb271 · שער !kHideUnderConstruction + divider אחריו
  (value: 'settings', emoji: '⚙️', label: 'הגדרות', cfgId: null), // t_47cfdefb
];

// ─── sheet שיחה-חדשה (_NewChatSheet ⇒ SheetScaffold-חנות + DirectoryRow ×N) ──
const newChatSheetContent = (
  titleCfgId: 'home.newchat.title', // 🔑
  titleEmoji: '✏️',
  title: 'שיחה חדשה', // t_82c40bcf · במקור מחרוזת-אחת עם הגליף (t_6a56b23c) — SheetScaffold מרכיב זהה
  subtitleCfgId: 'home.newchat.subtitle', // 🔑
  subtitle: 'בחר סוג איש קשר', // t_f7504576
  emptyCfgId: 'home.newchat.empty', // 🔑
  empty: 'אין עדיין משתמשים', // t_117a84ee · גם על error (הכלל-הקשיח של המקור)
);
// רשימת-הסוגים הקבועה (fallback כשאין backend — useFirebaseBackend כבוי):
const newChatContactTypes = [
  (emoji: '👷', label: 'קבלן'), // t_804ba9cf
  (emoji: '🏪', label: 'ספק'), // t_7c71c3ed
  (emoji: '🛵', label: 'שליח'), // t_76047c04
  (emoji: '🦺', label: 'עובד'), // t_2e131aef
  (emoji: '💬', label: 'תמיכה'), // t_3bc1abed
];
// תגי-תפקיד לשורת-ספרייה חיה (_roleBadge; מפתח = שם ה-BsRole; bot/null ⇒ fallback):
const roleBadges = {
  'contractor': (emoji: '👷', label: 'קבלן'), // t_804ba9cf
  'store': (emoji: '🏪', label: 'ספק'), // t_7c71c3ed
  'courier': (emoji: '🛵', label: 'שליח'), // t_76047c04
  'worker': (emoji: '🦺', label: 'עובד'), // t_2e131aef
  'manager': (emoji: '👔', label: 'מנהל'), // t_409634c7
};
const roleBadgeFallback = (emoji: '💬', label: ''); // bot / null — בלי תת-תווית

// ─── כרטיס-הפרופיל (_ProfileCard ⇒ ProfileHeaderRow + IconDetailRow + FilledCtaButton) ──
const profileCardContent = (
  guestName: 'אורח', // t_0cd9a48c · כששם-הפרופיל ריק (וגם: אווטאר ⇒ אייקון-person)
  closeTooltip: 'סגור', // t_55247199
  editCtaCfgId: 'home.profilecard.editCta', // 🔑 · גם CfgVisible (composite-hide) — חיווט-קופסה
  editCta: 'ערוך פרופיל', // t_1cfef312
);

// ─── צ׳יפ-סטטוס-ההרשמה (_RoleStatusChip ⇒ StatusDotChip; צבעי-המצבים = פיגמנטים) ──
const roleStatusLabels = (
  needsRegistration: 'דרוש הרשמה', // t_bbbf1ce4 · 🟠
  inProcess: 'בתהליך', // t_dd2254e7 · 🟡
  approved: 'מאושר', // t_8270663e · 🟢
  rejected: 'נדחה', // t_0a4a56cd · 🔴
);
const roleStatusSemanticsTpl = r'סטטוס הרשמה: $label'; // t_e7470501 · הקופסה מפרמטת
