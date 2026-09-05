// 📦 דאטה-תוכן · screens__store_screen (בנייה-חכמה) — ליטוש-ידני של פלט screen-lift.
// מוצא קדוש: scratchpad/all-screens/screens__store_screen.dart — הכול verbatim, אפס-המצאה.
// כל מונח-UI שקיים בקטלוג-המונחים מסומן במפתחו (uiTerms ב-ui_terms.dart) — המסך צורך
// termOf(key), לא מגדיר-מחדש; הערכים כאן = דאטה-מסך (seed/תבניות/רשומות-מבנה) שהקופסה
// מזרימה לאטומים שב-new/dart-ui-bs/screens__store_screen/.
// תבניות-$ נשמרות כ-raw strings — הקופסה מפרמטת, האטום מקבל מחרוזת-מוכנה.

// ─── פס-הסיכום (_SummaryRow:594 ⇒ SummaryChip) ───────────────────────────────
const summaryChips = (
  cartCountTpl: r'🛒 $cartCount פריטים בסל', // t_f858a72b
  openOrdersTpl: r'📦 $openOrders הזמנות פתוחות', // t_c57367d1
  supplierOffersTpl: r'📨 $offers הצעות ספקים', // t_e1cc63e1 · מוסתר תחת kHideUnderConstruction
  // צבעי-הצ׳יפים בחיווט: brand · 0xFF4CAF50 · 0xFFFF9800 (פיגמנטים, לא תוכן).
  // offers נגזר single-source מ-badge של שורת מכרז-הספקים (storeHubItems[5].badge).
);

// ─── צ׳יפי-הסקשן (_SectionChipsRow:672 ⇒ SectionPill) ────────────────────────
const sectionChips = (
  all: 'הכל', // t_5f8fb8a5
  cart: '🛒 הסל', // t_017688c2
  orders: '📦 הזמנות', // t_dbb601cd
  services: '🔧 שירותים', // t_d038c4cb · שער: !kHideUnderConstruction && featOn(orders,services)
  orderNotifTooltip: 'התראות הזמנות ומשלוחים', // t_502e2e60 · כפתור 🔔 רק בסקשן הזמנות
  orderNotifGlyph: '🔔',
);

// ─── פעולות-מהירות (_QuickActionsRow:773 ⇒ QuickActionButton) ────────────────
const quickActions = (
  favorites: 'מועדפים', // t_8b041840 · תמיד מוצג
  favoritesEmptyToast: 'אין פריטים מועדפים', // t_55389cea
  moadim: 'מועדים', // t_de21005d · תחת !kHideUnderConstruction
  scheduling: 'תזמון', // t_085a5652 · תחת !kHideUnderConstruction
  call: 'שיחה', // t_1c96b9bd · תחת !kHideUnderConstruction
  finance: 'כספים', // t_bf99e582 · שער modOn(finance) ⇒ openFinanceHub
);

// ─── sheets של פעולות-מהירות (⇒ SheetScaffold + SheetTile / ContactTile) ─────
const favoritesSheetHeader = (emoji: '❤️', title: 'מועדפים'); // t_8b041840
const moadimSheetHeader = (emoji: '📅', title: 'מועדים'); // t_de21005d
const moadimSheetTiles = [
  (emoji: '📅', label: 'לוח שנה'), // t_219d3ee0
  (emoji: '🗓️', label: 'אירועים קרובים'), // t_8cd42a1c
  (emoji: '🏗️', label: 'לוח עבודה'), // t_c05f743d
  (emoji: '⏰', label: 'תזכורות'), // t_ca25d18a
];
const tizmonSheetHeader = (emoji: '📆', title: 'תזמון'); // t_085a5652
const tizmonSheetTiles = [
  (emoji: '📆', label: 'תזמן פגישה'), // t_98e0b2a0
  (emoji: '🚛', label: 'תזמן משלוח'), // t_4e9a975f
  (emoji: '👷', label: 'תזמן עובד'), // t_5db3d921
  (emoji: '📋', label: 'תזמן ביקורת'), // t_f89ea01f
];
const sichaSheetHeader = (emoji: '📞', title: 'שיחה חדשה'); // t_82c40bcf
const sichaContacts = [
  (avatar: '👷', name: 'הקבלן הראשי'), // t_dfd2e0cf
  (avatar: '🏪', name: 'ספק חומרי בנייה'), // t_d6a198fe
  (avatar: '🛵', name: 'השליח'), // t_a5a1b69b
  (avatar: '👔', name: 'מנהל המערכת'), // t_2da6cebc
];
const sichaCallToastTpl = r'שיחה עם ${c.name} — בבנייה'; // t_f7944ba2
const sheetTileFallbackToastTpl = r'$label — בבנייה'; // t_f862ee5a · טוסט-ברירת-מחדל של SheetTile

// ─── שורות-ההאב (_kAllItems:220 ⇒ StoreHubRow / GridHubCard) ─────────────────
// seed-תצוגה; שורות הסל/הזמנות נדרסות חי בקופסה (cartCount/ordersPreview — ראו תבניות).
const storeHubItems = [
  (emoji: '🛒', title: 'הסל שלי', preview: '3 פריטים ממתינים לסיכום', time: 'עכשיו', badge: 3),
  (emoji: '📦', title: 'ההזמנות שלי', preview: 'הזמנה #1234 · בדרך אליך', time: 'אתמול', badge: 1),
  (emoji: '🔧', title: 'השכרת כלים', preview: '2 כלים מושכרים עד 30.5', time: '21.5', badge: 0),
  (emoji: '💰', title: 'פקדונות', preview: 'פיקדון פעיל · ₪350', time: '21.5', badge: 0),
  (emoji: '↩️', title: 'החזרה חדשה', preview: 'בקשה #567 ממתינה לאישור', time: '20.5', badge: 0),
  (emoji: '📨', title: 'מכרז ספקים', preview: '3 הצעות חדשות התקבלו', time: '20.5', badge: 3),
  (emoji: '🧪', title: 'גיליונות בטיחות', preview: '5 גיליונות זמינים להורדה', time: '19.5', badge: 0),
  (emoji: '📊', title: 'השוואת מחירים', preview: '4 ספקים עדכנו מחירים', time: '19.5', badge: 2),
];
// תתי-הרשימות של הסקשנים = הפניות לאותן שורות (מקור: _kCartItems/_kOrderItems/_kServiceItems):
const storeSectionItemIndexes = (
  cart: [0],
  orders: [1],
  services: [2, 3, 4, 5, 6, 7], // בפרופיל raw-shell (kProfileRawShell) שורה 7 מוסרת — שער-קופסה
);
// מיפוי גליף-שירות ⇒ אינדקס-sheet (מקור: _kServiceByEmoji:1151):
const serviceIndexByEmoji = {'🔧': 0, '💰': 1, '↩️': 2, '📨': 3, '🧪': 4, '📊': 5};

// תבניות-ההחייאה של שורות ההאב (_AllList:1186-1216):
const hubLiveTemplates = (
  cartPreviewTpl: r'$cartCount פריטים ממתינים לסיכום', // t_f07ee271
  ordersEmptyPreview: 'אין הזמנות פעילות', // t_fae03b4a
  ordersPreviewTpl: r'הזמנה ${storeOrders.first.id} · ${storeOrders.first.stageLabel}', // t_4e289c0e
  underConstructionToastTpl: r'${item.title} — בבנייה', // t_5de6454b
);
const favoriteTooltips = (
  add: 'הוסף למועדפים', // t_4d537e46
  remove: 'הסר ממועדפים', // t_17a65674
);

// ─── מצב-ריק (_EmptyState:1576 ⇒ SearchEmptyState) ──────────────────────────
const emptyStateContent = (
  glyph: '🔍',
  noItems: 'אין פריטים', // t_86e9cfb0
  noResultsTpl: 'לא נמצאו תוצאות\nעבור "\$query"', // מקור: 1595-1597 (מחרוזת רב-שורתית)
);

// ─── הסל (_CartView:1617) ────────────────────────────────────────────────────
const emptyCartContent = (
  glyph: '🛒',
  title: 'הסל ריק', // t_85ab355c · CfgText shop.emptycart.title
  hint: 'הוסיפו מוצרים מהקטלוג', // t_c1a1c78c · CfgText shop.emptycart.hint
);
const smartProductsGroupLabel = '🛠️ מוצרים חכמים'; // t_c6869430 ⇒ SupplierHeader.label
const supplierHeaderContent = (
  labelTpl: r'🏪 $name', // קידומת-הגליף של _SupplierHeader:2142
  leadTime: 'אספקה: יום-יומיים', // t_67ea9596 · CfgText store_screen.supplier_lead_time
);
const cartLineLabels = (
  removeFromCart: 'הסר מהסל', // t_a530b6eb · tooltip הסרה (שתי שורות-הסל)
  increment: 'הוסף כמות', // t_c3f9ac23 · tooltip הוספה (שני הסטפרים)
  decrement: 'הפחת כמות', // t_f3943fe9 · tooltip הפחתה
);

// ─── שיוך-לפרויקט (_ProjectSelector:1783 ⇒ LabeledField + ProjectChip) ───────
const projectSelectorContent = (
  title: '🏗️ שיוך לפרויקט', // t_db751a61 · CfgText store_screen.proj_assign_title
  addChip: '+ הוסף', // t_4d445d01 · CfgVisible store_screen.proj_add_chip
  addDialogTitle: 'הוספת פרויקט', // t_379a88f7
  addNameHint: 'שם הפרויקט', // t_e02dcdf0
  addCancel: 'ביטול', // t_a7c55a8d
  addConfirm: 'הוסף', // t_cf0a5531
  noProject: 'ללא פרויקט', // t_09fa4f26 · האופציה הפונקציונלית האחרונה בצ׳יפים
);
// seed-הפרויקטים (מוזנח — _kProjects:376; המנוע-הקנוני הוא projectsProvider):
const checkoutProjectSeeds = ['בית דוד 3', 'מגדל עזריאלי', 'ללא פרויקט'];
const checkoutProjectSeedsEmptyProfile = ['ללא פרויקט']; // kProfileEmptySeeds ⇒ רק הדלי הפונקציונלי

// ─── משלוח + תשלום (_kDeliveryOptions:426 / _kPaymentOptions:432) ────────────
const deliverySectionTitle = '🚚 אפשרויות משלוח'; // t_a39e5bff · CfgText shop.delivery.title
const deliveryOptions = [
  (method: 'express', emoji: '⚡', label: '4 שעות', fee: 120),
  (method: 'standard', emoji: '📦', label: 'יום-יומיים', fee: 45),
  (method: 'pickup', emoji: '🏪', label: 'איסוף עצמי', fee: 0),
];
const deliveryFreeLabel = 'חינם'; // t_323814d1 · fee==0 ⇒ feeLabel
const paymentSectionTitle = '💳 אמצעי תשלום'; // t_6de2dafb · CfgText shop.payment.title
const paymentOptions = [
  (method: 'card', emoji: '💳', label: 'כרטיס'),
  (method: 'bit', emoji: '📲', label: 'ביט'),
  (method: 'supplierCredit', emoji: '🤝', label: 'אשראי ספק'), // t_fd82d7bd · שער supplierCreditEnabled (הגדרת הסדר אשראי ספק, t_e47e8d55)
];

// ─── הערות-לשליח (_NotesField:2528 ⇒ LabeledField + slot-שדה) ────────────────
const notesFieldContent = (
  title: '📝 הערות לשליח', // t_6e42e25a · CfgText shop.notes.title
  hint: 'קומה / כניסה / שם האתר / הוראות לנהג...', // t_2846c78a
);

// ─── כרטיס-הסיכום (_SummaryCard:2571 ⇒ CartSummaryCard) ─────────────────────
const cartSummaryContent = (
  subtotalExVat: 'סכום ביניים (ללא מע"מ)', // t_2c14716d · כשהמחירים כוללי-מע״מ
  subtotal: 'סכום ביניים', // t_2fbec343
  vat18: 'מע"מ 18%', // t_fdafda56
  delivery: 'משלוח', // t_ee0500fa
  freeDelivery: 'חינם', // t_323814d1
  totalToPay: 'סה"כ לתשלום', // t_33de167e
);

// ─── לאן-לשלוח (openShipToSheet:2331 — חסר בפלט-המכונה, הושלם) ───────────────
const shipToSheetContent = (
  title: 'לאן לשלוח?', // CfgText store_screen.shipto_title
  hint: 'לא חובה — אפשר לאשר את ההזמנה גם בלי כתובת ולהשלים בהמשך.', // shipto_hint
  addressHint: 'כתובת / אתר העבודה',
  skip: 'דלג', // CfgVisible store_screen.shipto_skip
  save: 'שמירה', // CfgVisible store_screen.shipto_save
);

// ─── checkout (_CheckoutButton:2747 / _CheckoutSheet:2872) ───────────────────
const checkoutContent = (
  ctaTpl: r'הזמן עכשיו · ${_price(widget.total)} →', // t_5b1b0f53 · CfgText cart.cta
  minOrderToastTpl: r'מינימום להזמנה: ${_price(s.minOrderAmount)}', // t_6f5d0940
  largeOrderTitle: 'אישור הזמנה גדולה', // t_2e9d90a9
  largeOrderBodyTpl:
      r'סכום ההזמנה ${_price(widget.total)} חורג מהסף שהגדרת (${_price(s.largeOrderThreshold)}). להמשיך?', // t_dd5e7ff9 + t_e7c81360
  largeOrderCancel: 'ביטול', // t_a7c55a8d
  largeOrderConfirm: 'אשר והמשך', // t_ddc5a985
  sheetTitle: 'סיכום הזמנה', // t_a53a169c · CfgText shop.checkout.title
  projectLabel: 'פרויקט', // t_5a15099c
  deliveryLabel: '📦 משלוח', // t_5269970d
  paymentLabel: '💳 תשלום', // t_1ff000f8
  totalLabel: 'סה"כ לתשלום', // t_33de167e
  confirm: 'אישור הזמנה', // t_3f824e0e · CfgText shop.checkout.confirm
  mustRegisterToast: 'יש להירשם כדי לבצע הזמנה', // t_353e0813
  pendingApprovalToast: 'החשבון ממתין לאישור — אפשר לשלוח בקשת תפקיד', // t_cd9f2154
  anonymousContractorFallback: 'קבלן', // t_804ba9cf · who כשהפרופיל ריק
  placedToastTpl: r'הזמנה ${placed.id} אושרה! 🎉', // t_a265695c
);

// ─── פעולות-הסל (_CartActionsRow:3192) ───────────────────────────────────────
const cartActionsContent = (
  lists: 'רשימות', // t_549c1465 · CfgVisible store_screen.actions_lists
  save: 'שמור', // t_f50251bc · store_screen.actions_save
  share: 'שתף', // t_6d33c292 · store_screen.actions_share · שער shareCartWithTeam (t_b0d97ab9)
  clear: 'נקה', // t_e8b3a3d5 · store_screen.actions_clear
  saveDialogTitle: 'שמור סל כרשימה', // t_83ac9f90
  saveNameHint: 'שם הרשימה', // t_71761413
  saveCancel: 'ביטול', // t_a7c55a8d
  saveConfirm: 'שמור', // t_f50251bc
  saveNameEmptyToast: 'שם הרשימה לא יכול להיות ריק', // t_df5b0619
  cartEmptyToast: 'הסל ריק', // t_85ab355c
  savedToast: 'הרשימה נשמרה בהצלחה', // t_6b7bcaa3
  savedListBrandName: 'רשימה שמורה', // t_3efd3075 · brandName של שורה משוחזרת
  savedListsTitle: '🔖 רשימות שמורות', // t_3dc922d0
  savedListsEmpty: 'אין רשימות שמורות עדיין', // t_f7577c50
  savedListGlyph: '🛒',
  savedListCountTpl: r'${list.items.length} פריטים', // t_7a5b3642
  deleteTooltip: 'מחק', // t_09b6bcca
  deleteConfirmTitle: 'מחיקת רשימה שמורה?', // t_8a4b3f94
  deleteConfirmBodyTpl: r'הרשימה "${list.name}" תימחק לצמיתות.', // t_797b1d72
  loadedToastTpl: r'הרשימה "${list.name}" נטענה לסל', // t_88324e6f
  clearConfirmTitle: 'ניקוי הסל?', // t_d035ae8c
  clearConfirmBody: 'כל הפריטים יוסרו מהסל.', // t_84ca53bf
  clearConfirmLabel: 'נקה', // t_e8b3a3d5
  clearedToast: 'הסל נוקה', // t_ab421fd8
  shareLineTpl: r'${l.productEmoji} ${l.productName} × ${l.productQty} = ₪${l.total}',
  shareTextTpl: 'סל \${AppBrand.name}:\n\$items\n\nסה״כ: ₪\$total', // מקור: 3489
);

// ─── שירותים (_kServices:3602 / _kServiceSheets:3611 ⇒ SheetScaffold+ServiceTile) ─
const services = [
  (emoji: '🔧', title: 'השכרת כלים', sub: '2 כלים פעילים'),
  (emoji: '💰', title: 'פקדונות', sub: 'פיקדון ₪350'),
  (emoji: '↩️', title: 'החזרה חדשה', sub: 'בקשה #567'),
  (emoji: '📨', title: 'מכרז ספקים', sub: '3 הצעות חדשות'),
  (emoji: '🧪', title: 'גיליונות בטיחות', sub: '5 גיליונות'),
  (emoji: '📊', title: 'השוואת מחירים', sub: '4 ספקים עודכנו'), // אינדקס 5 ⇒ sheet-השוואה אמיתי (openPriceCompareSheet)
];
const serviceSheetRows = [
  [
    (emoji: '🔨', label: 'מקדחה', sub: 'מושכרת עד 30.5'),
    (emoji: '🪚', label: 'משור חשמלי', sub: 'מושכר עד 28.5'),
    (emoji: '➕', label: 'הוסף כלי', sub: ''),
  ],
  [
    (emoji: '💳', label: 'פיקדון #123', sub: '₪350 · פעיל'),
    (emoji: '↩️', label: 'בקשת החזר', sub: ''),
  ],
  [
    (emoji: '📋', label: 'בקשה #567', sub: 'ממתינה לאישור'),
    (emoji: '📦', label: 'פריטים להחזרה', sub: '3 יחידות'),
    (emoji: '🚛', label: 'תיאום איסוף', sub: ''),
  ],
  [
    (emoji: '🏪', label: 'ספק A', sub: '₪4,200 · הצעה חדשה'),
    (emoji: '🏪', label: 'ספק B', sub: '₪3,980 · הצעה חדשה'),
    (emoji: '🏪', label: 'ספק C', sub: '₪4,500 · הצעה חדשה'),
  ],
  [
    (emoji: '📄', label: 'ברזל 12mm', sub: 'עודכן 20.5'),
    (emoji: '📄', label: 'צבע אפוקסי', sub: 'עודכן 18.5'),
    (emoji: '📄', label: 'דבק אפוקסי', sub: 'עודכן 15.5'),
    (emoji: '📄', label: 'ממס ניקוי', sub: 'עודכן 12.5'),
    (emoji: '📄', label: 'בטון יצוק', sub: 'עודכן 10.5'),
  ],
  [
    (emoji: '🏪', label: 'רוט', sub: 'ברזל 12mm · ₪4.20'),
    (emoji: '🏪', label: 'מ.א. שלמה', sub: 'ברזל 12mm · ₪3.85'),
    (emoji: '🏪', label: 'אחים כהן', sub: 'ברזל 12mm · ₪4.10'),
    (emoji: '🏪', label: 'בני ברק מבנים', sub: 'ברזל 12mm · ₪3.95'),
  ],
];
const serviceSheetContent = (
  underConstructionBadge: '🚧 בבנייה', // t_eb0da3be · CfgText store_screen.service_under_construction
  rowToastTpl: r'${r.label} — בבנייה', // t_35f5eb31
);

// ─── הזמנות (_stageLabelFor:3776 / _stageColorFor:3786 / _OrderTimeline._steps:4330) ─
// רשומה פר-שלב: תווית-רשימה (עם גליף) · תווית-ציר · פיגמנט · אייקון-ציר — verbatim.
const orderStages = [
  (stage: 'new', label: 'התקבלה 🆕', timelineLabel: 'התקבלה', color: 0xFF9C27B0, icon: 'assignment_outlined'), // t_fce6a64c
  (stage: 'preparing', label: 'בהכנה 🔧', timelineLabel: 'בהכנה', color: 0xFFFF9800, icon: 'build_outlined'), // t_397ab8a2
  (stage: 'ready', label: 'מוכן 📦', timelineLabel: 'מוכן', color: 0xFF2196F3, icon: 'inventory_2_outlined'), // t_4c43bbb7
  (stage: 'pickup', label: 'ממתין לאיסוף 🏪', timelineLabel: 'נאסף', color: 0xFF00BCD4, icon: 'store_outlined'), // t_028c26e8
  (stage: 'transit', label: 'בדרך 🚛', timelineLabel: 'בדרך', color: 0xFF4CAF50, icon: 'local_shipping_outlined'), // t_909665f8
  (stage: 'delivered', label: 'נמסר ✓', timelineLabel: 'נמסר', color: 0xFF888888, icon: 'check_circle_outline'), // t_8b72a1ae
];
const orderRowGlyph = '📦';
const orderItemsCountTpl = r'${o.items} פריטים'; // _orderViewOf:3806 (וגם t_a2b78b97 בבדיקת-הלגאסי)
const ordersHiddenContent = (
  glyph: '🔒',
  title: 'היסטוריית הרכישות מוסתרת', // t_36b56af9 · CfgText shop.orders.hidden
  hint: 'הפעלת "היסטוריית רכישות" בהגדרות תציג שוב את ההזמנות.', // t_8ddb4b04 (המתג: היסטוריית רכישות, t_1aa18690)
  showAction: 'הצג היסטוריה', // t_e727f18c · CfgVisible store_screen.orders_hidden_show
);
const orderSheetContent = (
  titleTpl: r'הזמנה ${order.id}', // t_5f10a6ef
  noItems: 'פרטי הפריטים אינם זמינים', // t_595f77f0 · store_screen.order_no_items
  subtotal: 'סכום ביניים', // t_2fbec343 · store_screen.order_subtotal
  vatDelivery: 'מע"מ + משלוח', // t_86c9d4ec · store_screen.order_vat_delivery
  total: 'סה"כ', // t_9fcb2a25 · store_screen.order_total
  shipToGlyph: '📍',
  notesGlyph: '📝',
  trackingTitle: '🚛 מעקב הזמנה', // t_240e3a9e · CfgText shop.tracking.title
  scanDelivery: 'סרוק תעודת-משלוח', // t_cf9911fb · store_screen.order_scan_delivery
  scanDeliveryGlyph: '📄',
  scanDeliveryToast: 'סריקת תעודת-משלוח (OCR) — בקרוב', // t_bab37283
);
