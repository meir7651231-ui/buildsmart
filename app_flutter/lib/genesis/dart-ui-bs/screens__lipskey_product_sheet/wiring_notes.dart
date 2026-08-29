// 📜 קובץ-ראשי · screens__lipskey_product_sheet — פירוק סדין-מוצר-ליפסקי (בנייה-חכמה)
// לאטומים-נקיים. מוצא קדוש: scratchpad/all-screens/screens__lipskey_product_sheet.dart
// (3,557 שורות) — לא נגענו. מפת-המכונה: screens-seed/machine/screens__lipskey_product_sheet.json
// תוכן: new/dart-data-bs/screens__lipskey_product_sheet_content.dart
//
// ── שימוש באטומי-מדף קיימים (הכרעה-5: צורכים, לא משכפלים) ──
// נבדק מול המדף (new/dart-ui-bs/): PillButton · StatTile · BareStat · EmptyStateCard ·
// PlaceholderRow · HeroCard · TitledSection · QuickToolsList · WorkPathCard · OrderCard,
// וקבוצות widget-dedup.json (0 קבוצות). אף widget של הסדין אינו זהה-מנגנון לאטום-מדף:
//   _SectionTitle (1990) ≠ TitledSection — שורת גליף+כותרת+תת-כותרת 14/w700, לא
//     כותרת-מעל-תוכן 16/w800 ⇒ emoji_section_title חדש.
//   _RelatedCard (1416) ≠ HeroCard/OrderCard — מיני-כרטיס-קרוסלה 112px ⇒ product_mini_card.
//   _EmptyHint (3109) ≠ EmptyStateCard — שורת-טקסט נטויה, לא כרטיס-מסגרת ⇒ empty_hint_text.
//   _QtyStepper (1317) ≠ SmartQtyStepper של מסך-החנות (אייקונים+Tooltip, בלי מסגרת-מותג)
//     ⇒ qty_stepper_box (כפתורי-גליף − / + בקופסה-ממוסגרת).
// ⇒ אף אטום-מדף לא נצרך בגוף האטומים (אטום ממילא לא מייבא אטום — חוק-1); הקופסה
//   חופשית לצרוך מדף לצד האטומים האלה.
//
// ── דדופ פנים-מסך שנפתר בפירוק ──
// _ProductSide (1559) + _SpecSide (1760) ⇒ image_face_pager אחד (פייג'ר 1/N + זום +
//   כפתור-היפוך; ההבדלים — גרדיאנט-רקע, תג-PPR-CT, אייקון/תווית — props/שקעים).
// _RelatedCard (1416) + פריט-_miniCarousel (3026) ⇒ product_mini_card אחד (מידות כ-params;
//   צ'יפ-הסבר-חיבור אופציונלי).
// _kitRow (2619) + שורת-התקינות (2720) ⇒ tag_detail_row אחד (משקלים כ-params).
// _hopRail (416) + _hopConnectRail (468) ⇒ action_chip_rail אחד (כותרת+צ'יפים).
// _Divider (2030) + מפריד-הרצועות (2330) ⇒ inset_divider אחד (indent/thickness).
// כפתור-X של המציג-המלא (106) + של הסדין (766) ⇒ circle_close_button אחד (tooltip כ-param).
//
// ── התרת-סבך: קריאות-provider/מנוע שהפכו ל-props/callbacks (מה הקופסה תזרים) ──
// catalogSettingsProvider (reducedMotion :1506) ⇒ flip_card.reducedMotion (bool).
// catalogSettingsProvider (מטבע/מע"מ/ליחידה :2275, :2964) ⇒ הקופסה מחשבת formatCatalogPrice/
//   priceWithVat ומזרימה ל-price_estimate_panel טקסטים מוכנים (currencyText/amountText/
//   unitSuffixText) ול-info_strip_row את value של רצועת-המחיר.
// catalogSettingsProvider (formatDimValue :1017) ⇒ ערכי-שורות-המפרט מפורמטים בקופסה.
// featureFlagsProvider (kCardKeyboardFlag/kUnifiedFinderFlag ⇒ _live :405) ⇒ שער-קופסה:
//   האם לרנדר hop_breadcrumb / action_chip_rail / צ'יפי-הקו — האטומים עיוורים לדגל (חוק-5).
// smartCartProvider (add :338, :374, :633) ⇒ onPressed/onTap בלבד (recommended_kit_banner.
//   onPressed, כפתור-הסל בפס-הרכישה); SnackBar-ים = חיווט (התבניות ב-content).
// cardPicksProvider (:518, :546, :644) ⇒ הקופסה קוראת/כותבת; צ'יפי הוסף-לקו/השלם-קו =
//   ActionChip-ים בחיווט עם תוויות מ-content (hopCluster/lineBomSheet).
// claudeGatewayProvider (:1283) ⇒ שער-קופסה לכפתור מה-עוד-צריך-להתקנה (purchaseBar).
// HopGraph/divePoolBySku/HopStack (:417, :477, :179) ⇒ הקופסה גוזרת chipLabels/crumbLabels
//   ומעבירה onChipTap/onCrumbTap/onHomeTap; המחסנית נשארת בקופסה.
// מנועי-הקטלוג (finderGroupFor/compatibleProductsCount/installKitFor/variantSiblingsCountFor/
//   complianceTriggersFor/engineeringSpecFor/companyComplementsFor + המטמון פר-sku :2164)
//   ⇒ קופסה; רצועות = info_strip_row עם label/value מוכנים (stripDefs ב-content).
// productImage (data/product_images) ⇒ שקעי-Widget: image_face_pager.imageBuilder,
//   product_mini_card.media — הקופסה בונה את התמונה עם fallback-גליף.
// Navigator.pop/push (סגירה, SpecCopilotScreen, PairedExplainScreen) ⇒ callbacks בלבד.
// Clipboard.setData (העתקת-מק"ט :826) ⇒ חיווט-קופסה על GestureDetector של טקסט-המק"ט.
// שערים (kStoreComparisonUi · kVerifiedSpecs · kCompanySpecSkus · companyCatalogActive ·
//   kLipskeyConnectionSizeOverride/kLipskeyCompatPairOverride) ⇒ תמיד בקופסה.
//
// ── קומפוזרים שנשארים קופסאות (לא נחצבו לאטום) ──
// showLipskeyProductSheet (שומר-הכניסה-החוזרת :56-84) · _openFullscreenAsset (:87 —
// InteractiveViewer + circle_close_button + טקסט-רמז מ-content) · LipskeyProductSheet/
// _LipskeyProductSheetState (סדר-הסקציות, פס-הרכישה הנעוץ, שערי-הדגל) · _QuickInfoStrips
// (מטמון-עובדות + בחירת-רצועות) · _StripPanel (switch פר-סוג ⇒ strip_panel_frame + גופים
// מאטומי head/bullet/row) · _InteractiveChips (זיהוי-אחים) · _showLineBom (סדין-BOM).
// מועמדי-לוגיקה טהורים למחצבה (לא UI): _sizeSet · _connectionSizes · _material ·
// _partsForSize · _connectionGroups · _installKit · _sizeLabel · pprWeldDn ·
// _formatKitSummary · _formatSpecValue · _colorFrame · _variantsColor/Subtype/Type/Model/
// Size · _resolveCompoundType · _firstSizeNum · _hasSiblings · _pickerOptions.
//
// הקובץ מסתיים בלי קוד — תיעוד-חיווט בלבד (כמו wiring_notes של מסך-החנות).
