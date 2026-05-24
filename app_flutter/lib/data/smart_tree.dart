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
        name: 'ליפסקי — סיפון אמריקאי 1¼" לבן',
        tag: 'מחיר לפי ספק',
        rec: true,
        sku: '217861',
        imageAsset: 'assets/lipskey/products/217861.jpeg',
      ),
      SmartBrand(
        name: 'ליפסקי — סיפון 1¼" + יציאה למזגן',
        tag: 'עם יציאה למזגן',
        sku: '213055',
        imageAsset: 'assets/lipskey/products/213055.jpeg',
      ),
      SmartBrand(
        name: 'ליפסקי — סיפון בקבוק 1¼" כרום',
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
        name: 'ליפסקי — מחסום 245/50 פתוח גבוהה',
        tag: 'מחיר לפי ספק',
        rec: true,
        sku: '218681',
        imageAsset: 'assets/lipskey/products/218681.jpeg',
      ),
      SmartBrand(
        name: 'ליפסקי — מחסום 245/50 סגור גבוהה',
        tag: 'סגור',
        sku: '218722',
        imageAsset: 'assets/lipskey/products/218722.jpeg',
      ),
      SmartBrand(
        name: 'ליפסקי — מחסום 245/50 פתוח',
        tag: 'גובה רגיל',
        sku: '220542',
        imageAsset: 'assets/lipskey/products/220542.jpeg',
      ),
      SmartBrand(
        name: 'ליפסקי — מחסום 245/50 סגור',
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
