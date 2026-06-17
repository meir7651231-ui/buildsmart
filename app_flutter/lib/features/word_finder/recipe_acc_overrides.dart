/// SWARM-MATCHED accessory -> catalog sku overrides for the work-recipe bridge
/// (engine #6). Each entry maps a `SmartAcc.name` (whose `sku` was null and which
/// the keyword scorer could not confidently resolve) to the catalog product the
/// SWARM picked semantically AND a second adversarial agent VERIFIED — rejecting
/// keyword-coincidence matches (e.g. "לחצן הדחה" was NOT bound to "מיכל הדחה").
///
/// Provenance: produced 2026-06-18 by the donned match+verify swarm over the 138
/// unresolved accessory names; 36 were confirmed, 102 were rejected (genuinely
/// not in the catalog — tools/consumables/panels — or too uncertain).
///
/// OWNER-REVIEW: these are MACHINE matches, verified but not human-approved. They
/// are intentionally a SEPARATE, reviewable table (not folded into the catalog
/// data): scan the list, fix or delete any wrong binding, and the change takes
/// effect immediately. Removing the whole map reverts engine #6 to scorer-only.
library;

/// `SmartAcc.name` → the verified catalog `sku`. Consulted by
/// `recipe_kit.resolveAccessory` AFTER an owner-set `acc.sku` (which always
/// wins) and BEFORE the relevance scorer. A name absent here falls through to
/// scoring exactly as before.
const Map<String, String> kAccSkuOverrides = <String, String>{
  'צינורות חיבור גמישים': '61651061',
  'ברזי ניל זוויתיים': '77775263',
  'אטם גומי לברז': '506539',
  'פקק ניקוז עם שרשרת': '61110141',
  'ברגי תלייה לכיור': '77000905',
  'ברגי קיבוע': '77000903',
  'מיכל הדחה': '152785',
  'אטם שעווה לאסלה': '506525',
  'ברגי רצפה': '77000903',
  'סוללת מילוי לאמבטיה': '77701100',
  'שסתום ביטחון': 'HW-PRV-34',
  'סיפון כפול למטבח': '116652',
  'ברז זוויתי למדיח': '77775256',
  'שסתום אל-חזור': 'HW-CHECK-CU-20',
  'ברז למכונת כביסה 3/4"': '77775265',
  'אטם גומי': '506525',
  'מלכודת ריח (סיפון)': '116632',
  'מסנן מים': 'HW-YSTR-32',
  'ברזי ניתוק': 'HW-BALL-15',
  'מחסום רצפה': '196587',
  'אטם דו צדדי': '506510',
  'אטם בין מיכל לאסלה': '506525',
  'אטם לחיבור מים': '506521',
  'ברגי קיבוע למושב': '77777041',
  'מצמד חיתוכי לרב-שכבתי': '198517',
  'צינור גמיש למדיח': '645975',
  'צינור גמיש 1/2"': '77121240',
  'זרוע למקלחת': '77701189',
  'אטם דו צדדי 1/2"': '506510',
  'ברז ניל 1/2"': '77775263',
  'מזלף יד': '77701198',
  'ראש מקלחת': '77701166',
  'ברגי קיבוע לאסלה': '77000903',
  'צינור PEX': 'HW-PEX-20',
  'חבק תליה 4"': '77006038',
  'ברז ניל כפול': '77775255',
};
