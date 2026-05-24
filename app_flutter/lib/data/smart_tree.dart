import 'package:flutter/foundation.dart';

@immutable
class SmartStage {
  const SmartStage({
    required this.emoji,
    required this.label,
    required this.sub,
    this.isFinal = false,
    this.match = const [],
  });
  final String emoji;
  final String label;
  final String sub;
  final bool isFinal;
  /// Substrings matched against SmartAcc.name to highlight relevant accessories.
  final List<String> match;
}

// Pre-defined stage sequences — verbatim from prototype DIAGRAMS map.

// סיפון לכיור — 3 שלבים
const _strap = [
  SmartStage(emoji: '🔩', label: 'רכיבים',   sub: 'טפלון, מפתח',  match: ['סרט טפלון', 'מפתח צינורות']),
  SmartStage(emoji: '🌀', label: 'הברגה',    sub: 'ידנית + הידוק', match: ['סרט טפלון', 'מפתח צינורות']),
  SmartStage(emoji: '✅', label: 'סיפון מותקן', sub: 'בדיקת ניקוז', match: ['סיליקון סניטרי'], isFinal: true),
];

const _sf = [
  SmartStage(emoji: '🔩', label: 'רכיבים',      sub: 'אטמים, צינורות', match: ['אטם', 'סרט טפלון', 'צינורות חיבור']),
  SmartStage(emoji: '🔀', label: 'הזנת מים',    sub: 'PEX חם/קר',       match: ['צינורות חיבור', 'ברזי ניל']),
  SmartStage(emoji: '🔌', label: 'חיבור גס',    sub: 'ברזי ניל',        match: ['ברזי ניל', 'מפתח צינורות']),
  SmartStage(emoji: '✅', label: 'ברז גמור',    sub: 'מותקן',           match: ['סיליקון', 'פקק ניקוז', 'מסנן', 'סיפון'], isFinal: true),
];
const _st = [
  SmartStage(emoji: '🔩', label: 'רכיבים',       sub: 'אטם, ברגים',   match: ['אטם', 'ברגי']),
  SmartStage(emoji: '⬜', label: 'מיכל סמוי',    sub: 'בתוך הקיר',    match: ['מיכל הדחה', 'לחצן הדחה']),
  SmartStage(emoji: '🛡️', label: 'איטום וחיבור', sub: 'לקו ביוב',    match: ['אטם', 'סיליקון', 'צינור חיבור']),
  SmartStage(emoji: '✅', label: 'אסלה גמורה',   sub: 'מותקנת',       match: ['מושב', 'סיפון', 'ברגי קיבוע'], isFinal: true),
];
const _ss = [
  SmartStage(emoji: '🔩', label: 'רכיבים',      sub: 'טפלון, צינור',  match: ['סרט טפלון', 'צינור גמיש']),
  SmartStage(emoji: '🎛️', label: 'גוף סמוי',   sub: 'בתוך הקיר',     match: ['גוף סמוי', 'פרופילי עיגון', 'אגנית']),
  SmartStage(emoji: '🚿', label: 'זרוע + ראש',  sub: 'החלק הנראה',    match: ['ראש מקלחת', 'צינור גמיש', 'ידית']),
  SmartStage(emoji: '✅', label: 'מקלחת גמורה', sub: 'מותקנת',        match: ['סיליקון', 'מדף פינתי', 'פאנל'], isFinal: true),
];
const _sb = [
  SmartStage(emoji: '🔩', label: 'רכיבים',       sub: 'שסתום, צינורות', match: ['שסתום', 'צינורות חיבור', 'צנרת']),
  SmartStage(emoji: '🔧', label: 'הכנת הקיר',    sub: 'עיגון + חיבורים', match: ['מתקן תלייה', 'מתקן עיגון']),
  SmartStage(emoji: '🔥', label: 'חיבור והפעלה', sub: 'בדיקת לחץ',      match: ['גוף חימום', 'תרמוסטט', 'קולטים']),
  SmartStage(emoji: '✅', label: 'דוד פעיל',     sub: 'מוכן לחימום',    match: ['אנוד', 'שסתום ביטחון'], isFinal: true),
];
const _si = [
  SmartStage(emoji: '🔩', label: 'רכיבים',     sub: 'מחברים',      match: ['ברז זוויתי', 'ברז למכונת', 'ברזי ניתוק']),
  SmartStage(emoji: '🔧', label: 'קווי ביוב',  sub: 'צינור 50',    match: ['צינור ניקוז', 'רשת ניקוז', 'מחסום']),
  SmartStage(emoji: '🔀', label: 'קווי מים',   sub: 'PEX',         match: ['צינור מילוי', 'צנרת', 'מד לחץ', 'מסנן']),
  SmartStage(emoji: '✅', label: 'חיבור גמור', sub: 'בדיקה עברה', match: ['שסתום', 'מגש הצפה', 'אטם'], isFinal: true),
];
const _sw = [
  SmartStage(emoji: '🔩', label: 'חומרים',       sub: 'פריימר',      match: ['פריימר', 'מדה לשיפועים']),
  SmartStage(emoji: '🛡️', label: 'חיזוק פינות', sub: 'סרט איטום',   match: ['סרט איטום', 'רשת ניקוז']),
  SmartStage(emoji: '🧱', label: 'יריעות איטום', sub: 'בחפיפה',      match: ['יריעות', 'מחסום רצפה']),
  SmartStage(emoji: '✅', label: 'רצפה אטומה',   sub: 'עברה בדיקה', match: ['אטם גומי', 'מלכודת', 'צינור ניקוז'], isFinal: true),
];
const _stile = [
  SmartStage(emoji: '🔩', label: 'חומרים',      sub: 'דבק, פלסים',  match: ['דבק אריחים', 'פלסי ריווח']),
  SmartStage(emoji: '🟫', label: 'הנחת אריחים', sub: 'רצפה וקיר',   match: ['אריחי']),
  SmartStage(emoji: '🛡️', label: 'מילוי רובה', sub: 'עמיד מים',    match: ['רובה']),
  SmartStage(emoji: '✅', label: 'גמר מושלם',   sub: 'מוכן לכלים', match: ['פרופיל סיום'], isFinal: true),
];
const _sprof = [
  SmartStage(emoji: '🔩', label: 'רכיבים',          sub: 'ברגים, דיבל', match: ['ברגי גבס', 'דיבלים']),
  SmartStage(emoji: '🧱', label: 'מסילות ופרופיל',  sub: 'שלד הקיר',    match: ['פרופילים', 'משקוף']),
  SmartStage(emoji: '🟦', label: 'לוחות גבס',       sub: 'חיפוי',       match: ['לוחות גבס', 'צמר סלעים']),
  SmartStage(emoji: '✅', label: 'מחיצה גמורה',     sub: 'מוכנה לגמר', match: ['סרט בד', 'ידית', 'אטם לדלת', 'צירים'], isFinal: true),
];

@immutable
class SmartBrand {
  const SmartBrand({
    required this.name,
    required this.tag,
    this.price,
    this.rec = false,
    this.sku,
    this.imageAsset,
  });
  final String name;
  final String tag;
  final int? price;       // null = מחיר לפי ספק
  final bool rec;
  final String? sku;      // מק"ט ספק — מקשר ל-kLipskeyCatalog
  final String? imageAsset;
}

@immutable
class SmartAcc {
  const SmartAcc({
    required this.name,
    required this.emoji,
    required this.why,
    required this.must,
    this.price,
    this.sku,
  });
  final String name;
  final String emoji;
  final int? price;       // null = מחיר לפי ספק
  final String why;
  final bool must;
  final String? sku;      // מק"ט ספק — מקשר ל-kLipskeyCatalog
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
    this.diagramTitle = '',
    this.stages = const [],
  });
  final String key;
  final String name;
  final String emoji;
  final String cat;
  final List<SmartBrand> brands;
  final List<SmartAcc> acc;
  final String diagramTitle;
  final List<SmartStage> stages;

  int get mustCount => acc.where((a) => a.must).length;
  SmartBrand get recBrand => brands.firstWhere((b) => b.rec, orElse: () => brands.first);
}

const List<SmartProduct> kSmartProducts = [
  // ===== ניקוז — סיפונים =====
  SmartProduct(
    key: 'basinTrap',
    name: 'סיפון לכיור רחצה',
    emoji: '🌀',
    cat: 'ניקוז וצנרת',
    diagramTitle: 'התקנת סיפון — מהברגה עד בדיקת ניקוז',
    stages: _strap,
    brands: [
      SmartBrand(
        name: 'סיפון אמריקאי 1¼" לבן',
        tag: 'מחיר לפי ספק',
        rec: true,
        sku: '217861',
        imageAsset: 'assets/lipskey/products/217861.jpeg',
      ),
      SmartBrand(
        name: 'סיפון 1¼" + יציאה למזגן',
        tag: 'עם יציאה למזגן',
        sku: '213055',
        imageAsset: 'assets/lipskey/products/213055.jpeg',
      ),
      SmartBrand(
        name: 'סיפון בקבוק 1¼" כרום',
        tag: 'גרסה חלופית',
        sku: '218553',
        imageAsset: 'assets/lipskey/products/218553.jpeg',
      ),
    ],
    acc: [
      SmartAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4, why: 'אוטם את ההברגה — חובה', must: true),
      SmartAcc(name: 'מפתח צינורות', emoji: '🔧', price: 39, why: 'להידוק הסיפון', must: true),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום בין הסיפון למשטח', must: false),
      SmartAcc(
        name: 'אטם דו צדדי 32/50',
        emoji: '⚫',
        why: 'מונע נזילה בחיבור — חובה',
        must: true,
        sku: '558463',
      ),
    ],
  ),

  // ===== ברזים וכיורים =====
  SmartProduct(
    key: 'faucet',
    name: 'ברז לכיור',
    emoji: '🚰',
    cat: 'ברזים וכיורים',
    diagramTitle: 'תהליך התקנת ברז — מהזנה עד קצה',
    stages: _sf,
    brands: [
      SmartBrand(name: 'מותג סטנדרט', tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'מותג כלכלי', tag: 'הכי משתלם'),
      SmartBrand(name: 'מותג פרימיום', tag: 'איכות גבוהה'),
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
    diagramTitle: 'תהליך התקנת ברז למטבח',
    stages: _sf,
    brands: [
      SmartBrand(name: 'מותג סטנדרט', tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'מותג כלכלי', tag: 'הכי משתלם'),
      SmartBrand(name: 'מותג פרימיום — שליפה', tag: 'ראש נשלף'),
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
    diagramTitle: 'תהליך התקנת כיור אמבטיה',
    stages: _sf,
    brands: [
      SmartBrand(name: 'כיור מונח סטנדרט', tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'כיור כלכלי', tag: 'הכי משתלם'),
      SmartBrand(name: 'כיור שיש פרימיום', tag: 'איכות גבוהה'),
    ],
    acc: [
      SmartAcc(name: 'סיפון לכיור', emoji: '🌀', why: 'ניקוז הכיור — חובה', must: true, sku: '217861'),
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
    diagramTitle: 'תהליך התקנת אסלה תלויה',
    stages: _st,
    brands: [
      SmartBrand(name: 'מותג סטנדרט', tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'מותג כלכלי', tag: 'הכי משתלם'),
      SmartBrand(name: 'מותג פרימיום — Soft Close', tag: 'איכות גבוהה'),
    ],
    acc: [
      SmartAcc(name: 'מיכל הדחה סמוי', emoji: '⬜', price: 430, why: 'הבסיס למערכת — חובה', must: true),
      SmartAcc(name: 'אטם לאסלה', emoji: '⚫', price: 18, why: 'מונע ריחות ונזילות', must: true),
      SmartAcc(name: 'ברגי קיבוע', emoji: '🔩', price: 9, why: 'מחזיק את האסלה', must: true),
      SmartAcc(name: 'לחצן הדחה', emoji: '⏹️', price: 65, why: 'הכפתור של ההדחה', must: true),
      SmartAcc(
        name: 'מושב אסלה תרמופלסטי',
        emoji: '⭕',
        why: 'אם לא מגיע עם האסלה',
        must: false,
        sku: '220943',
      ),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום בסיס האסלה לרצפה', must: false),
    ],
  ),
  SmartProduct(
    key: 'toiletFloor',
    name: 'אסלה רגילה (עומדת)',
    emoji: '🚽',
    cat: 'אסלות',
    diagramTitle: 'תהליך התקנת אסלה עומדת',
    stages: _st,
    brands: [
      SmartBrand(name: 'מותג סטנדרט', tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'מותג כלכלי', tag: 'הכי משתלם'),
      SmartBrand(name: 'מותג פרימיום', tag: 'איכות גבוהה'),
    ],
    acc: [
      SmartAcc(name: 'מיכל הדחה', emoji: '⬜', price: 180, why: 'מיכל עליון — חובה', must: true),
      SmartAcc(name: 'אטם שעווה לאסלה', emoji: '⚫', price: 22, why: 'איטום מול קו הביוב', must: true),
      SmartAcc(name: 'ברגי רצפה', emoji: '🔩', price: 12, why: 'מקבע את האסלה לרצפה', must: true),
      SmartAcc(
        name: 'מושב אסלה תרמופלסטי',
        emoji: '⭕',
        why: 'אם לא מגיע עם האסלה',
        must: false,
        sku: '220943',
      ),
      SmartAcc(name: 'צינור חיבור למיכל', emoji: '🌀', price: 24, why: 'אם לא כלול בערכה', must: false),
    ],
  ),
  // ===== מקלחות ואמבטיות =====
  SmartProduct(
    key: 'shower',
    name: 'סוללת מקלחת',
    emoji: '🚿',
    cat: 'מקלחות ואמבטיות',
    diagramTitle: 'תהליך התקנת סוללת מקלחת',
    stages: _ss,
    brands: [
      SmartBrand(name: 'מותג סטנדרט', tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'מותג כלכלי', tag: 'הכי משתלם'),
      SmartBrand(name: 'מותג פרימיום — תרמוסטטי', tag: 'איכות גבוהה'),
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
    diagramTitle: 'תהליך התקנת אמבטיה',
    stages: _ss,
    brands: [
      SmartBrand(name: 'אמבטיה אקרילית', tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'אמבטיה כלכלית', tag: 'הכי משתלם'),
      SmartBrand(name: 'אמבטיה יצוקה פרימיום', tag: 'איכות גבוהה'),
    ],
    acc: [
      SmartAcc(name: 'סוללת מילוי לאמבטיה', emoji: '🚰', price: 320, why: 'הברז של האמבטיה', must: true),
      SmartAcc(name: 'סיפון לאמבטיה', emoji: '🌀', why: 'ניקוז — חובה', must: true, sku: '116178'),
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
    diagramTitle: 'תהליך התקנת דוד חשמל',
    stages: _sb,
    brands: [
      SmartBrand(name: 'מותג סטנדרט', tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'מותג כלכלי', tag: 'הכי משתלם'),
      SmartBrand(name: 'מותג פרימיום — חסכוני', tag: 'בידוד מוגבר'),
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
    diagramTitle: 'תהליך התקנת דוד שמש',
    stages: _sb,
    brands: [
      SmartBrand(name: 'מערכת סטנדרט 150 ליטר', tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'מערכת כלכלית', tag: 'הכי משתלם'),
      SmartBrand(name: 'מערכת פרימיום 200 ליטר', tag: 'למשפחה גדולה'),
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
    diagramTitle: 'תהליך התקנת כיור מטבח',
    stages: _sf,
    brands: [
      SmartBrand(name: 'נירוסטה — סטנדרט', tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'נירוסטה — כלכלי', tag: 'הכי משתלם'),
      SmartBrand(name: 'גרניט — פרימיום', tag: 'איכות גבוהה'),
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
    diagramTitle: 'תהליך חיבור מדיח כלים',
    stages: _si,
    brands: [
      SmartBrand(name: 'ערכת חיבור סטנדרט', tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'ערכת חיבור כלכלית', tag: 'הכי משתלם'),
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
    diagramTitle: 'תהליך חיבור מכונת כביסה',
    stages: _si,
    brands: [
      SmartBrand(name: 'ערכת חיבור סטנדרט', tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'ערכת חיבור כלכלית', tag: 'הכי משתלם'),
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
    diagramTitle: 'תהליך התקנת מחסום רצפה',
    stages: _sw,
    brands: [
      SmartBrand(
        name: 'מחסום 245/50 פתוח גבוהה',
        tag: 'מחיר לפי ספק',
        rec: true,
        sku: '218681',
        imageAsset: 'assets/lipskey/products/218681.jpeg',
      ),
      SmartBrand(
        name: 'מחסום 245/50 סגור גבוהה',
        tag: 'סגור',
        sku: '218722',
        imageAsset: 'assets/lipskey/products/218722.jpeg',
      ),
      SmartBrand(
        name: 'מחסום 245/50 פתוח',
        tag: 'גובה רגיל',
        sku: '220542',
        imageAsset: 'assets/lipskey/products/220542.jpeg',
      ),
      SmartBrand(
        name: 'מחסום 245/50 סגור',
        tag: 'גובה רגיל סגור',
        sku: '220543',
        imageAsset: 'assets/lipskey/products/220543.jpeg',
      ),
    ],
    acc: [
      SmartAcc(
        name: 'מכסה/רשת למחסום',
        emoji: '⚙️',
        why: 'מכסה המחסום — חובה',
        must: true,
        sku: '610911',
      ),
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
    diagramTitle: 'תהליך התקנת וסת לחץ מים',
    stages: _si,
    brands: [
      SmartBrand(name: 'וסת סטנדרט', tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'וסת כלכלי', tag: 'הכי משתלם'),
      SmartBrand(name: 'וסת פרימיום עם מד', tag: 'עם שעון לחץ'),
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
    diagramTitle: 'תהליך התקנת מקלחון',
    stages: _ss,
    brands: [
      SmartBrand(name: 'מקלחון זכוכית — סטנדרט', tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'מקלחון כלכלי', tag: 'הכי משתלם'),
      SmartBrand(name: 'מקלחון ללא מסגרת — פרימיום', tag: 'עיצוב נקי'),
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
    diagramTitle: 'תהליך התקנת בידה',
    stages: _st,
    brands: [
      SmartBrand(name: 'בידה תלויה — סטנדרט', tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'בידה כלכלית', tag: 'הכי משתלם'),
      SmartBrand(name: 'בידה פרימיום', tag: 'איכות גבוהה'),
    ],
    acc: [
      SmartAcc(name: 'סוללת בידה', emoji: '🚰', price: 240, why: 'הברז של הבידה — חובה', must: true),
      SmartAcc(name: 'סיפון לבידה', emoji: '🌀', why: 'ניקוז — חובה', must: true, sku: '217861'),
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
    diagramTitle: 'תהליך הרכבת מחיצת גבס',
    stages: _sprof,
    brands: [
      SmartBrand(name: 'גבס סטנדרט', tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'גבס כלכלי', tag: 'הכי משתלם'),
      SmartBrand(name: 'גבס עמיד-לחות', tag: 'מומלץ לחדר רטוב'),
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
    diagramTitle: 'תהליך התקנת דלת לשירותים',
    stages: _sprof,
    brands: [
      SmartBrand(name: 'דלת סטנדרט', tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'דלת כלכלית', tag: 'הכי משתלם'),
      SmartBrand(name: 'דלת עמידת-לחות', tag: 'מומלץ לחדר רטוב'),
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
    diagramTitle: 'תהליך הנחת ריצוף וחיפוי',
    stages: _stile,
    brands: [
      SmartBrand(name: 'קרמיקה סטנדרט', tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'קרמיקה כלכלית', tag: 'הכי משתלם'),
      SmartBrand(name: 'פורצלן פרימיום', tag: 'איכות גבוהה'),
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
    diagramTitle: 'תהליך איטום הרצפה',
    stages: _sw,
    brands: [
      SmartBrand(name: 'מערכת איטום סטנדרט', tag: 'הבחירה שלנו', rec: true),
      SmartBrand(name: 'מערכת כלכלית', tag: 'הכי משתלם'),
      SmartBrand(name: 'מערכת פרימיום', tag: 'בידוד כפול'),
    ],
    acc: [
      SmartAcc(name: 'יריעות איטום', emoji: '⬛', price: 280, why: 'מגן מפני מים — חובה', must: true),
      SmartAcc(name: 'פריימר ביטומני', emoji: '🪣', price: 64, why: 'מכין את הרצפה', must: true),
      SmartAcc(name: 'מחסום רצפה', emoji: '🔘', price: 54, why: 'נקודת הניקוז', must: true),
      SmartAcc(name: 'סרט איטום לפינות', emoji: '🧵', price: 36, why: 'חיזוק נקודות התורפה', must: true),
      SmartAcc(name: 'מדה לשיפועים', emoji: '🪨', price: 120, why: 'אם הרצפה לא משופעת', must: false),
    ],
  ),

  // ===== ניקוז — צינורות, ברכיים, מצמדים (Lipskey new categories) =====
  SmartProduct(
    key: 'pvcPipe',
    name: 'צינור ניקוז PVC',
    emoji: '📏',
    cat: 'ניקוז וצנרת',
    diagramTitle: 'הנחת צינור ניקוז — חיתוך, חיבור, איטום',
    stages: _si,
    brands: [
      SmartBrand(
        name: 'צינור DN50 200 ס"מ',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '116074',
      ),
      SmartBrand(
        name: 'צינור DN50 100 ס"מ',
        tag: 'גרסה קצרה',
        sku: '221022',
      ),
      SmartBrand(
        name: 'צינור DN75 200 ס"מ',
        tag: 'גודל בינוני',
        sku: '116001',
      ),
      SmartBrand(
        name: 'צינור DN110 200 ס"מ',
        tag: 'יציאה ראשית',
        sku: '116155',
      ),
    ],
    acc: [
      SmartAcc(
        name: 'מצמד חיתוכי',
        emoji: '🔌',
        why: 'לחיבור בין שני קטעי צינור — חובה',
        must: true,
        sku: '116680',
      ),
      SmartAcc(
        name: 'ברך 87°',
        emoji: '↩️',
        why: 'לשינוי כיוון הצינור',
        must: true,
        sku: '116033',
      ),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום החיבורים', must: true),
      SmartAcc(name: 'משור לצינור PVC', emoji: '🪚', price: 35, why: 'לחיתוך באורך הרצוי', must: false),
      SmartAcc(
        name: 'מחבר כפול DN50',
        emoji: '🔗',
        why: 'חיבור ישיר בין שני צינורות',
        must: false,
        sku: '124533',
      ),
    ],
  ),
  SmartProduct(
    key: 'drainageElbow',
    name: 'ברכיים וזוויות לניקוז',
    emoji: '↩️',
    cat: 'ניקוז וצנרת',
    diagramTitle: 'התקנת ברך — שינוי כיוון',
    stages: _si,
    brands: [
      SmartBrand(
        name: 'ברך 87° DN50',
        tag: 'גודל סטנדרט',
        rec: true,
        sku: '116601',
      ),
      SmartBrand(name: 'ברך 87° DN75',  tag: 'בינוני',           sku: '116033'),
      SmartBrand(name: 'ברך 87° DN110', tag: 'יציאה ראשית',     sku: '142289'),
      SmartBrand(name: 'ברך 87° DN160', tag: 'גדול במיוחד',     sku: '116028'),
      SmartBrand(
        name: 'ברך 87° עם ביקורת DN110',
        tag: 'עם פתח שירות',
        sku: '124843',
      ),
    ],
    acc: [
      SmartAcc(name: 'מצמד חיתוכי', emoji: '🔌', why: 'לחיבור לצינור — חובה', must: true, sku: '116680'),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום החיבור', must: true),
      SmartAcc(name: 'צינור PVC', emoji: '📏', why: 'אם צריך להאריך את הקו', must: false, sku: '116074'),
      SmartAcc(name: 'מפתח צינורות', emoji: '🔩', price: 39, why: 'להידוק', must: false),
    ],
  ),
  SmartProduct(
    key: 'drainageFittings',
    name: 'מחברים ומצמדי שקע',
    emoji: '🔌',
    cat: 'ניקוז וצנרת',
    diagramTitle: 'חיבור צינורות בקטעי מעבר',
    stages: _si,
    brands: [
      SmartBrand(
        name: 'מצמד חיתוכי 50/40',
        tag: 'מעבר מ-50 ל-40',
        rec: true,
        sku: '116680',
      ),
      SmartBrand(name: 'מצמד חיתוכי 40/32', tag: 'מעבר קטן',        sku: '198517'),
      SmartBrand(name: 'מצמד חיתוכי 75/50', tag: 'מעבר בינוני',     sku: '119215'),
      SmartBrand(name: 'מחבר כפול DN50',    tag: 'חיבור ישיר',     sku: '124533'),
      SmartBrand(name: 'מחבר כפול DN75',    tag: 'בינוני',          sku: '196762'),
      SmartBrand(name: 'מחבר כפול DN110',   tag: 'יציאה ראשית',    sku: '196575'),
    ],
    acc: [
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום החיבור — חובה', must: true),
      SmartAcc(name: 'אטם דו צדדי',     emoji: '⚫', price: 12, why: 'מונע נזילות',     must: true),
      SmartAcc(name: 'ברך 87°', emoji: '↩️', why: 'לשינוי כיוון', must: false, sku: '116033'),
      SmartAcc(name: 'צינור PVC', emoji: '📏', why: 'אם צריך להאריך', must: false, sku: '116074'),
    ],
  ),

  // ===== אסלות — מיכלי הדחה (Lipskey new categories) =====
  SmartProduct(
    key: 'toiletTankHigh',
    name: 'מיכל הדחה — התקנה גבוהה',
    emoji: '🔺',
    cat: 'אסלות',
    diagramTitle: 'התקנת מיכל הדחה גבוה',
    stages: _st,
    brands: [
      SmartBrand(
        name: 'טיטאן פרגמון',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '152786',
      ),
      SmartBrand(name: 'טיטאן אפור',   tag: 'גוון אפור',      sku: '152787'),
      SmartBrand(name: 'יהלום לבן',    tag: 'יהלום קלאסי',   sku: '145629'),
      SmartBrand(name: 'יהלום פרגמון', tag: 'גוון פרגמון',  sku: '145630'),
      SmartBrand(name: 'יהלום אפור',   tag: 'גוון אפור',      sku: '145631'),
    ],
    acc: [
      SmartAcc(name: 'צינור הדחה גבוה', emoji: '📏', price: 78, why: 'מחבר מיכל לאסלה — חובה', must: true),
      SmartAcc(
        name: 'מצוף מילוי הידראולי',
        emoji: '🔧',
        why: 'בקרת מילוי המיכל — חובה',
        must: true,
        sku: '686366',
      ),
      SmartAcc(name: 'אטם בין מיכל לצינור', emoji: '⚫', price: 24, why: 'מונע נזילות', must: true),
      SmartAcc(name: 'ברגי קיבוע לקיר', emoji: '🔩', price: 18, why: 'לתליית המיכל בגובה', must: true),
      SmartAcc(name: 'לחצן הדחה', emoji: '⏹️', price: 65, why: 'הכפתור', must: false),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום סופי', must: false),
    ],
  ),
  SmartProduct(
    key: 'toiletTankLow',
    name: 'מיכל הדחה — התקנה נמוכה',
    emoji: '🔻',
    cat: 'אסלות',
    diagramTitle: 'התקנת מיכל הדחה נמוך',
    stages: _st,
    brands: [
      SmartBrand(
        name: 'ספיר פרגמון',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '124050',
      ),
      SmartBrand(name: 'ספיר אפור',     tag: 'גוון אפור',     sku: '124051'),
      SmartBrand(name: 'ברקת לבן',      tag: 'ברקת קלאסי',   sku: '170862'),
      SmartBrand(name: 'ברקת פרגמון',   tag: 'גוון פרגמון',  sku: '170866'),
      SmartBrand(name: 'ברקת אפור',     tag: 'גוון אפור',     sku: '170869'),
      SmartBrand(name: 'טופז לבן',       tag: 'גרסה כלכלית',  sku: '116752'),
    ],
    acc: [
      SmartAcc(
        name: 'מצוף מילוי הידראולי',
        emoji: '🔧',
        why: 'בקרת מילוי — חובה',
        must: true,
        sku: '686366',
      ),
      SmartAcc(name: 'אטם בין מיכל לאסלה', emoji: '⚫', price: 18, why: 'איטום ההדחה', must: true),
      SmartAcc(name: 'ברגי קיבוע',           emoji: '🔩', price: 14, why: 'לקיבוע למקום', must: true),
      SmartAcc(name: 'לחצן הדחה',             emoji: '⏹️', price: 65, why: 'אם המיכל לא כולל', must: false),
      SmartAcc(name: 'סיליקון סניטרי',       emoji: '🧴', price: 21, why: 'איטום סופי', must: false),
    ],
  ),
  SmartProduct(
    key: 'toiletTankMonoblock',
    name: 'מיכל הדחה — מונובלוק (צמוד)',
    emoji: '⬜',
    cat: 'אסלות',
    diagramTitle: 'התקנת מיכל מונובלוק על האסלה',
    stages: _st,
    brands: [
      SmartBrand(
        name: 'כינרת מונובלוק פרגמון',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '169604',
      ),
      SmartBrand(name: 'ברקת מונובלוק לבן',    tag: 'ברקת קלאסי',  sku: '178864'),
      SmartBrand(name: 'ברקת מונובלוק פרגמון', tag: 'גוון פרגמון', sku: '178867'),
      SmartBrand(name: 'ברקת מונובלוק אפור',   tag: 'גוון אפור',    sku: '178870'),
    ],
    acc: [
      SmartAcc(name: 'אטם בין מיכל לאסלה', emoji: '⚫', price: 24, why: 'איטום החיבור — חובה', must: true),
      SmartAcc(
        name: 'מצוף מילוי מכני',
        emoji: '🔧',
        why: 'בקרת מילוי — חובה',
        must: true,
        sku: '642102',
      ),
      SmartAcc(name: 'ברגי קיבוע', emoji: '🔩', price: 14, why: 'מחזיק את המיכל לאסלה', must: true),
      SmartAcc(name: 'לחצן הדחה', emoji: '⏹️', price: 65, why: 'הכפתור (אם לא כלול)', must: false),
    ],
  ),

  // ===== אסלות — חיבורים וחלקים פנימיים =====
  SmartProduct(
    key: 'toiletBend',
    name: 'זקיף אסלה — חיבור ליציאה',
    emoji: '🚽',
    cat: 'אסלות',
    diagramTitle: 'חיבור האסלה לקו הביוב',
    stages: _st,
    brands: [
      SmartBrand(
        name: 'ברך אסלה לבן עם אום',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '140870',
      ),
      SmartBrand(
        name: 'חיבור ישיר DN110 קצר',
        tag: 'חיבור ישיר',
        sku: '211805',
      ),
    ],
    acc: [
      SmartAcc(name: 'אטם דו צדדי', emoji: '⚫', price: 18, why: 'אוטם את הזקיף — חובה', must: true),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום נוסף', must: true),
      SmartAcc(
        name: 'מצמד לצינור DN110',
        emoji: '🔌',
        why: 'אם צריך לחבר לצינור קיים',
        must: false,
        sku: '196575',
      ),
      SmartAcc(name: 'מפתח צינורות', emoji: '🔩', price: 39, why: 'להידוק האום', must: false),
    ],
  ),
  SmartProduct(
    key: 'toiletParts',
    name: 'מצופים וחלקים פנימיים',
    emoji: '🔧',
    cat: 'אסלות',
    diagramTitle: 'תיקון/החלפת מצוף מילוי',
    stages: _st,
    brands: [
      SmartBrand(
        name: 'מצוף הידראולי 3/8-1/2',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '686366',
      ),
      SmartBrand(
        name: 'מצוף מילוי מכני',
        tag: 'מכני חסכוני',
        sku: '642102',
      ),
    ],
    acc: [
      SmartAcc(name: 'אטם לחיבור מים', emoji: '⚫', price: 12, why: 'מונע נזילות — חובה', must: true),
      SmartAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4, why: 'אוטם את ההברגה — חובה', must: true),
      SmartAcc(name: 'ברז זוויתי 1/2"', emoji: '🔧', price: 22, why: 'לסגירת המים בעת תיקון', must: true),
      SmartAcc(name: 'מפתח צינורות', emoji: '🔩', price: 39, why: 'להידוק', must: false),
    ],
  ),

  // ===== ניקוז — מחסומים גלויים, מסעפים, מאספים, אטמים, תבריג =====
  SmartProduct(
    key: 'visibleTrap',
    name: 'מחסום (סיפון) גלוי',
    emoji: '🚰',
    cat: 'ניקוז וצנרת',
    diagramTitle: 'התקנת מחסום גלוי — איטום + הברגה',
    stages: _strap,
    brands: [
      SmartBrand(
        name: 'מחסום אמריקאי 1¼" לכיור רחצה',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '217861',
      ),
      SmartBrand(
        name: 'מחסום 1¼" עם יציאה למזגן',
        tag: 'עם יציאה למזגן',
        sku: '213055',
      ),
      SmartBrand(name: 'מחסום 2" לכיור מטבח',         tag: 'למטבח',       sku: '116124'),
      SmartBrand(name: 'מחסום 2" כפול למטבח',          tag: 'מטבח כפול',   sku: '116652'),
      SmartBrand(name: 'מחסום 1½" למכונת כביסה',       tag: 'מכונת כביסה', sku: '171190'),
      SmartBrand(name: 'סיפון אמריקאי בודד 2"',         tag: 'גדול',         sku: '209447'),
    ],
    acc: [
      SmartAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4, why: 'אוטם את ההברגה — חובה', must: true),
      SmartAcc(
        name: 'אטם דו צדדי 32/50',
        emoji: '⚫',
        why: 'מונע נזילה בחיבור — חובה',
        must: true,
        sku: '558463',
      ),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום בין הסיפון למשטח', must: true),
      SmartAcc(name: 'מפתח צינורות', emoji: '🔧', price: 39, why: 'להידוק', must: false),
      SmartAcc(
        name: 'מאריך למחסום',
        emoji: '📏',
        why: 'אם המרחק לקיר ארוך מהרגיל',
        must: false,
        sku: '610949',
      ),
    ],
  ),
  SmartProduct(
    key: 'drainageManifold',
    name: 'מסעפים וחיבורי אסלה',
    emoji: '🔗',
    cat: 'ניקוז וצנרת',
    diagramTitle: 'התקנת מסעף — איטום + חיבור 3 קווים',
    stages: _si,
    brands: [
      SmartBrand(
        name: 'מסעף 87° DN110/110',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '116556',
      ),
      SmartBrand(name: 'מסעף 45° DN110/110', tag: 'זווית מתונה',  sku: '116571'),
      SmartBrand(name: 'מסעף 90° DN110 ת"ב', tag: 'עם תבריג',     sku: '116684'),
      SmartBrand(name: 'מסעף 110/50/50',     tag: 'יציאות כפולות', sku: '218564'),
      SmartBrand(name: 'מסעף כפול 110×3',    tag: 'כפול לעומקים', sku: '218176'),
      SmartBrand(name: 'ברך אסלה 75/50',     tag: 'חיבור אסלה',  sku: '217533'),
    ],
    acc: [
      SmartAcc(name: 'אטם דו צדדי DN50', emoji: '⚫', why: 'אוטם את החיבור — חובה', must: true, sku: '506527'),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום נוסף', must: true),
      SmartAcc(name: 'מצמד חיתוכי', emoji: '🔌', why: 'לחיבור לצינור', must: false, sku: '116680'),
      SmartAcc(name: 'ברך 87° DN110', emoji: '↩️', why: 'לשינוי כיוון', must: false, sku: '142289'),
      SmartAcc(name: 'מפתח צינורות', emoji: '🔩', price: 39, why: 'להידוק האומים', must: false),
    ],
  ),
  SmartProduct(
    key: 'roofCollector',
    name: 'מאספים וקולטי גג',
    emoji: '🏠',
    cat: 'ניקוז וצנרת',
    diagramTitle: 'התקנת מאסף רצפה / קולט גג',
    stages: _si,
    brands: [
      SmartBrand(
        name: 'מאסף רצפה 130/50',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '116638',
      ),
      SmartBrand(name: 'מאסף נפילה פנימית 130/50', tag: 'נפילה ישרה',   sku: '217648'),
      SmartBrand(name: 'מאסף נפילה 50° 130/50',     tag: 'בזווית',       sku: '116640'),
      SmartBrand(name: 'מאסף 110 נפילה 4"',          tag: 'גדול',         sku: '116175'),
      SmartBrand(name: 'קולט A 50/100 גבוה',         tag: 'קולט גג',      sku: '171191'),
      SmartBrand(name: 'מחסום רצפה תיקני 130/50',    tag: 'תיקני',         sku: '196587'),
    ],
    acc: [
      SmartAcc(name: 'מכסה / רשת לבן',     emoji: '⬜', why: 'גמר עליון — חובה', must: true, sku: '610911'),
      SmartAcc(name: 'מכסה / רשת פרגמון',  emoji: '🟤', why: 'גמר עליון בצבע',   must: false, sku: '635736'),
      SmartAcc(name: 'רשת פנימית עגולה',    emoji: '🕸️', why: 'סינון פנימי',      must: true, sku: '610906'),
      SmartAcc(name: 'מכסה זמני',           emoji: '🚧', why: 'הגנה בזמן עבודה', must: false, sku: '610921'),
      SmartAcc(name: 'סיליקון סניטרי',     emoji: '🧴', price: 21, why: 'איטום סופי', must: true),
    ],
  ),

  // ===== אסלות — מושב אסלה כ-SmartProduct נפרד =====
  SmartProduct(
    key: 'toiletSeat',
    name: 'מושב אסלה',
    emoji: '⭕',
    cat: 'אסלות',
    diagramTitle: 'התקנת מושב אסלה',
    stages: _st,
    brands: [
      SmartBrand(
        name: 'מושב תרמופלסטי לבן',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '220943',
      ),
      SmartBrand(name: 'מושב טבור soft-close לבן',  tag: 'סגירה רכה',     sku: '187133'),
      SmartBrand(name: 'מושב כרמל soft-close לבן',  tag: 'סגירה רכה+',    sku: '195425'),
      SmartBrand(name: 'מושב ULTRA טרמו',            tag: 'תרמו חזק',      sku: '224286'),
      SmartBrand(name: 'מושב ציר נירוסטה',          tag: 'ציר חזק',       sku: '218361'),
      SmartBrand(name: 'מושב מס.3 פרגמון',           tag: 'גוון פרגמון',  sku: '116703'),
      SmartBrand(name: 'מושב הרמון לבן',              tag: 'דגם הרמון',     sku: '179046'),
    ],
    acc: [
      SmartAcc(name: 'ברגי קיבוע למושב', emoji: '🔩', price: 9, why: 'מחזיק את המושב — חובה', must: true),
      SmartAcc(name: 'אומים לקיבוע',       emoji: '⚙️', price: 6, why: 'משלים את הברגה — חובה', must: true),
      SmartAcc(name: 'אטם לקיבוע',          emoji: '⚫', price: 8, why: 'מונע רעידות', must: false),
    ],
  ),

  // ===== אביזרי קצה וחיבורים — תבריג ואטמים =====
  SmartProduct(
    key: 'threadFittings',
    name: 'אביזרי תבריג — ברכיים ומסעפים',
    emoji: '🔩',
    cat: 'אביזרי קצה וחיבורים',
    diagramTitle: 'חיבור עם אביזרי תבריג',
    stages: _si,
    brands: [
      SmartBrand(
        name: 'ברך 90° תבריג כפול DN50',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '116661',
      ),
      SmartBrand(name: 'ברך 45° תבריג כפול DN50/50',   tag: 'זווית מתונה',  sku: '116201'),
      SmartBrand(name: 'ברך 45° תבריג כפול DN110/110', tag: 'גדול',          sku: '116666'),
      SmartBrand(name: 'ברך 90° תבריג כפול DN110',     tag: 'יציאה ראשית',  sku: '116659'),
      SmartBrand(name: 'ברך טלסקופית 90° רב תכליתי',   tag: 'טלסקופית',      sku: '170643'),
      SmartBrand(name: 'מסעף 90° תבריג DN50/50/50',     tag: 'מסעף 90°',     sku: '116687'),
      SmartBrand(name: 'מחבר כפול תבריג DN50/50',       tag: 'מחבר כפול',    sku: '116675'),
    ],
    acc: [
      SmartAcc(
        name: 'אטם דו צדדי DN50',
        emoji: '⚫',
        why: 'אוטם את ההברגה — חובה',
        must: true,
        sku: '506527',
      ),
      SmartAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4, why: 'איטום ההברגה — חובה', must: true),
      SmartAcc(name: 'מפתח צינורות', emoji: '🔧', price: 39, why: 'להידוק', must: true),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום נוסף', must: false),
      SmartAcc(
        name: 'מחבר כפול DN40',
        emoji: '🔗',
        why: 'אם צריך מעבר 40',
        must: false,
        sku: '196172',
      ),
    ],
  ),
  SmartProduct(
    key: 'sealsAndPlugs',
    name: 'אטמים, אומים ופקקים',
    emoji: '⚫',
    cat: 'אביזרי קצה וחיבורים',
    diagramTitle: 'בחירת אטם / פקק לחיבור',
    stages: _si,
    brands: [
      SmartBrand(
        name: 'אטם דו צדדי DN50',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '506527',
      ),
      SmartBrand(name: 'אטם דו צדדי DN40',  tag: 'קטן',           sku: '506522'),
      SmartBrand(name: 'אטם דו צדדי 32/50', tag: 'מעבר 32/50',  sku: '558463'),
      SmartBrand(name: 'אטם דו צדדי DN60',  tag: 'גדול',          sku: '555703'),
      SmartBrand(name: 'אטם כדורי DN50/40', tag: 'כדורי',         sku: '506537'),
      SmartBrand(name: 'אטם חתך שטוח DN46', tag: 'שטוח',          sku: '506539'),
      SmartBrand(name: 'אטם לכוס 2"',         tag: 'לכוס',          sku: '506525'),
      SmartBrand(name: 'פקק למאסף ולמחסום 2"', tag: 'פקק',          sku: '218126'),
      SmartBrand(name: 'פקק שטוח לתבריג 1.25"', tag: 'פקק תבריג',  sku: '611051'),
    ],
    acc: [
      SmartAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4, why: 'אוטם את ההברגה — חובה', must: true),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום משלים', must: true),
      SmartAcc(name: 'מפתח צינורות', emoji: '🔧', price: 39, why: 'להידוק נכון', must: false),
      SmartAcc(name: 'דבק PVC', emoji: '🪣', price: 28, why: 'לאיטום חזק יותר', must: false),
    ],
  ),

  // ===== אביזרים נלווים — כלי עבודה =====
  SmartProduct(
    key: 'tools',
    name: 'כלי עבודה',
    emoji: '🔧',
    cat: 'אביזרים נלווים',
    diagramTitle: 'כלים בסיסיים להתקנה',
    brands: [
      SmartBrand(
        name: 'מפתח לאביק',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '610758',
      ),
      SmartBrand(name: 'מפתח צינורות 12"',  tag: 'חזק וגדול'),
      SmartBrand(name: 'מפתח צינורות 14"',  tag: 'גדול במיוחד'),
      SmartBrand(name: 'מפתח שוודי',          tag: 'מתכוונן'),
    ],
    acc: [
      SmartAcc(name: 'סרט טפלון',         emoji: '🎗️', price: 4,  why: 'אוטם את ההברגה', must: true),
      SmartAcc(name: 'סיליקון סניטרי',   emoji: '🧴', price: 21, why: 'איטום כללי',     must: true),
      SmartAcc(name: 'דבק PVC',            emoji: '🪣', price: 28, why: 'לאיטום חזק',     must: false),
      SmartAcc(name: 'משור לצינור',        emoji: '🪚', price: 35, why: 'לחיתוך צינורות', must: false),
      SmartAcc(name: 'סכין יפנית',         emoji: '🔪', price: 12, why: 'לקצירה ופירוק',  must: false),
    ],
  ),

  // ===== ניקוז — פיצול 'צינורות' ל-3 סוגים (אפור / רב-שכבתי / SILENT) =====
  SmartProduct(
    key: 'pvcPipeGray',
    name: 'צינור אפור — ניקוז ראשי',
    emoji: '⚫',
    cat: 'ניקוז וצנרת',
    diagramTitle: 'הנחת קו ניקוז ראשי (אפור)',
    stages: _si,
    brands: [
      SmartBrand(
        name: 'צינור אפור DN110 L=200',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '116622',
      ),
      SmartBrand(name: 'צינור אפור DN110 L=100', tag: 'קצר',          sku: '116099'),
      SmartBrand(name: 'צינור אפור DN110 L=300', tag: 'ארוך',          sku: '116103'),
      SmartBrand(name: 'צינור אפור DN75 L=100',  tag: 'בינוני קצר',   sku: '116084'),
      SmartBrand(name: 'צינור אפור DN75 L=300',  tag: 'בינוני ארוך', sku: '116091'),
      SmartBrand(name: 'צינור אפור DN50 L=100',  tag: 'קטן',           sku: '119967'),
      SmartBrand(name: 'צינור אפור DN40 L=100',  tag: 'קטן במיוחד', sku: '116606'),
    ],
    acc: [
      SmartAcc(name: 'מצמד חיתוכי',   emoji: '🔌', why: 'לחיבור — חובה',     must: true, sku: '116680'),
      SmartAcc(name: 'ברך 87° DN110',  emoji: '↩️', why: 'לשינוי כיוון',       must: true, sku: '142289'),
      SmartAcc(name: 'אטם דו צדדי DN50', emoji: '⚫', why: 'איטום החיבור',    must: true, sku: '506527'),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום משלים', must: true),
      SmartAcc(name: 'משור לצינור',   emoji: '🪚', price: 35, why: 'לחיתוך באורך', must: false),
    ],
  ),
  SmartProduct(
    key: 'pvcPipeMultilayer',
    name: 'צנרת רב-שכבתית PP-MD-ML',
    emoji: '🪀',
    cat: 'ניקוז וצנרת',
    diagramTitle: 'הנחת צנרת רב-שכבתית — לקיר/רצפה',
    stages: _si,
    brands: [
      SmartBrand(
        name: 'PP-MD-ML SN8 DN110 L=100',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '224169',
      ),
      SmartBrand(name: 'PP-MD-ML SN8 DN110 L=100 (חזק)', tag: 'גרסת SN8 חזקה', sku: '224344'),
      SmartBrand(name: 'PP-MD-ML SN4 DN110 L=50',         tag: 'קצר',            sku: '224170'),
      SmartBrand(name: 'PP-MD-ML SN4 DN160 L=50',         tag: 'גדול קצר',      sku: '224187'),
      SmartBrand(name: 'PP-MD-ML SN4 DN160 L=100',        tag: 'גדול בינוני',  sku: '224186'),
      SmartBrand(name: 'PP-MD-ML SN4 DN160 L=300',        tag: 'גדול ארוך',    sku: '224185'),
    ],
    acc: [
      SmartAcc(name: 'מצמד חיתוכי לרב-שכבתי', emoji: '🔌', why: 'חיבור מיוחד — חובה', must: true),
      SmartAcc(name: 'אטם דו צדדי DN50', emoji: '⚫', why: 'איטום',         must: true, sku: '506527'),
      SmartAcc(name: 'סיליקון סניטרי',   emoji: '🧴', price: 21, why: 'איטום משלים', must: true),
      SmartAcc(name: 'משור לצינור',     emoji: '🪚', price: 35, why: 'לחיתוך',      must: false),
    ],
  ),
  SmartProduct(
    key: 'pvcPipeSilent',
    name: 'צנרת SILENT — ניקוז שקט',
    emoji: '🤫',
    cat: 'ניקוז וצנרת',
    diagramTitle: 'הנחת צנרת SILENT — מגורים שקטים',
    stages: _si,
    brands: [
      SmartBrand(
        name: 'SILENT DN110 L=300',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '273201',
      ),
      SmartBrand(name: 'SILENT DN110 L=100', tag: 'בינוני',          sku: '273202'),
      SmartBrand(name: 'SILENT DN110 L=50',  tag: 'קצר',              sku: '273203'),
      SmartBrand(name: 'SILENT DN110 L=25',  tag: 'קצר במיוחד',    sku: '273215'),
      SmartBrand(name: 'SILENT DN75 L=300',  tag: 'בינוני ארוך',    sku: '273216'),
      SmartBrand(name: 'SILENT DN160 L=300', tag: 'גדול ארוך',      sku: '273219'),
    ],
    acc: [
      SmartAcc(name: 'מצמד שקט',       emoji: '🔌', why: 'חיבור שקט — חובה',     must: true),
      SmartAcc(name: 'אטם דו צדדי',     emoji: '⚫', why: 'איטום החיבור',        must: true, sku: '506527'),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום משלים',  must: true),
      SmartAcc(name: 'ברך 87° DN110',  emoji: '↩️', why: 'לשינוי כיוון',           must: false, sku: '142289'),
      SmartAcc(name: 'חומר בידוד',      emoji: '🧵', price: 45, why: 'להגברת השקט',  must: false),
    ],
  ),

  // ===== אסלות — מושב soft-close פרימיום =====
  SmartProduct(
    key: 'toiletSeatSoftClose',
    name: 'מושב אסלה Soft-Close',
    emoji: '⭕',
    cat: 'אסלות',
    diagramTitle: 'התקנת מושב soft-close',
    stages: _st,
    brands: [
      SmartBrand(
        name: 'מושב טבור soft-close לבן',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '187133',
      ),
      SmartBrand(name: 'מושב טבור soft-close פרגמון', tag: 'גוון פרגמון',   sku: '197134'),
      SmartBrand(name: 'מושב כרמל soft-close לבן',   tag: 'דגם כרמל לבן', sku: '195425'),
      SmartBrand(name: 'מושב כרמל soft-close פרגמון', tag: 'כרמל פרגמון',  sku: '195506'),
    ],
    acc: [
      SmartAcc(name: 'ברגי קיבוע למושב', emoji: '🔩', price: 14, why: 'מחזיק את המושב — חובה', must: true),
      SmartAcc(name: 'אומים לקיבוע',       emoji: '⚙️', price: 8,  why: 'משלים את ההברגה',     must: true),
      SmartAcc(name: 'אטם לקיבוע',          emoji: '⚫', price: 10, why: 'בולם רעידות',            must: false),
      SmartAcc(name: 'מפתח אלן',             emoji: '🔧', price: 18, why: 'להידוק הברגים',         must: false),
    ],
  ),

  // ===== ניקוז — סיפון מטבח (פיצול ייעודי) =====
  SmartProduct(
    key: 'kitchenDrain',
    name: 'סיפון לכיור מטבח',
    emoji: '🍽️',
    cat: 'ניקוז וצנרת',
    diagramTitle: 'התקנת סיפון מטבח — עם כניסה למדיח',
    stages: _strap,
    brands: [
      SmartBrand(
        name: 'סיפון 2" לכיור מטבח בודד',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '116124',
      ),
      SmartBrand(
        name: 'סיפון 2" לכיור מטבח כפול',
        tag: 'מטבח כפול',
        sku: '116652',
      ),
      SmartBrand(
        name: 'סיפון 2" כפול עם כניסה למדיח',
        tag: 'עם כניסה למדיח',
        sku: '116127',
      ),
      SmartBrand(
        name: 'סיפון 2" בודד מס׳ 1',
        tag: 'גרסה משופרת',
        sku: '116649',
      ),
    ],
    acc: [
      SmartAcc(name: 'סרט טפלון',          emoji: '🎗️', price: 4,  why: 'אוטם הברגה — חובה', must: true),
      SmartAcc(name: 'אטם דו צדדי DN50',   emoji: '⚫', why: 'מונע נזילות — חובה',           must: true, sku: '506527'),
      SmartAcc(name: 'סיליקון סניטרי',    emoji: '🧴', price: 21, why: 'איטום בין הסיפון לקיר', must: true),
      SmartAcc(name: 'צינור גמיש למדיח', emoji: '〰️', price: 28, why: 'אם יש מדיח כלים',     must: false),
      SmartAcc(name: 'מפתח צינורות',      emoji: '🔧', price: 39, why: 'להידוק',                must: false),
    ],
  ),

  // ===== ניקוז — סיפון מכונת כביסה =====
  SmartProduct(
    key: 'washingMachineDrain',
    name: 'סיפון למכונת כביסה',
    emoji: '🧺',
    cat: 'ניקוז וצנרת',
    diagramTitle: 'התקנת סיפון למכונת כביסה',
    stages: _strap,
    brands: [
      SmartBrand(
        name: 'מחסום 1½" למכונת כביסה',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '171190',
      ),
      SmartBrand(name: 'מחסום 1½" למכ. כביסה (20 ארז.)', tag: 'אריזה גדולה', sku: '171189'),
      SmartBrand(name: 'מחסום 1½" למכ. כביסה (פרימיום)', tag: 'דגם מורחב',   sku: '218495'),
    ],
    acc: [
      SmartAcc(name: 'צינור גמיש למכונה',  emoji: '〰️', price: 32, why: 'מחבר את הניקוז — חובה', must: true),
      SmartAcc(name: 'אטם דו צדדי 32/50',   emoji: '⚫', why: 'מונע נזילות',                       must: true, sku: '558463'),
      SmartAcc(name: 'סרט טפלון',           emoji: '🎗️', price: 4, why: 'איטום ההברגה',             must: true),
      SmartAcc(name: 'סיליקון סניטרי',     emoji: '🧴', price: 21, why: 'איטום חיצוני',            must: false),
      SmartAcc(name: 'מתקן תלייה לצינור', emoji: '🔩', price: 14, why: 'לקיבוע הצינור',            must: false),
    ],
  ),

  // ===== אביזרי קצה — ברכיים תבריג ייעודי =====
  SmartProduct(
    key: 'threadElbows',
    name: 'ברכיים תבריג — לכל גודל',
    emoji: '↪️',
    cat: 'אביזרי קצה וחיבורים',
    diagramTitle: 'חיבור ברך תבריג',
    stages: _si,
    brands: [
      SmartBrand(
        name: 'ברך 90° תבריג כפול DN50/50',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '116661',
      ),
      SmartBrand(name: 'ברך 90° תבריג צד אחד DN50',   tag: 'צד אחד',        sku: '116191'),
      SmartBrand(name: 'ברך 90° תבריג צד אחד DN40',   tag: 'קטן צד אחד',   sku: '116186'),
      SmartBrand(name: 'ברך 90° תבריג כפול DN40/40',  tag: 'קטן כפול',     sku: '116182'),
      SmartBrand(name: 'ברך 90° תבריג כפול DN50/40',  tag: 'מעבר 50→40', sku: '119934'),
      SmartBrand(name: 'ברך 90° תבריג כפול DN75/75',  tag: 'בינוני',        sku: '116663'),
      SmartBrand(name: 'ברך 90° תבריג כפול DN110',    tag: 'יציאה ראשית',  sku: '116659'),
      SmartBrand(name: 'ברך 90° ש"ת לסיפון DN50/50',   tag: 'לסיפון',         sku: '204127'),
    ],
    acc: [
      SmartAcc(name: 'אטם דו צדדי DN50', emoji: '⚫', why: 'אוטם — חובה',     must: true, sku: '506527'),
      SmartAcc(name: 'סרט טפלון',         emoji: '🎗️', price: 4, why: 'איטום ההברגה', must: true),
      SmartAcc(name: 'מפתח צינורות',     emoji: '🔧', price: 39, why: 'להידוק',       must: true),
      SmartAcc(name: 'סיליקון סניטרי',   emoji: '🧴', price: 21, why: 'איטום משלים', must: false),
    ],
  ),

  // ===== ניקוז — מאסף רצפה ייעודי (פיצול מ'מאספים') =====
  SmartProduct(
    key: 'floorCollector',
    name: 'מאסף רצפה — מקלחת/חצר',
    emoji: '🟦',
    cat: 'ניקוז וצנרת',
    diagramTitle: 'התקנת מאסף רצפה מתחת לרצפה',
    stages: _sw,
    brands: [
      SmartBrand(
        name: 'מאסף רצפה 130/50',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '116638',
      ),
      SmartBrand(name: 'מאסף 130/50 נפילה פנימית',  tag: 'נפילה ישרה',  sku: '217648'),
      SmartBrand(name: 'מאסף 130/50 נפילה 50°',      tag: 'בזווית',      sku: '116640'),
      SmartBrand(name: 'מאסף 110 נפילה 4"',          tag: 'גדול',         sku: '116175'),
    ],
    acc: [
      SmartAcc(name: 'מכסה/רשת לבן',          emoji: '⬜', why: 'גמר עליון — חובה', must: true,  sku: '610911'),
      SmartAcc(name: 'רשת פנימית עגולה',       emoji: '🕸️', why: 'סינון פנימי',      must: true,  sku: '610906'),
      SmartAcc(name: 'מכסה עגול עליון קבוע',  emoji: '🔘', why: 'נראות מוקפדת',     must: false, sku: '610918'),
      SmartAcc(name: 'מכסה זמני',               emoji: '🚧', why: 'הגנה בזמן עבודה', must: false, sku: '610921'),
      SmartAcc(name: 'רשת שרוול עגולה',         emoji: '🕷️', why: 'מסנן שיער',         must: false, sku: '610933'),
      SmartAcc(name: 'סיליקון סניטרי',         emoji: '🧴', price: 21, why: 'איטום סופי', must: true),
    ],
  ),

  // ===== ברזים — ברזי ניל וניתוק =====
  SmartProduct(
    key: 'shutoffValve',
    name: 'ברז ניל / ניתוק',
    emoji: '🔧',
    cat: 'ברזים וכיורים',
    diagramTitle: 'התקנת ברז ניל — סגירת מים נקודתית',
    stages: _sf,
    brands: [
      SmartBrand(
        name: 'רותם ברז ניל פתיחה קלה 1/2"×1/2"',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '77775268',
      ),
      SmartBrand(name: 'רותם ברז ניל 1/2"×3/8"',         tag: 'גודל מעבר',    sku: '77775269'),
      SmartBrand(name: 'דיור ברז ניל כפול 1/2"×1/2"',     tag: 'כפול',          sku: '77775255'),
      SmartBrand(name: 'דיור ברז ניל כפול 1/2"×3/8"',     tag: 'כפול מעבר',  sku: '77775259'),
      SmartBrand(name: 'דיור ברז 3/4" + יציאה למדיח+מטהר', tag: 'משולש',         sku: '77775257'),
      SmartBrand(name: 'דיור ברז כביסה מיני',              tag: 'למכונה',       sku: '77775254'),
      SmartBrand(name: 'דיור ברז אחורי למדיח',             tag: 'אחורי למדיח', sku: '77775258'),
    ],
    acc: [
      SmartAcc(name: 'סרט טפלון',         emoji: '🎗️', price: 4, why: 'אוטם את ההברגה — חובה', must: true),
      SmartAcc(name: 'אטם דו צדדי',       emoji: '⚫', price: 8, why: 'איטום החיבור',           must: true),
      SmartAcc(name: 'מפתח צינורות',     emoji: '🔧', price: 39, why: 'להידוק',                  must: true),
      SmartAcc(name: 'צינור גמיש 1/2"', emoji: '〰️', price: 28, why: 'אם צריך להאריך',          must: false),
    ],
  ),

  // ===== מקלחות — ראשי מקלחת ייעודי =====
  SmartProduct(
    key: 'showerHead',
    name: 'ראשי מקלחת',
    emoji: '🚿',
    cat: 'מקלחות ואמבטיות',
    diagramTitle: 'התקנת ראש מקלחת קבוע',
    stages: _ss,
    brands: [
      SmartBrand(
        name: 'דיור ראש מקלחת ניקל עגול 250 מ"מ',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '7777708C',
      ),
      SmartBrand(name: 'דיור ראש מקלחת ניקל עגול 200 מ"מ',     tag: 'קטן יותר',  sku: '7777707C'),
      SmartBrand(name: 'דיור ראש מט שחור עגול 250 מ"מ',          tag: 'שחור מט',  sku: '7777708B'),
      SmartBrand(name: 'דיור ראש מט שחור עגול 200 מ"מ',          tag: 'שחור קטן', sku: '7777707B'),
      SmartBrand(name: 'דיור ראש ניקל מרובע 250 מ"מ',             tag: 'מרובע גדול', sku: '7777711C'),
      SmartBrand(name: 'דיור ראש ניקל מרובע 200 מ"מ',             tag: 'מרובע קטן',  sku: '7777710C'),
      SmartBrand(name: 'פלורה ראש דוש 5 מצבים',                    tag: '5 מצבים',     sku: '77701170'),
    ],
    acc: [
      SmartAcc(name: 'זרוע למקלחת',     emoji: '⤴️', price: 95,  why: 'מחזיק את הראש — חובה', must: true),
      SmartAcc(name: 'סרט טפלון',       emoji: '🎗️', price: 4,  why: 'איטום ההברגה — חובה',  must: true),
      SmartAcc(name: 'מפתח צינורות',   emoji: '🔧', price: 39, why: 'להידוק',                  must: false),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום נוסף',              must: false),
      SmartAcc(name: 'צינור גמיש למקלחת', emoji: '〰️', price: 48, why: 'אם רוצים גם מזלף יד', must: false),
    ],
  ),

  // ===== מקלחות — מזלפי יד =====
  SmartProduct(
    key: 'handSprayer',
    name: 'מזלף יד (מקלחת ידנית)',
    emoji: '🤚',
    cat: 'מקלחות ואמבטיות',
    diagramTitle: 'התקנת מזלף יד עם צינור גמיש',
    stages: _ss,
    brands: [
      SmartBrand(
        name: 'תבור מזלף קומפלט',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '77701125',
      ),
      SmartBrand(name: 'קורל מזלף קומפלט 3 מצבים',     tag: '3 מצבים',     sku: '77701135'),
      SmartBrand(name: 'רותם מזלף קומפלט זהב מוברש', tag: 'זהב מוברש',   sku: '77701205'),
      SmartBrand(name: 'רותם מקלח יד שחור 3 מצבים',  tag: 'שחור 3 מצבים', sku: '77701203'),
      SmartBrand(name: 'תבור מקלח יד',                    tag: 'בסיסי',         sku: '77701130'),
      SmartBrand(name: 'הדר מקלח יד 5 מצבים',           tag: '5 מצבים',     sku: '77701150'),
      SmartBrand(name: 'מזלף לברז נשלף',                  tag: 'לברז נשלף',    sku: '77701195'),
    ],
    acc: [
      SmartAcc(name: 'צינור גמיש למקלחת', emoji: '〰️', price: 48, why: 'מחבר את המזלף — חובה', must: true),
      SmartAcc(name: 'מתקן תלייה',         emoji: '🔩', price: 32, why: 'להחזקה כשלא בשימוש',    must: true),
      SmartAcc(name: 'אטם דו צדדי',         emoji: '⚫', price: 6,  why: 'איטום החיבור',             must: true),
      SmartAcc(name: 'סרט טפלון',           emoji: '🎗️', price: 4, why: 'איטום ההברגה',             must: false),
    ],
  ),

  // ===== מקלחות — מערכות שטיפה ופינוק =====
  SmartProduct(
    key: 'showerSystem',
    name: 'מערכת שטיפה / פינוק',
    emoji: '✨',
    cat: 'מקלחות ואמבטיות',
    diagramTitle: 'התקנת מערכת מקלחת מורכבת (סוללה + ראש + מזלף)',
    stages: _ss,
    brands: [
      SmartBrand(
        name: 'מלודי מערכת שטיפה ניקל מפוארת',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '77777086',
      ),
      SmartBrand(name: 'מלודי מערכת שטיפה זהב מפוארת', tag: 'גרסת זהב',    sku: '77777087'),
      SmartBrand(name: 'גרנדה מערכת שטיפה ניקל מפוארת', tag: 'דגם גרנדה',    sku: '77777088'),
      SmartBrand(name: 'דיור דולפין פלוס ניקל',           tag: 'דולפין ניקל', sku: '77110166'),
      SmartBrand(name: 'דיור דולפין פלוס שחור',           tag: 'דולפין שחור', sku: '77110177'),
      SmartBrand(name: 'דיור ראש מתיזן ניקל',              tag: 'מתיזן',         sku: '77110164'),
    ],
    acc: [
      SmartAcc(name: 'סוללה לסוללת מקלחת',  emoji: '🎛️', price: 280, why: 'הגוף הסמוי — חובה', must: true),
      SmartAcc(name: 'זרוע + ראש מקלחת',     emoji: '⤴️', price: 220, why: 'החלק הנראה',         must: true),
      SmartAcc(name: 'צינור גמיש למקלחת',    emoji: '〰️', price: 48,  why: 'למזלף',                must: true),
      SmartAcc(name: 'מתקן תלייה למזלף',     emoji: '🔩', price: 32,  why: 'להחזקה',              must: false),
      SmartAcc(name: 'סיליקון סניטרי',        emoji: '🧴', price: 21,  why: 'איטום סופי',          must: true),
    ],
  ),

  // ===== ניקוז — מכסים ורשתות לרצפה =====
  SmartProduct(
    key: 'floorCover',
    name: 'מכסים ורשתות לרצפה',
    emoji: '⬜',
    cat: 'ניקוז וצנרת',
    diagramTitle: 'בחירת מכסה/רשת למאסף רצפה',
    stages: _si,
    brands: [
      SmartBrand(
        name: 'מכסה ניקל מרובע 4"',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '777Z3081',
      ),
      SmartBrand(name: 'רשת ניקל מרובעת 4"',           tag: 'רשת ניקל',    sku: '777Z3060'),
      SmartBrand(name: 'רשת נחושת מרובעת 4"',          tag: 'נחושת',         sku: '777Z3079A'),
      SmartBrand(name: 'רשת נחושת מונחת מרובעת 4"',   tag: 'נחושת מונחת', sku: '777Z3064'),
      SmartBrand(name: 'רשת שחור מונח מרובע 4"',         tag: 'שחור',          sku: '777Z3068'),
      SmartBrand(name: 'מכסה ניקל מרובע + אטם HDPE',     tag: 'עם אטם',       sku: '77Z2081C'),
      SmartBrand(name: 'רשת ניקל מרובעת + אטם HDPE',     tag: 'רשת עם אטם', sku: '77Z2079C'),
    ],
    acc: [
      SmartAcc(name: 'מאסף רצפה 130/50', emoji: '🟦', why: 'הבסיס — חובה',     must: true, sku: '116638'),
      SmartAcc(name: 'אטם דו צדדי',       emoji: '⚫', price: 12, why: 'איטום',  must: true),
      SmartAcc(name: 'סיליקון סניטרי',   emoji: '🧴', price: 21, why: 'איטום עליון', must: true),
      SmartAcc(name: 'רשת פנימית עגולה', emoji: '🕸️', why: 'סינון',                must: false, sku: '610906'),
    ],
  ),

  // ===== ניקוז — תעלות ניקוז למקלחת =====
  SmartProduct(
    key: 'drainChannel',
    name: 'תעלת ניקוז למקלחת',
    emoji: '📐',
    cat: 'ניקוז וצנרת',
    diagramTitle: 'התקנת תעלת ניקוז ארוכה',
    stages: _sw,
    brands: [
      SmartBrand(
        name: 'סיגמא פלוס תעלת ניקוז 60 ס"מ',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '77575320',
      ),
      SmartBrand(name: 'סיגמא פלוס תעלה 40 ס"מ',          tag: 'קצרה',        sku: '77575310'),
      SmartBrand(name: 'סיגמא פלוס תעלה 50 ס"מ',          tag: 'בינונית',    sku: '77575315'),
      SmartBrand(name: 'סיגמא פלוס תעלה 70 ס"מ',          tag: 'ארוכה',       sku: '77575325'),
      SmartBrand(name: 'סיגמא פלוס תעלה 90 ס"מ',          tag: 'ארוכה במיוחד', sku: '77575335'),
      SmartBrand(name: 'תעלה מנירוסטה מלוי עצמי 40',     tag: 'נירוסטה 40',  sku: '77575328'),
      SmartBrand(name: 'תעלה מנירוסטה מלוי עצמי 60',     tag: 'נירוסטה 60',  sku: '77575327'),
    ],
    acc: [
      SmartAcc(name: 'מחסום רצפה 130/50',    emoji: '🟦', why: 'הניקוז שמתחת — חובה', must: true, sku: '116638'),
      SmartAcc(name: 'יריעת איטום',           emoji: '🛡️', price: 320, why: 'איטום הרצפה',    must: true),
      SmartAcc(name: 'סרט איטום לפינות',    emoji: '🧵', price: 36,  why: 'חיזוק תורפה',     must: true),
      SmartAcc(name: 'דבק אריחים גמיש',     emoji: '🪣', price: 420, why: 'הדבקת האריחים',  must: true),
      SmartAcc(name: 'סיליקון סניטרי',       emoji: '🧴', price: 21,  why: 'איטום סופי',       must: true),
    ],
  ),

  // ===== ברזים — צינורות גמישים לברז =====
  SmartProduct(
    key: 'flexHose',
    name: 'צינור גמיש לברז',
    emoji: '〰️',
    cat: 'ברזים וכיורים',
    diagramTitle: 'חיבור צינור גמיש בין הברז לקיר',
    stages: _sf,
    brands: [
      SmartBrand(name: 'זוג צינור לברז פרח 50 ס"מ', tag: 'הבחירה שלנו', rec: true, sku: '77381050'),
      SmartBrand(name: 'זוג צינור לברז פרח 40 ס"מ', tag: 'קצר',         sku: '77381040'),
      SmartBrand(name: 'זוג צינור לברז פרח 60 ס"מ', tag: 'ארוך',         sku: '77381060'),
      SmartBrand(name: 'צינור מתכת משוריין 1/2×1/2 40', tag: 'משוריין קצר', sku: '77121240'),
      SmartBrand(name: 'צינור משוריין 50 ס"מ',           tag: 'משוריין',      sku: '77121250'),
      SmartBrand(name: 'צינור משוריין 60 ס"מ',           tag: 'משוריין ארוך', sku: '77121260'),
      SmartBrand(name: 'מאריך לברז ניל 3/8×3/8 15 ס"מ',   tag: 'מאריך קצר',  sku: '77383815'),
    ],
    acc: [
      SmartAcc(name: 'אטם דו צדדי 1/2"', emoji: '⚫', price: 6,  why: 'איטום החיבור — חובה', must: true),
      SmartAcc(name: 'סרט טפלון',         emoji: '🎗️', price: 4, why: 'אוטם ההברגה',          must: true),
      SmartAcc(name: 'ברז ניל 1/2"',      emoji: '🔧', price: 22, why: 'לסגירת מים',           must: false),
      SmartAcc(name: 'מפתח צינורות',     emoji: '🔩', price: 39, why: 'להידוק',                must: false),
    ],
  ),

  // ===== אסלות — אביזרי אסלה =====
  SmartProduct(
    key: 'toiletAccessories',
    name: 'אביזרי אסלה — חיבורים ופקקים',
    emoji: '🧷',
    cat: 'אסלות',
    diagramTitle: 'חיבור אסלה למיכל ולקו ביוב',
    stages: _st,
    brands: [
      SmartBrand(name: 'חיבור אסלה שרשורי משופר', tag: 'הבחירה שלנו', rec: true, sku: '77003223'),
      SmartBrand(name: 'אטם מנגית אקסנטר 4',      tag: 'אטם אקסנטר',  sku: '77777010'),
      SmartBrand(name: 'דיור ניפל אקסנטר 020',    tag: 'ניפל 20 מ"מ', sku: '777P1020'),
      SmartBrand(name: 'דיור ניפל אקסנטר 040',    tag: 'ניפל 40 מ"מ', sku: '777P1040'),
      SmartBrand(name: 'דיור ניפל אקסנטר 060',    tag: 'ניפל 60 מ"מ', sku: '777P1060'),
      SmartBrand(name: 'סט ניפל לאסלה סמויה',     tag: 'לאסלה תלויה', sku: '77777400'),
      SmartBrand(name: 'פקק פלסטיק 1/2" שחור',    tag: 'פקק שחור',    sku: '77777777'),
    ],
    acc: [
      SmartAcc(name: 'סרט טפלון',         emoji: '🎗️', price: 4,  why: 'אוטם ההברגה — חובה', must: true),
      SmartAcc(name: 'סיליקון סניטרי',   emoji: '🧴', price: 21, why: 'איטום סופי — חובה',  must: true),
      SmartAcc(name: 'אטם דו צדדי',       emoji: '⚫', price: 12, why: 'איטום החיבור',         must: true),
      SmartAcc(name: 'מפתח אלן',           emoji: '🔧', price: 18, why: 'להידוק',                must: false),
    ],
  ),

  // ===== מקלחות — מערכות אמבטיה =====
  SmartProduct(
    key: 'bathSystem',
    name: 'מערכת פינוק לאמבטיה',
    emoji: '🛁',
    cat: 'מקלחות ואמבטיות',
    diagramTitle: 'התקנת מערכת פינוק על האמבטיה',
    stages: _sb,
    brands: [
      SmartBrand(name: 'קונקורד מערכת פינוק מרובע',  tag: 'הבחירה שלנו', rec: true, sku: '77701200'),
      SmartBrand(name: 'טרפז שחור ראש עגול',          tag: 'שחור עגול',  sku: '77701202'),
      SmartBrand(name: 'טרפז שחור ראש מרובע',         tag: 'שחור מרובע', sku: '77701201'),
      SmartBrand(name: 'אוסלו לחורים קיימים',          tag: 'התקנה קלה',  sku: '77701116'),
    ],
    acc: [
      SmartAcc(name: 'סוללה לסוללת אמבט', emoji: '🎛️', price: 320, why: 'הגוף הסמוי — חובה', must: true),
      SmartAcc(name: 'זרוע אמבט',            emoji: '⤴️', price: 110, why: 'החלק הנראה',          must: true),
      SmartAcc(name: 'צינור גמיש לאמבט',  emoji: '〰️', price: 58,  why: 'למזלף',                 must: true),
      SmartAcc(name: 'מזלף יד',              emoji: '🤚', price: 120, why: 'אם לא כלול',           must: false),
      SmartAcc(name: 'סיליקון סניטרי',     emoji: '🧴', price: 21,  why: 'איטום',                  must: true),
    ],
  ),

  // ===== אביזרים נלווים — אביזרי חדר רחצה =====
  SmartProduct(
    key: 'bathroomFittings',
    name: 'אביזרי חדר רחצה',
    emoji: '🧴',
    cat: 'אביזרים נלווים',
    diagramTitle: 'התקנת מתלים ואביזרים לחדר רחצה',
    brands: [
      SmartBrand(name: 'דיור מוט מגבת בודד',     tag: 'הבחירה שלנו', rec: true, sku: '77775283'),
      SmartBrand(name: 'דיור טבעת למגבת',        tag: 'טבעת',         sku: '77775282'),
      SmartBrand(name: 'דיור קולב בודד',          tag: 'קולב',          sku: '77775288'),
      SmartBrand(name: 'דיור סבונייה נוזלי',      tag: 'סבונייה',     sku: '77775287'),
      SmartBrand(name: 'דיור מחזיק נייר פתוח',   tag: 'נייר פתוח',  sku: '77775281'),
      SmartBrand(name: 'דיור מחזיק נייר סגור',   tag: 'נייר סגור',  sku: '77775280'),
    ],
    acc: [
      SmartAcc(name: 'ברגים ודיבלים',  emoji: '🔩', price: 14, why: 'לקיבוע לקיר — חובה', must: true),
      SmartAcc(name: 'מקדח 6 מ"מ',     emoji: '🪛', price: 28, why: 'לקדיחה בקיר',         must: false),
      SmartAcc(name: 'פלס',              emoji: '📏', price: 32, why: 'יישור אופקי',         must: false),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום מסביב',         must: false),
    ],
  ),

  // ===== ניקוז — סיפונים נוספים =====
  SmartProduct(
    key: 'otherTraps',
    name: 'סיפונים נוספים',
    emoji: '🌀',
    cat: 'ניקוז וצנרת',
    diagramTitle: 'התקנת סיפון גמיש לכיור',
    stages: _strap,
    brands: [
      SmartBrand(name: 'סיפון 1¼" לכיור רחיצה',    tag: 'הבחירה שלנו', rec: true, sku: '77771012'),
      SmartBrand(name: 'סיפון שרשורי גמיש 1¼"',    tag: 'גמיש 1¼"',   sku: '77003220'),
      SmartBrand(name: 'סיפון שרשורי גמיש 2"',     tag: 'גמיש 2"',     sku: '77003221'),
      SmartBrand(name: 'ונטיל אמריקאי עם סיפון',   tag: 'עם ונטיל',   sku: '77771271'),
    ],
    acc: [
      SmartAcc(name: 'אטם דו צדדי 32/50',  emoji: '⚫', why: 'איטום — חובה', must: true, sku: '558463'),
      SmartAcc(name: 'סרט טפלון',           emoji: '🎗️', price: 4, why: 'אוטם ההברגה', must: true),
      SmartAcc(name: 'סיליקון סניטרי',     emoji: '🧴', price: 21, why: 'איטום',         must: true),
      SmartAcc(name: 'מפתח צינורות',      emoji: '🔧', price: 39, why: 'להידוק',          must: false),
    ],
  ),

  // ===== אביזרים נלווים — דיורים ופיות =====
  SmartProduct(
    key: 'spoutHousings',
    name: 'דיורים ופיות',
    emoji: '🚿',
    cat: 'אביזרים נלווים',
    diagramTitle: 'הוספת פייה לברז קיים',
    brands: [
      SmartBrand(name: 'דיור פיה לברז פרח קצר',           tag: 'הבחירה שלנו', rec: true, sku: '77772411'),
      SmartBrand(name: 'דיור פיה לברז מהקיר קצר',         tag: 'מהקיר',         sku: '77772413'),
      SmartBrand(name: 'דיור פיה לברז נחש מהקיר כבד',    tag: 'נחש כבד',     sku: '77772414'),
      SmartBrand(name: 'דיור מערכת פינוק מפוארת',         tag: 'מערכת מפוארת', sku: '77775292'),
    ],
    acc: [
      SmartAcc(name: 'סרט טפלון',         emoji: '🎗️', price: 4,  why: 'אוטם ההברגה — חובה', must: true),
      SmartAcc(name: 'אטם דו צדדי',       emoji: '⚫', price: 6,  why: 'איטום החיבור',        must: true),
      SmartAcc(name: 'מפתח צינורות',     emoji: '🔧', price: 39, why: 'להידוק',                must: false),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום נוסף',            must: false),
    ],
  ),

  // ===== מקלחות — זרועות דוש =====
  SmartProduct(
    key: 'showerArm',
    name: 'זרוע דוש למקלחת',
    emoji: '⤴️',
    cat: 'מקלחות ואמבטיות',
    diagramTitle: 'הוספת זרוע יציבה לראש המקלחת',
    stages: _ss,
    brands: [
      SmartBrand(name: 'זרוע דוש 40 ס"מ מפואר',         tag: 'הבחירה שלנו', rec: true, sku: '77701191'),
      SmartBrand(name: 'זרוע דוש 30 ס"מ מפואר',         tag: 'קצרה',         sku: '77701190'),
      SmartBrand(name: 'דיור זרוע מרובע 40 ס"מ מפואר', tag: 'מרובע 40',     sku: '77701193'),
      SmartBrand(name: 'דיור זרוע מרובע 30 ס"מ מפואר', tag: 'מרובע 30',     sku: '77701192'),
    ],
    acc: [
      SmartAcc(name: 'ראש מקלחת',     emoji: '🚿', price: 240, why: 'החלק הזורם — חובה', must: true),
      SmartAcc(name: 'סרט טפלון',     emoji: '🎗️', price: 4,  why: 'איטום ההברגה',       must: true),
      SmartAcc(name: 'מפתח צינורות', emoji: '🔧', price: 39, why: 'להידוק',                must: false),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום נוסף',          must: false),
    ],
  ),

  // ===== מקלחות — צינורות מקלחת =====
  SmartProduct(
    key: 'showerHose',
    name: 'צינור מקלחת גמיש',
    emoji: '〰️',
    cat: 'מקלחות ואמבטיות',
    diagramTitle: 'חיבור צינור גמיש בין סוללה למזלף',
    stages: _ss,
    brands: [
      SmartBrand(name: 'צינור ספירלה כפולה 1.5 מטר', tag: 'הבחירה שלנו', rec: true, sku: '77701155'),
      SmartBrand(name: 'צינור ספירלה כפולה 2 מטר',   tag: 'ארוך',          sku: '77701160'),
      SmartBrand(name: 'צינור ספירלה 1.5 מטר',        tag: 'ספירלה רגילה', sku: '77701113'),
      SmartBrand(name: 'צינור ספירלה 2 מטר',           tag: 'ספירלה ארוך', sku: '77701114'),
      SmartBrand(name: 'צינור משוריין לברז נשלף',     tag: 'משוריין',       sku: '77701196'),
    ],
    acc: [
      SmartAcc(name: 'מזלף יד',              emoji: '🤚', price: 95, why: 'בקצה הצינור — חובה', must: true),
      SmartAcc(name: 'מתקן תלייה למזלף',   emoji: '🔩', price: 32, why: 'להחזקה',                must: true),
      SmartAcc(name: 'אטם דו צדדי',          emoji: '⚫', price: 6,  why: 'איטום החיבור',         must: true),
      SmartAcc(name: 'סרט טפלון',            emoji: '🎗️', price: 4, why: 'אוטם ההברגה',           must: false),
    ],
  ),

  // ===== מקלחות — ערכות רחצה =====
  SmartProduct(
    key: 'bathingKit',
    name: 'ערכת אביזרי רחצה',
    emoji: '🎁',
    cat: 'מקלחות ואמבטיות',
    diagramTitle: 'התקנת ערכת אביזרים מלאה לחדר רחצה',
    brands: [
      SmartBrand(
        name: 'אקווה סט 5 חלקים ניקל',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '778580',
      ),
      SmartBrand(name: 'אקווה סט 5 חלקים שחור מט', tag: 'שחור מט', sku: '778581'),
    ],
    acc: [
      SmartAcc(name: 'ברגים ודיבלים',  emoji: '🔩', price: 14, why: 'לקיבוע — חובה',     must: true),
      SmartAcc(name: 'מקדח 6 מ"מ',     emoji: '🪛', price: 28, why: 'לקדיחה בקיר',         must: true),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום',               must: false),
      SmartAcc(name: 'פלס',              emoji: '📏', price: 32, why: 'יישור',               must: false),
    ],
  ),

  // ===== אסלות — יחידות אסלה+כיור מלאות =====
  SmartProduct(
    key: 'toiletUnit',
    name: 'אסלה קומפלט (יחידה מלאה)',
    emoji: '🚽',
    cat: 'אסלות',
    diagramTitle: 'התקנת אסלה קומפלט עם מיכל ומושב',
    stages: _st,
    brands: [
      SmartBrand(
        name: 'פיטרה מונבלוק קומפלט + מושב הידראולי לבן',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '77771010',
      ),
      SmartBrand(name: 'פיטרה אסלה P לבן', tag: 'גרסה רגילה', sku: '77771008'),
    ],
    acc: [
      SmartAcc(name: 'ברגי קיבוע לאסלה', emoji: '🔩', price: 18, why: 'לרצפה — חובה',     must: true),
      SmartAcc(name: 'אטם בין מיכל לאסלה', emoji: '⚫', price: 24, why: 'איטום — חובה', must: true),
      SmartAcc(name: 'זקיף אסלה',          emoji: '🚽', why: 'חיבור לקו ביוב', must: true, sku: '140870'),
      SmartAcc(name: 'מצוף מילוי',         emoji: '🔧', why: 'בקרת מילוי',     must: true, sku: '686366'),
      SmartAcc(name: 'סיליקון סניטרי',    emoji: '🧴', price: 21, why: 'איטום סופי',       must: true),
    ],
  ),

  // ===== אסלות — מנגנונים =====
  SmartProduct(
    key: 'toiletMechanism',
    name: 'מנגנונים לאסלה',
    emoji: '⚙️',
    cat: 'אסלות',
    diagramTitle: 'החלפת מנגנון פנימי במיכל הדחה',
    stages: _st,
    brands: [
      SmartBrand(
        name: 'מנגנון כרמי 40',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '777M1807',
      ),
    ],
    acc: [
      SmartAcc(name: 'אטם לחיבור מים',   emoji: '⚫', price: 12, why: 'מונע נזילות — חובה', must: true),
      SmartAcc(name: 'סרט טפלון',         emoji: '🎗️', price: 4,  why: 'אוטם ההברגה',         must: true),
      SmartAcc(name: 'ברז זוויתי 1/2"',  emoji: '🔧', price: 22, why: 'לסגירת מים בתיקון',  must: true),
      SmartAcc(name: 'מצוף מילוי',         emoji: '🔧', why: 'אם צריך להחליף', must: false, sku: '686366'),
    ],
  ),

  // ===== גופי תברואה — ידיות אחיזה לנכים =====
  SmartProduct(
    key: 'grabBars',
    name: 'ידיות אחיזה לנכים',
    emoji: '🤝',
    cat: 'אביזרים נלווים',
    diagramTitle: 'התקנת ידית אחיזה בטיחותית',
    brands: [
      SmartBrand(
        name: 'דיור ידית אחיזה 40 ס"מ',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '77775290',
      ),
      SmartBrand(name: 'דיור ידית אחיזה 30 ס"מ', tag: 'קצרה',   sku: '77775289'),
      SmartBrand(name: 'דיור ידית אחיזה 60 ס"מ', tag: 'ארוכה',  sku: '77775291'),
    ],
    acc: [
      SmartAcc(name: 'ברגי קיבוע חזקים', emoji: '🔩', price: 24, why: 'אחיזה לקיר — חובה', must: true),
      SmartAcc(name: 'דיבלים לבטון',     emoji: '⚙️', price: 18, why: 'לקירות בטון',         must: true),
      SmartAcc(name: 'מקדח 8 מ"מ',       emoji: '🪛', price: 38, why: 'לקדיחה בבטון',       must: false),
      SmartAcc(name: 'סיליקון סניטרי',   emoji: '🧴', price: 21, why: 'איטום',                must: false),
    ],
  ),

  // ===== מקלחות — אביזרי מקלחת =====
  SmartProduct(
    key: 'showerAccessories',
    name: 'אביזרי מקלחת קטנים',
    emoji: '🛠️',
    cat: 'מקלחות ואמבטיות',
    diagramTitle: 'הוספת אביזרים זוטרים למקלחת קיימת',
    stages: _ss,
    brands: [
      SmartBrand(
        name: 'מעדן זרימה קצר ניקל מתכוונן',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '77701180',
      ),
      SmartBrand(name: 'סעף דו כיווני כרום', tag: 'מפצל',          sku: '77701172'),
      SmartBrand(name: 'מתלה מתכוונן',        tag: 'מתלה גובה',    sku: '77701185'),
    ],
    acc: [
      SmartAcc(name: 'סרט טפלון',         emoji: '🎗️', price: 4,  why: 'אוטם ההברגה — חובה', must: true),
      SmartAcc(name: 'אטם דו צדדי',       emoji: '⚫', price: 6,  why: 'איטום החיבור',         must: true),
      SmartAcc(name: 'מפתח אלן',           emoji: '🔧', price: 18, why: 'להידוק',                must: false),
    ],
  ),

  // ===== ברזים — סטי הידוק וחיבורים =====
  SmartProduct(
    key: 'tighteningSet',
    name: 'סט הידוק לברזים',
    emoji: '🧰',
    cat: 'ברזים וכיורים',
    diagramTitle: 'הידוק ברז עם רוזטה ושטומים',
    stages: _sf,
    brands: [
      SmartBrand(
        name: 'סט הידוק לברז פרח בורג אחד',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '77772605',
      ),
      SmartBrand(name: 'למד+רוזטה ושתומים לסוללה', tag: 'לסוללה', sku: '77772606'),
    ],
    acc: [
      SmartAcc(name: 'סרט טפלון',         emoji: '🎗️', price: 4,  why: 'אוטם ההברגה — חובה', must: true),
      SmartAcc(name: 'מפתח אלן',           emoji: '🔧', price: 18, why: 'להידוק — חובה',         must: true),
      SmartAcc(name: 'מפתח צינורות',     emoji: '🔩', price: 39, why: 'להידוק חזק יותר',       must: false),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום נוסף',            must: false),
    ],
  ),

  // ===== ניקוז — מחברי HDPE (פלסטיק מקצועי) =====
  SmartProduct(
    key: 'hdpeConnector',
    name: 'מחברי HDPE — פלסטיק מקצועי',
    emoji: '🔗',
    cat: 'ניקוז וצנרת',
    diagramTitle: 'חיבור HDPE עם מצמד אלקטרופוזיה',
    stages: _si,
    brands: [
      SmartBrand(
        name: 'מצמד HDPE 25×25',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '9102502510',
      ),
      SmartBrand(name: 'מצמד HDPE 20×20', tag: 'קטן',           sku: '9102002010'),
      SmartBrand(name: 'מצמד HDPE 20×25', tag: 'מעבר 20→25',   sku: '910250080'),
      SmartBrand(name: 'מצמד HDPE 16×20', tag: 'הקטן ביותר', sku: '9102002004'),
      SmartBrand(name: 'מצמד HDPE 32×25', tag: 'מעבר 32→25',   sku: '9103202580'),
      SmartBrand(name: 'מצמד HDPE 40×25', tag: 'מעבר 40→25',   sku: '9104002580'),
    ],
    acc: [
      SmartAcc(name: 'מכונת אלקטרופוזיה', emoji: '⚡', why: 'להלחמת המצמד — חובה', must: true),
      SmartAcc(name: 'מקצועיסט HDPE',     emoji: '👷', why: 'התקנה מומלצת',         must: true),
      SmartAcc(name: 'משור לצינור',       emoji: '🪚', price: 35, why: 'לחיתוך באורך', must: false),
      SmartAcc(name: 'מד מרחק',              emoji: '📏', price: 38, why: 'למידה מדויקת', must: false),
    ],
  ),

  // ===== אביזרי קצה — אביזרי נחושת =====
  SmartProduct(
    key: 'copperFittings',
    name: 'אביזרי נחושת לקווי מים',
    emoji: '🟫',
    cat: 'אביזרי קצה וחיבורים',
    diagramTitle: 'חיבור צנרת נחושת בהלחמה',
    stages: _si,
    brands: [
      SmartBrand(
        name: 'ניפל כפול נחושת ארוך 1"',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '77777643',
      ),
      SmartBrand(name: 'ניפל כפול נחושת ארוך 3/4"', tag: 'גודל בינוני',  sku: '77777642'),
      SmartBrand(name: 'כפה נחושת 1/2"',              tag: 'כפה קטנה',     sku: '77777101'),
      SmartBrand(name: 'כפה נחושת 3/4"',              tag: 'כפה בינונית', sku: '77777102'),
      SmartBrand(name: 'כפה נחושת 1"',                 tag: 'כפה גדולה',   sku: '77777103'),
      SmartBrand(name: 'מופה נחושת 1/2"',              tag: 'מופה קטנה',    sku: '77777104'),
    ],
    acc: [
      SmartAcc(name: 'בורה ללחימת נחושת', emoji: '🔥', why: 'להלחמה — חובה',     must: true),
      SmartAcc(name: 'פלקס לנחושת',         emoji: '🧪', price: 28, why: 'הכנת השטח — חובה', must: true),
      SmartAcc(name: 'סיכת הלחמה',          emoji: '🪡', price: 18, why: 'חומר ההלחמה',         must: true),
      SmartAcc(name: 'מקצרה לנחושת',        emoji: '✂️', price: 95, why: 'לחיתוך נקי',          must: false),
      SmartAcc(name: 'משחזת',                  emoji: '🪨', price: 32, why: 'להכנת השטח',          must: false),
    ],
  ),

  // ===== ברזים — ברזי מעבר כדוריים =====
  SmartProduct(
    key: 'transitValve',
    name: 'ברז מעבר כדורי',
    emoji: '⚙️',
    cat: 'ברזים וכיורים',
    diagramTitle: 'התקנת ברז מעבר על קו המים הראשי',
    stages: _sf,
    brands: [
      SmartBrand(
        name: 'ברז מעבר כדורי ח.פ 3/4"',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '77777312',
      ),
      SmartBrand(name: 'ברז כדורי 1"',     tag: 'גדול',         sku: '77777313'),
      SmartBrand(name: 'ברז כדורי 1¼"',   tag: 'גדול יותר',   sku: '77777314'),
      SmartBrand(name: 'ברז כדורי 1½"',   tag: 'תעשייתי',     sku: '77777315'),
      SmartBrand(name: 'ברז כדורי 2"',     tag: 'ראשי',          sku: '77777316'),
      SmartBrand(name: 'ברז כדורי פ.פ 1/2"', tag: 'קטן פ.פ',  sku: '77777201'),
    ],
    acc: [
      SmartAcc(name: 'סרט טפלון',         emoji: '🎗️', price: 4,  why: 'אוטם ההברגה — חובה', must: true),
      SmartAcc(name: 'אטם דו צדדי',       emoji: '⚫', price: 12, why: 'איטום החיבור',         must: true),
      SmartAcc(name: 'מפתח צינורות',     emoji: '🔧', price: 39, why: 'להידוק',                must: true),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום נוסף',            must: false),
    ],
  ),

  // ===== גינון והשקיה — ציוד גן =====
  SmartProduct(
    key: 'gardenHose',
    name: 'צינור גן להשקיה',
    emoji: '🌿',
    cat: 'גינון והשקיה',
    diagramTitle: 'הזנת מים לגינה',
    brands: [
      SmartBrand(
        name: 'צינור גן ½" 25 מטר',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '10361325',
      ),
      SmartBrand(name: 'צינור גן ½" 20 מטר',  tag: 'קצר',     sku: '10361320'),
      SmartBrand(name: 'צינור גן ½" 30 מטר',  tag: 'בינוני',  sku: '10361330'),
      SmartBrand(name: 'צינור גן ½" 50 מטר',  tag: 'ארוך',     sku: '10361350'),
      SmartBrand(name: 'צינור גן ¾" 25 מטר',  tag: 'גדול קצר', sku: '10361425'),
      SmartBrand(name: 'צינור גן ¾" 50 מטר',  tag: 'גדול ארוך', sku: '10361426'),
    ],
    acc: [
      SmartAcc(name: 'ברז גן 3/4" כבד',  emoji: '🚰', why: 'לחיבור לקיר — חובה', must: true, sku: '77777345'),
      SmartAcc(name: 'מצמד לצינור גן',   emoji: '🔗', price: 18, why: 'חיבור לברז',         must: true),
      SmartAcc(name: 'ראש מתיז',           emoji: '🚿', price: 32, why: 'להשקיה רחבה',         must: false),
      SmartAcc(name: 'גלגלת לצינור',     emoji: '🔄', price: 240, why: 'אחסון מסודר',         must: false),
    ],
  ),

  // ===== גינון והשקיה — ברזי גן =====
  SmartProduct(
    key: 'gardenTap',
    name: 'ברז גן כבד',
    emoji: '🚰',
    cat: 'גינון והשקיה',
    diagramTitle: 'התקנת ברז גן חיצוני',
    brands: [
      SmartBrand(
        name: 'ברז גן ¾" כבד',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '77777345',
      ),
      SmartBrand(name: 'ברז גן ½" כבד', tag: 'קטן', sku: '77777341'),
    ],
    acc: [
      SmartAcc(name: 'סרט טפלון',         emoji: '🎗️', price: 4,  why: 'אוטם ההברגה — חובה', must: true),
      SmartAcc(name: 'אטם דו צדדי',       emoji: '⚫', price: 12, why: 'איטום',                 must: true),
      SmartAcc(name: 'מפתח צינורות',     emoji: '🔧', price: 39, why: 'להידוק',                must: true),
      SmartAcc(name: 'מצמד לצינור גן',   emoji: '🔗', price: 18, why: 'לחיבור לצינור',        must: false),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום נוסף',            must: false),
    ],
  ),

  // ===== ניקוז — מחברי NTM (חיבורי PEX מקצועיים) =====
  SmartProduct(
    key: 'ntmConnector',
    name: 'מחברי NTM — קווי מים PEX',
    emoji: '🔧',
    cat: 'ניקוז וצנרת',
    diagramTitle: 'חיבור PEX עם מקשרי NTM',
    stages: _si,
    brands: [
      SmartBrand(name: 'מקשר כפול NTM 25×25', tag: 'הבחירה שלנו', rec: true, sku: '77401535'),
      SmartBrand(name: 'מקשר כפול NTM 20×20', tag: 'קטן',         sku: '77401028'),
      SmartBrand(name: 'מקשר כפול NTM 32×32', tag: 'גדול',         sku: '40132444'),
      SmartBrand(name: 'מקשר מצמצם NTM 20×16', tag: 'מעבר 20→16', sku: '77401621'),
      SmartBrand(name: 'מקשר הברגה פנימית 16×1/2"', tag: 'הברגה 1/2"', sku: '77402222'),
      SmartBrand(name: 'מקשר הברגה פנימית 20×3/4"', tag: 'הברגה 3/4"', sku: '77402428'),
    ],
    acc: [
      SmartAcc(name: 'מפתח NTM ייעודי',  emoji: '🔧', price: 45, why: 'להידוק נכון — חובה',  must: true),
      SmartAcc(name: 'מקצרה לצינור',     emoji: '✂️', price: 65, why: 'לחיתוך נקי',           must: true),
      SmartAcc(name: 'אטם דו צדדי',      emoji: '⚫', price: 8,  why: 'איטום החיבור',         must: true),
      SmartAcc(name: 'צינור PEX',          emoji: '〰️', price: 380, why: 'הצנרת הראשית',      must: false),
    ],
  ),

  // ===== ניקוז — חבקי תליה =====
  SmartProduct(
    key: 'pipeClamps',
    name: 'חבקי תליה לצנרת',
    emoji: '🔩',
    cat: 'ניקוז וצנרת',
    diagramTitle: 'תליית צנרת על הקיר/תקרה',
    stages: _si,
    brands: [
      SmartBrand(name: 'חבק תליה 1" עם בידוד', tag: 'הבחירה שלנו', rec: true, sku: 'Z.0001032'),
      SmartBrand(name: 'חבק תליה 1/2" עם בידוד', tag: 'קטן',          sku: '77006010'),
      SmartBrand(name: 'חבק תליה 3/4" עם בידוד', tag: 'בינוני',       sku: 'Z.0001031'),
      SmartBrand(name: 'חבק תליה 3/4" בלי בידוד', tag: 'חסכוני',      sku: '77006031'),
      SmartBrand(name: 'חבק תליה 1" בלי בידוד', tag: 'גדול חסכוני', sku: '77006032'),
      SmartBrand(name: 'חבק תליה 1¼" עם בידוד', tag: 'גדול בידוד',  sku: 'Z.0001003'),
      SmartBrand(name: 'חבק תליה 1½" בלי בידוד', tag: 'תעשייתי',     sku: '77006034'),
    ],
    acc: [
      SmartAcc(name: 'ברגי קיבוע לקיר', emoji: '🔩', price: 18, why: 'לקיבוע — חובה', must: true),
      SmartAcc(name: 'דיבלים',             emoji: '⚙️', price: 14, why: 'בקירות בטון',  must: true),
      SmartAcc(name: 'מקדח 8 מ"מ',       emoji: '🪛', price: 38, why: 'לקדיחה',         must: false),
      SmartAcc(name: 'פלס',                  emoji: '📏', price: 32, why: 'יישור',         must: false),
    ],
  ),

  // ===== ניקוז — חבקי אומגה =====
  SmartProduct(
    key: 'omegaClamps',
    name: 'חבקי אומגה לצינורות',
    emoji: 'Ω',
    cat: 'ניקוז וצנרת',
    diagramTitle: 'הצמדת צינור לקיר עם חבק אומגה',
    stages: _si,
    brands: [
      SmartBrand(name: 'אומגה 1"',  tag: 'הבחירה שלנו', rec: true, sku: '77006082'),
      SmartBrand(name: 'אומגה 3/4"', tag: 'קטן',           sku: '77006081'),
      SmartBrand(name: 'אומגה 1¼"',  tag: 'בינוני',        sku: '77IS0001'),
      SmartBrand(name: 'אומגה 1½"',  tag: 'גדול',           sku: '77IS0002'),
      SmartBrand(name: 'אומגה 2"',    tag: 'תעשייתי',      sku: '77006085'),
      SmartBrand(name: 'אומגה 3"',    tag: 'גדול במיוחד', sku: '77006087'),
      SmartBrand(name: 'אומגה 4"',    tag: 'ראשי',           sku: '77006088'),
    ],
    acc: [
      SmartAcc(name: 'ברגי קיבוע',      emoji: '🔩', price: 14, why: 'לקיבוע — חובה', must: true),
      SmartAcc(name: 'דיבלים לבטון',    emoji: '⚙️', price: 18, why: 'לבטון',         must: true),
      SmartAcc(name: 'מקדח 8 מ"מ',     emoji: '🪛', price: 38, why: 'לקדיחה',        must: false),
    ],
  ),

  // ===== ברזים — מחלקים למים חמים/קרים =====
  SmartProduct(
    key: 'waterManifold',
    name: 'מחלק מים — יציאות מרובות',
    emoji: '🔀',
    cat: 'ברזים וכיורים',
    diagramTitle: 'התקנת מחלק מים בארון השירות',
    stages: _sf,
    brands: [
      SmartBrand(name: 'מחלק 1" 3 יציאות + ברז כחול', tag: 'הבחירה שלנו', rec: true, sku: '7609203B'),
      SmartBrand(name: 'מחלק 1" 2 יציאות + ברז כחול',   tag: 'קטן כחול',  sku: '7609202B'),
      SmartBrand(name: 'מחלק 1" 2 יציאות + ברז אדום',   tag: 'קטן אדום',  sku: '7609202R'),
      SmartBrand(name: 'מחלק 3/4" 2 יציאות + ברז כחול', tag: '3/4 כחול',  sku: '7608202B'),
      SmartBrand(name: 'מחלק 3/4" 2 יציאות + ברז אדום', tag: '3/4 אדום',  sku: '7609203R'),
      SmartBrand(name: 'מחלק 1" 4 יציאות ללא ברז',      tag: '4 יציאות',  sku: '76032204'),
      SmartBrand(name: 'מחלק 1" 3 יציאות ללא ברז',      tag: '3 ללא ברז', sku: '76032203'),
    ],
    acc: [
      SmartAcc(name: 'ארון פח למחלק 60×60', emoji: '📦', why: 'אחסון המחלק — חובה',     must: true, sku: '77901012'),
      SmartAcc(name: 'מקטין לחץ + שעון',     emoji: '📊', why: 'בקרת לחץ',                must: true, sku: '77772011'),
      SmartAcc(name: 'משחרר אוויר 1/2"',      emoji: '💨', why: 'מנקה אוויר',              must: true, sku: '77004410'),
      SmartAcc(name: 'אקווה בנד 3/4" נמוך',  emoji: '⚓', why: 'חיזוק חיבורים',           must: false, sku: '7ISR0001'),
      SmartAcc(name: 'סרט טפלון',             emoji: '🎗️', price: 4, why: 'איטום הברגות',  must: true),
    ],
  ),

  // ===== אביזרי קצה — מכשירי לחץ ומצופים =====
  SmartProduct(
    key: 'pressureDevices',
    name: 'מכשירי לחץ, מצופים ואל-חזור',
    emoji: '📊',
    cat: 'אביזרי קצה וחיבורים',
    diagramTitle: 'בקרת לחץ מים ראשית',
    stages: _si,
    brands: [
      SmartBrand(name: 'מקטין לחץ + שעון 3/4"', tag: 'הבחירה שלנו', rec: true, sku: '77772012'),
      SmartBrand(name: 'מקטין לחץ + שעון 1/2"', tag: 'גודל קטן',     sku: '77772011'),
      SmartBrand(name: 'שעון למקטין לחץ',          tag: 'חלף',            sku: '77773001'),
      SmartBrand(name: 'משחרר אוויר 1/2" אוטו',   tag: 'משחרר אוויר',  sku: '77004410'),
      SmartBrand(name: 'מצוף נחושת 1/2"',           tag: 'מצוף קטן',     sku: '77777481'),
      SmartBrand(name: 'מצוף נחושת 1"',             tag: 'מצוף גדול',    sku: '77777483'),
      SmartBrand(name: 'אל-חזור ביוב 110',           tag: 'אל-חזור',      sku: '777D0482'),
      SmartBrand(name: 'אל-חזור ביוב 160',           tag: 'אל-חזור גדול', sku: '777D0484'),
    ],
    acc: [
      SmartAcc(name: 'סרט טפלון',         emoji: '🎗️', price: 4,  why: 'אוטם ההברגה — חובה', must: true),
      SmartAcc(name: 'אטם דו צדדי',       emoji: '⚫', price: 12, why: 'איטום',                 must: true),
      SmartAcc(name: 'מפתח צינורות',     emoji: '🔧', price: 39, why: 'להידוק',                must: true),
      SmartAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21, why: 'איטום נוסף',            must: false),
    ],
  ),

  // ===== ניקוז — ניקוז גג =====
  SmartProduct(
    key: 'rooftopDrain',
    name: 'ניקוז גג — ברכי מי גשם',
    emoji: '🌧️',
    cat: 'ניקוז וצנרת',
    diagramTitle: 'הזרמת מי גשם מהגג למרזב',
    stages: _si,
    brands: [
      SmartBrand(name: 'ברך מי גשם מגולון 4"', tag: 'הבחירה שלנו', rec: true, sku: '4502A'),
      SmartBrand(name: 'ברך מי גשם מגולון 3"', tag: 'קטן',          sku: '4501A'),
    ],
    acc: [
      SmartAcc(name: 'חבק תליה 4"',         emoji: '🔩', why: 'תמיכה לקיר — חובה', must: true),
      SmartAcc(name: 'סיליקון סניטרי',     emoji: '🧴', price: 21, why: 'איטום החיבור',       must: true),
      SmartAcc(name: 'ברגי קיבוע ארוכים', emoji: '🔩', price: 18, why: 'לקיר חיצוני',         must: true),
      SmartAcc(name: 'מקדח 10 מ"מ',        emoji: '🪛', price: 48, why: 'לבטון/אבן',           must: false),
    ],
  ),

  // ===== ברזים — ברזי כיור AQUATEC =====
  SmartProduct(
    key: 'aquaBasinTap',
    name: 'ברז לכיור — AQUATEC',
    emoji: '🚰',
    cat: 'ברזים וכיורים',
    diagramTitle: 'התקנת ברז פרח לכיור רחצה',
    stages: _sf,
    brands: [
      SmartBrand(name: 'דיור ברז פרח ברבור ארוך',      tag: 'הבחירה שלנו', rec: true, sku: '777M2204'),
      SmartBrand(name: 'איביזה ברז פרח ברבור ארוך',   tag: 'איביזה',        sku: '777M1804'),
      SmartBrand(name: 'איביזה ברז פרח שטוח קצר',     tag: 'שטוח קצר',     sku: '777M2162'),
      SmartBrand(name: 'איביזה ברז פרח שטוח ארוך',    tag: 'שטוח ארוך',   sku: '777M2168'),
      SmartBrand(name: 'גליל ברז פרח גבוה לכיור מונח', tag: 'גבוה למונח', sku: '777M1122'),
      SmartBrand(name: 'בתא ברז מים קרים ידית צד',     tag: 'מים קרים',     sku: '7777113A'),
    ],
    acc: [
      SmartAcc(name: 'צינור גמיש 1/2"', emoji: '〰️', price: 28, why: 'חיבור למים — חובה', must: true),
      SmartAcc(name: 'ברז ניל 1/2"',     emoji: '🔧', price: 22, why: 'לסגירת מים — חובה', must: true),
      SmartAcc(name: 'סרט טפלון',         emoji: '🎗️', price: 4, why: 'אוטם ההברגה',        must: true),
      SmartAcc(name: 'סיפון לכיור',       emoji: '🌀', why: 'ניקוז הכיור',  must: false, sku: '217861'),
    ],
  ),

  // ===== ברזים — ברזי קיר =====
  SmartProduct(
    key: 'wallTap',
    name: 'ברז מהקיר',
    emoji: '🧱',
    cat: 'ברזים וכיורים',
    diagramTitle: 'התקנת ברז קיר עם פיה',
    stages: _sf,
    brands: [
      SmartBrand(name: 'דיור ברז מהקיר ארוך',          tag: 'הבחירה שלנו', rec: true, sku: '777M2207'),
      SmartBrand(name: 'דיור ברז מהקיר קצר',           tag: 'קצר',           sku: '777M2206'),
      SmartBrand(name: 'דיור ברז מהקיר ארוך פיית נחש', tag: 'פיית נחש',    sku: '777M2217'),
      SmartBrand(name: 'דיור ברז מהקיר קצר פיית נחש',  tag: 'נחש קצר',     sku: '777M2216'),
      SmartBrand(name: 'איביזה ברז מהקיר פיה ארוכה',   tag: 'איביזה ארוך', sku: '777M1717'),
      SmartBrand(name: 'איביזה ברז מהקיר פיה קצרה',    tag: 'איביזה קצר',  sku: '777M1716'),
    ],
    acc: [
      SmartAcc(name: 'אקסצנטרים לקיר', emoji: '⚙️', price: 38, why: 'חיבור לצנרת בקיר — חובה', must: true),
      SmartAcc(name: 'רוזטות כיסוי',    emoji: '⭕', price: 18, why: 'גמר אסתטי',                must: true),
      SmartAcc(name: 'סרט טפלון',       emoji: '🎗️', price: 4, why: 'אוטם ההברגה',              must: true),
      SmartAcc(name: 'פיה לברז',         emoji: '🚿', why: 'אם רוצים פיה אחרת', must: false, sku: '77772410'),
    ],
  ),

  // ===== ברזים — ברזי מטבח AQUATEC =====
  SmartProduct(
    key: 'aquaKitchenTap',
    name: 'ברז למטבח — AQUATEC',
    emoji: '🍽️',
    cat: 'ברזים וכיורים',
    diagramTitle: 'התקנת ברז מטבח נשלף',
    stages: _sf,
    brands: [
      SmartBrand(name: 'קיסר ברז נשלף ניקל',          tag: 'הבחירה שלנו', rec: true, sku: '779096C'),
      SmartBrand(name: 'קיסר ברז נשלף ניקל מוברש',   tag: 'ניקל מוברש',  sku: '779096S'),
      SmartBrand(name: 'קיסר ברז נשלף שחור מט',       tag: 'שחור מט',     sku: '779096B'),
      SmartBrand(name: 'קיסר ברז נשלף גרפיטי',         tag: 'גרפיטי',       sku: '779096F'),
      SmartBrand(name: 'פולו ברז פרח פיה מלבנית',     tag: 'פולו',          sku: '77777343'),
    ],
    acc: [
      SmartAcc(name: 'צינור גמיש 1/2"', emoji: '〰️', price: 28, why: 'חיבור למים — חובה', must: true),
      SmartAcc(name: 'ברז ניל כפול',     emoji: '🔧', price: 45, why: 'חם+קר — חובה',     must: true),
      SmartAcc(name: 'סרט טפלון',         emoji: '🎗️', price: 4, why: 'אוטם ההברגה',        must: true),
      SmartAcc(name: 'מסנן מים',          emoji: '💧', price: 95, why: 'סינון מי שתייה',    must: false),
    ],
  ),

  // ===== מקלחות — ברז אמבטיה AQUATEC =====
  SmartProduct(
    key: 'aquaBathTap',
    name: 'ברז אמבטיה — AQUATEC',
    emoji: '🛁',
    cat: 'מקלחות ואמבטיות',
    diagramTitle: 'התקנת סוללת אמבטיה עם מזלף',
    stages: _sb,
    brands: [
      SmartBrand(name: 'דיור ברז אמבטיה עם מזלף', tag: 'הבחירה שלנו', rec: true, sku: '777M2201'),
      SmartBrand(name: 'איביזה ברז אמבטיה',        tag: 'איביזה',        sku: '777M1801'),
    ],
    acc: [
      SmartAcc(name: 'אקסצנטרים לקיר', emoji: '⚙️', price: 38, why: 'חיבור לצנרת — חובה', must: true),
      SmartAcc(name: 'צינור גמיש למזלף', emoji: '〰️', price: 48, why: 'למזלף — חובה',     must: true),
      SmartAcc(name: 'מזלף יד',           emoji: '🤚', price: 120, why: 'אם לא כלול',       must: false),
      SmartAcc(name: 'סרט טפלון',         emoji: '🎗️', price: 4, why: 'אוטם ההברגה',        must: true),
    ],
  ),

  // ===== מקלחות — ברז מקלחת AQUATEC =====
  SmartProduct(
    key: 'aquaShowerTap',
    name: 'ברז מקלחת — AQUATEC',
    emoji: '🚿',
    cat: 'מקלחות ואמבטיות',
    diagramTitle: 'התקנת סוללת מקלחת',
    stages: _ss,
    brands: [
      SmartBrand(name: 'דיור ברז מקלחת עם מזלף', tag: 'הבחירה שלנו', rec: true, sku: '777M2208'),
      SmartBrand(name: 'איביזה ברז מקלחת',        tag: 'איביזה',        sku: '777M1808'),
    ],
    acc: [
      SmartAcc(name: 'אקסצנטרים לקיר', emoji: '⚙️', price: 38, why: 'חיבור לצנרת — חובה', must: true),
      SmartAcc(name: 'זרוע + ראש מקלחת', emoji: '⤴️', price: 220, why: 'החלק העליון',     must: true),
      SmartAcc(name: 'צינור גמיש למזלף', emoji: '〰️', price: 48, why: 'למזלף',             must: true),
      SmartAcc(name: 'סרט טפלון',         emoji: '🎗️', price: 4, why: 'אוטם ההברגה',        must: true),
    ],
  ),

  // ===== ברזים — אביזרי ברזים (פיות) =====
  SmartProduct(
    key: 'tapAccessories',
    name: 'אביזרי ברזים — פיות',
    emoji: '🔧',
    cat: 'ברזים וכיורים',
    diagramTitle: 'החלפת פיה לברז קיים',
    brands: [
      SmartBrand(name: 'דיור פיה לברז פרח ארוך',         tag: 'הבחירה שלנו', rec: true, sku: '77772410'),
      SmartBrand(name: 'דיור פיה לברז מהקיר ארוך',       tag: 'מהקיר',        sku: '77772413'),
      SmartBrand(name: 'דיור פיה לברז נחש מהקיר ארוך',   tag: 'פיית נחש',    sku: '77772415'),
    ],
    acc: [
      SmartAcc(name: 'סרט טפלון',   emoji: '🎗️', price: 4,  why: 'אוטם ההברגה — חובה', must: true),
      SmartAcc(name: 'אטם דו צדדי', emoji: '⚫', price: 6,  why: 'איטום החיבור',        must: true),
      SmartAcc(name: 'מפתח אלן',     emoji: '🔧', price: 18, why: 'להידוק',                must: false),
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

/// Find a smart product by its [key] (used to link catalog-tree leaves).
SmartProduct? smartProductByKey(String key) {
  for (final p in kSmartProducts) {
    if (p.key == key) return p;
  }
  return null;
}
