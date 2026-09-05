// 📦 דאטה-תוכן · screens__lipskey_product_sheet (בנייה-חכמה) — ליטוש-ידני של פלט screen-lift.
// מוצא קדוש: scratchpad/all-screens/screens__lipskey_product_sheet.dart — הכול verbatim, אפס-המצאה.
// מונח שקיים בקטלוג-המונחים מסומן במפתחו (t_xxxx ⇒ uiTerms ב-ui_terms.dart) — הקופסה
// צורכת termOf(key); הערכים כאן = דאטה-מסך שהקופסה מזרימה לאטומים שב-
// new/dart-ui-bs/screens__lipskey_product_sheet/. תבניות-$ נשמרות כ-raw strings —
// הקופסה מפרמטת, האטום מקבל מחרוזת-מוכנה. מפתחות-cfg (CfgText במקור) בהערות.
// ⚠️ 8 מחרוזות שהמכונה פספסה (escaped-quote: ג'וקר/ראטצ'ט/עמ') שוחזרו כאן מהמקור.

// ─── כרום-הסל: ידית, סגירה, מציג-מלא (:87-137, :754-792) ────────────────────
const sheetChrome = (
  closeLabel: 'סגור', // t_55247199 · Semantics+Tooltip של כפתור-ה-X (גם במציג-המלא)
  fullscreenPinchHint: 'צבוט להגדלה · הקש לסגירה', // t_36c80ecd · cfg: zoom_hint_fullscreen
);

// ─── פני-הכרטיס-המתהפך (:1470-1891 ⇒ FlipCard + ImageFacePager + ZoomHintBadge) ──
const heroFaces = (
  nextImageLabel: 'התמונה הבאה', // t_a0e071ac · פייג'ר צד-המוצר
  nextSpecLabel: 'המפרט הבא', // t_7c95e6fb · פייג'ר צד-המפרט
  flipToSpecLabel: 'פרטים / מפרט', // t_e0157a6d · cfg: details_spec (Icons.description_outlined)
  flipToProductLabel: 'חזרה למוצר', // t_d5bd65f6 · cfg: back_to_product (Icons.image_outlined)
  zoomHintLabel: 'הגדלה', // t_e6ec4e84 · cfg: zoom
  pprCtBadge: 'PPR-CT', // cfg: ppr_ct_badge · תג-פינה, מגודר dims['חומר'].contains('PPRCT')
  materialDimKey: 'חומר', // t_9a215501 · מפתח-dims של שער-התג (:1666)
);

// ─── כותרת-המוצר (:806-954) ─────────────────────────────────────────────────
const productHeader = (
  skuCopiedMsg: 'מק"ט הועתק', // t_6bd4b076 · cfg: sku_copied · SnackBar אחרי העתקת-מק"ט
  fullNameDimKey: 'שם מלא', // t_cbdaff61 · dims-key: שם-מלא גובר על nameHe (:847)
  dataScoreTpl: r'📋 שלמות נתונים ${d.score}% · ${d.label}', // t_f84ce1e0 · ScoreBandChip
  installScoreTpl: r'🔧 מוכנות התקנה ${s.score} · ${s.label}', // t_3a3361c4 · ScoreBandChip
  chipHint: '💡 צ׳יפ כתום ▾ — הקש להחלפת גודל/צבע/דגם', // t_556efd24 · cfg: chip_hint · רק כשיש >1 אחים
);

// ─── אשכול-הקפיצות מגודר-הדגל (:399-699 ⇒ ActionChipRail + HopBreadcrumb) ───
const hopCluster = (
  relatedRailTitle: '🔗 קשור', // t_00644600 · cfg: related_rail_title
  connectsRailTitle: '🔌 מה מתחבר לזה', // t_b1107d71 · cfg: connects_rail_title
  hopBackLabel: 'חזרה למוצר הקודם', // t_9b10863b · cfg: hop_back (ActionChip + Icons.undo)
  addToLineLabel: 'הוסף לקו', // t_78d84878 · cfg: add_to_line (Icons.add)
  completeLineTpl: r'השלם קו (${picks.length})', // t_dc59d0dc · מופיע רק כש->=2 בחירות
  addedToLineMsg: 'נוסף לקו ✓', // t_e0e3e75f · cfg: added_to_line · SnackBar
);

// ─── סדין-BOM-הקו (:556-629, חיווט-קופסה על אטומי-טקסט) ─────────────────────
const lineBomSheet = (
  title: '📋 רשימת חומרים — קו', // t_a8560b06 · cfg: line_bom_title
  emptyMsg: 'לא נמצאו פריטים לפתרון — בחר מוצרים אחרים לקו', // t_29fdd6dc · cfg: line_bom_empty
  itemTpl: r'• ${item.nameHe}  ×${plan.qtyOf(item.sku)}',
  gapsTpl: r'⚠️ ${plan.gaps.length} פערים — דורש השלמה', // t_2bfae940
  addAllBtn: 'הוסף הכל לסל', // t_c48ad859 · כפתור-מלא כשיש פריטים
  noItemsBtn: 'אין פריטים לסל', // t_58f615b1 · תווית-הכפתור-המנוטרל (plan ריק)
  lineAddedTpl: r'נוספו ${items.length} פריטי-קו לסל ✓', // t_0563f7af · SnackBar
);

// ─── פס-הרכישה הנעוץ (:1183-1305 ⇒ QtyStepperBox + UnitSegmentToggle) ───────
const purchaseBar = (
  totalUnitsTpl: r'סה"כ ${_qty * _unitMult} יחידות', // t_7066e63b · רק כשהיחידה ≠ בודד
  selectedAccessoriesLabel: 'אביזרים נבחרים:', // t_07294f05 · cfg: selected_accessories
  accessoriesTotalTpl: r'+ ₪$_accTotal',
  addToCartBtn: 'הוסף לסל', // t_4dd4fd24 · cfg: add_to_cart_btn (Icons.shopping_cart)
  addedToCartMsg: 'נוסף לסל ✓', // t_b1bbe7e5 · cfg: added_to_cart · SnackBar
  specCopilotCta: 'מתאים לתנאים שלי?', // t_df9e7a0f · cfg: spec_copilot_cta (🌡️) · שער kVerifiedSpecs
  pairedExplainCta: 'מה עוד צריך להתקנה?', // t_5eabf8fe · cfg: paired_explain_cta (🧩) · שער gateway
);

// בורר-היחידות (:1360-1413 · _Unit single/pack/pallet — הסדר = אינדקס):
const unitToggleOptions = [
  'בודד', // t_4f815ce8 · תמיד פעיל
  'ארגז', // t_2efbb17a · פעיל רק כש-qtyPack != null
  'משטח', // t_a9857806 · פעיל רק כש-qtyPallet != null
];

// ─── כותרות-הסקציות (:968-1049 ⇒ EmojiSectionTitle) ─────────────────────────
const sectionTitles = (
  stages: (emoji: '📋', title: 'שלבי התקנה'), // t_0c33f303
  stagesCountTpl: r'${_stages.length} שלבים', // t_bf8150a5
  details: (emoji: '📐', title: 'פרטי מוצר'), // t_cc9b1d22
  compat: (emoji: '🔧', title: 'חיבורים תואמים'), // t_fffb5824
  compatMultiTpl: r'${groups.length} צדדים — מה מתחבר לכל מידה', // t_deaae812
  compatSingleTpl: r'מה מתחבר ל-${_sizeLabel(groups.first.size)}', // t_48c8721a
);

// ─── שורות-המפרט (:1000-1022 ⇒ SpecRow) ─────────────────────────────────────
const specRows = (
  color: (emoji: '🎨', label: 'צבע'), // t_be49d01c
  qtyPack: (emoji: '📦', label: 'כמות באריזה'), // t_57c67db4
  qtyPallet: (emoji: '🏗️', label: 'כמות במשטח'), // t_1c17f824
  dims: (emoji: '📐'), // שורה פר-מפתח-dims (למעט שם מלא)
  catalogPage: (emoji: '📄', label: 'עמוד בקטלוג'), // t_5cdc3761
  catalogPageTpl: r'עמוד ${p.page}', // t_2a319539 · מגודר p.page > 0
  bogusPageGuardNote: 'עמוד 0', // t_ddb10342 · ההערה-במקור: מיובאים נושאים עמוד-0 — אין שורה
);

// ─── חיבורים-תואמים + ערכת-התקנה (:1034-1174) ───────────────────────────────
const compatSection = (
  kitBannerTitle: 'ערכת התקנה מומלצת', // t_4c529070 · cfg: recommended_kit
  kitBannerSubtitleTpl: r'${kit.length} חלקים — מתאם לכל צד חיבור', // t_b2ab6a53
  kitBannerBtn: '+ ערכה', // t_846e081f · cfg: add_kit
  kitBannerEmoji: '🧩',
  kitAddedTpl: r'נוספו ${kit.length} חלקי ערכת-התקנה לסל ✓', // t_d1b299a7 · SnackBar
  sideBadgeTpl: r'📐 צד ${gi + 1}: ${_sizeLabel(g.size)}', // t_89f5b381 · רב-צדדי
  sizeBadgeTpl: r'📐 ${_sizeLabel(g.size)}', // חד-צדדי
  partsCountTpl: r'${g.parts.length} חלקים', // t_47a15e63
  dnLabelTpl: r'DN$s', // _sizeLabel: מספר-עירום ⇒ DN, אחרת אינץ' עם גרש
  compatOverrideGroupLabel: 'תואם', // t_6d56cb2f · תווית-קבוצת-הזיווגים-הידניים (:309)
);

// ─── רצועות-המידע (:2201-2305 ⇒ InfoStripRow; הגוונים = פיגמנטים בחיווט) ────
const stripDefs = (
  finder: (label: 'נמצא ב'), // t_85f7879a · icon: Icons.travel_explore (עקיפת-canvaskit)
  compat: (emoji: '🤝', label: 'מוצרים תואמים'), // t_3277649e
  compatCountTpl: r'$compat מוצרים', // t_6790d529
  complements: (emoji: '🧩', label: 'מוצרים משלימים'), // t_e9f79937 · שער companyCatalogActive
  complementsCountTpl: r'${_companyComplements.length} מוצרים', // t_34e5ce0b
  kit: (emoji: '📦', label: 'ערכת התקנה'), // t_cdf6e5c3
  kitMustTpl: r'${k.must} חובה', // t_381255fc · _formatKitSummary
  kitOptionalTpl: r'${k.optional} אופציה', // t_384b1370
  kitToolsTpl: r'${k.tools} כלים', // t_6c4eb790
  variants: (emoji: '🔄', label: 'דומים'), // t_1225bb8f
  variantsCountTpl: r'$famCount וריאנטים', // t_17e0803a
  compliance: (emoji: '🛡', label: 'תקינות'), // t_ba3d5a63
  complianceCountTpl: r'${_compliance.length} דרישות', // t_c599e3ff
  spec: (emoji: '📊', label: 'מפרט הנדסי'), // t_91cfe6b8
  price: (emoji: '💰', label: 'מחיר משוער'), // t_47d028be
  priceUnitSuffixTpl: r'$base ליחידה', // t_ff166df7 · כש-showUnitPrice דלוק
  infoPolyroll: (emoji: 'ℹ️', label: 'מידע כללי', value: 'צנרת PPR · יתרונות'), // t_545926bc · t_53c6729c
  hygiene: (emoji: '🧼', label: 'חיטוי וניקוי', value: 'בור חלק · ללא אבנית'), // t_8a6a6fe2 · t_68db4ca1
  infoHuliot: (emoji: 'ℹ️', label: 'מידע כללי', value: 'SmartLock™ · דלוחין PP · 32-63 מ"מ'), // t_bb5573c7
);

// שערי-מותג של רצועות-המידע (דאטה-קטלוג, לא מונח-UI):
const stripBrandGates = (polyroll: 'פולירול', huliot: 'חוליות'); // t_14bbc679 · t_58f7253a

// ─── רמזי-ריקנות של הפאנלים (⇒ EmptyHintText) ───────────────────────────────
const stripEmptyHints = (
  finderNoGroup: 'אין קבוצה', // ❗ לא-בקטלוג (פספוס-מכונה) · :2496
  finderNoPeers: 'אין מוצרים אחרים בקבוצה', // t_3cca7958
  compatNoSpec: 'אין מפרט תואם', // t_c5cdf8bb
  compatNoHits: 'לא נמצאו מוצרים שמשלימים את הקצוות', // t_c6bea672
  noComplements: 'אין מוצרים משלימים', // t_334a1128
  noKit: 'אין רשימת ערכת התקנה', // t_def9753f
  noVariants: 'אין וריאנטים נוספים', // t_31215d8f
  noCompliance: 'אין דרישות תקינות מיוחדות', // t_dfe05957
  noSpec: 'אין מפרט הנדסי מאומת', // t_04858d0a
  noPrice: 'אין הערכת מחיר לקטגוריה זו', // t_b351ca65
);

// ─── פאנל-ערכת-ההתקנה (:2550-2701 ⇒ InfoHeadLine/AccessoryRow/TagDetailRow) ──
const kitPanel = (
  mustHead: 'חובה (עץ חכם)', // t_ce2d1247 · cfg: must_smart_tree
  optionalHead: 'אופציונלי (עץ חכם)', // t_878565e4 · cfg: optional_smart_tree
  toolsHead: 'כלים ואיטומים (אוטומטי)', // t_ae6a43f7 · cfg: tools_auto
  mustBadge: 'חובה', // t_116f6cc8 · cfg: must_badge (וגם must_badge_compliance)
  toolTag: 'כלי', // t_4ebe8c1e · KitKind.tool
  sealantTag: 'איטום', // t_961f8946 · KitKind.sealant
  safetyTag: 'בטיחות', // t_e642cece · KitKind.safety
);

// תוכנית-ריתוך-שקע PPR (דאטה-קטלוג עמ' 9 · :2089-2100 _kPprWeldPlan):
// פר-קוטר: (עומק-החדרה מ"מ, חימום שנ', קירור דק'). פלטה 260°C.
const pprWeldPlan = <String, (double, int, int)>{
  '20': (14.5, 8, 2),
  '25': (16.0, 11, 2),
  '32': (18.0, 12, 4),
  '40': (20.5, 18, 4),
  '50': (23.5, 27, 4),
  '63': (27.5, 36, 6),
  '75': (30.0, 45, 8),
  '90': (33.0, 60, 8),
  '110': (37.0, 75, 8),
  '125': (40.0, 90, 8),
};

// מפתחות-dims לאיתור ה-DN של צינור-PPR (:2107 pprWeldDn — 'dn נומינלי' גובר):
const pprWeldDimKeys = (
  nominal: 'dn נומינלי', // t_5b5f4b25
  outer: 'קוטר חיצוני', // t_6e33b8a9
);

const weldPlanSection = (
  head: 'תוכנית ריתוך-שקע (פלטה 260°C)', // t_9fe58ad5
  perDnTpl: r'⌀$dn: עומק ${weld.$1} מ"מ · חימום ${weld.$2} שנ׳ · קירור ${weld.$3} דק׳', // t_f56bf66c
  steps: [
    'ודא פלטה ב-260°C ותותבים מחוזקים', // t_ea5beea1
    'הכנס צינור ואביזר לתותבים (נקבה+זכר)', // t_4f346a88
    'חמם לפי הזמן בטבלה, שלוף וחבר מיד עד הסימון', // t_eacdf049
    'החזק מחוברים ללא סיבוב עד התקררות', // t_91877422
  ],
);

// ─── פאנל-המפרט-ההנדסי (:2766-2809 ⇒ SpecMonoRow) ───────────────────────────
const specPanelKeys = (
  material: 'חומר', // t_9a215501
  pressureRating: 'דירוג לחץ', // t_a0fdf3a3
  workPressure: 'לחץ עבודה', // t_eb6c72fa
  workPressureDimKey: 'לחץ עבודה (50 שנה)', // t_2783a1e0 · מפתח-dims וגם fallback-תווית
  maxTemp: "טמפ' מקס'", // ❗ לא-בקטלוג (escaped-quotes) · :2800
  waterSystem: 'מערכת', // t_f71c2fc7
  minBore: 'קוטר פנימי', // t_d5b13d16
  ends: 'קצוות חיבור', // t_5a109e57
  importedDataHead: 'לפי נתוני היבוא', // t_7f5b391c · כותרת-כנות כשהמפרט גושר-מייבוא
);

// ─── פאנל-המחיר (:2955-3021 ⇒ PriceEstimatePanel) ───────────────────────────
const pricePanel = (
  estimatePrefix: '~',
  perUnitSuffix: 'ליחידה', // t_98f13081 · cfg: per_unit
  estimateBadge: 'הערכה', // t_c242b4ba · cfg: estimate_badge
  note: 'הערכה לפי קטגוריה — מחיר אמיתי תלוי בספק, מותג ומידה ספציפית.', // t_f4ca49bd · cfg: price_note
);

// צ'יפ-הסבר-החיבור בקרוסלת-התאימות (:3083 ⇒ ProductMiniCard.linkChipLabel):
const connectExplainChipTpl = r'🔗 $label'; // הקופסה מפרמטת עם connectionExplainHe

// ─── מידע-כללי · פולירול PPR (מהקטלוג עמ' 77 · :2828-2858) ──────────────────
const polyrollInfo = (
  imageAsset: 'assets/polyroll/products/ppr_green_system.jpg',
  caption: 'צנרת PPR לאספקת מים חמים וקרים', // t_fa9f1255 · cfg: ppr_caption
  rawMaterialHead: 'חומר גלם', // t_aea296db
  rawMaterialBullets: [
    'אביזרים: PPR', // t_0a5e574e
    'אביזרי תבריג: PPR + פליז DZR', // t_189f09c2
  ],
  advantagesHead: 'יתרונות', // t_32bf4be3
  advantagesBullets: [
    'הצנרת היחידה לאספקת מים ההומוגנית בכל חלקיה לאחר ריתוך', // t_61bf2962
    'אין קורוזיה ואין הצטברות אבנית בכל חלקי המערכת', // t_2bb110b1
    'מקדם חיכוך נמוך ביותר — נשארת נקייה לאורך שנים', // t_dfa1ae5a
    'אין הקטנת קוטר בצינורות ובאביזרים לאחר החיבור', // t_bd64ab0a
    'עמידות מצוינת וארוכת טווח בלחצים גבוהים', // t_99601b96
    'רמת אקוסטיקה גבוהה', // t_c92ea2ed
    'צנרת קלה ונוחה לעבודה, מגוון אביזרים רחב', // t_8fafa1f8
    'מחברי הברגה מפליז DZR לסביבה קורוזיבית', // t_dbfbfa64
  ],
);

// ─── מידע-כללי · חוליות SmartLock (מהקטלוג עמ' 5-6 verbatim · :2861-2931) ────
// מבנה: רשימת (כותרת, תבליטים) — הקופסה ממפה ל-InfoHeadLine + InfoBulletLine.
const huliotInfoCaption =
    'SMART LOCK — מערכת דלוחין, צנרת ואביזרים מפוליפרופילן בקטרים 32-63 מ"מ בצבע שחור'; // t_2999e2d6 · cfg: smartlock_caption
const huliotInfoSections = <({String head, List<String> bullets})>[
  (
    head: 'חומר גלם', // t_aea296db
    bullets: [
      'צינור רב שכבתי PPML-MD-S16', // t_72ab7d74
      'שכבה חיצונית: פוליפרופילן שחור — מעכבת קרני UV', // t_7ff66bff
      'שכבה אמצעית: פוליפרופילן עם תרכובת מינרלית PPMD — בידוד אקוסטי', // t_10359a7d
      'שכבה פנימית: פוליפרופילן לבן — מאפשרת ניטור ובקרה חזותיים', // t_d5dadf10
      'אביזרים: PPMD PP', // t_0eeb272e
      "שיטת חיבור: נעילת שיניים - ראטצ'ט", // ❗ לא-בקטלוג (escaped-quote) · :2878
      'אטם מערכת: אטם לחץ אלסטומרי TPE', // t_184e13d7
    ],
  ),
  (
    head: 'יתרונות', // t_32bf4be3
    bullets: [
      'התקנה מהירה ופשוטה, אטם אינטגרלי באביזר', // t_adcc8df4
      'אטם עמיד לאורך זמן', // t_59e53b01
      'חוזק טבעתי גבוה', // t_2b388c02
      'עמידות כימית גבוהה', // t_db589922
      'קשיחות ויציבות גבוהים', // t_032f875a
      'עמידות בפני פגיעות מכניות', // t_4e03aa9c
      'מודול אלסטיות ואימפקט גבוה', // t_e5325bf9
      'פנים צינור חלק מאפשר זרימה נקיה', // t_d3ab5fdb
      'תוצאות צילום חדות במיוחד', // t_1daeb73a
      'מיוצר בישראל · בעל תו תקן ישראלי', // t_88ec9d79
      'קיימות (אורך חיים) ל-100 שנה', // t_cd4c1ac7
      'שימוש בצינורות חלקים', // t_470cd325
      'אין צורך בהכנת פאזה לצינור (נדרש לנקות גראדים) · אין צורך בשימוש בחומרי סיכה', // t_712bf262
      'צנרת אקוסטית להפחתת רעש', // t_df3a023a
      'צנרת עמידה בעומסי כבידה ללא היווצרות בטן', // t_89421619
      'עמידות בתנאי מזג אויר קשים', // t_04bedc33
    ],
  ),
  (
    head: 'תקינות', // t_ba3d5a63
    bullets: [
      'ת"י 958-1 — היתר 737 (צנרת PP לסילוק שפכים חמים)', // t_de12074e
      'ת"י 71253-1 — היתר 114782 (מחסום ריחות מפלסטיק לרצפה)', // t_d2dbe848
      'ת"י 71253-2 (מאסף מפלסטיק לרצפה ברצפה)', // t_57186e49
      'ת"י 5694 — היתר 114783 (אביזרי ניקוז לאמבט, מחסומים גלויה וסיפונים)', // t_31d24c0d
      'ת"י 14020 — היתר 70304 (תו ירוק למוצרי PP)', // t_cb7bc3be
      'תקן בינלאומי EN-1451 · DIN 8078 · ISO 180', // t_5975d756
    ],
  ),
  (
    head: "התקנה כללית (עמ' 8)", // ❗ לא-בקטלוג (escaped-quote) · :2906
    bullets: [
      '1. הכנס את הצינור* או האביזר עד למעצור (*ללא גראדים)', // t_4d55e491
      '2. הדק את האום עד לנעילת השיניים', // t_5ab69866
    ],
  ),
  (
    head: "התקנת מתאם זווית - ג'וקר", // ❗ לא-בקטלוג (escaped-quote) · :2909
    bullets: [
      "1. הכנס את גוף הג'וקר לאביזר הנדרש, ללא הידוק חיבור הסמארטלוק", // ❗ לא-בקטלוג · :2911
      '2. השחל את האום והאטם הכדורי על הצינור', // t_4c297e67
      "3. קבע את הזווית הרצויה במחבר הג'וקר והדק את אום הג'וקר", // ❗ לא-בקטלוג · :2914
      '4. הדק את אביזר הסמארט לוק', // t_e31224b4
    ],
  ),
  (
    head: "התקנת פקק במחסום/מאסף (עמ' 9)", // ❗ לא-בקטלוג (escaped-quote) · :2916
    bullets: [
      'הכנס את הפקק שהמילה UP נמצאת בחלקו העליון וידית האחיזה נמצאת במצב אנכי', // t_e6b18b19
      'הדק את האום עד נעילת השיניים', // t_f158ba26
    ],
  ),
  (
    head: 'התקנה ידנית של האום', // t_eae8fac5
    bullets: [
      '⚠️ האביזרים מגיעים כשהאומים מורכבים עליהם ומוכנים להתקנה. במצב שבו האום מופרד מהאביזר יכול להתקיים רק על ידי פתיחה מכוונת', // t_6516d642
      'כוון את החץ הירוק שעל האום מול השן הגדולה באביזר ← הברג את האום עד לשמיעת הקליק (מעבר מעל השן הגדולה)', // t_4209dd44
    ],
  ),
  (
    head: 'חיטוי וניקוי', // t_8a6a6fe2
    bullets: [
      'תכונות הניקיון נובעות משכבה פנימית פוליפרופילן לבן חלקה ⇒ ללא הצטברות זרימה חופשית', // t_af226b16
      'לא נדרש חיטוי שוטף — שטיפה במים בלבד ברוב המקרים', // t_bb4af86f
    ],
  ),
];

// ─── פאנל-חיטוי-וניקוי · פולירול (מהקטלוג עמ' 77 · :2934-2952) ───────────────
const hygienePanel = (
  intro: 'שתי צורות חיטוי למערכות פולירול: תרמי וכימי', // t_7f04a66e
  sections: <({String head, List<String> bullets})>[
    (
      head: 'חיטוי תרמי', // t_84c36041
      bullets: [
        '70°C למשך 30 דק׳ (טיפול בלגיונלה)', // t_f853e1ee
        'ניתן בטמפ׳ גבוהה יותר לפי הטבלאות — ללא חריגה מהמרבי', // t_628acc08
      ],
    ),
    (
      head: 'חיטוי כימי', // t_268e450c
      bullets: [
        'כלור חופשי 50 מ"ג/ל׳ מעל 12 שעות — פעמיים בשנה', // t_0013a216
        'חלופה: מי חמצן (H2O2) 150 מ"ג/ל׳ למשך 24 שעות', // t_98d337f8
        'טמפ׳ עד 30°C בזמן החיטוי הכימי', // t_1ed4903f
      ],
    ),
    (
      head: 'אזהרות (חוליות)', // t_87b6177b
      bullets: [
        'אסור לבצע חיטוי תרמי וכימי בו-זמנית', // t_31ef6888
        'אסור שימוש בכלור דיאוקסיד במערכות PPR', // t_e56095e7
        'חיטוי בכלור עלול לקצר את אורך חיי הצנרת', // t_de8170ef
      ],
    ),
  ],
);

// ─── צ'יפי-התכונות (:3357-3406 ⇒ AttributeChip; הסדר = סדר-הצ'יפים במקור) ────
const attributeChipLabels = (
  type: 'סוג', // t_f45000d5
  subtype: 'תת-סוג', // t_ccb77538
  size: 'גודל', // t_a4617429 · הערך עטוף LTR-embed (‪…‬) בקופסה
  color: 'צבע', // t_be49d01c
  model: 'דגם', // t_8cd6a827
  length: 'אורך', // t_4f70dfd4 · גם מפתח-dims (:3399)
);

// ─── דאטה-לוגיקה של מועמדי-המחצבה (לא מונחי-UI — שייך לאטומי-הלוגיקה) ───────
// _material (:237): הסקת-חומר משם/קטגוריה — מחרוזות-הזיהוי:
const materialInferKeys = (
  copper: 'נחושת', // t_7ca35c44 ⇒ 'copper'
  multiLayer: 'רב שכבתי', // t_fd53053d ⇒ 'pp' (יחד עם PP)
  // HDPE / PP / NTM / PEX — לטיניות, מזוהות כלשונן; ברירת-מחדל 'pvc'.
);
// _colorModifiers + קידומות-מסנן-הסוג (:3140, :3219 — _resolveCompoundType):
const compoundTypeFilters = (
  colorModifiers: ['מוברש', 'מט'], // t_67066303 · t_73cd2655
  qualifierPrefixes: ['ל', 'ב'], // t_d67cdc0f · t_23c1e0ba · מילה >2 אותיות שנפתחת בהן ≠ תואר
);
