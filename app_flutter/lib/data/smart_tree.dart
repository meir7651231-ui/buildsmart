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
        name: 'ליפסקי — צינור DN50 200 ס"מ',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '116074',
      ),
      SmartBrand(
        name: 'ליפסקי — צינור DN50 100 ס"מ',
        tag: 'גרסה קצרה',
        sku: '221022',
      ),
      SmartBrand(
        name: 'ליפסקי — צינור DN75 200 ס"מ',
        tag: 'גודל בינוני',
        sku: '116001',
      ),
      SmartBrand(
        name: 'ליפסקי — צינור DN110 200 ס"מ',
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
        name: 'ליפסקי — ברך 87° DN50',
        tag: 'גודל סטנדרט',
        rec: true,
        sku: '116601',
      ),
      SmartBrand(name: 'ליפסקי — ברך 87° DN75',  tag: 'בינוני',           sku: '116033'),
      SmartBrand(name: 'ליפסקי — ברך 87° DN110', tag: 'יציאה ראשית',     sku: '142289'),
      SmartBrand(name: 'ליפסקי — ברך 87° DN160', tag: 'גדול במיוחד',     sku: '116028'),
      SmartBrand(
        name: 'ליפסקי — ברך 87° עם ביקורת DN110',
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
        name: 'ליפסקי — מצמד חיתוכי 50/40',
        tag: 'מעבר מ-50 ל-40',
        rec: true,
        sku: '116680',
      ),
      SmartBrand(name: 'ליפסקי — מצמד חיתוכי 40/32', tag: 'מעבר קטן',        sku: '198517'),
      SmartBrand(name: 'ליפסקי — מצמד חיתוכי 75/50', tag: 'מעבר בינוני',     sku: '119215'),
      SmartBrand(name: 'ליפסקי — מחבר כפול DN50',    tag: 'חיבור ישיר',     sku: '124533'),
      SmartBrand(name: 'ליפסקי — מחבר כפול DN75',    tag: 'בינוני',          sku: '196762'),
      SmartBrand(name: 'ליפסקי — מחבר כפול DN110',   tag: 'יציאה ראשית',    sku: '196575'),
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
        name: 'ליפסקי — טיטאן פרגמון',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '152786',
      ),
      SmartBrand(name: 'ליפסקי — טיטאן אפור',   tag: 'גוון אפור',      sku: '152787'),
      SmartBrand(name: 'ליפסקי — יהלום לבן',    tag: 'יהלום קלאסי',   sku: '145629'),
      SmartBrand(name: 'ליפסקי — יהלום פרגמון', tag: 'גוון פרגמון',  sku: '145630'),
      SmartBrand(name: 'ליפסקי — יהלום אפור',   tag: 'גוון אפור',      sku: '145631'),
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
        name: 'ליפסקי — ספיר פרגמון',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '124050',
      ),
      SmartBrand(name: 'ליפסקי — ספיר אפור',     tag: 'גוון אפור',     sku: '124051'),
      SmartBrand(name: 'ליפסקי — ברקת לבן',      tag: 'ברקת קלאסי',   sku: '170862'),
      SmartBrand(name: 'ליפסקי — ברקת פרגמון',   tag: 'גוון פרגמון',  sku: '170866'),
      SmartBrand(name: 'ליפסקי — ברקת אפור',     tag: 'גוון אפור',     sku: '170869'),
      SmartBrand(name: 'ליפסקי — טופז לבן',       tag: 'גרסה כלכלית',  sku: '116752'),
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
        name: 'ליפסקי — כינרת מונובלוק פרגמון',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '169604',
      ),
      SmartBrand(name: 'ליפסקי — ברקת מונובלוק לבן',    tag: 'ברקת קלאסי',  sku: '178864'),
      SmartBrand(name: 'ליפסקי — ברקת מונובלוק פרגמון', tag: 'גוון פרגמון', sku: '178867'),
      SmartBrand(name: 'ליפסקי — ברקת מונובלוק אפור',   tag: 'גוון אפור',    sku: '178870'),
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
        name: 'ליפסקי — ברך אסלה לבן עם אום',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '140870',
      ),
      SmartBrand(
        name: 'ליפסקי — חיבור ישיר DN110 קצר',
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
        name: 'ליפסקי — מצוף הידראולי 3/8-1/2',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '686366',
      ),
      SmartBrand(
        name: 'ליפסקי — מצוף מילוי מכני',
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
        name: 'ליפסקי — מחסום אמריקאי 1¼" לכיור רחצה',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '217861',
      ),
      SmartBrand(
        name: 'ליפסקי — מחסום 1¼" עם יציאה למזגן',
        tag: 'עם יציאה למזגן',
        sku: '213055',
      ),
      SmartBrand(name: 'ליפסקי — מחסום 2" לכיור מטבח',         tag: 'למטבח',       sku: '116124'),
      SmartBrand(name: 'ליפסקי — מחסום 2" כפול למטבח',          tag: 'מטבח כפול',   sku: '116652'),
      SmartBrand(name: 'ליפסקי — מחסום 1½" למכונת כביסה',       tag: 'מכונת כביסה', sku: '171190'),
      SmartBrand(name: 'ליפסקי — סיפון אמריקאי בודד 2"',         tag: 'גדול',         sku: '209447'),
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
        name: 'ליפסקי — מסעף 87° DN110/110',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '116556',
      ),
      SmartBrand(name: 'ליפסקי — מסעף 45° DN110/110', tag: 'זווית מתונה',  sku: '116571'),
      SmartBrand(name: 'ליפסקי — מסעף 90° DN110 ת"ב', tag: 'עם תבריג',     sku: '116684'),
      SmartBrand(name: 'ליפסקי — מסעף 110/50/50',     tag: 'יציאות כפולות', sku: '218564'),
      SmartBrand(name: 'ליפסקי — מסעף כפול 110×3',    tag: 'כפול לעומקים', sku: '218176'),
      SmartBrand(name: 'ליפסקי — ברך אסלה 75/50',     tag: 'חיבור אסלה',  sku: '217533'),
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
        name: 'ליפסקי — מאסף רצפה 130/50',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '116638',
      ),
      SmartBrand(name: 'ליפסקי — מאסף נפילה פנימית 130/50', tag: 'נפילה ישרה',   sku: '217648'),
      SmartBrand(name: 'ליפסקי — מאסף נפילה 50° 130/50',     tag: 'בזווית',       sku: '116640'),
      SmartBrand(name: 'ליפסקי — מאסף 110 נפילה 4"',          tag: 'גדול',         sku: '116175'),
      SmartBrand(name: 'ליפסקי — קולט A 50/100 גבוה',         tag: 'קולט גג',      sku: '171191'),
      SmartBrand(name: 'ליפסקי — מחסום רצפה תיקני 130/50',    tag: 'תיקני',         sku: '196587'),
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
        name: 'ליפסקי — מושב תרמופלסטי לבן',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '220943',
      ),
      SmartBrand(name: 'ליפסקי — מושב טבור soft-close לבן',  tag: 'סגירה רכה',     sku: '187133'),
      SmartBrand(name: 'ליפסקי — מושב כרמל soft-close לבן',  tag: 'סגירה רכה+',    sku: '195425'),
      SmartBrand(name: 'ליפסקי — מושב ULTRA טרמו',            tag: 'תרמו חזק',      sku: '224286'),
      SmartBrand(name: 'ליפסקי — מושב ציר נירוסטה',          tag: 'ציר חזק',       sku: '218361'),
      SmartBrand(name: 'ליפסקי — מושב מס.3 פרגמון',           tag: 'גוון פרגמון',  sku: '116703'),
      SmartBrand(name: 'ליפסקי — מושב הרמון לבן',              tag: 'דגם הרמון',     sku: '179046'),
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
        name: 'ליפסקי — ברך 90° תבריג כפול DN50',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '116661',
      ),
      SmartBrand(name: 'ליפסקי — ברך 45° תבריג כפול DN50/50',   tag: 'זווית מתונה',  sku: '116201'),
      SmartBrand(name: 'ליפסקי — ברך 45° תבריג כפול DN110/110', tag: 'גדול',          sku: '116666'),
      SmartBrand(name: 'ליפסקי — ברך 90° תבריג כפול DN110',     tag: 'יציאה ראשית',  sku: '116659'),
      SmartBrand(name: 'ליפסקי — ברך טלסקופית 90° רב תכליתי',   tag: 'טלסקופית',      sku: '170643'),
      SmartBrand(name: 'ליפסקי — מסעף 90° תבריג DN50/50/50',     tag: 'מסעף 90°',     sku: '116687'),
      SmartBrand(name: 'ליפסקי — מחבר כפול תבריג DN50/50',       tag: 'מחבר כפול',    sku: '116675'),
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
        name: 'ליפסקי — אטם דו צדדי DN50',
        tag: 'הבחירה שלנו',
        rec: true,
        sku: '506527',
      ),
      SmartBrand(name: 'ליפסקי — אטם דו צדדי DN40',  tag: 'קטן',           sku: '506522'),
      SmartBrand(name: 'ליפסקי — אטם דו צדדי 32/50', tag: 'מעבר 32/50',  sku: '558463'),
      SmartBrand(name: 'ליפסקי — אטם דו צדדי DN60',  tag: 'גדול',          sku: '555703'),
      SmartBrand(name: 'ליפסקי — אטם כדורי DN50/40', tag: 'כדורי',         sku: '506537'),
      SmartBrand(name: 'ליפסקי — אטם חתך שטוח DN46', tag: 'שטוח',          sku: '506539'),
      SmartBrand(name: 'ליפסקי — אטם לכוס 2"',         tag: 'לכוס',          sku: '506525'),
      SmartBrand(name: 'ליפסקי — פקק למאסף ולמחסום 2"', tag: 'פקק',          sku: '218126'),
      SmartBrand(name: 'ליפסקי — פקק שטוח לתבריג 1.25"', tag: 'פקק תבריג',  sku: '611051'),
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
        name: 'ליפסקי — מפתח לאביק',
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
