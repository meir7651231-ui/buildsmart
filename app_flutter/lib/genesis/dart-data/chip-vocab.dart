// 🗄️ דאטה · מילון-הצ'יפים (chip vocabulary) — 12 קבוצות סיווג לפירוק שם-מוצר עברי.
// **זו דאטה, לא מנוע.** מוזרקת ל-parseChips ע"י קופסת-bs-pipe כ-12 שקעי-required.
// מקור-ערכים: buildsmart/app_flutter/lib/data/chip_hierarchy.dart:7-148,317-399 (verbatim).
// שינוי-מילון = עריכת-שורה כאן. אפס-נגיעה בלוגיקת-הפירוק (parse_chips.dart).
// הכרעת-בעלים "אפס-דאטה במנוע": כל קבוצת-מילים = רשימה/מילון ⇒ יוצאת מהאטום.

const Set<String> kChipTypes = {
  'ברך', 'מסעף', 'מצמד', 'מתאם', 'רוכב', 'ברז', 'צווארון', 'אוגן', 'פקק',
  'אומגה', 'שרוול', 'צינור', 'מחבר', 'סעפת', 'לוחית',
  // tool nouns — keep as standalone type
  'מזוודת', 'פלטת', 'מכונת', 'מברגה', 'תותב', 'מקדח',
  // Huliot SmartLock — drainage system types
  'סיפון', 'מחסום', 'מאסף', 'אום', 'אטם', 'משפך', 'אביק', 'רוזטה', 'מבוא',
  'מכלול', 'מצרה', 'חותך', 'מערכת', 'מצחיה', 'ונטיל', 'מפתח', 'חיבור',
  'מאריך', 'הגבהה', 'מכסה', 'רשת', 'סט', 'פס',
  // Lipski — additional drainage / shower system types (gate 117 follow-up)
  'קולט', 'זרוע', 'פיה', 'כובע',
};

/// Compound types — checked BEFORE the single-token kChipTypes lookup so that
/// `מיכל הדחה` becomes one type chip instead of `מיכל` (type) + `הדחה` (leftover).
/// Lipski uses these for cisterns and seats. Polyroll/Huliot have none.
const Set<String> kChipCompoundTypes = {
  'מיכל הדחה',
  'מושב אסלה',
};

const Set<String> kChipLevel1Connection = {
  'לריתוך', 'ריתוך', 'הברגה',
  'ריתוך/הברגה', 'ריתוך/רקורד',
  // EF compound: when we see 'חשמלי' adjacent we promote to "ריתוך חשמלי"
  'חשמלי', 'אלקטרופיוזן',
};

const Set<String> kChipLevel2Shape = {
  // Angles carry the degree symbol in this catalog (45° / 90°). The bare
  // '45'/'90' are intentionally NOT here — those would collide with the
  // diameters 45mm/90mm and steal them from the size slot.
  '45°', '90°',
  // Huliot SmartLock — drainage angles. 15°/30° = single-side elbows; 87.5°
  // = telescopic elbow per the SmartLock catalog (pages 12, 15).
  '15°', '30°', '87.5°',
  // Lipski insertion bends — 87° is a distinct angle from Huliot's 87.5°.
  '87°',
  'מצרה', 'שווה', 'סמוי', 'פרפר', 'כדורי',
  'מעבר', 'ישר', 'אלכסוני',
  'בין', 'אוגנים', // compound "בין אוגנים"
  'עגול', 'משושה', 'רקורד',
  'פייזר', 'אספקת', 'מים', // pipe sub-types: "אספקת מים", "פייזר"
  'מיזוג', 'אוויר',
  // Huliot SmartLock shape qualifiers
  'חלק', 'טלסקופית', 'גלילית', 'כפול', 'נפילה', 'קומקום',
  'זווית', 'ריבועי', 'מוגבה', 'קבוע', 'זמני', 'אמריקאי',
  'אוניברסלית',
};

const Set<String> kChipLevel3Feature = {
  'משטח', 'ריסון', // "משטח ריסון"
  'לנקודת', 'נקודת', 'למיקום',
  'ללא', 'ידית',
  'עם', 'מניעת', 'זרימה', 'חוזרת',
  'כולל', 'אטם',
  'ציפוי', 'כרום',
  'מתוברג', 'מפורק', 'מפלסטיק', 'פוליפרופילן',
  'קטנה', 'גדולה', 'קלה', 'שולחני',
  'לעבודה', 'בגובה', '(לעבודה', 'בגובה)',
  'לתיקון', 'חורים', 'לצינורות', 'לרוכבים', 'רוכב',
  'למונים', 'פיגורות', 'לקטרים',
  // ('מ"מ' moved to _kChipUnits — folded into the size chip, not a level-3 word)
  'סופי', 'גשר',
  'הולירומה', // sub-brand qualifier
  'מצופה', 'פלדה', // for "אוגן פלדה מצופה PP"
  'PP',
  // ─── Huliot SmartLock features (qualifiers, suffixes, contexts) ─────────
  // open/closed access
  'סגור', 'פתוח',
  // accessory targets ("ל…")
  'לג\'וקר', 'למחסום/מאסף', 'למאסף', 'למחסום', 'לכיור', 'לאמבט', 'למזגן',
  'למדיח', 'למכונת', 'לסיפון', 'לאגנית', 'לאביק', 'לברז', 'לסילוק',
  // installation contexts
  'מטבח', 'רחצה', 'כביסה', 'מדיח', 'כלים', 'מקלחת', 'אמבט',
  // joiner words / connectors
  'אורך', 'ארוך', 'קצר', 'קומפלט', 'משלימים', 'מדידה', 'יציאה', 'כניסה',
  'חיבור', 'אקוסטית',
  // catalog suffixes — model/series numbers + parens
  'מספר', 'דגם', 'מערכת',
  'AQUA', 'SLIM', 'SmartLock', 'Aqua', 'Slim',  // brand series identifiers
  'מתאם', 'ניקוז',  'הורקה', 'תקע', 'ראש',
  'ABS', 'TPE', 'SBR', 'PP+ABS',
  // parens (size variants from catalog headers like (6) (1) (3) (4) (5))
  '(1)', '(2)', '(3)', '(4)', '(5)', '(6)', '(8)', '(10)',
  '(70)', '(17)', '(שרשרת+10)', '(ללא',
  // colors / decorative
  'ירוק', 'שחור', 'אפור', 'בז\'', 'לבן', 'כחול', 'נירוסטה', 'ניירוסטה',
  'נילון', '66',
  'ניקל', 'פסים', 'ריבועים', 'מלא/אריח', 'משפך)',
  'אינטגרלי', '+',
  // shape feminine forms / Huliot stragglers
  'רבועה', 'כיור', 'זחיח', 'למבוא', 'קומפלקט',
  // Type words that already-took-the-leading-type may appear again as features
  // ('סט חיבור למדיח / מכונת כביסה' — type='סט', then 'מכונת' is a feature).
  'מכונת', 'מצרה', 'סיפון', 'מחסום', 'מבוא', 'משפך',
  // joiner/list words
  'שרשרת', 'פקקים', 'ושבלונה', 'לאום',
  '1¼', '1½', '½"',  // size variants seen as feature tokens
  'J', 'H', 'Top', 'Floor',
  // joker/SmartLock specific
  'ג\'וקר',
  // 2002 = bathtub drain model number
  '2002',
  // catalog row helpers (size pair label)
  'דלוחין',
  // ─── parser-aid vocab for Huliot ───────────────────────────────────────
  'צינורות', 'קוטר',  // 'חותך צינורות קוטר 40' (אורך already above)
  'מעביר', 'SL',  // 'אטם מעביר SL 40/32'
  'מברזל', 'למעבר',  // 'אום מעבר מברזל'
  'פתח', 'רבוע', 'לאריח',  // 'הגבהה פתח רבוע'
  'מוגבהת', 'עגולה',  // 'רשת מוגבהת עגולה'
  'אחד', '(צד', 'חלק)',  // '(צד אחד חלק)' tokenization with parens
  // SmartLock-specific contexts
  'נחושת',
  // ─── Lipski — toilet-tank/seat model names (gate 117 follow-up) ─────────
  'ספיר', 'ברקת', 'טופז', 'יהלום', 'טיטאן', 'כנרת',
  'חרמון', 'אדיר', 'תבור', 'כרמל', 'הגייני',
  // Lipski — tank/seat sub-features
  'מונובלוק', 'משולב', 'טרמו', 'ULTRA',
  // Lipski — bottle-trap qualifier
  'תיקני', 'בודד', 'פרגמון',
  // Lipski — trailing token after stripped parens "(מס. N)"
  'מס.',
  // Lipski — shower context (parallel to existing 'למזגן'/'למדיח'/etc.)
  'למקלחת',
};

const Set<String> kChipLevel4Thread = {
  'פ.פ', 'פ.ח', 'ח.ח', 'ח.פ',
  'פנימי', 'חיצוני', 'תבריג',
  'שקע', 'תקע',
  'פנים', 'חוץ', // alternates
};

// Material tokens — shown as image badge, not in chip path.
const Set<String> kChipMaterial = {'PPR', 'PPRCT', 'PP-RCT'};

// Unit tokens — folded INTO the size chip rather than dropped or shown as a
// standalone chip, so the size reads "20-63 מ"מ" and the full catalog name is
// recoverable from the chips alone (E2E §21.B).
const Set<String> kChipUnits = {'מ"מ', 'מ”מ', 'mm'};


const Set<String> kChipL1Compounds = {
  'ריתוך חשמלי', 'לריתוך חשמלי',
  'לריתוך הברגה',
};
const Set<String> kChipL2Compounds = {
  'בין אוגנים', 'מעבר ישר', 'מיזוג אוויר', 'אספקת מים',
};
const Set<String> kChipL3Compounds = {
  'משטח ריסון', 'עם משטח ריסון',
  'ללא ידית', 'לנקודת מים',
  // "לוחית למיקום נקודת מים" — keep the whole positioning phrase as ONE chip
  // so it reads in order; otherwise מים→L2, למיקום/נקודת→L3 and the breadcrumb
  // scrambles to "מים ‹ למיקום ‹ נקודת".
  'למיקום נקודת מים',
  'עם מניעת זרימה חוזרת', 'עם מניעת זרימה', 'מניעת זרימה',
  'ציפוי כרום', 'כולל אטם', 'מפלסטיק פוליפרופילן',
  'לעבודה בגובה', 'לתיקון חורים',
  'פלדה מצופה PP', 'פלדה מצופה',
  'מכונת פיגורות', 'פיגורות שולחני', 'פיגורות קלה',
  'לקטרים', 'מקדח לרוכבים', 'תותב ריתוך',
  'לריתוך רוכב', 'עם רקורד',
  '(לעבודה בגובה)',
  // §22.E finish parentheticals (verbatim from catalog page headers — dashes
  // are stripped by tokenizer so compound match expects tokens WITHOUT '-').
  '(ציפוי כרום)',
  '(ציפוי כרום ללא ידית)',
  '(ציפוי כרום כולל ידית)',
  // ─── Huliot SmartLock compounds (multi-word qualifiers from catalog) ───
  'צד אחד חלק', 'צד אחד שקע תקע',
  'AQUA SLIM', 'Aqua Slim',
  'מערכת ניקוז',
  'לכיור רחצה', 'לכיור מטבח', 'לכיור אמריקאי',
  'למכונת כביסה', 'למדיח כלים', 'למדיח/מ.כביסה',
  'עם כניסה למדיח/מ.כביסה', 'עם כניסה למדיח', 'עם כניסה למזגן',
  'עם 2 מבואים צידיים', 'עם מבוא צידי וכניסה למ.כלים/מ.כביסה',
  'עם יציאה למדיח', 'יציאה למדיח',
  '+ צינור מדידה',
  'מצרה (צד אחד חלק)', 'מצרה (צד אחד חלק) חיבור ברזל ופלסטיק',
  'מתאם זווית - ג\'וקר', 'מתאם זווית',
  'אום מעבר מברזל', 'אום מעבר מברזל למעבר מברזל',
  'מתאם זחיח לכיור אמריקאי', 'מתאם זחיח',
  'מבוא זחיח עם חיבור למזגן', 'מבוא זחיח',
  'מאריך למבוא זחיח', 'ראש שקע תקע', 'ראש שקע תקע + אטם',
  'מאסף קווי AQUA SLIM',
  'סט פקקים לברז ושבלונה', 'סט פקקים לברז',
  'מצחיה קומפלט לאביק לאמבט',
  'מערכת ניקוז לאמבט',
  // ─── Lipski — toilet-seat / gasket / trap compound features (gate 117) ─
  'סגירה רכה', 'אנטי ונדליזם',
  'ציר ניירוסטה', 'ציר פלסטיק',
  'דו צדדי', 'חתך שטוח',
  // "(מס. N)" — kitchen-sink trap variant marker; tokenizer keeps the parens
  // attached so the compound walker sees `(מס.` + `N)` as two tokens.
  '(מס. 1)', '(מס. 2)', '(מס. 3)', '(מס. 4)', '(מס. 5)',
  '(מס. 6)', '(מס. 7)', '(מס. 8)', '(מס. 9)',
  'ונטיל לכיור אמריקאי J', 'ונטיל לכיור אמריקאי',
  'מחסום הורקה למכונת כביסה',
  'סיפון הורקה קומפלקט J', 'סיפון הורקה קומפלקט',
  'מחסום H למכונת כביסה',
  'הגבהה אוניברסלית לאריח עם מכסה אטום מונע ריחות',
  'הגבהה אוניברסלית לאריח', 'מכסה אטום מונע ריחות',
  'אביזרים משלימים',
  'דגם פסים', 'דגם ריבועים', 'דגם מלא/אריח',
  'חיבור ברזל ופלסטיק', 'חיבור קצר לאגנית', 'חיבור ארוך לאגנית',
  'סט חיבור למדיח / מכונת כביסה', 'סט חיבור למדיח',
  'הגבהה פתח רבוע',
  'מצרה לסיפון', 'ברך מצרה לסיפון',
  'פקק לאביק', 'פקק לברז',
  'מבוא לכיור אמריקאי', 'מבוא לכיור',
  'מכלול לסיפון', 'צינור זחיח לסיפון',
  'אטם מעביר SL',
  'גומי אלסטומרי',
  'מפתח לאום תבריג',
  'Top Floor',
  // catalog notes
  '(ללא משפך)', '(שרשרת+10)', '(שחור)',
  'מאסף נפילה',
};
const Set<String> kChipL4Compounds = {
  'שקע תקע', 'שקע-תקע',
  'תבריג פנימי', 'תבריג חיצוני',
  'תבריג פנים', 'תבריג חוץ',
};
