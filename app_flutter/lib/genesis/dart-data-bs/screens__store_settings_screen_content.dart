// 📦 דאטה-תוכן · screens__store_settings_screen (הגדרות-חנות, בנייה-חכמה) — ליטוש-ידני
// של פלט-המכונה (screen-lift): שמות-סמנטיים במקום תעתיק, אפס המצאת-תוכן — הכול verbatim
// מהמקור הקדוש scratchpad/all-screens/screens__store_settings_screen.dart.
// כל מונח-עברי קיים בקטלוג terms-catalog.json — המפתח t_XXXXXXXX מוער ליד כל ערך
// (הכרעת "מונח-קיים ⇒ המפתח שלו"); הקופסה רשאית לצרוך דרך uiTerms[key] במקום הערך
// המקומי. ערכים לועזיים/גליפיים (Apple/Google Pay · דירוגי-★ · יחידות) אינם בקטלוג —
// נשמרים כאן verbatim. מזהי-הסטודיו (store_settings_screen.* של CfgText/CfgVisible)
// מוערים גם הם — חיווט-קופסה, לא ידע-אטום.

// ── שלד-המסך + דיאלוג-איפוס (StoreSettingsScreen, שורות 20–121) ──
const storeSettingsScreenContent = (
  appBarTitle: 'הגדרות חנות', // screen_title · t_7c71571c
  resetTooltip: 'איפוס לברירת מחדל', // t_00367599
  resetDialogTitle: 'איפוס הגדרות?', // reset_title · t_d5f40ad5
  resetDialogBody: 'כל הגדרות החנות יוחזרו לברירת המחדל.', // reset_body · t_7b818f6c
  resetCancel: 'ביטול', // cancel (CfgVisible מרוכב) · t_a7c55a8d
  resetConfirm: 'אפס', // reset_ok (CfgVisible מרוכב) · t_769b7b3c
  resetDoneToast: 'הגדרות אופסו', // t_9e2ee412
);

// ── 1. משלוחים וכתובות (_ShippingSection, שורות 125–193) ──
const shippingSectionContent = (
  emoji: '📍',
  title: 'משלוחים וכתובות', // t_2f689a37
  defaultAddressLabel: 'כתובת ברירת מחדל', // t_6ec13e9c · WIRED: מילוי-מוקדם openShipToSheet
  defaultAddressHint: 'רחוב, מספר, עיר', // t_1e44e18e
  deliveryWindowLabel: 'חלון זמן מועדף', // t_d8873d47
  windowMorning: 'בוקר', // t_d741ca0e
  windowNoon: 'צהריים', // t_300ea530
  windowEvening: 'ערב', // t_33c5e69b
  windowFlexible: 'גמיש', // t_9057aef3
  deliveryAreasLabel: 'אזורי משלוח', // t_f29f08ad
  deliveryAreasHint: 'ת"א, רמת גן, הרצליה...', // t_81eda1f0
  courierInstructionsLabel: 'הוראות לשליח', // t_93249292
  courierInstructionsHint: 'הערות למשלוח...', // t_0f564352
  selfPickupDefault: 'איסוף עצמי כברירת מחדל', // t_da7fe4e5
);

// ── 2. אמצעי תשלום (_PaymentSection, שורות 197–251) ──
const paymentSectionContent = (
  emoji: '💳',
  title: 'אמצעי תשלום', // t_9c709c1b
  defaultPaymentLabel: 'ברירת מחדל', // t_9b5409b0
  payCard: 'כרטיס אשראי', // t_c5a87fbf
  payBit: 'ביט', // t_68e0442a
  payApplePay: 'Apple/Google Pay', // לועזי — אינו בקטלוג-המונחים
  paySupplierCredit: 'אשראי ספק', // t_fd82d7bd
  savedCardsPlaceholder: 'כרטיסים שמורים', // t_fd1de491 · שורת-בבנייה (PlaceholderRow)
  installmentsLabel: 'תשלומים (1/3/6/12)', // t_a473334f
  installmentsOne: 'תשלום אחד', // t_0abf6435
  installmentsThree: '3 תשלומים', // t_b3b90e5a
  installmentsSix: '6 תשלומים', // t_b4cbee32
  installmentsTwelve: '12 תשלומים', // t_3e3c5caf
  supplierCreditToggle: 'הסדר אשראי ספק', // t_e47e8d55 · WIRED: שער chip בצ׳קאאוט
);

// ── 3. חשבוניות ומס (_InvoicesSection, שורות 255–320) ──
const invoicesSectionContent = (
  emoji: '🧾',
  title: 'חשבוניות ומס', // t_3ccfaaa8
  vatInclusive: 'הצג מחירים כולל מע"מ', // t_c51226d6
  businessNameLabel: 'פרטי עוסק/חברה', // t_f3eb97e7
  businessNameHint: 'שם עסק...', // t_d1924f87
  businessIdLabel: 'ח.פ. / ע.מ.', // t_de859eb4
  businessIdHint: 'מספר...', // t_bab99f7b
  businessIdError: 'ח.פ. חייב להכיל 9 ספרות', // t_1a20048a · הקופסה מחשבת validBusinessId
  exportToAccountant: 'ייצוא לרו"ח', // t_0ca3d92a
  autoReceipts: 'קבלות אוטומטיות', // t_8a711c6f
);

// ── 4. התראות חנות (_NotificationsSection, שורות 324–378; סקציה-בבנייה) ──
const notificationsSectionContent = (
  emoji: '🔔',
  title: 'התראות חנות', // t_fdd74f83
  deals: 'התראות מבצעים', // t_db4dc886
  backInStock: 'חזר למלאי במועדפים', // t_af2d77c6
  priceDrop: 'ירידת מחיר במועדפים', // t_ba51e66c
  orderStatus: 'סטטוס הזמנה', // t_19ddf771
  shipmentEnRoute: 'משלוח בדרך', // t_ce928cb0
);

// ── 5. סל והזמנות (_CartSection, שורות 382–448) ──
const cartSectionContent = (
  emoji: '🛒',
  title: 'סל והזמנות', // t_61c6935f
  minOrderAmount: 'מינימום הזמנה (₪)', // t_93236a22
  confirmLargeOrder: 'אישור כפול לרכישה גדולה', // t_c7fa5569
  largeOrderThreshold: 'סף לאישור כפול (₪)', // t_b50c0f1d · מרונדר רק כשהמתג דלוק
  repeatOrders: 'הזמנות חוזרות', // t_1756070c
  shareCartWithTeam: 'שיתוף סל עם צוות', // t_b0d97ab9 · WIRED: שער כפתור-שיתוף-הסל
  saveCartToProject: 'שמירת סל לפרויקט', // t_f89f082d
);

// ── 6. ספקים מועדפים (_SuppliersSection, שורות 452–499; סקציה-בבנייה) ──
const suppliersSectionContent = (
  emoji: '🏪',
  title: 'ספקים מועדפים', // t_2f08d624
  markedStoresPlaceholder: 'חנויות מסומנות', // t_ebbba2de · שורת-בבנייה (PlaceholderRow)
  blockedSuppliersPlaceholder: 'ספקים חסומים', // t_c4f0e83c · שורת-בבנייה (PlaceholderRow)
  maxDistanceLabel: 'מרחק מקסימלי (ק"מ, 0=ללא)', // t_c7d50f0d
  minRatingLabel: 'דירוג מינימלי', // t_d5983837
  ratingAny: 'ללא סינון', // t_ee9d85ed
  ratingTwoPlus: '★★+', // גליפי — אינו בקטלוג-המונחים
  ratingThreePlus: '★★★+', // גליפי
  ratingFourPlus: '★★★★+', // גליפי
  ratingFive: '★★★★★', // גליפי
  localOnly: 'ספקים מקומיים בלבד', // t_76954b33
);

// ── 7. תצוגה ומיון (_DisplaySection, שורות 503–568) ──
const displaySectionContent = (
  emoji: '📊',
  title: 'תצוגה ומיון', // t_b250492d
  sortDefaultLabel: 'מיון ברירת מחדל', // t_df135ca8
  sortPriceAsc: 'מחיר: זול → יקר', // t_84ff892f
  sortRating: 'דירוג גבוה', // t_b714ac5b · מגודר !kHideUnderConstruction (הקופסה)
  sortDistance: 'מרחק קרוב', // t_044519e2 · מגודר !kHideUnderConstruction (הקופסה)
  displayModeLabel: 'תצוגה (רשת / רשימה)', // t_a7bbd1fa
  displayList: 'רשימה', // t_ef8f7b72
  displayGrid: 'רשת', // t_beb2b151
  unitSystemLabel: "יחידות (מטר / אינץ')", // גרש-בודד — נעדר מהקטלוג (regex-המכונה)
  unitMetric: 'מטרי', // t_46af84c1
  unitImperial: 'אינגלי', // t_fff2b869
  showStock: 'הצגת מלאי', // t_768869c8
);

// ── 8. שירות ולוגיסטיקה (_LogisticsSection, שורות 572–624; סקציה-בבנייה) ──
const logisticsSectionContent = (
  emoji: '⚡',
  title: 'שירות ולוגיסטיקה', // t_e223f954
  fastDelivery: 'משלוח מהיר (תוך 4 שעות)', // t_b9084233
  regularDelivery: 'משלוח רגיל (יום-יומיים)', // t_f4b4c367
  technicalAdvicePlaceholder: 'ייעוץ טכני', // t_41017dca · שורת-בבנייה (PlaceholderRow)
  returnPolicyLabel: 'מדיניות החזרות', // t_b5af8227
  returnDays7: '7 ימים', // t_986f9ad7
  returnDays14: '14 יום', // t_084120da
  returnDays30: '30 יום', // t_fa2a3649
  extendedWarranty: 'אחריות מורחבת', // t_b9301aa4
);

// ── 9. פרטיות ורכישות (_PrivacySection, שורות 628–685) ──
const privacySectionContent = (
  emoji: '🔐',
  title: 'פרטיות ורכישות', // t_2b00a4aa
  purchaseHistory: 'היסטוריית רכישות', // t_1aa18690 · WIRED: שער הסתרת-לשונית-הזמנות
  clearSearchLabel: 'מחיקת חיפושים', // t_049e7e80
  clearSearchButton: 'מחק', // t_09b6bcca
  clearSearchDialogTitle: 'מחיקת חיפושים?', // t_b338356a
  clearSearchDialogBody: 'החיפוש הנוכחי בחנות יימחק.', // t_0c817498
  clearSearchDoneToast: 'החיפוש נוקה', // t_bc63f246
  biometricConfirm: 'אישור ביומטרי לרכישה', // t_659956cf
  dailyCreditLimit: 'מגבלת אשראי יומית (₪, 0=ללא)', // t_4a7e1333
);

// ── תוויות-בבנייה משותפות (מנגנוני-המדף) ──
const underConstructionContent = (
  // תת-כותרת סקציה-בבנייה — SettingsSectionTile (section_wip) · t_3a3cce3d
  sectionNote: 'בבנייה — ההגדרות נשמרות אך עדיין אינן משפיעות',
  // תת-כותרת שורה-בבנייה — נוסח verbatim זהה בארבעה מנגנונים: SettingsSwitchRow
  // (switch_wip) · SettingsRadioGroupRow (radio_wip) · SettingsValidatedTextRow
  // (inline_wip) · SettingsNumberRow (number_wip) · t_584cf3e1
  rowNote: 'בבנייה — עדיין לא משפיע',
  badge: 'בבנייה', // placeholder_wip · t_a98f280f — ה-badge של אטום-המדף PlaceholderRow
  // תבנית-$: הקופסה מפרמטת ('<label> — בבנייה') ומעבירה טוסט מוכן ל-PlaceholderRow
  tapToastTemplate: r'$label — בבנייה',
);
