// 📜 קובץ-ראשי · screens__store_screen — פירוק-מסך-החנות (בנייה-חכמה) לאטומים-נקיים.
// מוצא קדוש: scratchpad/all-screens/screens__store_screen.dart (4,390 שורות) — לא נגענו.
// מפת-המכונה: screens-seed/machine/screens__store_screen.json · תוכן: new/dart-data-bs/screens__store_screen_content.dart
//
// ── שימוש באטומי-מדף קיימים (הכרעה-5: צורכים, לא משכפלים) ──
// נבדק מול המדף (new/dart-ui-bs/): PillButton · StatTile · BareStat · EmptyStateCard ·
// PlaceholderRow · HeroCard · TitledSection · QuickToolsList · WorkPathCard · OrderCard.
// אף widget של המסך אינו זהה-מנגנון לאטום-מדף (עוגנים):
//   _Pill (740) ≠ PillButton — למדף אין מצב active (צבע+משקל מתחלפים) ⇒ section_pill חדש.
//   _EmptyState (1576) ≠ EmptyStateCard — מרכז-מסך גלילה מלאה, לא כרטיס-מסגרת ⇒ search_empty_state.
//   _OrderRow (3951) ≠ OrderCard — שורת-רשימה עם עיגול-גליף ותג-שלב, לא כרטיס-רוחב ⇒ order_list_row.
//   _SheetTile (1088) ≠ PlaceholderRow — leading-גליף, בלי badge-trailing ⇒ sheet_tile.
//   _NotesField-כותרת (2528) ≠ TitledSection — גופן 12/black54, לא 16/w800 ⇒ labeled_field.
// ⇒ לא נצרך אטום-מדף בגוף האטומים (אטום ממילא לא מייבא אטום — חוק-1); הקופסה חופשית
//   לצרוך מדף לצד האטומים האלה.
//
// ── דדופ פנים-מסך שנפתר בפירוק ──
// _MoadimSheet + _TizmonSheet (קבוצת widget-dedup n=2, loc=14) + _FavoritesSheet ⇒ אותו
// מנגנון: sheet_scaffold + sheet_tile ×N; ההבדל = שורות-תוכן (moadimSheetTiles /
// tizmonSheetTiles / hub-items) — עברו ל-content. _SichaSheet ⇒ sheet_scaffold + contact_tile.
// _ServiceSheet ⇒ sheet_scaffold(עם subtitle) + service_tile + under_construction_badge.
// _SummaryLine נשמר כאטום עצמאי (summary_line) ובנוסף שוכן-מוטמע ב-cart_summary_card
// (חוק-1: אטום לא מייבא אטום) — כפל-גוף מכוון ומתועד.
//
// ── התרת-סבך: קריאות-provider שהפכו ל-props/callbacks (מה הקופסה תזרים) ──
// storeSectionProvider (קריאה+כתיבה, _SectionChipsRow/_FavoritesSheet/_AllList)
//   ⇒ section_pill.active + onTap; sheet_tile.onTap — הקופסה כותבת לסקשן.
// storeFavoritesProvider (_QuickActionsRow/_AllList) ⇒ isFav + onFavToggle
//   (grid_hub_card / store_hub_row / dismissible_fav_row).
// cartQtysProvider + smartCartProvider ⇒ הקופסה מחשבת cartItemCount ומזינה labels;
//   כתיבות (setQty/setLineQty/remove) ⇒ onRemove/onMinus/onPlus/minusButton/plusButton.
// storeOrdersProvider (נגזרת ordersEngineProvider) ⇒ order_list_row מקבל idLabel/metaLabel/
//   stageLabel/stageColor מפורמטים (orderStages ב-content); order_timeline מקבל currentIndex.
// cartProjectProvider/projectsProvider (_ProjectSelector) ⇒ project_chip.active+onTap;
//   דיאלוג-ההוספה (BsKeyboardField, addProject) = חיווט-קופסה, לא אטום.
// cartDeliveryProvider/cartPaymentProvider ⇒ delivery_option_card / payment_chip
//   active+onTap; ברירות-מחדל (storeSettings) = חיווט.
// storeSettingsProvider (vatInclusive/supplierCreditEnabled/purchaseHistory/displayMode/
//   sortDefault/shareCartWithTeam/saveCartToProject) ⇒ שערי-קופסה: אילו אטומים מרונדרים
//   ואילו labels (למשל cart_summary_card מקבל lines כבר לפי דין-המע״מ).
// intelBusProvider/telemetryProvider/toast/showModalBottomSheet/CfgText/CfgVisible/
//   BsKeyboardField/cartLineThumb(productBySku) ⇒ כולם חיווט-קופסה; האטומים מקבלים
//   Widget-slots (thumb/stepper/trailing/stageChip/child) או callbacks בלבד.
// שערים (kHideUnderConstruction · featOn(orders,services) · modOn(finance) · kGlobalSearch ·
//   kProfileRawShell · kProfileEmptySeeds) ⇒ תמיד בקופסה; האטומים עיוורים להם (חוק-5).
//
// ── קומפוזרים שנשארים קופסאות (לא נחצבו לאטום) ──
// StoreScreen/_StoreList/_AllList/_CartView/_SummaryRow/_SectionChipsRow/_QuickActionsRow/
// _ProjectSelector/_DeliverySelector/_PaymentSelector/_CheckoutButton/_CheckoutSheet/
// _CartActionsRow/_ServicesGrid/_OrdersList/_OrderSheet + openShipToSheet — לוגיקת-חיבור
// (providers, שערים, דיאלוגים, checkout) על-גבי האטומים שכאן + content.
// מועמדי-לוגיקה טהורים למחצבה (לא UI): savedLineReconstruct · cartVat · cartTotal ·
// cartItemCount · deliveryFeeFor · cartDeliveryFor/cartPaymentFor · isOrderOpen ·
// cartBelowMinimum · cartNeedsLargeConfirm · _price.
