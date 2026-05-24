import 'package:flutter/foundation.dart';

@immutable
class SmartBrand {
  const SmartBrand({
    required this.name,
    required this.price,
    required this.tag,
    this.rec = false,
  });
  final String name;
  final int price;
  final String tag;
  final bool rec;
}

@immutable
class SmartAcc {
  const SmartAcc({
    required this.name,
    required this.emoji,
    required this.price,
    required this.why,
    required this.must,
  });
  final String name;
  final String emoji;
  final int price;
  final String why;
  final bool must;
}

@immutable
class SmartProduct {
  const SmartProduct({
    required this.key,
    required this.name,
    required this.emoji,
    required this.cat,
    required this.brands,
    required this.acc,
  });
  final String key;
  final String name;
  final String emoji;
  final String cat; // matches kCatalogCats title
  final List<SmartBrand> brands;
  final List<SmartAcc> acc;

  int get mustCount => acc.where((a) => a.must).length;
  SmartBrand get recBrand => brands.firstWhere((b) => b.rec, orElse: () => brands.first);
}

const List<SmartProduct> kSmartProducts = [
  // ===== ברזים וכיורים =====
  SmartProduct(
    key: 'faucet',
    name: 'ברז לכיור',
    emoji: '🚰',
    cat: 'ברזים וכיורים',
    brands: [
      SmartBrand(name: 'מותג סטנדרט', price: 189, tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'מותג כלכלי', price: 139, tag: 'הכי משתלם'),
      SmartBrand(name: 'מותג פרימיום', price: 329, tag: 'איכות גבוהה'),
    ],
    acc: [
      SmartAcc(name: 'צינורות חיבור גמישים', emoji: '🌀', price: 28, why: 'מחבר את הברז למים', must: true),
      SmartAcc(name: 'ברזי ניל זוויתיים', emoji: '🔧', price: 22, why: 'לסגור מים בעת תיקון', must: true),
      SmartAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4, why: 'אוטם את ההברגה', must: true),
      SmartAcc(name: 'אטם גומי לברז', emoji: '⚫', price: 3, why: 'מונע נזילה בחיבור', must: true),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'אם הברז יושב על המשטח', must: false),
      SmartAcc(name: 'מפתח צינורות', emoji: '🔩', price: 39, why: 'רק אם אין לך בערכה', must: false),
      SmartAcc(name: 'פקק ניקוז עם שרשרת', emoji: '⚪', price: 18, why: 'אם הכיור בלי פקק מובנה', must: false),
    ],
  ),
  SmartProduct(
    key: 'kitchenFaucet',
    name: 'ברז למטבח',
    emoji: '🚰',
    cat: 'ברזים וכיורים',
    brands: [
      SmartBrand(name: 'מותג סטנדרט', price: 289, tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'מותג כלכלי', price: 199, tag: 'הכי משתלם'),
      SmartBrand(name: 'מותג פרימיום — שליפה', price: 540, tag: 'ראש נשלף'),
    ],
    acc: [
      SmartAcc(name: 'צינורות חיבור גמישים', emoji: '🌀', price: 32, why: 'מחבר את הברז למים', must: true),
      SmartAcc(name: 'ברזי ניל זוויתיים', emoji: '🔧', price: 22, why: 'לסגור מים בעת תיקון', must: true),
      SmartAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4, why: 'אוטם את ההברגה', must: true),
      SmartAcc(name: 'מסנן מים לברז', emoji: '💧', price: 95, why: 'אם רוצים סינון מי שתייה', must: false),
      SmartAcc(name: 'מפתח צינורות', emoji: '🔩', price: 39, why: 'רק אם אין לך בערכה', must: false),
    ],
  ),
  SmartProduct(
    key: 'basin',
    name: 'כיור אמבטיה',
    emoji: '🪣',
    cat: 'ברזים וכיורים',
    brands: [
      SmartBrand(name: 'כיור מונח סטנדרט', price: 340, tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'כיור כלכלי', price: 230, tag: 'הכי משתלם'),
      SmartBrand(name: 'כיור שיש פרימיום', price: 790, tag: 'איכות גבוהה'),
    ],
    acc: [
      SmartAcc(name: 'סיפון לכיור', emoji: '🌀', price: 46, why: 'ניקוז הכיור — חובה', must: true),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'אוטם בין הכיור לקיר', must: true),
      SmartAcc(name: 'ברגי תלייה לכיור', emoji: '🔩', price: 14, why: 'אם הכיור תלוי על הקיר', must: false),
      SmartAcc(name: 'רגל תמיכה לכיור', emoji: '🦵', price: 120, why: 'אם הכיור עם רגל', must: false),
    ],
  ),
  // ===== אסלות =====
  SmartProduct(
    key: 'toilet',
    name: 'אסלה תלויה',
    emoji: '🚽',
    cat: 'אסלות',
    brands: [
      SmartBrand(name: 'מותג סטנדרט', price: 740, tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'מותג כלכלי', price: 560, tag: 'הכי משתלם'),
      SmartBrand(name: 'מותג פרימיום — Soft Close', price: 1240, tag: 'איכות גבוהה'),
    ],
    acc: [
      SmartAcc(name: 'מיכל הדחה סמוי', emoji: '⬜', price: 430, why: 'הבסיס למערכת — חובה', must: true),
      SmartAcc(name: 'אטם לאסלה', emoji: '⚫', price: 18, why: 'מונע ריחות ונזילות', must: true),
      SmartAcc(name: 'ברגי קיבוע', emoji: '🔩', price: 9, why: 'מחזיק את האסלה', must: true),
      SmartAcc(name: 'לחצן הדחה', emoji: '⏹️', price: 65, why: 'הכפתור של ההדחה', must: true),
      SmartAcc(name: 'מושב אסלה', emoji: '⭕', price: 89, why: 'אם לא מגיע עם האסלה', must: false),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום בסיס האסלה לרצפה', must: false),
    ],
  ),
  SmartProduct(
    key: 'toiletFloor',
    name: 'אסלה רגילה (עומדת)',
    emoji: '🚽',
    cat: 'אסלות',
    brands: [
      SmartBrand(name: 'מותג סטנדרט', price: 520, tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'מותג כלכלי', price: 390, tag: 'הכי משתלם'),
      SmartBrand(name: 'מותג פרימיום', price: 880, tag: 'איכות גבוהה'),
    ],
    acc: [
      SmartAcc(name: 'מיכל הדחה', emoji: '⬜', price: 180, why: 'מיכל עליון — חובה', must: true),
      SmartAcc(name: 'אטם שעווה לאסלה', emoji: '⚫', price: 22, why: 'איטום מול קו הביוב', must: true),
      SmartAcc(name: 'ברגי רצפה', emoji: '🔩', price: 12, why: 'מקבע את האסלה לרצפה', must: true),
      SmartAcc(name: 'מושב אסלה', emoji: '⭕', price: 75, why: 'אם לא מגיע עם האסלה', must: false),
      SmartAcc(name: 'צינור חיבור למיכל', emoji: '🌀', price: 24, why: 'אם לא כלול בערכה', must: false),
    ],
  ),
  // ===== מקלחות ואמבטיות =====
  SmartProduct(
    key: 'shower',
    name: 'סוללת מקלחת',
    emoji: '🚿',
    cat: 'מקלחות ואמבטיות',
    brands: [
      SmartBrand(name: 'מותג סטנדרט', price: 520, tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'מותג כלכלי', price: 380, tag: 'הכי משתלם'),
      SmartBrand(name: 'מותג פרימיום — תרמוסטטי', price: 890, tag: 'איכות גבוהה'),
    ],
    acc: [
      SmartAcc(name: 'גוף סמוי לסוללה', emoji: '⬛', price: 240, why: 'נכנס לקיר — חובה', must: true),
      SmartAcc(name: 'ראש מקלחת + זרוע', emoji: '🌧️', price: 155, why: 'החלק שרואים', must: true),
      SmartAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4, why: 'אוטם את ההברגות', must: true),
      SmartAcc(name: 'צינור גמיש + מתקן', emoji: '🌀', price: 32, why: 'אם רוצים גם ראש נייד', must: false),
      SmartAcc(name: 'מדף פינתי למקלחת', emoji: '📐', price: 48, why: 'נחמד אבל לא חובה', must: false),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום מול הקרמיקה', must: false),
    ],
  ),
  SmartProduct(
    key: 'bathtub',
    name: 'אמבטיה',
    emoji: '🛁',
    cat: 'מקלחות ואמבטיות',
    brands: [
      SmartBrand(name: 'אמבטיה אקרילית', price: 890, tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'אמבטיה כלכלית', price: 620, tag: 'הכי משתלם'),
      SmartBrand(name: 'אמבטיה יצוקה פרימיום', price: 1850, tag: 'איכות גבוהה'),
    ],
    acc: [
      SmartAcc(name: 'סוללת מילוי לאמבטיה', emoji: '🚰', price: 320, why: 'הברז של האמבטיה', must: true),
      SmartAcc(name: 'סיפון לאמבטיה', emoji: '🌀', price: 78, why: 'ניקוז — חובה', must: true),
      SmartAcc(name: 'רגליות תמיכה', emoji: '🦵', price: 90, why: 'מייצב את האמבטיה', must: true),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום מול הקיר', must: true),
      SmartAcc(name: 'פאנל חזית לאמבטיה', emoji: '⬜', price: 240, why: 'אם האמבטיה חשופה', must: false),
    ],
  ),
  // ===== חימום מים =====
  SmartProduct(
    key: 'boilerElectric',
    name: 'דוד חשמל',
    emoji: '♨️',
    cat: 'חימום מים',
    brands: [
      SmartBrand(name: 'מותג סטנדרט', price: 780, tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'מותג כלכלי', price: 560, tag: 'הכי משתלם'),
      SmartBrand(name: 'מותג פרימיום — חסכוני', price: 1340, tag: 'בידוד מוגבר'),
    ],
    acc: [
      SmartAcc(name: 'גוף חימום', emoji: '🔥', price: 120, why: 'מחמם את המים — חובה', must: true),
      SmartAcc(name: 'תרמוסטט', emoji: '🌡️', price: 85, why: 'שולט בטמפרטורה', must: true),
      SmartAcc(name: 'שסתום ביטחון', emoji: '⚙️', price: 48, why: 'בטיחות מפני לחץ — חובה', must: true),
      SmartAcc(name: 'צינורות חיבור גמישים', emoji: '🌀', price: 36, why: 'חיבור הדוד לקווי המים', must: true),
      SmartAcc(name: 'מתקן תלייה לקיר', emoji: '🔩', price: 64, why: 'אם הדוד תלוי על הקיר', must: false),
      SmartAcc(name: 'אנוד מגנזיום', emoji: '🔋', price: 42, why: 'מאריך את חיי הדוד', must: false),
    ],
  ),
  SmartProduct(
    key: 'boilerSolar',
    name: 'מערכת דוד שמש',
    emoji: '☀️',
    cat: 'חימום מים',
    brands: [
      SmartBrand(name: 'מערכת סטנדרט 150 ליטר', price: 2400, tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'מערכת כלכלית', price: 1850, tag: 'הכי משתלם'),
      SmartBrand(name: 'מערכת פרימיום 200 ליטר', price: 3650, tag: 'למשפחה גדולה'),
    ],
    acc: [
      SmartAcc(name: 'קולטים סולאריים', emoji: '🟦', price: 680, why: 'אוספים את חום השמש — חובה', must: true),
      SmartAcc(name: 'גוף חימום גיבוי (חשמל)', emoji: '🔥', price: 140, why: 'לימים מעוננים', must: true),
      SmartAcc(name: 'שסתום ביטחון', emoji: '⚙️', price: 48, why: 'בטיחות — חובה', must: true),
      SmartAcc(name: 'צנרת מבודדת לגג', emoji: '🌀', price: 220, why: 'מחברת קולטים לדוד', must: true),
      SmartAcc(name: 'מתקן עיגון לגג', emoji: '🔩', price: 180, why: 'מקבע את המערכת לגג', must: false),
    ],
  ),
  // ===== מטבח =====
  SmartProduct(
    key: 'kitchenSink',
    name: 'כיור מטבח',
    emoji: '🍽️',
    cat: 'מטבח',
    brands: [
      SmartBrand(name: 'נירוסטה — סטנדרט', price: 420, tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'נירוסטה — כלכלי', price: 290, tag: 'הכי משתלם'),
      SmartBrand(name: 'גרניט — פרימיום', price: 980, tag: 'איכות גבוהה'),
    ],
    acc: [
      SmartAcc(name: 'סיפון כפול למטבח', emoji: '🌀', price: 68, why: 'ניקוז הכיור — חובה', must: true),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'אוטם בין הכיור למשטח', must: true),
      SmartAcc(name: 'מסנן שאריות מזון', emoji: '⚪', price: 24, why: 'מונע סתימות', must: false),
      SmartAcc(name: 'מתקן סבון מובנה', emoji: '🧼', price: 55, why: 'תוספת נוחות', must: false),
    ],
  ),
  SmartProduct(
    key: 'dishwasher',
    name: 'נקודת מים למדיח',
    emoji: '💧',
    cat: 'מטבח',
    brands: [
      SmartBrand(name: 'ערכת חיבור סטנדרט', price: 140, tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'ערכת חיבור כלכלית', price: 95, tag: 'הכי משתלם'),
    ],
    acc: [
      SmartAcc(name: 'ברז זוויתי למדיח', emoji: '🔧', price: 32, why: 'נקודת ניתוק המים — חובה', must: true),
      SmartAcc(name: 'צינור מילוי', emoji: '🌀', price: 28, why: 'הזנת מים למדיח', must: true),
      SmartAcc(name: 'צינור ניקוז', emoji: '🌀', price: 24, why: 'פינוי מים מהמדיח', must: true),
      SmartAcc(name: 'שסתום אל-חזור', emoji: '⚙️', price: 18, why: 'מונע חזרת מים מלוכלכים', must: false),
    ],
  ),
  SmartProduct(
    key: 'washingPoint',
    name: 'נקודת מכונת כביסה',
    emoji: '🧺',
    cat: 'מטבח',
    brands: [
      SmartBrand(name: 'ערכת חיבור סטנדרט', price: 130, tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'ערכת חיבור כלכלית', price: 88, tag: 'הכי משתלם'),
    ],
    acc: [
      SmartAcc(name: 'ברז למכונת כביסה 3/4"', emoji: '🔧', price: 38, why: 'נקודת ניתוק — חובה', must: true),
      SmartAcc(name: 'צינור ניקוז עם וו', emoji: '🌀', price: 24, why: 'פינוי המים מהמכונה', must: true),
      SmartAcc(name: 'שסתום אל-חזור', emoji: '⚙️', price: 18, why: 'מונע ריחות וחזרת מים', must: false),
      SmartAcc(name: 'מגש הצפה', emoji: '🟦', price: 46, why: 'הגנה מנזילות — מומלץ', must: false),
    ],
  ),
  // ===== ניקוז וצנרת =====
  SmartProduct(
    key: 'floorDrain',
    name: 'מחסום רצפה',
    emoji: '🕳️',
    cat: 'ניקוז וצנרת',
    brands: [
      SmartBrand(name: 'מחסום סטנדרט', price: 54, tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'מחסום כלכלי', price: 34, tag: 'הכי משתלם'),
      SmartBrand(name: 'מחסום נירוסטה — פרימיום', price: 165, tag: 'עיצובי ועמיד'),
    ],
    acc: [
      SmartAcc(name: 'רשת ניקוז', emoji: '⚙️', price: 22, why: 'מכסה המחסום — חובה', must: true),
      SmartAcc(name: 'אטם גומי', emoji: '⚫', price: 8, why: 'מונע ריחות וחדירת מים', must: true),
      SmartAcc(name: 'צינור ניקוז 50 מ"מ', emoji: '🌀', price: 32, why: 'מחבר לקו הביוב', must: true),
      SmartAcc(name: 'מלכודת ריח (סיפון)', emoji: '🌀', price: 38, why: 'חוסם ריחות ביוב — מומלץ', must: false),
    ],
  ),
  SmartProduct(
    key: 'pressureReg',
    name: 'וסת לחץ מים',
    emoji: '⚙️',
    cat: 'ניקוז וצנרת',
    brands: [
      SmartBrand(name: 'וסת סטנדרט', price: 185, tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'וסת כלכלי', price: 120, tag: 'הכי משתלם'),
      SmartBrand(name: 'וסת פרימיום עם מד', price: 320, tag: 'עם שעון לחץ'),
    ],
    acc: [
      SmartAcc(name: 'מד לחץ', emoji: '🌡️', price: 48, why: 'מציג את לחץ המים', must: true),
      SmartAcc(name: 'מסנן מים', emoji: '💧', price: 65, why: 'מגן על הווסת מלכלוך', must: true),
      SmartAcc(name: 'ברזי ניתוק', emoji: '🔧', price: 44, why: 'לתחזוקה עתידית — מומלץ', must: false),
    ],
  ),
  // ===== גופי תברואה =====
  SmartProduct(
    key: 'showerCabin',
    name: 'מקלחון (פינת מקלחת)',
    emoji: '🛗',
    cat: 'גופי תברואה',
    brands: [
      SmartBrand(name: 'מקלחון זכוכית — סטנדרט', price: 980, tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'מקלחון כלכלי', price: 640, tag: 'הכי משתלם'),
      SmartBrand(name: 'מקלחון ללא מסגרת — פרימיום', price: 1980, tag: 'עיצוב נקי'),
    ],
    acc: [
      SmartAcc(name: 'פרופילי עיגון לקיר', emoji: '➖', price: 120, why: 'מקבעים את המקלחון — חובה', must: true),
      SmartAcc(name: 'אגנית מקלחת', emoji: '⬜', price: 340, why: 'בסיס המקלחון', must: true),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום מול הקיר והרצפה', must: true),
      SmartAcc(name: 'ידית + ציר לדלת', emoji: '🔘', price: 85, why: 'אם הדלת לא מגיעה מורכבת', must: false),
    ],
  ),
  SmartProduct(
    key: 'bidet',
    name: 'בידה',
    emoji: '🚾',
    cat: 'גופי תברואה',
    brands: [
      SmartBrand(name: 'בידה תלויה — סטנדרט', price: 560, tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'בידה כלכלית', price: 390, tag: 'הכי משתלם'),
      SmartBrand(name: 'בידה פרימיום', price: 1120, tag: 'איכות גבוהה'),
    ],
    acc: [
      SmartAcc(name: 'סוללת בידה', emoji: '🚰', price: 240, why: 'הברז של הבידה — חובה', must: true),
      SmartAcc(name: 'סיפון לבידה', emoji: '🌀', price: 46, why: 'ניקוז — חובה', must: true),
      SmartAcc(name: 'ברגי קיבוע', emoji: '🔩', price: 14, why: 'מעגנים את הבידה', must: true),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום מול הקיר', must: false),
    ],
  ),
  // ===== בנייה ומחיצות =====
  SmartProduct(
    key: 'wall',
    name: 'קיר גבס',
    emoji: '🧱',
    cat: 'בנייה ומחיצות',
    brands: [
      SmartBrand(name: 'גבס סטנדרט', price: 240, tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'גבס כלכלי', price: 185, tag: 'הכי משתלם'),
      SmartBrand(name: 'גבס עמיד-לחות', price: 340, tag: 'מומלץ לחדר רטוב'),
    ],
    acc: [
      SmartAcc(name: 'פרופילים + מסילות', emoji: '⬜', price: 120, why: 'השלד של הקיר', must: true),
      SmartAcc(name: 'לוחות גבס', emoji: '🟩', price: 220, why: 'החיפוי של הקיר', must: true),
      SmartAcc(name: 'ברגי גבס', emoji: '🔩', price: 40, why: 'מחבר הכל', must: true),
      SmartAcc(name: 'דיבלים לרצפה', emoji: '⚪', price: 18, why: 'עיגון המסילות', must: true),
      SmartAcc(name: 'צמר סלעים לבידוד', emoji: '🧵', price: 95, why: 'אם רוצים בידוד אקוסטי', must: false),
      SmartAcc(name: 'סרט בד לפינות', emoji: '🧵', price: 24, why: 'חיזוק חיבורי לוחות', must: false),
    ],
  ),
  SmartProduct(
    key: 'door',
    name: 'דלת לשירותים',
    emoji: '🚪',
    cat: 'בנייה ומחיצות',
    brands: [
      SmartBrand(name: 'דלת סטנדרט', price: 480, tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'דלת כלכלית', price: 340, tag: 'הכי משתלם'),
      SmartBrand(name: 'דלת עמידת-לחות', price: 720, tag: 'מומלץ לחדר רטוב'),
    ],
    acc: [
      SmartAcc(name: 'משקוף', emoji: '🟫', price: 160, why: 'המסגרת של הדלת — חובה', must: true),
      SmartAcc(name: 'ידית + צילינדר', emoji: '🔘', price: 85, why: 'הידית והנעילה', must: true),
      SmartAcc(name: 'צירים', emoji: '⚙️', price: 32, why: 'מחבר את הדלת למשקוף', must: true),
      SmartAcc(name: 'אטם לדלת', emoji: '🎗️', price: 24, why: 'מקטין רעש וטיוטות', must: false),
    ],
  ),
  // ===== גמר =====
  SmartProduct(
    key: 'floor',
    name: 'ריצוף וחיפוי',
    emoji: '🟫',
    cat: 'גמר',
    brands: [
      SmartBrand(name: 'קרמיקה סטנדרט', price: 680, tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'קרמיקה כלכלית', price: 480, tag: 'הכי משתלם'),
      SmartBrand(name: 'פורצלן פרימיום', price: 1200, tag: 'איכות גבוהה'),
    ],
    acc: [
      SmartAcc(name: 'אריחי רצפה', emoji: '⬜', price: 680, why: 'ריצוף הרצפה', must: true),
      SmartAcc(name: 'אריחי חיפוי קיר', emoji: '🟧', price: 570, why: 'חיפוי הקירות', must: true),
      SmartAcc(name: 'דבק אריחים גמיש', emoji: '🪣', price: 420, why: 'מדביק את האריחים', must: true),
      SmartAcc(name: 'רובה אפוקסי', emoji: '🎨', price: 240, why: 'ממלא בין האריחים', must: true),
      SmartAcc(name: 'פלסי ריווח', emoji: '➕', price: 14, why: 'מרווח אחיד בין אריחים', must: true),
      SmartAcc(name: 'פרופיל סיום לאריח', emoji: '➖', price: 48, why: 'גימור פינות וקצוות', must: false),
    ],
  ),
  SmartProduct(
    key: 'seal',
    name: 'איטום הרצפה',
    emoji: '🛡️',
    cat: 'גמר',
    brands: [
      SmartBrand(name: 'מערכת איטום סטנדרט', price: 280, tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'מערכת כלכלית', price: 190, tag: 'הכי משתלם'),
      SmartBrand(name: 'מערכת פרימיום', price: 450, tag: 'בידוד כפול'),
    ],
    acc: [
      SmartAcc(name: 'יריעות איטום', emoji: '⬛', price: 280, why: 'מגן מפני מים — חובה', must: true),
      SmartAcc(name: 'פריימר ביטומני', emoji: '🪣', price: 64, why: 'מכין את הרצפה', must: true),
      SmartAcc(name: 'מחסום רצפה', emoji: '🔘', price: 54, why: 'נקודת הניקוז', must: true),
      SmartAcc(name: 'סרט איטום לפינות', emoji: '🧵', price: 36, why: 'חיזוק נקודות התורפה', must: true),
      SmartAcc(name: 'מדה לשיפועים', emoji: '🪨', price: 120, why: 'אם הרצפה לא משופעת', must: false),
    ],
  ),
];

/// Returns unique categories that have smart products, preserving prototype order.
List<String> get kSmartTreeCats {
  final seen = <String>{};
  final result = <String>[];
  for (final p in kSmartProducts) {
    if (seen.add(p.cat)) result.add(p.cat);
  }
  return result;
}

/// Returns products for a given category.
List<SmartProduct> smartProductsForCat(String cat) =>
    kSmartProducts.where((p) => p.cat == cat).toList();
